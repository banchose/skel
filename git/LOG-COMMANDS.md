Yes, there are several ways to see which files were changed or added in a commit:

**To see files with their change status (added, modified, deleted):**
```bash
git show --name-status <commit-hash>
# git show --name-only <commit-hash>
```

**To see the actual diff/content changes along with files:**
```bash
git show <commit-hash>
```

**To see files changed in recent commits:**
```bash
git log --name-only
git log --name-status
git log --stat
```

The `--stat` option is particularly useful as it shows files along with the number of lines changed.

Based on the context provided, I can see that `git log` supports showing diff changes with the `-p` flag [2], which would display the actual content changes. You can combine this with other options to filter what you're looking for.

**For the most recent commit:**
```bash
git show --name-status
```
(no commit hash needed, defaults to HEAD)

Each of these approaches gives you different levels of detail—from just filenames to full diffs—so you can choose based on what information you need.

```sh
git log --diff-filter=A -- <filename>
git log --follow <filename>
git log --diff-filter=A --oneline -- <filename>
git log --name-status --diff-filter=A

```

