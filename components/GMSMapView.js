/**
* @Author: Hoang Pham Huu <hoangph>
* @Date:   19-07-2016 1:26
* @Email:  phamhuuhoang@gmail.com
* @Last modified by:   hoangph
* @Last modified time: 19-07-2016 1:28
*/

import React from 'react';
import { requireNativeComponent } from 'react-native';

class GMSMapView extends React.Component {
  render() {
    return <GMSAIRMap {...this.props} />;
  }
}

GMSMapView.propTypes = {
  /**
   * When this property is set to `true` and a valid camera is associated
   * with the map, the camera’s pitch angle is used to tilt the plane
   * of the map. When this property is set to `false`, the camera’s pitch
   * angle is ignored and the map is always displayed as if the user
   * is looking straight down onto it.
   */
  pitchEnabled: React.PropTypes.bool,
};

var GMSAIRMap = requireNativeComponent('GMSAIRMap', GMSMapView);

module.exports = GMSMapView;
