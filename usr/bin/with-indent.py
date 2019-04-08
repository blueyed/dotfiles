#!/usr/bin/env python
"""Wrapper around commands that dedents/reindent partial code via textwrap.

Useful for ``black`` from an editor on selected code blocks.

Tests via ``pytest …/with-indent.py`` (the reason for the .py extension).

Ref: https://github.com/ambv/black/issues/796
"""
import textwrap
import sys
import subprocess


def len_firstline(s):
    return len(s.split("\n", 1)[0])


def dedent(stdin):
    if not stdin:
        return 0, stdin
    dedented = textwrap.dedent(stdin)
    removed_indent = len_firstline(stdin) - len_firstline(dedented)
    return removed_indent, dedented


def prepare(stdin):
    if stdin and stdin.startswith(" "):
        removed_indent, dedented = dedent(stdin)
        add_prefixes = max(1, removed_indent // 4)
        prefix = ""
        indent = " " * 4
        for i in range(0, add_prefixes):
            prefix += (indent * i) + "class wrappedforindent:\n"
        stdin = prefix + stdin
        return add_prefixes, stdin
    return 0, stdin


def main(argv):
    if "-" not in argv:
        sys.stderr.write("should be used with stdin, i.e. -\n")
        sys.exit(64)

    orig_stdin = sys.stdin.read()
    wrapped, dedented = prepare(orig_stdin)

    proc = subprocess.Popen(
        argv, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    proc_stdin = dedented.encode()
    stdout, stderr = proc.communicate(proc_stdin)
    stdout = stdout.decode("utf8")
    if proc.returncode == 0:
        while wrapped:
            stdout = stdout[(stdout.index("\n") + 1) :]
            wrapped -= 1
        sys.stdout.write(stdout)
    else:
        # Output original input in case of error (similar to black does it, but
        # we have changed it).
        sys.stdout.write(orig_stdin)
    sys.stdout.flush()
    sys.stderr.write(stderr.decode("utf8"))
    return proc.returncode


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))


class Test:
    def test_dedent(self):
        assert dedent("") == (0, "")
        assert dedent("  if True:\n    pass\n") == (2, "if True:\n  pass\n")
        assert dedent("  if True:\npass\n") == (0, "  if True:\npass\n")

    def test_prepare(self):
        assert prepare("") == (0, "")

        wrap_prefix = "class wrappedforindent:\n"

        in_ = "  if True:\n    pass\n"
        assert prepare(in_) == (1, wrap_prefix + in_)

        in_ = "  if True:\npass\n"
        assert prepare(in_) == (1, wrap_prefix + in_)

        in_ = "        pass\n"
        assert prepare(in_) == (2, "{0}    {0}        pass\n".format(wrap_prefix))

    def test_main_with_black(self, monkeypatch, capsys):
        stdin = []

        def read():
            nonlocal stdin
            return "\n".join(stdin)

        monkeypatch.setattr(sys.stdin, "read", read)

        def run_black():
            return main(["black", "-q", "-"])

        assert run_black() == 0
        out, err = capsys.readouterr()
        assert out == ""
        assert err == ""

        # No changes, but still indented.
        stdin = ["    if foo:", "        pass"]
        assert run_black() == 0
        out, err = capsys.readouterr()
        assert out.splitlines() == stdin
        assert err == ""

        # No changes, no indent.
        stdin = ["def foo():", "    pass"]
        assert run_black() == 0
        out, err = capsys.readouterr()
        assert out.splitlines() == stdin
        assert err == ""

        # Fixed def.
        stdin = ["  def foo():", "    pass"]
        assert run_black() == 0
        out, err = capsys.readouterr()
        assert out.splitlines() == ["    def foo():", "        pass"]
        assert err == ""

        # Multiple indents.
        stdin = ["        pass"]
        assert run_black() == 0
        out, err = capsys.readouterr()
        assert out.splitlines() == stdin
        assert err == ""

        # Invalid.
        stdin = ["    if foo:", "pass"]
        assert run_black() == 123
        out, err = capsys.readouterr()
        assert out.splitlines() == stdin
        assert err == "error: cannot format -: Cannot parse: 3:0: pass\n"
