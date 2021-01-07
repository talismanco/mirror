# Usage
Use `mirror help` to get the list of available commands.

## Download Template
In order to download a template from a github repository, use the following command:

```bash
mirror download <github-repo-path> <template-name>
mirror download tmrts/mirror-license license
```

The downloaded template will be saved to local `mirror` registry.

## Save Local Template
In order to save a template from filesystem to the template registry use the following command:

```bash
mirror save <template-path> <template-name>
mirror save ~/mirror-license license
```

The saved template will be saved to local `mirror` registry.

## Use Template
In order to use a template from template registry use the following command:

```bash
mirror use <template-name> <target-dir>
mirror use license ~/workspace/example-project/
``

You will be prompted for values when using a template.
