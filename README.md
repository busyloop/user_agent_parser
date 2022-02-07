# user_agent_parser

[![GitHub release](https://img.shields.io/github/release/busyloop/user_agent_parser.svg)](https://github.com/busyloop/user_agent_parser/releases)
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](<https://busyloop.github.io/user_agent_parser/>)

A crystal shard for parsing user agent strings using the BrowserScope pattern library.
It automatically fetches the latest version of [BrowserScope's parsing patterns](https://github.com/ua-parser/uap-core)
at compile time and inlines them with your compiled binary.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  user_agent_parser:
    github: busyloop/user_agent_parser
```

## Usage

```crystal
require "user_agent_parser"

## Load BrowserScope parsing patterns, latest version
## can be found here: https://raw.githubusercontent.com/ua-parser/uap-core/master/regexes.yaml

UserAgent.load_regexes(File.read("regexes.yaml"))

# 1. Parse a user agent string
ua = UserAgent.new("Mozilla/5.0 (Linux; Android 7.0; SM-G892A Build/NRD90M; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/60.0.3112.107 Mobile Safari/537.36")

# 2. Inspect the result
puts ua.family # => Chrome Mobile WebView
puts ua.version # => 60.0.3112

puts ua.device # => UserAgent::Device(@model="SM-G892A", @brand="Samsung", @name="Samsung SM-G892A")

puts ua.os # => UserAgent::Os(@family="Android", @version=#<SemanticVersion:0x10c1c97e0 @major=7, @minor=0, @patch=0, @build=nil, @prerelease=SemanticVersion::Prerelease(@identifiers=[])>)
```

## Documentation

* [API Documentation](https://busyloop.github.io/user_agent_parser/)


## Automatic updates

By default this shard downloads the latest version of [BrowserScope's parsing patterns](https://github.com/ua-parser/uap-core)
at compile time and inlines it with your binary.

This ensures you get the latest version every time you re-compile your app.

If you wish to update without recompiling your app, you can also
load a new `regexes.yml` at runtime via `UserAgent.load_regexes("..yaml string..")`.

## Contributing

1. Fork it (<https://github.com/busyloop/user_agent_parser/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

