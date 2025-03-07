# Ansible role: mambaorg.micromamba

Install micromamba, and optionally create a root/base conda environment.

## Links

* [GitHub](https://github.com/mamba-org/ansible-role-micromamba)
* [Galaxy](https://galaxy.ansible.com/mambaorg/micromamba)
* [Advanced usage example](https://github.com/maresb/micromamba-role-example) for bootstrapping and setting up a system conda environment in a Docker image

## Motivation

[Conda](https://docs.conda.io/projects/conda) is a very powerful Python-centric dependency management tool. Unfortunately, for environments with large numbers of dependencies, its slow dependency solver can take [hours](https://github.com/iterative/dvc.org/issues/2370#issuecomment-818891218) to complete.

The new [Mamba](https://github.com/mamba-org/mamba) project addresses this issue by reimplementing the dependency solver in C++, and is lightning-fast. Apart from the solver, `mamba` delegates most tasks to the otherwise dependable `conda` tool.

[Micromamba](https://github.com/mamba-org/mamba#micromamba) is a highly experimental pure C++ package manager for conda environments. Because it has no Python dependencies, it can efficiently create environments for any version of Python from a single `micromamba` binary. If none of your conda packages has a Python dependency, then Micromamba will even create a conda environment without Python!

Micromamba eliminates the need for "distributions" such as Anaconda or Miniconda. You can set up your desired environment directly.

## Role Variables

```yaml
arch: linux-64
version: latest
```

For the [latest architectures and version numbers](https://api.anaconda.org/release/conda-forge/micromamba/latest), check `distributions[#].basename`, which has the format `{arch}/micromamba-{version}.tar.bz2`. Current possible values for `arch` are `linux-64`, `linux-aarch64`, `osx-64`, `osx-arm64`, `win-64`. The format of `version` is either `latest` or something like `0.15.2-0`, where `-0` denotes the build number.

---

```yaml
dest: /usr/local/bin/micromamba
```

Location of the `micromamba` executable.

---

```yaml
root_prefix: /opt/conda
```

When the root prefix is defined and does not already exist, a new root prefix will be created in this location.

---

```yaml
packages:
  - mamba
  - python=3.9
```

A list of initial conda packages to be installed when a new root prefix is created.

---

```yaml
file: /tmp/environment.yaml
```

As an alternative to the list of `packages`, an environment file or lock file can be provided.

---

```yaml
root_prefix_condarc:
  channels:
    - conda-forge
```

Contents to write to `.condarc` in the new root prefix. If not defined, then no `.condarc` file is created.

## Example Playbooks

```yaml
- hosts: servers
  become: yes
  roles:
      - mambaorg.micromamba
```

This downloads the `micromamba` executable to the default location of `/usr/local/bin/micromamba`.

---

```yaml
- hosts: servers
  become: yes
  roles:
      - mambaorg.micromamba
  vars:
    dest: /tmp/micromamba
    root_prefix: /opt/conda
    packages:
      - mamba
      - python=3.9
```

This downloads `micromamba` into `/tmp/micromamba` and creates a new root prefix in `/opt/conda/` with Python 3.9 and Mamba.

---

```yaml
- hosts: servers
  become: yes
  become_user: condauser
  roles:
      - mambaorg.micromamba
  vars:
    root_prefix: ~/micromamba
    root_prefix_condarc:
      channels:
        - conda-forge
    packages:
      - s3fs-fuse
```

This creates a new root prefix in `/home/conda-user/micromamba` and creates a conda environment without Python. It also places a `.condarc` file in the root prefix to configure packages to be installed by default from the `conda-forge` channel.

## Subsequent Usage

In order run any commands from a conda environment, it must first be *activated*. Activation involves altering the `PATH` and other environment variables in the active shell (usually Bash). This can be accomplished in various ways.

### Directly

```bash
eval "$(micromamba shell hook --shell=bash)"
micromamba activate --prefix=/opt/conda
```

The first command executes a sequence of commands which define a Bash function, also named `micromamba`. (Otherwise, the `micromamba` executable would run as a *subprocess* which is unable to modify the environment of the shell.) The second command runs the newly-defined Bash function to activate the environment located at `/opt/conda`.

### With an initialization script

```bash
micromamba shell init --shell=bash --prefix=/opt/conda
```

This modifies `~/.bashrc` so that in subsequent interactive Bash sessions, the command `micromamba activate` suffices to activate the environment. (The command `micromamba activate` can be added to `~/.bashrc` if desired.)

### With mamba or conda

Since micromamba is experimental, instead of relying on the above possibilities which use `micromamba` for activation, it is advisable to install `mamba` into the environment and run

```bash
/opt/conda/bin/conda init bash
/opt/conda/bin/mamba init bash
```

These commands modify `~/.bashrc` so that the environment will be fully activated in subsequent interactive Bash sessions.

### Troubleshooting

If Bash is *not* being run interactively, then the `.bashrc` will not be sourced, so running `micromamba activate` will fail. In this case, you can either use the [direct activation procedure](#directly) or force an interactive shell by passing the `-i` flag to the `bash` command.

## License

MIT

## Author Information

Currently maintained by Ben Mares (@maresb) and Andreas Trawoeger (@atrawog). Initial version by @maresb. Contributions are welcome!
