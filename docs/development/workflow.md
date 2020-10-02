
# Workflow

We use a combination of three pillar fundementals when it comes to our git workflow:
- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)
- [Conventional Commits](https://www.conventionalcommits.org)
- [semantic-release](https://github.com/semantic-release/semantic-release)

This Workflow defines a strict branching model designed around the project release ([Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)), a strong focus on commit history ([Conventional Commits](https://www.conventionalcommits.org)), and provides a dynamic release and changelog pipeline ([semantic-release](https://github.com/semantic-release/semantic-release)). This provides a robust framework for managing larger projects.  

## Getting Started

The foundation of this workflow is centered around [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/), which provides a standard for  what kind of branches to set up and how to merge them together. We will touch on the purposes of the branches below. The `git-flow` toolset is an actual command line tool that has an installation process. The installation process for `git-flow` is straightforward. Packages for `git-flow` are available on multiple operating systems. On OSX systems, you can execute brew install `git-flow`. On windows you will need to download and install `git-flow`. After installing `git-flow` you can use it in your project by executing `git flow init`. Git-flow is a wrapper around Git. The `git flow init` command is an extension of the default git init command and doesn't change anything in your repository other than creating branches for you.

> If you're using [Casa](https://github.com/lunaris-studios/casa), `git-flow` will be available upon installation.

## How it works

![Git flow workflow - Historical Branches](https://storage.googleapis.com/lunaris-docs/git/workflow/branches.svg)

### Develop and Master Branches

Instead of a single `master` branch, this workflow uses two branches to record the history of the project. The `master` branch stores the official release history, and the `develop` branch serves as an integration branch for features. It's also convenient to tag all commits in the `master` branch with a version number.

The first step is to complement the default `master` with a `develop` branch. A simple way to do this is for one `develop`er to create an empty `develop` branch locally and push it to the server:

```shell
git branch develop
git push -u origin develop
```

This branch will contain the complete history of the project, whereas `master` will contain an abridged version. Other `develop`ers should now clone the central repository and create a tracking branch for `develop`.

When using the `git-flow` extension library, executing `git flow init` on an existing repo will create the `develop` branch:

```shell;
$ git flow init
Initialized empty Git repository in ~/project/.git/
No branches exist yet. Base branches must be created now.
Branch name for production releases: [`master`]
Branch name for "next release" development: [`develop`]

How to name your supporting branch prefixes?
Feature branches? [feature/]
Release branches? [release/]
Hotfix branches? [hotfix/]
Support branches? [support/]
Version tag prefix? []

$ git branch
* `develop`
 `master`
```

### Alpha Branch

Similar to the `develop` branch, the alpha branch is integration branch for features before they hit `develop`. The `alpha` branch is not a mandatory step, however. It exists as a sandbox to test volatile code that might not necessarily correspond to a release cycle.

## Feature Branches

Each new feature should reside in its own branch, which can be pushed to the central repository for backup/collaboration. But, instead of branching off of `master`, feature branches use `develop` as their parent branch. When a feature is complete, it gets merged back into `develop`. Features should never interact directly with `master`.

![Git flow workflow - Feature Branches](https://storage.googleapis.com/lunaris-docs/git/workflow/feature.svg)

Feature branches are generally created off to the latest `develop` branch.

### Creating a feature branch

Without the git-flow extensions:

```shell
git checkout develop
git checkout -b feature_branch
```
When using the git-flow extension:

```shell
git flow feature start feature_branch
```

Continue your work and use Git like you normally would.

### Finishing a feature branch

When you’re done with the development work on the feature, the next step is to merge the `feature_branch` into `develop`.

Without the git-flow extensions:

```shell
git checkout develop
git merge feature_branch
```

Using the git-flow extensions:

```shell
git flow feature finish feature_branch
```

## Release Branches

![Git flow workflow - Release Branches](https://storage.googleapis.com/lunaris-docs/git/workflow/release.svg)

Once `develop` has acquired enough features for a release (or a predetermined release date is approaching), you fork a release branch off of `develop`. Creating this branch starts the next release cycle, so no new features can be added after this point—only bug fixes, documentation generation, and other release-oriented tasks should go in this branch. Once it's ready to ship, the release branch gets merged into `master` and tagged with a version number. In addition, it should be merged back into `develop`, which may have progressed since the release was initiated.

Using a dedicated branch to prepare releases makes it possible for one team to polish the current release while another team continues working on features for the next release. It also creates well-defined phases of development (e.g., it's easy to say, “This week we're preparing for version 4.0,” and to actually see it in the structure of the repository).

Making release branches is another straightforward branching operation. Like feature branches, release branches are based on the `develop` branch. A new release branch can be created using the following methods.

Without the git-flow extensions:

```shell
git checkout develop
git checkout -b release/0.1.0
```

When using the git-flow extensions:

```shell
$ git flow release start 0.1.0
Switched to a new branch 'release/0.1.0'
```

Once the release is ready to ship, it will get merged it into `master` and `develop`, then the release branch will be deleted. It’s important to merge back into `develop` because critical updates may have been added to the release branch and they need to be accessible to new features. If your organization stresses code review, this would be an ideal place for a pull request.

To finish a release branch, use the following methods:

Without the git-flow extensions:

```shell
git checkout master
git merge release/0.1.0
```

Or with the git-flow extension:

```shell
git flow release finish '0.1.0'
```

Following a successful merge, The [CI Github Action](/github/workflows/release.yaml), power will fire: determining the next version number, generating the release notes and publishing the package - powered by [semantic-release](https://github.com/semantic-release/semantic-release). Semantic release follows the commit message guidelines provided by [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) and the release policy provided by [Semantic Versioning](https://semver.org/).
> Read our [maintenance outline](maintenance.md) for more information on project release and maintenance policy.

## Hotfix Branches
![Git flow workflow - Hotfix Branches](https://storage.googleapis.com/lunaris-docs/git/workflow/feature.svg)

Maintenance or “hotfix” branches are used to quickly patch production releases. Hotfix branches are a lot like release branches and feature branches except they're based on `master` instead of `develop`. This is the only branch that should fork directly off of `master`. As soon as the fix is complete, it should be merged into both `master` and `develop` (or the current release branch), and `master` should be tagged with an updated version number.

Having a dedicated line of development for bug fixes lets your team address issues without interrupting the rest of the workflow or waiting for the next release cycle. You can think of maintenance branches as ad hoc release branches that work directly with `master`. A hotfix branch can be created using the following methods:

Without the git-flow extensions:

```shell
git checkout master
git checkout -b hotfix_branch
```

When using the git-flow extensions: 

```shell
git flow hotfix start hotfix_branch
```

Similar to finishing a release branch, a hotfix branch gets merged into both `master` and `develop`.

```shell
git checkout master
git merge hotfix_branch
git checkout develop
git merge hotfix_branch
git branch -d hotfix_branch
```

```shell
$ git flow hotfix finish hotfix_branch
```

## Example

A complete example demonstrating a Feature Branch Flow is as follows. Assuming we have a repo setup with a `master` branch.

Without the git-flow extensions:

```shell
git checkout master
git checkout -b develop
git checkout -b feature_branch
# work happens on feature branch
git checkout develop
git merge feature_branch
git branch -d feature_branch
# release cycle has ended, and we are ready to start a release
git checkout develop
git checkout -b release/0.1.0
# release is ready to ship
git checkout master
git merge release/0.1.0
git branch -D release/0.1.0
```

When using the git-flow extensions: 

```shell
git flow init
git flow feature start feature_branch
# work happens on feature branch
git flow feature finish feature_branch
# release cycle has ended, and we are ready to start a release
git flow release start 0.1.0
# release is ready to ship
git flow release finish '0.1.0'
```

In addition to the feature and release flow, a hotfix example is as follows:

Without the git-flow extensions:

```shell
git checkout master
git checkout -b hotfix_branch
# work is done commits are added to the hotfix_branch
git checkout develop
git merge hotfix_branch
git checkout master
git merge hotfix_branch
```

When using the git-flow extensions: 

```shell
git flow init
git flow hotfix start hotfix_branch
# work is done commits are added to the hotfix_branch
git flow hotfix finish hotfix_branch
```

## Summary

Some key takeaways to know about Gitflow are:

    The workflow is great for a release-based software workflow.
    Gitflow offers a dedicated channel for hotfixes to production.
     

The overall flow of Gitflow is:

    A `develop` branch is created from `master`
    A release branch is created from `develop`
    Feature branches are created from `develop`
    When a feature is complete it is merged into the `develop` branch
    When the release branch is done it is merged into `develop` and `master`
    If an issue in `master` is detected a hotfix branch is created from `master`
    Once the hotfix is complete it is merged to both `develop` and `master`
