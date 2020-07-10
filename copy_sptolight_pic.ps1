
# ����ͼ����
[system.reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null

# ����ԴĿ¼
# $env:LOCALAPPDATA ϵͳ����,����ִ���û�����ʹ�ñ���
# $source_dir = "C:\Users\xxxxxx\AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets\"
$source_dir = Join-Path (Get-ChildItem -Path (Join-Path $env:LOCALAPPDATA "Packages") -Recurse -Filter Microsoft.Windows.ContentDeliveryManager* | ? { $_.PSIsContainer } | % { $_.FullName }) "LocalState\Assets"

# ��ȡ��ǰĿ¼
# $shell_dir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$shell_dir = ($PWD).Path

# ����ͼƬ���Ŀ¼ 1Ϊ���Ŀ¼ 2Ϊ�ݰ�Ŀ¼
# ����ͼƬ�ݺ���������ͬĿ¼ Ҳ����������ͬĿ¼
$output_dir1 = Join-Path $shell_dir 'Windows Sptolight'
$output_dir2 = Join-Path $shell_dir 'Windows Sptolight2'

if (!(Test-Path $output_dir1)) {
  New-Item -ItemType Directory -Force -Path $output_dir1 | Out-Null
}
if (!(Test-Path $output_dir2)) {
  New-Item -ItemType Directory -Force -Path $output_dir2 | Out-Null
}

# �������log�ļ�
$logfile = Join-Path $shell_dir 'log_for_sptolight.log'

# ��ȡ����100KB��ͼƬ�ļ������б�
$pic_file_list = Get-ChildItem $source_dir | Where-Object { $_.Length -gt 100kb } | Select-Object Name

# ls variable:

$copy_file_number = 0
$skip_file_number_small = 0
$skip_file_number_same = 0

# ���ļ����д���
foreach($file in $pic_file_list) {
  $source_file = Join-Path $source_dir $file.name
  
  # ��ԴͼƬ������жԱ��ж�
  $pic_size = New-Object System.Drawing.Bitmap($source_file)
  
  if (($pic_size.height -lt 800) -or ($pic_size.width -lt 800)) {
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] small picture skip: $source_file" | Out-File -Append -FilePath $logfile
    $msgout = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] picture height: " + $pic_size.height + ", width: " + $pic_size.width
    Write-Output $msgout | Out-File -Append -FilePath $logfile
    $skip_file_number_small++
    continue
  }
  if ($pic_size.height -lt $pic_size.width) {
    $output_file = (Join-Path $output_dir1 $file.name) + ".jpg"
  } else {
    $output_file = (Join-Path $output_dir2 $file.name) + ".jpg"
  }
  
  # �жϲ������ļ���Ŀ¼
  if (!(Test-Path $output_file)) {
    Copy-Item $source_file $output_file
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] source file is: $source_file" | Out-File -Append -FilePath $logfile
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] output file is: $output_file" | Out-File -Append -FilePath $logfile
    $copy_file_number++
  } else {
    $skip_file_number_same++
  }
}

Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] file check finished. copy $copy_file_number files. skip $skip_file_number_same same files. skip $skip_file_number_small small files." | Out-File -Append -FilePath $logfile

