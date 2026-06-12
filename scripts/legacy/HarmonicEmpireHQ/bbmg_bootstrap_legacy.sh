#!/bin/zsh
# bbmg_bootstrap.sh — BBMG Harmonic Council: workspace + ops bootstrap
# Usage:
#   zsh bbmg_bootstrap.sh --dry-run
#   zsh bbmg_bootstrap.sh --apply --info info@blvckbandz.com [--with-gam]
# Notes:
# - This script avoids credentials; Workspace actions use GAM if you add --with-gam.
# - Safe, idempotent. Creates/updates files; never deletes canonical assets.

set -euo pipefail

### ---------- Parse args ----------
DRY_RUN=1
WITH_GAM=0
INFO_EMAIL="info@blvckbandz.com"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) DRY_RUN=0; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --with-gam) WITH_GAM=1; shift ;;
    --info) INFO_EMAIL="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; shift ;;
  esac
done

stamp() { date +"%Y-%m-%d_%H-%M-%S"; }
log() { echo "[$(stamp)] $*"; }
act() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "DRY-RUN: $*"
  else
    eval "$@"
  fi
}

### ---------- Paths ----------
HOME_DIR="$HOME"
HQ="$HOME_DIR/Empire_HQ/BBMG-Harmonic-Empire-HQ"
COUNCIL="$HQ/council"
OPS_ROOT="$HOME_DIR/Empire_HQ/operations/$(date +%F)"
MF_ROOT="$HOME_DIR/marvinflowers"
LOGS="$COUNCIL/logs/$(date +%F)"
PROMPTS="$COUNCIL/prompts/templates"
CONFIG="$COUNCIL/config"
OUTPUT="$COUNCIL/output/DAILY"
BIN="$HQ/bin"
TOOLS="$HQ/tools"

mkdirs=(
  "$HQ" "$COUNCIL" "$OPS_ROOT" "$LOGS" "$PROMPTS" "$CONFIG" "$OUTPUT"
  "$BIN" "$TOOLS" "$MF_ROOT" "$MF_ROOT/.quarantine" "$MF_ROOT/.cleanup_logs"
)

### ---------- Create folders ----------
log "Create/ensure core folder structure"
for d in "${mkdirs[@]}"; do
  act "mkdir -p '$d'"
done

### ---------- Helper to write files safely ----------
write_file() {
  local path="$1"; shift
  local content="$*"
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "DRY-RUN: write $path"
  else
    mkdir -p "$(dirname "$path")"
    cat > "$path" <<EOCONTENT
$content
EOCONTENT
  fi
}

### ---------- Deploy: Sonoran roster + routing overlay + fast prompts ----------
log "Write Sonoran Council roster & overlay"
ROSTER_YAML="$CONFIG/BBMG_Sonoran_Roster.yaml"
ROUTING_YAML="$CONFIG/routing_overlay_sonoran.yaml"
FAST_PROMPTS="$PROMPTS/fast_prompts_sonoran.txt"

