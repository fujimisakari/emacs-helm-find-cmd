# helm-find-cmd.el

## Introduction

`helm-find-cmd.el` will be able to use find command through helm interface


## Requirements

* Emacs 24.4 or higher
* helm 1.5 or higher


## Configuration

To use this package, add these lines to your init.el or .emacs file:
```
(require 'helm-find-cmd)
```


## Basic Usage

#### `helm-find-cmd-type-file`
Execute `find . -type f`

#### `helm-find-cmd-type-directory`
Execute `find . -type d`
