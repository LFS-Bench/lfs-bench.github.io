import os
import re
from pydub import AudioSegment

def merge_wav_files(directory="."):
    # 用于存储分组信息，格式: {'文件名不带后缀': [(索引, '完整文件名'), ...]}
    # 例如: {'8': [(0, '8_0.wav'), (1, '8_1.wav'), ...]}
    groups = {}
    
    # 正则表达式匹配 "数字_数字.wav" 的格式
    # group(1) 是主文件名 (如 "8"), group(2) 是分片索引 (如 "0")
    pattern = re.compile(r"^(.+)_(\d+)\.wav$")

    # 1. 扫描目录并分组
    files = [f for f in os.listdir(directory) if f.endswith(".wav")]
    
    for filename in files:
        match = pattern.match(filename)
        if match:
            base_name = match.group(1)
            index = int(match.group(2))
            
            if base_name not in groups:
                groups[base_name] = []
            groups[base_name].append((index, filename))
    
    # 2. 遍历分组进行拼接
    for base_name, file_list in groups.items():
        # 按索引数字排序 (确保 8_2 在 8_10 前面，如果存在多位数索引)
        file_list.sort(key=lambda x: x[0])
        
        print(f"正在拼接 {base_name}.wav (包含 {len(file_list)} 个分片)...")
        
        combined_audio = AudioSegment.empty()
        
        for _, filename in file_list:
            file_path = os.path.join(directory, filename)
            try:
                audio = AudioSegment.from_wav(file_path)
                combined_audio += audio
            except Exception as e:
                print(f"  读取文件 {filename} 失败: {e}")
                
        # 3. 导出拼接后的文件
        output_filename = f"{base_name}.wav"
        output_path = os.path.join(directory, output_filename)
        
        try:
            combined_audio.export(output_path, format="wav")
            print(f"✅ 成功生成: {output_filename}")
        except Exception as e:
            print(f"❌ 导出 {output_filename} 失败: {e}")

if __name__ == "__main__":
    # 默认处理当前目录，也可以传入指定路径，如 merge_wav_files("/path/to/wavs")
    merge_wav_files()
