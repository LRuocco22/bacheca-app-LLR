# Bacheca annunci di lavoro — app Flutter

Client Flutter della bacheca: le aziende si registrano, pubblicano annunci e
consultano le candidature; i candidati (senza login) consultano la bacheca e si
candidano allegando il curriculum in PDF.

Back-end: repository separato `bacheca-server-LLR` (Dart + shelf).

## Ambiente di sviluppo e scelte tecniche

Il progetto è stato sviluppato su un **Chromebook con Linux** (ambiente di
sviluppo Linux di ChromeOS) e provato su un **iPhone**.

- **Perché l'app è usata dal browser e non installata.** Per installare
  un'app su iPhone servono un Mac (Xcode) e un account sviluppatore Apple,
  che non ho. Per questo l'app è compilata per il **web**
  (`flutter build web`): è lo stesso codice Flutter, che sull'iPhone si apre
  in Safari (e si può aggiungere alla schermata Home come un'app).
  Per lo stesso motivo il curriculum si sceglie con `file_picker` in
  modalità web e si apre in una nuova scheda con `url_launcher`.
- **Perché il tunnel.** Il telefono non riusciva a raggiungere direttamente
  il server dentro l'ambiente Linux del Chromebook (port forwarding di
  ChromeOS non funzionante). Ho quindi usato un tunnel Cloudflare
  (`cloudflared tunnel --url http://localhost:8080`), che dà un indirizzo
  `https://....trycloudflare.com` raggiungibile dal telefono.
  Il tunnel trasporta solo il traffico: **il server, i dati e i curriculum
  restano sul mio computer** e sono gestiti dal back-end scritto da me
  (repository `bacheca-server-LLR`). Non si usano servizi esterni già pronti
  (tipo Firebase o Supabase).
- **Compilazione.** Il Chromebook non ha abbastanza memoria per compilare
  Flutter, quindi la versione web la compila **GitHub Actions** a ogni push
  (file `.github/workflows/build-web.yml`); il risultato (artefatto
  `bacheca-web`) viene copiato nella cartella `web/` del server.

## Pacchetti

Come nell'esempio del corso: `http`, `provider`, `shared_preferences`, `intl`.
In più, solo per il curriculum: `file_picker` + `file_picker_web` (scelta del PDF) e
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
