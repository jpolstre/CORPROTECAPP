
# ALL ROUTES.
module.exports = (app, moongose)->
	# console.log 'INGRESANDO AQUI' + app
	UsersController = require('./controllers/UserController')(moongose, app)
	ComprasController = require('./controllers/ComprasController')(moongose, app)
	ProductosController = require('./controllers/ProductosController')(moongose, app)
	VentasController = require('./controllers/VentasController')(moongose, app)
	ReportesController = require('./controllers/ReportesController')(moongose, app)
	ServiciosController = require('./controllers/ServiciosController')(moongose, app)
	ConfigController = require('./controllers/ConfigController')(moongose, app)
	
	EstadisticasController = require('./controllers/EstadisticasController')(moongose, app)

	# moongose.connection.on "open", ->
	# 	console.log("Connection opened to mongodb at")	

	# moongose.connection.on "connecting", ->
	# 	console.log("un usuario se ha conectado")
	
	# ROUTE FOR LOG PAGE.
	isAut = (req, res, next)->
		if req.session.aut
			# console.log '2'
			next()  
		else
			res.redirect '/'
			# console.log '1' 

	app.get '/', (req, resp)->
		if req.session.aut
			console.log 'hay session'
			name = req.session.dataUser.name
		else
			console.log 'no hay session'
			name = 'undefined'

		# req.session.aut = false
		# name = req.session.dataUser
		req.session.destroy (err)->
			console.log err if err
		resp.render 'pages/login', {title:'Log', name:name}
	
	# ROUTES FOR PAGES/
	app.get '/pages/:page', isAut, (req, resp)->
		# console.log req.session
		resp.header('Cache-Control', 'private, no-cache, no-store, must-revalidate')
		resp.header('Expires', '-1')
		resp.header('Pragma', 'no-cache')
		page = req.params.page
		resp.render "pages/#{page}", {page:page, dataUser:req.session.dataUser}

	# ROUTES FOR USER.
	app.post '/users/login', UsersController.doLogin
	app.get '/users/getAll', UsersController.getAll
	app.get '/users/getUsersOn', UsersController.getUsersOn
	app.get '/newuser/:name/:password/:estado?/:privilegios?', UsersController.newUser

	#rutas y acciones(io) (route:accion) desde el cliente.
	app.io.route 'users',
		create:UsersController.create
		delete:UsersController.delete
		edit:UsersController.edit
		userIn:UsersController.userIn
		userOut:UsersController.userOut
		addComment:UsersController.addComment
		
	# COMPRAS.
	app.get '/compras/prodReg', ComprasController.prodReg
	app.get '/newcompra/:serie/:codigo/:descripcion/:costo/:cantidad/:utilidad/:garantia/:proveedor', ComprasController.newCompra
	app.get '/compras/getAll', ComprasController.getAll
	
	#rutas y acciones(io) (route:accion) desde el cliente.
	app.io.route 'compras',
		shopp:ComprasController.shopp
		delete:ComprasController.delete
		edit:ComprasController.edit
		shopping:ComprasController.shopping

	# PRODUCTOS.
	app.get '/productos/getAll', ProductosController.getAll

	# VENTAS.
	app.io.route 'ventas',
		addToCart:VentasController.addToCart
		delToCart:VentasController.delToCart
		cancelShopp:VentasController.cancelShopp
		shopp:VentasController.shopp
		deleteRestore:VentasController.deleteRestore
		cobrar:VentasController.cobrar
		delete:VentasController.delete

	app.get '/ventas/getAll', VentasController.getAll

	#SERVICIOS.
	app.get '/servicios/getAll', ServiciosController.getAll

	app.io.route 'servicios',
		create:ServiciosController.create
		delete:ServiciosController.delete
		cobrar:ServiciosController.cobrar
		editar:ServiciosController.editar

	#TEST ROUTES.
	app.get '/pdf', (req, resp)->
		resp.render 'pdf'

	# app.get '/reportes/:tipo/:modelo/:querySelect/:querySort/:textFilter?', ReportesController.generarReporte
	app.post '/reportes/makeReport', ReportesController.makeReport
	app.get '/reportes/makeReport2', ReportesController.makeReport2
	app.get '/reportes/viewReport', ReportesController.viewReport	
	app.get '/reportes/viewRecibo', ReportesController.viewRecibo	
	app.post '/reportes/makeRecibo', ReportesController.makeRecibo	

	# estadisticas
	app.get '/estadisticas/estadisticaVentas', EstadisticasController.estadisticaVentas	
	app.get '/estadisticas/estadisticaCompras', EstadisticasController.estadisticaCompras	
	app.get '/reportes/viewMayorCompradorPdf', ReportesController.viewMayorCompradorPdf	

	#configuraciones.
	app.get '/config/dropDB', ConfigController.dropDB	
