# OCI Java modernisation worker

Facilitator infrastructure for `demo-supermarket-runbook`. Terraform creates one
disposable **Oracle Linux 10 x86_64** VM in an existing compartment, plus its own
VCN, Internet gateway, route table, regional public subnet, and security list.
This infrastructure is not copied into the attendee starter repository.

The default worker has 1 OCPU, 8 GB RAM, and a 50 GB boot volume. These are starting
values for this small project, not measured performance requirements. This is a
paid flexible shape; do not assume Always Free eligibility or regional capacity.

## Installed software

Cloud-init installs Oracle JDK 25, native Codex CLI, Eclipse JDT LS, Git, `jq`,
`ripgrep` (from the Codex package), `bubblewrap`, and archive/download
utilities. Maven comes from the project's existing wrapper. Oracle's
`jdk-25-headful` package includes the compiler and requires the headless runtime;
it does not mean this VM needs a desktop environment.

Codex defaults to release `0.162.1`. Its full standalone package is checked
against a pinned SHA-256 digest; its helper files stay together under `/opt/codex`.
To change versions, update **both** `codex_version` and `codex_sha256`. Package
versions from the Oracle RPM repositories are resolved at boot, so
Codex and JDT LS are pinned, while the latest compatible OS image is selected
at plan time. This is not a fully frozen software image.
JDK updates remain within Java 25. Installed RPM versions are recorded in
`/var/lib/java-worker/packages.txt`.

Terraform selects the latest available official Oracle Linux 10 **x86_64** platform
image in your region compatible with the configured E4/E5 Flex shape, ordered by
creation time. No image OCID input is needed. The platform image supplies the
`ol10_oci_included` repository for Oracle JDK. Bootstrap enables it explicitly and
fills an empty `/etc/dnf/vars/ociregion` from IMDSv2 so DNF uses the OCI regional
mirror. Some platform images leave the repository disabled and the region blank;
the public mirror does not supply OCI Included content. Arm and custom images are excluded;
bootstrap also checks CPU architecture. A1 shapes are not supported.

A newer image can cause Terraform to replace the disposable VM on a subsequent
apply. Review the plan and copy needed evidence out before replacing it.
Use `terraform output image_name` and `terraform output image_id` to inspect the
selected image after applying. Remove any old `image_id` entry from your variables file.

## Provision

Prerequisites on your machine:

- Terraform 1.5 or later and OCI API-key authentication in `~/.oci/config`.
- An existing compartment and permission to manage its compute and network
  resources. No OCI credentials are installed on the worker.
- An SSH key pair. Set `ssh_private_key_path` to the private key corresponding
  to `ssh_public_key_path`. Terraform passes the expanded private-key path to
  the readiness check; the private-key contents remain on your machine.
- Your public IPv4 address in `/32` notation. SSH is restricted to this address;
  update the value and apply again if your address changes.

From this directory:

```shell
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your region, compartment, SSH key paths, and IP.
terraform init
terraform fmt -check
terraform validate
terraform plan -out=worker.tfplan
terraform apply worker.tfplan
terraform output -raw ssh_command
```

Terraform discovers the full tenancy-prefixed **AD-1** name from OCI using your
compartment and configured region. No availability-domain input is needed.
Remove any `availability_domain` or `availability_domain_number` entries from
existing variables files. Selection matches the `AD-1` suffix, not the API's
list order. Inspect the selected name with `terraform output -raw availability_domain`
after applying.

The configuration uses your local OCI profile (default `DEFAULT`). It does not
create a compartment or IAM policies, grant instance-principal permissions, clone
the application, configure model/repository authentication, or start scheduled
modernisation runs. Terraform variables and cloud-init contain no credentials.

