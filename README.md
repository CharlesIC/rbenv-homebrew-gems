# rbenv plugin for Homebrew Ruby gems support

rbenv can't find gems from Ruby versions installed through Homebrew, as opposed to using `rbenv install`.

This is an issue when it's useful to have an external version installed on the system and added to rbenv by creating a symlink in the rbenv versions directory.
This doesn't work very well though, as rbenv can't find gems installed in Homebrew Ruby versions because their gem binaries are placed in an unexpected location.

This plugin solves this issue by making rbenv look for gems in additional locations.

The plugin also adds support for the case where it's desirable to have the same version of Ruby installed twice through `rbenv install` as well as Homebrew, and share the Homebrew installation gems with the rbenv installation.

## Problem manifestation

Install Ruby through Homebrew

```shell script
  brew install ruby
```

Add the custom Ruby installation to rbenv by creating a symlink in the `versions` directory.

```shell script
  ln -s <HOMEBREW_PREFIX>/opt/ruby <RBENV_ROOT>/versions/<NAME>
```

_`<RBENV_ROOT>` is by default set to `~/.rbenv`_

Select the symlinked Homebrew version with rbenv and install a gem with `gem install <gem_name>`. Try to use the gem by executing `<gem_name>`.
rbenv will print a message saying the gem was not found in the current Ruby version even though it has just been installed.  

## Gem binary locations

rbenv looks for gem executables in [the same directory as the Ruby binary](https://github.com/rbenv/rbenv/blob/c879cb0f2fb2b01c6ee73cdfb25c90d139febda9/libexec/rbenv-which#L43).

Ruby versions installed with `rbenv install` set their RubyGems `bindir` to `<RBENV_ROOT>/versions/<VERSION>/bin`, as expected by rbenv.

The [Homebrew version of Ruby](https://github.com/Homebrew/homebrew-core/blob/master/Formula/ruby.rb) sets the RubyGems [`bindir` path](https://github.com/Homebrew/homebrew-core/blob/master/Formula/ruby.rb#L40-L42) to `<HOMEBREW_PREFIX>/lib/ruby/gems/<API_VERSION>/bin`:

```ruby
  def rubygems_bindir
    HOMEBREW_PREFIX/"lib/ruby/gems/#{api_version}/bin"
  end
```

However, the Ruby executable lives in `<HOMEBREW_PREFIX>/opt/ruby/bin` which is not the same place as the gem executables. 

## Implementation

This plugin modifies rbenv to look for gems in the Homebrew gem directories in addition to the default location when creating shims (or rehashing). rbenv will search for binaries in the `<HOMEBREW_PREFIX>/lib/ruby/gems/<API_VERSION>/bin` directory for the current version when executing a command.
In case of conflicts, binaries from the default rbenv location will be picked.

## Whence

The default `rbenv whence` command will not show the Homebrew Ruby version, as it only searches for binaries in the default rbenv location and is not hook-enabled so can't be extended like `rbenv which` or `rbenv rehash`.
To check for binaries including the Homebrew installation, use the `whence-all` command provided with this plugin instead.