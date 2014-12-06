express = require 'express.io'
# http = require 'http'
# consolidate = require 'consolidate'
ECT = require 'ect' 
ectRenderer = ECT { watch: true, root: "#{__dirname}/views" }

# moment = require 'moment'
# moment.lang("es")
app = express()
app.http().io()

#config express.
app.set 'port', process.env.PORT or 6969
app.set 'views', "#{__dirname}/views"
app.engine '.ect', ectRenderer.render
# app.engine 'ect', consolidate.ect
app.set 'view engine', 'ect'
# use middlewares express.
app.use express.static("#{__dirname}/public")
# para ler los campos POST.
# app.use(express.bodyParser()) equivale alas siguientes 3 lineas.
app.use(express.json());
app.use(express.urlencoded());
# app.use(express.multipart());

app.use(express.cookieParser())
app.use express.session(secret: '023197422617bce43335cbd3c675aeed')
app.use express.logger('dev')

# CONFIG DB.
mongoose = require('mongoose')
# mongoose.connect('mongodb://localhost/corprotecdb')

# mongoose.connect('mongodb://nodejitsu:corprotecc9cb1dc9b0c087dc02be43eb871f3dc4@troup.mongohq.com:10031/nodejitsudb3765217105')
mongoose.connect('mongodb://chelo:corprotec@ds061360.mongolab.com:61360/corprotec')
#ALL ROUTES.
# require('./routes')(app, mongoose)
#START SERVER.
# app.listen app.get('port'), ->
# 	console.log "servidor escuchando en: #{app.get 'port'}"


require("jsreport").bootstrapper({
	express : { 
		app : app
	}
}).start().then (bootstrapp)->
	app.reporter = bootstrapp.reporter 
	# console.log app
	require('./routes')(app, mongoose)
	app.listen app.get('port'), ->
		console.log "servidor escuchando en: #{app.get 'port'}"