`terraform apply` waits for bootstrap through `check-bootstrap.sh`, invoked by
the `terraform_data.worker_ready` resource. The check retries SSH up to 60 times
(5-second connection timeout and 5 seconds between attempts), then allows
cloud-init up to 15 minutes to finish. The cloud-init check also retries SSH
transport failures (up to 60 attempts within that wait budget); a reported
bootstrap failure stops immediately. It requires successful cloud-init status,
the `ready` marker, and no `failed` marker. On failure it prints the last cloud-init
log lines and causes Terraform and `deploy.sh` to exit unsuccessfully.

The VM remains available for diagnosis. A subsequent apply retries a failed
readiness check; it does not rerun bootstrap on an existing VM. Bootstrap changes
still replace the VM as described below. The check runs on creation/replacement
of the readiness resource, not as a continuous health check. SSH trusts a new
host key on first connection and rejects changed known keys.

Connect using the private key corresponding to the configured public key:

```shell
ssh -i ~/.ssh/id_ed25519 opc@<public-ip>
sudo cloud-init status --wait --long
sudo test -f /var/lib/java-worker/ready
sudo cat /var/lib/java-worker/packages.txt
sudo -iu agent
java -version
javac -version
codex --version
cd ~/work
codex sandbox -- /bin/true
```

The `opc` account is the OCI administrator. `agent` owns its workspace and has no
sudo grant or SSH key. Run the model and build processes as `agent`, never as
`opc` or root. Bootstrap tests the Linux sandbox under that account and records a
failure in `/var/lib/java-worker/failed`. Inspect `/var/log/cloud-init-output.log`
if installation or sandbox startup fails. SELinux remains enabled.

For non-login runners, explicitly set `JAVA_HOME=/opt/java-worker/jdk-25` and include
`/opt/java-worker/jdk-25/bin:/usr/local/bin:/usr/bin:/bin` in `PATH`. Bootstrap creates
this stable symlink from the installed RPM's versioned JDK directory. Login shells
load the same Java path from `/etc/profile.d/java-worker.sh`.

## Maven cache and sandbox access

Bootstrap creates `/home/agent/.m2`, including its `repository` and `wrapper`
directories, with owner `agent:agent` and mode `0700`. It also writes
`/home/agent/.codex/config.toml` with:

```toml
sandbox_mode = "workspace-write"

[sandbox_workspace_write]
writable_roots = ["/home/agent/.m2"]
```

Both are required: filesystem ownership permits the account to write, and the
Codex setting permits writes outside the current checkout. This grants cache
access to workspace-write runs using the agent's normal Codex home. Managed
requirements and higher-priority configuration still apply. See the
[Codex configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference).

Before creating the ready marker, bootstrap starts a Codex sandbox from
`/home/agent/work` and verifies writes in both cache directories.
Any failure prevents readiness. To repeat
the checks after connecting as `agent`:

```shell
cd ~/work
codex sandbox -c 'sandbox_mode="workspace-write"' -- bash -euc '
  for cache_dir in /home/agent/.m2/repository /home/agent/.m2/wrapper; do
    probe="$(mktemp "$cache_dir/manual-write.XXXXXX")"
    printf "Maven cache write check\n" > "$probe"
    rm -- "$probe"
  done
'
```

Bootstrap prepares cache permissions only. The project's `./mvnw` downloads Maven
on first use; Maven downloads application dependencies and build plugins as needed.
The cache permission does not enable sandbox network access. With a
network-restricted execution policy, these downloads must happen in a trusted
preparation step before asking Codex to run tests; otherwise they can still be
blocked.

The scheduled modernisation runner performs this preparation after cloning the
uploaded bundle: it runs `./mvnw --batch-mode --no-transfer-progress clean package`
as `agent`, outside the Codex sandbox, before starting Codex. This populates the
same account's cache and checks the baseline unit tests. A preparation failure
stops the run, with output retained in the controller's `evidence/worker.log`.
This covers dependencies through the package phase; later lifecycle phases may
require additional downloads.

