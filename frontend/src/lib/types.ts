export type FieldType = 'text' | 'textarea' | 'number' | 'url' | 'select'

export interface FieldDefinition {
	key: string
	label: string
	type: FieldType
	required?: boolean
	lookup?: string
	optionLabel?: string
	optionValue?: string
	placeholder?: string
	step?: string
	min?: number
}

export interface ResourceDefinition {
	key: string
	table: string
	title: string
	description: string
	fields: FieldDefinition[]
}

export interface RecordListResponse<T> {
	records: T[]
	results?: number
}

export type GenericRecord = Record<string, string | number | null>

export interface SessionUser {
	id: number
	username: string
	nome: string
	roles: string[]
	isAdmin: boolean
}

export interface SessionResponse {
	authenticated: boolean
	user: SessionUser | null
}

export interface ProjectSummary {
	idProgetto: number
	idIstitutoCapofila: number
	codice: string
	progetto: string
	tipologia: string
	istitutoCapofila: string
	tipoFinanziamento: string
	finanziamento: string
	idCampus: number | null
	campus: string | null
	tipoAggregazione: string | null
	ambientiMinimi: number
	partecipantiMinimi: number
	ambienti: number
	moduli: number
	partecipantiTotali: number
	budgetAllocato: string | number
	vincoloCampusRispettato: number
	vincoloAmbientiRispettato: number
	vincoloPartecipantiRispettato: number
	vincoliRispettati: number
}

export interface ProjectLaboratory {
	id: number
	idPlesso: number
	laboratorio: string
	aula: string | null
	descrizione: string | null
	plesso: string
	indirizzo: string | null
	costoTotale: string | number
}

export interface ProjectModule {
	id: number
	idLaboratorio: number
	idTarget: number
	modulo: string
	descrizione: string | null
	discipline: string | null
	professione: string | null
	laboratorio: string
	target: string
	obiettiviCount: number
}

export interface ProjectModuleObjective {
	id: number
	idModulo: number
	idObiettivo: number
	priorita: number
	obiettivo: string
	tipoObiettivo: string
}

export interface ProjectDetailResponse {
	project: ProjectSummary
	laboratori: ProjectLaboratory[]
	moduli: ProjectModule[]
	obiettiviModulo: ProjectModuleObjective[]
}

export interface LookupOption {
	id: number
	label: string
}

export interface ProjectLookupsResponse {
	finanziamenti: LookupOption[]
	istituti: LookupOption[]
	plessi: LookupOption[]
	target: LookupOption[]
	curriculum: LookupOption[]
	obiettivi: LookupOption[]
}

export interface FinancingCreatePayload {
	tipo: string
	denominazione: string
	urlAvviso: string | null
	importo: number
}

export interface ProjectCreatePayload {
	idFinanziamento: number | null
	idIstitutoCapofila: number
	codice: string
	progetto: string
	tipologia: string
	descrizione: string | null
	ambientiMinimi: number
	partecipantiMinimi: number
	nuovoFinanziamento?: FinancingCreatePayload | null
}
