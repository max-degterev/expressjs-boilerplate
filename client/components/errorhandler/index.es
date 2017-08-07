React = require('react')
PropTypes = require('prop-types')

{ connect } = require('react-redux')
{ setError } = require('./state').actions


class ErrorCatcher extends React.PureComponent
  @contextTypes:
    layout: PropTypes.object
    router: PropTypes.object

  componentDidMount: -> @checkAppState(@props)
  componentWillReceiveProps: (nextProps) -> @checkAppState(nextProps) if not @props.error
  render: -> <pre>{props.error}</pre>

  handleLogout: =>
    @props.setToken(null)
    @props.setProfile(null)
    process.nextTick(@handleRefresh)

  handleReset: =>
    @props.setToken(null)
    @props.setSession(null)
    @props.setProfile(null)
    process.nextTick(@handleRefresh)

  handleRefresh: =>
    global.location.reload()

  checkAppState: (props) ->
    return unless props.error

    switch props.error.statusCode
      when 401
        recordClientError(createErrorReport(global.location.href, @props))
        @handleLogout()
      when 404
        @context.router.replace(INVALID_ROUTE)
        @props.setError(null)
      when 410
        @context.layout.setModal(<GoneModal profile={props.profile} />)
        @props.setError(null)
      else
        modal =
          <ErrorModal
            error={props.error}
            onReset={@handleReset}
            onRefresh={@handleRefresh}
          />

        recordClientError(createErrorReport(global.location.href, @props))
        @context.layout.setModal(modal)

mapError = ({ error, profile, session, token }) -> { error, profile, session, token }
actions = { setError, setToken, setSession, setProfile  }
ErrorCatcher = connect(mapError, actions)(ErrorCatcher)

module.exports = { ErrorModal, GoneModal, ErrorCatcher }
