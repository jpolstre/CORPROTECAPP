model = undefined
module.exports = (mongoose)->
	# create Collection. first
	codProdSchema = mongoose.Schema
		miId:{type:String, default:'uno'}
		numero:Number
	if mongoose.modelNames().indexOf('codprod') is -1#si no existe creamos el esquema.
		model = mongoose.model('codprod', codProdSchema)
	#si existe enviamos el ya creado.
	model