jQuery.fn.dataTableExt.oApi.fnGetDisplayRows = (oSettings)->
	rowsDataDisplay = []
	for i in oSettings.aiDisplay
		rowData =  oSettings.aoData[i]._aData
		rowsDataDisplay.push rowData
	rowsDataDisplay

###########GLOBALS.

# moment.locale('es')
# console.log 'lenguaje por def:' + moment.locale()

clientes = []
proveedores = []
codprod = undefined
getCodProd = ->
	'ITEM-' + codprod 
tablaAlmacen = undefined
ivaJqVenta = undefined
ivaCompraJq = undefined
iva = undefined

NroFactura = undefined 
NroRecibo = undefined


########################################### COMPRAS.#############################################################################


ctnComprasJq = $('div#comprar-ctn')
numItemsJq2 = ctnComprasJq.find('span#num-items')
msgCarritoJq2 = ctnComprasJq.find('div#msg-carrito')
AuxObjAttribs2 = ['series', 'codigo', 'descripcion', 'costo', 'cantidad', 'utilidad', 'garantia', 'subtotal']

htmlProveedor = '<form class="form-horizontal">'
htmlProveedor += "
<div class='form-group'>
	<label for='proveedor' class='col-md-3  control-label'>Proveedor:</label>
	<div class='col-md-5'>
		<input type='text' class='form-control upper' id='proveedor' name='proveedor' autocomplete='off' validar='requiere'>
	</div>
</div>"
htmlProveedor += '<input type="submit" style="width:0px;height:0px;margin:0;padding:0;border:none;"></form>'

formHtmlEditarItem2 = '<form class="form-horizontal">'
for item in AuxObjAttribs2 when item isnt 'subtotal'
	formHtmlEditarItem2 += "
	<div class='form-group'>
		<label for='#{item}' class='col-md-3  control-label'>#{item}:</label>
		<div class='col-md-7'>
			<input type='text' class='form-control upper' id='#{item}' name='#{item}' validar='requiere'>
		</div>
	</div>"
formHtmlEditarItem2 += '<input type="submit" style="width:0px;height:0px;margin:0;padding:0;border:none;"></form>'

codigoComprasGlobalJq = undefined
$(document).ready ->
	valArray = {codigo:ctnComprasJq.find('input#codigo'), descripcion:ctnComprasJq.find('textarea#descripcion'), costo:ctnComprasJq.find('input#costo'), utilidad:ctnComprasJq.find('input#utilidad'), garantia:ctnComprasJq.find('input#garantia')}
	codigoComprasGlobalJq = valArray.codigo
	# day = moment('2014-07-19T16:10:59.568Z')
	# console.log day.format("MM-DD-YYYY")
	swPorComprar = false
	# ESCUCHADORES.
	io.on 'compras:shopp', (data)->
		# and update table for all users.
		# for item, i in data.compras
		#   indexRow = ShoppingCart2.upOrCreIdexesRows[i]
		#   if indexRow is -1#create
		#     tablaRegistrados.add(ShoppingCart2.itemsInCart[i])
		#   else#update.
		#     tablaRegistrados.api().row(indexRow).data(item)
		if data.newIva
			iva = data.newIva
			ivaJqVenta.val iva
			ivaCompraJq.val iva
		# console.log data.productoReg
		# console.log data.codprod*1
		if not data.productoReg#no registrado.
			console.log 'no registrado'
			codprod = data.codprod*1
			codprod++
			valArray.codigo.val getCodProd()
		drawEstadisticasCompras()
		tablaRegistrados.api().ajax.reload()
		tablaCompras.api().ajax.reload()
		tablaAlmacen.api().ajax.reload()
		if data.userAction is globalUser
			# ShoppingCart2.restar()
			new Alerta data.msg 

		# if not data.existProveedor#false
		#   # sourceArray(proveedores, data.proveedor)

		#   proveedores.push data.proveedor

		# and update table for all users.
		# if itemElegido.codigo#no empty
		#   tdElegido = $('td', tablaRegistradosJq.tBodyJq).filter(in) -> $(this).text() is itemElegido.codigo 
		#   trElegido = tdElegido.parent() 

	
	tablaRegistradosJq = ctnComprasJq.find('#prod-registrados')
	contTablaRegJq = tablaRegistradosJq.parent()
	tablaRegistrados = tablaRegistradosJq.dataTable
		"dom": '<"top"fl>t<"bottom"pi><"clear">'
		"language": {
				"search": "Buscar: ",
				"lengthMenu":"",
				"lengthMenu": "_MENU_",
				"zeroRecords": "Ningun registro encontrado",
				"info": "pagina _PAGE_ de _PAGES_",
				"infoEmpty": "Ningun Registro",
				"infoFiltered": "(fitrado de _MAX_ total registros)"
		 },

		"ajax": '/compras/prodReg',
		"columns": [
			{ "data": "docdata._id" }
			{ "data": "docdata.fecha" }
			{ "data": "docdata.serie" }
			{ "data": "docdata.codigo" }
			{ "data": "docdata.descripcion" }
			{ "data": "docdata.costo" }
			{ "data": "docdata.cantidad" }
			{ "data": "docdata.utilidad" }
			{ "data": "docdata.garantia" }
			{ "data": "docdata.proveedor" }
			# { "defaultContent": "<button class='btn btn-primary'>Elegir</button>"}
		]
		"columnDefs": [
			{ "visible": false, "targets": 0 }
			{ "targets": 1, "visible": false, "createdCell":(td, cellData, rowData, row, col)-> 
				time = moment(cellData).format("DD/MMM/YYYY H:mm:ss")
				$(td).text time
				# rowData.fecha = time
			}
			{ "visible": false, "targets": 2 }
			{ "targets": 3, "createdCell":(td, cellData, rowData, row, col)-> $(td).html("<a href='javascript:;'>#{cellData}</a>")}
			{ "targets": 4, "createdCell":(td, cellData, rowData, row, col)-> $(td).html("<a href='javascript:;'>#{cellData}</a>")}
			{ "visible": false, "targets": 5 }
			{ "visible": false, "targets": 6 }
			{ "visible": false, "targets": 7 }
			{ "visible": false, "targets": 8 }
			{ "visible": false, "targets": 9 }
			# { "orderable": false, "targets": -1 }
		 ]
		"order": [1, 'desc'],
		# "ordering": false

	showHideMenujq = ctnComprasJq.find('div.show-hide-colms:eq(0)')
	$(document).ajaxComplete (event, xhr, settings)->
		tablaRegistradosJq.css('width', '')
	

	formCompraJq = ctnComprasJq.find('form#compra-nueva')
	formIvaJq = ctnComprasJq.find('#form-iva')
	ivaCompraJq = formIvaJq.find('input:text:eq(0)').on 'keyup change', (e)->
		ivaJqVenta.val(ivaCompraJq.val())
		ivaJqVenta.trigger 'keyup'
		utilidad = utilidadJq.val()
		costo = costoJq.val()
		if utilidad isnt '' and costo isnt ''
			precio_recibo = costo*1 + utilidad*1
			precioRecJq.val (precio_recibo).toFixed(2)
			precioFacJq.val ((ivaCompraJq.val()*precio_recibo/100)+precio_recibo).toFixed(2) 


	precioRecJq = formIvaJq.find('input:text:eq(1)')
	precioFacJq = formIvaJq.find('input:text:eq(2)')
	
	costoJq = formCompraJq.find('input:text:eq(1)').on 'keyup change', (e)->
		utilidad = utilidadJq.val()
		costo = costoJq.val()
		if utilidad isnt ''
			precio_recibo = costo*1 + utilidad*1
			precioRecJq.val (precio_recibo).toFixed(2)
			precioFacJq.val ((ivaCompraJq.val()*precio_recibo/100)+precio_recibo).toFixed(2) 	
	
	utilidadJq = formCompraJq.find('input:text:eq(2)').on 'keyup change', (e)->
		utilidad = utilidadJq.val()
		costo = costoJq.val()
		if costo isnt ''
			precio_recibo = costo*1 + utilidad*1
			precioRecJq.val (precio_recibo).toFixed(2)
			precioFacJq.val ((ivaCompraJq.val()*precio_recibo/100)+precio_recibo).toFixed(2) 	
				

	new Validador
		formulario:formIvaJq
		procesarFormulario:(formJq)=>
			# alert ivaCompraJq.val()+precioRecJq.val()+precioFacJq()


	ctnComprasJq.find('ul.dropdown-cols:eq(0) input:checkbox').on 'click', (event)->
		column = tablaRegistrados.api().column( $(this).attr('data-column') );
		#Toggle the visibility
		if $(this).is(':checked')
			column.visible( true )
		else
			column.visible( false )
		tablaRegistradosJq.css('width', '')

	cantidadJq =  ctnComprasJq.find("input#cantidad")

	tableTitleJq = ctnComprasJq.find('div#title-panel1')
	buttonTitleJq = ctnComprasJq.find('div#title-panel2')

	titlePanelJq = ctnComprasJq.find('div#nueva-compra div.panel-heading')
	itemElegido = {}

	$('tbody', tablaRegistradosJq).on 'click', 'a', (evt) ->
		evt.preventDefault()
		indexElegido = tablaRegistrados.api().row($(this).parents('tr')[0]).index()
		# ShoppingCart2.upOrCreIdexesRows.push indexElegido
		data =  tablaRegistrados.api().row(indexElegido).data()
		itemElegido = data.docdata
		# console.log data
		contTablaRegJq.fadeOut 'fast', ->
			showHideMenujq.hide()
			tableTitleJq.show()
			buttonTitleJq.hide()
			contTablaRegJq.next().fadeIn 'fast', ->
				jq.val data.docdata[prop] for prop, jq of valArray #when prop isnt 'costo'
				#valArray.costo.val data.costo
				valArray.costo.select()
	
	#btn search.
	inputSearchJq = $('input.input-sm', contTablaRegJq)
	
	imputsFormCompraJq = $('input:text, textarea', formCompraJq)
	btnSearchJq = ctnComprasJq.find('button#btn-search-form').on 'click', (evt)->
		# imputsFormCompraJq.val ''
		# codprod-- 
		validador.ocultarMensajes()
		cantidadJq.val ''
		contTablaRegJq.next().fadeOut 'fast', ->
			if inputSearchJq.val() isnt ''
				inputSearchJq.val ''
				inputSearchJq.trigger 'keyup'
			# titlePanelJq.html('Productos Registrados <strong>(Elija Uno)</strong> / o uno <button class="btn btn-primary btn-sm">Nuevo</button>')
			showHideMenujq.show()
			tableTitleJq.hide()
			buttonTitleJq.show()
			contTablaRegJq.fadeIn 'fast', ->
				inputSearchJq.focus()

	# new shopp
	$(titlePanelJq).on 'click', 'button:eq(0)', (e)->
		contTablaRegJq.fadeOut 'fast', ->
			showHideMenujq.hide()
			tableTitleJq.show()
			buttonTitleJq.hide()
			# titlePanelJq.html('<strong>(Agregue al carrito)</strong>')
			btnClearJq.trigger 'click'
			contTablaRegJq.next().fadeIn 'fast', ->

				# codprod++
				valArray.codigo.val getCodProd()
				valArray.descripcion.focus()

	#btn clear.
	btnClearJq = ctnComprasJq.find('button#btnClearForm').on 'click', (evt)->
		valArray.codigo.val getCodProd()
		imputsFormCompraJq.slice(1).val ''
		precioRecJq.val ''
		precioFacJq.val ''
		validador.ocultarMensajes()
		itemElegido = {}
		valArray.descripcion.focus()
	

	# serialize form
	serializeForm = (formJq)->
		objResult = {}
		$('input:text, textarea', formJq).each (k)->
			elJq = $(this)
			objResult[elJq.attr('id')] = elJq.val() 
		console.log objResult
		objResult


	# FORM NUEVA COMPRA SUBMIT
	procAddToCard = (series = false)->
		itemsInCart = []
		rowObj = serializeForm formCompraJq

		# rowObj.subtotal = rowObj.cantidad * rowObj.costo
		if series
			rowObj.series = series#'ACC-11, XX-34, etc'
		else
			rowObj.series = '----------'  
		
		itemsInCart.push rowObj
		# ShoppingCart2.addRow rowObj

		# btnSearchJq.trigger 'click'
		console.log itemsInCart 
		btnClearJq.trigger 'click'
		io.emit('compras:shopp', {compras:itemsInCart, userAction:globalUser, productoReg:swPorComprar, iva:ivaCompraJq.val()})
		# io.emit('compras:shopping', {userAction:globalUser})#for vender.

		new Alerta
			tipo:'info'
			titulo:'Item(s) Agregado'
			texto: "#{rowObj.cantidad} item(s) agregados al carrito"
			posicion:'arriba-izquierda'

		# alert itemElegido.codigo

	procSeries = ->
		# arrayProductos[codigoJq.val()] = true
		cantidad = cantidadJq.val()*1
		htmlSeries = '<form class="form-horizontal">'
		for i in [0...cantidad]
			htmlSeries += "
			<div class='form-group'>
				<label for='serie#{i+1}' class='col-md-3  control-label'>Serie#{i+1}:</label>
				<div class='col-md-5'>
					<input type='text' class='form-control upper' id='serie#{i+1}' name='serie#{i+1}' placeholder='Serie del producto' validar='requiere'>
				</div>
			</div>"
		htmlSeries += '<input type="submit" style="width:0px;height:0px;margin:0;padding:0;border:none;"></form>'
		modalSeries = new Modal
			titulo:'Series'
			tipo:'formulario'
			contenido: htmlSeries
			despuesDeMostrar:(ModalJq)->
				# alert 'ok'
				setTimeout ->
					# alert ModalJq.find('input:text:first').attr('class')
					ModalJq.find('input:text:first').focus()    
				,500
			antesDeMostrar:(ModalJq)->
				ModalJq.find('div.modal-footer button:first').text 'ok' 
		
		new Validador
			formulario:modalSeries.jq.find('form:first')
			procesarFormulario:(formSeriesJq)=>
				modalSeries.cerrar ->
					series = ''
					formSeriesJq.find('input:text:not(:last)').each (k)->
						series += "#{$(this).val()}, "
					series += formSeriesJq.find('input:text:last').val()
					procAddToCard(series)
			
	validador = new Validador
		# validarTeclas:false#no validar al presionar teclas
		formulario:formCompraJq

		procesarFormulario:(formJq)->
			# alert arrayProductos[codigoJq.val()].serie
			formIvaJq.trigger 'submit'
			if ivaCompraJq.val() isnt ''
				prod = itemElegido
				unless prod.serie#es nuevo.
					# ShoppingCart2.upOrCreIdexesRows.push -1
					swPorComprar = false
					modalConfirm = new Modal
						titulo:'Producto Nuevo'
						tipo:'confirmacion'
						contenido:"<p>! El Producto con codigo <strong>#{valArray.codigo.val()}</strong> es un nuevo producto</p><br> <p>Posee serie?</p>"
						accionSi: ->
							modalConfirm.cerrar ->
								procSeries()
						antesDeMostrar:(jqModal)->
							btnsi = jqModal.find('button.btn-danger').text('SI')
							jqModal.find('button:last').text('NO').click (e)->
								procAddToCard()
							setTimeout ->
								btnsi.focus()   
							,500
						despuesDeCerrar: (jqModal)->
				else if prod.serie isnt '----------'
					swPorComprar = true
					procSeries()
				else
					swPorComprar = true
					procAddToCard()



	tablaComprasJq = ctnComprasJq.find('#tabla-compras')
	contTablaComJq = tablaComprasJq.parent()
	tablaCompras = tablaComprasJq.dataTable
		"dom": '<"top"fl>t<"bottom"pi><"clear">'
		"language": {
				"search": "Buscar: ",
				"lengthMenu":"",
				"lengthMenu": "_MENU_",
				"zeroRecords": "Ningun registro encontrado",
				"info": "pagina _PAGE_ de _PAGES_",
				"infoEmpty": "Ningun Registro",
				"infoFiltered": "(fitrado de _MAX_ total registros)"
		 },

		"ajax": '/compras/getAll',
		"columns": [
			{ "data": "_id" }
			{ "data": "fecha" }
			{ "data": "serie" }
			{ "data": "codigo" }
			{ "data": "descripcion" }
			{ "data": "costo" }
			{ "data": "cantidad" }
			{ "data": "utilidad" }
			{ "data": "garantia" }
			{ "data": "proveedor" }
			# { "defaultContent": "<button class='btn btn-primary'>Elegir</button>"}
		]
		"columnDefs": [
			{ "visible": false, "targets": 0 }
			{ "targets": 1, "visible": true, "createdCell":(td, cellData, rowData, row, col)-> 
				time = moment(cellData).format("DD/MMMM/YYYY H:mm:ss")
				$(td).text time
				# rowData.fecha = time
			}
			# { "visible": false, "targets": 2 }
			# { "visible": false, "targets": 3 }
			# { "visible": false, "targets": 4 }
			# { "visible": false, "targets": 5 }
			# { "visible": false, "targets": 6 }
			# { "visible": false, "targets": 7 }
			{ "visible": false, "targets": 8 }
			{ "visible": false, "targets": 9 }
			# { "orderable": false, "targets": -1 }
		 ]
		"order": [1, 'desc']

	$(document).ajaxComplete (event, xhr, settings)->
		tablaComprasJq.css('width', '')
		# showHideMenujq2.show()

	#hide/show columns.
	ctnComprasJq.find('ul.dropdown-cols:eq(1) input:checkbox').on 'click', (event)->
		column = tablaCompras.api().column( $(this).attr('data-column') );
		#Toggle the visibility
		if $(this).is(':checked')
			column.visible( true )
		else
			column.visible( false )
		tablaComprasJq.css('width', '')

	# SHOPPING CART.
	# ShoppingCart2 = new ShoppingCart2()
	# ShoppingCart2.addTo ctnComprasJq.find('div.table-responsive:eq(1)')
	# ShoppingCart2.addRow {series:'DDS-124', codigo:'XXX', descripcion:'Descripcion de XXX', costo:1456, cantidad:4, utilidad:178, garantia:'1 anio'}

