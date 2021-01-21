folder=source/architecture
file=ddd-implement-repository.md
imageHost=https://github.com/linksgo2011/wiki/raw/master/$folder/

rm -rf build
mkdir build

cat ${folder}/${file} > build/output.md
sed -i "" "s@src=\"@src=\"$imageHost@g" build/output.md
pandoc -s build/output.md -w html --template=template/wechat_template.html -o build/wechat.html  --title-prefix email --highlight-style pygments

juice build/wechat.html build/wechat.html
