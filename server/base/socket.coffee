_ = require('lodash')


module.exports = class Socket
  getEventName: (event, options) ->
    [options.namespace, event, options.signature].join(':')

  getStreamData: (socket, options) ->
    socket.streaming[options.namespace] ?= {}
    socket.streaming[options.namespace][options.signature] ?= {}
    socket.streaming[options.namespace][options.signature]

  eventProxy: (event, socket) ->
    (args...) =>
      handler = @events[event]
      callback = if _.isString(handler) then @[handler] else handler
      callback.call(@, socket, args...)

  buildEvents: (socket) =>
    socket.streaming = {}

    if @events
      for event of @events
        socket.on(event, @eventProxy(event, socket))

    socket.on('disconnect', => @abortRequests(socket))

  createRequest: (socket, options, data) ->
    streamData = @getStreamData(socket, options)
    _.merge(streamData, data)

  deleteRequest: (socket, options) ->
    streamData = @getStreamData(socket, options)
    for key of streamData
      delete streamData[key]

  abortRequest: (socket, options) ->
    streamData = @getStreamData(socket, options)
    if streamData.request
      streamData.request.abort()
      streamData.aborted = true

  abortRequests: (socket) ->
    for namespace, transfers of socket.streaming
      for signature, transfer of transfers
        @abortRequest(socket, { namespace, signature })

  use: (app) ->
    @socket = app.get('socket')
    @socket.on('connection', @buildEvents)
