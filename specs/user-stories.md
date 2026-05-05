# User story dell'app

## Persona principale

### Docente progettista

Docente che progetta il laboratorio di propria pertinenza oppure i beni da assegnare in comodato d'uso, definendo contesto didattico, dotazioni, quantità e costi.

## Obiettivo del documento

Fornire un insieme di user story con criteri di accettazione per guidare la generazione e l'evoluzione dell'applicazione.

## Epic 1 - Accesso al proprio ambito di progettazione

### US-01 - Visualizzare i progetti assegnati

**Come** docente progettista  
**voglio** vedere i progetti e i laboratori di mia pertinenza  
**cosi' da** lavorare solo sugli ambienti che mi sono assegnati.

**Criteri di accettazione**
1. L'utente vede l'elenco dei progetti su cui puo' operare.
2. Per ogni progetto l'utente vede almeno nome progetto, finanziamento, istituto capofila e numero di laboratori collegati.
3. L'utente non puo' modificare progetti non inclusi nel proprio ambito di lavoro.

### US-02 - Visualizzare il contesto del progetto

**Come** docente progettista  
**voglio** aprire un progetto e vedere il suo contesto  
**cosi' da** comprendere i vincoli entro cui progettare.

**Criteri di accettazione**
1. La scheda progetto mostra almeno finanziamento, istituto capofila, tipologia progetto ed eventuale campus associato.
2. Se il progetto appartiene a un campus, la schermata mostra anche tipo di aggregazione e partecipanti.
3. La scheda progetto mostra i principali indicatori strutturali disponibili, inclusi ambienti minimi richiesti e ambienti attualmente censiti.

### US-03 - Filtrare i laboratori

**Come** docente progettista  
**voglio** filtrare i laboratori per progetto, plesso e target formativo  
**cosi' da** trovare rapidamente l'ambiente su cui intervenire.

**Criteri di accettazione**
1. L'utente puo' filtrare i laboratori almeno per progetto.
2. L'utente puo' combinare il filtro per progetto con plesso o target.
3. L'elenco aggiornato mostra solo i laboratori coerenti con i filtri attivi.

## Epic 2 - Progettazione del laboratorio

### US-04 - Definire la scheda laboratorio

**Come** docente progettista  
**voglio** creare o aggiornare la scheda del mio laboratorio  
**cosi' da** descrivere chiaramente l'ambiente da realizzare.

**Criteri di accettazione**
1. L'utente puo' inserire o modificare almeno nome laboratorio, plesso, aula e descrizione.
2. Ogni laboratorio deve essere associato a un progetto.
3. Dopo il salvataggio, il laboratorio compare nell'elenco del progetto di riferimento.

### US-05 - Associare moduli didattici al laboratorio

**Come** docente progettista  
**voglio** associare uno o piu' moduli didattici al laboratorio  
**cosi' da** collegare lo spazio alle attivita' formative previste.

**Criteri di accettazione**
1. L'utente puo' creare piu' moduli per lo stesso laboratorio.
2. Ogni modulo deve essere associato a un target formativo.
3. L'elenco dei moduli del laboratorio e' visibile nella scheda laboratorio.

### US-06 - Descrivere i moduli in chiave didattica

**Come** docente progettista  
**voglio** indicare target, discipline, profilo professionale e descrizione del modulo  
**cosi' da** motivare le scelte progettuali dal punto di vista formativo.

**Criteri di accettazione**
1. Per ogni modulo l'utente puo' compilare nome, descrizione, discipline e profilo professionale.
2. Il target formativo e' selezionabile dai target presenti nel sistema.
3. I dati del modulo restano modificabili fino alla conferma finale della progettazione.

### US-07 - Collegare obiettivi ai moduli

**Come** docente progettista  
**voglio** associare obiettivi ai moduli del laboratorio  
**cosi' da** mantenere coerenza tra finalita' didattiche e progettazione dell'ambiente.

**Criteri di accettazione**
1. L'utente puo' selezionare obiettivi esistenti dal catalogo.
2. Lo stesso modulo puo' essere collegato a piu' obiettivi.
3. Il sistema mostra gli obiettivi gia' associati al modulo e consente di aggiornarne la priorita'.

## Epic 3 - Piano delle forniture

### US-08 - Inserire beni e attrezzature per il laboratorio

**Come** docente progettista  
**voglio** inserire beni e attrezzature necessari per il mio laboratorio  
**cosi' da** costruire un piano acquisti dettagliato.

**Criteri di accettazione**
1. L'utente puo' associare al laboratorio una o piu' forniture.
2. Per ogni fornitura l'utente puo' indicare almeno quantita' e voce di costo.
3. Il laboratorio mostra l'elenco aggiornato delle forniture inserite.

### US-09 - Descrivere in modo acquistabile ogni bene

**Come** docente progettista  
**voglio** indicare tipologia, fornitore, prezzo, link e codice prodotto di ciascun bene  
**cosi' da** rendere ogni voce utilizzabile nella fase di acquisizione.

