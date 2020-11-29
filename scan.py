import os
root = os.getcwd() + '/source'

def file_name(file_dir):
    output = ''

    for dir in os.listdir(root):
        if os.path.isdir(dir) != True:
            continue;
        output = output + '## ' + dir.strip() + '\r\n'
        subDir = root + '/' + dir;
        for file in os.listdir(subDir):
            if file.endswith('.md') != True:
                continue;
            fileName = subDir + '/' + file;
            file_object = open(fileName, 'r')
            lines = file_object.readlines()
            title = lines[1].replace('title: ','').strip('\r\n')
            file_object.close()
            path = dir + '/' + file
            output = output +  f'- [{title}]({path})' + '\r\n'
    with open('source/' + "README.md","w") as f:
            f.write(output)
file_name(root)