Apply this change through the plan/apply procedure above. The bootstrap hash
changes, so Terraform replaces an existing disposable VM, including its local
cache, credentials, and run evidence. Copy needed evidence out first and restore
Codex authentication after replacement. This repository change alone does not
update a running VM.

## Codex authentication

Authenticate Codex separately under `agent` using an organisation-approved method
(for an interactive headless setup, inspect `codex login --help`). Do not put an
API key, GitHub token, OCI key, or private SSH key in Terraform variables or
cloud-init: their contents are stored in state and VM metadata.

To copy an existing laptop `auth.json` to the worker, run from this directory:

```shell
./copy-codex-auth.sh "$(terraform output -raw public_ip)" "$(terraform output -raw ssh_private_key_path)"
```

Use the private key configured for this VM. The script connects directly as
`opc` and writes `/home/agent/.codex/auth.json` as `agent`, with directory mode
`700` and file mode `600`. It replaces an existing file atomically. No tunnel
is needed and the credentials never pass through Terraform state or cloud-init.
Run it again when you deliberately want to replace the worker credentials.

The host and key can instead come from `CODEX_MODERNISATION_WORKER_HOST` and
`CODEX_MODERNISATION_SSH_PRIVATE_KEY_PATH` (or `SSH_PRIVATE_KEY_PATH`). With no
host argument or environment variable, the script reads this directory's
Terraform `public_ip` output. With no key configured, SSH selects the key using
its normal configuration or ssh-agent. The source defaults to
`${CODEX_HOME:-$HOME/.codex}/auth.json`; set `CODEX_AUTH_FILE` to override it.

## Network and workflow boundaries

Only TCP 22 from `ssh_source_cidr` is admitted by this subnet's security list.
Outbound IPv4 Internet traffic is permitted for package downloads, model access,
Git reads, and Maven dependencies. This is a dedicated demo network, **not**
domain-restricted egress or a private enterprise deployment. No application or
LSP port is opened. Legacy metadata endpoints are disabled; that does not block
IMDSv2 access or create a per-process cloud permission boundary.

The scheduled runner keeps clone, commit, push, and draft-PR creation on the
controller. It transfers a Git bundle with history to a fresh VM workspace over
SSH as `opc`, then runs Codex as `agent`. Codex may run tests permitted by the
existing policy; the prompt prohibits Maven `verify`. The worker's origin
points at that local bundle. GitHub credentials,
controller Git configuration, and SSH-agent forwarding are not sent to the VM.
The patch, JSON hand-off, Git-state observations, and execution logs return to
the controller. The controller validates them, checks Maven inputs, and runs
`./mvnw clean verify` independently before committing or publishing, regardless
of the worker's reported test results. GitHub CLI (`gh`) belongs on the
controller; it is not installed on the VM.

After authenticating Codex as `agent`, configure the controller from this directory:

```shell
export CODEX_MODERNISATION_WORKER_HOST="$(terraform output -raw public_ip)"
export CODEX_MODERNISATION_SSH_PRIVATE_KEY_PATH="$(terraform output -raw ssh_private_key_path)"
# From your personal starter fork checkout:
CODEX_MODERNISATION_SOURCE_REPOSITORY="$(git remote get-url origin)" \
  ./tools/run-scheduled-java-modernisation.sh
```

Use the private key corresponding to `ssh_public_key_path`. The key variable is
optional when local SSH configuration or ssh-agent already selects that key.
The controller needs `bash`, `ssh`, `git`, `gh`, `jq`, and JDK 25, with Git/GitHub
publication authentication configured. Maven comes from the project wrapper;
the controller needs network access for its verification build. Codex runs only
on the worker.
An unattended scheduler must supply the same environment and authentication.
Each invocation creates a fresh temporary checkout on the controller and a
unique `/home/agent/work/modernisation.*` directory on the worker. Earlier
checkouts and patches are not reused. Both machines retain all run files for
inspection; the runner performs no automatic cleanup. Remove old run directories
manually when you no longer need them, leaving installed tools, authentication,
and shared dependency caches in place.

