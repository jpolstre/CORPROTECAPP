class Chat			#array
	constructor: (@usersIn, inChat) ->
		@html = "<ul id='mi-chat'>
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
		
		@buttonJq = @jq.find('button').on 'click', (e)=> 	@hideShowChat()
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

$(window).on 'load', ->
	
	inChat = new Chat [], []
	inChat.addTo $('div#page-wrapper')
	# $.ajax
	# 	url:'/users/getUsersOn'
	# 	jsonp: "callback",
	# 	dataType:'jsonp'
	# 	success:(usersOn)->
	# 		inChat.updateUsersIn usersOn
	io.emit('users:userIn', {userAction:globalUser})
	
	io.on 'users:userOut', (data)->
		inChat.updateUsersIn data.usersIn
		inChat.addComment data.inChat

	
	io.on 'users:userIn', (data)->
		inChat.updateUsersIn data.usersIn
		# inChat.addComment data.inChat
	
	io.on 'users:addComment', (data)->
		# inChat.addComment data.inChat
		inChat.buttonJq.effect('highlight', 800) unless inChat.jdBlokLi.is ':visible'
		inChat.addComment data.comment
		inChat.txt.val '' if data.comment.name is globalUser

	
	`$(window).on('beforeunload', function(e) {
			io.emit('users:userOut', {
				userAction: globalUser,
				closeNav:true
			});
		})`
	
