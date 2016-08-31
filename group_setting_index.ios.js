/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  Image,
  ScrollView,
  Navigator,
  TouchableHighlight,
  ActionSheetIOS,
  View
} from 'react-native';

import { NativeModules, NativeAppEventEmitter } from 'react-native';


import GroupMemberAdd from './group_member_add.ios';
import GroupMemberRemove from './group_member_remove.ios';
import GroupName from './group_name.ios';
import GroupSetting from './group_setting.ios';

class GroupSettingIndex extends Component {
  constructor(props) {
    super(props);

  }
  
  componentDidMount() {
  }

  render() {
    const routes = [
      {title: '群聊', index: "setting"},
    ];


    var self = this;
    var renderScene = function(route, navigator) {
      if (route.index == "setting") {
        return <GroupSetting  {...self.props} navigator={navigator}/>
      } else if (route.index == "member_add") {
        return <GroupMemberAdd {...self.props} users={route.users} eventEmitter={route.eventEmitter} navigator={navigator}/>
      } else if (route.index == "member_remove") {
        var users = route.users;
        return <GroupMemberRemove {...self.props} users={users} eventEmitter={route.eventEmitter} navigator={navigator}/>;
      } else if (route.index == "name") {
        console.log("render name...");
        return <GroupName {...self.props} topic={route.topic} eventEmitter={route.eventEmitter} navigator={navigator}/>
      }
    }

    return (
      <Navigator ref={(nav) => { self.navigator = nav; }} 
                 initialRoute={routes[0]}
                 renderScene={renderScene}
                 configureScene={(route, routeStack) =>
                   Navigator.SceneConfigs.FloatFromRight}/>
    );
  }

}


AppRegistry.registerComponent('GroupSettingIndex', () => GroupSettingIndex);
