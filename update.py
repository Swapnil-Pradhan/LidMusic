import sys, json, urllib.request, ssl, os, tempfile, zipfile
from datetime import datetime

def safe_extract(z, path):
    for member in z.namelist():
        if member.startswith("__MACOSX") or not member.strip():
            continue
        norm = os.path.normpath(member)
        if norm.startswith(("..", "/", "\\")):
            continue
        dest = os.path.join(path, norm)
        parent = os.path.dirname(dest)
        if not os.path.exists(parent):
            os.makedirs(parent, exist_ok=True)
        # if target exists remove it to allow overwrite
        if os.path.lexists(dest):
            if os.path.isdir(dest) and not os.path.islink(dest):
                for root, dirs, files in os.walk(dest, topdown=False):
                    for f in files:
                        try: os.remove(os.path.join(root, f))
                        except: pass
                    for d in dirs:
                        try: os.rmdir(os.path.join(root, d))
                        except: pass
                try: os.rmdir(dest)
                except: pass
            else:
                try: os.remove(dest)
                except: pass
        # directories in zip are represented with trailing slash
        if member.endswith("/"):
            try: os.makedirs(dest, exist_ok=True)
            except: pass
        else:
            with z.open(member) as src, open(dest, "wb") as dst:
                dst.write(src.read())

try:
    t = input().strip()
    user_time = datetime.fromisoformat(t.replace("Z", "+00:00"))
    ctx = ssl._create_unverified_context()
    with urllib.request.urlopen("https://api.github.com/repos/Swapnil-Pradhan/LidMusic/releases/latest", context=ctx) as r:
        data = json.load(r)
    updated = datetime.fromisoformat(data["updated_at"].replace("Z", "+00:00"))
    if updated <= user_time:
        sys.exit()
    for a in data.get("assets", []):
        if a.get("content_type") == "application/zip" and a.get("browser_download_url"):
            url = a["browser_download_url"]
            fd, tmp = tempfile.mkstemp(suffix=".zip")
            os.close(fd)
            try:
                with urllib.request.urlopen(url, context=ctx) as resp, open(tmp, "wb") as out:
                    out.write(resp.read())
                with zipfile.ZipFile(tmp, "r") as z:
                    safe_extract(z, "/Applications")
            finally:
                print(data["name"])
                try: os.remove(tmp)
                except: pass
except Exception: pass