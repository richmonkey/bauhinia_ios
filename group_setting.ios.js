/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

var reactMixin = require('react-mixin');
var Subscribable = require('Subscribable');
var EventEmitter = require('EventEmitter');

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  Image,
  ScrollView,
  TouchableHighlight,
  ActionSheetIOS,
  View
} from 'react-native';

import { NativeModules, NativeAppEventEmitter } from 'react-native';


import NavigationBar from 'react-native-navbar';

import GroupMemberAdd from './group_member_add.ios';
import GroupMemberRemove from './group_member_remove.ios';
import GroupName from './group_name.ios';



var GroupSettingViewControllerBridge = NativeModules.GroupSettingViewControllerBridge;
var ProgressHudBridge = NativeModules.ProgressHudBridge;

class GroupSetting extends Component {
  constructor(props) {
    super(props);
    this.state = {members:this.props.members, 
                  topic:this.props.topic};

    this.eventEmitter = new EventEmitter();

  }
  
  componentDidMount() {
    console.log("add listener");
    var add_listener = this.addListenerOn(
      this.eventEmitter,
      'member_added',
      (obj) => {
        console.log(obj);
        this.addNewMember(obj['users']);
      }
    );

    var remove_listener = this.addListenerOn(
      this.eventEmitter,
      'member_removed',
      (obj) => {
        console.log(obj);
        this.removeMember(obj['id']);
      }
    );


    var name_listener = this.addListenerOn(
      this.eventEmitter,
      'name_updated',
      (obj) => {
        console.log(obj);
        this.setState({topic:obj['name']});
      }
    );
  }

  removeMember(id) {
    var members = this.state.members;
    for (var i = 0; i < members.length; i++) {
      let m = members[i];
      if (m.uid == id) {
        members.splice(i, 1);
        break;
      }
    }
    this.setState({members:members});
  }

  addNewMember(users) {
    var members = this.state.members;
    var all = members.concat(users);
    this.setState({members:all});
  }

  componentWillUnmount() {
    var subscription = this.state.add_listener;
    subscription.remove();

    subscription = this.state.remove_listener;
    subscription.remove();
    
    console.log("remove listener");
  }

  handleBack() {
    console.log("action back");
    GroupSettingViewControllerBridge.handleBack();
  }

  render() {
    var self = this;
    var rows = this.state.members.map(function(i) {
      return (
        <View key={i.uid} style={{alignItems:'center'}}>
          <TouchableHighlight underlayColor='gray' style={styles.headButton} onPress={self.handleClickMember.bind(self, i)} >
            <Image
                source={require('./img/PersonalChat.png')}
                style={styles.head}
            />
          </TouchableHighlight>
          <Text numberOfLines={1} style={{width:50, height:20}}>{i.name}</Text>

        </View>
      );
      
    });

    
    var leftButtonConfig = {
      title: '取消',
      handler: () => this.handleBack()
    };

    var rightButtonConfig = {
      title: '确定',
      handler: () => console.log("ok")
    };

    var titleConfig = {
      title: '聊天信息',
    };

    
    return (
      <View style={{flex:1}}>
        <NavigationBar
            statusBar={{hidden:true}}
            style={{}}
            title={titleConfig}
            leftButton={leftButtonConfig} 
            rightButton={rightButtonConfig} />

        <ScrollView style={styles.container}>
          <View style={styles.block}>
            <View style={{flex: 1, flexDirection:'row', flexWrap: 'wrap', marginLeft:10, marginBottom:10}}>
              {rows}
              <TouchableHighlight  underlayColor='gray' style={styles.headButton} onPress={this.handleAdd.bind(this)}>
                <Image
                    source={require('./img/AddGroupMemberBtn.png')}
                    style={styles.head}
                />
              </TouchableHighlight>
              {
                this.props.is_master ?
                (
                  <TouchableHighlight  underlayColor='gray' style={styles.headButton} onPress={this.handleRemove.bind(this)}>
                    <Image
                        source={require('./img/RemoveGroupMemberBtn.png')}
                        style={{width:50, height:50}}
                    />
                  </TouchableHighlight>
                ) : null
              }
            </View>
            
            <View style={styles.line}/>

            <TouchableHighlight underlayColor='ghostwhite' style={styles.item} onPress={this.handleName.bind(this)} >
              <View style={styles.itemInternal}>
                <Text>群聊名称</Text>
                <View style={{flexDirection:'row', alignItems:"center", marginRight:8}}>
                  <Text>{this.state.topic}</Text>
                  <Image source={require('./img/TableViewArrow.png')}
                         style={{marginLeft:4, width:20, height:20}} />
                </View>
              </View>
            </TouchableHighlight>
          </View>

          <TouchableHighlight underlayColor="lightcoral" style={styles.quit} onPress={this.handleQuit.bind(this)}>
            <Text>退出</Text>
          </TouchableHighlight>
          
        </ScrollView>
      </View>
    );
  }

