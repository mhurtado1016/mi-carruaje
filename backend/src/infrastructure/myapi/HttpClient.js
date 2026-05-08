/**
 * Thin HTTP wrapper around Node 18+ native fetch.
 * Configure base URL and optional static API key via constructor.
 * Each repository receives one instance and calls get/post/patch/delete.
 */
class HttpClient {
  /**
   * @param {string} baseUrl  - e.g. "https://api.example.com/v1"
   * @param {string} [apiKey] - sent as Bearer token if provided
   */
  constructor(baseUrl, apiKey) {
    this.baseUrl = baseUrl.replace(/\/$/, '');
    this.apiKey  = apiKey || null;
  }

  _headers(extra = {}) {
    const headers = { 'Content-Type': 'application/json', ...extra };
    if (this.apiKey) headers['Authorization'] = `Bearer ${this.apiKey}`;
    return headers;
  }

  async _request(method, path, body) {
    const url  = `${this.baseUrl}${path}`;
    const init = { method, headers: this._headers() };
    if (body !== undefined) init.body = JSON.stringify(body);

    const res = await fetch(url, init);

    if (!res.ok) {
      const text = await res.text().catch(() => res.statusText);
      const err  = new Error(`HTTP ${res.status} ${method} ${path}: ${text}`);
      err.status = res.status;
      throw err;
    }

    if (res.status === 204) return null;
    return res.json();
  }

  get(path)          { return this._request('GET',    path);        }
  post(path, body)   { return this._request('POST',   path, body);  }
  patch(path, body)  { return this._request('PATCH',  path, body);  }
  put(path, body)    { return this._request('PUT',    path, body);  }
  delete(path, body) { return this._request('DELETE', path, body);  }
}

module.exports = HttpClient;
