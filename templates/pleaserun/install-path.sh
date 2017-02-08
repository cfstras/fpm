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
      if [ "$(dirname "$d")" = "/etc/default" ]; then
        # upgrade
        echo "upgrading file $1"
        _new_entries=$(awk -F"=" '{print $1}' "$1")
        if [ -f "${_old_file}" ]; then
          _old_entries=$(awk -F"=" '{print $1}' "${_old_file}")
        else
          _old_entries=""
        fi
        IFS='
'
        for key in ${_new_entries}; do
          if ! echo "${_old_entries}" | silent grep "${key}"; then
            [ -f "${_old_file}" ] && echo "New setting: $(egrep "^${key}=" "$1")"
            egrep "^${key}" "$1" | sed 's|^export\s*#|#|g' | sed 's|^\s*\(#.*\)=""|\1|g' >> "${_old_file}"
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