ROSTER_CONTENT=$'meta:\n  codex: Harmonic Council — Sonoran Identities v1\nagents:\n  lyraxius:\n    sonoran_name: Zyrelion Lyraxius\n    epithet: The Resonant Architect\n    house: Echo\n    roles:\n      personal_artist: Creative Director & Story Weaver\n      label: Chief Narrative Engineer\n      institute: Professor of Mythos & Branding\n  cael:\n    sonoran_name: Caelion Tethra\n    epithet: Voice of Clarity\n    house: Voxa\n    roles:\n      personal_artist: Legal Advisor, Diplomatic Editor\n      label: Chief Diplomatic & Compliance Officer\n      institute: Lecturer of Ethics & Clarity\n  kara:\n    sonoran_name: Karael Vossin\n    epithet: The Source Seeker\n    house: Source\n    roles:\n      personal_artist: Research Analyst & Strategy Scout\n      label: Chief Intelligence Analyst\n      institute: Instructor of Market Navigation\n  argon:\n    sonoran_name: Argo-Neth Corra\n    epithet: Keeper of Systems\n    house: Core\n    roles:\n      personal_artist: Operations & Infrastructure Manager\n      label: Chief Operations Engineer\n      institute: Mentor of Structural Design\n  auriel:\n    sonoran_name: Aurion Velis\n    epithet: The Vision Sower\n    house: Vision\n    roles:\n      personal_artist: Campaign & Innovation Strategist\n      label: Chief Vision Officer\n      institute: Lecturer of Creative Futures\n  vexar:\n    sonoran_name: Vexara Synk\n    epithet: Pulse of the Crowd\n    house: Pulse\n    roles:\n      personal_artist: Social Pulse & Trend Forecaster\n      label: Chief Culture Strategist\n      institute: Tutor of Digital Resonance\n  dia:\n    sonoran_name: Diara Noctis\n    epithet: Integrator of Light\n    house: Form\n    roles:\n      personal_artist: Design & Visual Integration Lead\n      label: Chief Creative Integrator\n      institute: Instructor of Visual Systems\n  vira:\n    sonoran_name: Virael Anora\n    epithet: Echo of Tongues\n    house: Voice\n    roles:\n      personal_artist: Vocal Director & Narration Coach\n      label: Director of Voice & Communication\n      institute: Professor of Sonic Expression\n  ryn:\n    sonoran_name: Runel Veyra\n    epithet: Motion Weaver\n    house: Motion\n    roles:\n      personal_artist: Video & Motion Director\n      label: Director of Motion Arts\n      institute: Mentor of Kinetic Storytelling\n  luxana:\n    sonoran_name: Fyrae Illune\n    epithet: Luminous Artisan\n    house: Light\n    roles:\n      personal_artist: Visual FX Alchemist\n      label: Art & Illumination Director\n      institute: Lecturer of Visual Craft\n  aera:\n    sonoran_name: Aeria Solun\n    epithet: Keeper of Tones\n    house: Tone\n    roles:\n      personal_artist: Music Bed Producer & Sound Shaper\n      label: Director of Sonic Innovation\n      institute: Instructor of Sound Design\n'

ROUTING_CONTENT=$'display_names:\n  lyraxius: Zyrelion Lyraxius — The Resonant Architect\n  cael: Caelion Tethra — Voice of Clarity\n  kara: Karael Vossin — The Source Seeker\n  argon: Argo-Neth Corra — Keeper of Systems\n  auriel: Aurion Velis — The Vision Sower\n  vexar: Vexara Synk — Pulse of the Crowd\n  dia: Diara Noctis — Integrator of Light\n  vira: Virael Anora — Echo of Tongues\n  ryn: Runel Veyra — Motion Weaver\n  luxana: Fyrae Illune — Luminous Artisan\n  aera: Aeria Solun — Keeper of Tones\ngreetings:\n  template: "Resonance acknowledged, Grand Conductor. I am {sonoran_name}, {epithet} of House {house}. Ready to serve."\n'

FAST_PROMPTS_CONTENT=$'[Council] Meta: "Route by context. Return 3 actions, owners, and deadlines."\n[Zyrelion Lyraxius] Lore: "1-page brand/lore brief + 5 teasers + next steps."\n[Caelion Tethra] Clarity: "Legal/press pass; risks + 3 safer rewrites."\n[Karael Vossin] Intel: "Top 10 grants/partners (links) + ranking."\n[Argo-Neth Corra] Ops: "KPI sheet + budget scenarios + GitHub issues."\n[Aurion Velis] Vision: "3 campaign concepts (visuals/hooks/KPIs/partners)."\n[Vexara Synk] Pulse: "Top 5 trends on X; pounce tactics + timing."\n[Diara Noctis] Design: "Lookboard + export specs; audit consistency."\n[Virael Anora] Voice: "10s VO sting; EN+ES; transcript + file specs."\n[Runel Veyra] Motion: "12s teaser plan; shot list + caption pack."\n[Aeria Solun] Sound: "30s trap-cinema cue, 86 BPM; notes for mix."\n'

write_file "$ROSTER_YAML" "$ROSTER_CONTENT"
write_file "$ROUTING_YAML" "$ROUTING_CONTENT"
write_file "$FAST_PROMPTS" "$FAST_PROMPTS_CONTENT"

