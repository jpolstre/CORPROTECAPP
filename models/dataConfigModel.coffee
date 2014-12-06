model = undefined
module.exports = (mongoose)->
	# create Collection. first
	dataConfigSchema = mongoose.Schema
		miId:{type:String, default:'uno'}
		iva:Number
		codigo:Number
		NroRecibo:Number
		NroFactura:Number
	if mongoose.modelNames().indexOf('dataconfig') is -1#si no existe creamos el esquema.
		model = mongoose.model('dataconfig', dataConfigSchema)
	#si existe enviamos el ya creado.
	model