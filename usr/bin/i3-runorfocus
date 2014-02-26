import json
import subprocess
import sys

def get_output(cmd):
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    out = process.communicate()[0].decode()
    process.stdout.close()
    return out

def get_tree():
    cmd = ["i3-msg", "-t", "get_tree"]
    return json.loads(get_output(cmd))

def get_matching_class():
    cmd = ["xdotool", "search", "--class", sys.argv[1]]
    return get_output(cmd).split('\n')

windows = []
def walk_tree(tree):
    if tree['window']:
        windows.append({'window': str(tree['window']),
                        'focused': tree['focused']})
    if len(tree['nodes']) > 0:
        for node in tree['nodes']:
            walk_tree(node)

def get_matches():
    matches = []
    tree = get_tree()
    check = get_matching_class()
    walk_tree(tree)
    for window in windows:
        for winid in check:
            if window['window'] == winid:
                matches.append(window)
    return matches

def main():
    matches = get_matches()
    # Sort the list by window IDs
    matches = [(match['window'], match) for match in matches]
    matches.sort()
    matches = [match for (key, match) in matches]
    # Iterate over the matches to find the first focused one, then focus the
    # next one.
    for ind, match in enumerate(matches):
        if match['focused'] == True:
            subprocess.call(["i3-msg", "[id=%s] focus" % matches[(ind+1)%len(matches)]['window']])
            return
    # No focused match was found, so focus the first one
    if len(matches) > 0:
            subprocess.call(["i3-msg", "[id=%s] focus" % matches[0]['window']])
            return
    # No matches found, launch program
    subprocess.call(["i3-msg", "exec", "--no-startup-id", sys.argv[2]])

if __name__ == '__main__':
    main()
