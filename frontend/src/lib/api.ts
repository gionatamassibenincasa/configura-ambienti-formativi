import type {
	GenericRecord,
	ProjectCreatePayload,
	ProjectDetailResponse,
	ProjectLookupsResponse,
	ProjectSummary,
	RecordListResponse,
	SessionResponse
} from './types'

const API_BASE = (import.meta.env.VITE_API_BASE as string | undefined) ?? '/api.php'
const AUTH_BASE = (import.meta.env.VITE_AUTH_BASE as string | undefined) ?? '/auth.php'
const PROJECTS_BASE = (import.meta.env.VITE_PROJECTS_BASE as string | undefined) ?? '/projects.php'

const buildUrl = (base: string, path = '', params?: Record<string, string>) => {
	const url = new URL(`${base}${path}`, window.location.origin)
	if (params) {
		for (const [key, value] of Object.entries(params)) {
			url.searchParams.set(key, value)
		}
	}
	return url
}

async function request<T>(base: string, path = '', init?: RequestInit, params?: Record<string, string>): Promise<T> {
	const response = await fetch(buildUrl(base, path, params), {
		credentials: 'include',
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
	return request<RecordListResponse<GenericRecord>>(API_BASE, `/records/${table}`, { method: 'GET' }, query)
}

export async function createRecord(table: string, payload: GenericRecord) {
	return request<number>(API_BASE, `/records/${table}`, {
		method: 'POST',
		body: JSON.stringify(payload)
	})
}

export async function updateRecord(table: string, id: string | number, payload: GenericRecord) {
	return request<number>(API_BASE, `/records/${table}/${id}`, {
		method: 'PUT',
		body: JSON.stringify(payload)
	})
}

export async function deleteRecord(table: string, id: string | number) {
	return request<number>(API_BASE, `/records/${table}/${id}`, { method: 'DELETE' })
}

export async function getSession() {
	return request<SessionResponse>(AUTH_BASE, '', { method: 'GET' })
}

export async function login(username: string, password: string) {
	return request<SessionResponse>(AUTH_BASE, '', {
		method: 'POST',
		body: JSON.stringify({ username, password })
	})
}

export async function logout() {
	return request<SessionResponse>(AUTH_BASE, '', { method: 'DELETE' })
}

export async function listProjects() {
	return request<RecordListResponse<ProjectSummary>>(PROJECTS_BASE, '', { method: 'GET' })
}

export async function getProjectDetail(projectId: number) {
	return request<ProjectDetailResponse>(PROJECTS_BASE, '', { method: 'GET' }, { id: String(projectId) })
}

export async function getProjectLookups() {
	return request<ProjectLookupsResponse>(PROJECTS_BASE, '', { method: 'GET' }, { lookups: '1' })
}

export async function createProject(payload: ProjectCreatePayload) {
	return request<{ project: ProjectSummary }>(PROJECTS_BASE, '', {
		method: 'POST',
		body: JSON.stringify(payload)
	})
}

export { API_BASE }
