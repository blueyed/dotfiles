"""
Used as PYTHONSTARTUP file.

Based on the example in Doc/library/readline.rst.

# The default behavior is enable tab-completion and to use
# :file:`~/.python_history` as the history save file.  To disable it, delete
# (or override) the :data:`sys.__interactivehook__` attribute in your
# :mod:`sitecustomize` or :mod:`usercustomize` module or your
# :envvar:`PYTHONSTARTUP` file.
"""

import atexit
import os
import readline

default_histfile = os.path.join(
    os.path.expanduser('~'), '.local', 'share', 'python_history')


def get_histfile(test):
    """Use history file based on project / start_filename, if it exists.

    Also used in ~/.pdbrc.py.
    """
    prev, test = None, os.path.abspath(test)
    while prev != test:
        fname = os.path.join(test, '.python_history')
        if os.path.isfile(fname):
            return fname
        prev, test = test, os.path.abspath(os.path.join(test,
                                                        os.pardir))
    return default_histfile


histfile = get_histfile(os.getcwd())
# print('Using histfile {} (via {})'.format(histfile, __file__))
print('Using histfile {} (via pythonrc)'.format(histfile))

try:
    readline.read_history_file(histfile)
    h_len = readline.get_history_length()
except FileNotFoundError:
    open(histfile, 'wb').close()
    h_len = 0


def save(prev_h_len, histfile):
    """Save the history file on exit."""
    readline.set_history_length(1000)

    if hasattr(readline, 'append_history_file'):
        new_h_len = readline.get_history_length()
        # py 3.5+
        readline.append_history_file(new_h_len - prev_h_len, histfile)
    else:
        readline.write_history_file(histfile)


atexit.register(save, h_len, histfile)
