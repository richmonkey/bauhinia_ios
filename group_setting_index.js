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

import { Provider } from 'react-redux';
import { createStore } from 'redux'

import GroupMemberAdd from './group_member_add';
import GroupMemberRemove from './group_member_remove';
import GroupName from './group_name';
import GroupSetting from './group_setting';

import {groupApp} from "./actions";

class GroupSettingIndex extends Component {
  constructor(props) {
    super(props);
      var initState = {
          topic:this.props.topic,
          members:this.props.members
      };
      this.store = createStore(groupApp, initState);
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
        <Provider store={this.store}>
            <Navigator ref={(nav) => { self.navigator = nav; }} 
                       initialRoute={routes[0]}
                       renderScene={renderScene}
                       configureScene={(route, routeStack) =>
                           Navigator.SceneConfigs.FloatFromRight}/>
        </Provider>
    );
  }

}


AppRegistry.registerComponent('GroupSettingIndex', () => GroupSettingIndex);
