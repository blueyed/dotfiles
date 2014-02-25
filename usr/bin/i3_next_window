import json
import re
import subprocess
import sys


I3MSG = '/usr/bin/i3-msg'


windows = []


def parse_args():
    if len(sys.argv) == 3:
        return (sys.argv[1], sys.argv[2])
    else:
        sys.exit('Must provide 2 arguments.')


def get_tree():
    process = subprocess.Popen([I3MSG, "-t", "get_tree"], stdout=subprocess.PIPE)
    tree = str(process.communicate()[0])
    process.stdout.close()
    return json.loads(tree)


def walk_tree(tree):
    if tree['window']:
        windows.append({
            'name': tree['name'],
            'id': str(tree['id']),
            'focused': tree['focused']
        })
    if len(tree['nodes']) > 0:
        for node in tree['nodes']:
            walk_tree(node)


def main():
    pattern, command = parse_args()

    tree = get_tree()
    walk_tree(tree)

    focused = filter(lambda x: x['focused'], windows)
    if len(focused) == 1:
        focused = focused[0]
    else:
        focused = False

    filteredWindows = filter(lambda x: re.search(pattern, x['name']), windows)

    if len(filteredWindows) == 0:
        subprocess.call([I3MSG, 'exec', '--no-startup-id', command])
    else:
        nextWindow = False

        try:
            if not focused:
                raise ValueError

            nextIndex = filteredWindows.index(focused) + 1

            if nextIndex == len(filteredWindows):
                raise ValueError
            else:
                nextWindow = filteredWindows[nextIndex]

        except ValueError:
            nextWindow = filteredWindows[0]

        con_id = nextWindow['id']

        subprocess.call([I3MSG, '[con_id=' + con_id + ']', 'focus'])


if __name__ == '__main__':
    main()

