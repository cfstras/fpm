#!/bin/sh

silent() {
  "$@" > /dev/null 2>&1
}

install_path() {
  d="${1##.}"
  if [ ! -z "$d" ] ; then 
    if [ -d "$1" ] && [ ! -d "$d" ] ; then 
      mkdir "$d"
    fi
    if [ -f "$1" ] ; then
      _old_file="$d"
      if [ "$(dirname "$d")" = "/etc/default" ] && [ -f "${_old_file}" ]; then
        # upgrade
        echo "upgrading file $1"
        _new_entries=$(awk -F"=" '{print $1}' "$1")
        _old_entries=$(awk -F"=" '{print $1}' "${_old_file}")
        IFS='
'
        for key in ${_new_entries}; do
          if ! echo "${_old_entries}" | silent grep "${key}"; then
            echo "New setting: $(egrep "^${key}=" "$1")"
            egrep "^${key}" "$1" >> "${_old_file}"
          fi
        done
        # TODO obsolete settings
        IFS=' '
        
      else
        cp -p "$1" "$d"
      fi
    fi
  fi
}

for i in "$@" ; do
  install_path "$i"
done
