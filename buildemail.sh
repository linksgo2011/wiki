filepath=hexo/source/_posts/team
imageHost=https://github.com/linksgo2011/wiki/raw/master/$filepath/
source=retro.md

rm -rf build
mkdir build

cat ${filepath}/${source} > build/output.md
sed -i "" "s@src=\"@src=\"$imageHost@g" build/output.md
pandoc -s build/output.md -w html --template=email/email_template.html -o build/email.html --title-prefix email
