# Aplicatie UpOrtho — context proiect

Aplicatie iOS nativa (SwiftUI) pentru **uportho.ro**, descarcabila din App Store,
cu backend Odoo (cont client, facturare — aceleasi date/structura ca site-ul),
dar cu design vizual diferit fata de site. Include push notifications.

## Structura folderelor din acest proiect

- `Rezultate/UPorthoApp/` — proiectul Xcode propriu-zis (codul aplicatiei, singurul folder deschis in Xcode)
- `.claude/agents/` — subagenti Claude Code reali pentru acest proiect (`ios-development`, `odoo-integration`, `design`)
- `PROIECT.md` — planul general, scope, roadmap (limba romana, pentru om)
- `CLAUDE.md` — acest fisier, context tehnic pentru Claude Code

## REGULA CRITICA DE SIGURANTA — Odoo

**NU se modifica NIMIC in Odoo fara acceptul explicit al userului.**
Este permis doar accesul de citire (browsing, API read-only). Niciodata:
- scrieri/updateuri prin XML-RPC/JSON-RPC fara confirmare explicita
- submit real de comenzi/checkout
- orice alta modificare de date in Odoo

Pana la confirmarea userului, orice integrare Odoo ramane read-only sau mock.

## Stack tehnic

- SwiftUI, iOS 16+ deployment target, pattern MVVM
- XcodeGen pentru generarea `.xcodeproj` din `project.yml` (nu se editeaza manual pbxproj)
- `xcodebuild` / `xcrun simctl` pentru build si testare in simulator
- Model de date + `MockOdooClient` (protocol `OdooClient`) gata pregatite pentru inlocuire cu implementare reala Odoo (XML-RPC/JSON-RPC), cand vom avea acces (host, nume DB, API key)

## Status curent

- Scaffold complet functional: Home (banner + categorii + recomandari), Catalog (grid + filtre categorii),
  Detaliu produs (variante, tiers de pret, pret Ortho Club), Cos + Checkout (demo, fara request-uri reale),
  Cont, 4 taburi (Acasa/Catalog/Cos/Cont)
- Toate datele sunt mock, aliniate structural cu uportho.ro (verificat prin navigare read-only pe site)
- Integrare Odoo reala: **neinceputa** — in asteptarea cheii API (userul are login backend/admin separat,
  cauta sectiunea Account Security > API Keys din propriul profil)
- Fara commit-uri git facute pana acum (doar la cerere explicita)

## Conventii de lucru

- Commit doar cand userul cere explicit
- Dupa orice swap temporar de root view (pentru screenshot-uri de verificare), reinstaleaza si relanseaza
  intotdeauna aplicatia pe simulator (nu doar recompilare) inainte de a considera revert-ul complet
- Numele de model `Category` intra in conflict cu `ObjectiveC.Category` (typealias catre `OpaquePointer`) —
  se foloseste `ProductCategory`