**Criteri di accettazione**
1. Ogni fornitura puo' essere classificata per tipo fornitura.
2. Il sistema consente di associare un fornitore e un prezzo unitario.
3. Il sistema consente di salvare informazioni di dettaglio come link, codice MEPA, SKU e note.

### US-10 - Ripartire i costi per voce di spesa

**Come** docente progettista  
**voglio** associare ogni bene a una voce del quadro economico  
**cosi' da** controllare il budget per categoria di spesa.

**Criteri di accettazione**
1. Ogni riga di costo richiede la selezione di una voce di spesa.
2. Il sistema puo' aggregare i costi del laboratorio per voce.
3. L'utente puo' vedere il totale per voce senza calcoli manuali.

### US-11 - Consultare il costo totale del laboratorio

**Come** docente progettista  
**voglio** vedere il costo totale del mio laboratorio e il dettaglio delle forniture  
**cosi' da** valutare subito la sostenibilita' della proposta.

**Criteri di accettazione**
1. La scheda laboratorio mostra il costo totale calcolato come somma di quantita' per prezzo.
2. Il dettaglio mostra almeno fornitura, quantita', prezzo unitario e totale riga.
3. I valori si aggiornano dopo l'inserimento, modifica o rimozione di una fornitura.

## Epic 4 - Beni in comodato d'uso

### US-12 - Distinguere i beni in comodato d'uso

**Come** docente progettista  
**voglio** distinguere i beni destinati al laboratorio dai beni da assegnare in comodato d'uso  
**cosi' da** gestire correttamente due finalita' diverse.

**Criteri di accettazione**
1. Ogni bene puo' essere classificato come dotazione del laboratorio oppure bene in comodato d'uso.
2. La classificazione e' visibile nell'elenco delle forniture.
3. Il sistema consente di filtrare separatamente le due tipologie.

### US-13 - Registrare i destinatari del comodato

**Come** docente progettista  
**voglio** indicare destinatario, motivazione e quantita' dei beni in comodato d'uso  
**cosi' da** tracciare l'uso previsto di tali beni.

**Criteri di accettazione**
1. Per i beni in comodato l'utente puo' indicare almeno destinatario o gruppo destinatario.
2. L'utente puo' inserire una motivazione descrittiva dell'assegnazione.
3. I dati del comodato restano collegati al progetto e al laboratorio di origine.

### US-14 - Consultare il riepilogo dei beni in comodato

**Come** docente progettista  
**voglio** visualizzare separatamente l'elenco dei beni in comodato d'uso  
**cosi' da** controllarli senza confonderli con le dotazioni fisse del laboratorio.

**Criteri di accettazione**
1. L'utente dispone di una vista o sezione dedicata ai beni in comodato.
2. Il riepilogo mostra almeno bene, quantita', destinatario e progetto di riferimento.
3. Dal riepilogo e' possibile aprire il dettaglio del bene o del laboratorio collegato.

## Epic 5 - Controlli di coerenza del progetto

### US-15 - Verificare i vincoli strutturali del progetto

**Come** docente progettista  
**voglio** vedere se il progetto rispetta i vincoli strutturali previsti  
**cosi' da** sapere se la mia proposta e' completa.

**Criteri di accettazione**
1. Il sistema mostra almeno il numero di ambienti previsti e il numero di ambienti censiti.
2. Per i progetti di tipo campus il sistema mostra anche il numero minimo di partecipanti e i partecipanti attualmente registrati.
3. Il sistema segnala se i vincoli strutturali risultano rispettati oppure no.

### US-16 - Evidenziare le carenze del progetto

**Come** docente progettista  
**voglio** essere avvisato se mancano ambienti, moduli o partecipanti richiesti  
**cosi' da** correggere la progettazione prima della chiusura.

**Criteri di accettazione**
1. Il sistema evidenzia i vincoli non soddisfatti nella scheda progetto.
2. Per ogni anomalia il sistema mostra un messaggio comprensibile, ad esempio ambiente mancante o partecipanti insufficienti.
3. Le anomalie si aggiornano quando l'utente modifica dati rilevanti del progetto.

### US-17 - Ottenere una sintesi finale del progetto

**Come** docente progettista  
**voglio** vedere una sintesi finale del progetto con laboratori, moduli, beni e costi  
**cosi' da** condividere una proposta leggibile e verificabile.

**Criteri di accettazione**
1. Il sistema mostra una vista sintetica per progetto.
2. La sintesi include almeno numero laboratori, numero moduli, totale beni e budget complessivo.
3. La sintesi rende visibile anche l'esito dei controlli strutturali del progetto.

## Note di modellazione implicate dalle user story

1. Le user story sui beni in comodato d'uso implicano l'introduzione di attributi o entita' aggiuntive per distinguere la destinazione del bene.
2. Le user story sui progetti campus presuppongono l'uso delle entita' `Progetto`, `Campus`, `TipoAggregazione` e `CampusPartecipante`.
3. Le user story sui controlli strutturali si appoggiano a viste o query di sintesi analoghe a `SintesiProgetto` e `VerificaVincoliProgetto`.
