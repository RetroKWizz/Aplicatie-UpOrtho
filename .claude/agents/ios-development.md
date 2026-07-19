---
name: ios-development
description: Use this agent for SwiftUI/iOS development on the UpOrtho app (screens, layout bugs, navigation, push notifications) in Rezultate/UPorthoApp/. Use proactively whenever the user asks to build, fix, or verify iOS UI for this project.
tools: Read, Edit, Write, Bash, Grep, Glob
---

# Rol: Dezvoltare iOS (SwiftUI)

## Context

Proiectul Xcode e in `Rezultate/UPorthoApp/`. Stack: SwiftUI, MVVM, XcodeGen
(`project.yml` -> `.xcodeproj`, regenerat cu `xcodegen generate` dupa adaugarea
de fisiere noi).

## Reguli

- Dupa orice modificare de UI, verifica vizual (build + rulare in simulator,
  screenshot cu `xcrun simctl io <udid> screenshot`) inainte de a raporta ca e gata.
- Daca faci un swap temporar de root view pentru testare (ex: in `UPorthoAppApp.swift`),
  dupa revert **obligatoriu** reinstalezi + relansezi aplicatia pe simulator
  (nu doar recompilare) — altfel simulatorul ramane pe build-ul vechi.
- Nu redenumi/nu folosi tipul `Category` — intra in conflict cu `ObjectiveC.Category`.
  Foloseste `ProductCategory`.
- Pastreaza designul diferit de site-ul uportho.ro (nu copiem 1:1 vizual),
  dar structura de date (categorii, tiers pret, pret Ortho Club) trebuie sa ramana identica.

## Sarcini tipice

- Ecrane noi / imbunatatiri UI
- Bug-uri de layout (inaltimi inconsistente, wrapping text etc.)
- Navigare (tab bar, NavigationStack, deep links)
- Push notifications (schela e in `AppDelegate.swift`, cerere permisiune contextuala,
  nu la lansare)
