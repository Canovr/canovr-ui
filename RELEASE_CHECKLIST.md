# CanovR iOS Release Checklist

## Security Gate
- [ ] Kein sensibles Logging in Networking/Auth/Onboarding
- [ ] OAuth-State wird bei Strava zwingend erzeugt und validiert
- [ ] Universal Links aktiv (Associated Domains + AASA korrekt)
- [ ] Keine internen Dateien im App-Bundle (`.claude`, `patches`, `.patch`, `.gitignore`)

## Quality Gate
- [ ] `./scripts/release_gate.sh` erfolgreich
- [ ] Returning-User-Flow führt deterministisch ins Dashboard
- [ ] Onboarding, Week-Load, Account-Löschung manuell verifiziert
- [ ] Mindestziel `iOS 18.0` im Release-Build geprüft

## Store Submission Gate
- [ ] Privacy URL und Support URL in App Store Connect hinterlegt
- [ ] App Privacy Details (Datenkategorien) vollständig gepflegt
- [ ] Export-Compliance beantwortet
- [ ] TestFlight Smoke (intern) ohne P0/P1 abgeschlossen
