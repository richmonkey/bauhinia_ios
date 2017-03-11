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
} from 'react-native';

import {connect} from 'react-redux'

class Setting extends Component {

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
    }

    onProfile() {
        console.log("on profile");
        this.props.navigator.push({
            title:"个人信息",
            screen:"profile.Profile",
            navigatorStyle:{
                tabBarHidden:true
            },
            passProps:{
            },
        });
    }

    onAbout() {
        console.log("on about");
        this.props.navigator.push({
            title:"关于",
            screen:"app.About",
            navigatorStyle:{
                tabBarHidden:true
            },
            passProps:{
            },
        });
    }

    renderAvatar() {
        if (this.props.profile.avatar) {
            return (
                <Image style={{width:60, height:60}}
                       source={{uri:this.props.profile.avatar}}></Image>
            );
        } else {
            return (
                <Image style={{width:60, height:60}}
                       source={require('./img/PersonalChat.png')}></Image>
            );
        }
    }

    render() {
        var name = this.props.profile.name;
        if (!name) {
            name = "我";
        }
        
        return (
            <View style={{flex:1}}>
                <ScrollView style={{flex:1, backgroundColor:"#F5FCFF"}}>
                    <View style={{marginTop:16}}>
                        <TouchableHighlight
                            style={{flex:1,
                                    justifyContent:"center",
                                    height:80,
                                    backgroundColor:"white"}}
                            activeOpacity={0.6}
                            underlayColor={"gray"}
                            onPress={this.onProfile.bind(this)}>
                            <View style={{flexDirection:"row", marginLeft:12, alignItems:"center"}}>
                                {this.renderAvatar()}
                                <Text style={{marginLeft:12}}>{name}</Text>
                            </View>
                        </TouchableHighlight>
                    </View>

                    <View style={{height:64,
                                  marginTop:16,
                                  backgroundColor:"white",
                                  flexDirection:"row",
                                  alignItems:"center",
                                  paddingHorizontal:16,
                                  justifyContent:"space-between"}}>
                        <Text>网络状态</Text>
                        <Text>{this.props.connectState}</Text>
                    </View>
                    
                    <View style={{ height:1, backgroundColor:"gray"}}/>
                    
                    <View>
                        <TouchableHighlight
                            style={{flex:1,
                                    justifyContent:"center",
                                    height:64,
                                    backgroundColor:"white"}}
                            activeOpacity={0.6}
                            underlayColor={"gray"}
                            onPress={this.onAbout.bind(this)}>
                            <Text style={{marginLeft:12, marginBottom:4}}>关于</Text>
                        </TouchableHighlight>
                    </View>
                    
                </ScrollView>
            </View>
        );
    }    
}

Setting = connect(function(state){
    return {
        profile:state.profile
    };
})(Setting);

export default Setting;
