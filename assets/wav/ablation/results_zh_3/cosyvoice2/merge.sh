#!/bin/bash

# 1. 获取所有通过下划线编号的文件前缀 (例如从 8_0.wav 提取出 "8")
# ls *_*[0-9].wav : 列出所有符合格式的文件
# sed ... : 去掉 "_数字.wav" 后缀
# sort -u : 去重，得到唯一的前缀列表 (如 3, 4, 5, 6, 7, 8)
prefixes=$(ls *_*[0-9].wav 2>/dev/null | sed -E 's/_[0-9]+\.wav$//' | sort -u)

if [ -z "$prefixes" ]; then
    echo "当前目录下未找到符合 '名称_数字.wav' 格式的文件。"
    exit 0
fi

for prefix in $prefixes; do
    echo "正在处理分组: $prefix ..."
    
    # 定义临时列表文件名
    list_file="list_${prefix}.txt"
    
    # 2. 生成 ffmpeg 需要的拼接列表
    # ls "${prefix}"_*.wav : 找到该组所有文件
    # sort -V : "版本排序" (Natural Sort)，确保 8_2 排在 8_10 前面，而不是后面
    # awk ... : 格式化为 ffmpeg 要求的格式: file '文件名'
    ls "${prefix}"_*.wav | sort -V | awk '{print "file \x27" $0 "\x27"}' > "$list_file"
    
    output_file="${prefix}.wav"
    
    # 3. 执行 ffmpeg 合并
    # -f concat : 使用 concat 分离器
    # -safe 0 : 允许读取相对路径
    # -i ... : 输入列表文件
    # -c copy : 【关键】流复制模式，不重新编码，速度极快
    # -y : 如果目标文件存在则直接覆盖
    ffmpeg -v error -f concat -safe 0 -i "$list_file" -c copy -y "$output_file"
    
    if [ $? -eq 0 ]; then
        echo "✅ 成功生成: $output_file"
        # 如果你想合并后自动删除原分片文件，取消下面这行的注释:
        # rm "${prefix}"_*.wav
    else
        echo "❌ 合并失败: $prefix"
    fi
    
    # 删除临时的列表文件
    rm "$list_file"
done

echo "所有任务完成。"
