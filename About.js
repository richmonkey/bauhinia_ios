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

export default class Abount extends Component {

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
        this.state = {version:"1.0"};
        NativeModules.TokenManager.getVersion()
                     .then((ver) => {
                         this.setState({version:ver.version});
                     });
    }
    
    render() {
        return (
            <View style={{flex:1,
                          justifyContent:"center",
                          alignItems:"center",
                          backgroundColor:"#F5FCFF"}}>
                <Image style={{height:100, width:100}}
                       source={require('./img/me.png')}>
                </Image>

                <Text style={{marginTop:36}}>{"Copyright 2017 HY Inc."}</Text>
                <Text style={{marginTop:24}}>{"version " + this.state.version}</Text>
            </View>
        )
    }
}
