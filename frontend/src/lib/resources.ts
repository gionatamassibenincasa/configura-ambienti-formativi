import type { ResourceDefinition } from './types'

export const resources: ResourceDefinition[] = [
	{
		key: 'Ordinamento',
		table: 'Ordinamento',
		title: 'Ordinamenti',
		description: 'Macro-tipologie del percorso di studi.',
		fields: [
			{ key: 'ordinamento', label: 'Ordinamento', type: 'text', required: true },
			{ key: 'descrizione', label: 'Descrizione', type: 'textarea' }
		]
	},
	{
		key: 'Corso',
		table: 'Corso',
		title: 'Corsi',
		description: 'Corsi associati agli ordinamenti.',
		fields: [
			{ key: 'idOrdinamento', label: 'Ordinamento', type: 'select', lookup: 'Ordinamento', optionLabel: 'ordinamento', required: true },
			{ key: 'corso', label: 'Corso', type: 'text', required: true },
			{ key: 'descrizione', label: 'Descrizione', type: 'textarea' }
		]
	},
	{
		key: 'Indirizzo',
		table: 'Indirizzo',
		title: 'Indirizzi',
		description: 'Indirizzi dei corsi di studio.',
		fields: [
			{ key: 'idCorso', label: 'Corso', type: 'select', lookup: 'Corso', optionLabel: 'corso', required: true },
			{ key: 'indirizzo', label: 'Indirizzo', type: 'text', required: true },
			{ key: 'descrizione', label: 'Descrizione', type: 'textarea' }
		]
	},
	{
		key: 'Articolazione',
		table: 'Articolazione',
		title: 'Articolazioni',
		description: 'Sotto-articolazioni opzionali degli indirizzi.',
		fields: [
			{ key: 'idIndirizzo', label: 'Indirizzo', type: 'select', lookup: 'Indirizzo', optionLabel: 'indirizzo', required: true },
			{ key: 'articolazione', label: 'Articolazione', type: 'text', required: true }
		]
	},
	{
		key: 'Curriculum',
		table: 'Curriculum',
		title: 'Curricoli',
		description: 'Curricoli di riferimento per i target formativi.',
		fields: [
			{ key: 'codice', label: 'Codice', type: 'text', required: true },
			{ key: 'idIndirizzo', label: 'Indirizzo', type: 'select', lookup: 'Indirizzo', optionLabel: 'indirizzo', required: true },
			{ key: 'idArticolazione', label: 'Articolazione', type: 'select', lookup: 'Articolazione', optionLabel: 'articolazione' },
			{ key: 'curriculum', label: 'Curriculum', type: 'text', required: true }
		]
	},
	{
		key: 'Istituto',
		table: 'Istituto',
		title: 'Istituti',
		description: 'Istituzioni scolastiche servite dal progetto.',
		fields: [
			{ key: 'istituto', label: 'Istituto', type: 'text', required: true },
			{ key: 'comune', label: 'Comune', type: 'text' }
		]
	},
	{
		key: 'Target',
		table: 'Target',
		title: 'Target formativi',
		description: 'Incrocio tra curriculum e istituto.',
		fields: [
			{ key: 'idCurriculum', label: 'Curriculum', type: 'select', lookup: 'Curriculum', optionLabel: 'curriculum', required: true },
			{ key: 'idIstituto', label: 'Istituto', type: 'select', lookup: 'Istituto', optionLabel: 'istituto', required: true },
			{ key: 'abbreviazione', label: 'Abbreviazione', type: 'text', required: true },
			{ key: 'target', label: 'Target', type: 'text', required: true }
		]
	},
	{
		key: 'Plesso',
		table: 'Plesso',
		title: 'Plessi',
		description: 'Sedi fisiche degli istituti.',
		fields: [
			{ key: 'idIstituto', label: 'Istituto', type: 'select', lookup: 'Istituto', optionLabel: 'istituto', required: true },
			{ key: 'plesso', label: 'Plesso', type: 'text', required: true },
			{ key: 'indirizzo', label: 'Indirizzo', type: 'text' }
		]
	},
	{
		key: 'Finanziamento',
		table: 'Finanziamento',
		title: 'Finanziamenti',
		description: 'Fonti di finanziamento dei progetti.',
		fields: [
			{ key: 'tipo', label: 'Tipo', type: 'text', required: true },
			{ key: 'denominazione', label: 'Denominazione', type: 'text', required: true },
			{ key: 'urlAvviso', label: 'URL avviso', type: 'url' },
			{ key: 'importo', label: 'Importo', type: 'number', required: true, step: '0.01', min: 0 }
		]
	},
	{
		key: 'Progetto',
		table: 'Progetto',
		title: 'Progetti',
		description: 'Contenitore progettuale associato a finanziamento e istituto capofila.',
		fields: [
			{ key: 'idFinanziamento', label: 'Finanziamento', type: 'select', lookup: 'Finanziamento', optionLabel: 'denominazione', required: true },
			{ key: 'idIstitutoCapofila', label: 'Istituto capofila', type: 'select', lookup: 'Istituto', optionLabel: 'istituto', required: true },
			{ key: 'codice', label: 'Codice progetto', type: 'text', required: true },
			{ key: 'progetto', label: 'Progetto', type: 'text', required: true },
			{ key: 'tipologia', label: 'Tipologia', type: 'text', required: true },
			{ key: 'descrizione', label: 'Descrizione', type: 'textarea' },
			{ key: 'ambientiMinimi', label: 'Ambienti minimi', type: 'number', required: true, min: 1 },
			{ key: 'partecipantiMinimi', label: 'Partecipanti minimi', type: 'number', required: true, min: 1 }
		]
	},
	{
		key: 'TipoAggregazione',
		table: 'TipoAggregazione',
		title: 'Tipi aggregazione',
		description: 'Classifica il campus come partenariato o rete.',
		fields: [
			{ key: 'tipoAggregazione', label: 'Tipo aggregazione', type: 'text', required: true },
			{ key: 'descrizione', label: 'Descrizione', type: 'textarea' }
		]
	},
	{
		key: 'Campus',
		table: 'Campus',
		title: 'Campus',
		description: 'Campus opzionale associato a un progetto.',
		fields: [
			{ key: 'idProgetto', label: 'Progetto', type: 'select', lookup: 'Progetto', optionLabel: 'progetto', required: true },
			{ key: 'idTipoAggregazione', label: 'Tipo aggregazione', type: 'select', lookup: 'TipoAggregazione', optionLabel: 'tipoAggregazione', required: true },
			{ key: 'campus', label: 'Campus', type: 'text', required: true },
			{ key: 'descrizione', label: 'Descrizione', type: 'textarea' }
		]
	},
	{
		key: 'CampusPartecipante',
		table: 'CampusPartecipante',
		title: 'Partecipanti campus',
		description: 'Istituti partecipanti al campus oltre al capofila.',
		fields: [
			{ key: 'idCampus', label: 'Campus', type: 'select', lookup: 'Campus', optionLabel: 'campus', required: true },
			{ key: 'idIstituto', label: 'Istituto', type: 'select', lookup: 'Istituto', optionLabel: 'istituto', required: true },
			{ key: 'ruolo', label: 'Ruolo', type: 'text' }
		]
	},
	{
		key: 'Laboratorio',
		table: 'Laboratorio',
		title: 'Laboratori',
		description: 'Ambienti progettati e associati a plesso e progetto.',
		fields: [
			{ key: 'idPlesso', label: 'Plesso', type: 'select', lookup: 'Plesso', optionLabel: 'plesso', required: true },
			{ key: 'idProgetto', label: 'Progetto', type: 'select', lookup: 'Progetto', optionLabel: 'progetto', required: true },
			{ key: 'laboratorio', label: 'Laboratorio', type: 'text', required: true },
			{ key: 'aula', label: 'Aula', type: 'text' },
			{ key: 'descrizione', label: 'Descrizione', type: 'textarea' }
		]
	},
	{
		key: 'TipoObiettivo',
		table: 'TipoObiettivo',
		title: 'Tipi obiettivo',
		description: 'Classificazione degli obiettivi formativi.',
		fields: [
			{ key: 'tipoObiettivo', label: 'Tipo obiettivo', type: 'text', required: true },
			{ key: 'descrizione', label: 'Descrizione', type: 'textarea' }
		]
	},
	{
		key: 'Obiettivo',
		table: 'Obiettivo',
		title: 'Obiettivi',
		description: 'Obiettivi generali e specifici.',
		fields: [
			{ key: 'idTipoObiettivo', label: 'Tipo', type: 'select', lookup: 'TipoObiettivo', optionLabel: 'tipoObiettivo', required: true },
			{ key: 'obiettivo', label: 'Obiettivo', type: 'textarea', required: true }
		]
	},
	{
		key: 'Modulo',
		table: 'Modulo',
		title: 'Moduli',
		description: 'Moduli didattici associati a laboratori e target.',
		fields: [
			{ key: 'idLaboratorio', label: 'Laboratorio', type: 'select', lookup: 'Laboratorio', optionLabel: 'laboratorio', required: true },
			{ key: 'idTarget', label: 'Target', type: 'select', lookup: 'Target', optionLabel: 'abbreviazione', required: true },
			{ key: 'modulo', label: 'Modulo', type: 'text', required: true },
			{ key: 'descrizione', label: 'Descrizione', type: 'textarea' },
			{ key: 'discipline', label: 'Discipline', type: 'text' },
			{ key: 'professione', label: 'Profilo professionale', type: 'text' }
		]
	},
	{
		key: 'ObiettiviModulo',
		table: 'ObiettiviModulo',
		title: 'Associazioni modulo-obiettivo',
		description: 'Mappa gli obiettivi ai moduli con priorita.',
		fields: [
			{ key: 'idModulo', label: 'Modulo', type: 'select', lookup: 'Modulo', optionLabel: 'modulo', required: true },
			{ key: 'idObiettivo', label: 'Obiettivo', type: 'select', lookup: 'Obiettivo', optionLabel: 'obiettivo', required: true },
			{ key: 'priorita', label: 'Priorita', type: 'number', required: true, min: 1 }
		]
	},
	{
		key: 'Fornitore',
		table: 'Fornitore',
		title: 'Fornitori',
		description: 'Operatori economici disponibili.',
		fields: [
			{ key: 'fornitore', label: 'Fornitore', type: 'text', required: true },
			{ key: 'PIVA', label: 'P. IVA', type: 'text' },
			{ key: 'indirizzo', label: 'Indirizzo', type: 'text' },
			{ key: 'telefono', label: 'Telefono', type: 'text' }
		]
	},
	{
		key: 'TipoFornitura',
		table: 'TipoFornitura',
		title: 'Tipi fornitura',
		description: 'Classificazione delle forniture.',
		fields: [{ key: 'tipoFornitura', label: 'Tipo fornitura', type: 'text', required: true }]
	},
	{
		key: 'Fornitura',
		table: 'Fornitura',
		title: 'Forniture',
		description: 'Beni e servizi acquistabili.',
		fields: [
			{ key: 'idTipoFornitura', label: 'Tipo fornitura', type: 'select', lookup: 'TipoFornitura', optionLabel: 'tipoFornitura', required: true },
			{ key: 'idFornitore', label: 'Fornitore', type: 'select', lookup: 'Fornitore', optionLabel: 'fornitore', required: true },
			{ key: 'fornitura', label: 'Fornitura', type: 'text', required: true },
			{ key: 'prezzo', label: 'Prezzo', type: 'number', required: true, step: '0.01', min: 0 },
			{ key: 'codiceMepa', label: 'Codice MEPA', type: 'text' },
			{ key: 'link', label: 'Link', type: 'url' },
			{ key: 'SKU', label: 'SKU', type: 'text' },
			{ key: 'note', label: 'Note', type: 'textarea' }
		]
	},
	{
		key: 'Voce',
		table: 'Voce',
		title: 'Voci di spesa',
		description: 'Voci del quadro economico.',
		fields: [
			{ key: 'lettera', label: 'Lettera', type: 'text', required: true },
			{ key: 'voce', label: 'Voce', type: 'text', required: true },
			{ key: 'descrizione', label: 'Descrizione', type: 'textarea' },
			{ key: 'minimale', label: 'Minimale', type: 'number', required: true, min: 0 },
			{ key: 'massimale', label: 'Massimale', type: 'number', required: true, min: 0 }
		]
	},
	{
		key: 'Costo',
		table: 'Costo',
		title: 'Costi',
		description: 'Associazione tra laboratorio, fornitura e voce di spesa.',
		fields: [
			{ key: 'idVoce', label: 'Voce', type: 'select', lookup: 'Voce', optionLabel: 'voce', required: true },
			{ key: 'idLaboratorio', label: 'Laboratorio', type: 'select', lookup: 'Laboratorio', optionLabel: 'laboratorio', required: true },
			{ key: 'idFornitura', label: 'Fornitura', type: 'select', lookup: 'Fornitura', optionLabel: 'fornitura', required: true },
			{ key: 'descrizione', label: 'Descrizione', type: 'textarea' },
			{ key: 'quantita', label: 'Quantita', type: 'number', required: true, min: 1 }
		]
	}
]

export const resourceGroups = [
	{
		title: 'Catalogo scolastico',
		keys: ['Ordinamento', 'Corso', 'Indirizzo', 'Articolazione', 'Curriculum', 'Istituto', 'Target', 'Plesso']
	},
	{
		title: 'Progettazione',
		keys: ['Finanziamento', 'Progetto', 'TipoAggregazione', 'Campus', 'CampusPartecipante', 'Laboratorio', 'TipoObiettivo', 'Obiettivo', 'Modulo', 'ObiettiviModulo']
	},
	{
		title: 'Acquisti',
		keys: ['Fornitore', 'TipoFornitura', 'Fornitura', 'Voce', 'Costo']
	}
]
