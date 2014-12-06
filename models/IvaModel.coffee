model = undefined
module.exports = (mongoose)->
	# create Collection. first
	ivaSchema = mongoose.Schema
		miId:{type:String, default:'uno'}
		iva:Number
	if mongoose.modelNames().indexOf('iva') is -1#si no existe creamos el esquema.
		model = mongoose.model('iva', ivaSchema)
	#si existe enviamos el ya creado.
	model