if [[ $autoenv_event == enter ]]; then
  if [[ -n $commands[ag] ]]; then
    if [[ -n $aliases[ag] ]]; then
      autostash alias ag="$aliases[ag] -U"
    else
      autostash alias ag='ag -U'
    fi
  fi
fi