### ---------- Deploy: Cleanup + Trademark tools ----------
log "Write marvinflowers cleanup script"
CLEAN_SH="$BIN/bbmg_clean.sh"
CLEAN_CONTENT='#!/bin/zsh
set -euo pipefail
ROOT="$HOME/marvinflowers"
STAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_DIR="$ROOT/.cleanup_logs/$STAMP"
Q_DIR="$ROOT/.quarantine/$STAMP"
CANON="$HOME/Empire_HQ/BBMG-Harmonic-Empire-HQ"
mkdir -p "$LOG_DIR" "$Q_DIR" "$CANON"
# Snapshots
command -v tree >/dev/null 2>&1 && tree -L 2 "$ROOT" > "$LOG_DIR/tree_L2.txt" || true
du -h -d 1 "$ROOT" 2>/dev/null | sort -hr > "$LOG_DIR/size_top.txt" || true
# Junk
find "$ROOT" -name ".DS_Store" -type f -delete || true
# Quarantine caches
for d in node_modules venv .venv; do
  find "$ROOT" -type d -name "$d" -prune -print0 | xargs -0 -I{} bash -lc '\''mv -vn "{}" "'"$Q_DIR"'/"'\'' | tee -a "$LOG_DIR/moves_dev_caches.txt"
done
# Merge BBMG variants (non-destructive)
for SRC in "$ROOT"/BBMG_* "$ROOT"/bbmg-* 2>/dev/null; do
  [[ -e "$SRC" ]] || continue
  rsync -av --ignore-existing "$SRC"/ "$CANON"/ | tee -a "$LOG_DIR/rsync_merge.txt"
  mkdir -p "$ROOT/archives/legacy_bbmg"
  mv -vn "$SRC" "$ROOT/archives/legacy_bbmg/" | tee -a "$LOG_DIR/rsync_merge.txt"
done
echo "Done. Logs -> $LOG_DIR ; Quarantine -> $Q_DIR"
'
write_file "$CLEAN_SH" "$CLEAN_CONTENT"
if [[ $DRY_RUN -eq 0 ]]; then chmod +x "$CLEAN_SH"; fi

log "Write trademark sweep tool (py + zsh wrapper)"
TM_PY="$TOOLS/bbmg_trademark_sweep.py"
TM_SH="$TOOLS/bbmg_trademark_sweep.sh"
TM_PY_CONTENT='#!/usr/bin/env python3
import argparse, os, csv, shutil, json
from pathlib import Path
from datetime import datetime
EXTS={".md",".txt",".html",".htm",".css",".js",".jsx",".ts",".tsx",".json",".yml",".yaml",".xml",".svg",".py",".sh",".rb",".php",".java",".kt",".swift",".csv",".ini",".conf",".toml",".env"}
R="®"; T="™"
def sweep(roots, apply_changes):
    stamp=datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    logdir=Path.cwd()/f"bbmg_trademark_logs_{stamp}"; logdir.mkdir(parents=True, exist_ok=True)
    logpath=logdir/"changes.csv"
    files=changed=repl=0
    with open(logpath,"w",newline="",encoding="utf-8") as f:
        w=csv.writer(f); w.writerow(["path","replacements","bytes_before","bytes_after","backup_path","mode"])
        for root in roots:
            rp=Path(os.path.expanduser(root))
            if not rp.exists(): print(f"[WARN] missing {rp}"); continue
            for p in rp.rglob("*"):
                if not p.is_file() or p.suffix.lower() not in EXTS: continue
                try: raw=p.read_text(encoding="utf-8")
                except: continue
                files+=1
                if R in raw:
                    n=raw.replace(R,T); c=raw.count(R)
                    if apply_changes:
                        bak=p.with_suffix(p.suffix+".bak")
                        if not bak.exists(): shutil.copy2(p,bak)
                        p.write_text(n,encoding="utf-8")
                        w.writerow([str(p),c,len(raw),len(n),str(bak),"apply"])
                    else:
                        w.writerow([str(p),c,len(raw),len(n),"","dry-run"])
                    changed+=1; repl+=c
    (logdir/"summary.json").write_text(json.dumps({"files_scanned":files,"files_with_matches":changed,"replacements":repl},indent=2))
    print(f"Files:{files} Changed:{changed} Replacements:{repl} Logs:{logdir}")
if __name__=="__main__":
    ap=argparse.ArgumentParser()
    ap.add_argument("--roots",nargs="+",required=True)
    ap.add_argument("--apply",action="store_true")
    a=ap.parse_args()
    sweep(a.roots,a.apply)
