# udiskie

## USB made easyish 

- Worked

```
sudo pacman -Suy
sudo pacman install  udisks2 udiskie --needed  --noconfirm
# ~/.config/hypr/hyprland.conf
# exec-once = udiskie &
```


```
# info

## object
udisksctl info -p drives/PNY_USB_3_2e2_2e2_FD_07182B28BAD6D952

## device
udisksctl info -b /dev/sda


# mount
udisksctl mount -b  /dev/sdb

# unmount
udisksctl unmount -b /dev/sdb

# label
sudo exfatlabel /dev/sdb PNY256

```
