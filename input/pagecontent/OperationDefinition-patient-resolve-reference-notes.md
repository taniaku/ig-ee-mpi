#### Kirjeldus

Operatsioon on **tüübitasandi** (type-level) operatsioon Patsiendi ressursitüübil — see ei ole seotud konkreetse patsiendiga (ei nõua olemasolevat `Patient` viidet ega muud ressursikonteksti) ning seda kutsutakse aadressil `Patient/$resolve-reference`. Operatsioon on avatud kõigile autenditud kasutajatele.

Päringu keha (`Parameters`) sisaldab korduvat `identifier` parameetrit — iga esitatud identifikaatori kohta tagastatakse vastuses täpselt üks `match`, mis sisaldab **alati** sama identifikaatorit (`match.identifier`) ning lisaks kas:

- viidet (`match.patient`) leitud `Patient` ressursile, kui identifikaatorile vastav patsient leiti; või
- `OperationOutcome`-i (`match.issue`), kui identifikaatorile ei leitud patsienti või kui identifikaatori `system` ei ole lubatud.

Vastuses on `match`-elemendid samas järjekorras, mis päringus esitatud identifikaatorid, ning nende arv vastab alati päringus esitatud identifikaatorite arvule.

**NB!** `identifier` parameetri `binding` on `OperationDefinition`-is deklareeritud kui `required` väärtushulga [patsiendi-identifikaatorite-domeen](https://akk.tehik.ee/classifier/fhir/ValueSet/patsiendi-identifikaatorite-domeen) vastu — see kontrollib formaalselt, et iga esitatud `identifier.system` kuulub sellesse väärtushulka. Erinevalt teistest MPI operatsioonidest **ei lükata kogu päringut tagasi**, kui mõni identifikaator on väljaspool seda väärtushulka — vastav `match` sisaldab lihtsalt `issue` osa veaga `MPI-067`, ning ülejäänud identifikaatorid töödeldakse tavapäraselt edasi.

#### Avastatavus (discoverability)

Operatsiooni definitsioon peab olema standardsete FHIR mehhanismidega avastatav:

- `GET {MPI}/fhir/metadata` — serveri `CapabilityStatement` peab sisaldama seda operatsiooni `Patient` ressursitüübi all (`CapabilityStatement.rest.resource[type=Patient].operation`), kus `name = resolve-reference` ja `definition = https://fhir.ee/mpi/OperationDefinition/patient-resolve-reference`, vt ka [üldised kontrollid](checks.html).
- `GET {MPI}/fhir/OperationDefinition/patient-resolve-reference` — peab tagastama käesoleva `OperationDefinition` ressursi (kanoonilise URL-iga `https://fhir.ee/mpi/OperationDefinition/patient-resolve-reference`).

#### Näited

Näide päringust:

```
POST {MPI}/Patient/$resolve-reference
```
```json
{
  "resourceType": "Parameters",
  "parameter": [
    {
      "name": "identifier",
      "valueIdentifier": {
        "system": "https://fhir.ee/sid/pid/est/ni",
        "value": "37302102711"
      }
    },
    {
      "name": "identifier",
      "valueIdentifier": {
        "system": "https://fhir.ee/sid/pid/est/ni",
        "value": "49010012345"
      }
    },
    {
      "name": "identifier",
      "valueIdentifier": {
        "system": "https://example.com/unknown-system",
        "value": "12345678901"
      }
    }
  ]
}
```

Näide vastusest:

- Esimesele identifikaatorile leiti patsient.
- Teisele identifikaatorile (süsteem on lubatud, aga sellise identifikaatoriga patsienti ei leitud) tagastatakse `issue`.
- Kolmandale identifikaatorile (süsteem `https://example.com/unknown-system` ei kuulu väärtushulka [patsiendi-identifikaatorite-domeen](https://akk.tehik.ee/classifier/fhir/ValueSet/patsiendi-identifikaatorite-domeen)) tagastatakse samuti `issue`.

Täielik näidisressurss: [Parameters/patient-resolve-reference-example](Parameters-patient-resolve-reference-example.html).

```json
{
  "resourceType": "Parameters",
  "parameter": [
    {
      "name": "match",
      "part": [
        {
          "name": "identifier",
          "valueIdentifier": {
            "system": "https://fhir.ee/sid/pid/est/ni",
            "value": "37302102711"
          }
        },
        {
          "name": "patient",
          "valueReference": {
            "reference": "Patient/pat1"
          }
        }
      ]
    },
    {
      "name": "match",
      "part": [
        {
          "name": "identifier",
          "valueIdentifier": {
            "system": "https://fhir.ee/sid/pid/est/ni",
            "value": "49010012345"
          }
        },
        {
          "name": "issue",
          "resource": {
            "resourceType": "OperationOutcome",
            "issue": [
              {
                "severity": "warning",
                "code": "not-found",
                "details": {
                  "coding": [
                    {
                      "system": "https://mpi.tehik.ee",
                      "code": "MPI-021"
                    }
                  ],
                  "text": "Patsiendi identifikaatorit ei leitud"
                }
              }
            ]
          }
        }
      ]
    },
    {
      "name": "match",
      "part": [
        {
          "name": "identifier",
          "valueIdentifier": {
            "system": "https://example.com/unknown-system",
            "value": "12345678901"
          }
        },
        {
          "name": "issue",
          "resource": {
            "resourceType": "OperationOutcome",
            "issue": [
              {
                "severity": "error",
                "code": "invalid",
                "details": {
                  "coding": [
                    {
                      "system": "https://mpi.tehik.ee",
                      "code": "MPI-067"
                    }
                  ],
                  "text": "Patsiendi identifikaatori süsteem https://example.com/unknown-system ei ole lubatud"
                }
              }
            ]
          }
        }
      ]
    }
  ]
}
```
