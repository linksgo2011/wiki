folder=architecture
file=ddd-distribution-architecture.md
imageHost=http://cdn.printf.cn/$folder/

rm -rf build
mkdir build

cat source/${folder}/${file} > build/output.md
sed -i "" "s@src=\"@src=\"$imageHost@g" build/output.md
pandoc -s build/output.md -w html --template=template/wechat_template.html -o build/wechat.html  --title-prefix email --highlight-style pygments

juice build/wechat.html build/wechat.html
