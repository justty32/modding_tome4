### 1.4 商店定義 (stores/)

**`basic.lua`**（22KB）：完整商店/供應商系統。

#### 商店類型

| 商店名稱 | 商品類型 |
|---------|---------|
| Heavy Armor Smith | 重甲、板甲 |
| Light Armor Tanner | 輕甲、布甲 |
| Weapon Smith | 各類武器 |
| Potion Alchemist | 藥水、消耗品 |
| Scroll Vendor | 卷軸、魔棒 |
| Jewelry Vendor | 戒指、項鍊 |
| Gem Vendor | 寶石（材料）|
| General Loot | 混合物品 |
| Faction Merchant | 陣營限定物品 |

#### 商店配置

```lua
newEntity{
    name = _t"heavy armor store",
    store_filter = "tome_store",
    purse = 200,          -- 商人金幣（影響最大收購價）
    nb_fill = 10,          -- 庫存格數
    filters = {            -- 允許的物品類型篩選
        {type="armor", subtype="massive"},
        {type="armor", subtype="heavy"},
        {type="armor", subtype="shield"},
    },
    empty_before_restock = true,   -- 補貨前清空
    restock_on_zone_change = true, -- 換地區時補貨
}
```

**定價規則**：
- 基礎買入價 = 物品原價 × 1.0
- 賣出價：寶石為 40%，其他物品為 5%
- 陣營友好度加成（Angolwen 等特殊商人有折扣）

---

