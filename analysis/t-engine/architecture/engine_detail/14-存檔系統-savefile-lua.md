### 格式

每次存檔 = 一個 zip 檔，內含多個 Lua 序列化字串：

```
/save/<player_name>/
    save.lua          -- 頂層 game 物件
    description.lua   -- 元資料（模組、版本、Addon、可讀取旗標）
    <hash1>.lua       -- 某個子物件（Level、Actor…）
    <hash2>.lua
```

### 存檔流程

1. `game:save()` → `Savefile:init(name)` → 建立 zip
2. `core.serial.new()` 序列化根物件
3. 遞迴遇到子物件 → `addToProcess(t)` 排隊
4. 相同物件引用 → `loadObject(hash)` 取代（避免重複）
5. 完成後關閉 zip，可選 Steam Cloud 上傳

### 讀檔流程

1. `Savefile:load()` → 解壓到 `/tmp/loadsave/`
2. `class.load(str)` 反序列化，遇 `loadObject` 遞迴讀取
3. 根據 `__CLASSNAME` 重設 metatable
4. 延遲呼叫 `:loaded()`（確保相互引用建立後才初始化）

### 其他特性

- `SavefilePipe`：背景存檔（協程分批，避免卡頓）
- `setSaveMD5Type(type)`：啟用 MD5 校驗（偵測存檔修改）
- `saveQuickBirth(descriptor)` / `loadQuickBirth()` — 快速角色創建模板

---
