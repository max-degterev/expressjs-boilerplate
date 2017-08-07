React = require('react')
{ connect } = require('react-redux')

{ getHomeUrl } = require('../../modules/permissions')

BaseComponent = require('../../base/base_component')
MicroHelmet = require('../../ui/micro_helmet')
Link = require('../../ui/link')
Layout = require('../../components/layout').default


class Error404 extends BaseComponent
  render: ->
    <Layout className="c-error">
      <MicroHelmet title={@t('meta.title_error_404')} />
      <article className="ui-card">
        <header className="ui-card-section">
          <h1>{@t('error_404.title')}</h1>
        </header>
        <div className="ui-card-section">
          <p>{@t('error_404.text')}</p>
          <Link to={getHomeUrl(@props.profile)} className="ui-button ui-button-primary">{@t('common.to_home')}</Link>
        </div>
      </article>
    </Layout>

mapStateToProps = ({ profile }) -> { profile }

module.exports = connect(mapStateToProps)(Error404)
