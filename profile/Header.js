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

class Header extends Component {
    static navigatorButtons = {
        rightButtons: [
            {
                title: '...', 
                id: 'image', 
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
        this.props.navigator.setOnNavigatorEvent(this.onNavigatorEvent.bind(this));
    }

    showDialog() {
        var options = {
            title: '',
            content: '上传中...',
            progress:{
                indeterminate:true
            }
        };

        var dialog = new DialogAndroid();
        dialog.set(options);
        dialog.show();
        
        this.dialog = dialog;
    }
    
    onNavigatorEvent(event) {
        if (event.type == 'NavBarButtonPress') { 
            if (event.id == 'image') {
                var options = {
                    maxWidth:256,
                    title:"",
                    cancelButtonTitle: '取消',
                    takePhotoButtonTitle: '拍照',
                    chooseFromLibraryButtonTitle: '图库',
                };
                
                ImagePicker.showImagePicker(options, (response) => {
                    console.log('Response = ', response);

                    if (response.didCancel) {
                        console.log('User cancelled image picker');
                    } else if (response.error) {
                        console.log('ImagePicker Error: ', response.error);
                    } else if (response.customButton) {
                        console.log('User tapped custom button: ', response.customButton);
                    } else {
                        var uri = response.uri;
                        var fileName = response.fileName;
                        console.log("image width:", response.width,
                                    " height:", response.height);

                        this.showDialog();
                        this.uploadImage(uri, fileName)
                            .then((url) => {
                                return this.updateAvatar(url);
                            })
                            .then((url) => {
                                this.props.dispatch({type:"set_avatar", avatar:url})
                                ProfileDB.getInstance().setAvatar(url);
                                this.dialog.dismiss();
                                this.props.navigator.pop();
                            })
                            .catch((err) => {
                                console.log("error:", err);
                                this.dialog.dismiss();
                                Alert.alert(
                                    '错误',
                                    '更新头像失败',
                                    [
                                        {text: 'OK'}
                                    ]
                                )
                            })
                    }
                });
            }
        }
    }

    uploadImage(uri, fileName) {
        var url = API_URL + "/v2/images";
        var formData = new FormData();
        formData.append('file', {uri: uri, name:fileName, type:"image/jpeg"});
        let options = {};
        options.body = formData;
        options.method = 'POST';
        options.headers = {
            'Content-Type': 'multipart/form-data; boundary=6ff46e0b6b5148d984f148b6542e5a5d',
            "Authorization":"Bearer " + this.props.token,
        };
        return fetch(url, options)
            .then((response) => {
                return Promise.all([response.status, response.json()]);
            })
            .then((values)=>{
                var status = values[0];
                var respJson = values[1];
                if (status != 200) {
                    console.log("upload image fail:", respJson);
                    Promise.reject(respJson);
                    return;
                }
                console.log("upload image success:", respJson);
                return respJson.src_url;
            });
    }

    updateAvatar(avatarURL) {
        var url = API_URL + "/users/me";
        let options = {};
        options.method = 'PATCH';
        options.headers = {
            'Content-Type': 'application/json',
            "Authorization":"Bearer " + this.props.token,
        };
        options.body = JSON.stringify({avatar:avatarURL});
        
        return fetch(url, options)
            .then((response) => {
                console.log("upload avatar:", response.status);
                if (response.status == 200) {
                    return avatarURL;
                } else {
                    return Promise.reject("update avatar:" + response.status);
                }
            })
    }
    
    renderAvatar() {
        if (this.props.avatar) {
            return (
                <Image  style={{width:"100%",
                                height:"100%"}}
                        resizeMode="stretch"
                        source={{uri:this.props.avatar}}>
                </Image>
            );
        } else {
            return (
                <Image style={{width:"100%", height:"100%"}}
                       resizeMode="stretch"
                       source={require('../img/PersonalChat.png')}>
                </Image>
            );
        }
    }
    
    
    render() {
        return (
            <View  style={{flex:1,
                           backgroundColor:"#F5FCFF"}}>
                <View style={{flex:1,
                              flexDirection:"row",
                              alignItems:"stretch",
                              paddingVertical:48,
                              backgroundColor:"#F5FCFF"}}>
                    {this.renderAvatar()}
                </View>
            </View>
        )
    }
}



Header = connect(function(state){
    return {
        profile:state.profile,
        token:state.profile.token,
        avatar:state.profile.avatar,
    };
})(Header);

export default Header;