A later invocation stops if the remote candidate branch still exists awaiting
review. Do not schedule overlapping invocations: separate directories isolate
the checkouts, but concurrent runs can still duplicate assessment work and race
to publish the same branch.

Changing the bootstrap template, JDT LS
installer, or pinned Codex/JDT LS inputs replaces the disposable VM. Copy needed
evidence out first. Updating cloud-init metadata on a running VM
is not a reliable software update mechanism. For OS updates requiring a reboot,
schedule an administrator-controlled reboot before using the worker.

When finished:

```shell
terraform plan -destroy
terraform destroy
```

Destroy removes the VM, its boot volume, and this dedicated network. Protect
Terraform state and saved plans; both are ignored by Git. Commit the generated
`.terraform.lock.hcl` to retain the chosen provider version and checksums.

## Java language server

Eclipse JDT Language Server (JDT LS) supports Java 25, Maven project import,
diagnostics, navigation, references, and code actions. Its documented minimum
runtime is Java 21, so this worker's JDK 25 satisfies that requirement.

Installing a server is separate from connecting an agent to it. A language server
speaks LSP; it is not an MCP server or a command that automatically exposes
semantic tools to Codex. This configuration does not assert a native Codex LSP
integration or add an adapter. Maven verification remains authoritative.

Cloud-init installs JDT LS automatically using `install-jdtls.sh`, embedded in
Terraform's `user_data` alongside the bootstrap script. No manual `scp` upload or
administrator installation is needed. The installer is retained at
`/usr/local/libexec/java-worker/install-jdtls.sh` on the VM.

The default is milestone **1.57.0**, using the timestamped archive and SHA-256
published by Eclipse. To change it, update **both** `jdtls_archive_url` and
`jdtls_sha256`, selecting a pinned milestone with Java 25 support. The selected
URL and checksum are recorded in `/var/lib/java-worker/jdtls-archive.txt`.
A download, checksum, or installation failure prevents the bootstrap ready marker.

After bootstrap completes, run your LSP client as `agent`. It should launch:

```shell
sudo -iu agent
java-lsp /home/agent/work/jdtls-state/<job-id>
```

The installer verifies the archive and installs it under root-owned `/opt/jdtls`.
The Bash `java-lsp` launcher invokes JDK 25 directly, with no Python launcher or
explicit Python installation requirement. It selects the archive's Equinox
launcher JAR and uses writable per-session configuration/data directories backed
by the server's read-only shared configuration. Communication is over stdin/stdout
by default; it needs an LSP
client to initialise it and open/import the project. Do not share its state
directory across concurrent projects or sessions. The installer refuses to
overwrite an existing installation; upgrades require an explicit administrator
replacement decision.

Engineering effort estimates, not vendor guarantees:

| Work | Estimated effort |
| --- | --- |
| Install a pinned JDT LS and verify project import with an existing LSP client | 30–60 minutes |
| Wire an existing suitable LSP-to-agent adapter and validate diagnostics/references | Half a day to one day |
| Build and test a small adapter with project initialisation, indexing readiness, timeouts, and process cleanup | Several days |

For this demo, first prove native Codex on the VM and independent
`./mvnw clean verify` on the controller. JDT LS is installed, but connecting it
to Codex still requires an LSP client or
adapter and validation of project import and process lifecycle.

References:

- [Oracle JDK repositories for OCI Oracle Linux](https://yum.oracle.com/oracle-linux-java.html)
- [OCI Terraform compute resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance)
- [Codex installation](https://learn.chatgpt.com/docs/codex/cli)
- [Codex Linux sandbox prerequisites](https://learn.chatgpt.com/docs/sandboxing)
- [Pinned JDT LS 1.57.0 distribution and checksum](https://download.eclipse.org/jdtls/milestones/1.57.0/)
- [Eclipse JDT LS requirements and launch options](https://github.com/eclipse-jdtls/eclipse.jdt.ls)
