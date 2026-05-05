# Backlog tecnico prioritizzato

## Scopo

Tradurre `specs/user-stories.md` in un backlog tecnico ordinato per priorita', con task distinti per:

- **backend**
- **frontend**
- **dati**

Il backlog e' pensato per guidare lo sviluppo dell'app con focus iniziale sul **docente progettista**.

## Assunzioni confermate

1. I beni in **comodato d'uso** saranno gestiti con una **entita' dedicata di assegnazione/comodato collegata al bene**.
2. Il modello `Progetto -> Laboratorio -> Modulo -> Fornitura/Costo` resta il flusso principale dell'MVP.
3. `Campus` e `rete/partenariato` restano supportati, ma non sono il primo flusso utente da ottimizzare.

## Strategia di priorita'

- **P0**: fondamenta applicative minime per sostituire il CRUD tabellare con un flusso coerente.
- **P1**: percorso completo del docente progettista per laboratorio, moduli, beni e costi.
- **P2**: gestione dei beni in comodato d'uso.
- **P3**: controlli strutturali evoluti, supporto campus e rifiniture.

---

## P0 - Fondamenta applicative

### BL-01 - Navigazione guidata per progetto

**Priorita'**: P0  
**User story collegate**: US-01, US-02, US-03  
**Obiettivo**: introdurre una UX centrata sul progetto, non piu' solo sul CRUD per singola tabella.

**Backend**
1. Esportare endpoint leggibili per:
   - elenco progetti
   - dettaglio progetto
   - laboratori del progetto
2. Valutare viste SQL dedicate per ridurre join lato frontend.
3. Esporre in API almeno i campi sintetici richiesti dalla lista progetti.

**Frontend**
1. Creare una pagina o sezione `Progetti`.
2. Implementare una vista elenco con ricerca e filtri minimi.
3. Implementare una vista dettaglio progetto con collegamenti ai laboratori.

**Dati**
1. Verificare che `SintesiProgetto` esponga tutti gli attributi richiesti dalla UX iniziale.
2. Aggiungere eventuali viste per conteggi sintetici se il payload corrente non basta.

**Dipendenze**: nessuna.

---

### BL-02 - Ambito operativo del docente

**Priorita'**: P0  
**User story collegate**: US-01  
**Obiettivo**: preparare il sistema a limitare progetti e laboratori al perimetro dell'utente.

**Backend**
1. Definire il modello di assegnazione docente-progetto o docente-laboratorio.
2. Progettare le API in modo che il filtraggio per ambito possa essere aggiunto senza rompere gli endpoint.
3. Se l'autenticazione non e' ancora implementata, prevedere un livello temporaneo di mock o configurazione locale.

**Frontend**
1. Strutturare le schermate assumendo che l'elenco dati possa essere gia' filtrato lato API.
2. Evitare dipendenza da elenchi globali non coerenti con il futuro perimetro utente.

**Dati**
1. Progettare una futura entita' di assegnazione, ad esempio `AssegnazioneDocente`.
2. Non implementarla subito se il progetto resta monoprofessionale nella prima iterazione.

**Dipendenze**: BL-01.

**Nota**: questo punto resta parzialmente aperto finche' non viene deciso il modello di autenticazione/autorizzazione.

---

## P1 - Flusso principale del docente progettista

### BL-03 - Scheda progetto applicativa

**Priorita'**: P1  
**User story collegate**: US-02, US-15, US-17  
**Obiettivo**: costruire una schermata di progetto orientata al lavoro, non solo alla manutenzione dati.

**Backend**
1. Creare un endpoint o una vista di dettaglio progetto che aggrega:
   - dati anagrafici progetto
   - finanziamento
   - istituto capofila
   - campus opzionale
   - indicatori strutturali
2. Riutilizzare `SintesiProgetto` e `VerificaVincoliProgetto`.
3. Aggiungere eventuali campi mancanti per conteggi di beni o costi totali.

**Frontend**
1. Costruire una `ProjectDetailView`.
2. Mostrare card con:
   - contesto del progetto
   - stato vincoli strutturali
   - accesso rapido a laboratori, moduli, beni e riepilogo.
3. Evidenziare chiaramente eventuali anomalie.

**Dati**
1. Verificare che le viste supportino conteggi aggiornati su laboratori, moduli, costi.
2. Se necessario aggiungere una vista `RiepilogoProgetto`.

**Dipendenze**: BL-01.

---

### BL-04 - Gestione laboratorio in contesto progetto

**Priorita'**: P1  
**User story collegate**: US-03, US-04  
**Obiettivo**: permettere al docente di creare e mantenere i laboratori nel contesto del progetto.

**Backend**
1. Consolidare endpoint CRUD per `Laboratorio` nel contesto di `idProgetto`.
2. Introdurre endpoint filtrati per progetto e plesso.
3. Validare lato API che ogni laboratorio appartenga a un progetto esistente.

