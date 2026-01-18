# Nvim Remote commands

```sh
mytext="hello frisco"; nvim --server 127.0.0.1:9000 --remote-send ':echo "Hello"<CR>:cd ~/temp<CR>:pwd<CR>:e! boom.txt<CR>0ggDGithis mytext: '"${mytext}"'<ESC>:w! boom.txt<CR>'

```
