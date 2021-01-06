<center>

## 🔳 Mirror

### A command-line utility that creates projects from `mirrors` (project templates)

[![Build Status](https://github.com/talismanco/mirror/workflows/CI/badge.svg)](https://github.com/talismanco/mirror/actions)
[![Code Coverage](https://codecov.io/gh/talismanco/mirror/branch/master/graph/badge.svg)](https://codecov.io/gh/talismanco/mirror)
[![Go Report Card](https://goreportcard.com/badge/talismanco/mirror)](https://goreportcard.com/report/talismanco/mirror)
[![LICENSE](https://img.shields.io/github/license/talismanco/mirror.svg)](https://github.com/talismanco/mirror/blob/master/LICENSE)
[![Releases](https://img.shields.io/github/release-pre/talismanco/mirror.svg)](https://github.com/talismanco/mirror/releases)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

</center>

<!-- ----------------------------------------------------------------- -->

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Getting Started](#getting-started)
  - [Download a Mirror](#download-a-mirror)
  - [Save a Local Template](#save-a-local-template)
  - [Create a mirror](#create-a-mirror)
  - [List of Mirrors](#list-of-mirrors)

<!-- ----------------------------------------------------------------- -->

# Features

- **No dependencies (NodeJS, Python Interpreter etc.)** - Mirror is a single statically linked binary.
  Grab the one that fits your architecture, and you're all set to save time by using templates!
- **Full Power of [Golang Templates](https://golang.org/pkg/text/template/)** - Golang has powerful templating
  constructs which are very easy to learn and powerful.
- **Dead-Simple Template Creation** - Creating boilerplate templates are very easy, check out
  the [license template](https://github.com/talismanco/mirror-license) to see a simple, but very useful template for
  adding licenses to new projects with a single command.

<!-- ----------------------------------------------------------------- -->

# Installation

> Our home management system, [Casa](https://github.com/talismanco/casa), is shipped with the most recent version of `Mirror` via [talismanpkgs](https://github.com/talismanco/talismanpkgs)

Binaries for Windows, Mac, and Linux are officially supported. You can download them directly, from the release page, or run the installation script.

Please see [Installation](https://github.com/talismanco/mirror/wiki/Installation) page for more information.

<!-- ----------------------------------------------------------------- -->

# Getting Started

To see all available options:

```shell
mirror help
```

## Download a Mirror

In order to download a mirror from a github repository, use the following command:

```bash
mirror download <github-repo-path> <mirror-tag>
mirror download talismanco/mirror-license license
```

The downloaded template will be saved to local `mirror` registry.

## Save a Local Template

In order to save a template from filesystem to the template registry use the following command:

```bash
mirror save <mirror-path> <mirror-tag>
mirror save ~/mirror-license license
```

The saved template will be saved to local `mirror` registry.

## Create a template

For a mirror template with the given directory structure:

```tree
.
├── project.json
├── README.md
└── template
    └── LICENSE
```

And the following `project.json` context file:

```json
{
	"Author": "John Doe",
	"Year": "2020",
	"License": ["Apache Software License 2.0", "MIT", "GNU GPL v3.0"]
}
```

When using the mirror with the following command:

```bash
mirror use <mirror-tag> <target-dir>
mirror use license /workspace/talismanco/example-project/
```

The user will be prompted as follows:

```bash
[?] Please choose an option for "License"
    1 -  "Apache Software License 2.0"
    2 -  "MIT"
    3 -  "GNU GPL v3.0"
    Select from 1..3 [default: 1]: 2
[?] Please choose a value for "Year" [default: "2015"]:
[?] Please choose a value for "Author" [default: "Tamer Tas"]:
[✔] Created /workspace/talismanco/example-project/LICENSE
[✔] Successfully executed the project license in /workspace/talismanco/example-project
```

For more information please take a look at [Usage](https://github.com/talismanco/mirror/wiki/Usage) and [Creating Templates](https://github.com/talismanco/mirror/wiki/Creating-Templates) pages in the wiki.

<!-------------------------------------------------------------------->

## List of Templates

Take a look at the [Templates](https://github.com/talismanco/mirror/wiki/Templates) page for an index of project templates, examples, and more information.
