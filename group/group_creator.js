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
var IsAndroid = (Platform.OS == 'android');
import Spinner from 'react-native-loading-spinner-overlay';

const URL = "https://api.gobelieve.io";
class GroupCreator extends Component {
    static navigatorButtons = {
        rightButtons: [
            {
                title: '创建', 
                id: 'create', 
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
        this.state = {topic:"", visible:false};
        this.props.navigator.setOnNavigatorEvent(this.onNavigatorEvent.bind(this));
    }


    onNavigatorEvent(event) {
        if (event.type == 'NavBarButtonPress') { 
            if (event.id == 'create') {
                this.createGroup();
            }
        }
    }
    componentDidMount() {

    }

    componentWillUnmount() {

    }


    showSpinner() {
        this.setState({visible:true});
    }

    hideSpinner() {
        this.setState({visible:false});
    }

    createGroup() {
        var users = this.props.users.map((u) => {
            return u.id;
        });

        if (this.state.topic.length == 0) {
            Alert.alert(
                '',
                '名称为空',
                [
                    {text: '确定'},
                ]
            )
            return;
        }

        var topic = this.state.topic;
        var obj = {
            master:this.props.profile.uid, 
            name:this.state.topic, 
            "super":false, 
            members:users
        };

        var url = URL + "/client/groups";

        this.showSpinner();
        fetch(url, {
            method:"POST",  
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                "Authorization": "Bearer " + this.props.profile.gobelieveToken,
            },
            body:JSON.stringify(obj),
        }).then((response) => {
            console.log("status:", response.status);
            return response.json().then((responseJson)=>{
                this.hideSpinner();
                if (response.status == 200) {
                    console.log("response json:", responseJson);
                    console.log("group id:", responseJson.data.group_id);
                    var groupID = responseJson.data.group_id;
                    return groupID;
                } else {
                    console.log(responseJson.meta.message);
                    return Promise.reject(responseJson.meta.message);
                } 
            });
        }).then((groupID) => {
            if (Platform.OS == 'ios') {
                this.props.navigator.popToRoot({animated:false});
                this.props.navigator.push({
                    title:topic,
                    screen:"chat.GroupChat",
                    navigatorStyle:{
                        tabBarHidden:true
                    },
                    passProps:{
                        sender:this.props.profile.uid,
                        receiver:groupID,
                        groupID:groupID,
                        name:topic,
                        token:this.props.profile.gobelieveToken,
                    },
                });
            } else {
                var Token = NativeModules.TokenManager;
                Token.handleGroupCreated(groupID, topic);
                                         
            }
        }).catch((error) => {
            console.log("error:", error);
            this.hideSpinner();
            setTimeout(function() {
                Alert.alert(
                    '',
                    '' + error,
                    [
                        {text: '确定'},
                    ]
                );
            }, 10);
        });
    }
    
    render() {
        console.log("render group name");
        return (
            <View style={{flex:1}}>
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

                <Spinner visible={this.state.visible} />
            </View>
        );
    }
    
}


class GroupSelectMember extends Component {
    
    static navigatorButtons = {
        rightButtons: [
            {
                title: '下一步', 
                id: 'next', 
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

        console.log("profile:", this.props.profile.uid, this.props.profile.gobelieveToken);

        var rowHasChanged = function (r1, r2) {
            return r1 !== r2;
        }
        var ds = new ListView.DataSource({rowHasChanged: rowHasChanged});


        var data = [];

        for (var i = 0; i < this.props.users.length; i++) {
            var selected = false;
            var master = false;
            if (this.props.users[i].id == this.props.profile.uid) {
                selected = true;
                master = true;
            }
            data.push(Object.assign({}, this.props.users[i], {index:i, selected:selected, master:master}));
        }
        this.state = {
            data:data,
            dataSource: ds.cloneWithRows(data),
            visible:false,
        };

        this.props.navigator.setOnNavigatorEvent(this.onNavigatorEvent.bind(this));
    }
    
    onNavigatorEvent(event) {
        if (event.type == 'NavBarButtonPress') { 
            if (event.id == 'next') {
                this.handleCreate();
            }
        }
    }
    
    handleCreate() {
        var data = this.state.data;
        var users = data.filter((u) => {
            return u.selected;
        })

        if (users.length == 0) {
            return;
        }

        var navigator = this.props.navigator;
        navigator.push({
            title:"新建群组",
            screen:"group.GroupCreator",
            navigatorStyle:{
                tabBarHidden:true
            },
            passProps:{
                users:users
            },
        });
    }

    showSpinner() {
        this.setState({visible:true});
    }

    hideSpinner() {
        this.setState({visible:false});
    }

    render() {
        var renderRow = (rowData) => {
            var selectImage = () => {
                if (rowData.master) {
                    return require('./img/CellGraySelected.png');
                } else if (rowData.selected) {
                    return require('./img/CellBlueSelected.png');
                } else {
                    return require('./img/CellNotSelected.png');
                }
            }
            var name = rowData.name;
            if (!name && rowData.uid == this.props.profile.uid) {
                name = "自己";
            }

            return (
                <TouchableHighlight style={{height:50}} onPress={() => this.rowPressed(rowData)}
                                    underlayColor='#eeeeee' >
                    <View style={{flexDirection:"row", flex:1, alignItems:"center" }}>
                        <Image style={{marginLeft:10}} source={selectImage()}></Image>
                        <Text style={{marginLeft:10}}>{name}</Text>
                    </View>
                </TouchableHighlight>
            );
        }


        return (
            <View style={{ flex:1, backgroundColor:"#F5FCFF" }}>

                <View style={{height:1, backgroundColor:"lightgrey"}}></View>

                <ListView
                    dataSource={this.state.dataSource}
                    renderRow={renderRow}
                />

                <Spinner visible={this.state.visible} />
            </View>
        );
    }

    rowPressed(rowData) {
        if (rowData.master) {
            return;
        }
        
        var data = this.state.data;
        var ds = this.state.dataSource;
        var newData = data.slice();
        var newRow = Object.assign({}, rowData, {selected:!rowData.selected});
        newData[rowData.index] = newRow;
        this.setState({data:newData, dataSource:ds.cloneWithRows(newData)});
    }

}



GroupCreator = connect(function(state){
    return {
        profile:state.profile
    };
})(GroupCreator);




GroupSelectMember = connect(function(state){
    return {
        profile:state.profile
    };
})(GroupSelectMember);

export {GroupCreator, GroupSelectMember};

