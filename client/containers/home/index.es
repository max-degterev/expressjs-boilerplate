import React from 'react';
import { provideHooks } from 'redial';
import { connect } from 'react-redux';

import { isAuthorized } from '../../modules/permissions/utils';
import { actions as homeActions } from './state';
import { actions as cityActions } from '../city/state';

import BaseComponent from '../../base/base_component';
import Layout from '../../components/layout';
import MicroHelmet from '../../ui/micro_helmet';
import EngageLinks from '../../components/engage_links';
import LandingStage from '../../components/landing_stage';
import HoodSearchCard from '../../components/hood_search_card';
import HomeTeaser from './components/teaser';
import PrivacyBanner from '../../components/privacy_banner';
import PressBanner from '../../components/press_banner';
import RegistrationBanner from '../../components/registration_banner';
import FeaturedBanner from '../../components/featured_banner';
import ApplicationsBanner from '../../components/applications_banner';
import PromotionList from '../../components/promotion_list';
import LandingStories from '../../components/landing_stories';
import CitiesPreview from '../../components/cities_preview';

const {
  getHomeStage,
  getTeaser,
  getPromotions,
  getPressBar,
  getFeaturedBadges,
  fetchStories,
  resetStories,
} = homeActions;

const {
  fetchCityStages,
  resetCity,
} = cityActions;

const CITIES_PREVIEW_COUNT = 10;


class Home extends BaseComponent {
  renderContent() {
    const {
      profile,

      entities,
      cityEntities,

      homeStage,
      teaser,
      pressBar,
      featuredBadges,
      stories,
      promotions,
      cities,
    } = this.props;

    let homeStageNode;
    if (homeStage) {
      homeStageNode = (
        <LandingStage
          item={homeStage}
          entities={entities}
        >
          <HoodSearchCard withAwardBanner />
        </LandingStage>
      );
    }

    let teaserNode;
    if (teaser && teaser.fields.visibility) {
      teaserNode = <HomeTeaser item={teaser.fields} />;
    }

    let landingStories;
    if (stories.length >= 3) {
      landingStories = <LandingStories items={stories} entities={entities} />;
    }

    let registrationBanner;
    if (!isAuthorized(profile)) {
      registrationBanner = <RegistrationBanner link="/register" />;
    }

    let citiesPreview;
    if (cities.length >= CITIES_PREVIEW_COUNT) {
      citiesPreview = <CitiesPreview items={cities} entities={cityEntities} />;
    }

    let pressBarNode;
    if (pressBar) pressBarNode = <PressBanner item={pressBar} entities={entities} />;

    return (
      <div>
        {homeStageNode}
        <FeaturedBanner badges={featuredBadges} />
        {teaserNode}
        {landingStories}
        <PrivacyBanner featuredBadges={featuredBadges} />
        <PromotionList items={promotions} entities={entities} />
        {pressBarNode}
        {registrationBanner}
        {citiesPreview}
        <ApplicationsBanner />
      </div>
    );
  }
  render() {
    let headerContent;
    if (!isAuthorized(this.props.profile)) headerContent = <EngageLinks />;

    return (
      <Layout className="c-home" headerContent={headerContent} fullWidth>
        <MicroHelmet titleTemplate={null} />
        {this.renderContent()}
      </Layout>
    );
  }
}

const hooks = {
  fetch({ dispatch, state }) {
    dispatch(resetStories());
    const promises = [
      dispatch(fetchStories(1, 3)),
      dispatch(getHomeStage()),
      dispatch(getPressBar()),
      dispatch(getFeaturedBadges()),
      dispatch(getPromotions()),
      dispatch(getTeaser()),
    ];

    const { stages: cities } = state.city;

    if (cities.collection.length < CITIES_PREVIEW_COUNT) {
      dispatch(resetCity());
      promises.push(dispatch(fetchCityStages(1, CITIES_PREVIEW_COUNT)));
    }

    return Promise.all(promises);
  },
};

const mapStateToProps = ({ profile, home, city }) => {
  const {
    homeStage,
    entities,
    promotions,
    pressBar,
    stories,
    teaser,
    featuredBadges,
  } = home;

  const { entities: cityEntities, stages } = city;

  return {
    profile,

    entities,
    cityEntities: cityEntities.stages,

    homeStage,
    teaser,
    pressBar,
    featuredBadges,
    stories: stories.collection,
    promotions,
    cities: stages.collection,
  };
};

export default provideHooks(hooks)(connect(mapStateToProps)(Home));
