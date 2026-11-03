"""시연용 공유 화면: 공유 링크와 QR 코드를 크게 보여주는 HTML 한 장을 만들어요.

python share_page.py https://xxx.trycloudflare.com 저장할경로.html
프로젝터에 띄워 두면 학생들이 핸드폰 카메라로 QR을 찍어 바로 들어올 수 있어요.
"""
import html
import sys

import qrcode
import qrcode.image.svg

url, out = sys.argv[1], sys.argv[2]
svg = qrcode.make(url, image_factory=qrcode.image.svg.SvgPathImage, box_size=10, border=2).to_string(encoding="unicode")
u = html.escape(url)
open(out, "w", encoding="utf-8").write(f"""<!doctype html>
<html lang="ko"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>둘 시연 · 핸드폰으로 들어오세요</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">
<style>
  body {{ margin: 0; min-height: 100vh; display: grid; place-items: center; font-family: "Pretendard Variable", system-ui, sans-serif; color: #1F2147;
         background: radial-gradient(circle at 20% 15%, #FCE3EE, transparent 45%), radial-gradient(circle at 85% 80%, #DCDBFF, transparent 50%), #F4F3FF; }}
  main {{ display: flex; gap: 56px; align-items: center; padding: 40px; flex-wrap: wrap; justify-content: center; }}
  .qr {{ background: #FFFFFF; padding: 22px; border-radius: 32px; box-shadow: 0 20px 60px rgba(91, 95, 224, .25); }}
  .qr svg {{ width: min(62vh, 80vw); height: auto; display: block; }}
  h1 {{ font-size: 64px; margin: 0; color: #5B5FE0; letter-spacing: -.02em; }}
  p {{ font-size: 26px; margin: 12px 0; line-height: 1.5; }}
  .url {{ font-size: 22px; font-weight: 700; color: #A3214F; background: #FFE3EC; padding: 10px 16px; border-radius: 14px; word-break: break-all; }}
  small {{ display: block; font-size: 18px; color: #64678A; margin-top: 18px; }}
</style></head>
<body><main>
  <div class="qr">{svg}</div>
  <div style="max-width:560px">
    <h1>둘 · dul ♥</h1>
    <p>핸드폰 카메라로 QR을 찍어<br>바로 써 보세요</p>
    <p class="url">{u}</p>
    <small>가상 회원 500명 시연판이에요. 처음 화면에서 아무 회원이나 눌러 로그인하세요.<br>AI 답은 한 명씩 차례로 만들어서 10~30초 걸려요.</small>
  </div>
</main></body></html>
""")
print(out)
