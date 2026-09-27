# ts notes

The static import declaration is used to import read-only live bindings which are exported by another module.

## Types

- TypeScript is JavaScript’s runtime with a compile-time type checker
- TypeScript checks a program for errors before execution, and does so based on the **kinds of values**, making it a static type checker.

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
