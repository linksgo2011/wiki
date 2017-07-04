cd hexo
hexo clean
hexo g


## commit to git
cd ..
cp CNAME docs/CNAME
git add -A
git commit -m 'generate website'
git push