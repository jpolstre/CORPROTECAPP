class ReportesController
	@data:undefined
	constructor:(moongose, app)->
		# reporter:undefined
		# require('jsreport').bootstrapper().start().then (bootstrapp)=>
		# 	@reporter = bootstrapp.reporter
		@reporter = app.reporter
		# console.log @reporter

		# models for working in this controller.
		# @ComprasModel = require('../models/ComprasModel')(moongose)
		@VentasModel = require('../models/VentasModel')(moongose)
		@ComprasModel = require('../models/ComprasModel')(moongose)
		# @moment = require('moment')
		@app = app
		@fs = require("fs")
		@dirTemplates = __dirname.split('\\')
		@dirTemplates.pop()
		@dirTemplates = @dirTemplates.join('\\')
		
	makeReport:(req, resp)=>
		@data = req.body.data
		# console.log req.body.data
		# @fs.writeFileSync(@dirTemplates+'/public/templates/data.js', req.body.data)
		# @fs.writeFile @dirTemplates+'/public/templates/data.js', req.body.data, (err)->
		resp.json {'ok'}

	makeReport2:(req, resp)=>
		textFilter = new RegExp(req.query.textFilter, 'i')
		# console.log textFilter
		@VentasModel.find().or([{descripcion:{$regex:textFilter}}, {cliente:{$regex:textFilter}}, {tipo:{$regex:textFilter}}, {fecha_cancel:{$regex:textFilter}}, {fecha_emision:{$regex:textFilter}}]).sort(req.query.querySort).exec (err, doc) =>
		# @VentasModel.find().where('descripcion').regex(textFilter).exec (err, doc) =>
			console.log doc.length
			@fs.writeFileSync(@dirTemplates+'/public/templates/data.js', JSON.stringify({ventas:doc}))
			resp.jsonp {'ok'}
	
	makeRecibo:(req, resp)=>
		# @data = req.body.data
		req.body.data.fechaEmision = req.body.data.fecha
		@fs.writeFileSync(@dirTemplates+'/public/templates/recibo.js', req.body.data)
		resp.json {'ok'}

	viewRecibo:(req, resp)=>
		content = @fs.readFileSync(@dirTemplates+'/public/templates/recibo.html').toString("utf8")
		helpers = @fs.readFileSync(@dirTemplates+'/public/templates/helpers.js').toString("utf8")
		data = @fs.readFileSync(@dirTemplates+'/public/templates/recibo.js').toString("utf8")
		@reporter.render({
			template: { 
				name: "Recibo",
				content: content,
				helpers: helpers,
				engine: "handlebars",
				recipe: "phantom-pdf",
				# phantom: {
				# 	header: "<div style='text-align:center'>{#pageNum}/{#numPages}</div>"
				# }
			},	
			data:data
		}).then (response)->
			 # response.result is a stream to a pdf
			 # you can for example pipe it to express.js response
			response.result.pipe(resp)

	viewReport:(req, resp)=>
		# console.log @data
		# data = @fs.readFileSync(@dirTemplates+'/public/templates/data.js').toString("utf8")
		content = @fs.readFileSync(@dirTemplates+'/public/templates/ventas.html').toString("utf8")
		helpers = @fs.readFileSync(@dirTemplates+'/public/templates/helpers.js').toString("utf8")
		@reporter.render({
			template: { 
				name: "Reporte de Ventas",
				content: content,
				helpers: helpers,
				engine: "handlebars",
				recipe: "phantom-pdf",
				phantom: {
					header: "<div style='text-align:center'>{#pageNum}/{#numPages}</div>"
				}
			},	
			data:@data
		}).then (response)->
			 # response.result is a stream to a pdf
			 # you can for example pipe it to express.js response
			response.result.pipe(resp)
			

	generarReporte:(req, resp)=>
		
		data = @fs.readFileSync(@dirTemplates+'/public/templates/data2.js').toString("utf8")
		content = @fs.readFileSync(@dirTemplates+'/public/templates/sample.html').toString("utf8")
		helpers = @fs.readFileSync(@dirTemplates+'/public/templates/helpers.js').toString("utf8")
		@fs.appendFileSync(@dirTemplates+'/public/templates/data2.js', data)
		console.log content

		@reporter.render({
			template: { 
				name: "Sample report",
				content: content,
				helpers: helpers,
				engine: "handlebars",
				recipe: "phantom-pdf",
				phantom: {
					header: "<div style='text-align:center'>{#pageNum}/{#numPages}</div>"
				}
			},	
			data:data
		}).then (response)->
			 # response.result is a stream to a pdf
			 # you can for example pipe it to express.js response
			response.result.pipe(resp);


	testReporte:(req, resp)=>
	
		fs = require("fs")
		dirTemplates = __dirname.split('\\')
		dirTemplates.pop()
		dirTemplates = dirTemplates.join('\\')

		data = fs.readFileSync(dirTemplates+'/public/templates/data.js').toString("utf8")
		content = fs.readFileSync(dirTemplates+'/public/templates/sample.html').toString("utf8")
		helpers = fs.readFileSync(dirTemplates+'/public/templates/helpers.js').toString("utf8")

		console.log content

		@reporter.render({
			template: { 
				name: "Sample report",
				content: content,
				helpers: helpers,
				engine: "handlebars",
				recipe: "phantom-pdf",
				phantom: {
					header: "<div style='text-align:center'>{#pageNum}/{#numPages}</div>"
				}
			},	
			data:data
		}).then (response)->
			 # response.result is a stream to a pdf
			 # you can for example pipe it to express.js response
			response.result.pipe(resp);


	viewMayorCompradorPdf:(req, resp)=>
		content = @fs.readFileSync(@dirTemplates+'/public/templates/pieMayorComprador.html').toString("utf8")
		data = @fs.readFileSync(@dirTemplates+'/public/templates/pieMayorComprador.js').toString("utf8")
		# console.log data
		@reporter.render({
			template: { 
				name: "Mayores Compradores",
				content: content,
				# helpers: helpers,
				engine: "handlebars",
				recipe: "phantom-pdf",
				# phantom: {
				# 	header: "<div style='text-align:center'>{#pageNum}/{#numPages}</div>"
				# }
			},	
			data:data
		}).then (response)->
			 # response.result is a stream to a pdf
			 # you can for example pipe it to express.js response
			response.result.pipe(resp)


module.exports = (moongose, app)->  new ReportesController(moongose, app)