# 🧑🏽‍💻 Project `Lorentz`

[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![Infrastructure Provisioning](https://github.com/zatarain/lorentz/actions/workflows/provisioning.yml/badge.svg)](https://github.com/zatarain/lorentz/actions/workflows/provisioning.yml) [![Development Infrastructure](https://badgen.net/github/checks/zatarain/lorentz/development?label=Development&icon=terraform)](https://github.com/zatarain/lorentz/actions/workflows/provisioning.yml) [![Staging Infrastructure](https://badgen.net/github/checks/zatarain/lorentz/staging?label=Staging&icon=terraform)](https://github.com/zatarain/lorentz/actions/workflows/provisioning.yml)
[![Production Infrastructure](https://badgen.net/github/checks/zatarain/lorentz?label=Production&icon=terraform)](https://github.com/zatarain/lorentz/actions/workflows/provisioning.yml)

This repository defines the `ether`-structure (infrastructure as code) for my personal projects. Its name comes after [Hendrik Lorentz][hendrik-lorentz] who was a Dutch physics and his Ether Theory, which also gives the name to the Ethernet standard for Networks (yes, this is yet another nerdy reference from me).

## 🔭 Overview

The infrastructure is defined using [Hashicorp Configuration Language][hcl-docs] and can be provisioned to [Amazon Web Services][aws-docs] using [Terraform][terraform]. The repository is designed to use multiple AWS accounts, such as development and production accounts.

### 🧩 Structure

The code in the repository is designed to have at least two Terraform workspaces. In particular I am using four workspaces each of them linked to my AWS accounts and three of them linked to GitHub environments (sharing the same name):

* **Default**. It holds resources that cannot be replicated or must be shared between the other accounts (e. g. registered domain name, the Terraform State, etc).
* **Development**. It holds the resources for development and the ones I use from my local machine, so its quite unstable.
* **Staging**. This workspace is more stable than development and it's used to test with similar data as production.
* **Production**. It holds the live resources and data for my personal projects.

---

[hendrik-lorentz]: https://en.wikipedia.org/wiki/Hendrik_Lorentz
[terraform]: https://www.terraform.io
[aws-docs]: https://docs.aws.amazon.com
[hcl-docs]: https://developer.hashicorp.com/terraform/language