########################################### VENTAS.#############################################################################
htmlFormCobrar = '<form class="form-horizontal">'
htmlFormCobrar += "
<div class='form-group'>
	<label for='monto' class='col-md-3  control-label'>Monto a Cobrar:</label>
	<div class='col-md-5'>
		<input type='text' class='form-control upper' id='monto' name='monto' autocomplete='off' validar='real'>
	</div>
</div>"
# <div class='col-md-5'>
# 	<label class='radio-inline'>
# 		<input type='radio' class='tipo_precio' name='inlineRadioOptions3' checked='checked' value='no_comprobante'> o imprimir
# 	</label>
# 	<label class='radio-inline'>
# 		<input type='radio' class='tipo_precio' name='inlineRadioOptions3' value='comprobante'> Imprimir
# 	</label>
# </div>

htmlFormCobrar += '<input type="submit" style="width:0px;height:0px;margin:0;padding:0;border:none;"></form>'
clientesContrato = ['MADEPA', 'COBEE']

formHtmlEditarServicio = '<form class="form-horizontal">'
formHtmlEditarServicio += "
<div class='form-group'>
	<label for='fecha_cancel' class='col-md-3  control-label'>Fecha Reg.:</label>
	<div class='col-md-5'>
		<div class='input-group date' id='datetimepicker2'>
			<input type='text' class='form-control' id='fecha' name='fecha' autocomplete='off' data-date-format='DD/MMM/YYYY H:mm:ss'/>
			<span class='input-group-addon'><span class='glyphicon glyphicon-calendar'></span>
		</div>
	</div>
</div>
<div class='form-group'>
	<label for='cliente' class='col-md-3  control-label'>Cliente:</label>
	<div class='col-md-5'>
		<input type='text' class='form-control upper' id='cliente' name='cliente' autocomplete='off' validar='requiere'>
	</div>
</div>
<div class='form-group'>
	<label for='descripcion' class='col-md-3  control-label'>Descripcion:</label>
	<div class='col-md-5'>
		<textarea type='text' class='form-control' id='descripcion' name='descripcion' autocomplete='off' validar='requiere'></textarea>
	</div>
</div>
<div class='form-group'>
	<label for='cobro' class='col-md-3  control-label'>Cobro:</label>
	<div class='col-md-5'>
		<select class='form-control' validar='requiere'>
			<option></option>
			<option>pendiente</option>
			<option>cancelado</option>
			<option>contrato</option>
		</select>
	</div>
</div>

<div class='form-group'>
	<label for='fecha' class='col-md-3  control-label'>Monto:</label>
	<div class='col-md-5'>
		<input type='text' class='form-control upper' id='fecha' name='fecha' autocomplete='off' validar='real'>
	</div>
</div>
<div class='form-group'>
	<label for='fecha_cancel' class='col-md-3  control-label'>Fecha Cancel:</label>
	<div class='col-md-5'>
		<div class='input-group date' id='datetimepicker1'>
			<input type='text' class='form-control' id='fecha_cancel' name='fecha_cancel' autocomplete='off' data-date-format='DD/MMM/YYYY H:mm:ss'/>
			<span class='input-group-addon'><span class='glyphicon glyphicon-calendar'></span>
		</div>
	</div>
</div>"
formHtmlEditarServicio += '<input type="submit" style="width:0px;height:0px;margin:0;padding:0;border:none;"></form>'

ctnVentasJq = $('div#ventas-ctn')
tablaAlmacen = undefined
# tablaVentas = undefined