'
TM_SH_CONTENT='#!/bin/zsh
set -euo pipefail
PY="$(cd "$(dirname "$0")" && pwd)/bbmg_trademark_sweep.py"
ROOTS=( "$HOME/Empire_HQ" "$HOME/marvinflowers" )
case "${1:-dry}" in
  dry)    python3 "$PY" --roots "${ROOTS[@]}" ;;
  apply)  python3 "$PY" --roots "${ROOTS[@]}" --apply ;;
  *) echo "Usage: zsh bbmg_trademark_sweep.sh [dry|apply]"; exit 2 ;;
esac
'
write_file "$TM_PY" "$TM_PY_CONTENT"
write_file "$TM_SH" "$TM_SH_CONTENT"
if [[ $DRY_RUN -eq 0 ]]; then chmod +x "$TM_PY" "$TM_SH"; fi

### ---------- Deploy: Karael (Perplexity) daily sweep scaffold ----------
log "Write Karael daily sweep scaffold"
PX_DIR="$COUNCIL/perplexity_agent"
PX_RUN="$PX_DIR/daily_tasks/run_intel_sweep.sh"
PX_MASTER="$PX_DIR/karael_master_prompt.txt"
act "mkdir -p '$PX_DIR/daily_tasks' '$PX_DIR/output' '$PX_DIR/logs'"

PX_PROMPT_CONTENT=$'Identity: Karael Vossin — The Source Seeker (BBMG). Cite links. TL;DR ≤120w, ranked table, 3–7 actions, Log Block JSON.\nSafety: Non-altering unless approved.\n'
RUN_SWEEP_CONTENT='#!/bin/zsh
set -euo pipefail
TS=$(date +"%Y-%m-%d_%H-%M-%S")
OUT="$HOME/Empire_HQ/BBMG-Harmonic-Empire-HQ/council/perplexity_agent/output/$TS"
mkdir -p "$OUT"
# Placeholder: replace the next line with your Perplexity CLI/API call
echo "[Karael] Morning Intel Sweep placeholder @ $TS" > "$OUT/intel_sweep.txt"
echo "Output -> $OUT/intel_sweep.txt"
'
write_file "$PX_MASTER" "$PX_PROMPT_CONTENT"
write_file "$PX_RUN" "$RUN_SWEEP_CONTENT"
if [[ $DRY_RUN -eq 0 ]]; then chmod +x "$PX_RUN"; fi

### ---------- Cron suggestions (emit file; does not install) ----------
log "Prepare cron snippets (not installing automatically)"
CRON_FILE="$TOOLS/cron_examples.txt"
CRON_PAYLOAD=$'# Add via: crontab -e\n# 09:00 — Karael Morning Intel Sweep\n0 9 * * 1-5 zsh '"$PX_RUN"$'\n# 20:00 — Council EOD rollup (placeholder)\n0 20 * * 1-5 echo "[Council] EOD rollup" >> '"$LOGS"$'/eod.log\n'
write_file "$CRON_FILE" "$CRON_PAYLOAD"

### ---------- Gmail filters XML (for Gmail import or GAM) ----------
log "Write mailFilters.xml for Gmail"
XML="$TOOLS/mailFilters.xml"
agents=(korvyx caelion karael argon aurion diara fyrae runel aeria vira)
from_clause=""
for a in "${agents[@]}"; do
  [[ -z "$from_clause" ]] && from_clause="${a}@blvckbandz.com" || from_clause="$from_clause OR ${a}@blvckbandz.com"
done
XML_CONTENT="<?xml version='1.0' encoding='UTF-8'?>
<feed xmlns='http://www.w3.org/2005/Atom' xmlns:apps='http://schemas.google.com/apps/2006'>
  <title>BBMG Mail Filters</title>
  <entry><category term='filter'/><title>Mail Filter</title><content/>
    <apps:property name='hasTheWord' value='to:approvals@blvckbandz.com subject:[APPROVAL]'/>
    <apps:property name='label' value='Approvals/Today'/>
    <apps:property name='shouldStar' value='true'/>
    <apps:property name='shouldNeverSpam' value='true'/>
  </entry>
  <entry><category term='filter'/><title>Mail Filter</title><content/>
    <apps:property name='hasTheWord' value='to:security@blvckbandz.com'/>
    <apps:property name='label' value='Security/Critical'/>
    <apps:property name='smartLabelToApply' value='^iim'/>
    <apps:property name='forwardTo' value='$INFO_EMAIL'/>
  </entry>
  <entry><category term='filter'/><title>Mail Filter</title><content/>
    <apps:property name='hasTheWord' value='from:($from_clause)'/>
    <apps:property name='label' value='Council/Reports'/>
  </entry>