  handleName(event) {
    var route = {title: '名称', index: "name", topic:this.state.topic, eventEmitter:this.eventEmitter};
    console.log("handle name...");
    this.props.navigator.push(route);
  }

  handleRemove(event) {
    var users = this.props.members.slice();
    for (var i = 0; i < users.length; i++) {
      users[i].selected = false;
    }
    
    var route = {title:'删除', index:"member_remove", users:users, eventEmitter:this.eventEmitter};
    this.props.navigator.push(route);
  }

  handleAdd(event) {
    var self = this;
    GroupSettingViewControllerBridge.loadUsers((users) => {
      for (var i = 0; i < users.length; i++) {   
        let u = users[i];

        var index = self.state.members.findIndex((element, index, array) => {
          return (element.uid == u.uid);
        });
        u.is_member = (index != -1);
        u.selected = false;
      }
      console.log("users:", users, "length:", users.length);

      var route = {title:'添加', index:"member_add", users:users, eventEmitter:this.eventEmitter};
      self.props.navigator.push(route);
    });
  }

  handleClickMember(i, event) {
    console.log("this.props:", this.props);
    console.log("i:", i);
    var GroupSettingViewControllerBridge = NativeModules.GroupSettingViewControllerBridge;
    GroupSettingViewControllerBridge.handleClickMember(i.uid);
  }

  quitGroup() {
    console.log("remove member:", this.props.uid);
    let url = this.props.url + "/groups/" + this.props.group_id + "/members/" + this.props.uid;
    console.log("url:", url);

    ProgressHudBridge.showHud();
    fetch(url, {
      method:"DELETE",  
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        "Authorization": "Bearer " + this.props.token,
      },
    }).then((response) => {
      console.log("status:", response.status);
      if (response.status == 200) {
        ProgressHudBridge.hideHud();
        GroupSettingViewControllerBridge.quitGroup();  
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

  handleQuit(event) {
    var BUTTONS = [
      '确定',
      '取消',
    ];

    var self = this;
    ActionSheetIOS.showActionSheetWithOptions({
      options: BUTTONS,
      title:"退出后不会在接受此群聊消息",
      cancelButtonIndex: 1,
      destructiveButtonIndex: 0,
    }, function(buttonIndex) {
      console.log('button index:', buttonIndex);  
      if (buttonIndex == 0) {
        self.quitGroup();
      }
    });
    console.log('Pressed!');
  }
}


reactMixin(GroupSetting.prototype, Subscribable.Mixin);


const styles = StyleSheet.create({
  container: {
    backgroundColor: '#F5FCFF',
  },

  block: {
    backgroundColor: '#FFFFFF',
  },

  line: {
    alignSelf: 'stretch',
    height:1,
    backgroundColor: 'gray',
    marginLeft:10,
  },

  item: {
    paddingTop:8,
    paddingBottom:8,
    paddingLeft:16,
    alignSelf:'stretch',
  },
  itemInternal: {
    flex:1,
    flexDirection:'row',
    justifyContent: 'space-between',
  },

  headButton: {
    width:50,
    height:50,
    margin:4,
    borderRadius:4,
  },
  head: {
    width: 50,
    height: 50,
    borderRadius:4,
  },

  quit: {
    margin: 10,
    padding: 10,
    backgroundColor: 'orangered',
    alignSelf: 'stretch',
    alignItems: 'center',
  },
});


module.exports = GroupSetting;
