# rbenv plugin for Homebrew Ruby gems support

The Homebrew installation of Ruby via `brew install ruby` sets the RubyGems executable path to a location not supported by rbenv.
This means that if you want to use your Homebrew Ruby with rbenv, it won't be able to recognise gems installed for that version.
This plugin adds support for those gems.

## Gem binary locations

Ruby versions installed with `rbenv install` set RubyGems `bindir` to `<RBENV_ROOT>/versions/<VERSION>/bin`, as rbenv expects the gem executables to reside in the same directory as the Ruby executable.

The [Homebrew version of Ruby](https://github.com/Homebrew/homebrew-core/blob/master/Formula/ruby.rb) sets the RubyGems [`bindir` path](https://github.com/Homebrew/homebrew-core/blob/master/Formula/ruby.rb#L40-L42) to `<HOMEBREW_PREFIX>/lib/ruby/gems/<API_VERSION>/bin`:

```ruby
  def rubygems_bindir
    HOMEBREW_PREFIX/"lib/ruby/gems/#{api_version}/bin"
  end
```

However, the Ruby executable lives in `<HOMEBREW_PREFIX>/opt/ruby/bin`, which means that the gem executables don't live in the same place as the Ruby binary. This causes a problem where rbenv can't find gems for the Homebrew Ruby if you have symlinked it in `<RBENV_ROOT>/versions` by running `ln -s /usr/local/opt/ruby <RBENV_ROOT>/versions/<NAME>`.

This plugin also adds support for the case where you have the same version of Ruby installed through `rbenv install` and Homebrew, and want to share the Homebrew installation gems with the rbenv installation. 

## Implementation

This plugin modifies rbenv to look for gems in the Homebrew gem directories in addition to the default location when creating shims (or rehashing). rbenv will search for binaries in the `<HOMEBREW_PREFIX>/lib/ruby/gems/<API_VERSION>/bin` directory for the current version when executing a command.
In case of conflicts, binaries from the default rbenv location will be picked.

_`<RBENV_ROOT>` is by default set to `~/.rbenv`_

## Whence

The default `rbenv whence` command will not show the Homebrew Ruby version, as it only searches for binaries in the default rbenv location and is not hook-enabled so can't be extended like `rbenv which` or `rbenv rehash`.
To check for binaries including the Homebrew installation, use the `whence-all` command provided with this plugin instead.