# BBMG Harmonic Empire HQ — Bootstrap

Turnkey shell script to stand up the **BBMG™ Harmonic Council** workspace on macOS:
- Creates the `Empire_HQ` structure + council configs
- Drops cleanup + trademark tools
- Scaffolds Perplexity Intel Sweep job (placeholder)
- Generates Gmail `mailFilters.xml`
- (Optional) Wires Google Workspace aliases/groups/labels/filters via **GAM**

> Script: `bbmg_bootstrap.sh`

---

## Quickstart (Local)

**Dry-run (no changes):**
```bash
zsh bbmg_bootstrap.sh --dry-run
```

**Apply (creates files locally):**
```bash
zsh bbmg_bootstrap.sh --apply --info info@blvckbandz.com
```

**Apply + Workspace wiring (requires GAMADV-XTD3 + super-admin):**
```bash
zsh bbmg_bootstrap.sh --apply --info info@blvckbandz.com --with-gam
```

---

## One‑liner Install (from GitHub Releases or raw URL)

Replace `<RAW_URL>` with your hosted raw file URL (e.g., GitHub):
```bash
curl -fsSL <RAW_URL>/bbmg_bootstrap.sh -o ~/bbmg_bootstrap.sh && chmod +x ~/bbmg_bootstrap.sh && zsh ~/bbmg_bootstrap.sh --dry-run
```

Then, when satisfied:
```bash
zsh ~/bbmg_bootstrap.sh --apply --info info@blvckbandz.com --with-gam
```

---

## What It Sets Up

- **Folders**
  - `~/Empire_HQ/BBMG-Harmonic-Empire-HQ/` (council, config, prompts, tools, logs)
  - `~/marvinflowers/` cleanup quarantine + logs

- **Configs & Prompts**
  - `BBMG_Sonoran_Roster.yaml`
  - `routing_overlay_sonoran.yaml`
  - `prompts/fast_prompts_sonoran.txt`

- **Tools**
  - `bin/bbmg_clean.sh` (safe local cleanup/quarantine + merge)
  - `tools/bbmg_trademark_sweep.py` + `bbmg_trademark_sweep.sh` (®→™ on text; backups + logs)

- **Perplexity Scaffold**
  - `council/perplexity_agent/daily_tasks/run_intel_sweep.sh` (placeholder)
  - `council/perplexity_agent/karael_master_prompt.txt`

- **Gmail**
  - `tools/mailFilters.xml` (import via Gmail UI or GAM)

---

## Gmail Filters Import (UI)

Gmail → Settings → **Filters** → **Import** → select `tools/mailFilters.xml`

Creates:
- **Approvals**: `to:approvals@blvckbandz.com subject:[APPROVAL]` → Star + Label `Approvals/Today` + Never spam
- **Security**: `to:security@blvckbandz.com` → Label `Security/Critical` + Important + Forward to `info@`
- **Council Reports**: `from:(<agents>)` → Label `Council/Reports`

---

## Optional: GAM Wiring (CLI)

Install GAMADV-XTD3, authorize as Workspace super-admin, then run with `--with-gam` to:
- Create 10 **agent aliases** on `info@`
- Create **approvals@**, **security@**, **council@** groups and add `info@` as member
- Create Gmail **labels**
- Import **filters**
- Send a **test [APPROVAL]** email

Sanity checks:
```bash
gam info user info@blvckbandz.com | grep -A1 Aliases
gam info group approvals@blvckbandz.com
gam user info@blvckbandz.com filters list
```

---

## Verification Checklist

- [ ] `~/Empire_HQ/BBMG-Harmonic-Empire-HQ` exists with `council/`, `config/`, `prompts/`
- [ ] `bbmg_clean.sh` runs: `zsh ~/Empire_HQ/BBMG-Harmonic-Empire-HQ/bin/bbmg_clean.sh`
- [ ] Trademark sweep dry-run: `zsh ~/Empire_HQ/BBMG-Harmonic-Empire-HQ/tools/bbmg_trademark_sweep.sh dry`
- [ ] Gmail labels visible; filters imported
- [ ] Test email arrived: Starred + `Approvals/Today`
- [ ] DKIM/SPF/DMARC set at DNS (deliverability)

---

## Safety Notes

- Trademark tool only touches **text-like** files; creates `.bak` before write.
- Cleanup script quarantines heavy dev caches (`node_modules`, `venv`, `.venv`) non-destructively.
- Perplexity job is a placeholder—wire your CLI/API key before use.

---

## License

© 2025 Blvck Bandz Music Group™. All Rights Reserved.
For internal BBMG™ deployment only.
