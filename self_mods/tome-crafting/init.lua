long_name = "Crafting"
short_name = "crafting"
for_module = "tome"
version = { 1, 7, 6 }
addon_version = { 0, 1, 0 }
weight = 100
author = { "tome4-modkit" }
homepage = "-"
description = [[工匠之藝（Crafting）——附魔與煉製，全職業通用。

建角自動學會兩個天賦：
- 附魔：把背包裡任一顆寶石鑲入一件武器或防具，永久獲得該寶石的效果
  （沿用基礎遊戲煉金師 Imbue Item 的機制：applyEgo + gem.imbue_powers）。
- 煉製：消耗背包裡 3 顆寶石，煉出 1 顆隨機寶石（材料→產物的配方範例）。

蒸氣工匠(Steamtech)DLC 的機械製作不在本 addon；此處全部基於基礎遊戲既有機制。]]
tags = { "crafting", "enchant" }

data = true   -- talents/ → 在 hooks 的 ToME:load 手動 loadDefinition
hooks = true  -- 載入天賦 + ToME:birthDone 教給玩家 + selfcheck
