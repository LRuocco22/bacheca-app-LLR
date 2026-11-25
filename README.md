# Bacheca annunci di lavoro — app Flutter

Client Flutter della bacheca: le aziende si registrano, pubblicano annunci e
consultano le candidature; i candidati (senza login) consultano la bacheca e si
candidano allegando il curriculum in PDF.

Back-end: repository separato `bacheca_server` (Dart + shelf).

## Pacchetti

Come nell'esempio del corso: `http`, `provider`, `shared_preferences`, `intl`.
In più, solo per il curriculum: `file_picker` (scelta del PDF) e
`url_launcher` (apertura del PDF ricevuto).

## Struttura

```
lib/main.dart                 avvio, tema, provider, ripristino sessione
lib/routes.dart               rotte con nome e protezione dell'area riservata
lib/config/api_config.dart    indirizzo del server
lib/services/api_client.dart  chiamate HTTP (JSON e multipart), errori
lib/providers/auth_provider.dart  login/logout/registrazione azienda
lib/models/                   Azienda, Annuncio, Candidatura
lib/screens/                  bacheca, dettaglio, candidatura, login, registrazione
lib/screens/area/             area riservata, nuovo annuncio, candidature, dettaglio
lib/widgets/                  menu laterale, messaggi di errore
lib/utils/validators.dart     validazione (stesse regole del server), date
```

## Scenari

| Scenario | Percorso nell'app |
|---|---|
| S1 – Pubblicare un annuncio | Menu → Registra la tua azienda → Crea account → Login → Area riservata → Nuovo annuncio → Pubblica → Menu → Bacheca annunci |
| S2 – Candidarsi | Bacheca → tocca un annuncio → Candidati → nome, cognome, email, Allega curriculum → Invia → messaggio di conferma |
| S3 – Candidature e logout | Login → Area riservata → tocca un annuncio → tocca una candidatura → Apri curriculum → Logout (torna alla bacheca) |

## Esecuzione

L'app è pensata per essere usata come **app web** servita dal back-end:

1. `flutter build web` (oppure scaricare l'artefatto `bacheca-web` generato
   automaticamente da GitHub Actions a ogni push, scheda *Actions*);
2. copiare il contenuto di `build/web` nella cartella `web/` del server;
3. avviare il server e aprire il suo indirizzo nel browser del telefono
   (per l'accesso da qualsiasi rete: `cloudflared tunnel --url http://localhost:8080`).

Le API vengono chiamate allo stesso indirizzo della pagina, quindi non c'è
nessun indirizzo da configurare. Per l'anteprima di FlutLab (che gira su un
altro dominio) impostare `manualBaseUrl` in `lib/config/api_config.dart`.
