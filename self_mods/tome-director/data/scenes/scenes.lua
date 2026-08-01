-- 場景索引。新增場景就在這裡多一行 dofile。
--
-- ⚠️ 不能用 require("data.scenes.demo")：addon 的 data/ 掛在私有的 /data-director/，
--    完全不在 package.path 上（E/Module.lua:498-503，grep package.path engine/ 零命中），
--    require 一定失敗。私有掛載點只能用絕對 VFS 路徑 dofile。
--    見 docs/knowledge/addon-loading.md §0。

dofile("/data-director/scenes/demo.lua")
dofile("/data-director/scenes/selftest.lua")
