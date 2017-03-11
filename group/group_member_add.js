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
    Platform,
    View
} from 'react-native';

import {connect} from 'react-redux';
import {addGroupMembers} from "./actions";
import Spinner from 'react-native-loading-spinner-overlay';
import {API_URL, NAVIGATOR_STYLE} from './config';

class GroupMemberAdd extends Component {
    static navigatorButtons = {
        rightButtons: [
            {
                title: '确定', 
                id: 'setting', 
                showAsAction: 'ifRoom' 
            },
        ]
    };

    static navigatorStyle = NAVIGATOR_STYLE;

    constructor(props) {
        super(props);

        var rowHasChanged = function (r1, r2) {
            return r1 !== r2;
        }
        var ds = new ListView.DataSource({rowHasChanged: rowHasChanged});

        var data = [];
        for (var i = 0; i < this.props.users.length; i++) {
            var m = this.props.users[i];
            data.push(Object.assign({}, m, {index:i}));
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
                this.handleAdd();
            }     
        }
    }
    
    addMember(users) {
        var members = users.map((u) => ({uid:u.id, name:u.name}));

        var url = API_URL + "/client/groups/" + this.props.group_id + "/members";
        this.setState({visible:true});
        fetch(url, {
            method:"POST",  
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                "Authorization": "Bearer " + this.props.token,
            },
            body:JSON.stringify(members),
        }).then((response) => {
            console.log("status:", response.status);
            if (response.status == 200) {
                var members = users.map((u) => {
                    return Object.assign({}, u, {uid:u.id})
                })
                var e = addGroupMembers(members);
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

    handleAdd() {
        var users = [];
        var data = this.state.data;
        for (var i = 0; i < data.length; i++) {
            let u = data[i];
            if (u.selected && !u.is_member) {
                users.push(u);
            }
        }
        if (users.length == 0) {
            return;
        }
        this.addMember(users);
    }

    render() {
        var renderRow = (rowData) => {
            var selectImage = () => {
                if (rowData.is_member) {
                    return require('./img/CellGraySelected.png')
                } else if (rowData.selected) {
                    return  require('./img/CellBlueSelected.png');
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
                    renderRow={renderRow}
                />

                <Spinner visible={this.state.visible} />
            </View>
        );
    }

    rowPressed(rowData) {
        if (rowData.is_member) {
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


const styles = StyleSheet.create({
    row: {
        height:50,
    },
});



export default connect((state) => {
    return {
        token:state.profile.gobelieveToken,
        group_id:state.group.id,
        topic:state.group.name,
        members:state.group.members
    };
})(GroupMemberAdd);
