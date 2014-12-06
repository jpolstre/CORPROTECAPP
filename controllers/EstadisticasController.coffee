class EstadisticasController
	
	constructor:(moongose, app)->
		@moment = require 'moment'
		@VentasModel = require('../models/VentasModel')(moongose)
		@ProductosModel = require('../models/ProductosModel')(moongose)
		@_ = require 'underscore'
		# @moment = require('moment')
		# @ComprasModel = require('../models/ComprasModel')(moongose)
		# @app = app
		
		@fs = require("fs")
		@dirTemplates = __dirname.split('\\')
		@dirTemplates.pop()
		@dirTemplates = @dirTemplates.join('\\')

	makeEstadisticasVentas:(ventas)=>
		clientesMontos = {}
		itemsVendidos = {}
		utilidadTotal = 0
		ventasPorFecha = []
		ventasPorCobrar = 0
		ventas.forEach (venta)=>
			ventasPorCobrar++ if venta.cancelacion[0] is '<'
			d = new Date(venta.fecha)
			# d.setUTCDate(15)
			ventasPorFecha.push [d.getTime(), venta.monto]
			# producto mas vendido hasta el momento.
			if clientesMontos[venta.cliente]?
				clientesMontos[venta.cliente].data += venta.monto
			else
				clientesMontos[venta.cliente] = {label:venta.cliente, data:venta.monto, fecha:venta.fecha}
			
			# producto mas vendido hata el momento.
			venta.items.forEach (item)=>
				if item.utilidad?
					if itemsVendidos[item.codigo]?
						itemsVendidos[item.codigo].cantidad += item.cantidad 
						itemsVendidos[item.codigo].utilidad += item.cantidad*item.utilidad 
						utilidadTotal += itemsVendidos[item.codigo].utilidad#ganancia.
					else
						itemsVendidos[item.codigo] = {codigo:item.codigo, cantidad:item.cantidad, descripcion:item.descripcion, fecha:venta.fecha, utilidad:item.utilidad*item.cantidad}
						utilidadTotal += itemsVendidos[item.codigo].utilidad#ganancia.
				else
					utilidadTotal += item.precio		
		mayCompData = (@_.sortBy clientesMontos, (elem)-> -elem.data).slice(0, 5)#primeros 20
		prodsMasVenData = (@_.sortBy itemsVendidos, (item)-> -item.cantidad).slice(0, 5)#primeros 5
		# console.log @moment
		@fs.writeFileSync(@dirTemplates+'/public/templates/pieMayorComprador.js',  JSON.stringify({data:mayCompData, fecha:@moment(new Date()).format("DD/MMM/YYYY H:mm:ss")}))
		{mayCompData:mayCompData, prodsMasVenData:prodsMasVenData, utilidadTotal:utilidadTotal, ventasPorFecha:ventasPorFecha, ventasPorCobrar:ventasPorCobrar} 


	estadisticaVentas:(req, resp)=>
		# console.log req.query
		fechaInicio = req.query.fechaInicio
		fechaFinal = req.query.fechaFinal
		
		if fechaInicio? and fechaFinal?
			fechaInicio = new Date(req.query.fechaInicio)
			fechaFinal = new Date(req.query.fechaFinal)
			@VentasModel.find($and:[{fecha:{$lte:fechaFinal}}, {fecha:{$gte:fechaInicio}}]).sort('fecha').exec (err, ventas) =>
				resp.json @makeEstadisticasVentas ventas
		else
			# apartir de esta fecha.
			if fechaInicio?
				fechaInicio = new Date(req.query.fechaInicio)
				@VentasModel.find({fecha:{$gte:fechaInicio}}).sort('fecha').exec (err, ventas) =>
					resp.json @makeEstadisticasVentas ventas
			else
			# anio actual
				currentYear = (new Date()).getFullYear().toString()
				fechaInicio = (new Date("01/01/#{currentYear}"))
				# fechaInicio = "Sat Nov 22 2014 21:24:10 GMT-0400 (Hora estándar oeste, Sudamérica)"
				console.log fechaInicio
				@VentasModel.find({fecha:{$gte:fechaInicio}}).sort('fecha').exec (err, ventas) =>
					console.log ventas
					resp.json @makeEstadisticasVentas(ventas)

	estadisticaCompras:(req, resp)=>
		@ProductosModel.find({}).exec (err, prods) =>
			resp.json @makeEstadisticasCompras(prods)

	makeEstadisticasCompras:(prods)=>
		{ prodsAlmacen:prods.length }
		
		# @VentasModel.find().or([{descripcion:{$regex:textFilter}}, {cliente:{$regex:textFilter}}, {tipo:{$regex:textFilter}}, {fecha_cancel:{$regex:textFilter}}, {fecha_emision:{$regex:textFilter}}]).sort(req.query.querySort).exec (err, doc) =>
			

module.exports = (moongose, app)->  new EstadisticasController(moongose, app)
