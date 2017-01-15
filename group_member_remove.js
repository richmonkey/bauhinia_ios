/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */


'use strict';

import React, { Component } from 'react';
import {
    AppRegistry,
    StyleSheet,
    Text,
    Image,
    ListView,
    ScrollView,
    Alert,
    TouchableHighlight,
    ActionSheetIOS,
    Platform,
    View
} from 'react-native';

import NavigationBar from 'react-native-navbar';

import { NativeModules } from 'react-native';
var IsAndroid = (Platform.OS == 'android');
var native;
if (IsAndroid) {
    native = NativeModules.GroupSettingActivity;
} else {
    native = NativeModules.GroupSettingViewController;
}


import {connect} from 'react-redux';
import {removeGroupMembers} from "./actions";


var GroupMemberRemove = React.createClass({
    getInitialState: function() {
        var rowHasChanged = function (r1, r2) {
            return r1 !== r2;
        }
        var ds = new ListView.DataSource({rowHasChanged: rowHasChanged});
        var data = this.props.members.slice();

        for (var i = 0; i < data.length; i++) {
            data[i].id = i;
            data[i].selected = false;
        }
        return {
            data:data,
            dataSource: ds.cloneWithRows(data),
        };
    },

    removeMember: function(u) {
        console.log("remove member:", u);
        let url = this.props.url + "/client/groups/" + this.props.group_id + "/members"
        console.log("url:", url);
        [u.uid];
        native.showHUD();
        console.log("token:", this.props.token);
        fetch(url, {
            method:"DELETE",
            body:JSON.stringify([u.uid]),
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                "Authorization": "Bearer " + this.props.token,
            },
        }).then((response) => {
            console.log("status:", response.status);
            if (response.status == 200) {
                var e = removeGroupMembers([u]);
                this.props.dispatch(e);
                native.hideHUD();
                this.props.navigator.pop();
            } else {
                return response.json().then((responseJson)=>{
                    console.log(responseJson.meta.message);
                    native.hideTextHUD(responseJson.meta.message);
                });
            }
        }).catch((error) => {
            console.log("error:", error);
            native.hideTextHUD('' + error);
        });
    },

    handleRemove: function() {
        console.log("confirm");
        var s = [];//selected group member
        var users = this.state.data;
        for (let i = 0; i < users.length; i++) {
            let u = users[i];
            if (u.selected) {
                s.push(u);
            }
        }

        if (s.length == 0) {
            return;
        }

        let u = s[0];
        var alertMessage = '确定要删除成员' + u.name + '?';
        Alert.alert(
            '',
            alertMessage,
            [
                {text: '取消', onPress: () => console.log('Cancel Pressed!')},
                {text: '确定', onPress: () => this.removeMember(u)},
            ]
        );
    },

    render: function() {
        var renderRow = (rowData) => {
            var selectImage = () => {
                if (rowData.selected) {
                    return require('./img/CellBlueSelected.png');
                } else {
                    return require('./img/CellNotSelected.png');
                }
            }

            return (
                <TouchableHighlight style={styles.row} onPress={() => this.rowPressed(rowData)}
                                    underlayColor='#eeeeee' >
                    <View style={{flexDirection:"row", flex:1, alignItems:"center" }}>
                        <Image style={{marginLeft:10}} source={selectImage()}></Image>
                        <Text style={{marginLeft:10}}>{rowData.name}</Text>
                    </View>
                </TouchableHighlight>
            );
        }


        var leftButtonConfig = {
            title: '取消',
            handler: () => {
                this.props.navigator.pop();
            }
        };

        var rightButtonConfig = {
            title: '删除',
            handler: this.handleRemove,
        };
        var titleConfig = {
            title: '删除成员',
        };



        return (
            <View style={{ flex: 1, backgroundColor:"white" }}>
                <NavigationBar
                    statusBar={{hidden:true}}
                    style={{}}
                    title={titleConfig}
                    leftButton={leftButtonConfig} 
                    rightButton={rightButtonConfig} />

                <View style={{height:1, backgroundColor:"lightgrey"}}></View>

                <ListView
                    dataSource={this.state.dataSource}
                    renderRow={renderRow}
                />
            </View>
        );
    },

    rowPressed: function(rowData) {
        var data = this.state.data;
        var ds = this.state.dataSource;

        var newData = data.slice();

        //select only one
        for (var i = 0; i < newData.length; i++) {
            if (i != rowData.id && newData[i].selected) {
                let t = newData[i]
                let t2 = {uid:t.uid, name:t.name, id:t.id, selected:false};
                newData[i] = t2;
            }
        }
        var newRow = {uid:rowData.uid, name:rowData.name, id:rowData.id, selected:!rowData.selected};
        newData[rowData.id] = newRow;
        this.setState({data:newData, dataSource:ds.cloneWithRows(newData)});
    },

});


const styles = StyleSheet.create({
    row: {
        height:50,
    },
});

export default connect((state) => ({...state}))(GroupMemberRemove);
