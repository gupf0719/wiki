var http = require('http')
  , exec = require('exec')

const PORT = 3000
  , BASE_PATH = '~/'

var deployServer = http.createServer(function(request, response) {
  if (request.url.search(/deploy\/.*/i) > 0) {
        var object_url = request.url.split("/")[2]
    var commands = [
      'cd ' + BASE_PATH + object_url,
      'git pull origin master',
      'sudo rm -rf /var/www/html/*',
      'suco cp ~/GTD/* /var/www/html/',
      'sudo /etc/init.d/apache2 restart'
    ].join(' && ')

    exec(commands, function(err, out, code) {
      if (err instanceof Error) {
        response.writeHead(500)
        response.end('Server Internal Error.')
        throw err
      }

      process.stderr.write(err)
      process.stdout.write(out)
      response.writeHead(200)
      response.end('Deploy Done.')

    })

  } else {

    response.writeHead(404)
    response.end('Not Found.')

  }
})

deployServer.listen(PORT)