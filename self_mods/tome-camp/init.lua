long_name = "Homestead Camp"
short_name = "camp"
for_module = "tome"
version = { 1, 7, 6 }
addon_version = { 0, 1, 0 }
weight = 100
author = { "tome4-modkit" }
homepage = "-"
description = [[營地系統（Homestead Camp）——一個持久的私人據點。

建角自動學會「返回營地」天賦：
- 在野外用：傳送到你的私人營地，並在營火旁完全恢復（休息）。
- 在營地用：收拾行囊，回到你先前所在之處。
營地是 persistent zone，狀態持久——你留下的東西下次還在。

（進階：把入口貼到大地圖、建造/農作系統，見 PLAN-camp-and-isekai.md。）]]
tags = { "camp", "base", "zone" }

data = true   -- talents/ 手動 loadDefinition；zones/ 與 maps/ 由 changeLevel 惰性載入
hooks = true  -- 載入天賦 + ToME:birthDone 教給玩家 + selfcheck
