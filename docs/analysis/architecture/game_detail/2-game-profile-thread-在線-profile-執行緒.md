獨立執行緒，負責維持與 te4.org 伺服器的連線，避免阻塞主遊戲迴圈。

### init.lua

執行緒初始化與生命週期管理。

### Client.lua

**雙 TCP Socket 架構**：
- 主 Socket（port 2257/2260）：請求/回應（認證、角色存檔、設定）
- Push Socket（port 2258/2260）：伺服器主動推送事件
- 元伺服器查詢：`profiles.te4.org:2240` 動態路由

**主要功能**：

| 功能 | 方法 |
|------|------|
| 認證 | Steam token（`STM_`）或帳號密碼（`AUTH`/`PASH`）|
| 角色管理 | `orderRegisterNewCharacter()`、chardump 兩段上傳 |
| 設定同步 | `orderSetConfigsBatch()` — 批次設定 + zlib 壓縮 |
| 雜湊驗證 | 模組/Addon MD5 批次校驗 |
| Addon 管理 | 版本上傳、Steam Workshop 整合、更新檢查 |
| 微交易 | Steam/TE4 購物車建立與完成 |
| 心跳 | 60 秒 keep-alive |

**設計模式**：Producer-Consumer（主執行緒推送命令，profile-thread 推回事件）、Non-blocking I/O（`socket.select()`）

### UserChat.lua

- 事件路由：talk、whisper、成就廣播、序列化資料
- 頻道管理：join/part 追蹤
- 好友列表：`FriendJoin`/`FriendPart` 事件

---