**Frontend**
1. Creare una lista laboratori dentro la scheda progetto.
2. Implementare form laboratorio con:
   - nome
   - plesso
   - aula
   - descrizione
3. Consentire creazione, modifica e navigazione al dettaglio laboratorio.

**Dati**
1. Verificare indici su `Laboratorio(idProgetto, idPlesso)`.
2. Valutare una vista `LaboratorioConTarget` per filtri piu' rapidi.

**Dipendenze**: BL-03.

---

### BL-05 - Gestione moduli didattici

**Priorita'**: P1  
**User story collegate**: US-05, US-06, US-07  
**Obiettivo**: completare la progettazione didattica del laboratorio.

**Backend**
1. Esporre CRUD contestualizzato per `Modulo`.
2. Esporre catalogo `Target`, `Obiettivo`, `TipoObiettivo`.
3. Esporre associazioni `ObiettiviModulo` in modo semplice per il frontend.

**Frontend**
1. Creare una sezione `Moduli` nella scheda laboratorio.
2. Implementare:
   - lista moduli
   - form modulo
   - gestione obiettivi associati con priorita'
3. Mostrare i moduli con target e sintesi didattica.

**Dati**
1. Verificare vincoli di univocita' dei moduli per laboratorio.
2. Valutare una vista `ModuloDettaglio` con target e obiettivi gia' risolti.

**Dipendenze**: BL-04.

---

### BL-06 - Piano beni e attrezzature

**Priorita'**: P1  
**User story collegate**: US-08, US-09  
**Obiettivo**: permettere al docente di costruire il paniere di beni per ciascun laboratorio.

**Backend**
1. Mantenere CRUD per `Fornitura`, `TipoFornitura`, `Fornitore`.
2. Definire se l'anagrafica bene e' condivisa tra laboratori o clonabile per laboratorio.
3. Esporre endpoint che restituiscono le forniture usate nel laboratorio con i dati utili alla modifica.

**Frontend**
1. Creare una sezione `Beni` nella scheda laboratorio.
2. Separare chiaramente:
   - catalogo beni
   - beni gia' associati al laboratorio
3. Consentire inserimento e modifica dei dettagli acquistabili.

**Dati**
1. Valutare se il modello attuale `Fornitura` + `Costo` copre bene la distinzione tra catalogo bene e utilizzo nel laboratorio.
2. Se necessario introdurre una vista di join per l'editing applicativo.

**Dipendenze**: BL-04.

**Nota aperta**: resta da decidere se il record `Fornitura` rappresenta un catalogo globale o una definizione di bene contestuale al progetto.

---

### BL-07 - Costi e quadro economico

**Priorita'**: P1  
**User story collegate**: US-10, US-11  
**Obiettivo**: rendere operativa la costruzione del piano costi per laboratorio.

**Backend**
1. Consolidare CRUD per `Costo` con validazioni minime.
2. Esporre aggregati per:
   - totale laboratorio
   - totale per voce
   - dettaglio righe costo
3. Gestire errori chiari su quantita', voce e fornitura mancanti.

**Frontend**
1. Integrare editor delle righe costo nella scheda laboratorio.
2. Mostrare:
   - totale laboratorio
   - tabella per voce
   - dettaglio riga
3. Aggiornare i riepiloghi dopo ogni salvataggio.

**Dati**
1. Riutilizzare `CostoTotalePerLaboratorio`, `CostoPerVoce`, `DettaglioForniture`.
2. Valutare una vista laboratorio-completa che unisca dati anagrafici e costi.

**Dipendenze**: BL-06.

---

## P2 - Comodato d'uso

### BL-08 - Estensione del modello dati per comodato

**Priorita'**: P2  
**User story collegate**: US-12, US-13, US-14  
**Obiettivo**: introdurre il modello dedicato per i beni in comodato d'uso.

**Backend**
1. Progettare nuove entita', ad esempio:
   - `Comodato`
   - `DestinatarioComodato` oppure campi equivalenti
2. Collegare il comodato al bene/voce di costo o alla riga di utilizzo del bene nel laboratorio.
3. Esporre CRUD e query di riepilogo dedicate.

**Frontend**
1. Aggiungere la distinzione tra beni del laboratorio e beni in comodato.
2. Aggiungere form per assegnazione del comodato:
   - destinatario o gruppo destinatario
   - motivazione
   - quantita'
3. Implementare vista separata dei comodati.

**Dati**
1. Estendere lo schema SQL con le nuove tabelle.
2. Valutare se il collegamento corretto sia verso `Costo` oppure verso una nuova entita' di allocazione del bene.
3. Aggiungere viste di riepilogo per progetto e laboratorio.

**Dipendenze**: BL-06, BL-07.

