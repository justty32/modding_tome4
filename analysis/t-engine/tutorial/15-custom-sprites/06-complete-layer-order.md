`updateModdableTile()` 依序建立 `add_mos` 列表，圖層由下而上：

```
[self.image]  ← 陰影底圖（base_shadow_01.png），作為主 image 欄位，不在 add_mos 中

add_mos[1]  ← 尾巴（moddable_tile_tail）
add_mos[2]  ← 背後飾物（moddable_tile_behinds，列表）
add_mos[3]  ← 披風後擺（CLOAK.moddable_tile:format("behind")）
add_mos[4]  ← Shader 光環（shader_auras）
add_mos[5]  ← 身體基底（moddable_tile_base 或 base_01.png）
             ← Hook: Actor:updateModdableTile:skin
add_mos[6]  ← 刺青（moddable_tile_tatoo）
add_mos[7]  ← 主手武器後層（MAINHAND.moddable_tile_back:format("right")）
add_mos[8]  ← 副手武器後層（OFFHAND.moddable_tile_back:format("left")）
add_mos[9]  ← 靴子（FEET.moddable_tile）
add_mos[10] ← 下身護甲/內衣（BODY.moddable_tile2 或 lower_body_01.png）
add_mos[11] ← 上身護甲/內衣（BODY.moddable_tile 或 upper_body_01.png）
add_mos[12] ← 披風肩部（CLOAK.moddable_tile:format("shoulder")）
add_mos[13] ← 披風兜帽（CLOAK.moddable_tile:format("hood")，需開啟設定）
add_mos[14] ← 頭髮（moddable_tile_hair）
add_mos[15] ← 面部特徵（moddable_tile_facial_features，列表）
add_mos[16] ← 頭盔（HEAD.moddable_tile）
             ← Hook: Actor:updateModdableTile:middle
add_mos[17] ← 角/冠（moddable_tile_horn）
add_mos[18] ← 手套（HANDS.moddable_tile）
add_mos[19] ← 箭袋（QUIVER.moddable_tile）
add_mos[20] ← 主手武器正面（MAINHAND.moddable_tile:format("right") + ornament）
add_mos[21] ← 副手武器正面（OFFHAND.moddable_tile:format("left") + ornament）
             ← Hook: Actor:updateModdableTile:front
```

---
