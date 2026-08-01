### 放置模組

將整個 `hellodungeon/` 目錄放到：

```
game/modules/hellodungeon/
```

### 執行引擎

**方式 A：用 Steam 安裝版（本機推薦，免編譯）**

```bash
# 模組放進 Steam 版的 modules 目錄
cp -r hellodungeon ~/.local/share/Steam/steamapps/common/TalesMajEyal/game/modules/

# 啟動
~/.local/share/Steam/steamapps/common/TalesMajEyal/t-engine64
```

**方式 B：從原始碼編譯**（需含 C 層的完整原始碼；本工作區 `vendor/t-engine4/` 只有 Lua 層）

```bash
# 先生成構建檔案（在完整原始碼根目錄）
premake4 gmake

# 編譯
make -C build

# 執行（Debug 版本）
./bin/Debug/t-engine
```

### 讓模組在清單中顯示

`init.lua` 預設沒有 `show_only_on_cheat`，所以會直接顯示在遊戲選擇畫面。

如果設定了 `show_only_on_cheat = true`，需要在設定中開啟 Cheat 模式，或直接移除這行。

---