**Decisione presa**: usare **entita' dedicata di assegnazione/comodato**, non semplice flag sul bene.

---

### BL-09 - Riepilogo beni in comodato

**Priorita'**: P2  
**User story collegate**: US-14  
**Obiettivo**: offrire una vista leggibile dei beni assegnati in comodato.

**Backend**
1. Creare una vista o endpoint `RiepilogoComodati`.
2. Esporre progetto, laboratorio, bene, quantita', destinatario e motivazione.

**Frontend**
1. Creare una sezione dedicata nel progetto.
2. Supportare filtri per progetto, laboratorio e destinatario.

**Dati**
1. Aggiungere indici utili per filtri e riepiloghi.

**Dipendenze**: BL-08.

---

## P3 - Controlli strutturali e supporto campus

### BL-10 - Controlli strutturali applicativi

**Priorita'**: P3  
**User story collegate**: US-15, US-16  
**Obiettivo**: trasformare i controlli strutturali da semplice vista dati a feedback applicativo.

**Backend**
1. Mantenere e, se serve, ampliare `VerificaVincoliProgetto`.
2. Classificare le anomalie con codici interpretabili dal frontend.
3. Esporre motivazioni puntuali per ciascun vincolo non rispettato.

**Frontend**
1. Mostrare badge e messaggi strutturati nella scheda progetto.
2. Evidenziare quali azioni mancano per completare il progetto.
3. Aggiornare il pannello dopo modifiche su laboratori, campus e comodati rilevanti.

**Dati**
1. Valutare una vista `AnomalieProgetto` oltre alla vista booleana esistente.

**Dipendenze**: BL-03, BL-04, BL-08.

---

### BL-11 - Supporto campus e partecipanti

**Priorita'**: P3  
**User story collegate**: US-02, US-15, US-16  
**Obiettivo**: completare la gestione del campus quando il progetto lo richiede.

**Backend**
1. Rendere pienamente operativi CRUD e query per `Campus`, `TipoAggregazione`, `CampusPartecipante`.
2. Validare coerenza tra progetto di tipo `campus` e presenza del relativo record campus.
3. Esporre riepiloghi con partecipanti e conteggi.

**Frontend**
1. Aggiungere editor campus dentro la scheda progetto.
2. Aggiungere gestione dei partecipanti.
3. Mostrare il contributo del campus nei controlli strutturali.

**Dati**
1. Verificare che il seed continui a funzionare anche senza campus.
2. Aggiungere eventuali viste di sintesi per campus.

**Dipendenze**: BL-03, BL-10.

---

### BL-12 - Sintesi finale progetto

**Priorita'**: P3  
**User story collegate**: US-17  
**Obiettivo**: fornire una vista finale condivisibile e verificabile.

**Backend**
1. Esporre una query o vista finale per progetto con:
   - contesto progetto
   - numero laboratori
   - numero moduli
   - totale beni
   - budget complessivo
   - esito vincoli
2. Prevedere esportazione futura senza introdurla subito.

**Frontend**
1. Creare una schermata `Riepilogo progetto`.
2. Organizzare la vista in sezioni leggibili.
3. Preparare layout stampabile o esportabile in fase successiva.

**Dati**
1. Valutare una vista `RiepilogoFinaleProgetto`.

**Dipendenze**: BL-07, BL-09, BL-10, BL-11.

---

## Sequenza consigliata di implementazione

### Fase 1 - MVP docente progettista

1. BL-01 Navigazione guidata per progetto
2. BL-03 Scheda progetto applicativa
3. BL-04 Gestione laboratorio in contesto progetto
4. BL-05 Gestione moduli didattici
5. BL-06 Piano beni e attrezzature
6. BL-07 Costi e quadro economico

### Fase 2 - Comodato d'uso

1. BL-08 Estensione del modello dati per comodato
2. BL-09 Riepilogo beni in comodato

### Fase 3 - Evoluzione progetto/campus

1. BL-10 Controlli strutturali applicativi
2. BL-11 Supporto campus e partecipanti
3. BL-12 Sintesi finale progetto

## Ambiguita' residue da confermare

1. **Autenticazione e autorizzazione**: non e' ancora deciso come il docente venga identificato e collegato ai propri progetti/laboratori.
2. **Catalogo beni**: non e' ancora deciso se `Fornitura` debba restare un catalogo globale condiviso oppure diventare anche contestualizzabile per progetto.
3. **Chiusura della progettazione**: nelle user story compare implicitamente una nozione di conferma finale, ma non e' ancora definito uno stato di workflow.

## Prossimo deliverable consigliato

Trasformare questo backlog in **issue implementative** o in **task eseguibili per sprint**, con stima relativa, dipendenze operative e definizione puntuale delle modifiche a schema, API e componenti frontend.
