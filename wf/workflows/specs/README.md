# specs — 設計方案入口

一個 idea/roadmap 項認真討論後產出的設計方案：目標、架構、資料流、權衡、取捨。

規劃階梯：

```text
idea → roadmap → spec → plan → feature-dev
```

## 規則

- 開始前寫 `Done when: <設計問題被回答，取捨/不做範圍清楚，可進 plan>`。
- 本夾 `*.md` = 各功能的設計方案。
- 建議命名：`<feature>-design.md`。
- 設計涉及 code 結構時參考 [common/conventions](../common/conventions.md)。
- 落地或被取代後移到 `archive/`。

## 現役設計方案

| 設計方案 | 討論日期 | 對應 idea/roadmap | 狀態 |
|----------|----------|-------------------|------|
| [生長式天賦 organic-talents](organic-talents-design.md) | 2026-08-01 | （直接由使用者構想起） | 可行性已驗，待使用者決定 §6 四題後進 plan |
| [歐拉麗完全版 orario-complete](orario-complete-design.md) | 2026-08-01 | 前身 [PLAN-camp-and-isekai §B](../plans/PLAN-camp-and-isekai.md) | 可行性已驗，**卡在 §4「玩家是誰」** |
| [生產職業 crafting-professions](crafting-professions-design.md) | 2026-08-01 | （直接由使用者構想起） | 可行性已驗，待使用者決定 §8 四題後進 plan |
| [型月魔術體系 fate-magecraft](fate-magecraft-design.md) | 2026-08-03 | （直接由使用者構想起） | **可行性未驗**（寫於無 `vendor/` 的辦公室機），§11 複驗清單待跑 |
| [埃瑞布斯 erebus](erebus/README.md) | 2026-08-06 | （使用者指定取材 Fall from Heaven） | **初步規劃，可行性未驗**（同上）。自成新世界地圖；等拆包 FFH 本體後修正 |

> 前三份底層共用同一套機制（見 orario spec §8）。**已於 2026-08-03 拍板方案 3：
> 歐拉麗當試驗場**——先做 Falna，跑通再抽通用框架。
>
> fate-magecraft 是那個框架的**第二個使用者**（見該文件 §15），
> 位置在歐拉麗隔壁（Eyal 大地圖 (28,18)，待複驗）。
> 建議不在 Falna v0.7 之前開工。

## 何時不用

- 小功能已清楚可直接做，走 feature-dev。
- 已決定設計，只缺實作步驟，走 plans。
- 還只是靈感，走 idea 或 roadmap。
