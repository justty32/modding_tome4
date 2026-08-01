-- 弗雷之族（Freyr's Ætt）—— 古弗薩克文 24 符文的第一族，主題是創生、財富與烈焰。
--
-- 歷史依據：Elder Futhark 分為三個 ættir，各 8 符文。第一族以 Fehu（家畜／財富）起首，
-- 傳統上被視為「顯化」之族——把潛能化為實體。這裡取其四：
--   ᚠ Fehu    財富、流動的資產     → 資源轉換
--   ᚦ Thurisaz 巨人、荊棘、破壞    → 穿刺攻擊
--   ᚲ Kenaz   火炬、知識之火       → 火焰與照明
--   ᚹ Wunjo   喜悅、和諧、圓滿     → 持續增益
--
-- 天賦一律明確指定 short_name（中文 name 會生成非 ASCII 的 id）。

newTalentType {
    type = "spell/futhark-freyr",
    name = "弗雷之族",
    description = "古弗薩克文的第一族。顯化之符，將潛藏的力量化為烈焰與實體。",
    generic = false,
    allow_random = true,
}
