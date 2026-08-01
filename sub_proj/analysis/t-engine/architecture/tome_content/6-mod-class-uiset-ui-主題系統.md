ToME 支援可切換的 UI 佈局主題（UISet）。

### 6.1 檔案結構

| 檔案 | 大小 | 說明 |
|------|------|------|
| `UISet.lua` | 1.7KB | UISet 基礎類別 |
| `Classic.lua` | 22KB | 傳統 UI 佈局 |
| `ClassicPlayerDisplay.lua` | 22KB | 傳統玩家資訊面板 |
| `Minimalist.lua` | 105KB（最大）| 極簡 UI 主題 |

### 6.2 UISet 架構

**UISet.lua** — 基礎介面：
- `UISet:init()` — 初始化 UI 元素
- `UISet:display()` — 每幀繪製回呼
- `UISet:resize(w, h)` — 視窗大小改變時重排
- `UISet:getTargetDisplay(actor)` — 取得目標資訊顯示格式

### 6.3 Classic UI（傳統佈局）

**Classic.lua** — 主佈局：
- 底部：訊息 log（1-5 行，可設定）
- 右側：玩家屬性面板
- 右上：小地圖
- 整合快捷鍵列（3 頁 × 12 格）

**ClassicPlayerDisplay.lua** — 玩家資訊面板：
- 生命/魔力/體力等資源條（顏色編碼）
- 當前效果圖示
- 裝備欄縮略圖
- 屬性數值（根據是否有效果而閃爍）

### 6.4 Minimalist UI（極簡佈局）

**Minimalist.lua**（105KB）— 最複雜的 UI 主題：

主要設計理念：
- **地圖最大化**：移除固定面板，只在需要時顯示 HUD
- **條件式顯示**：資源條只在資源不滿或最近變化時顯示
- **通知氣泡**：事件用飄動文字取代靜態 log
- **智慧縮放**：根據視窗大小自動調整所有元素

顯著功能：
- 自訂圖示庫（技能/效果圖示）
- 動畫資源條（血量下降時紅色脈衝）
- 拖曳式快捷鍵列
- 可收合的多個資訊浮動面板

---
