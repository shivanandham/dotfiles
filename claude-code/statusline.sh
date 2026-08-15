#!/usr/bin/env bash
# Claude Code statusLine script.
# Reads the session JSON from stdin and prints one status line.
# Schema: https://code.claude.com/docs/en/statusline.md

input=$(cat)

model=$(jq -r '.model.display_name // "Claude"' <<<"$input")
effort=$(jq -r '.effort.level // empty' <<<"$input")
cwd=$(jq -r '.workspace.current_dir // "."' <<<"$input")
project_dir=$(jq -r '.workspace.project_dir // empty' <<<"$input")
[ -z "$project_dir" ] && project_dir="$cwd"

proj_name=$(basename "$project_dir")
case "$cwd" in
  "$project_dir")
    dir_name="$proj_name"
    ;;
  "$project_dir"/*)
    dir_name="${proj_name}/${cwd#"$project_dir"/}"
    ;;
  *)
    dir_name="$cwd"
    ;;
esac

branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

used_pct=$(jq -r '.context_window.used_percentage // empty' <<<"$input")

color_for() {
  local pct=${1%.*}
  [ -z "$pct" ] && pct=0
  if [ "$pct" -ge 90 ]; then printf '\033[31m'
  elif [ "$pct" -ge 70 ]; then printf '\033[33m'
  else printf '\033[32m'
  fi
}

reset='\033[0m'
dim='\033[2m'
bold='\033[1m'
gray='\033[90m'

bar() {
  local pct=$1 width=10
  pct=${pct%.*}
  [ -z "$pct" ] && pct=0
  local c filled empty filled_str="" empty_str=""
  c=$(color_for "$pct")
  filled=$(( pct * width / 100 ))
  empty=$(( width - filled ))
  for ((i = 0; i < filled; i++)); do filled_str+="█"; done
  for ((i = 0; i < empty; i++)); do empty_str+="░"; done
  printf '%s%s%s%s%s%s' "$c" "$filled_str" "$reset" "$gray" "$empty_str" "$reset"
}

ctx_segment=""
if [ -n "$used_pct" ]; then
  c=$(color_for "$used_pct")
  ctx_segment="${dim}Ctx${reset} $(bar "$used_pct") ${c}${used_pct}%${reset}"
fi

fmt_reset() {
  local epoch="$1"
  [ -z "$epoch" ] || [ "$epoch" = "null" ] && return
  date -r "$epoch" +"%H:%M" 2>/dev/null || date -d "@$epoch" +"%H:%M" 2>/dev/null
}

five_hour=$(jq -r '.rate_limits.five_hour.used_percentage // empty' <<<"$input")
five_hour_reset=$(jq -r '.rate_limits.five_hour.resets_at // empty' <<<"$input")
seven_day=$(jq -r '.rate_limits.seven_day.used_percentage // empty' <<<"$input")
seven_day_reset=$(jq -r '.rate_limits.seven_day.resets_at // empty' <<<"$input")

limits_segment=""
if [ -n "$five_hour" ] || [ -n "$seven_day" ]; then
  parts=()
  if [ -n "$five_hour" ]; then
    c=$(color_for "$five_hour")
    seg="${dim}5h${reset} ${c}${five_hour}%${reset}"
    rt=$(fmt_reset "$five_hour_reset")
    [ -n "$rt" ] && seg+=" ${dim}(${rt})${reset}"
    parts+=("$seg")
  fi
  if [ -n "$seven_day" ]; then
    c=$(color_for "$seven_day")
    seg="${dim}7d${reset} ${c}${seven_day}%${reset}"
    rt=$(fmt_reset "$seven_day_reset")
    [ -n "$rt" ] && seg+=" ${dim}(${rt})${reset}"
    parts+=("$seg")
  fi
  limits_segment=""
  for p in "${parts[@]}"; do
    if [ -z "$limits_segment" ]; then
      limits_segment="$p"
    else
      limits_segment="${limits_segment} ${dim}│${reset} ${p}"
    fi
  done
fi

div=" ${dim}│${reset} "

line="${bold}${model}${reset}"
[ -n "$effort" ] && line+=" ${dim}(${effort})${reset}"
line+="${div}${dim}${dir_name}${reset}"
[ -n "$branch" ] && line+=" ${dim}(${branch})${reset}"
[ -n "$ctx_segment" ] && line+="${div}${ctx_segment}"
[ -n "$limits_segment" ] && line+="${div}${limits_segment}"

printf '%b' "$line"
