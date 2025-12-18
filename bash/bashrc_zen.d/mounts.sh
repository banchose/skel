findusb() {

  find /sys/bus/usb/devices/*/host*/target*/*/block -name "sd*"
}

usbmount-mkdir() {

  [[ -d "/media/$USER/usb" ]] || sudo mkdir -p "/media/$USER/usb" && sudo chown "$USER" "/media/$USER/usb" && sudo chmod 0777 "/media/$USER/usb"

  sudo umount "/media/$USER/usb"
  sudo mount -o uid="$(id -u)",gid="$(id -g)",fmask=113,dmask=002 /dev/sdX1 "/media/$USER/usb"
}
