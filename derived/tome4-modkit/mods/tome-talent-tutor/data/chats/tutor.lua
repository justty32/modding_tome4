-- 技藝導師的對話。
--
-- 由 can_talk = "talent-tutor+tutor" 觸發：engine/Chat.lua:83-90 看到 "<addon>+<file>"
-- 就去找 /data-talent-tutor/chats/tutor.lua。不需要 overload，不會跟任何 addon 撞檔。
--
-- 對話檔的執行環境有 `newChat`，且 metatable 的 __index 指向 _G（engine/Chat.lua:94-102），
-- 所以 require / game / table 這些都能直接用。
--
-- 這個檔案在**每次開啟對話時重新執行**，所以清單是動態的：
-- 其他 addon 新增的技能樹會自動出現，不必維護一份寫死的名單。

local tutor_lib = require "data.lib.tutor_lib"
local by_cat = tutor_lib.buildByCat()

-- CAT_ORDER 之外若還有大類（別的 addon 帶來的），附加在後面，不要漏掉
local cats = {}
local seen = {}
for _, c in ipairs(tutor_lib.CAT_ORDER) do
    if by_cat[c] then cats[#cats + 1] = c; seen[c] = true end
end
for c in pairs(by_cat) do
    if not seen[c] then cats[#cats + 1] = c end
end

-- ---------------------------------------------------------------------------
-- 入口
-- ---------------------------------------------------------------------------
local welcome_answers = {}
for _, cat in ipairs(cats) do
    local list = by_cat[cat]
    local label = tutor_lib.CAT_NAME[cat] or cat
    welcome_answers[#welcome_answers + 1] = {
        ("#LIGHT_GREEN#%s#LAST#（%d 棵） >"):format(label, #list),
        jump = tutor_lib.cat_chat_id(cat, 1),
    }
end
welcome_answers[#welcome_answers + 1] = { "#ORANGE#我要一次學會全部。#LAST#", jump = "all_confirm" }
welcome_answers[#welcome_answers + 1] = { "#RED#< 改天再來。#LAST#" }

newChat {
    id = "welcome",
    text = [[知識不該被囤積。

我把畢生所學都攤在這裡，你想拿什麼就拿什麼——不收分文。
只是記住：學會一棵樹，不代表你走得完它。

你想從哪一類開始？]],
    answers = welcome_answers,
}

-- ---------------------------------------------------------------------------
-- 每個大類一組分頁對話
-- ---------------------------------------------------------------------------
for _, cat in ipairs(cats) do
    local list = by_cat[cat]
    local label = tutor_lib.CAT_NAME[cat] or cat
    local pages = math.ceil(#list / tutor_lib.PER_PAGE)

    for page = 1, pages do
        local answers = {}
        local first = (page - 1) * tutor_lib.PER_PAGE + 1
        local last = math.min(page * tutor_lib.PER_PAGE, #list)

        answers[#answers + 1] = { "#LIGHT_BLUE#< 回到分類。#LAST#", jump = "welcome" }
        if page < pages then
            answers[#answers + 1] = { ("#WHITE#下一頁（%d/%d） >#LAST#"):format(page + 1, pages),
                jump = tutor_lib.cat_chat_id(cat, page + 1) }
        end
        if page > 1 then
            answers[#answers + 1] = { ("#WHITE#< 上一頁（%d/%d）#LAST#"):format(page - 1, pages),
                jump = tutor_lib.cat_chat_id(cat, page - 1) }
        end
        answers[#answers + 1] = {
            ("#ORANGE#把「%s」全部教給我。#LAST#"):format(label),
            action = function(npc, player)
                local n = 0
                for _, e in ipairs(list) do
                    if tutor_lib.grantable(player, e.id) then tutor_lib.grant(player, e.id); n = n + 1 end
                end
                game.logPlayer(player, "#LIGHT_GREEN#導師傾囊相授：%s 共 %d 棵技能樹。#LAST#", label, n)
            end,
            cond = function(npc, player)
                for _, e in ipairs(list) do if tutor_lib.grantable(player, e.id) then return true end end
                return false
            end,
            jump = tutor_lib.cat_chat_id(cat, page),
        }

        for i = first, last do
            local e = list[i]
            answers[#answers + 1] = {
                tutor_lib.tree_label(e),
                action = function(npc, player)
                    tutor_lib.grant(player, e.id)
                    game.logPlayer(player, "#LIGHT_GREEN#導師向你揭示了「%s」的奧秘。#LAST#", e.name)
                end,
                cond = function(npc, player) return tutor_lib.grantable(player, e.id) end,
                jump = tutor_lib.cat_chat_id(cat, page),
            }
        end

        newChat {
            id = tutor_lib.cat_chat_id(cat, page),
            text = ("#{bold}#%s#{normal}#（第 %d/%d 頁，共 %d 棵）\n\n已經學會的不會再列出來。"):
                format(label, page, pages, #list),
            answers = answers,
        }
    end
end

-- ---------------------------------------------------------------------------
-- 一次全部
-- ---------------------------------------------------------------------------
newChat {
    id = "all_confirm",
    text = [[全部？

我可以。但你會在升級畫面看到一片你永遠點不完的樹林，
而且再也回不去那種「不知道下一步該學什麼」的樂趣了。

還要嗎？]],
    answers = {
        {
            "#ORANGE#要。全部給我。#LAST#",
            action = function(npc, player)
                local n = 0
                for _, list in pairs(by_cat) do
                    for _, e in ipairs(list) do
                        if tutor_lib.grantable(player, e.id) then tutor_lib.grant(player, e.id); n = n + 1 end
                    end
                end
                game.logPlayer(player, "#LIGHT_GREEN#導師傾囊相授：共 %d 棵技能樹。#LAST#", n)
            end,
            jump = "welcome",
        },
        { "#LIGHT_BLUE#< 還是一類一類來吧。#LAST#", jump = "welcome" },
    },
}

-- ⚠️ 對話檔的**回傳值**就是起始 chat 的 id（engine/Chat.lua:70 的
-- `if setid then self.default_id = f() end`）。漏了這行，default_id 會是 nil，
-- 一跟 NPC 說話就 `dialogs/Chat.lua:134: attempt to index a nil value`。
-- 原版 98 個對話檔裡有 92 個是這樣收尾的。
return "welcome"
