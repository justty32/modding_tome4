**目標形狀描述**：
```lua
{type="bolt", range=10}              -- 直線單目標
{type="beam", range=10}              -- 直線貫穿
{type="ball", range=5, radius=3}     -- 球形 AOE
{type="cone", range=8, cone_angle=45} -- 扇形
{type="hit"}                          -- 直接命中
```

**目標樣式**
- `lock`（掃描模式）：鍵盤掃描目標
- `free`（自由模式）：滑鼠指定位置
- `immediate`（即時模式）：方向鍵選擇

**渲染**
- 彩色 overlay 即時顯示射程/形狀（紅/藍/綠/黃 tile 顏色）
- 可選 FBO 渲染做半透明 overlay 效果
- 箭頭指示器顯示來源→目標方向

---
