### 11.1 Base (`engine/ui/Base.lua`)

所有 UI 元件的基底，提供：
- **字型**：`font`（DroidSans 12pt）、`font_mono`（等寬）、`font_bold`。
- **UI 主題**：`ui = "dark"`（可換皮），透過 `loadUIDefinitions(file)` 載入主題設定（顏色、圖片路徑）。
- **材質快取**：`cache` / `tcache`，避免重複載入圖像。
- **音效**：`sounds.button` 等互動音效。

### 11.2 Dialog (`engine/ui/Dialog.lua`)

視窗基底，提供：
```lua
local d = Dialog.new("Title", width, height)
d:loadUI{
    {left=3, top=3, ui=Button.new{...}},
    {right=3, bottom=3, ui=List.new{...}},
}
d:setupUI(auto_w, auto_h)  -- 自動計算大小
game:registerDialog(d)
```

- **Layout**：`{left, right, top, bottom, vcenter, hcenter}` 錨點定位，支援相對座標。
- **Modal 堆疊**：`game.dialogs` 是個堆疊，頂部 dialog 接收輸入。
- **工廠方法**：`simplePopup`, `simpleWaiter`, `simpleWaiterTip` 等快速建立常用對話框。

### 11.3 主要 UI 元件

| 元件 | 特色 |
|------|------|
| `Button` | 點擊回調，可禁用 |
| `List` | 可選清單，支援鍵盤操作，高亮當前行 |
| `ListColumns` | 多欄清單，可調整欄寬 |
| `TreeList` | 可展開/收合的樹狀清單 |
| `Textzone` | 富文本顯示（支援顏色 tag），可滾動 |
| `TextzoneList` | 多段文字 + 條目選擇 |
| `Textbox` | 單行輸入框，支援 Unicode |
| `Numberbox` | 數字輸入框 |
| `Slider` / `NumberSlider` | 滑桿 |
| `Checkbox` | 勾選框 |
| `Dropdown` | 下拉選單 |
| `Tabs` | 標籤頁切換 |
| `ImageList` | 圖像格狀選擇（技能、物品圖示列表） |
| `EquipDoll` | 人形裝備圖（點擊對應部位） |
| `EntityDisplay` | 顯示實體的圖像與描述 |
| `Waitbar` / `Waiter` | 進度條（loading 等） |
| `WebView` | 嵌入網頁（CEF3/Awesomium） |
| `UIContainer` / `UIGroup` | 容器/群組佈局 |
| `SurfaceZone` | 自由繪製區域（GL surface） |

### 11.4 輸入整合

每個 Dialog 持有獨立的 `KeyBind` 和 `Mouse` 實例，`setCurrent()` 後接收事件。

---
