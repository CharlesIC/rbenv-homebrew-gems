if ! [[ -x "$RBENV_COMMAND_PATH" ]]; then
  ruby_version=$("$(rbenv-prefix)"/bin/ruby -e 'puts RbConfig::CONFIG["ruby_version"]')
  command_path="$(brew --prefix)/lib/ruby/gems/$ruby_version/bin/$RBENV_COMMAND"
  if [[ -x "$command_path" ]]; then
    RBENV_COMMAND_PATH=$command_path
  fi
fi