$(document).ready ->
	# console.log window.location
	io.on 'ventas:deleteRestore', (data)->
		drawEstadisticasCompras()
		tablaVentas.api().ajax.reload()
		tablaAlmacen.api().ajax.reload()
		drawEstadisticasVentas()
		if data.userAction is globalUser
			new Alerta data.msg 
	
	io.on 'ventas:addToCart', (data)->
		tablaAlmacen.api().ajax.reload()
		if data.userAction is globalUser
			addCartProcedure data.item
			inputSearchJq.val('').trigger('keyup').focus()
			new Alerta data.msg 	

		
	io.on 'ventas:cobrar', (data)->
		drawEstadisticasVentas()
		tablaVentas.api().ajax.reload()
		if data.userAction is globalUser
			new Alerta data.msg 

	io.on 'ventas:delToCart', (data)->
		tablaAlmacen.api().ajax.reload()

	io.on 'ventas:cancelShopp', (data)->
		tablaAlmacen.api().ajax.reload()


	
	io.on 'ventas:shopp', (data)->
		drawEstadisticasVentas()
		drawEstadisticasCompras()
		if data.tipoVenta is 'factura'
			NroFactura = data.nroComprobante*1 + 1
		else
			NroRecibo = data.nroComprobante*1 + 1
		if data.userAction is globalUser and data.tipoVenta is 'recibo'
			window.open("/reportes/viewRecibo/", "report", "toolbar=no, scrollbars=yes, resizable=yes, location=no, menubar=no, top=50, left=250, width=700, height=400");

		setTimeout ->
			tablaVentas.api().ajax.reload()
		,1

		if not data.existCliente
			clientes.push data.cliente 
		
		if data.userAction is globalUser
			btnClearJq2.trigger 'click'
			new Alerta data.msg 

	# io.on 'servicios:editar', (data)->
	# 		tablaServicios.api().ajax.reload()
	# 		if data.userAction is globalUser
	# 			new Alerta data.msg

	# io.on 'servicios:cobrar', (data)->
	# 	tablaServicios.api().ajax.reload()
	# 	if data.userAction is globalUser
	# 		new Alerta data.msg

	# io.on 'servicios:delete', (data)->
	# 	tablaServicios.api().ajax.reload()
	# 	if data.userAction is globalUser
	# 		new Alerta data.msg

	# io.on 'servicios:create', (data)->
	# 	# console.log data.existCliente
	# 	tablaServicios.api().ajax.reload()
	# 	if not data.existCliente
	# 		clientes.push data.servicio.cliente 
	# 	if data.userAction is globalUser
	# 		new Alerta data.msg
	# 		btnClearJq2.trigger 'click'
	
	tablaAlmacenJq = ctnVentasJq.find('table#tabla-almacen')
	contTablaVentaJq = tablaAlmacenJq.parent()
	tablaAlmacen = tablaAlmacenJq.dataTable
		"dom": '<"top"fl>t<"bottom"pi><"clear">'
		"language": {
				"search": "Buscar: ",
				"lengthMenu":"",
				"lengthMenu": "_MENU_",
				"zeroRecords": "Ningun registro encontrado",
				"info": "pagina _PAGE_ de _PAGES_",
				"infoEmpty": "Ningun Registro",
				"infoFiltered": "(fitrado de _MAX_ total registros)"
		 },

		"ajax": '/productos/getAll',
		"columns": [
			{ "data": "_id" }
			{ "data": "fecha" }
			{ "data": "serie" }
			{ "data": "codigo" }
			{ "data": "descripcion" }
			{ "data": "costo" }
			{ "data": "cantidad" }
			{ "data": "utilidad" }
			{ "data": "garantia" }
			{ "data": "proveedor" }
			{ "data": "precio_recibo" }
			{ "data": "precio_factura" }
			{ "data": "idCompra" }
			# { "defaultContent": "<button class='btn btn-primary'>Elegir</button>"}
		]
		"columnDefs": [
			{ "visible": false, "targets": 0 }
			{ "targets": 1, "visible": true, "createdCell":(td, cellData, rowData, row, col)-> 
				time = moment(cellData).format("DD/MMM/YYYY H:mm:ss")
				$(td).text time
				rowData.fecha = time
			}
			{ "visible": true, "targets": 2 }
			{ "targets": 3, "createdCell":(td, cellData, rowData, row, col)-> 
				$(td).addClass('selectable-td').html("<a href='javascript:;'>#{cellData}</a>")
			}
			{ "targets": 4, "createdCell":(td, cellData, rowData, row, col)-> 
				$(td).addClass('selectable-td').html("<a href='javascript:;'>#{cellData}</a>")
			}
			{ "visible": false, "targets": 5 }
			{ "visible": true, "targets": 6 }
			{ "visible": false, "targets": 7 }
			{ "visible": false, "targets": 8 }
			{ "visible": false, "targets": 9 }
			{ "visible": false, "targets": 12 }

			# { "orderable": false, "targets": -1 }
		 ]
		"order": [1, 'asc'],
		# "ordering": false

	showHideMenujq = ctnVentasJq.find('div.show-hide-colms:eq(0)')
	$(document).ajaxComplete (event, xhr, settings)->
		tablaAlmacenJq.css('width', '')
		showHideMenujq.show()
	ctnVentasJq.find('ul.dropdown-cols:eq(0) input:checkbox').on 'click', (event)->
		column = tablaAlmacen.api().column( $(this).attr('data-column') );
		#Toggle the visibility
		if $(this).is(':checked')
			column.visible( true )
		else
			column.visible( false )
		tablaAlmacenJq.css('width', '')

	htmlCantdad = "<form class='form-horizontal'>
			<div class='form-group'>
				<label for='cantidad' class='col-md-3  control-label'>Cantidad:</label>
				<div class='col-md-5'>
					<input type='text' class='form-control upper' id='cantidad' name='cantidad' placeholder='Cantidad a vender' validar='requiere'>
				</div>
			</div><input type='submit' style='width:0px;height:0px;margin:0;padding:0;border:none;'></form>"
	itemElegido = {}
	$('tbody', tablaAlmacenJq).on 'click', 'a', (evt) ->
			evt.preventDefault()
			elTrNode = $(this).parents('tr')[0]
			indexElegido = tablaAlmacen.api().row(elTrNode).index()
			# console.log 'elindice elegido es: '+indexElegido
			# console.log tablaAlmacen.row indexElegido
			# shoppingCart.upOrCreIdexesRows.push indexElegido
			rowTable =  tablaAlmacen.api().row(indexElegido)
			# console.log rowTable
			itemElegido = rowTable.data()
			# console.log itemElegido
			if itemElegido.cantidad*1 > 1
				modalCantidad = new Modal
					titulo:'Cantidad A Vender'
					tipo:'formulario'
					contenido: htmlCantdad
					despuesDeMostrar:(ModalJq)->
						# alert 'ok'
						setTimeout ->
							# alert ModalJq.find('input:text:first').attr('class')
							ModalJq.find('input:text:first').focus()    
						,500
					antesDeMostrar:(ModalJq)->
						ModalJq.find('div.modal-footer button:first').text 'ok' 
				new Validador
					formulario:modalCantidad.jq.find('form:first')
					procesarFormulario:(fromJq)=>
						cantidad = fromJq.find('input:text:first').val()
						if cantidad*1 > itemElegido.cantidad*1
							new Alerta
								tipo:'error'
								titulo:'Error'
								texto: "Solo se dispone de #{itemElegido.cantidad} Productos de este tipo"
								posicion:'arriba-izquierda'
						else
							modalCantidad.cerrar ->
								itemElegido.cantidad = cantidad*1
								io.emit('ventas:addToCart', {item:itemElegido, userAction:globalUser})  
			else
				io.emit('ventas:addToCart', {item:itemElegido, userAction:globalUser})

		inputSearchJq = $('input.input-sm', contTablaVentaJq)
	
	itemsInCartVentas = {}
	addCartProcedure = (item)->
		if itemsInCartVentas[item._id]?
			itemsInCartVentas[item._id].cantidad += item.cantidad 
			txtAreaJq = ctnVentasJq.find("tr##{item._id} textarea").val "#{itemsInCartVentas[item._id].cantidad} #{item.descripcion}"
			txtJq = ctnVentasJq.find("tr##{item._id} input:text")
			precioFactura = item.precio_recibo + iva*item.precio_recibo/100
			preciou = if tipoVenta is 'recibo' then item.precio_recibo*1 else precioFactura
			precio = (preciou*itemsInCartVentas[item._id].cantidad).toFixed(2)
			txtJq.val precio
		else
			itemsInCartVentas[item._id] = item
			btnAddJq = ctnVentasJq.find('form button.btn-info:last')
			trJq = btnAddJq.parent().parent()
			if trJq.find('input:text').val() isnt '' or  trJq.find('textarea').val() isnt ''
				ctnVentasJq.find('form button.btn-info:last').trigger 'click'
				btnAddJq = ctnVentasJq.find('form button.btn-info:last')
				trJq = btnAddJq.parent().parent()
			# trJq.attr 'name', item.idCompra
			# trJq.attr 'cantidad', item.cantidad
			precioFactura = item.precio_recibo + iva*item.precio_recibo/100
			preciou = if tipoVenta is 'recibo' then item.precio_recibo*1 else precioFactura
			precio = (preciou*item.cantidad).toFixed(2)

			trJq.find('input:text').val precio
			 # (Pu.: #{preciou} )
			textareaJq = trJq.find('textarea').attr('disabled','disabled').val if item.serie is '----------' then "#{item.cantidad} #{item.descripcion}" else "#{item.cantidad} #{item.descripcion} (Serie: #{item.serie} )"
			textareaJq.attr 'rows', (textareaJq.val().length/40) + 1
			trJq.attr 'id', item._id
			totalJq2.text sumarCols()

	# tabla ventas sera.
	tablaVentasJq = ctnVentasJq.find('table#tabla-ventas-realizadas')
	tablaVentas = tablaVentasJq.dataTable
		"dom": '<"top"fl>t<"bottom"pi><"clear">'
		"language": {
				"search": "Buscar: ",
				"lengthMenu":"",
				"lengthMenu": "_MENU_",
				"zeroRecords": "Ningun registro encontrado",
				"info": "pagina _PAGE_ de _PAGES_",
				"infoEmpty": "Ningun Registro",
				"infoFiltered": "(fitrado de _MAX_ total registros)"
		 },

		"ajax": '/ventas/getAll',
		"columns": [
			{ "data": "_id" },
			{ "data": "fecha" },
			{ "data": "cliente" },
			{ "data": "descripcionCorta" },
			{ "data": "descripcion" },
			{ "data": "items" },
			{ "data": "monto" },
			{ "data": "tipo" },
			# { "data": "cobro" },
			{ "data": "nroComprobante" },
			{ "data": "cancelacion" },#btn-circle 
			# { "data": "idsCompra" },#btn-circle 
			{ "defaultContent": '<button type="button" class="btn btn-danger btn-xs" alt="eliminar"><i class="fa fa-times"></i></button> <button type="button" class="btn btn-info btn-xs" alt="editar"><i class="fa fa-pencil"></i></button>'}
		],
		"columnDefs": [
			{ "visible": false, "targets": 0 },
			
			{ "targets": 1, "visible": true, "createdCell":(td, cellData, rowData, row, col)->
				# console.log 
				$(td).attr 'name', rowData._id
				time = moment(new Date(cellData)).format("DD/MMM/YYYY H:mm:ss")#H:mm:ss
				$(td).text time
				# rowData.fecha = time
			},
			{ "visible": false, "targets": 4 }, 
			{ "visible": false, "targets": 5 } 
			# { "visible": false, "targets": 9 },

			# { "targets": 6, "visible": true, "createdCell":(td, cellData, rowData, row, col)->
			# 	tdJq = $(td)
			# 	if cellData is 'pendiente'
			# 		tdJq.html("<span class='label label-danger selectable-red'>#{cellData}</span>")
			# 	else
			# 		# if rowData.cliente.toUpperCase() in clientesContrato
			# 		#   tdJq.text 'contrato'
			# 		#   rowData.fecha_cancel = ''
			# 		# else
			# 		tdJq.html("<span class='label label-success'>#{cellData}</span>")
			# } 

			# { "targets": 6, "visible": true, "createdCell":(td, cellData, rowData, row, col)->
			#   if cellData isnt ''
			#     time = moment(cellData).format("DD/MMM/YYYY H:mm:ss")#H:mm:ss
			#     $(td).text time
			#     # rowData.fecha = time
			# } 

		],
		"order": [1, 'desc']
	# tablaVentas.order(1, 'desc')

	$(document).ajaxComplete (event, xhr, settings)->
		tablaVentasJq.css('width', '')
	# ELIMINAR VENTA.
	tablaVentasJq.on 'click', 'button.btn-danger', (e)->
		elTrNode = $(this).parents('tr')[0]
		indexElegido = tablaVentas.api().row(elTrNode).index()
		rowTable = tablaVentas.api().row(indexElegido)
		itemElegido = rowTable.data()

		console.log itemElegido
		modalConfirm = new Modal
			titulo:'Confirmar - Eliminar Venta'
			tipo:'confirmacion'
			contenido:"
			<div class='radio'>
				<label>
					<input type='radio' name='optionsRadios' id='optionsRadios1' value='option1' checked>
					Eliminar Venta <span class='label label-info'>Restaurando</span> los items a Almacen
				</label>
			</div>
			<div class='radio'>
				<label>
					<input type='radio' name='optionsRadios' id='optionsRadios2' value='option2'>
					Eliminar Venta <span class='label label-info'>Sin Restaurar</span> Lo items a Almacen
				</label>
			</div>"
			accionSi:()=>
				if modalConfirm.jq.find('#optionsRadios1').is ':checked'
					io.emit('ventas:deleteRestore', {id:itemElegido._id, userAction:globalUser})
				else
					io.emit('ventas:delete', {id:itemElegido._id, userAction:globalUser})
				modalConfirm.cerrar =>
					
			antesDeMostrar:(jqModal)->
				jqModal.find('button:last').text('Cancelar').click (e)->
					modalConfirm.cerrar()

	# EDITAR VENTA.
	tablaVentasJq.on 'click', 'button.btn-info', (e)->
		elTrNode = $(this).parents('tr')[0]
		indexElegido = tablaVentas.api().row(elTrNode).index()
		rowTable = tablaVentas.api().row(indexElegido)
		itemElegido = rowTable.data()
		# console.log itemElegido

		$.ajax
			url:'/reportes/makeRecibo/'
			type:'POST'
			dataType:'json'
			data:"data=#{JSON.stringify itemElegido}"
			success:(resp)->
				# console.log resp
				window.open("/reportes/viewRecibo/", "report", "toolbar=no, scrollbars=yes, resizable=yes, location=no, menubar=no, top=50, left=250, width=700, height=400");

			error:->
				alert 'error in server'

		# modalJq = undefined
		# elsJq = undefined
		# dateTime1 = undefined
		# dateTime2 = undefined

		# modalEditarServicio = new Modal
		# 	titulo:'Editar - Venta'
		# 	tipo:'formulario' 
		# 	contenido:formHtmlEditarServicio
		# 	despuesDeMostrar:(ModalJq)=>
		# 		modalJq = ModalJq
		# 		dateTime1 = $('#datetimepicker2').datetimepicker()

		# 		dateTime2 = $('#datetimepicker1').datetimepicker()
				
		# 		jqFecha = ModalJq.find('input:text:first')
		# 		montoJq = ModalJq.find('input:text:eq(2)')

		# 		clienteJq = ModalJq.find('input:text:eq(1)')

		# 		clienteJq.typeahead
		# 			source: clientes

		# 		setTimeout ->
		# 			# alert ModalJq.find('input:text:first').attr('class')
		# 			jqFecha.focus()   
		# 		,500

		# 		ModalJq.find('select').on 'change', ->
		# 			if $(this).val() in ['contrato', 'pendiente']
		# 				montoJq.val 0
		# 				$(elsJq[5]).val ''

			
		# 	antesDeMostrar:(ModalJq)=>
		# 		tdsJq = $(this).parent().parent().find('td')
		# 		elsJq = ModalJq.find('input:text, select, textarea').each (index)->
		# 			$(this).val $(tdsJq[index]).text()

		# new Validador
		# 	formulario:modalJq
		# 	procesarFormulario:(formJq)=>
		# 		io.emit('servicios:editar', {id:$(this).parent().parent().find('td:first').attr('name'), servicio:{fecha:$(elsJq[0]).val(), cliente:$(elsJq[1]).val(), descripcion:$(elsJq[2]).val(), cobro:$(elsJq[3]).val(), monto:$(elsJq[4]).val(),  fecha_cancel:$(elsJq[5]).val()}, userAction:globalUser})
		# 		modalEditarServicio.cerrar()


	clienteJq = ctnVentasJq.find('input#cliente-venta')
	ivaJqVenta = ctnVentasJq.find('input#iva-venta').on 'keyup', (e)->
		ivaAnt = iva*1
		console.log 'iva '+iva
		iva = ivaJqVenta.val()*1
		sum  = 0
		tbodyFormJq.find('input:text').each (ind)->
			valor = $(this).val()*1
			if valor
				# valor anterior sin porcentaje.
				valorAnt = 100*valor/(100+ivaAnt)# cienporciento.
				console.log 'valor '+valor
				console.log 'ivaAnt '+ivaAnt

				console.log 'anterior '+valorAnt
				#nuevo valor.
				
				porcen = valorAnt*iva/100
				valorcalc = valorAnt + porcen
				
				$(this).val valorcalc.toFixed(2)      
				sum += valorcalc
		totalJq2.text sum.toFixed(2)

	hideShowIvaJq = ivaJqVenta.parent()
	# hideShowIvaJq.push ivaJqVenta.parent().prev()[0]
	# hideShowIvaJq.hide()

	clienteJq.typeahead
		source:-> clientes
		updater:(cliente)->
			setTimeout ->
				tbodyFormJq.find('textarea#descripcion-venta:first').focus()
			,0 
			cliente

	formNuevoServJq = ctnVentasJq.find('form#formu-nueva-venta')
	tbodyFormJq = formNuevoServJq.find('tbody:eq(1)')
	totalJq2 = formNuevoServJq.find('tfoot th:eq(1)')
	rowSelectedJq = undefined
	rowText = '<tr>
							<td><textarea class="form-control input-sm" rows="1" id="descripcion-venta" name="descripcion-venta" placeholder="Descripcion del producto ó servicio" validar="requiere"></textarea></td>
							<td><input type="text" class="form-control input-sm" autocomplete="off" id="precio-venta" name="precio-venta" placeholder="Precio del producto ó servicio" validar="real"></td>
							<td>
								<button type="button" class="btn btn-danger btn-sm" tabindex="-1" alt="eliminar"><i class="fa fa-times"></i></button>
								<button type="button" class="btn btn-info btn-sm" tabindex="-1"><i class="fa fa-plus fa-fw"></i> </button>
							</td>
						</tr>'

	tbodyFormJq.on 'keyup', 'textarea', (e)->
		textareaJq = $(this)
		if e.keyCode is 13
			textareaJq.val ($.trim textareaJq.val())+' '
			
		textareaJq.attr 'rows', (textareaJq.val().length/40) + 1
	
	tbodyFormJq.on 'click', 'button.btn-info', (e)->
		$(this).parent().html '<button type="button" class="btn btn-danger btn-sm" tabindex="-1" alt="eliminar"><i class="fa fa-times"></i></button>'  
		rowAddJq = $(rowText).appendTo(tbodyFormJq)
		validadorNuevaVenta.reiniciar()
		# validadorNuevaVenta.addItem rowAddJq.find('textarea')
		# validadorNuevaVenta.addItem rowAddJq.find('input:text')
		setTimeout ->
			rowAddJq.find('textarea:first').focus()
		,100


	tbodyFormJq.on 'click', 'button.btn-danger', (e)->
		trJq = $(this).parent().parent()
		id = trJq.attr('id')
		if id isnt undefined#es item de almacen
			# console.log itemsInCartVentas[id]
			# console.log itemsInCartVentas
			delete itemsInCartVentas[id]
			# console.log itemsInCartVentas
			io.emit('ventas:delToCart', {id:id, userAction:globalUser})

		trPibotJq = trJq.prev()
		if $(this).next().length
			tdAntJq = trPibotJq.find('td:last')
			if trPibotJq.prev().length
				# hay mas de uno.
				tdAntJq.html '<button type="button" class="btn btn-danger btn-sm" tabindex="-1" alt="eliminar"><i class="fa fa-times"></i></button> <button type="button" class="btn btn-info btn-sm"><i class="fa fa-plus fa-fw"></i> </button>'
			else
				#hay uno solo.
				tdAntJq.html '<button type="button" class="btn btn-info btn-sm" tabindex="-1"><i class="fa fa-plus fa-fw"></i></button>'
			trJq.remove()

		else
			nextJq = trJq.next()
			if trPibotJq.length is 0 and nextJq.next().length is 0
				#hay uno solo.
				nextJq.find('td:last').html '<button type="button" class="btn btn-info btn-sm" tabindex="-1"><i class="fa fa-plus fa-fw"></i> </button>'
			
			trJq.remove()
		totalJq2.text sumarCols()
		validadorNuevaVenta.reiniciar()
		

	sumarCols = ->
		sum = 0
		tbodyFormJq.find('input:text').each (ind)->
			sum += $(this).val()*1
		sum.toFixed 2
	
	tipoVenta = 'recibo'
	radiosJq = formNuevoServJq.find('input:radio').on 'change', (e)->

		tipoVenta = $(this).val()
		sum  = 0
		
		tbodyFormJq.find('input:text').each (ind)->
			valor = $(this).val()*1
			if valor
				iva = ivaJqVenta.val()*1
				porcen = valor*iva/100
				if tipoVenta is 'factura'
					hideShowIvaJq.show()
					valorcalc = valor + porcen
				else
					hideShowIvaJq.hide()
					valorcalc = 100*valor/(100+iva)# cienporciento.
				$(this).val valorcalc.toFixed(2)      
				sum += valorcalc
		totalJq2.text sum.toFixed(2)
	
	reciboRadiojq = $(radiosJq[0]) 

	tbodyFormJq.on 'change keyup', 'input:text', (e)->
		totalJq2.text sumarCols()

	btnClearJq2 = $('button#btn-clear-form', ctnVentasJq).on 'click', (e)->
		trsJq = tbodyFormJq.find('tr')
		for trJq, i in trsJq
			if $(trJq).attr('id') isnt undefined 
				itemsInCartVentas = {}
				io.emit('ventas:cancelShopp', {userAction:globalUser})
				break
		reciboRadiojq.trigger 'click'
		clienteJq.val ''
		trJq = tbodyFormJq.html(rowText)
		trJq.find('button.btn-danger').remove()
		totalJq2.text ''
		validadorNuevaVenta.reiniciar()

		setTimeout ->
			clienteJq.focus()
			# trJq.find('textarea:first').focus()
		,10

	tablaVentasJq.on 'click', 'span.selectable-red', (e)->
		elTrNode = $(this).parents('tr')[0]
		indexElegido = tablaVentas.api().row(elTrNode).index()
		rowTable = tablaVentas.api().row(indexElegido)
		itemElegido = rowTable.data()

		montoJq = undefined
		modalCobrar = new Modal
			titulo:'Cobrar Venta'
			tipo:'formulario'
			contenido: htmlFormCobrar
			despuesDeMostrar:(ModalJq)=>
				montoJq = ModalJq.find('input:text:first')
				montoJq.val(itemElegido.monto)
				setTimeout ->
					# alert ModalJq.find('input:text:first').attr('class')
					montoJq.select()   
				,500
			antesDeMostrar:(ModalJq)=>
				ModalJq.find('div.modal-footer button:first').text 'ok'

		
		new Validador
			formulario:modalCobrar.jq.find('form:first')
			procesarFormulario:(formJq)=>
				if montoJq.val()*1 > itemElegido.monto
					new Alerta
						tipo:'error'
						titulo:'Error'
						texto: "Elija un monto menor o igua a #{itemElegido.monto}"
						posicion:'arriba-izquierda'
				else
					# alert $(this).parent().parent().find('td:first').attr('name')
					modalCobrar.cerrar =>
						io.emit('ventas:cobrar', {id:itemElegido._id, monto:montoJq.val()*1, userAction:globalUser})

	htmlConfVenta = "<table class='table table-striped conf-venta-table'>
		<thead>
			<tr>
				<th>Descripcion</th>
				<th>Subtotal</th>
			</tr>
		</thead>
		<tbody></tbody>
		<tfoot>
			<tr>
				<th>Total (Bs.)</th>
				<th></th>
			</tr>
		</tfoot>
	</table>"

	#CONFIRMAR VENTA.
	nroComprobanteJq = undefined
	nrodeventa = undefined
	cancelacionVar = undefined
	validadorNuevaVenta = new Validador
		formulario:formNuevoServJq
		procesarFormulario:(formJq)->
			# alert $(this).parent().parent().find('td:first').attr('name')
			modConfirmar = new Modal
				titulo:'Confirmar Venta' 
				tipo:'confirmacion'
				#icono:'images/admin/icons/packs/fugue/24x24/alert.png'
				contenido: htmlConfVenta 
				accionSi:->
					nrodeventa.trigger 'submit'
					if not nroComprobanteJq.next().is(':visible')
						nuevosItems = []
						# console.log itemsInCartVentas
						tbodyFormJq.find('tr').each (i)->
							trJq = $(this) 
							id = trJq.attr('id')
							if id isnt undefined#es item de almacen
								# console.log itemsInCartVentas[id]
								item =  itemsInCartVentas[id]
							else
								item = {}
								item.descripcion = trJq.find('textarea').val() 
								item.cantidad = 1
							item.precio = trJq.find('input:text').val()*1 
							nuevosItems.push item
						modConfirmar.cerrar ->
							console.log nuevosItems
							io.emit('ventas:shopp', {cliente:clienteJq.val(),iva:ivaJqVenta.val(), tipoVenta:tipoVenta, nroComprobante:$.trim(nroComprobanteJq.val()), cancelacion:cancelacionVar, items:nuevosItems, userAction:globalUser})#emitir. al servidor, en vez de ajax.
				antesDeMostrar:(mjq)->
					cancelacionVar = 'pendiente'
					tbodyJq = mjq.find 'tbody'
					pharaGrapsJq = $("<div><p><strong>Cliente: </strong>#{clienteJq.val()}</p><p><strong>Comprobante: </strong></p> <p><strong>Cancelacion:</strong><label class='radio-inline'><input type='radio' class='cancelacion' name='inlineRadioOptions1' checked='checked' value='pendiente'>Pendiente</label><label class='radio-inline'><input type='radio' class='cancelacion' name='inlineRadioOptions1' value='cancelada'>Cancelada</label></p></div>").insertBefore(tbodyJq.parent())
					newRadiosJq = reciboRadiojq.parent().parent().find('label').clone().appendTo(pharaGrapsJq.find('p:eq(1)')).find('input:radio').on 'change', (e)->
						$(radiosJq[newRadiosJq.index(this)]).trigger 'click' 
						html = ''
						tbodyFormJq.find('tr').each (i)->
							descripcion = $(this).find('textarea').val()
							subtotal = $(this).find('input:text').val()
							html += "<tr><td>#{descripcion}</td><td>#{subtotal}</td></tr>"  
						tbodyJq.html html 
						mjq.find('tfoot th:last').text totalJq2.text()
						nrodeventa.find('strong').text "N.#{tipoVenta}:" 
						if tipoVenta is 'factura'
							nroComprobanteJq.val NroFactura
						else
							nroComprobanteJq.val NroRecibo
					pharaGrapsJq.find('input.cancelacion').on 'change', ->
						cancelacionVar = $(this).val()
					nrodeventa = $("<form style='position: fixed;top: 73px;right: 17px;' class='col-md-3'><strong>N.#{tipoVenta}:</strong><input type='text' class='form-control input-sm' style='background-color:lime;' validar='real'></input></form>").appendTo pharaGrapsJq
					new Validador
						formulario:nrodeventa
						procesarFormulario:(formJq)->
							nroComprobanteJq = formJq.find('input:text')
					nroComprobanteJq = nrodeventa.find('input:text')
					if tipoVenta is 'factura'
						nroComprobanteJq.val NroFactura
					else
						nroComprobanteJq.val NroRecibo
					# newRadiosJq.val tipoVenta
						# alert 'ok'
					# $("<p><strong>Cancelacion con</strong>: #{tipoVenta}</p>").insertBefore tbodyJq.parent()

					tbodyFormJq.find('tr').each (i)->
						descripcion = $(this).find('textarea').val()
						subtotal = $(this).find('input:text').val()
						$("<tr><td>#{descripcion}</td><td>#{subtotal}</td></tr>").appendTo tbodyJq  
					mjq.find('tfoot th:last').text totalJq2.text()  
				# despuesDeCerrar:(mjq)=>
				#   @panelJq.removeClass().addClass('panel panel-info')

	#DETALLES DE LA VENTA
	ctnVentasJq.on 'click', 'span.label-descripcion', (e)->
		elTrNode = $(this).parents('tr')[0]
		indexElegido = tablaVentas.api().row(elTrNode).index()
		rowTable = tablaVentas.api().row(indexElegido)
		itemElegido = rowTable.data()
		# console.log itemElegido

		modalDescripcion = new Modal
			titulo:'Detalles de la Venta' 
			tipo:'alerta'
			contenido: htmlConfVenta
			antesDeMostrar:(mjq)->
				tbodyHtml = ""
				tbodyJq = mjq.find 'tbody'
				pharaGrapsJq = $("<ul><li><strong>Cliente: </strong>#{itemElegido.cliente}</li><li><strong>Tipo Cancelacion: </strong>#{itemElegido.tipo}</li><li><strong>Fecha De Emicion: </strong>#{itemElegido.fecha_emision}</li><li><strong>Fecha Cancelacion: </strong>#{itemElegido.fecha_cancel}</li></ul>").insertBefore(tbodyJq.parent())
				# nitems = itemElegido.descripcion.split('e1n1d1e1d1o1f1c1a1d')
				# console.log nitems
				for nitem in itemElegido.items
					if nitem.cantidad isnt undefined
						tbodyHtml += "<tr><td><strong>#{nitem.cantidad}</strong> #{nitem.descripcion} (serie:#{nitem.serie})</td><td>#{nitem.precio}</td></tr>"
					else
						tbodyHtml += "<tr><td>#{nitem.descripcion}</td><td>#{nitem.precio}</td></tr>"

				tbodyJq.html tbodyHtml
				mjq.find('tfoot th:last').text itemElegido.monto				

	# reporte en word.
	# inputSearchJq2 = $('input.input-sm', tablaVentasJq)

	settingsg = undefined
	tablaVentasJq.on 'search.dt', (e, settings)->
		settingsg =  settings

	# ctnVentasJq.find('button.pdf').on 'click', (e)->
	# 	querySelect = ''
	# 	querySort = ''

	# 	fields = []
	# 	tablaVentasJq.find('th').each (i)->
	# 		fields.push $(this).attr('iden')
	# 	fields.pop()
		
	# 	fieldSortJq = tablaVentasJq.find('th.sorting_desc, th.sorting_asc')
	# 	fieldSort = fieldSortJq.attr('iden')
	# 	sort = if fieldSortJq.attr('class') is 'sorting_desc' then '-' else ''
		
	# 	querySelect = fields.join(' ')
	# 	querySort = sort+fieldSort
	# 	# console.log querySelect
	# 	# console.log querySort
	# 	textFilter = $.trim(tablaVentas.api().settings().search())

	# 	$.ajax
	# 		url:'/reportes/makeReport2/'
	# 		jsonp: "callback"
	# 		dataType:'jsonp'
	# 		data:
	# 			querySelect:querySelect
	# 			querySort:querySort
	# 			textFilter:textFilter
	# 		success:(resp)->
	# 			console.log resp
	# 			window.open("/reportes/viewReport/", "report", "toolbar=no, scrollbars=yes, resizable=yes, location=no, menubar=no, top=50, left=250, width=700, height=400");

	# 		error:->
	# 			alert 'error on this server'
	


	ctnVentasJq.find('button.pdf').on 'click', (e)->

		# console.log tablaVentas.fnGetDisplayRows()
		# para enviar una gran cantidad de datos usar post.
		# visibles = []
		# for i in settingsg.aiDisplay
		# 	visible =  settingsg.aoData[i]._aData
		# 	visibles.push visible
		# console.log tablaVentas.fnGetDisplayRows()
		$.ajax
			url:'/reportes/makeReport/'
			type:'POST'
			dataType:'json'
			data:"data=#{JSON.stringify {ventas:tablaVentas.fnGetDisplayRows(), fecha:new Date(), parametros:$.trim(tablaVentas.api().settings().search())}}"
			success:(resp)->
				console.log resp
				window.open("/reportes/viewReport/", "report", "toolbar=no, scrollbars=yes, resizable=yes, location=no, menubar=no, top=50, left=250, width=700, height=400");

			error:->
				alert 'error in server'
		# tablaVentas.
		# visibles = []
		# first = undefined

		# for i in settingsg.aiDisplay
		# 	first =  settingsg.aoData[i]._aData
		# 	visibles.push first
		
		# for i in [0..100]
		# 	visibles.push first
		# console.log visibles

	
	
		# alert $.trim(inputSearchJq2.val())
																				#			0,1,2,etc	asc or desc, true, false, etc
		# window.open("/reportes/word/VentasModel/#{querySelect}/#{querySort}/#{textFilter}", "report", "toolbar=no, scrollbars=yes, resizable=yes, location=no, menubar=no, top=50, left=250, width=700, height=400");

		# alert 'ok'
					
	# shoppingCart.addRow {series:'DDS-124', codigo:'XXX', descripcion:'Descripcion de XXX', costo:1456, cantidad:4, utilidad:178, garantia:'1 anio'}
	`$(window).on('beforeunload', function(e) {
			io.emit('ventas:cancelShopp', {
				userAction: globalUser
			});
		})`
