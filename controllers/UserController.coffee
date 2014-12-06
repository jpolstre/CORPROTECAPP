
class UserController
	_ : require("underscore")
	nameUser:''

	constructor:(moongose, app)->
		# models for working in this controller.
		@UserModel = require('../models/UserModel')(moongose)
		@ClienteModel = require('../models/ClientesModel')(moongose)
		@ProveedoresModel = require('../models/ProveedoresModel')(moongose)
		# @CodProdModel = require('../models/CodProdModel')(moongose)
		# @IvaModel = require('../models/IvaModel')(moongose)
		@dataConfigModel = require('../models/dataConfigModel')(moongose)
		
		@app = app
		
		# utils.
		@hash = require('../libs/password')

		# moongose.connection.on "connecting", ->
		# 	console.log("un usuario se ha conectado")

		# moongose.connection.on "close", ->
		# 	console.log("un usuario se ha desconectado")	

		# moongose.connection.on "diconnecting", ->
		# 	console.log("un usuario se ha desconectado")

	getAll:(req, resp)=>
		@UserModel.find({}).select('-password -__v').exec (err, users)=>
			resp.jsonp users
		
	doLogin:(req, resp) =>
		# name = @capitalize req.body.name
		name = req.body.name

		# console.log name
		password = req.body.password
		@UserModel.findOne {name:name}, (err, usuario)=>
			if usuario
				if @hash.validate(usuario.password, password)
					if usuario.estado and usuario.estado is 'Habilitado'
						req.session.aut = true
						req.session.inCart = {}
						req.session.inChat = []
						@nameUser = name
						privilegios = if usuario.privilegios then usuario.privilegios else []#compras, ventas, usuarios
						req.session.dataUser = {name:name, privilegios:privilegios, estado:req.body.estado}
						usuario.conectado = 'on'
						usuario.save (err, usuario)=>
							# console.log usuario.conectado
						# req.session.privilegios = privilegios
						# console.log privilegios
																																																# #{privilegios[0]}
							resp.json {msg:{tipo:'exito', titulo:'Bien', texto:'Ok Ingresando la sistema..!', posicion:'arriba-izquierda'}, url:"pages/main"}##{privilegios[0]}
					else
						resp.json {msg:{tipo:'error', titulo:'Error', texto:'Ud no tiene permisos para ingresar al sistema consulte con el administrador..!', posicion:'arriba-izquierda'} }
				else
					resp.json {msg:{tipo:'error', titulo:'Error', texto: 'Password Incorrecto..!', posicion:'arriba-izquierda'}}
			else
				resp.json {msg:{tipo:'error', titulo:'Error', texto:"No existe este el usuario <strong>#{name}</strong>..!", posicion:'arriba-izquierda'}}

	capitalize:(val)->
		val = val.toLowerCase()
		if 'string' isnt typeof val
			val = ''
		else
			val = val.charAt(0).toUpperCase() + val.substring(1)
		val
	
	edit:(req)=>
		dataUpdate = req.data.newData#del formulario html.
		if dataUpdate.password
			dataUpdate.password = @hash.hash dataUpdate.password
		
		@UserModel.findByIdAndUpdate req.data.id, dataUpdate, (err, user)=>
			if err
				data = {}
				data.msg = {tipo:'error', titulo:'Error', texto:"No se pudo eliminar el usuario"}
				@app.io.broadcast('users:edit', data)#enviar al cliente.
			else
				req.data.msg = {tipo:'exito', titulo:'Bien', texto:"El usuario editado"}
				@app.io.broadcast('users:edit', req.data)#enviar al cliente.

	create:(req)=>
		user = req.data.usuario
		# user.name = @capitalize user.name 
		@UserModel.findOne {name:user.name}, (err, usuario)=>
			if usuario
				req.data.msg = {tipo:'error', titulo:'Error', texto:"el usuario <strong>#{user.name}</strong> ya esta registrado"}
				# console.log respData
				@app.io.broadcast('users:create', req.data)#enviar al cliente.
			else
				user.password = @hash.hash user.password
				unUsuario = new @UserModel user
				unUsuario.save (err, unUsuario)=>
					if err 
						console.error(err)
					else
						req.data.msg = {tipo:'exito', titulo:'Ok', texto:'usuario Creado.'}
						req.data.user = unUsuario
						# console.log respData
						# console.log req.data
					@app.io.broadcast('users:create', req.data)#enviar al cliente.

		# console.log respData
		# @app.io.broadcast('users:create', respData)#enviar al cliente.

	delete:(req)=>
		@UserModel.findById req.data.id, (err, user)=>
			if user 
				user.remove (err, user)=>
					req.data.msg = {tipo:'exito', titulo:'Ok', texto:'Usuario Eliminado.'}
					# console.log req.data
					@app.io.broadcast('users:delete', req.data)#enviar al cliente.

	newUser:(req, resp)=>
		name = req.params.name
		# email = req.params.email
		@UserModel.findOne {name:name}, (err, usuario)=>
			if usuario
					resp.send "El usuario <strong>#{req.params.name}</strong> ya existe"
			else
				req.params.password = @hash.hash req.params.password
				req.params.privilegios = if req.params.privilegios then req.params.privilegios.split ',' else []
				unUsuario = new @UserModel req.params
				unUsuario.save (err, unUsuario)->
					if err 
						console.error(err)
					else
						# console.log unUsuario		
						resp.send 'ok creado'

		# console.log unUsuario
		# resp.send unUsuario
		# console.log @UserModel ok.
		# resp.json @UserModel ok.
	getUsersOn:(req, resp)=>
		@UserModel.find({conectado:'on'}).select('-password -__v').exec (err, usuarios)=>
			resp.jsonp usuarios

	userIn:(req, resp)=>
		@UserModel.find({conectado:'on'}).select('-password -__v').exec (err, usuarios)=>
			req.data.usersIn = usuarios
			if req.data.userAction is @nameUser
				@ClienteModel.find({}).select('nombre').exec (err, clientes)=>
					req.data.clientes = @_.pluck clientes, 'nombre'
					@dataConfigModel.findOne({miId:'uno'}).exec (err, data)=>
						if data
							if data.codigo?
								req.data.codprod = data.codigo
							else
								data.codigo = 0
								req.data.codprod = data.codigo
								data.save (err, data)=>
							
							if data.iva?
								req.data.iva = data.iva
							else
								data.iva = 17
								req.data.iva = data.iva	
								data.save (err, data)=>
							
							if data.NroFactura?
								req.data.NroFactura = data.NroFactura
							else
								data.NroFactura = 0
								req.data.NroFactura = data.NroFactura	
								data.save (err, data)=>
						
							if data.NroRecibo?
								req.data.NroRecibo = data.NroRecibo
							else
								data.NroRecibo = 0
								req.data.NroRecibo = data.NroRecibo	
								data.save (err, data)=>

							console.log req.data
							@app.io.broadcast('users:userIn', req.data)#enviar al cliente.		
						else
							data = new @dataConfigModel { miId:'uno', codigo:0, iva:17, NroFactura:0, NroRecibo:0}
							data.save (err, data)=>
								req.data.codprod = data.codigo	
								req.data.iva = data.iva
								req.data.NroFactura = data.NroFactura
								req.data.NroRecibo = data.NroRecibo
								# console.log req.data
								@app.io.broadcast('users:userIn', req.data)#enviar al cliente.
			else 
				@app.io.broadcast('users:userIn', req.data)#enviar al cliente.
	userOut:(req, resp)=>
		console.log req.data.closeNav
		if req.session.aut#refrescar, y cerrar navegador.
			console.log '1'
			@userIn(req, resp)#uodate chat. refrescar

		else# salir( y cerrar navegador)
			console.log '2 '+req.data.userAction 
			@UserModel.findOne {name:req.data.userAction}, (err, usuario)=>
				if usuario
					usuario.conectado = 'off'
					usuario.save (err, usuario)=>
						@userIn(req, resp)
				else
					console.log 'bad'

	logOut:(req, resp)=>
		@UserModel.findOne {name:req.session.dataUser.name}, (err, usuario)=>
			if usuario
				usuario.conectado = 'off'
				usuario.save (err, usuario)=>
					console.log 'Out'

	addComment:(req, resp)=>
		comment = req.data.comment# {usuario:'chelo', comment:'Hola carlos'}
		# req.session.inChat.push comment
		# req.data.inChat = req.session.inChat
		@app.io.broadcast('users:addComment', req.data)#enviar al cliente.


	
module.exports = (moongose, app)->	new UserController(moongose, app)
