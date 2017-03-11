'use strict';

import React, { Component } from 'react';
import {
    AppRegistry,
    StyleSheet,
    Text,
    Image,
    ListView,
    ScrollView,
    TouchableHighlight,
    Navigator,
    BackAndroid,
    TextInput,
    Platform,
    Alert,
    View,
    NativeModules,
    PermissionsAndroid,
} from 'react-native';

import {connect} from 'react-redux'
import ImagePicker from 'react-native-image-picker'
import DialogAndroid from 'react-native-dialogs';

import ProfileDB from './ProfileDB';
import {API_URL} from './config';

class Name extends Component {
    static navigatorButtons = {
        rightButtons: [
            {
                title: '保存', 
                id: 'save', 
                showAsAction: 'ifRoom' 
            },
        ]
    };
    
    
    static navigatorStyle = Platform.select({
        ios: {
            navBarBackgroundColor: '#4dbce9',
            navBarTextColor: '#ffff00',
            navBarSubtitleTextColor: '#ff0000',
            navBarButtonColor: '#ffffff',
            statusBarTextColorScheme: 'light',
        },
        android: {
            navBarBackgroundColor: '#212121',
            navBarTextColor: '#ffffff',
            navBarSubtitleTextColor: '#ff0000',
            navBarButtonColor: '#ffffff',
            statusBarTextColorScheme: 'light',
        }
    });
    
    constructor(props) {
        super(props);
        this.state = {name:this.props.name};
        this.props.navigator.setOnNavigatorEvent(this.onNavigatorEvent.bind(this));
    }
    
    onNavigatorEvent(event) {
        if (event.type == 'NavBarButtonPress') { 
            if (event.id == 'save') {
                if (this.props.name != this.state.name &&
                    this.state.name) {
                    var name = this.state.name;
                    this.showDialog();
                    this.updateName(name)
                        .then((name) => {
                            this.props.dispatch({type:"set_name", name:name});
                            ProfileDB.getInstance().setName(name);
                            this.dialog.dismiss();
                            this.props.navigator.pop();                            
                        })
                        .catch((err) => {
                            console.log("error:", err);
                            this.dialog.dismiss();
                            Alert.alert(
                                '错误',
                                '更新失败',
                                [
                                    {text: 'OK'}
                                ]
                            )
                        })

                }
            }
        }
    }

    updateName(name) {
        var url = API_URL + "/users/me";
        let options = {};
        options.method = 'PATCH';
        options.headers = {
            'Content-Type': 'application/json',
            "Authorization":"Bearer " + this.props.token,
        };
        options.body = JSON.stringify({name:name});
        
        return fetch(url, options)
            .then((response) => {
                console.log("upload name:", response.status);
                if (response.status == 200) {
                    return name;
                } else {
                    return Promise.reject("update name:" + response.status);
                }
            })        
    }

    showDialog() {
        var options = {
            title: '',
            content: '更新中...',
            progress:{
                indeterminate:true
            }
        };

        var dialog = new DialogAndroid();
        dialog.set(options);
        dialog.show();
        
        this.dialog = dialog;
    }
    
    render() {
        var inputHeight = Platform.select({
            ios:35,
            android:35
        });
        
        return (
            <View style={{flex:1, marginHorizontal:16}}>
                <TextInput
                    onChangeText={(text) => {
                            this.setState({name:text});
                        }}
                    style={{    
                        marginTop:40,
                        marginHorizontal:16,
                        height:inputHeight,
                        padding:4,
                    }}
                    underlineColorAndroid='rgba(0,0,0,0)'
                    placeholder=""
                    value={this.state.name}
                />

                <View style={{marginHorizontal:12,  height:1, backgroundColor:"darkgray"}}/>
                <Text style={{marginHorizontal:16, marginTop:8}}>好名字可以让你的朋友更容易记住你</Text>
            </View>
        )
    }
}

Name = connect(function(state){
    return {
        token:state.profile.token,
        name:state.profile.name,
    };
})(Name);

export default Name;
