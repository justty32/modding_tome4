| 系統 | 位置 | 用途 |
|------|------|------|
| 精靈圖序列（`entity.anim`） | C 層 map object | 實體在地圖上逐幀播放 |
| 移動動畫（`setMoveAnim`） | C 層 map object | 滑動 / 攻擊搖晃 |
| `tween` 補間 | Lua thirdparty | 數值平滑過渡（UI 元素動畫） |
| `FlyingText` 飄字 | `engine.FlyingText` | 傷害數字、浮動提示文字 |
| `displayCallback` | C 層 map object | 實體每幀自訂渲染 |
| OpenGL 變換（glTranslate/Scale/Rotate） | `core.display.*` | 任意 2D 幾何動畫 |

---
