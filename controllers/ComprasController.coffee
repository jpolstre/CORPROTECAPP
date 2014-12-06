class ComprasController
	iva: undefined
	constructor:(moongose, app)->
		# models for working in this controller.
		@ComprasModel = require('../models/ComprasModel')(moongose)
		@ProductosModel = require('../models/ProductosModel')(moongose)
		@ClientesModel = require('../models/ClientesModel')(moongose)
		@ProveedoresModel = require('../models/ProveedoresModel')(moongose)
	
		# @CodProdModel = require('../models/CodProdModel')(moongose)
		# @IvaModel = require('../models/IvaModel')(moongose)

		@dataConfigModel = require('../models/dataConfigModel')(moongose)

		@getIva()
		
		# @moment = require('moment')
		@app = app
		# utils.
		# @hash = require('../libs/password')
	getIva:=>
		@dataConfigModel.findOne({miId:'uno'}).exec (err, data)=>
			if data
				if data.iva
					@iva = data.iva
				else
					data.iva = 17
					data.save (err, data)=>
						@iva = 17
			else
				data = new @dataConfigModel {miId:'uno', iva:17}
				data.save (err, data)=>
					@iva = 17

	verificaSeries:=>
		html = ""

	shopp:(req, resp)=>
		ivaC = req.data.iva
		fecha = new Date()
		# dataResp = []
		# console.log req.data.compras
		req.data.compras.forEach (compra)=>
			compra.fecha = fecha
			compra.proveedor = '----------'
			series = compra.series.split ','
			delete compra.series
			series.forEach (serie)=> 
				# console.log 'numero de inserciones'
				console.log serie
				compra.serie = serie
				compra.cantidad = if serie is '----------' then compra.cantidad else 1
				unaCompra = new @ComprasModel compra
				unaCompra.save (err, unaCompra)=>
				console.log unaCompra._id
				compra.precio_recibo = (compra.costo*1 + compra.utilidad*1).toFixed(2) 
				compra.precio_factura = (compra.precio_recibo*1 + (compra.precio_recibo*@iva)/100).toFixed(2)
				compra.idCompra = unaCompra._id
				unaCompra = new @ProductosModel compra
				unaCompra.save (err, unaCompra)=>

		if not req.data.productoReg
			console.log 'true'
			@dataConfigModel.findOne({miId:'uno'}).exec (err, data)=>
				if data
					if data.codigo?
						data.codigo = data.codigo*1 + 1
						data.save (err, data)=>
						req.data.codprod = data.codigo
					else
						data.codigo = 0
						data.save (err, data)=>
						req.data.codprod = data.codigo

					if ivaC*1 isnt data.iva*1
						data.iva = ivaC*1 
						data.save (err, data)=>
							req.data.newIva = data.iva
							req.data.msg = {tipo:'exito', titulo:'Ok', texto:'Compras Realizadas.'}
							@app.io.broadcast('compras:shopp', req.data)#enviar al cliente.
					else
						req.data.newIva = false	
						req.data.msg = {tipo:'exito', titulo:'Ok', texto:'Compras Realizadas.'}
						@app.io.broadcast('compras:shopp', req.data)#enviar al cliente.
				else
					data = new @dataConfigModel { miId:'uno', codigo:0 }
					data.save (err, data)=>
						req.data.codprod = data.codigo
						req.data.msg = {tipo:'exito', titulo:'Ok', texto:'Compras Realizadas.'}
						@app.io.broadcast('compras:shopp', req.data)#enviar al cliente.
		else
			console.log 'false'
			req.data.msg = {tipo:'exito', titulo:'Ok', texto:'Compras Realizadas.'}
			@app.io.broadcast('compras:shopp', req.data)#enviar al cliente.


	prodReg:(req, resp)=>				#ultima compra										 #todos los costos							#el primero. el de menor fecha todos los registros dela tabla ComprasModel
		@ComprasModel.aggregate().sort('fecha').group({_id:'$codigo', series: { $addToSet: "$serie" }, costos: { $addToSet: "$costo" }, docdata:{$last:"$$ROOT"}}).exec (err, compras)=>
			# ().distinct('codigo').populate('codigo').sort({fecha:'asc'}).exec (err, compras)=>
			# console.log compras
			respData = {}
			respData.data = compras
			resp.jsonp respData

	newCompra:(req, resp)=>
		# req.params.fecha = Date.now
		console.log req.params
		unaCompra = new @ComprasModel req.params
		unaCompra.save (err, compra)=>
			unProducto = new @ProductosModel req.params
			unProducto.precio_recibo = parseFloat(compra.costo*1 + compra.utilidad*1).toFixed(2) 
			unProducto.precio_factura = parseFloat(unProducto.precio_recibo*1 + (unProducto.precio_recibo*@iva)/100).toFixed(2)   
			unProducto.save (err, producto)=>
				if err 
					console.error(err)
				else
					console.log unProducto		
					resp.send 'ok creado'

	shopping:(req, resp)=>
		req.data.msg = {tipo:'exito', titulo:'Ok', texto:'Nuevo item en Almacen.'}
		req.data.existCliente = true
		@app.io.broadcast('ventas:shopping', req.data)

	getAll:(req, resp)=>			#primera compra	
		@ComprasModel.find({}).sort('fecha').exec (err, compras)=>
			respData = {}
			respData.data = compras
			resp.jsonp respData

module.exports = (moongose, app)->	new ComprasController(moongose, app)
