### Base.lua — UI 基底

所有 UI 元件的基底：

- 靜態字型：`font`（DroidSans 12pt）、`font_mono`、`font_bold`
- 主題系統：`loadUIDefinitions(file)` — 可換皮（9-patch frame + 顏色）
- 材質快取：`cache` / `tcache`，避免重複載入
- `makeFrame(base, w, h, iw, ih)` — 9-patch 邊框建構
- `drawFrame(f, x, y, r, g, b, a, w, h)` — 含裁切的邊框渲染

### Dialog.lua — 視窗容器

```lua
local d = Dialog.new("Title", width, height)
d:loadUI{
    {left=3, top=3, ui=Button.new{...}},
    {right=3, bottom=3, ui=List.new{...}},
}
d:setupUI(auto_w, auto_h)
game:registerDialog(d)
```

- 錨點佈局：`{left, right, top, bottom, vcenter, hcenter}`
- Modal 堆疊：`game.dialogs` 頂部接收輸入
- 工廠方法：`simplePopup`、`simpleWaiter`、`listPopup`、`yesnoPopup` 等

### 主要 UI 元件

| 元件 | 特色 |
|------|------|
| `Button` | 點擊 callback；glow 動畫；失焦淡出 |
| `List` | 可捲動清單；鍵盤（↑↓, Home/End, PgUp/Dn）+ 滾輪操作 |
| `ListColumns` | 多欄清單，可調整欄寬 |
| `TreeList` | 可展開/收合的樹狀清單 |
| `Textzone` | 富文本（色彩 tag）；慣性捲動；可選 shadow shader |
| `TextzoneList` | 多段文字 + 條目選擇 |
| `Textbox` | 單行輸入框，支援 Unicode |
| `Numberbox` | 數字輸入框 |
| `Slider` / `NumberSlider` | 滑桿 |
| `Checkbox` | 勾選框 |
| `Dropdown` | 下拉選單 |
| `Tabs` | 標籤頁切換；滑鼠事件委派 |
| `ImageList` | 圖像格狀選擇（技能/物品圖示）|
| `EquipDoll` | 人形裝備圖（點擊對應部位）|
| `EntityDisplay` | 顯示實體圖像與描述 |
| `Waitbar` / `Waiter` | 進度條 |
| `WebView` | 嵌入網頁（CEF3/Awesomium）|
| `UIContainer` / `UIGroup` | 容器/群組佈局 |
| `SurfaceZone` | 自由繪製區域（GL surface）|

### 預建對話框 (dialogs/)

| 對話框 | 功能 |
|--------|------|
| `GameMenu` | 主選單/暫停選單 |
| `ShowInventory` / `ShowEquipment` / `ShowEquipInven` | 物品/裝備管理 |
| `ShowPickupFloor` | 地板撿取 |
| `ShowStore` | 商店界面 |
| `ShowQuests` | 任務列表 |
| `ShowLog` | 訊息記錄 |
| `ShowAchievements` | 成就清單 |
| `ViewHighScores` | 排行榜 |
| `UseTalents` | 技能使用 |
| `KeyBinder` | 按鍵設定 |
| `VideoOptions` / `AudioOptions` | 影音設定 |
| `DisplayResolution` | 解析度設定 |
| `LanguageSelect` | 語言選擇 |
| `Downloader` | 更新/下載器 |
| `Chat` / `ChatChannels` / `ChatFilter` | 在線聊天 |
| `GetText` / `GetQuantity` / `Talkbox` | 輸入對話 |
| `UserInfo` | 用戶資料 |

---
