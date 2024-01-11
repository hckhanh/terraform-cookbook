const routes = /^\/(dashboard|login|password)|\/$/

function handler(event) {
  const request = event.request
  const uri = request.uri

  // Prevent mobile requests
  const isMobileViewer = request.headers['cloudfront-is-mobile-viewer']
  if (isMobileViewer && isMobileViewer.value === 'true') {
    return {
      statusCode: 307,
      statusDescription: 'Temporary Redirect',
      headers: {
        'content-type': { value: 'text/html' },
        location: { value: 'https://www.saladin.vn' },
      },
    }
  }

  // Check if this is a admin route
  if (routes.test(uri) || !uri.includes('.')) {
    request.uri = '/index.html'
  }

  return request
}