########################################### USUARIOS.#############################################################################

allUsers = {}

serializeForm2 = (formJq)->
	data = {}
	formJq.find('input:text, select').each (i)->
		elJq = $(this)
		data[elJq.attr('name')] = elJq.val()
	privilegios = []
	formJq.find('div.privilegios input:checkbox').each (i)->
		elJq = $(this)
		if elJq.is ':checked'
			privilegios.push elJq.attr 'name' 
	data.privilegios = privilegios
	pass = formJq.find('#rewPass').val()
	data.password = pass if pass isnt '' 
	data

formHtml = (opt)->
	htmlForm = "<form class='form-horizontal'role='form'>"
	htmlForm += "<div class='form-group'>
		<label for='name' class='col-lg-3 control-label'>Nombre</label>
		<div class='col-lg-8'>
			<input type='text' autofocus class='form-control' id='name' name='name' validar='requiere'>
		</div>
	</div>
	<div class='form-group'>
			<label for='email' class='col-lg-3 control-label'>Email</label>
			<div class='col-lg-8'>
				<input type='text' class='form-control' id='email' name='email' validar='email'>
			</div>
		</div>"
		# <label class='checkbox'>
		#   <input type='checkbox' name='inicio'> Inicio 
		# </label>
	htmlForm += "<div class='form-group'>
		<label for='privilegios' class='col-lg-3 control-label'>Privilegios</label>
		<div class='col-lg-8'>
			<div id='blk-privilegio' class='privilegios' validar='especial'>
				<label class='checkbox'>
					<input type='checkbox' name='estadisticas'> Estadisticas
				</label>
				<label class='checkbox'>
					<input type='checkbox' name='comprar'> Comprar
				</label>
				<label class='checkbox'>
					<input type='checkbox' name='vender'> Vender 
				</label>
				<label class='checkbox'>
					<input type='checkbox' name='ventas'> Ventas
				</label>
				<label class='checkbox'>
					<input type='checkbox' name='reportes'> Reportes
				</label>
				<label class='checkbox'>
					<input type='checkbox' name='clientes'> Admin. Clientes
				</label>
				<label class='checkbox'>
					<input type='checkbox' name='proveedores'> Admin. Proveedores
				</label>
				<label class='checkbox'>
					<input type='checkbox' name='usuarios'> Admin. Usuarios
				</label>
			</div>
		</div>
	</div>"
	htmlForm += "<div class='form-group'>
		<label for='estado' class='col-lg-3 control-label'>Estado</label>
		<div class='col-lg-8'>
			<select type='text' class='form-control' id='estado' name='estado' validar='requiere'>
				<option></option>
				<option>Habilitado</option>
				<option>Bloqueado</option>
			</select>
		</div>
	</div>"
	if opt is 'edit'
		htmlForm += "<div class='form-group chk'>
			<div class='col-lg-offset-2 col-lg-10'>
				<div class='checkbox'>
					<label>
						<input type='checkbox' name='chk'> Cambiar Password
					</label>
				</div>
			</div>
		</div>"
		htmlForm += "<div class='cnt-pass' style='display:none;'>"
	else
		htmlForm += "<div class='cnt-pass'>"
	arrayPass = {newPass:'Password', rewPass:'Reescribir pass'}#oldPass:'Anterio pass', 
	for key, val of arrayPass
		htmlForm += "<div class='form-group'>
			<label for='#{key}' class='col-lg-3 control-label'>#{val}</label>
			<div class='col-lg-8'>
				<input type='password' class='form-control' id='#{key}' name='#{key}' validar='requiere#{if key is "rewPass" then ",igual_a|newPass" else ""}'>
			</div>
		</div>" 
	htmlForm += "</div></form>"
	htmlForm
