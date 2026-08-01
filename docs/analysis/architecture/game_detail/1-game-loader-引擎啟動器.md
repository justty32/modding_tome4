`game/loader/` 是整個引擎的第一段 Lua 代碼，在任何模組載入前執行。

### pre-init.lua

- **LuaJIT 初始化**：嘗試啟用 JIT（`jit.on()`，最佳化等級 2），失敗則降級到標準 Lua
- **RNG 工具函數**：注入全局 `rng.*` 函數（`mbonus`、`avg`、`table*`）
- **Table 序列化**：`table.serialize()` / `table.unserialize()` 用於遊戲狀態持久化
- **安全強化**：停用危險 OS 函數（`os.execute`、`os.getenv`、`os.remove`、`os.rename`）

### init.lua

**引擎發現與載入**：
- 掃描 `/engines/` 目錄尋找可用引擎版本（支援目錄型或 `.teae` 壓縮包）
- 解析版本字串（`engine/version.lua` 或 `name-X.Y.Z.teae` 檔名格式）
- 選取指定版本（預設 "LATEST"），掛載到虛擬根目錄

**模組 Loader 鏈**（自訂 `package.loaders`）：
- `te4_loader()`：實作 Addon **Superload** 能力
  - 載入原始模組後，依 `__addons_superload_order` 順序在 `/mod/addons/<addon>/superload/` 找覆蓋
  - `loadPrevious()` 讓 superload 取得原始模組
- Stub DLC：`.lua.stub` 映射到預編譯 DLCD 內容

**設計模式**：
- **三層初始化**：pre-init（VM 設定）→ init（引擎選取）→ engine/init（遊戲設定）
- **Plugin 架構**：Addon superloading 讓模組在不修改基礎代碼的情況下擴充任何模組

---
