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
  ActionSheetIOS,
  View
} from 'react-native';

import { NativeModules, NativeAppEventEmitter } from 'react-native';


class GroupSetting extends Component {
  constructor(props) {
    super(props);
    this.state = {members:this.props.members};
  }
  
  componentDidMount() {
    console.log("add listener");
    var self = this;
    var add_listener = NativeAppEventEmitter.addListener(
      'member_added',
      (obj) => {
        console.log(obj);
        self.addNewMember(obj['users']);
      }
    );

    var remove_listener = NativeAppEventEmitter.addListener(
      'member_removed',
      (obj) => {
        console.log(obj);
        self.removeMember(obj['id']);
      }
    );

    this.setState({add_listener:add_listener, remove_listener:remove_listener});
  }

  removeMember(id) {
    var members = this.state.members;
    for (var i = 0; i < members.length; i++) {
      let m = members[i];
      if (m.member_id == id) {
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

  render() {
    console.log("render props:", this.props);
    var self = this;
    var rows = this.state.members.map(function(i) {
      return (
        <View key={i.member_id} style={{alignItems:'center'}}>
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
    
    return (
      <View style={{flex:1}}>
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
              <Text>群聊名称</Text>
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
    
  }
  handleRemove(event) {
    var GroupSettingViewControllerBridge = NativeModules.GroupSettingViewControllerBridge;
    GroupSettingViewControllerBridge.handleRemove();
  }

  handleAdd(event) {
    var GroupSettingViewControllerBridge = NativeModules.GroupSettingViewControllerBridge;
    GroupSettingViewControllerBridge.handleAdd();
  }

  handleClickMember(i, event) {
    console.log("this.props:", this.props);
    console.log("i:", i);
    var GroupSettingViewControllerBridge = NativeModules.GroupSettingViewControllerBridge;
    GroupSettingViewControllerBridge.handleClickMember(i.member_id);
  }

  handleQuit(event) {
    var BUTTONS = [
      '确定',
      '取消',
    ];

    ActionSheetIOS.showActionSheetWithOptions({
      options: BUTTONS,
      title:"退出后不会在接受此群聊消息",
      cancelButtonIndex: 1,
      destructiveButtonIndex: 0,
    }, function(buttonIndex) {
      console.log('button index:', buttonIndex);  
      if (buttonIndex == 0) {
        var GroupSettingViewControllerBridge = NativeModules.GroupSettingViewControllerBridge;
        GroupSettingViewControllerBridge.quitGroup();  
      }
    });
    console.log('Pressed!');
  }
}

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
    backgroundColor: 'red',
    alignSelf: 'stretch',
    alignItems: 'center',
  },
});

AppRegistry.registerComponent('GroupSetting', () => GroupSetting);
