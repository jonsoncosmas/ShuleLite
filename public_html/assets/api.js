(() => {
  async function request(url, options = {}) {
    let response;
    try {
      response = await fetch(url, { credentials: 'same-origin', ...options });
    } catch {
      throw new Error('Connection interrupted. Check your network and try again.');
    }
    const contentType = response.headers.get('content-type') || '';
    if (!contentType.includes('application/json')) {
      if (response.redirected && /login\.php/.test(response.url)) {
        window.location.assign(response.url);
        throw new Error('Your session expired. Sign in again.');
      }
      throw new Error(response.redirected ? 'Your session expired. Sign in again.' : 'The server returned an unexpected response. Refresh the page and try again.');
    }
    const result = await response.json();
    if (!response.ok || result.ok !== true) throw new Error(result.message || 'The request could not be completed.');
    return result;
  }
  async function post(url, form, csrf) {
    return request(url, { method: 'POST', body: form, headers: { Accept: 'application/json', 'X-CSRF-Token': csrf } });
  }
  window.ShuleApi = Object.freeze({ request, post });
})();
