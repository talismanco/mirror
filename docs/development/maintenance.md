# `mirror` release and maintenance policy

`mirror` has strict policies governing version naming, as well as release pace for major, minor,
patch, and security releases.

Our current policy is:

- Backporting bug fixes for **only the current stable release** at any given time. (See [patch releases](#patch-releases).)
- Backporting **to the previous two monthly releases in addition to the current stable release**. (See [security releases](#security-releases).)

## Versioning

`mirror` uses [Semantic Versioning](https://semver.org/) for its releases:
`(Major).(Minor).(Patch)`.

For example, for `mirror` version 12.10.6:

- `12` represents the major version. The major release was 12.0.0 but often referred to as 12.0.
- `10` represents the minor version. The minor release was 12.10.0 but often referred to as 12.10.
- `6` represents the patch number.

Any part of the version number can increment into multiple digits, for example, 13.10.11.

The following table describes the version types and their release cadence:

| Version type | Description | Cadence |
|:-------------|:------------|:--------|
| Major        | For significant changes, or when any backward-incompatible changes are introduced to the public API. | Yearly. The next major release is `mirror` 14.0 on May 22, 2021. Subsequent major releases will be scheduled for May 22 each year, by default. |
| Minor        | For when new backward-compatible functionality is introduced to the public API, a minor feature is introduced, or when a set of smaller features is rolled out. | Monthly on the 22nd. |
| Patch        | For backward-compatible bug fixes that fix incorrect behavior. See [Patch releases](#patch-releases). | As needed. |

## Upgrade recommendations

We encourage everyone to run the [latest stable release](https://github.com/lunaris-studios/mirror/releases) (the latest stable release is also reflected in the current state of the [master branch](https://github.com/lunaris-studios/mirror))
to ensure that you can easily upgrade to the most secure and feature-rich `mirror` experience.
To make sure you can easily run the most recent stable release, we are working
hard to keep the update process simple and reliable.

If you are unable to follow our monthly release cycle, there are a couple of
cases you need to consider.

It is considered safe to jump between patch versions and minor versions within
one major version. For example, it is safe to:

- Upgrade the *minor* version. For example:

  - `12.7.5` -> `12.10.5`
  - `11.3.4` -> `11.11.1`
  - `10.6.6` -> `10.8.3`
  - `11.3.4` -> `11.11.8`
  - `10.6.6` -> `10.8.7`
  - `9.2.3` -> `9.5.5`
  - `8.9.4` -> `8.12.3`

- Upgrade the *patch* version. For example:

  - `12.0.4` -> `12.0.12`
  - `11.11.1` -> `11.11.8`
  - `10.6.3` -> `10.6.6`
  - `11.11.1` -> `11.11.8`
  - `10.6.3` -> `10.6.6`
  - `9.5.5` -> `9.5.9`
  - `8.9.2` -> `8.9.6`

### Upgrading major versions

Upgrading the *major* version requires more attention.
Backward-incompatible changes and migrations are reserved for major versions.
We cannot guarantee that upgrading between major versions will be seamless.
We suggest upgrading to the latest available *minor* version within
your major version before proceeding to the next major version.
Doing this will address any backward-incompatible changes or deprecations
to help ensure a successful upgrade to the next major release.