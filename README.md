[![Gem](https://img.shields.io/gem/v/danger-php_codesniffer.svg)](https://rubygems.org/gems/danger-php_codesniffer) [![Build Status](https://travis-ci.org/Golface/danger-php_codesniffer.svg?branch=master)](https://travis-ci.org/Golface/danger-php_codesniffer)

# danger-php_codesniffer

[Danger](https://github.com/danger/danger) plugin for [PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer).

## Installation

```
$ gem install danger-php_codesniffer
```

## Usage

Detect your PHP violations of a defined coding standard. The plugin will post a comment on PR/MR on your Github or Gitlab project.

Add this to your Dangerfile to run CodeSniffer:

```
php_codesniffer.exec
```

---

You can modify how the plugin behaves by adding one or more of the following options before the `php_codesniffer.exec` call:

Ignore file/path:

```
php_codesniffer.ignore = "./vendor"
```

Use specific coding standard:

```
php_codesniffer.standard = "CodeIgniter"
```

Only check new and modified file:

```
php_codesniffer.filtering = true
```

Fail the pipeline if CodeSniffer reports any errors (you also have to run Danger with the `--fail-on-errors` flag set to true):

```
php_codesniffer.fail_on_error = true
```

Ignore warnings and/or fixables in the Danger output:

```
php_codesniffer.ignore_warnings = true
php_codesniffer.ignore_fixables = true
```

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.