class User
	constructor: (@options = {}) ->
		@html = "<div class='col-lg-5' id='#{@options._id}' >
			<div class='panel panel-info'>
				<div class='panel-heading'>
					<i class='fa fa-user fa-2x'></i> <strong>#{@options.name}</strong>
				</div>
				<div class='panel-body'>
					<p><strong>Email: </strong>#{@options.email}</p>          
					<p><strong>Privilegio: </strong>#{@options.privilegios}</p>         
					<p><strong>Estado: </strong>#{@options.estado}</p>          
				</div>
				<div class='panel-footer'>
					<div class='btn-group btn-group-sm'>
						<button type='button' class='btn btn-info'><i class='fa fa-pencil fa-fw'></i> Editar</button>
						<button type='button' class='btn btn-danger'><i class='fa fa-minus fa-fw'></i> Eliminar</button>
					</div>
				</div>
			</div>
		</div>"
	
		###
			<select type='text' class='form-control' id='#{key}' name='#{key}' validar='requiere'>
				<option></option>
				<option>Administrador</option>
				<option>Empleado</option>
			</select>
		###
	addTo:(jqElement)->
		@jq = $(@html).appendTo jqElement
		@panelJq = $('div.panel', @jq)
		$('button:first', @jq).click (e)=> 
			@panelJq.removeClass().addClass('panel panel-danger')
			@edit()
		$('button:last', @jq).click (e)=> 
			@panelJq.removeClass().addClass('panel panel-danger')
			@delete()
			
	delete:->
		# first confirm
		modConfirmar = new Modal
			titulo:if @options.name is globalUser then 'Eliminar - Usuario (<small>El sitema se reinicia</small>)' else 'Eliminar - Usuario' 
			tipo:'confirmacion'
			#icono:'images/admin/icons/packs/fugue/24x24/alert.png'
			contenido: "Realmente desea eliminar este usuario?"
			accionSi:() =>
				modConfirmar.cerrar =>
					io.emit('users:delete', {id:@options._id, userDelete:@options.name, userAction:globalUser})#emitir. al servidor, en vez de ajax.
					
			despuesDeCerrar:(mjq)=>
				@panelJq.removeClass().addClass('panel panel-info')
	edit:->
		editModal = new Modal
			titulo:if @options.name is globalUser then 'Editar - Usuario (<small>El sitema se reinicia</small>)' else 'Editar - Usuario' 
			tipo:'formulario'
			contenido:formHtml('edit')
			antesDeMostrar:(jq)=>
				ctnPassJq = $('div.cnt-pass')
				$('div.chk input:checkbox', jq).click ->
					if $(this).is(':checked')
						ctnPassJq.show()
					else
						ctnPassJq.hide()
				jq.find("input##{key}, select##{key}").val val for key, val of @options when key isnt '_id'
				privilegios = @options.privilegios
				jq.find('div#blk-privilegio input:checkbox').each (e)->
					elChkJq = $(this)
					if _.indexOf(privilegios, $.trim(elChkJq.attr('name'))) isnt -1
						elChkJq.trigger 'click'     

			despuesDeCerrar:(mjq)=>
				@panelJq.removeClass().addClass('panel panel-info')
				
		new Validador
			formulario:editModal.jq.find('form:first')
			procesarFormulario:(formJq)=>
				# alert formJq.serialize()
				console.log serializeForm2(formJq)
				editModal.cerrar =>
					io.emit('users:edit', {id:@options._id, newData:serializeForm2(formJq), userAction:globalUser, useredit:@options.name})#emitir. al servidor, en vez de ajax.

				# $.ajax
				#   url:"usuarios/saveUser/#{@options.id}/"
				#   type:'GET'
				#   data:formJq.serialize()
				#   dataType:'json'
				#   success:(resp)=>
				#     msg = resp.msg
				#     if msg.tipo is 'exito'
				#       editModal.cerrar =>
				#         @updateHtml(resp.user)
				#         @pbodyJq.effect('highlight', {}, 5000)
				#       new Alerta msg
				#       if beforeNick is globaUser
				#         setTimeout ->
				#           window.location.replace('logout')
				#         ,2000
				#     else
				#       new Alerta msg

	updateHtml:(newData)->
		(@options[key] = val if @options[key]) for key, val of newData
		$('div.panel-heading strong', @jq).text @options.name
		$('div.panel-body', @jq).html "<p><strong>Email: </strong>#{@options.email}</p><p><strong>Privilegio: </strong>#{@options.privilegios}</p><p><strong>Estado: </strong>#{@options.estado}</p>"         

