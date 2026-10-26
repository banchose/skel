# wsl ubuntu uses systemd-resolved

mount2404() {
  local mp=/mnt/wsl/ubuntu-2404
  if ! findmnt -n "$mp" >/dev/null; then
    mkdir -p "$mp" &&
      wsl.exe -d Ubuntu-24.04 -u root --cd / mount --bind / "$mp" || return
  fi
  sudo mount -o remount,bind,ro "$mp" && findmnt "$mp"
}
