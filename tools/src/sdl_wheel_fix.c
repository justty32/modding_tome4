/* sdl_wheel_fix.c — LD_PRELOAD 補丁：把 X11 的 button 4-7 改寫成 SDL 滾輪事件。
 *
 * 為什麼需要它
 * ------------
 * ToME 1.7.6 自帶 SDL 2.0.3。那版的 src/video/x11/SDL_x11events.c 這樣判滾輪：
 *
 *     static SDL_bool X11_IsWheelEvent(Display *display, XEvent *event, int *ticks) {
 *         XEvent relevent;
 *         if (X11_XPending(display)) {                     // 佇列裡「當下」得有東西
 *             if (X11_XCheckIfEvent(display, &relevent,
 *                     X11_IsWheelCheckIfEvent, (XPointer) event)) {   // 且得是配對的 release
 *                 if (event->xbutton.button == Button4) *ticks = 1;
 *                 else if (event->xbutton.button == Button5) *ticks = -1;
 *                 return SDL_TRUE;
 *             }
 *         }
 *         return SDL_FALSE;                                // 找不到 → 當普通按鍵
 *     }
 *
 * 只有在 ButtonPress 進來的那一瞬間、配對的 ButtonRelease 已經躺在 X 事件佇列裡，
 * 才會發出 SDL_MOUSEWHEEL；否則退化成 SDL_MOUSEBUTTONDOWN(button=4/5)，Lua 端收到
 * "button4"/"button5"，而沒有任何 UI 在監聽那個名字 → 滾輪全死。在 XWayland 上這個
 * 競態幾乎必然觸發。SDL 2.0.4 起改成無條件認 button 4-7。
 *
 * 為什麼不直接換掉 SDL
 * --------------------
 * 換 SDL 2.32 實測**滾輪會好但畫面全白**（RTX 5060 Ti / NVIDIA 610.43.03、全螢幕；
 * 遊戲邏輯照跑，只有 GL 輸出壞）——2.0.3 到 2.32 跨了十年的 context/FBO 行為差異。
 * 本補丁只攔事件佇列的取出口，**SDL 2.0.3 與整條渲染路徑一個字節都沒動**，
 * 所以不可能影響畫面。詳見 docs/knowledge/real-machine.md §5。
 *
 * 攔得到的理由：t-engine64 是以未定義符號 SDL_PollEvent / SDL_WaitEvent 連進去的
 * （`nm -D --undefined-only t-engine64` 可見），LD_PRELOAD 的物件在全域符號搜尋順序上
 * 早於那份改名的 libSDL2-usemeyousilly-2.0.so.0，所以我們的定義會勝出。
 *
 * 已知取捨：button 4-7 的「按下」被轉成滾輪、「放開」被吞掉，所以任何綁在
 * button4-7 上的按鍵繫結會失效。那些繫結本來就沒用（滾輪壞的時候沒人綁得起來）。
 *
 * 編譯：tools/run.sh --build-wheel-fix
 * 用法：LD_PRELOAD=<這個.so> ./t-engine64 …   （tools/run.sh 會自動帶上）
 *
 * 結構相容性：以系統 SDL2 標頭編譯，但只寫入 SDL 2.0.3 也有的前綴欄位。
 * 實測 offsetof 完全一致：sizeof(SDL_Event)=56、wheel{type=0,timestamp=4,windowID=8,
 * which=12,x=16,y=20}、button{…,button=16,state=17}。2.0.18 才加的 wheel.direction
 * 我們不寫，引擎（對著 2.0.3 標頭編的）也不會讀。
 */

#define _GNU_SOURCE
#include <SDL2/SDL.h>
#include <dlfcn.h>
#include <string.h>

static int (*real_poll)(SDL_Event *);
static int (*real_wait)(SDL_Event *);

/* 回傳 1 = 這個事件可以交給呼叫者；0 = 丟掉，去拿下一個。 */
static int rewrite(SDL_Event *e)
{
	Uint8 b;

	if (e->type != SDL_MOUSEBUTTONDOWN && e->type != SDL_MOUSEBUTTONUP) return 1;

	b = e->button.button;
	if (b < 4 || b > 7) return 1;

	/* 放開事件沒有對應的滾輪語意，吞掉，否則引擎會多收一次 buttonN。 */
	if (e->type == SDL_MOUSEBUTTONUP) return 0;

	{
		Uint32 timestamp = e->button.timestamp;
		Uint32 windowID  = e->button.windowID;
		Uint32 which     = e->button.which;

		memset(e, 0, sizeof(*e));
		e->wheel.type      = SDL_MOUSEWHEEL;
		e->wheel.timestamp = timestamp;
		e->wheel.windowID  = windowID;
		e->wheel.which     = which;
		e->wheel.x = (b == 6) ?  1 : (b == 7) ? -1 : 0;   /* 橫向：6 右、7 左 */
		e->wheel.y = (b == 4) ?  1 : (b == 5) ? -1 : 0;   /* 縱向：4 上、5 下 */
	}
	return 1;
}

int SDL_PollEvent(SDL_Event *e)
{
	if (!real_poll) real_poll = (int (*)(SDL_Event *)) dlsym(RTLD_NEXT, "SDL_PollEvent");
	if (!real_poll) return 0;

	/* SDL_PollEvent(NULL) 是合法的「只抽水、只回報有沒有事件」，不能解參考。 */
	if (!e) return real_poll(NULL);

	for (;;) {
		int r = real_poll(e);
		if (r <= 0) return r;
		if (rewrite(e)) return r;
	}
}

int SDL_WaitEvent(SDL_Event *e)
{
	if (!real_wait) real_wait = (int (*)(SDL_Event *)) dlsym(RTLD_NEXT, "SDL_WaitEvent");
	if (!real_wait) return 0;

	if (!e) return real_wait(NULL);

	for (;;) {
		int r = real_wait(e);
		if (r <= 0) return r;
		if (rewrite(e)) return r;
	}
}
