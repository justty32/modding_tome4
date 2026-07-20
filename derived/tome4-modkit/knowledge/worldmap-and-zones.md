# 大地圖、zone、與新增 campaign

> 目標版本 **ToME 1.7.6**。每一條都在原始碼複驗過並附行號。路徑代號見 [README.md](README.md)。
> 實作範例：`mods/tome-runeisles/`（新大地圖 + 城鎮 + 兩個地城 + 主線）。

本文件已拆分為三部分，各自獨立成檔：

1. **[01-basics.md](worldmap-parts/01-basics.md)**：大地圖本質、地圖檔格式、addon zone 載入機制（§1-3）。
2. **[02-adding-to-eyal.md](worldmap-parts/02-adding-to-eyal.md)**：往 Eyal 加東西、第二大地圖 wild_x/y bug、zone.lua 必填欄位（§4-6）。
3. **[03-decoration-and-campaign.md](worldmap-parts/03-decoration-and-campaign.md)**：裝飾層、GRASS 陷阱、入口格、campaign、Static 生成失敗、change_level 地磚（§7-10 + ★）。