$(document).ready ->
	contentJq = $('div.users-content')#.sortable {items: 'div.col-lg-4'}

	#escuchadores de acciones (para modificar el DOM tags html).
	io.on 'users:create', (data)->
		if data.msg.tipo is 'exito'
			user = new User data.user
			user.addTo contentJq
			allUsers[data.user._id] = user
			
			console.log data.userAction+'---'+globalUser
			if data.userAction isnt globalUser# para los otros usuarios.
				data.msg.tipo = 'info'
				data.msg.titulo = 'Informacion'
				data.msg.texto = "El usuario <strong>#{data.userCreate}</strong>a sido creado"
			new Alerta data.msg
		else
			if data.userAction is globalUser
				new Alerta data.msg 

	io.on 'users:delete', (data)->
		console.log data
		msg = data.msg
		el = allUsers[data.id]
		el.jq.fadeOut 'medium', ->
			el.jq.remove()
			`delete el`
			if data.userAction isnt globalUser# para los otros usuarios.
				msg.tipo = 'info'
				msg.titulo = 'Informacion'
				msg.texto = "!El usuario <strong>#{data.userDelete}</strong> a sido eliminado."
			new Alerta msg
		if data.userDelete is globalUser
			setTimeout ->
				window.location.replace('/')
			,2000

	# updateHtml = (newData)->
	#   (@options[key] = val if @options[key]) for key, val of newData
	#   $('div.panel-heading strong', @jq).text @options.name
	#   $('div.panel-body', @jq).html "<p><strong>Email: </strong>#{@options.email}</p><p><strong>Privilegio: </strong>#{@options.privilegios}</p><p><strong>Estado: </strong>#{@options.estado}</p>"         

	io.on 'users:edit', (data)->
		user = allUsers[data.id]
		user.updateHtml data.newData
		if data.userAction is globalUser
			new Alerta data.msg
			
		if data.useredit is globalUser
			data.msg.tipo = 'info'
			data.msg.titulo = 'Informacion'
			data.msg.texto = "!Tu cuenta a sido modificada el sistema se reiniciara."
			new Alerta data.msg
			setTimeout ->
				window.location.replace('/')
			,2000

		# updateHtml.call(data.userObj, data.newData)
		# msg = data.resp.msg
		# if msg.tipo is 'exito'
		#   @updateHtml(resp.user)
		#   @pbodyJq.effect('highlight', {}, 5000)
		#   new Alerta msg
		#   if beforeNick is globaUser
		#     setTimeout ->
		#       window.location.replace('logout')
		#     ,2000
		# else
		#   new Alerta msg
	
	# elmesFormAdd = $('div#addUser input:text, div#addUser input:password, div#addUser select').val ''
	# chekboxesJq = $('input:checkbox')
	# clearFunc = ->
	#   elmesFormAdd.val ''
	#   chekboxesJq.each (indx)->
	#     thisEljq = $(this)
	#     thisEljq.trigger('click') if thisEljq.is(':checked')

	#   val.ocultarMensajes()
	#   setTimeout ->
	#     $(elmesFormAdd[0]).focus()
	#   ,0 
	# $('div#addUser').on('show.bs.collapse', -> clearFunc())
	# $('div.col-md-offset-3 button:first').click -> clearFunc()
	$('button#btn-addUser').on 'click', (e)->
		addUserModal = new Modal
			titulo:'Nuevo - Usuario' 
			tipo:'formulario'
			contenido:formHtml('add')
			despuesDeMostrar:(jq)->
				setTimeout ->
					jq.find('input#name').focus()
				,800
	
		val = new Validador
			formulario:addUserModal.jq.find('form')
			procesarFormulario:(jqForm)->
				#console.log serializeForm2(jqForm)
				addUserModal.cerrar ->
					dataUser = serializeForm2(jqForm)
					# console.log dataUser
					# console.log globalUser
					io.emit('users:create', {usuario:dataUser, userAction:globalUser, userCreate:dataUser.name})#emitir. al servidor, en vez de ajax.

			# CREAR NUEVO USUARIO.
				# alert jqForm.serialize()
				# $.ajax
				#   url:'usuarios/saveUser/'
				#   type:'GET'
				#   dataType:'json'
				#   data:jqForm.serialize()
				#   success:(resp)->
				#     msg = resp.msg
				#     if msg.tipo is 'exito'
				#       user = new User resp.user
				#       clearFunc()
				#       user.addTo contentJq
				#       user.jq.hide()
				#       user.jq.fadeIn 'slow', ->
				#         new Alerta resp.msg
								
				#     else
				#       new Alerta resp.msg

	$.ajax
		url:'/users/getAll'
		jsonp: "callback"
		dataType:'jsonp'
		success:(users)->
			for useri, i in users
				user = new User useri 
				user.addTo contentJq
				
				allUsers[useri._id] = user
				
	# console.log window

# navbar left control.

headerTitleJq = $('h1#page-header')
ctnMainJq = $('div#main-ctn')
divRowsJq = ctnMainJq.find('div.row')
lisJq = $('ul#side-menu li.tile div').on 'click', (e)->
	e.preventDefault()
	divRowsJq.hide()
	lisJq.removeClass('clicki')
	txt = $.trim($(this).text())
	$(this).addClass 'clicki'
	# $(this).parent().html "<tag1><a href='#{txt}'><i class='fa fa-arrow-right fa-fw'></i> #{txt}</a></tag1>"
	headerTitleJq.text txt.toUpperCase()
	elegidoJq = ctnMainJq.find("div##{txt}-ctn")
	elegidoJq.show() unless elegidoJq.is ':visible'
		
txt2 = $.trim($(lisJq[0]).text())
headerTitleJq.text txt2.toUpperCase()

ctnMainJq.find("div##{txt2}-ctn").show()

###########################################################CHAT##################################################################
class Chat      #array
	constructor: (@usersIn, inChat) ->
		@html = "<ul id='mi-chat' style='display:none;'>
			<button type='button' class='close' data-dismiss='modal' aria-hidden='true' style='margin-top: -10px;margin-right: -7px;'>x</button>
			<li>	
				<button class='btn btn-primary btn-sm' style='width: 100%;'>Chat</button>
			</li>
			<div style='display:none;'>
				<li class='divider'></li>
				<li>Conectados: <strong id='conectados'>#{@usersIn}</strong></li>
				<li class='divider'><li>
				<li><div id='txtchat'></div></li>
				<li class='divider'></li>
				<li>
					<form class='form-horizontal'>
						<input type='text'  class='form-control' name='texto'>
					</form>
				</li>
			</div>
		</ul>"

	addTo:(jqEl)->
		@jq = $(@html).appendTo jqEl 
		
		@buttonJq = @jq.find('button:last').on 'click', (e)=>  @hideShowChat()
		@jq.find('button:first').on 'click', (e)=>  @jq.hide()
		@conectadosJq = @jq.find('strong#conectados')
		@form = @jq.find('form')
		@txt = @form.find('input:text')
		@txtchatJq = @jq.find('#txtchat')
		@form.on 'submit', (e)=>
			e.preventDefault()
			@sendMessage $.trim @txt.val()
		@jdBlokLi = @jq.find('div:first')
		
	hideShowChat:->
	
		if @jdBlokLi.is ':visible'

			@jdBlokLi.hide =>
		else
			
			@jdBlokLi.show =>
				@txtchatJq.scrollTop 1000000
				@txt.focus()

	sendMessage:(msg)->
		if msg isnt ''
			io.emit('users:addComment', {comment:{name:globalUser, msg:msg}})

	addComment:(comment)->
		# contentHtml = ''
		# contentHtml += "<p><strong>#{comment.name}: </strong>#{comment.msg}</p>" for comment in comments
		contentHtml = "<p><strong>#{comment.name}: </strong>#{comment.msg}</p>"
		$(contentHtml).appendTo @txtchatJq
		@txtchatJq.scrollTop 1000000

	updateUsersIn:(usersObj)->
		users = []
		users.push userObj.name for userObj in usersObj when usersObj.name isnt globalUser
		@conectadosJq.text users

$(document).ready ->

	inChat = new Chat [], []
	inChat.addTo $('div#page-wrapper')
	
	$('a#chat-context').on 'click', ->
		if inChat.jq.is ':visible'
			inChat.jq.hide()
		else
			inChat.jq.show()
			inChat.jdBlokLi.show()
			setTimeout ->
				inChat.txt.focus()
			,0


	# $.ajax
	#   url:'/users/getUsersOn'
	#   jsonp: "callback",
	#   dataType:'jsonp'
	#   success:(usersOn)->
	#     inChat.updateUsersIn usersOn
	io.emit('users:userIn', {userAction:globalUser})
	
	# io.on 'users:userOut', (data)->
	#   inChat.updateUsersIn data.usersIn
	#   inChat.addComment data.inChat

	
	io.on 'users:userIn', (data)->
		# console.log iva
		inChat.updateUsersIn data.usersIn
		if data.userAction is globalUser
			iva = data.iva
			ivaJqVenta.val iva
			ivaCompraJq.val iva
			proveedores = data.proveedores
			clientes = data.clientes
			codprod = data.codprod*1
			codprod++
			# console.log 'codprod: '+codprod
			codigoComprasGlobalJq.val getCodProd()

			NroFactura = data.NroFactura + 1
			NroRecibo = data.NroRecibo + 1
		# inChat.addComment data.inChat
	
	io.on 'users:addComment', (data)->
		# inChat.addComment data.inChat
		if inChat.jq.is ':visible'
			inChat.buttonJq.effect('highlight', 800) unless inChat.jdBlokLi.is ':visible'
			inChat.addComment data.comment
			inChat.txt.val '' if data.comment.name is globalUser

	# refrescar y cerrar navegador 
	`$(window).on('beforeunload', function(e) {
			console.log('close nav');
			io.emit('users:userOut', {
				userAction: globalUser,
				closeNav:e
			});
		})`
	
###########################################################REPORTES##################################################################
tablaVentasRep = undefined
$(window).on 'load',  ->
	
	ctnVentasRepJq = $('div#ventas')
	
	tablaVentasRepJq = ctnVentasRepJq.find('table#ventas-report')
	ctnTablaVentasRepJq = tablaVentasRepJq.parent()
	
	tablaVentasRep = tablaVentasRepJq.dataTable
		"dom": '<"top"fl>t<"bottom"pi><"clear">'
		"language": {
				"search": "Buscar: ",
				"lengthMenu":"",
				"lengthMenu": "_MENU_",
				"zeroRecords": "Ningun registro encontrado",
				"info": "pagina _PAGE_ de _PAGES_",
				"infoEmpty": "Ningun Registro",
				"infoFiltered": "(fitrado de _MAX_ total registros)"
		 },

		"ajax": '/ventas/getAll',
		"columns": [
			{ "data": "_id" }
			{ "data": "fecha" }
			{ "data": "serie" }
			{ "data": "codigo" }
			{ "data": "descripcion" }
			{ "data": "costo" }
			{ "data": "cantidad" }
			{ "data": "utilidad" }
			{ "data": "garantia" }
			{ "data": "cliente" }
			{ "data": "proveedor" }
			{ "data": "tipoVenta" }
			{ "data": "precioVenta" }
			{ "data": "precio_recibo" }
			{ "data": "precio_factura" }
			# { "defaultContent": "<button class='btn btn-primary'>Elegir</button>"}
		]
		"columnDefs": [
			{ "visible": false, "targets": 0 }
			{ "targets": 1, "visible": true, "createdCell":(td, cellData, rowData, row, col)-> 
				time = moment(cellData).format("DD/MMM/YYYY H:mm:ss")
				$(td).text time
				rowData.fecha = time
			}
			{ "visible": true, "targets": 2 }
			{ "targets": 3 }
			{ "targets": 4 }
			{ "visible": false, "targets": 5 }
			{ "visible": true, "targets": 6 }
			{ "visible": false, "targets": 7 }
			{ "visible": false, "targets": 8 }
			{ "visible": true, "targets": 9 }
			{ "visible": false, "targets": 10 }
			{ "visible": true, "targets": 11, "createdCell":(td, cellData, rowData, row, col)-> 
				$(td).addClass('selectable-td').html("<a href='javascript:;'>#{cellData}</a>")
			}
			{ "visible": true, "targets": 12 }
			{ "visible": false, "targets": 13 }
			{ "visible": false, "targets": 14 }
			# { "orderable": false, "targets": -1 }
		 ]
		"order": [1, 'asc'],
		# "ordering": false

	showHideMenujq = ctnVentasRepJq.find('div.show-hide-colms')
	$(document).ajaxComplete (event, xhr, settings)->
		tablaVentasRepJq.css('width', '')
		showHideMenujq.show()
	
	#hide/show columns.
	ctnVentasRepJq.find('ul.dropdown-cols input:checkbox').on 'click', (event)->
		column = tablaVentasRep.api().column( $(this).attr('data-column') )
		#Toggle the visibility
		if $(this).is(':checked')
			column.visible( true )
		else
			column.visible( false )
		tablaVentasRepJq.css('width', '')
	#click generar factura/recibo. 
	tablaVentasRepJq.on 'click', 'a', (ev)->
		alert "generar: #{$(this).text()}"
	#pdf.
	
		# window.open("/reportes/reporte.pdf/ventasModel/#{fielSort}/#{sort}/#{textFilter}/#{attrs}", "report", "toolbar=no, scrollbars=yes, resizable=yes, location=no, menubar=no, top=50, left=250, width=700, height=400");

