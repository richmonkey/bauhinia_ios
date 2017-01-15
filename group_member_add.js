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
  ActionSheetIOS,
  Platform,
  View
} from 'react-native';

import {connect} from 'react-redux';

import NavigationBar from 'react-native-navbar';

import {addGroupMembers} from "./actions";

import { NativeModules } from 'react-native';

var native = (Platform.OS == 'android') ? NativeModules.GroupSettingActivity : NativeModules.GroupSettingViewController;




var GroupMemberAdd = React.createClass({
  getInitialState: function() {
    var rowHasChanged = function (r1, r2) {
      return r1 !== r2;
    }
    var ds = new ListView.DataSource({rowHasChanged: rowHasChanged});
    var data = this.props.users.slice();

    for (var i = 0; i < data.length; i++) {
      data[i].id = i;
    }
    return {
      data:data,
      dataSource: ds.cloneWithRows(data),
    };
  },

  addMember: function(users) {
    var userIDs = users.map((u) => u.uid)

    var url = this.props.url + "/client/groups/" + this.props.group_id + "/members";
    native.showHUD();
    fetch(url, {
      method:"POST",  
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        "Authorization": "Bearer " + this.props.token,
      },
      body:JSON.stringify(userIDs),
    }).then((response) => {
      console.log("status:", response.status);
      if (response.status == 200) {
          var e = addGroupMembers(users);
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

  handleAdd: function() {
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
  },

  handleCancel: function() {
    this.props.navigator.pop();
  },

  render: function() {
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

    var leftButtonConfig = {
      title: '取消',
      handler: this.handleCancel,
    };

    var rightButtonConfig = {
      title: '确定',
      handler: this.handleAdd,
    };
    var titleConfig = {
      title: '选择联系人',
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
    if (rowData.is_member) {
      return;
    }
    
    var data = this.state.data;
    var ds = this.state.dataSource;
    var newData = data.slice();
    var newRow = {uid:rowData.uid, name:rowData.name, id:rowData.id, selected:!rowData.selected, is_member:rowData.is_member};
    newData[rowData.id] = newRow;
    this.setState({data:newData, dataSource:ds.cloneWithRows(newData)});
  },

});


const styles = StyleSheet.create({
  row: {
    height:50,
  },
});



export default connect((state) => ({...state}))(GroupMemberAdd);
