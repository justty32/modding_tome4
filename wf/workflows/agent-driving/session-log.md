# agent-driving — session log

只列 open/in-flight。完成的濃縮到 git log 或 [experiments.md](experiments.md)。

## Open

- **第三次驅動還沒做**：`tome-witchwood` 三 agent 平行產出後，尚未實機 playtest。
  下次可順便測一個沒測過的模式：**讓 agent 自己跑 playtest 並用 probe 驗證遊戲邏輯**
  （前兩次都只到 verify，playtest 是我自己跑的）。

- **共用檔擴充點還沒實作**。這次契約禁止 agent 改 `hooks/load.lua`，
  造成 B「回報 → 我代改」的往返。下個 addon 試 `hooks/parts/<agent>.lua` + 迴圈載入。

- **`agy` 的文本生成沒測過**。兩次實驗都只用到它的圖像生成。
  劇情長文本、addon description 這類要不要交給它，未知。

## 已驗證可行（不必再試）

- `pi -p --session-id <id>` 多步驟驅動、`printf '%s' | pi` 注入
- 三 agent 平行 + `TOME_PLAYTEST_STATE` 隔離
- `agy` 圖像生成 + 洋紅 key color 去背
- `agy` **沒有**音訊生成能力