###########################################################SERVICIOS##################################################################
# htmlFormCobrar = '<form class="form-horizontal">'
# htmlFormCobrar += "
# <div class='form-group'>
#   <label for='monto' class='col-md-3  control-label'>Monto:</label>
#   <div class='col-md-5'>
#     <input type='text' class='form-control upper' id='monto' name='monto' autocomplete='off' validar='real'>
#   </div>
# </div>"
# htmlFormCobrar += '<input type="submit" style="width:0px;height:0px;margin:0;padding:0;border:none;"></form>'
# clientesContrato = ['MADEPA', 'COBEE']

# formHtmlEditarServicio = '<form class="form-horizontal">'
# formHtmlEditarServicio += "
# <div class='form-group'>
#   <label for='fecha_cancel' class='col-md-3  control-label'>Fecha Reg.:</label>
#   <div class='col-md-5'>
#     <div class='input-group date' id='datetimepicker2'>
#       <input type='text' class='form-control' id='fecha' name='fecha' autocomplete='off' data-date-format='DD/MMM/YYYY H:mm:ss'/>
#       <span class='input-group-addon'><span class='glyphicon glyphicon-calendar'></span>
#     </div>
#   </div>
# </div>
# <div class='form-group'>
#   <label for='cliente' class='col-md-3  control-label'>Cliente:</label>
#   <div class='col-md-5'>
#     <input type='text' class='form-control upper' id='cliente' name='cliente' autocomplete='off' validar='requiere'>
#   </div>
# </div>
# <div class='form-group'>
#   <label for='descripcion' class='col-md-3  control-label'>Descripcion:</label>
#   <div class='col-md-5'>
#     <textarea type='text' class='form-control' id='descripcion' name='descripcion' autocomplete='off' validar='requiere'></textarea>
#   </div>
# </div>
# <div class='form-group'>
#   <label for='cobro' class='col-md-3  control-label'>Cobro:</label>
#   <div class='col-md-5'>
#     <select class='form-control' validar='requiere'>
#       <option></option>
#       <option>pendiente</option>
#       <option>cancelado</option>
#       <option>contrato</option>
#     </select>
#   </div>
# </div>

# <div class='form-group'>
#   <label for='fecha' class='col-md-3  control-label'>Monto:</label>
#   <div class='col-md-5'>
#     <input type='text' class='form-control upper' id='fecha' name='fecha' autocomplete='off' validar='real'>
#   </div>
# </div>
# <div class='form-group'>
#   <label for='fecha_cancel' class='col-md-3  control-label'>Fecha Cancel:</label>
#   <div class='col-md-5'>
#     <div class='input-group date' id='datetimepicker1'>
#       <input type='text' class='form-control' id='fecha_cancel' name='fecha_cancel' autocomplete='off' data-date-format='DD/MMM/YYYY H:mm:ss'/>
#       <span class='input-group-addon'><span class='glyphicon glyphicon-calendar'></span>
#     </div>
#   </div>
# </div>"
# formHtmlEditarServicio += '<input type="submit" style="width:0px;height:0px;margin:0;padding:0;border:none;"></form>'

# $(document).ready ->
#   console.log window.location
#   io.on 'ventas:addToCart', (data)->
#     tablaAlmacen.api().ajax.reload()
#     if data.userAction is globalUser
#       addCartProcedure data.item
#       inputSearchJq.val('').trigger('keyup').focus()
#       new Alerta data.msg 

#   io.on 'ventas:delToCart', (data)->
#     tablaAlmacen.api().ajax.reload()
		
#   io.on 'ventas:cancelShopp', (data)->
#     tablaAlmacen.api().ajax.reload()
	
#   io.on 'ventas:shopp', (data)->
#     tablaAlmacen.api().ajax.reload()
#     # tablaVentasRep.api().ajax.reload()
#     if data.userAction is globalUser
#       # shoppingCart.restar()
#       new Alerta data.msg 

#   io.on 'servicios:editar', (data)->
#     tablaServicios.api().ajax.reload()
#     if data.userAction is globalUser
#       new Alerta data.msg

#   io.on 'servicios:cobrar', (data)->
#     tablaServicios.api().ajax.reload()
#     if data.userAction is globalUser
#       new Alerta data.msg

#   io.on 'servicios:delete', (data)->
#     tablaServicios.api().ajax.reload()
#     if data.userAction is globalUser
#       new Alerta data.msg

#   io.on 'servicios:create', (data)->
#     console.log data.existCliente
#     tablaServicios.api().ajax.reload()
#     if not data.existCliente
#       clientes.push data.servicio.cliente 
#     if data.userAction is globalUser
#       new Alerta data.msg
#       btnClearJq2.trigger 'click'
			
#   ctnVentasJq = $('div#servicios-ctn')
#   tablaAlmacen = undefined
#   tablaAlmacenJq = ctnVentasJq.find('#productos-registrados')
#   contTablaVentaJq = tablaAlmacenJq.parent()
#   tablaAlmacen = tablaAlmacenJq.dataTable
#     "dom": '<"top"fl>t<"bottom"pi><"clear">'
#     "language": {
#         "search": "Buscar: ",
#         "lengthMenu":"",
#         "lengthMenu": "_MENU_",
#         "zeroRecords": "Ningun registro encontrado",
#         "info": "pagina _PAGE_ de _PAGES_",
#         "infoEmpty": "Ningun Registro",
#         "infoFiltered": "(fitrado de _MAX_ total registros)"
#      },

#     "ajax": '/productos/getAll',
#     "columns": [
#       { "data": "_id" }
#       { "data": "fecha" }
#       { "data": "serie" }
#       { "data": "codigo" }
#       { "data": "descripcion" }
#       { "data": "costo" }
#       { "data": "cantidad" }
#       { "data": "utilidad" }
#       { "data": "garantia" }
#       { "data": "proveedor" }
#       { "data": "precio_recibo" }
#       { "data": "precio_factura" }
#       # { "defaultContent": "<button class='btn btn-primary'>Elegir</button>"}
#     ]
#     "columnDefs": [
#       { "visible": false, "targets": 0 }
#       { "targets": 1, "visible": true, "createdCell":(td, cellData, rowData, row, col)-> 
#         time = moment(cellData).format("DD/MMM/YYYY H:mm:ss")
#         $(td).text time
#         rowData.fecha = time
#       }
#       { "visible": true, "targets": 2 }
#       { "targets": 3, "createdCell":(td, cellData, rowData, row, col)-> 
#         $(td).addClass('selectable-td').html("<a href='javascript:;'>#{cellData}</a>")
#       }
#       { "targets": 4, "createdCell":(td, cellData, rowData, row, col)-> 
#         $(td).addClass('selectable-td').html("<a href='javascript:;'>#{cellData}</a>")
#       }
#       { "visible": false, "targets": 5 }
#       { "visible": true, "targets": 6 }
#       { "visible": false, "targets": 7 }
#       { "visible": false, "targets": 8 }
#       { "visible": false, "targets": 9 }
#       # { "orderable": false, "targets": -1 }
#      ]
#     "order": [1, 'asc'],
#   showHideMenujq = ctnVentasJq.find('div.show-hide-colms:eq(0)')
#   $(document).ajaxComplete (event, xhr, settings)->
#     tablaAlmacenJq.css('width', '')
#     showHideMenujq.show()
#   ctnVentasJq.find('ul.dropdown-cols:eq(0) input:checkbox').on 'click', (event)->
#     column = tablaAlmacen.api().column( $(this).attr('data-column') );
#     #Toggle the visibility
#     if $(this).is(':checked')
#       column.visible( true )
#     else
#       column.visible( false )
#     tablaAlmacenJq.css('width', '')

#   htmlCantdad = "<form class='form-horizontal'>
#       <div class='form-group'>
#         <label for='cantidad' class='col-md-3  control-label'>Cantidad:</label>
#         <div class='col-md-5'>
#           <input type='text' class='form-control upper' id='cantidad' name='cantidad' placeholder='Cantidad a vender' validar='requiere'>
#         </div>
#       </div><input type='submit' style='width:0px;height:0px;margin:0;padding:0;border:none;'></form>"


#   $('tbody', tablaAlmacenJq).on 'click', 'a', (evt) ->
#     evt.preventDefault()
#     elTrNode = $(this).parents('tr')[0]
#     indexElegido = tablaAlmacen.api().row(elTrNode).index()
#     console.log 'elindice elegido es: '+indexElegido
#     console.log tablaAlmacen.row indexElegido
#     # shoppingCart.upOrCreIdexesRows.push indexElegido
#     rowTable =  tablaAlmacen.api().row(indexElegido)
#     # console.log rowTable
#     itemElegido = rowTable.data()
#     # console.log itemElegido
#     if itemElegido.cantidad*1 > 1
#       modalCantidad = new Modal
#         titulo:'Cantidad A Vender'
#         tipo:'formulario'
#         contenido: htmlCantdad
#         despuesDeMostrar:(ModalJq)->
#           # alert 'ok'
#           setTimeout ->
#             # alert ModalJq.find('input:text:first').attr('class')
#             ModalJq.find('input:text:first').focus()    
#           ,500
#         antesDeMostrar:(ModalJq)->
#           ModalJq.find('div.modal-footer button:first').text 'ok' 
#       new Validador
#         formulario:modalCantidad.jq.find('form:first')
#         procesarFormulario:(fromJq)=>
#           cantidad = fromJq.find('input:text:first').val()
#           if cantidad*1 > itemElegido.cantidad*1
#             new Alerta
#               tipo:'error'
#               titulo:'Error'
#               texto: "Solo se dispone de #{itemElegido.cantidad} Productos de este tipo"
#               posicion:'arriba-izquierda'
#           else
#             modalCantidad.cerrar ->
#               itemElegido.cantidad = cantidad*1
#               io.emit('ventas:addToCart', {item:itemElegido, userAction:globalUser})  
#     else
#       io.emit('ventas:addToCart', {item:itemElegido, userAction:globalUser})

#   inputSearchJq = $('input.input-sm', contTablaVentaJq)

#   addCartProcedure = (item)->
#     ctnVentasJq.find('form button.btn-info:last').trigger 'click'
#     btnAddJq = ctnVentasJq.find('form button.btn-info:last')
#     trJq = btnAddJq.parent().parent()
#     trJq.find('input:text').val item.precio_recibo
#     trJq.find('textarea').attr('disabled','disabled').val if item.serie is '----------' then "<strong>#{item.cantidad}</strong> #{item.descripcion}" else "#{item.cantidad} #{item.descripcion} ( #{item.serie} )"

#   tablaServiciosJq = $('table#servicios')
#   tablaServicios = tablaServiciosJq.dataTable
#     "dom": '<"top"fl>t<"bottom"pi><"clear">'
#     "language": {
#         "search": "Buscar: ",
#         "lengthMenu":"",
#         "lengthMenu": "_MENU_",
#         "zeroRecords": "Ningun registro encontrado",
#         "info": "pagina _PAGE_ de _PAGES_",
#         "infoEmpty": "Ningun Registro",
#         "infoFiltered": "(fitrado de _MAX_ total registros)"
#      },

#     "ajax": '/servicios/getAll',
#     "columns": [
#       { "data": "_id" },
#       { "data": "fecha" },
#       { "data": "cliente" },
#       { "data": "descripcion" },
#       { "data": "cobro" },
#       { "data": "monto" },
#       { "data": "fecha_cancel" },
#       { "defaultContent": '<button type="button" class="btn btn-danger btn-circle" alt="eliminar"><i class="fa fa-times"></i></button> <button type="button" class="btn btn-info btn-circle" alt="editar"><i class="fa fa-pencil"></i></button>'}
#     ],
#     "columnDefs": [
#       { "visible": false, "targets": 0 }
#       { "targets": 1, "visible": true, "createdCell":(td, cellData, rowData, row, col)->
#         $(td).attr 'name', rowData._id
#         time = moment(cellData).format("DD/MMM/YYYY H:mm:ss")#H:mm:ss
#         $(td).text time
#         # rowData.fecha = time
#       } 

