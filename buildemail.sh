folder=source/security
file=black-production.md
imageHost=https://github.com/linksgo2011/wiki/raw/master/$folder/

rm -rf build
mkdir build

cat ${folder}/${file} > build/output.md
sed -i "" "s@src=\"@src=\"$imageHost@g" build/output.md
pandoc -s build/output.md -w html --template=email/email_template.html -o build/email.html --title-prefix email