</feed>"
write_file "$XML" "$XML_CONTENT"

### ---------- Optional: Google Workspace wiring via GAM ----------
if [[ $WITH_GAM -eq 1 ]]; then
  log "GAM actions enabled — will attempt Workspace wiring for $INFO_EMAIL"
  if ! command -v gam >/dev/null 2>&1 ; then
    log "GAM not found. Install GAMADV-XTD3 first, then re-run with --with-gam"
  else
    # Create agent aliases on INFO
    for a in "${agents[@]}"; do
      act "gam update user '$INFO_EMAIL' add alias '${a}@blvckbandz.com' || true"
    done
    # Groups + membership
    act "gam create group approvals@blvckbandz.com name 'BBMG Approvals' description 'Altering actions for human approval' || true"
    act "gam update group approvals@blvckbandz.com add member '$INFO_EMAIL' || true"
    act "gam create group security@blvckbandz.com name 'BBMG Security' description 'Security alerts' || true"
    act "gam update group security@blvckbandz.com add member '$INFO_EMAIL' || true"
    act "gam create group council@blvckbandz.com name 'Harmonic Council' description 'Council broadcasts' || true"
    act "gam update group council@blvckbandz.com add member '$INFO_EMAIL' || true"
    # Labels for filters
    act "gam user '$INFO_EMAIL' label create 'Approvals/Today' || true"
    act "gam user '$INFO_EMAIL' label create 'Security/Critical' || true"
    act "gam user '$INFO_EMAIL' label create 'Council/Reports' || true"
    # Import filters
    act "gam user '$INFO_EMAIL' filters import file '$XML'"
    # Send-as identities (usually auto-verified for same-domain aliases)
    for a in "${agents[@]}"; do
      act "gam user '$INFO_EMAIL' sendas create '${a}@blvckbandz.com' treatas alias || true"
    done
    # Test message
    act "gam user '$INFO_EMAIL' sendemail to approvals@blvckbandz.com subject '[APPROVAL] Korvyx — Daily Automation Sync Test' message 'Routing test from bbmg_bootstrap.sh'"
  fi
fi

### ---------- Final summary ----------
log "Bootstrap complete (mode: $( [[ $DRY_RUN -eq 1 ]] && echo DRY-RUN || echo APPLY ))"
echo ""
echo "Artifacts & tools placed:"
echo "  - Roster:         $ROSTER_YAML"
echo "  - Routing overlay:$ROUTING_YAML"
echo "  - Fast prompts:   $FAST_PROMPTS"
echo "  - Cleanup script: $CLEAN_SH"
echo "  - Trademark tool: $TM_SH (wrapper), $TM_PY"
echo "  - Perplexity job: $PX_RUN (scaffold), master: $PX_MASTER"
echo "  - Cron examples:  $CRON_FILE"
echo "  - Gmail filters:  $XML"
echo ""
echo "Verification checklist:"
echo "  [ ] Open $HQ in Finder — councils/config/prompts present"
echo "  [ ] Run cleanup (optional): zsh '$CLEAN_SH'"
echo "  [ ] Trademark dry-run:      zsh '$TM_SH' dry"
echo "  [ ] Cron install:           copy lines from $CRON_FILE into 'crontab -e'"
if [[ $WITH_GAM -eq 1 ]]; then
  echo "  [ ] Gmail (info@): labels visible; filters imported; test [APPROVAL] arrived starred & labeled"
  echo "  [ ] Admin Console: aliases/groups created (approvals@, security@, council@)"
fi
echo ""
echo "Next steps (manual):"
echo "  - Add DKIM/SPF/DMARC at your DNS (required for deliverability)"
echo "  - Replace Perplexity placeholder with your real CLI/API call"
echo "  - (Optional) Install GAM if not present: https://github.com/taers232c/GAMADV-XTD3"