#       { "targets": 4, "visible": true, "createdCell":(td, cellData, rowData, row, col)->
#         tdJq = $(td)
#         if cellData is 'pendiente'
#           tdJq.html("<span class='label label-danger selectable-red'>#{cellData}</span>")
#         else
#           if rowData.cliente.toUpperCase() in clientesContrato
#             tdJq.text 'contrato'
#             rowData.fecha_cancel = ''
#           else
#             tdJq.html("<span class='label label-success'>#{cellData}</span>")

#       } 

#       { "targets": 6, "visible": true, "createdCell":(td, cellData, rowData, row, col)->
#         if cellData isnt ''
#           time = moment(cellData).format("DD/MMM/YYYY H:mm:ss")#H:mm:ss
#           $(td).text time
#           # rowData.fecha = time
#       } 

#     ],
#     "order": [1, 'desc']
#     # "ordering": false

#   $(document).ajaxComplete (event, xhr, settings)->
#     tablaServiciosJq.css('width', '')
	
#   tablaServiciosJq.on 'click', 'button.btn-danger', (e)->
#     modalConfirm = new Modal
#       titulo:'Confirmar - Eliminar Servicio'
#       tipo:'confirmacion'
#       contenido:"<p>Eliminar Servicio ?</p>"
#       accionSi: =>
#         io.emit('servicios:delete', {id:$(this).parent().parent().find('td:first').attr('name'), userAction:globalUser})

#         modalConfirm.cerrar =>
#       antesDeMostrar:(jqModal)->
#         btnsi = jqModal.find('button.btn-danger').text('SI')
#         jqModal.find('button:last').text('NO').click (e)->
#           modalConfirm.cerrar()


#   tablaServiciosJq.on 'click', 'button.btn-info', (e)->

#     modalJq = undefined
#     elsJq = undefined
#     dateTime1 = undefined
#     dateTime2 = undefined

#     modalEditarServicio = new Modal
#       titulo:'Editar - Servicio'
#       tipo:'formulario' 
#       contenido:formHtmlEditarServicio
#       despuesDeMostrar:(ModalJq)=>
#         modalJq = ModalJq
#         dateTime1 = $('#datetimepicker2').datetimepicker()

#         dateTime2 = $('#datetimepicker1').datetimepicker()
				
#         jqFecha = ModalJq.find('input:text:first')
#         montoJq = ModalJq.find('input:text:eq(2)')

#         clienteJq = ModalJq.find('input:text:eq(1)')

#         clienteJq.typeahead
#           source: clientes

#         setTimeout ->
#           # alert ModalJq.find('input:text:first').attr('class')
#           jqFecha.focus()   
#         ,500

#         ModalJq.find('select').on 'change', ->
#           if $(this).val() in ['contrato', 'pendiente']
#             montoJq.val 0
#             $(elsJq[5]).val ''

			
#       antesDeMostrar:(ModalJq)=>
#         tdsJq = $(this).parent().parent().find('td')
#         elsJq = ModalJq.find('input:text, select, textarea').each (index)->
#           $(this).val $(tdsJq[index]).text()


#     new Validador
#       formulario:modalJq
#       procesarFormulario:(formJq)=>
#         io.emit('servicios:editar', {id:$(this).parent().parent().find('td:first').attr('name'), servicio:{fecha:$(elsJq[0]).val(), cliente:$(elsJq[1]).val(), descripcion:$(elsJq[2]).val(), cobro:$(elsJq[3]).val(), monto:$(elsJq[4]).val(),  fecha_cancel:$(elsJq[5]).val()}, userAction:globalUser})
#         modalEditarServicio.cerrar()
		
#   descServJq = $('textarea#descripcion-serv')

#   clienteServJq = $('input#cliente-serv')
#   clienteServJq.typeahead
#     source:-> clientes
#     updater:(cliente)->
#       setTimeout ->
#         descServJq.focus()
#       ,0 
#       cliente

#   formNuevoServJq = $('form#nuevo-servicio')
#   tbodyFormJq = formNuevoServJq.find('tbody')
#   totalJq2 = formNuevoServJq.find('tfoot th:last')
#   rowSelectedJq = undefined
#   rowText = '<tr>
#               <td><textarea class="form-control" id="descripcion-serv" name="descripcion-serv" placeholder="Descripcion del servicio" validar="requiere"></textarea></td>
#               <td><input type="text" class="form-control" id="precio-serv" name="precio-serv" placeholder="Precio del servicio" validar="requiere"></td>
#               <td>
#                 <button type="button" class="btn btn-danger" alt="eliminar"><i class="fa fa-times"></i></button>
#                 <button type="button" class="btn btn-info"><i class="fa fa-plus fa-fw"></i> </button>
#               </td>
#             </tr>'

#   tbodyFormJq.on 'click', 'button.btn-info', (e)->
#     $(this).parent().html '<button type="button" class="btn btn-danger" alt="eliminar"><i class="fa fa-times"></i></button>'  
#     rowAddJq = $(rowText).appendTo(tbodyFormJq)
#     setTimeout ->
#       rowAddJq.find('textarea:first').focus()
#     ,100
#   tbodyFormJq.on 'click', 'button.btn-danger', (e)->
#     trJq = $(this).parent().parent()

#     trPibotJq = trJq.prev()
#     if $(this).next().length
#       tdAntJq = trPibotJq.find('td:last')
#       if trPibotJq.prev().length
#         # hay mas de uno.
#         tdAntJq.html '<button type="button" class="btn btn-danger" alt="eliminar"><i class="fa fa-times"></i></button> <button type="button" class="btn btn-info"><i class="fa fa-plus fa-fw"></i> </button>'
#       else
#         #hay uno solo.
#         tdAntJq.html '<button type="button" class="btn btn-info"><i class="fa fa-plus fa-fw"></i></button>'
#       trJq.remove()

#     else
#       nextJq = trJq.next()
#       if trPibotJq.length is 0 and nextJq.next().length is 0
#         #hay uno solo.
#         nextJq.find('td:last').html '<button type="button" class="btn btn-info"><i class="fa fa-plus fa-fw"></i> </button>'
			
#       trJq.remove()
#     totalJq2.text sumarCols()
#     # $(this).parent().parent().remove()
	
#   sumarCols = ->
#     sum = 0
#     tbodyFormJq.find('input:text').each (ind)->
#       sum += $(this).val()*1
#     sum.toFixed 2

#   tbodyFormJq.on 'change keyup', 'input:text', (e)->
#     totalJq2.text sumarCols()
#   # anchoTextarea = tbodyFormJq.find('textarea:first').width()
	
#   tbodyFormJq.on 'resizable', 'textarea', (e)->
#     $(this).css 'margin', ''


#   btnClearJq2 = $('button#btn-clear-form', ctnVentasJq).on 'click', (e)->
#     trJq = tbodyFormJq.html(rowText)
#     trJq.find('button.btn-danger').remove()
#     totalJq2.text ''
#     setTimeout ->
#       trJq.find('textarea:first').focus()
#     ,10
#     # clienteServJq.val('').focus()
#     # descServJq.val('')

#   new Validador
#     formulario:formNuevoServJq
#     procesarFormulario:(formJq)=>
#       io.emit('servicios:create', {servicio:{cliente:clienteServJq.val(), descripcion:descServJq.val()} ,userAction:globalUser})

#   tablaServiciosJq.on 'click', 'span.selectable-red', (e)->
#     montoJq = undefined
#     modalCobrar = new Modal
#       titulo:'Cobrar-Servicio'
#       tipo:'formulario'
#       contenido: htmlFormCobrar
#       despuesDeMostrar:(ModalJq)=>
#         montoJq = ModalJq.find('input:text:first')
#         setTimeout ->
#           # alert ModalJq.find('input:text:first').attr('class')
#           montoJq.focus()   
#         ,500
#       antesDeMostrar:(ModalJq)=>
#         ModalJq.find('div.modal-footer button:first').text 'ok' 
		
#     new Validador
#       formulario:modalCobrar.jq.find('form:first')
#       procesarFormulario:(formJq)=>
#         # alert $(this).parent().parent().find('td:first').attr('name')
#         modalCobrar.cerrar =>
#           io.emit('servicios:cobrar', {id:$(this).parent().parent().find('td:first').attr('name'), monto:montoJq.val()*1, userAction:globalUser})

#   `$(window).on('beforeunload', function(e) {
#       io.emit('ventas:cancelShopp', {
#         userAction: globalUser
#       });
#     })`

###################################################################ESTADISTICAS########################################################

contEstaJq = $('div#estadisticas-ctn')
drawEstadisticasVentas = ()-> 
	$.ajax
		url:'/estadisticas/estadisticaVentas/'
		type:'GET'
		dataType:'json'
		success:(data)->
			item.label = item.label+' '+item.data+' Bs' for item in data.mayCompData
			$.plot(contEstaJq.find("#flot-pie-chart"), data.mayCompData, {
				series: {
					pie: {
						show: true
					}
				},
				grid: {
					hoverable: true
				},
				tooltip: true,
				tooltipOpts: {
					content: "%p.0%, %s",
					shifts: {
						x: 20,
						y: 0
					},
					defaultTheme: false
				}
			})
			contEstaJq.find("b#est-utilidad").text data.utilidadTotal
			contEstaJq.find("b#est-mas-vendido").html "<div>#{data.prodsMasVenData[0].descripcion} con #{data.prodsMasVenData[0].cantidad} Unidade(s)</div>" if data.prodsMasVenData[0]? 
			contEstaJq.find("b#ventas-cobrar").text data.ventasPorCobrar
			
			console.log data.ventasPorFecha
			doPlot = (position)-> 
				$.plot($("#flot-chart-ventas"), [ 
						{
							data: data.ventasPorFecha,
							label: "Ventas",
							yaxis: 2
						}
					], 
					{	 
						# points: {show:true},
						xaxes: [
							{
								mode: 'time'
								timeformat: '%d/%m/%y %H:%M:%S',

							}
						],
						yaxes: [
							{
								min: 0
							}, 
							{
								# // align if we are to the right
								alignTicksWithAxis: if position is "right" then 1 else null,
								position: position,
								tickFormatter: (v, axis)-> 
									v.toFixed(axis.tickDecimals) + " Bs"
							}
						],
						legend: {
							position: 'sw'
						},
						grid: {
							hoverable: true #//IMPORTANT! this is needed for tooltip to work
						},
						tooltip: true,
						tooltipOpts: {
							content: "%s para %x, %y",
							xDateFormat: "%d-%m-%y",

							onHover: (flotItem, $tooltipEl)->
								# // console.log(flotItem, $tooltipEl);
						}
					}
				)

			# console.log((new Date("2009/07/01")).getTime()*1000)
			doPlot("right")

drawEstadisticasCompras = ()-> 
	$.ajax
		url:'/estadisticas/estadisticaCompras/'
		type:'GET'
		dataType:'json'
		success:(data)->
			contEstaJq.find("b#prod-almacen").text data.prodsAlmacen
			
			

$(window).on 'load', ->
	drawEstadisticasVentas()
	drawEstadisticasCompras()
	# contEstaJq.find('div.panel-body:eq(0) button.btn-danger').on 'click', ->
	# 	window.open("/reportes/viewMayorCompradorPdf/", "report", "toolbar=no, scrollbars=yes, resizable=yes, location=no, menubar=no, top=50, left=250, width=700, height=400");
	contEstaJq.find('button#btn_est_fechas').on 'click', ->
		modalEstfechas = new Modal
			titulo:'Rango de Estadisticas'
			tipo:'formulario'
			contenido: '<form class="form-horizontal">
				<div class="form-group">
					<label for="est_fecha_inicio" class="col-md-3  control-label">A partir de:</label>
					<div class="col-md-5">
						<input type="text" class="form-control input-sm" id="est_fecha_inicio" name="est_fecha_inicio">
					</div>
				</div>
				<div class="form-group">
					<label for="est_fecha_final" class="col-md-3  control-label">Hasta:</label>
					<div class="col-md-5">
						<input type="text" class="form-control input-sm" id="est_fecha_final" name="est_fecha_final">
					</div>
				</div>
			</form>'
			antesDeMostrar:(modalJq)->
				$('div.bootstrap-datetimepicker-widget').remove()
				modalJq.find('input:text:eq(0)').datetimepicker()
				modalJq.find('input:text:eq(1)').datetimepicker()
			despuesDeCerrar:(modalJq)->
	
$(window).on 'load', ->
	# navTopJq = $('nav.navbar-fixed-top')
	# navSideJq = $('nav.navbar-static-side')

	$('button.btn-fullscreen').on 'click', (e)->

		ctnDivParentJq = $(this).parent()
		if ctnDivParentJq.attr('class') is 'row'
			ctnDivParentJq.addClass('full-screen')
			# navTopJq.hide()
			# navSideJq.hide()
		else
			ctnDivParentJq.removeClass('full-screen')
			# navTopJq.show()
			# navSideJq.show()