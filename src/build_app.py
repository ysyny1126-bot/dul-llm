"""앱 페이지 생성: 엔진 + 화면 + 데이터

python3 build_app.py                    시연용 (가상 회원 500명 포함) → gyeol_app.html
python3 build_app.py --real             실제 서비스용 (가상 회원 없음) → dul_real.html
"""
import json
from matching import PURPOSE_WEIGHTS, POP_FREE, POP_DAMP, load, run, age, WEIGHTS, PENALTY, DIST_PENALTY_PER_5KM, FAV_BONUS, RARITY_CAP, RELATED, CATEGORIES, CATEGORY_SIM, LEVEL_MULT, MAX_TOP_LEVEL, AXES, TAG_VEC, OVERLAP_SHARE, COS_FLOOR

import sys
from regions import REGIONS
REAL = "--real" in sys.argv
args = [a for a in sys.argv[1:] if not a.startswith("--")]
SRC = args[0] if args else "profiles_500.json"
people = [] if REAL else load(SRC)
results = {} if REAL else run(people)[0]
profiles = []
for p in people:
    profiles.append({
        "id": str(p["id"]), "login_id": f"user{p['id']:03d}", "nickname": p["nickname"], "gender": p["gender"],
        "birth_date": p["birth_date"], "age": age(p),
        "region": p["location"]["region"], "lat": p["location"]["lat"], "lng": p["location"]["lng"],
        "has_photo": True, "searchable": p.get("searchable", p["id"] not in (3, 12, 18)), "job": p["job"], "height": p["height"], "bio": p["bio"],
        "interests": p["interests"], "favorite_tag": p["favorite_tag"], "interest_level": p["interest_level"], "mbti": p["mbti"],
        "smoking": p["smoking"], "drinking": p["drinking"], "religion": p["religion"],
        "chronotype": p["chronotype"], "contact_style": p["contact_style"], "weekend": p["weekend"],
        "pet": p["pet"], "purpose": p["purpose"], "marriage_view": p["marriage_view"],
        "spending": p["spending"], "appearance": p["appearance"], "preference": p["preference"],
    })
cfg = {"weights": WEIGHTS, "penalty": PENALTY, "dist_penalty": DIST_PENALTY_PER_5KM,
       "fav_bonus": FAV_BONUS, "rarity_cap": RARITY_CAP, "related": RELATED,
       "categories": CATEGORIES, "category_sim": CATEGORY_SIM,
       "level_mult": {str(k): v for k, v in LEVEL_MULT.items()}, "max_top_level": MAX_TOP_LEVEL,
       "axes": AXES, "tag_vec": TAG_VEC, "overlap_share": OVERLAP_SHARE, "cos_floor": COS_FLOOR, "auto_top_n": 3,
       "purpose_weights": PURPOSE_WEIGHTS, "pop_free": POP_FREE, "pop_damp": POP_DAMP,
       "regions": [[r[0], r[1], r[2]] for r in REGIONS]}
# 시연판 로그인 화면에 보여줄 지방 회원: 시·도마다 추천이 가장 많이 나오는 사람 (빈 화면으로 시연하지 않게)
showcase = []
for city in ["부산", "대구", "광주", "제주"]:
    cand = [p for p in people if p["location"]["region"].startswith(city)]
    if cand:
        showcase.append(str(max(cand, key=lambda p: len(results.get(p["id"], {}).get("recommendations", [])))["id"]))
# 대화 데이터: 시연판 가상 회원 답장용 (AI 코치 예시는 서버만 쓰니 빼고)
dlg = {k: v for k, v in json.load(open("dialogues.json", encoding="utf-8")).items() if k not in ("coach_examples", "_설명")}
data = {"profiles": profiles, "cfg": cfg, "real": REAL, "showcase": showcase, "dlg": dlg}
if not REAL:
    json.dump({"data": data, "py": results}, open("app_data.json", "w", encoding="utf-8"), ensure_ascii=False)

import os
if os.path.exists("app_template.html"):
    tpl = open("app_template.html", encoding="utf-8").read()
    eng = open("app_engine.js", encoding="utf-8").read()
    out = tpl.replace("/*__ENGINE__*/", eng).replace("/*__DATA__*/null", json.dumps(data, ensure_ascii=False))
    name = "dul_real.html" if REAL else "gyeol_app.html"
    open(name, "w", encoding="utf-8").write(out)
    print("built", name, len(out))
