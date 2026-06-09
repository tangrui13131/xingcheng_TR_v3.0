# -*- coding: utf-8 -*-
import re

file_path = r'e:\RuoYi-Vue\ruoyi-admin\src\main\resources\application-druid.yml'

# 读取文件
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 替换密码 (只替换第一个匹配的 password 行)
content = re.sub(r'(^\s+password:\s+)\S+', r'\g<1>123456', content, count=1, flags=re.MULTILINE)

# 写回文件
with open(file_path, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

print("密码已成功修改为: 123456")
print(f"文件: {file_path}")
