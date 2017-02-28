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
        _tmp_new=$(mktemp)
        _tmp_old=$(mktemp)
        sed 's|^export\s*#|#|g' "$1"         | sed 's|^\s*\(#.*\)\s*=""|\1|g' > "$_tmp_new"
        sed 's|^export\s*#|#|g' "$_old_file" | sed 's|^\s*\(#.*\)\s*=""|\1|g' > "$_tmp_old"
        _new_entries=$(awk -F"=" '{gsub(/^[ \t]+/, "", $1); gsub(/[ \t]+$/, "", $1);print $1}' "$_tmp_new")
        if [ -f "${_old_file}" ]; then
          _old_entries=$(awk -F"=" '{gsub(/^[ \t]+/, "", $1); gsub(/[ \t]+$/, "", $1);print $1}' "${_tmp_old}")
        else
          _old_entries=""
        fi
        IFS='
'
        for key in ${_new_entries}; do
          if ! echo "${_old_entries}" | silent grep "${key}"; then
            echo "New setting $key: $(egrep "^${key}" "$_tmp_new")|"
            egrep "^${key}" "$_tmp_new" >> "${_old_file}"
          fi
        done
        # TODO obsolete settings
        IFS=' '
        rm -f "$_tmp_new" "$_tmp_old"
      else
        cp -p "$1" "$d"
      fi
    fi
  fi
}

for i in "$@" ; do
  install_path "$i"
done
