long_name = "AutoBirth (modkit test fixture)"
short_name = "autobirth"
for_module = "tome"
-- 必須讓 engine.version_nearly_same({1,7,6}, version) 為真，否則 addon 被靜默移除
-- （engine/Module.lua:390 → :595，全程沒有錯誤訊息）
version = { 1, 7, 6 }
addon_version = { 0, 1, 0 }
-- weight 給很大：superload 是層層包裹，weight 越大越晚套用＝越外層。
-- 本 addon 必須是最外層，才能在其他 addon 的 Birther 修改之後才決定要不要自動建角。
weight = 9000
author = { "tome4-modkit" }
homepage = "-"
description = [[**開發用測試夾具，不是給玩家的 addon。**

讓 agent 完全不碰滑鼠鍵盤就完成建角：superload `mod/dialogs/Birther.lua`，
在建角對話框註冊時讀取 `<home>/.t-engine/4.0/autobirth.lua` 的規格，
直接呼叫 setDescriptor + atEnd("created")，跳過整個 UI 流程。

沒有那個規格檔就完全不作用（一般玩家即使誤裝也只是多一個 no-op addon）。
規格檔由 `tools/playtest.sh start --birth ...` 產生，只寫進 scratch home。

為什麼需要它：建角對話框會吃掉所有按鍵，`playtest.sh lua`（ctrl+L）在那個畫面
進不去，所以在建角完成前沒有任何程式化操作的入口——這是整條無頭鏈唯一的斷點。]]
tags = { "dev", "testing" }

superload = true  -- 只用 superload 疊 mod/dialogs/Birther.lua，不覆寫任何原版檔案。
