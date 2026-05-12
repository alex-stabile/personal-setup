setopt prompt_subst

# Shorten current working directory
function prompt_short_pwd() {
  local path_components
  local formatted_path=""
  local last_component

  # Split the path into components
  IFS='/' read -rA path_components <<< "${PWD}"

  # Handle the root directory separately
  if [[ "${#path_components[@]}" -eq 1 && "${path_components[1]}" = "" ]]; then
    echo "/"
    return
  fi

  # Extract the last component
  last_component="${path_components[-1]}"
  unset 'path_components[-1]'

  # Format the preceding components to their first letter
  for component in "${path_components[@]}"; do
    if [[ -n "$component" ]]; then # Skip empty components from leading slashes
      formatted_path+="${component[1]}/"
    fi
  done

  # Combine with the full last component
  echo "${formatted_path}${last_component}"
}

function set_prompt() {
  # shellcheck disable=SC2016
  export PROMPT='%F{green}%n%f:%F{blue}$(prompt_short_pwd)%f%# '
}

export ORIG_PROMPT=$PROMPT
set_prompt
