
devlinks(){
  declare -A devmap
  while read link ; do
    devmap[${link}]="$(readlink "${link}")"
  done <<< "$(/usr/bin/find /dev/disk -type l)"
  for link in "${!devmap[@]}" ; do
    [ "${devmap[${link}]}" ] || continue
    printf "${devmap[${link}]/..\/..\///dev/} <- ${link}\n"
  done | sort
}
