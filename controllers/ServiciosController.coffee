class ServiciosController
	clientesContrato:['MADEPA', 'COBEE']
	constructor:(moongose, app)->
		# models for working in this controller.
		# @ComprasModel = require('../models/ComprasModel')(moongose)
		@ServiciosModel = require('../models/ServiciosModel')(moongose)
		@ClientesModel = require('../models/ClientesModel')(moongose)
		# @moment = require('moment')
		@app = app
		
	getAll:(req, resp)=>			#primera compra	
		@ServiciosModel.find({ cliente: { $not: { $in: @clientesContrato } } }).sort('fecha').exec (err, servicios)=>
		# @ServiciosModel.find().sort('fecha').exec (err, servicios)=>
			respData = {}
			respData.data = servicios
			resp.jsonp respData
	create:(req, resp)=>
		servicio = new @ServiciosModel req.data.servicio
		servicio.save (err, servicio)=>
			if err
				req.data.msg = {tipo:'error', titulo:'Error', texto:"No se pudo crear el servicio."}
				@app.io.broadcast('servicios:create', req.data)
			else
				@ClientesModel.findOne {nombre:req.data.servicio.cliente}, (err, cliente)=>
					if cliente
						req.data.existCliente = true
						req.data.msg = {tipo:'exito', titulo:'Ok', texto:"Servicio Anadido."}
						@app.io.broadcast('servicios:create', req.data)
					else
						req.data.existCliente = false
						unCliente = new @ClientesModel {nombre:req.data.servicio.cliente}
						unCliente.save (err, unCliente)=>
						req.data.msg = {tipo:'exito', titulo:'Ok', texto:"Servicio Anadido."}
						@app.io.broadcast('servicios:create', req.data)
	delete:(req, resp)=>
		@ServiciosModel.findById req.data.id, (err, servicio)=>
			if servicio 
				servicio.remove (err, user)=>
					req.data.msg = {tipo:'exito', titulo:'Ok', texto:'servicio Eliminado.'}
					# console.log req.data
					@app.io.broadcast('servicios:delete', req.data)#enviar al cliente.
	cobrar:(req, resp)=>
		@ServiciosModel.findById req.data.id, (err, servicio)=>
			if servicio 
				servicio.cobro = 'cancelado'
				servicio.monto = req.data.monto
				servicio.fecha_cancel = new Date()
				servicio.save (err, servicio)=>
					if err
						console.log  err
					# console.log 'cobrado '+ servicio
				req.data.msg = {tipo:'exito', titulo:'Ok', texto:"Servicio Cobrado."}
				@app.io.broadcast('servicios:cobrar', req.data)

	editar:(req, resp)=>
		@ServiciosModel.findById req.data.id, (err, servicio)=>
			if servicio 
				servicio.fecha = req.data.servicio.fecha
				servicio.cliente = req.data.servicio.cliente
				servicio.descripcion = req.data.servicio.descripcion
				servicio.cobro = req.data.servicio.cobro 
				servicio.monto = req.data.servicio.monto
				servicio.fecha_cancel = req.data.servicio.fecha_cancel
				servicio.save (err, servicio)=>
				req.data.msg = {tipo:'exito', titulo:'Ok', texto:"Registro Modigficado."}
				@app.io.broadcast('servicios:editar', req.data)


module.exports = (moongose, app)->	new ServiciosController(moongose, app)
