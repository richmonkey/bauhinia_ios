'use strict';
import React from 'react';
import {
    AppRegistry,
    StyleSheet,
    Text,
    Image,
    ListView,
    ScrollView,
    Alert,
    TouchableHighlight,
    Platform,
    View
} from 'react-native';

import {connect} from 'react-redux';
import {removeGroupMembers} from "./actions";
import Spinner from 'react-native-loading-spinner-overlay';

import {API_URL} from './config';

class GroupMemberRemove extends React.Component {
    static navigatorButtons = {
        rightButtons: [
            {
                title: '确定', 
                id: 'setting', 
                showAsAction: 'ifRoom' 
            },
        ]
    };

    static navigatorStyle = {
        navBarBackgroundColor: '#4dbce9',
        navBarTextColor: '#ffff00',
        navBarSubtitleTextColor: '#ff0000',
        navBarButtonColor: '#ffffff',
        statusBarTextColorScheme: 'light',
    };
    
    constructor(props) {
        super(props);

        var rowHasChanged = function (r1, r2) {
            return r1 !== r2;
        }
        var ds = new ListView.DataSource({rowHasChanged: rowHasChanged});
        
        var data = [];
        for (var i = 0; i < this.props.members.length; i++) {
            var m = this.props.members[i];
            data.push(Object.assign({}, m, {index:i, selected:false}));
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
            if (event.id == 'setting') {
                this.handleRemove();
            }     
        }
    }

    removeMember(u) {
        console.log("remove member:", u);
        let url = API_URL + "/client/groups/" + this.props.group_id + "/members"
        console.log("url:", url);
        this.setState({visible:true});
        fetch(url, {
            method:"DELETE",
            body:JSON.stringify([u]),
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
                this.setState({visible:false});
                this.props.navigator.pop();
            } else {
                return response.json().then((responseJson)=>{
                    console.log(responseJson.meta.message);
                    this.setState({visible:false});
                });
            }
        }).catch((error) => {
            console.log("error:", error);
            this.setState({visible:false});
        });
    }

    handleRemove() {
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
    }

 
    render() {
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

        return (
            <View style={{ flex: 1, backgroundColor:"white" }}>
                <ListView
                    dataSource={this.state.dataSource}
                    renderRow={renderRow}/>

                <Spinner visible={this.state.visible} />
            </View>
        );
    }

    rowPressed(rowData) {
        var data = this.state.data;
        var ds = this.state.dataSource;

        var newData;
        var selected = !rowData.selected;
        if (selected) {
            newData = data.map((t) => {
                return Object.assign({}, t, {selected:false});
            });
        } else {
            newData = data.slice();
        }
        
        var newRow = Object.assign({}, rowData, {selected:selected});
        newData[rowData.index] = newRow;
        this.setState({data:newData, dataSource:ds.cloneWithRows(newData)});
    }
}


const styles = StyleSheet.create({
    row: {
        height:50,
    },
});

GroupMemberRemove = connect(function(state){
    return {
        token:state.profile.gobelieveToken,
        group_id:state.group.id,
        topic:state.group.name,
        members:state.group.members
    };
})(GroupMemberRemove);
export default GroupMemberRemove;
