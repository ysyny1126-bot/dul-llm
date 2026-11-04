import asyncio, sys, subprocess, os, glob, imageio_ffmpeg
from playwright.async_api import async_playwright
S = sys.argv[1]
async def main():
    srv = subprocess.Popen([sys.executable, "-m", "http.server", "8765", "-d", S + "/stage3"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    await asyncio.sleep(1)
    try:
        async with async_playwright() as p:
            b = await p.chromium.launch()
            ctx = await b.new_context(viewport={"width": 1920, "height": 1080}, record_video_dir=S + "/rawvid3", record_video_size={"width": 1920, "height": 1080})
            pg = await ctx.new_page()
            pg.on("console", lambda m: print("console:", m.text) if ("ERR" in m.text or "no el" in m.text) else None)
            pg.on("pageerror", lambda e: print("pageerror:", e))
            await pg.goto("http://localhost:8765/promo.html")
            await pg.wait_for_function("window.DONE === true", timeout=180000, polling=500)
            vp = await pg.video.path()
            await ctx.close(); await b.close()
            print("raw", vp)
            ff = imageio_ffmpeg.get_ffmpeg_exe()
            out = S + "/dul_promo.mp4"
            subprocess.run([ff, "-y", "-loglevel", "error", "-ss", "1.2", "-i", vp, "-c:v", "libx264", "-preset", "slow", "-crf", "18", "-pix_fmt", "yuv420p", "-r", "30", "-movflags", "+faststart", out], check=True)
            print("out", out, os.path.getsize(out))
    finally:
        srv.terminate()
asyncio.run(main())
