# OANDA Terraform GCP Onix Projects

This repo is for Onix Contractors to contribute to systems in Google Compute Platform (GCP) using Infrastructure As Code (IaC)

## Making changes

This repository uses [Atlantis](https://www.runatlantis.io/) running [here](https://atlantis-onix.oanda.services/) to run plans and applies

DO NOT try to push to the main branch, you must open a Pull Request and have Atlantis run the terraform plan and terraform apply

If the apply is successful Atlantis will merge the PR for you

See [HERE](https://oandacorp.atlassian.net/wiki/spaces/RI/pages/2740781233/Atlantis) for more information about Atlantis and it's workflow


## Pre-Commit checks

In order to ensure that simple errors are caught before the pull-request is created, please install and configure pre-commit-terraform and dependencies as follows:

### Install pre-commit

See [here](https://oandacorp.atlassian.net/wiki/spaces/RI/pages/2102627751/Pre-Commit) for instructions on how to install `pre-commit`

### Install repo dependencies

This repositories has some tools that need to be installed in order to run the configured pre-commit hooks:

* [`terraform`](https://www.terraform.io/downloads.html) (choose a version of terraform that matches your plan; install tfenv to manage multiple versions)
* [`terraform-docs 0.12.0`](https://github.com/segmentio/terraform-docs) required for `terraform_docs` hooks. `GNU awk` is required if using `terraform-docs` older than 0.8.0 with Terraform 0.12.
* [`TFLint 0.25.0`](https://github.com/terraform-linters/tflint) required for `terraform_tflint` hook.
* [`yamllint`](https://yamllint.readthedocs.io/en/stable/index.html) required for yamllint pre-commit hook
* [`golang`](https://golang.org/) required for terraform-check-syntax hook.

### Running pre-commit

Pre-commit hooks will run automatically every time you do a `git commit`

They may correct issues themselves, in which case they will print out `files were modified by this hook`

Use `git diff` to see any changes they might have made, then add and commit again.
