Yes, use the `-I` flag:

```bash

tree -I '.git'

```

To ignore multiple patterns, separate with `|`:

```bash

tree -I '.git|node_modules|__pycache__'

```