model = undefined
module.exports = (mongoose)->
	# create Collection. first
	VentasSchema = mongoose.Schema
		fecha:{ type: Date, default: Date.now }#emision/registro. sera
		cliente:String
		descripcionCorta:{ type: String, default: '' }
		descripcion:{type:String, default:''}
		items:[]
		monto:{ type: Number, default: 0.00 } 
		tipo:String#factura / recibo
		nroComprobante:Number
		# cobro:{ type: String, default: 'pendiente' }
		# fecha_emision:{type: String, default: '<span class="label label-danger selectable-red">sin emitir</span>' }
		cancelacion:{type: String, default: '<span class="label label-danger selectable-red">pendiente</span>' }
		# idsCompra:[]
	if mongoose.modelNames().indexOf('Ventas') is -1
		model = mongoose.model('Ventas', VentasSchema)
	
	# console.log model
	model

# model = undefined

# module.exports = (mongoose)->
# 	# create Collection. first
# 	ventasSchema = mongoose.Schema
# 		fecha: { type:Date, default: Date.now }
# 		serie: { type:String, default:'----------'}
# 		codigo:String
# 		descripcion:String
# 		tipoVenta:String
# 		precioVenta:Number
# 		cantidad:Number
# 		costo:Number
# 		precio_recibo:Number
# 		precio_factura:Number
# 		utilidad:Number
# 		garantia:String
# 		proveedor:String
# 		cliente:String
	
# 	if mongoose.modelNames().indexOf('Ventas') is -1#si no existe creamos el esquema.
# 		model = mongoose.model('Ventas', ventasSchema)
# 	#si existe enviamos el ya creado.
# 	model