#!/usr/bin/env python
"""Wrapper around commands that dedents/reindent partial code via textwrap.

Useful for ``black`` from an editor on selected code blocks.

Tests via ``pytest …/with-indent.py`` (the reason for the .py extension).

Ref: https://github.com/ambv/black/issues/796
"""

import textwrap
import sys
import subprocess


def dedent(stdin):
    if not stdin:
        return 0, stdin
    dedented = textwrap.dedent(stdin)
    indent = stdin.index("\n") - dedented.index("\n")
    return indent, dedented


def main(argv):
    if "-" not in argv:
        sys.stderr.write("should be used with stdin, i.e. -\n")
        sys.exit(64)

    stdin = sys.stdin.read()
    indent, dedented = dedent(stdin)

    proc = subprocess.Popen(
        argv,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    stdin = dedented.encode()
    stdout, stderr = proc.communicate(stdin)
    stdout = stdout.decode("utf8")
    if proc.returncode == 0:
        if indent:
            prefix = " " * indent
            stdout = "".join(prefix + line for line in stdout.splitlines(True))
    sys.stdout.write(stdout)
    sys.stderr.write(stderr.decode("utf8"))
    return proc.returncode


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))


class Test:
    def test_dedent(self):
        assert dedent("") == (0, "")
        assert dedent("  if True:\n    pass\n") == (2, "if True:\n  pass\n")
        assert dedent("  if True:\npass\n") == (0, "  if True:\npass\n")

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

        # Invalid.
        stdin = ["    if foo:", "pass"]
        assert run_black() == 123
        out, err = capsys.readouterr()
        assert out.splitlines() == stdin
        assert err == "error: cannot format -: Cannot parse: 2:0: pass\n"
