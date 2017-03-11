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
import {NAVIGATOR_STYLE} from './config';

class Profile extends Component {

    static navigatorStyle = NAVIGATOR_STYLE;
    
    constructor(props) {
        super(props);
    }

    onHeader() {
        this.props.navigator.push({
            title:"头像",
            screen:"profile.Header",
            navigatorStyle:{
                tabBarHidden:true
            },
            passProps:{
            },
        });        
    }

    onName() {
        this.props.navigator.push({
            title:"更改名字",
            screen:"profile.Name",
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
                       source={require('../img/PersonalChat.png')}></Image>
            );
        }
    }
    render() {
        var name = this.props.profile.name;
        if (!name) {
            name = "";
        }
        var number = this.props.profile.username;
        
        return (
            <View style={{flex:1}}>
                <ScrollView style={{flex:1, backgroundColor:"#F5FCFF"}}>
                    <TouchableHighlight
                        style={{flex:1,
                                justifyContent:"center",
                                height:64,
                                marginTop:12,
                                backgroundColor:"white"}}
                        activeOpacity={0.6}
                        underlayColor={"gray"}
                        onPress={this.onHeader.bind(this)}>
                        <View style={{height:64,
                                      backgroundColor:"white",
                                      flexDirection:"row",
                                      alignItems:"center",
                                      paddingHorizontal:16,
                                      justifyContent:"space-between"}}>
                            <Text>头像</Text>
                            {this.renderAvatar()}
                        </View>
                    </TouchableHighlight>
                    <View style={{ height:1, backgroundColor:"gray"}}/>
                    
                    <TouchableHighlight
                        style={{flex:1,
                                justifyContent:"center",
                                height:64,
                                backgroundColor:"white"}}
                        activeOpacity={0.6}
                        underlayColor={"gray"}
                        onPress={this.onName.bind(this)}>
                        <View style={{height:64,
                                      backgroundColor:"white",
                                      flexDirection:"row",
                                      alignItems:"center",
                                      paddingHorizontal:16,
                                      justifyContent:"space-between"}}>
                            <Text>昵称</Text>
                            <Text>{name}</Text>
                        </View>
                    </TouchableHighlight>
                    <View style={{ height:1, backgroundColor:"gray"}}/>
                 
                    <View style={{height:64,
                                  backgroundColor:"white",
                                  flexDirection:"row",
                                  alignItems:"center",
                                  paddingHorizontal:16,
                                  justifyContent:"space-between"}}>
                        <Text>手机号码</Text>
                        <Text>{number}</Text>
                    </View>

                    <View style={{ height:1, backgroundColor:"gray"}}/>
                    
                </ScrollView>
            </View>
        );
    }
}





Profile = connect(function(state){
    return {
        profile:state.profile
    };
})(Profile);

export default Profile;
