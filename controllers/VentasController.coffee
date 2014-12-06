class VentasController
	iva:undefined
	_ : require("underscore")
	constructor:(moongose, app)->
		# models for working in this controller.
		# @ComprasModel = require('../models/ComprasModel')(moongose)
		@ProductosModel = require('../models/ProductosModel')(moongose)
		@ClientesModel = require('../models/ClientesModel')(moongose)
		@VentasModel = require('../models/VentasModel')(moongose)
		@ComprasModel = require('../models/ComprasModel')(moongose)
		@dataConfigModel = require('../models/dataConfigModel')(moongose)

		@fs = require("fs")
		@dirTemplates = __dirname.split('\\')
		@dirTemplates.pop()
		@dirTemplates = @dirTemplates.join('\\')
		
		# @fs.writeFileSync(@dirTemplates+'/public/templates/data.js', req.body.data)
		# console.log @fieldsModelVentas	
		# moongose.connection.on "close", =>
		# 	@restoreItem(id, req) for id, item of req.session.inCart
		# 	@app.io.broadcast('ventas:cancelShopp', req.data)#enviar al cliente.	

		# moongose.connection.on "diconnecting", =>
		# 	@restoreItem(id, req) for id, item of req.session.inCart
		# 	@app.io.broadcast('ventas:cancelShopp', req.data)#enviar al cliente.
	
		# moongose.connection.on "disconnected", =>
		# 	@restoreItem(id, req) for id, item of req.session.inCart
		# 	@app.io.broadcast('ventas:cancelShopp', req.data)#enviar al cliente.

		@moment = require('moment')
		@app = app
		@getIva()
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

	addToCart:(req, resp)=>
		console.log req.session
		itemi = req.data.item
		itemIncart = req.session.inCart[itemi._id]
		if itemIncart isnt undefined
			itemIncart.cantidad += itemi.cantidad*1
		else
			req.session.inCart[itemi._id] = itemi 
		@ProductosModel.findById itemi._id, (err, item)=>
			if item 
				if itemi.cantidad*1 is item.cantidad*1#delete.
					item.remove (err, item)=>
						console.log 'delete'
						req.data.msg = {tipo:'exito', titulo:'Ok', texto:"#{itemi.cantidad} agregado(s) al carrito", posicion:'arriba-derecha'}
						@app.io.broadcast('ventas:addToCart', req.data)#enviar al cliente.
				else#update.
					item.cantidad -= itemi.cantidad*1
					item.save (err, item)=>
						console.log 'update'
						req.data.msg = {tipo:'exito', titulo:'Ok', texto:"#{itemi.cantidad} agregado(s) al carrito", posicion:'arriba-derecha'}
						@app.io.broadcast('ventas:addToCart', req.data)#enviar al cliente.
			else
				console.log 'producto no encontrado.'
	
	delToCart:(req, resp)=>
		id = req.data.id
		@restoreItem(id, req)
		@app.io.broadcast('ventas:delToCart', req.data)#enviar al cliente.		

	cancelShopp:(req, resp)=>
		console.log 'CANCEL shopp'
		@restoreItem(id, req) for id, item of req.session.inCart
		@app.io.broadcast('ventas:cancelShopp', req.data)#enviar al cliente.

	restoreItem:(id, req)=>
		# clone
		itemi = {}
		itemi[prop] = val for prop, val of req.session.inCart[id]
		#delete		
		delete req.session.inCart[id]
		console.log req.session.inCart
		@ProductosModel.findById id, (err, item)=>
			if item#update.
				item.cantidad += itemi.cantidad*1
				item.save (err, item)=>
			else#add.	
				item = new  @ProductosModel itemi
				item.save (err, item)=>
	
	round:(cadena, n)->
	
		cadena.slice(0, n-3)+'...'

	shopp:(req, resp)=>
		fecha = new Date()
		cliente = req.data.cliente
		ivaC = req.data.iva
		tipoVenta = req.data.tipoVenta
		nroComprobante = req.data.nroComprobante
		cancelacion = req.data.cancelacion
		if cancelacion is 'cancelada'
			itemDeventa.cancelacion = fecha
		# console.log req.session.inCart
		# add in the collections ventas.
		monto = 0
		itemDeventa = {}
		itemDeventa.items = []
		itemDeventa.descripcionCorta = '<ul>'
		itemDeventa.descripcion = ''
		# for key, item of req.session.inCart
		# 	# delete item._id
		# 	# delete item.__v
		# 	# delete item.codigo
		# 	# delete item.costo
		# 	# delete item.utilidad
		# 	# delete item.precio_recibo
		# 	# delete item.precio_factura
		# 	# delete item.proveedor
		# 	# delete item.serie
		# 	# delete item.garantia
		# 	# delete item.cantidad
		# 	itemDeventa.descripcion += if item.serie is '----------' then "#{item.cantidad} #{item.descripcion}" else "#{item.cantidad} #{item.descripcion} (Serie: #{item.serie} )"
		# 	if tipoVenta is 'recibo' 
		# 		precio = item.precio_recibo*item.cantidad
		# 	else 
		# 		precio = item.precio_factura*item.cantidad
		# 	itemDeventa.descripcion += "-> #{precio.toFixed(2)}|" 
		# 	monto += precio 
		itemDeventa.tipo = tipoVenta
		itemDeventa.cliente = cliente
		itemDeventa.fecha = fecha
		# console.log req.data.nuevosItems
		for key, item of req.data.items
			# console.log 'Items de vente:'+ item.idCompra
			if item.descripcion.length > 29 
				# console.log 'redondeo: '+@round(item.descripcion, 29)
				descripcion = @round(item.descripcion, 29) 
			else 
				# console.log 'no redondeo'
				descripcion = item.descripcion 
					
			if item.idCompra is undefined
				itemDeventa.descripcionCorta += "<li>#{descripcion} #{item.precio} Bs.</li>"
				itemDeventa.descripcion += "#{item.descripcion}" #para busqueda.
				itemDeventa.items.push {cantidad:1, descripcion:item.descripcion, precio:item.precio, estado:'noregistrado'}
			else
				serie = if item.serie isnt '----------' then '('+item.serie+')' else ''
				itemDeventa.descripcionCorta += "<li>#{item.cantidad} #{descripcion} #{serie} #{item.precio} Bs.</li>"
				itemDeventa.descripcion += "#{item.descripcion} #{item.serie} #{item.codigo}" #para busqueda.
				item.estado = 'registrado'
				itemDeventa.items.push item
				# no es un item de almacen.
				
			monto += item.precio*1
		itemDeventa.descripcionCorta +='</ul>'
		itemDeventa.monto = monto.toFixed(2)
		itemDeventa.nroComprobante = nroComprobante*1
		@fs.writeFileSync(@dirTemplates+'/public/templates/recibo.js', JSON.stringify(itemDeventa))
		itemVenta = new @VentasModel itemDeventa
		itemVenta.save (err, itemVenta)=>
			if err 
				console.error(err)
		req.session.inCart = {}
		
		@ClientesModel.findOne {nombre:req.data.cliente}, (err, cliente)=>
			if cliente
				req.data.existCliente = true
				req.data.msg = {tipo:'exito', titulo:'Ok', texto:'Venta Realizada.'}
				# @app.io.broadcast('ventas:shopp', req.data)
			else
				req.data.existCliente = false
				unCliente = new @ClientesModel {nombre:req.data.cliente}
				unCliente.save (err, unCliente)=>
				req.data.msg = {tipo:'exito', titulo:'Ok', texto:'Venta Realizada.'}
				# @app.io.broadcast('ventas:shopp', req.data)

			@dataConfigModel.findOne({miId:'uno'}).exec (err, data)=>
				if tipoVenta is 'factura' 
					data.NroFactura = nroComprobante*1
				else
					data.NroRecibo = nroComprobante*1

				data.save (err, data)=>
				if ivaC*1 isnt data.iva*1
					data.iva = ivaC*1 
					data.save (err, data)=>
						req.data.newIva = data.iva
						console.log 'IVADISTINTO'
						@app.io.broadcast('ventas:shopp', req.data)#enviar al cliente. 
				else
					req.data.newIva = false	
					console.log 'IVAIGUAL'
					@app.io.broadcast('ventas:shopp', req.data)#enviar al cliente.
	
	getAll:(req, resp)=>			#primera compra	
		@VentasModel.find({}).sort('fecha').exec (err, ventas)=>
			respData = {}
			respData.data = ventas
			resp.jsonp respData
	
	deleteRestore:(req, resp)=>
		id = req.data.id
		swRegistrados = 0
		@VentasModel.findById id, (err, venta)=>
			# console.log venta.items
			# NOTA IMPORTANTE: NO USAR "for item in items" NUNCA (NO FUNCIONA BIEN)dentro de una consula mejor utilizar items.forEach (item)->
			venta.items.forEach (item)=>
				if item.estado is 'registrado'
					swRegistrados++
					@ProductosModel.findOne({idCompra:item.idCompra}).exec (err, producto)=>
						if producto?
							producto.cantidad += item.cantidad*1#cantidadesVenta[k]*1
							producto.save (err, producto)=>
						else
							delete item.__v
							delete item._id
							delete item.precio
							delete item.estado
							productoi = new  @ProductosModel item
							productoi.save (err, itemr)=>
								console.log  itemr
			
			# console.log swRegistrados
			if swRegistrados
				req.data.msg = {tipo:'exito', titulo:'Ok', texto:'Venta Eliminada e Items Restaurados.'}
			else
				req.data.msg = {tipo:'exito', titulo:'Ok', texto:'Venta Eliminada.'}
			venta.remove (err, venta)=>
					@app.io.broadcast('ventas:deleteRestore', req.data)#enviar al cliente.	

	cobrar:(req, resp)=>
		monto = req.data.monto
		@VentasModel.findById req.data.id, (err, venta)=>
			if monto*1 < venta.monto 
				venta.monto = venta.monto - monto*1
			else 
				venta.cancelacion = @moment(new Date()).format("DD/MMM/YYYY H:mm:ss") 
			venta.save (err, venta)=>
				req.data.msg = {tipo:'exito', titulo:'Ok', texto:"Venta Cobrada."}
				@app.io.broadcast('ventas:cobrar', req.data)

module.exports = (moongose, app)->	new VentasController(moongose, app)