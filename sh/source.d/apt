# Aliases and functions for apt-* command expansion.
#
# asearch:   apt-cache search
# aup:       apt-get update
# aupgrade:  aptitude upgrade -V
# asup:      apt-get update -qq && aptitude safe-upgrade
# apurge:    aptitude purge
# afs:       apt-file search
# amad:      apt-cache madison
# apol:      apt-cache policy
# apv:       Display currently installed version of a package (via apol)
#
# The following support '-g PATTERN' (via apt-cache madison).
# "asrc -g lucid hello" => "apt-get source hello=2.4-3"
# ainst:     aptitude install
# asrc:      apt-get source
# ashow:     apt-cache show
# ashowsrc:  apt-cache showsrc
#
# These are meant to work in both bash and zsh (via bashcompinit wrapper).
#
# Author: http://daniel.hahler.de/
#
# License: Public Domain
#


# Helper function: wrapper around "apt-cache madison".
#
# $1: command to execute
# $2: selection ("Sources", "Packages", "")
# $3...: options and arguments (package names)
_apt_cache_madison_grep_wrapper() {
    local PACKAGE APT_MADISON CANDIDATES CAND_VERS OLD_IFS line
    local COMMAND SELECTION GREP_FOR ARG VERBOSE DEBUG

    COMMAND="$1"; shift;
    SELECTION="$1"; shift;

    OPTIND=1
    while getopts 'g:hvd' option ; do
        case $option in
            g) GREP_FOR=$OPTARG;;
            h) echo "Usage: [-g grep] [-v] <package>..."; return 0;;
            \?) echo "Usage: [-g grep] [-v] <package>..."; return 1;;
            v) VERBOSE=1;;
            d) VERBOSE=1; DEBUG=1;;
        esac
    done
    shift $((OPTIND-1))

    if [[ -z $GREP_FOR ]]; then
        # Nothing to grep for, just execute:
        echo $COMMAND $@
        args=${*:q}
        /bin/sh -c "$COMMAND $args"
        return
    fi

    COMMAND_ARG=""
    for ARG in $@; do
        [ $VERBOSE ] && echo "Looking for '$ARG' in '$SELECTION', filtering by '$GREP_FOR'.."
        PACKAGE=""
        APT_MADISON="$( apt-cache madison "$ARG" )"
        CANDIDATES=$( echo "$APT_MADISON" | grep "$GREP_FOR" )
        [ $DEBUG ] && echo "CANDIDATES=\"$CANDIDATES\""
        if [[ -z $SELECTION ]]; then
            if [[ -n $CANDIDATES ]]; then
                PACKAGE=$( echo "$CANDIDATES" | head -n 1 | awk '{print $1"="$3}' )
            fi
        else
            # e.g. there is a Sources line for 2.2 in edgy, but
            # no Packages for it. But the 2.2 Package in hardy is
            # fine then!

            # Get all versions of the candidates:
            CAND_VERS="$( echo "$CANDIDATES" | awk '{ print $3 }' )"
            [ $DEBUG ] && echo "CAND_VERS=\"$CAND_VERS\""
            if [[ -n $CAND_VERS ]]; then
                # build regexp for versions:
                CAND_VERS=${(j:|:)${(f)${CAND_VERS//./\\.}//+/\\+}}
                [ $DEBUG ] && echo "CAND_VERS=\"$CAND_VERS\""
                # Now filter madison output by matching version and Sources or Packages:
                PACKAGE=$( echo "$APT_MADISON" | awk "\$3 ~ /^($CAND_VERS)\$/ && \$7 == \"$SELECTION\"" )
                # Test: PACKAGE=$( echo "$PACKAGE" | sort -R )
                [ $DEBUG ] && echo "PACKAGES=\"$PACKAGE\""

                # Sort $PACKAGE using Dpkg::Version::version_compare on the version column
                PACKAGE=$( echo "$PACKAGE" | perl -e '
                use Dpkg::Version qw(version_compare);
                @data = (<>);
                @sorted = map $_->[0], sort { version_compare($a->[1], $b->[1]) } map [$_, /\|\s+(\S+)/], @data;
                @parts = split(/\s+\|\s+/, @sorted[-1]);
                $s = "$parts[0]=$parts[1]";
                $s =~ s/^\s+//;
                print $s' )
                [ $DEBUG ] && echo "PACKAGE=\"$PACKAGE\""
            fi
        fi
        if [[ -z $PACKAGE ]]; then
            echo "No matching package found for '$ARG'. Aborting."

            # split APT_MADISON by newline only:
            OLD_IFS=$IFS
            IFS='
            '
            for line in $APT_MADISON; do
                # If we need Packages|Sources, highlight both:
                if [[ -n $SELECTION ]]; then
                    if echo "  $line" | grep --color=auto "$GREP_FOR" | grep --color=auto "$SELECTION"; then continue; fi
                    if echo "  $line" | grep --color=auto "$SELECTION"; then continue; fi
                fi
                # Highlight search:
                if echo "  $line" | grep --color=auto "$GREP_FOR"; then
                    continue
                fi
                # Nothing highlighted:
                echo "  $line"
            done
            IFS=$OLD_IFS
            return 1
        fi
        COMMAND_ARG="$COMMAND_ARG$PACKAGE "
    done
    # execute:
    echo "$COMMAND $COMMAND_ARG"
    /bin/sh -c "$COMMAND $COMMAND_ARG"
}

alias asearch="apt-cache search"
alias amad="apt-cache madison"
alias apol="apt-cache policy"
alias afs="apt-file search"
if [[ $UID = 0 ]]; then
    alias aup="LANG=C apt-get update"
    alias aupgrade="aptitude upgrade -V"
    alias apurge="aptitude purge"
    alias asup="LANG=C verynice apt-get update -qq && verynice aptitude safe-upgrade -V"
else
    alias aup="LANG=C sudo apt-get update"
    alias aupgrade="sudo aptitude upgrade -V"
    alias apurge="sudo aptitude purge"
    alias asup="LANG=C verynice sudo apt-get update -q2 && verynice sudo aptitude safe-upgrade -V"
fi

# Install source package, supports grepping in $2 to fetch a specific version
# E.g. "asrc -g gutsy hello" will become "apt-get source hello=2.2-2"
asrc() {
    _apt_cache_madison_grep_wrapper "apt-get source" "Sources" $*
}
ainst() {
    if [[ $UID = 0 ]]; then
        _apt_cache_madison_grep_wrapper "aptitude install" "Packages" $*
    else
        _apt_cache_madison_grep_wrapper "sudo aptitude install" "Packages" $*
    fi
    # rebuild zsh cache of known programs
    which rehash > /dev/null && rehash
}
ashow() {
    _apt_cache_madison_grep_wrapper "apt-cache show" "" $* | less
}
ashowsrc() {
    _apt_cache_madison_grep_wrapper "apt-cache showsrc" "" $* | less
}
# Display currently installed version of a package
apv() {
    apol $* | grep '^ \*\*\*'
}

# Bash completion for the above functions:
# Completing package names or filenames
if ! which complete &>/dev/null; then
    autoload -Uz bashcompinit
    if which bashcompinit &>/dev/null; then
        bashcompinit
    fi
fi
complete -F _complete_apt_cache_package -o filenames ainst
complete -F _complete_apt_cache_package -o filenames amad
complete -F _complete_apt_cache_package -o filenames apol
complete -F _complete_apt_cache_package -o filenames ashow
complete -F _complete_apt_cache_package -o filenames ashowsrc
complete -F _complete_apt_cache_package -o filenames asrc
complete -F _complete_apt_cache_package -o filenames apv

# complete function for apt-cache packages
# (extracted from /etc/bash/bash_completion)
# TODO: does not include source package names (e.g. meta-gnome2), useful for e.g. asrc
_complete_apt_cache_package() {
    COMPREPLY=( $( apt-cache pkgnames ${COMP_WORDS[COMP_CWORD]} 2> /dev/null ) )
    return 0
}

# Usefule aptitude aliases
# Source: https://github.com/xtaran/zshrc/commit/a02dc87df6b16d1856e1559150347cf2432e8ad7
alias aptitude-just-recommended='aptitude -o "Aptitude::Pkg-Display-Limit=!?reverse-depends(~i) ~M !?essential"'
alias aptitude-also-via-dependency='aptitude -o "Aptitude::Pkg-Display-Limit=~i !~M ?reverse-depends(~i) !?essential"'

