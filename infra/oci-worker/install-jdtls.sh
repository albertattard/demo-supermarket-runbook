#!/usr/bin/env bash
# Install a pinned Eclipse JDT LS milestone during bootstrap or as administrator.
set -euo pipefail
umask 022

# Require root privileges and exactly two arguments: the archive URL and its
# SHA-256 checksum.
if [[ "$EUID" -ne 0 || "$#" -ne 2 ]]; then
  printf 'Usage: sudo bash %s <https://download.eclipse.org/...tar.gz> <sha256>\n' "$0" >&2
  exit 1
fi

# Validate the Eclipse milestone URL and checksum format, refuse an existing
# installation, and check that the expected JDK 25 Java executable is available.
archive_url="$1"
archive_sha256="$2"
[[ "$archive_url" =~ ^https://download\.eclipse\.org/jdtls/milestones/.+\.tar\.gz$ ]] \
  || { printf 'Use a pinned official Eclipse JDT LS milestone URL.\n' >&2; exit 1; }
[[ "$archive_sha256" =~ ^[a-f0-9]{64}$ ]] \
  || { printf 'Supply the archive SHA-256 digest.\n' >&2; exit 1; }
[[ ! -e /opt/jdtls ]] \
  || { printf '/opt/jdtls already exists; review the existing installation before replacing it.\n' >&2; exit 1; }
test -x /opt/java-worker/jdk-25/bin/java

# Download into a temporary directory, verify the checksum, and extract the
# archive. Check the Linux configuration and launcher before installing under
# /opt/jdtls. Remove group/other write permissions and clean up temporary files
# on exit.
download_dir="$(mktemp -d /var/tmp/jdtls-install.XXXXXX)"
trap 'rm -rf "$download_dir"' EXIT
curl --fail --location --retry 3 --proto '=https' --tlsv1.2 \
  "$archive_url" --output "$download_dir/jdtls.tar.gz"
printf '%s  %s\n' "$archive_sha256" "$download_dir/jdtls.tar.gz" | sha256sum --check -
mkdir "$download_dir/server"
tar --extract --gzip --file "$download_dir/jdtls.tar.gz" \
  --directory "$download_dir/server" --no-same-owner
test -f "$download_dir/server/config_linux/config.ini"
shopt -s nullglob
launchers=("$download_dir/server"/plugins/org.eclipse.equinox.launcher_*.jar)
[[ "${#launchers[@]}" -eq 1 ]] \
  || { printf 'Expected exactly one Equinox launcher in the JDT LS archive.\n' >&2; exit 1; }
mv "$download_dir/server" /opt/jdtls
chmod -R go-w /opt/jdtls

# State belongs to the client user, never to the root-owned server installation.
# The first argument is a unique absolute state directory per project/session.
cat > /usr/local/bin/java-lsp <<'LAUNCHER'
#!/usr/bin/env bash
set -euo pipefail
if [[ "$#" -lt 1 || "$1" != /* ]]; then
  printf 'Usage: java-lsp /absolute/project-state-directory [jdtls options]\n' >&2
  exit 1
fi
state_dir="$1"
shift
umask 077
mkdir -p "$state_dir/config" "$state_dir/data"
export JAVA_HOME=/opt/java-worker/jdk-25
export PATH="$JAVA_HOME/bin:$PATH"
shopt -s nullglob
launchers=(/opt/jdtls/plugins/org.eclipse.equinox.launcher_*.jar)
if [[ "${#launchers[@]}" -ne 1 ]]; then
  printf 'Expected exactly one Equinox launcher under /opt/jdtls/plugins.\n' >&2
  exit 1
fi
exec "$JAVA_HOME/bin/java" \
  -Declipse.application=org.eclipse.jdt.ls.core.id1 \
  -Dosgi.bundles.defaultStartLevel=4 \
  -Declipse.product=org.eclipse.jdt.ls.core.product \
  -Dosgi.checkConfiguration=true \
  -Dosgi.sharedConfiguration.area=/opt/jdtls/config_linux \
  -Dosgi.sharedConfiguration.area.readOnly=true \
  -Dosgi.configuration.cascaded=true \
  -Djdk.xml.maxGeneralEntitySizeLimit=0 \
  -Djdk.xml.totalEntitySizeLimit=0 \
  -Xms256m -Xmx1G \
  --add-modules=ALL-SYSTEM \
  --add-opens java.base/java.util=ALL-UNNAMED \
  --add-opens java.base/java.lang=ALL-UNNAMED \
  -jar "${launchers[0]}" \
  -configuration "$state_dir/config" -data "$state_dir/data" "$@"
LAUNCHER
chmod 0755 /usr/local/bin/java-lsp
printf 'Installed JDT LS. Start it through an LSP client using java-lsp and a unique state directory.\n'
