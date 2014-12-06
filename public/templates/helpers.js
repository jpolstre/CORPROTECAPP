function mostSelling(books, prop){
	return _.max(books, function(book){ return book.sales; })[prop];
}

function dateFormat(fecha){
	return moment(new Date(fecha)).format("DD/MMM/YYYY H:mm:ss")
}

function parse(fecha){
	if(fecha[0] === '<') {
		return fecha.slice(48, -7);
	}else{
		// dateFormat(fecha);
		return fecha;
	}
}
