| 錯誤現象 | 原因 | 解法 |
|---------|------|------|
| 粒子完全不顯示 | 粒子 Lua 語法錯誤，或貼圖路徑找不到 | 查看 Cheat Console 錯誤訊息；確認貼圖路徑和 PNG 存在 |
| 粒子顯示但立即消失 | `life` 太小（< 5）或 `av` 太大（每幀透明度扣太多） | 增大 `life`；減小 `av` 的絕對值 |
| 光環粒子不跟隨角色移動 | 未設定 `can_shift = true` | 在粒子 Lua 頂層加 `can_shift = true` |
| 自訂貼圖顯示為方形 | PNG 背景不透明 | 確認 PNG 背景完全透明（Alpha = 0） |
| 自訂貼圖顏色不對 | 貼圖不是全白，Lua 顏色乘法不符合預期 | 把貼圖畫成純白，讓 r/g/b 參數控制顏色 |
| 爆炸粒子只出現在格左上角 | `particleEmitter` 座標傳的是格座標（整數）是正確的，問題可能在粒子 Lua 中 x/y 偏移計算 | 確認 `sradius` 是用像素計算的：`(radius + 0.5) * (tile_w + tile_h) / 2` |
| SUSTAINED 技能開啟後光環立即消失 | `activate` 沒有 `return {...}` | 確認 `activate` 最後有 `return {particle=particle, ...}` |
| `addParticles` 後移動時粒子抖動 | `can_shift = true` 但 `shift` 被呼叫時更新不及時 | 這是 TE4 已知行為，通常在高移動速度時才明顯，一般可接受 |

---
