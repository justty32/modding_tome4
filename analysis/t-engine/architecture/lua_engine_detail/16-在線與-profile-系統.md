### 16.1 PlayerProfile (`engine/PlayerProfile.lua`)

```lua
profile = PlayerProfile.new()
profile:start()   -- 啟動後台 profile thread
```

- 在獨立 thread 處理與 te4.org 的通訊（防止主執行緒阻塞）。
- 功能：登入、排行榜提交、成就同步、角色 vault 上傳、在線聊天。

### 16.2 UserChat (`engine/UserChat.lua`)

全局頻道聊天，使用 LuaSocket 連接 te4.org 伺服器。

### 16.3 MicroTxn (`engine/MicroTxn.lua`)

Steam DLC 微交易整合，透過 `core.steam` API。

---
