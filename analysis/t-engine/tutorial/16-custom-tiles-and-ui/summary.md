**地塊貼圖**
- `image` 欄位 → `/data/gfx/` 相對路徑的 PNG
- `add_mos` → 在同 z 層疊加裝飾圖
- `add_displays` → 在不同 z 層新增子實體（牆頂蓋用 z=18, display_y=-1）
- `nice_tiler = {method="replace", base={"PREFIX", 100, 1, N}}` → 隨機地板紋路
- `nice_tiler = {method="wall3d", inner=..., north=..., south=...}` → 自動牆壁方向偵測

**UI 主題**
- PNG 放在 `/data/gfx/THEMENAME-ui/` 資料夾
- 定義檔設定 `frame_ox`、`frame_shadow` 等參數
- `UIBase:loadUIDefinitions(file)` → 載入定義
- `UIBase:changeDefault("mytheme")` → 全域切換
- `Dialog.new(title, w, h, nil, nil, "mytheme")` → 單一對話框使用特定主題
- 缺少的 PNG 自動 fallback 到 `dark-ui/`，可以只提供想修改的部分
