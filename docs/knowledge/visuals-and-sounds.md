# 引擎事實：視覺特效、音效、圖示

> 路徑代號 `E` / `M` / `R` 見 [README.md](README.md)。
> `G = ~/.steam/steam/steamapps/common/TalesMajEyal/game/modules`

本文件已依主題拆分為三部分，位於 `visuals-and-sounds-parts/` 下：

1. **[01-effects-api-and-pitfalls.md](visuals-and-sounds-parts/01-effects-api-and-pitfalls.md)**：三類資產分工原則、三種特效三套 API（彈道／範圍／光束／命中／光環／音效）、`Particles.new()` 參數陷阱、`arcane_power` 永久殘留、飛行粒子誤當命中粒子、殘留驗證手法（§0-1）。
2. **[02-asset-paths-and-overload.md](visuals-and-sounds-parts/02-asset-paths-and-overload.md)**：現成粒子／音效／圖示名字怎麼列、圖片路徑兩段查找、自製圖片 `overload/` 唯一解、`addon+file` 語法、物品貼圖的 tileset 變體（§2-4b）。
3. **[03-class-icons-sound-particles-and-fonts.md](visuals-and-sounds-parts/03-class-icons-sound-particles-and-fonts.md)**：職業圖示命名與時序陷阱、自製音效、自製粒子與紋理放哪、各類資產路徑寫錯的症狀總表、字型限制（§5-9）。
