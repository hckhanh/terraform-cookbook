function handler(event) {
  const response = event.response
  const headers = response.headers
  const contentType = headers['content-type']

  if (
    contentType &&
    contentType.value === 'text/html' &&
    response.statusCode !== 403
  ) {
    headers['document-policy'] = { value: 'js-profiling' }
  }

  return response
}
