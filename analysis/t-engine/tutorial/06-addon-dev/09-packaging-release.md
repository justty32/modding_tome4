開發完成後，將 Addon 目錄壓縮成 `.team` 格式：

```bash
# 進入 Addon 目錄的父目錄
cd game/addons/

# 使用 zip 打包（.team 就是標準 zip）
zip -r my-shadow-1.0.0.team my-shadow/
```

發布時：
- 放在 [te4.org](https://te4.org) 的 Addon 頁面
- 或直接分發 `.team` 檔案，玩家放入 `~/.t-engine/4.0/game/addons/` 即可

---
