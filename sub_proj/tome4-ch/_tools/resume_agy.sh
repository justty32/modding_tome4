#!/usr/bin/env bash
# agy 額度監視器：額度回復後自動補翻 verdant + arcanum 並組裝驗證
cd ~/repo/moddings/tome4/sub_proj/tome4-ch
echo "[$(date +%H:%M:%S)] 監視啟動" >> _work/resume_result.txt
while true; do
  r=$(agy --dangerously-skip-permissions --print-timeout 2m -p 'Reply with exactly: OK' 2>/dev/null | tr -d '[:space:]')
  [ -n "$r" ] && break
  sleep 1200
done
echo "[$(date +%H:%M:%S)] agy 已回復，開始補翻" >> _work/resume_result.txt
python3 _tools/translate.py _work/verdant >> _work/verdant/log.txt 2>&1
python3 _tools/translate.py _work/arcanum >> _work/arcanum/log.txt 2>&1
{
  python3 _tools/assemble.py verdant tome-verdant-zh _work/verdant/salvage.lua
  python3 _tools/assemble.py arcanum tome-arcanum-zh
  lua5.1 _tools/check_locale.lua tome-verdant-zh/data/locales/zh_hant.lua _reference/orig/verdant/ | head -1
  lua5.1 _tools/check_locale.lua tome-arcanum-zh/data/locales/zh_hant.lua _reference/orig/arcanum/ | head -1
  echo "[$(date +%H:%M:%S)] DONE"
} >> _work/resume_result.txt 2>&1
