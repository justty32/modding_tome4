```lua
-- 描述投射形狀
{type = "bolt", range = 10}              -- 直線單目標
{type = "beam", range = 10}              -- 直線貫穿
{type = "ball", range = 5, radius = 3}  -- 球形 AOE
{type = "cone", range = 8, cone_angle = 45}  -- 扇形
{type = "hit"}                           -- 直接命中
```

- `Target:getType(t)` 解析 type 描述，回傳包含 `block_path`、`block_radius` 等函數的完整 typ table。
- 目標系統也負責 UI 層的目標選擇顯示（紅色游標、射程顯示）。
- `self.target = {x, y, entity}` 追蹤當前目標，entity 為弱引用（目標死後自動清空）。
- FBO 渲染模式下可做半透明 overlay 效果。

---
