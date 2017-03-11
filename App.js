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


    //应用主界面
    openMain: function() {
        Navigation.startTabBasedApp({
            tabs: [

                {
                    screen: 'app.Status',
                    icon: require("./img/TabBarIconStatusOff.png"),
                    selectedIcon: require('./img/TabBarIconStatusOn.png'),
                    label:"状态",
                    title:"状态",
                    navigatorStyle: {
                        
                    },
                },
                
            
                {
                    screen: 'app.Contact',
                    icon: require("./img/tabbar_contacts.png"),
                    label:"联系人",
                    title:"联系人",
                    navigatorStyle: {
                        
                    },
                },

                {
                    screen: 'app.Conversation',
                    icon: require("./img/TabBarIconChatsOff.png"),
                    selectedIcon: require("./img/TabBarIconChatsOn.png"),
                    label:"对话",
                    title:"对话",
                    navigatorStyle: {
                        
                    },
                },

                {
                    screen: 'app.Setting',
                    icon: require("./img/TabBarIconSettingsOff.png"),
                    selectedIcon: require("./img/TabBarIconSettingsOn.png"),
                    label:"设置",
                    title:"设置",
                    navigatorStyle: {
                        
                    },
                },
            ],
            passProps: {
                app:this
            }
        });        
    },

    openLogin: function() {
        Navigation.startSingleScreenApp({
            screen: {
                screen: 'app.Authentication',
                title: '手机验证',
                navigatorStyle: {
                },
            },
            passProps: {
                app:this
            }
        });
    },
    
    startApp: function() {

        console.log("start app...");
        
        this.store = createStore(appReducer);
        this.registerScreens();

        var self = this;

        if (Platform.OS == 'ios') {
            var Token = NativeModules.TokenManager;
            Token.getToken()
                 .then((t) => {
                     console.log("token:", t);
                     if (t.uid && t.gobelieveToken) {
                         this.store.dispatch({type:"set_profile", profile:t});
                         this.openMain();
                     } else {
                         return Promise.reject("non token exists");
                     }
                 })
                 .catch((e) => {
                     console.log("err:", e);
                     this.openLogin();
                 });
        } else {
            console.log("get token...");
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
        }

        
        
        RCTDeviceEventEmitter.addListener('create_group', function(event) {
            console.log("create group:", event);
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

        RCTDeviceEventEmitter.addListener('create_group_android', function(event) {
            console.log("create group android:", event);

            var params = {
                screen:{
                    title:"选择成员",
                    screen:"group.GroupSelectMember",
                    navigatorStyle:{
                        tabBarHidden:true
                    },
                    leftButton: {
                        id:"back",
                    },
                },
                passProps:{
                    users:event.users
                },
            };
            Navigation.startSingleScreenApp(params);
        });
        

        RCTDeviceEventEmitter.addListener('open_app_main', function(event) {
            console.log("open app main:", event);
            self.store.dispatch({type:"set_profile", profile:event.token});
            self.openMain();
        });

        RCTDeviceEventEmitter.addListener('group_setting', function(event) {
            console.log("group setting event:", event);

            self.store.dispatch(setGroup(event.group));

            var params = {
                title:"setting",
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


        
        RCTDeviceEventEmitter.addListener('group_setting_android', function(event) {
            console.log("group setting android event:", event);

            self.store.dispatch(setGroup(event.group));

            var params = {
                screen:{
                    title:"setting",
                    screen:"group.GroupSetting",
                    navigatorStyle:{
                        tabBarHidden:true
                    },
                    leftButton: {
                        id:"back",
                    },
                },
                passProps:{
                    contacts:event.contacts
                },
            };
            Navigation.startSingleScreenApp(params);            
        });

        
        RCTDeviceEventEmitter.addListener('open_setting', function(event) {
            console.log("open setting:", event)
            var params = {
                screen:{
                    title:"设置",
                    screen:"app.Setting",
                    navigatorStyle:{
                        tabBarHidden:true
                    },
                    leftButton: {
                        id:"back",
                    },
                },
                passProps:{
                    connectState:event.connectState,
                },
            };
            Navigation.startSingleScreenApp(params);            
        });
        
    },
}

app.startApp();
