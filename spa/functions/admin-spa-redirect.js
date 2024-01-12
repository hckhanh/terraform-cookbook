
function handler(event) {
  const request = event.request
  const uri = request.uri

  // Check if this is a route
  if (!uri.includes('.')) {
    request.uri = '/index.html'
  }

  return request
}
