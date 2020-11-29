## display status
git status

## generate wiki
python3 scan.py
cp -r source/* docs/

## commit to git
git add -A
git commit -m 'generate website on `date +%y%m%d`'
git push
