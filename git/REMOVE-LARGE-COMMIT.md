# Remove a large file from commits in git repo

## Look for the file in history

```sh
git log --all --full-history -- HRI-INFRA/OpenWebUI/s3-vector-backup/webui.db
```


## Install git-filter-repo

```sh
pipx install git-filter-repo
```

## Create a clean environment

```sh
cd ~/gitdir
git clone https://github.com/banchose/aws aws-clean
cd aws-clean
```

## git-filter-repo removes origin for safety

```sh
git filter-repo --path HRI-INFRA/OpenWebUI/s3-vector-backup/webui.db --invert-paths
```

## Add the original repo and push the changes

```sh
git remote add origin https://github.com/banchose/aws
git push origin --force --all
git push origin --force --tags
```

## Clean up

```sh
cd ~/gitdir
rm -rf aws-clean
```


# cd ~/gitdir/aws
# echo "*.db" >> .gitignore
## git add .gitignore
## git commit -m "Add .db files to .gitignore"
## git push

