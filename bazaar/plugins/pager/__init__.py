"""\
Run commands producing long output in a pager ($PAGER or less).
"""

import os, sys
from bzrlib import builtins
from bzrlib.branch import Branch
from bzrlib.commands import register_command, Command
from bzrlib.osutils import format_date
from bzrlib.log import LogFormatter, log_formatter_registry

try:
    from bzrlib.plugins.bzrtools.colordiff import DiffWriter
except ImportError:
    DiffWriter = None


def setup_pager():
    # Based on the lesslog plugin by Michael Ellerman and
    # pager.c from git by Linus Torvalds
    if hasattr(sys.stdout, 'isatty'):
        target = sys.stdout
    elif isinstance(sys.stdout, DiffWriter) and hasattr(sys.stdout.target, 'isatty'):
        target = sys.stdout.target
    else:
        return
    if not target.isatty() or not hasattr(os, 'fork'):
        return

    pager = os.environ.get('PAGER', 'less').strip()
    if not pager or pager == 'cat':
        return

    fd0, fd1 = os.pipe()

    pid = os.fork()
    if pid < 0:
        os.close(fd0)
        os.close(fd1)
        return

    if pid == 0:
        os.close(fd0)
        # redirect stdout to the pipe
        os.dup2(fd1, target.fileno())
        os.close(fd1)
        return

    # redirect the pipe to stdin
    os.dup2(fd0, sys.stdin.fileno())
    os.close(fd0)
    os.close(fd1)

    os.environ['LESS'] = 'FRSX'
    os.execlp(pager, pager)
    sys.exit(255)


def run_in_pager(cmd_class):
    class wrapped_cmd_class(cmd_class):
        __doc__ = cmd_class.__doc__
        def run(self, **kwargs):
            setup_pager()
            cmd_class.run(self, **kwargs)
    wrapped_cmd_class.__name__ = cmd_class.__name__
    register_command(wrapped_cmd_class, decorate=True)


run_in_pager(builtins.cmd_log)
run_in_pager(builtins.cmd_diff)
run_in_pager(builtins.cmd_missing)
run_in_pager(builtins.cmd_cat)
run_in_pager(builtins.cmd_help)
run_in_pager(builtins.cmd_status)
run_in_pager(builtins.cmd_annotate)


class GitLogFormatter(LogFormatter):

    supports_merge_revisions = True
    supports_delta = False # TODO
    supports_diff = True
    supports_tags = True
    hide_merges = False

    def log_revision(self, revision):
        r = revision.rev
        if self.hide_merges and len(r.parent_ids) > 1:
            return
        to_file = self.to_file
        to_file.write('\033[33mrevision %s (%s)\033[m\n' % (r.revision_id, revision.revno))
        author = r.properties.get('author', None)
        if author is not None:
            to_file.write('\033[;1mAuthor:\033[m %s\n\033[;1mCommitter:\033[m %s\n' % (author, r.committer))
        else:
            to_file.write('\033[;1mAuthor:\033[m %s\n' % (r.committer,))
        to_file.write('\033[;1mDate:\033[m ' + format_date(revision.rev.timestamp, revision.rev.timezone or 0) + '\n')
        branch_nick = r.properties.get('branch-nick', None)
        if branch_nick is not None:
            to_file.write('\033[;1mBranch:\033[m %s\n' % (branch_nick,))
        if revision.tags:
            to_file.write('\033[;1mTags:\033[m \033[93m%s\033[m\n' % (', '.join(revision.tags),))
        bugs = r.properties.get('bugs', None)
        if bugs:
            to_file.write('\033[;1mBugs:\033[m \033[91m%s\033[m\n' % (bugs.replace('\n', ', '),))
        to_file.write('\n')
        for line in r.message.strip().splitlines():
            to_file.write('    ' + line + '\n')

        if revision.diff is not None:
            to_file.write('\n')
            self.show_diff(self.to_exact_file, revision.diff, '')
            to_file.write('\n')
        to_file.write('\n')

    def show_diff(self, to_file, diff, indent):
        DiffWriter(to_file).write(diff)

log_formatter_registry.register('git', GitLogFormatter, 'Git-like log format')
