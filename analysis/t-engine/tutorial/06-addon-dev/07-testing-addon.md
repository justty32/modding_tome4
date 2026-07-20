### 方法一：直接放目錄

開發時不需要打包，直接把 Addon 目錄放在：

```
game/addons/my-shadow/
```

ToME 啟動後，在主選單進入「Addons」，勾選你的 Addon，重啟即生效。

### 方法二：使用 tome-addon-dev

啟用 `tome-addon-dev` Addon 後，遊戲內有 Debug 選單（按 F1 或進入 Debug > Addon Developer），提供：

- **FSHelper**：瀏覽 PhysFS 虛擬檔案系統，確認路徑是否正確掛載
- **NPCDesign**：即時測試 NPC 定義
- **TalentFinder**：搜尋所有天賦
- **ExampleAddonMaker**：快速生成 Addon 骨架

### 常見錯誤排查

```lua
-- 在 hooks/load.lua 或天賦 action 中加 print
print("Loading my talent definition...")

-- 確認天賦常數是否產生
-- 天賦 "Shadow Step" → T_SHADOW_STEP
-- 在遊戲 console (F1 LUA CONSOLE) 中執行：
-- print(ActorTalents.T_SHADOW_STEP)
```

| 錯誤情況 | 可能原因 |
|----------|----------|
| Addon 不出現在清單 | `for_module` 與遊戲模組不符；`init.lua` 語法錯誤 |
| 天賦不在職業選單 | `hooks` 未設 `true`；`ToME:load` hook 內路徑錯誤 |
| `T_SHADOW_STEP` 為 nil | 天賦定義未被 `ActorTalents:loadDefinition` 載入 |
| superload 崩潰 | 忘了 `return _M`；或 `loadPrevious(...)` 缺了 `...` |
| 路徑找不到 | `data/` 的真實路徑是 `/data-my-shadow/`，不是 `/data/` |

---
