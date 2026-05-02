import type { GenericRecord, RecordListResponse } from './types'

const API_BASE = (import.meta.env.VITE_API_BASE as string | undefined) ?? '/api.php'

const buildUrl = (path: string, params?: Record<string, string>) => {
	const url = new URL(`${API_BASE}${path}`, window.location.origin)
	if (params) {
		for (const [key, value] of Object.entries(params)) {
			url.searchParams.set(key, value)
		}
	}
	return url
}

async function request<T>(path: string, init?: RequestInit, params?: Record<string, string>): Promise<T> {
	const response = await fetch(buildUrl(path, params), {
		headers: {
			'Content-Type': 'application/json',
			...(init?.headers ?? {})
		},
		...init
	})

	if (!response.ok) {
		const message = await response.text()
		throw new Error(message || `HTTP ${response.status}`)
	}

	if (response.status === 204) {
		return undefined as T
	}

	return (await response.json()) as T
}

export async function listRecords(table: string, params?: Record<string, string>) {
	const query = {
		order: 'id,asc',
		size: '500',
		...params
	}
	return request<RecordListResponse<GenericRecord>>(`/records/${table}`, { method: 'GET' }, query)
}

export async function createRecord(table: string, payload: GenericRecord) {
	return request<number>(`/records/${table}`, {
		method: 'POST',
		body: JSON.stringify(payload)
	})
}

export async function updateRecord(table: string, id: string | number, payload: GenericRecord) {
	return request<number>(`/records/${table}/${id}`, {
		method: 'PUT',
		body: JSON.stringify(payload)
	})
}

export async function deleteRecord(table: string, id: string | number) {
	return request<number>(`/records/${table}/${id}`, { method: 'DELETE' })
}

export { API_BASE }

