class ConfigController
	iva: undefined
	constructor:(moongose, app)->
		@moongose = moongose
		# @mongobackup = require('mongobackup')
		# models for working in this controller.
		# @ComprasModel = require('../models/ComprasModel')(moongose)
		# @ProductosModel = require('../models/ProductosModel')(moongose)
		# @ClientesModel = require('../models/ClientesModel')(moongose)
		# @ProveedoresModel = require('../models/ProveedoresModel')(moongose)
	
		# @CodProdModel = require('../models/CodProdModel')(moongose)
		# @IvaModel = require('../models/IvaModel')(moongose)

		# @dataConfigModel = require('../models/dataConfigModel')(moongose)

		# @getIva()
		
		# @moment = require('moment')
		# @app = app
		# utils.
		# @hash = require('../libs/password')
	dropDB:(req, resp)=>
		@moongose.connection.db.dropDatabase()
		resp.send '<h1>Db Eliminada</h1>'

module.exports = (moongose, app)->	new ConfigController(moongose, app)