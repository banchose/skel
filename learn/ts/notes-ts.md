# ts notes

The static import declaration is used to import read-only live bindings which are exported by another module.

## import

- Can only appear in a module
- Only at top level

```json
import defaultExport from "module-name";
```

### module-name

- Only string literals are allowed

## 4 Forms of `import` declarations

1. Named import: `import { export, export2 } from "module-name`;
2. Default import: defaultExport from "module-name";
3. Namespace import: `import * as name from "module-name";`
4. Side effect import: `import "module-name";`
