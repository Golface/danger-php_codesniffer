[![Gem](https://img.shields.io/gem/v/danger-php_codesniffer.svg)](https://rubygems.org/gems/danger-php_codesniffer) [![Build Status](https://travis-ci.org/Golface/danger-php_codesniffer.svg?branch=master)](https://travis-ci.org/Golface/danger-php_codesniffer)

# danger-php_codesniffer

[Danger](https://github.com/danger/danger) plugin for [PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer).

## Installation

```
$ gem install danger-php_codesniffer
```

## Usage

Detect your PHP violations of a defined coding standard. The plugin will post a comment on PR/MR on your Github or Gitlab project.

Dangerfile:

```
php_codesniffer.exec
```

Ignore file/path and use specific coding standard:

```
php_codesniffer.ignore = "./vendor"
php_codesniffer.standard = "CodeIgniter"
php_codesniffer.exec
```

Only check new and modified file:

```
php_codesniffer.filtering = true
php_codesniffer.exec
```

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.
