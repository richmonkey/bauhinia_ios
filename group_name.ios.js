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
  TouchableHighlight,
  TextInput,
  View
} from 'react-native';

import { NativeModules, NativeAppEventEmitter } from 'react-native';

var GroupNameViewControllerBridge = NativeModules.GroupNameViewControllerBridge;
var ProgressHudBridge = NativeModules.ProgressHudBridge;


class GroupName extends Component {
  constructor(props) {
    super(props);
    this.state = {topic:this.props.topic};
  }

  componentDidMount() {
    console.log("add listener");
    var self = this;
    var listener = NativeAppEventEmitter.addListener(
      'update',
      (obj) => {
        console.log(obj);
        self.updateName();
      }
    );

    this.setState({istener:listener});
  }

  updateName() {
    if (this.state.topic == this.props.topic) {
      return;
    }
    console.log("update group name...");

    var name = this.state.topic;
    var url = this.props.url + "/groups/" + this.props.group_id;
    ProgressHudBridge.showHud();
    fetch(url, {
      method:"PATCH",
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        "Authorization": "Bearer " + this.props.token,
      },
      body:JSON.stringify({name:name}),
    }).then((response) => {
      console.log("status:", response.status);
      if (response.status == 200) {
        GroupNameViewControllerBridge.groupNameChanged(name);
        ProgressHudBridge.hideHud();
        GroupNameViewControllerBridge.popViewController();
      } else {
        return response.json().then((responseJson)=>{
          console.log(responseJson.meta.message);
          ProgressHudBridge.hideTextHud(responseJson.meta.message);
        });
      }
    }).catch((error) => {
      console.log("error:", error);
      ProgressHudBridge.hideTextHud('' + error);
    });

  }

  componentWillUnmount() {
    var subscription = this.state.listener;
    subscription.remove();
    console.log("remove listener");
  }

  render() {
    console.log("render props:", this.props);
    return (
      <ScrollView style={{flex:1, backgroundColor:"#F5FCFF"}}>
        <View style={{marginTop:12}}>
          <Text style={{marginLeft:12, marginBottom:4}}>群聊名称</Text>
          <TextInput
              style={{paddingLeft:12, height: 40, backgroundColor:"white"}}
              placeholder=""
              onChangeText={(text) => this.setState({topic:text})}
              value={this.state.topic}/>
        </View>
      </ScrollView>
    );
  }
  
}

const styles = StyleSheet.create({
  
});

AppRegistry.registerComponent('GroupName', () => GroupName);
