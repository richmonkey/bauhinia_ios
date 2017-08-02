import React, { Component } from 'react';
import {
    AppRegistry,
    StyleSheet,
    Text,
    TextInput,
    Image,
    ScrollView,
    Navigator,
    TouchableHighlight,
    ActionSheetIOS,
    NetInfo,
    AppState,
    View,
    Platform,
    AsyncStorage,
    NativeModules,
    NativeAppEventEmitter,
} from 'react-native';

import { createStore } from 'redux'
import { Provider } from 'react-redux'
import RCTDeviceEventEmitter from 'RCTDeviceEventEmitter'
import {Navigation} from 'react-native-navigation';

import About from './About';
import Setting from './Setting';

import Name from './profile/Name.js';
import Profile from './profile/Profile.js';
import Header from './profile/Header.js'

import {GroupCreator, GroupSelectMember} from "./group/group_creator";
import GroupSetting from './group/group_setting';
import GroupName from './group/group_name';
import GroupMemberAdd from './group/group_member_add';
import GroupMemberRemove from './group/group_member_remove';


import {profileReducer} from './reducers';
import {setGroup, groupReducer} from './group/actions';

//do not use combineReducers which ignore init state of createStore
function appReducer(state={}, action) {
    return {
        profile:profileReducer(state.profile, action),
        group:groupReducer(state.group, action),
    };
}

//仅注册用，不会真正创建
class AppView extends Component {
    constructor(props) {
        super(props);
    }
    render() {
        return (
            <Text>test</Text>
        );
    }
}


var app = {
    registerScreens: function() {
        Navigation.registerComponent('profile.Profile', () => Profile, this.store, Provider);
        Navigation.registerComponent('profile.Name', () => Name, this.store, Provider);
        Navigation.registerComponent('profile.Header', () => Header, this.store, Provider);
        Navigation.registerComponent('app.Setting', () => Setting, this.store, Provider);
        Navigation.registerComponent('app.About', () => About, this.store, Provider);
        
        Navigation.registerComponent('app.Authentication', () => AppView, this.store, Provider);
        Navigation.registerComponent('app.Conversation', () => AppView, this.store, Provider);
        Navigation.registerComponent('app.Contact', () => AppView, this.store, Provider);
        Navigation.registerComponent('app.Status', () => AppView, this.store, Provider);
        
        Navigation.registerComponent('chat.GroupChat', () => AppView, this.store, Provider);
        
        Navigation.registerComponent('group.GroupSelectMember', () => GroupSelectMember, this.store, Provider);
        Navigation.registerComponent('group.GroupCreator', () => GroupCreator, this.store, Provider);
        Navigation.registerComponent('group.GroupSetting', () => GroupSetting, this.store, Provider);
        Navigation.registerComponent('group.GroupName', () => GroupName, this.store, Provider);
        Navigation.registerComponent('group.GroupMemberAdd', () => GroupMemberAdd, this.store, Provider);
        Navigation.registerComponent('group.GroupMemberRemove', () => GroupMemberRemove, this.store, Provider);
    },

    
    startApp: function() {
        console.log("start app...");
        this.store = createStore(appReducer);
        this.registerScreens();
        var self = this;
      
        var Token = NativeModules.TokenManager;
        Token.getToken()
             .then((t) => {
                 console.log("token:", t);
                 if (t.uid && t.gobelieveToken) {
                     this.store.dispatch({type:"set_profile", profile:t});
                     
                 } else {
                     return Promise.reject("non token exists");
                 }
             })
             .catch((e) => {
                 console.log("err:", e);
             });
        
        RCTDeviceEventEmitter.addListener('create_group', function(event) {
            console.log("create group:", event);
            self.store.dispatch({type:"set_profile", profile:event.profile});
            var params = {
                title:"选择成员",
                screen:"group.GroupSelectMember",
                navigatorStyle:{
                    tabBarHidden:true
                },
                passProps:{
                    users:event.users
                },
            }
            Navigation.push(event.navigatorID, params);
        });
    

        RCTDeviceEventEmitter.addListener('group_setting', function(event) {
            console.log("group setting event:", event);
            self.store.dispatch({type:"set_profile", profile:event.profile});
            self.store.dispatch(setGroup(event.group));

            var params = {
                title:"聊天信息",
                screen:"group.GroupSetting",
                navigatorStyle:{
                    tabBarHidden:true
                },
                passProps:{
                    contacts:event.contacts
                },
            }
            Navigation.push(event.navigatorID, params);
        });

        
        RCTDeviceEventEmitter.addListener('open_setting', function(event) {
            console.log("open setting:", event)
            var params = {
                title:"设置",
                screen:"app.Setting",
                navigatorStyle:{
                    tabBarHidden:true
                },
                passProps:{
                    connectState:event.connectState,
                },
            };
            Navigation.push(event.navigatorID, params);            
        });
        
    },
}

app.startApp();
