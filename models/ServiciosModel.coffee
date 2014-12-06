
model = undefined
module.exports = (mongoose)->
	# create Collection. first
	ServiciosSchema = mongoose.Schema
		fecha:{ type: Date, default: Date.now }
		descripcion:String
		tipo:String#factura / recibo
		cliente:String
		cobro:{ type: String, default: 'pendiente' }
		monto:{ type: Number, default: 0.00 } 
		fecha_cancel:{type: Date, default: '' }
		
	if mongoose.modelNames().indexOf('Servicios') is -1
		model = mongoose.model('Servicios', ServiciosSchema)
	
	# console.log model
	model