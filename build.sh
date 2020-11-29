## display status
git status


## generate wiki
rm -rf docs
cp -r source/* docs/

## commit to git
git add -A
git commit -m 'generate website on `date +%y%m%d`'
git push
