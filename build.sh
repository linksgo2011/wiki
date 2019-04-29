## display status
git status


## generate wiki
cd hexo
npm run clean
npm run g


## commit to git
cd ..
cp CNAME docs/CNAME
git add -A
git commit -m 'generate website on `date +%y%m%d`'
git push