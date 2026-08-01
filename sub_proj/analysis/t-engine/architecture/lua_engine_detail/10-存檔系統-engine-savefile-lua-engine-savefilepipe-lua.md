### 10.1 存檔格式

每次存檔 = 一個 **zip 檔案**，內含多個 Lua 序列化字串：

```
/save/<player_name>/
    save.lua          -- 頂層 game 物件入口
    <hash1>.lua       -- 某個子物件（Level、Actor、...）
    <hash2>.lua
    ...
```

每個物件序列化為：
```lua
setLoaded("hash1", {
    __CLASSNAME = "game.actor.Player",
    name = "Bob", level = 5,
    _actor_ref_ = loadObject("hash2"),  -- 跨物件引用
    ...
})
```

### 10.2 存檔流程

1. `game:save()` → `Savefile:init(name)` → 建立 zip。
2. `game:save(filter)` → `core.serial.new()` → 序列化根物件。
3. 遞迴遇到子物件 → `addToProcess(t)` → 排隊，後續序列化為獨立檔案。
4. 相同物件引用 → `loadObject(hash)` 取代（避免重複儲存）。
5. 完成後關閉 zip，可選 Steam Cloud 上傳。

### 10.3 讀檔流程

1. `Savefile:load()` → 解壓 zip 到 `/tmp/loadsave/`。
2. `class.load(str)` 反序列化字串，遇到 `loadObject` 就遞迴讀取子物件。
3. 設回 metatable（根據 `__CLASSNAME`）。
4. 延遲呼叫 `:loaded()`（確保相互引用都已建立後才初始化）。

### 10.4 SavefilePipe

後台存檔（background save）：
- 主執行緒繼續遊戲，存檔在 coroutine 中分批進行。
- 每次 yield 讓出控制權，避免卡頓。

### 10.5 MD5 完整性

- 部分類型的存檔啟用 MD5 校驗（`Savefile:setSaveMD5Type(type)`）。
- 讀取時若 MD5 不符記錄到 `bad_md5_loaded`，可用來偵測存檔修改。

---
