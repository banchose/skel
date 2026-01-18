# headless

```
# starts in normal mode '-s'
printf 'ifoo\x1b0~~~\n' | nvim -s - myfile.txt
```

## remote control

### with gui

```
nvim --listen 127.0.0.1:9000
nvim --server 127.0.0.1:9000 --remote-ui
:detach
```

### Without gui

```
# Start server with GUI visible
nvim --listen 127.0.0.1:9000 file.txt

# Pipe commands to it from another terminal
nvim --server 127.0.0.1:9000 --remote-send ':echo "Hello"<CR>'
```
