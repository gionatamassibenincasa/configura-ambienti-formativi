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

