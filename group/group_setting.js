
import React, { Component } from 'react';
import {
    AppRegistry,
    StyleSheet,
    Text,
    Image,
    ScrollView,
    TouchableHighlight,
    ActionSheetIOS,
    Platform,
    View
} from 'react-native';

import { connect } from 'react-redux';
import Spinner from 'react-native-loading-spinner-overlay';
import {API_URL} from './config';

class GroupSetting extends Component {
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

        this.state = {visible:false};
        console.log("group name:", this.props.topic);
        console.log("contacts:", this.props.contacts);
        console.log("group id:", this.props.group_id);
    }
    
    componentDidMount() {

    }


    componentWillUnmount() {

    }

   

    render() {
        var self = this;
        var rows = this.props.members.map(function(i) {
            return (
                <View key={i.uid} style={{alignItems:'center', height:78}}>
                    <TouchableHighlight underlayColor='gray' style={styles.headButton} onPress={self.handleClickMember.bind(self, i)} >
                        <Image
                            source={require('./img/PersonalChat.png')}
                            style={styles.head}
                        />
                    </TouchableHighlight>
                    <Text numberOfLines={1} style={{width:50, height:20}}>{i.name}</Text>

                </View>
            );
            
        });
    
        
        return (
            <View style={{flex:1}}>
                <ScrollView style={styles.container}>
                    <View style={styles.block}>
                        <View style={{flex: 1, flexDirection:'row', flexWrap: 'wrap', marginLeft:10, marginBottom:10}}>
                            {rows}
                            <TouchableHighlight  underlayColor='gray' style={styles.headButton} onPress={this.handleAdd.bind(this)}>
                                <Image
                                    source={require('./img/AddGroupMemberBtn.png')}
                                    style={styles.head}
                                />
                            </TouchableHighlight>
                            {
                                this.props.is_master ?
                                (
                                    <TouchableHighlight  underlayColor='gray' style={styles.headButton} onPress={this.handleRemove.bind(this)}>
                                        <Image
                                            source={require('./img/RemoveGroupMemberBtn.png')}
                                            style={{width:50, height:50}}
                                        />
                                    </TouchableHighlight>
                                ) : null
                            }
                        </View>
                        
                        <View style={styles.line}/>

                        <TouchableHighlight underlayColor='ghostwhite' style={styles.item} onPress={this.handleName.bind(this)} >
                            <View style={styles.itemInternal}>
                                <Text>群聊名称</Text>
                                <View style={{flexDirection:'row', alignItems:"center", marginRight:8}}>
                                    <Text>{this.props.topic}</Text>
                                    <Image source={require('./img/TableViewArrow.png')}
                                           style={{marginLeft:4, width:20, height:20}} />
                                </View>
                            </View>
                        </TouchableHighlight>
                    </View>

                    <TouchableHighlight underlayColor="lightcoral" style={styles.quit} onPress={this.handleQuit.bind(this)}>
                        <Text>退出</Text>
                    </TouchableHighlight>
                    
                </ScrollView>

                <Spinner visible={this.state.visible} />
            </View>
        );
    }

    handleName(event) {
        this.props.navigator.push({
            title:"群聊名称",
            screen:"group.GroupName",
            navigatorStyle:{
                tabBarHidden:true
            },
            passProps:{
            },
        });
    }

    handleRemove(event) {
        this.props.navigator.push({
            title:"名称",
            screen:"group.GroupMemberRemove",
            navigatorStyle:{
                tabBarHidden:true
            },
            passProps:{
            },
        });
    }

    handleAdd(event) {
        var self = this;
        var users = this.props.contacts;

        var users = users.map((u) => {
            var index = this.props.members.findIndex((e) => {
                return e.uid == u.id;
            });

            var is_member = (index != -1);
            return Object.assign({}, u, {selected:false, is_member:is_member});
        });
   
        console.log("users:", users, "length:", users.length);

        self.props.navigator.push({
            title:"添加",
            screen:"group.GroupMemberAdd",
            navigatorStyle:{
                tabBarHidden:true
            },
            passProps:{
                users:users
            },
        });

    }

    handleClickMember(i, event) {
    
    }

    quitGroup() {
        console.log("remove member:", this.props.uid);
        let url = API_URL + "/client/groups/" + this.props.group_id + "/members"
        u = {uid:this.props.uid, "name":this.props.name};
        
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
                this.setState({visible:false});
                this.props.navigator.pop();
            } else {
                return response.json().then((responseJson)=>{
                    console.log(responseJson);
                    this.setState({visible:false});
                });
            }
        }).catch((error) => {
            console.log("error:", error);
            this.setState({visible:false});
        });
    }

    handleQuit(event) {
        var BUTTONS = [
            '确定',
            '取消',
        ];

        var self = this;
        ActionSheetIOS.showActionSheetWithOptions({
            options: BUTTONS,
            title:"退出后不会在接受此群聊消息",
            cancelButtonIndex: 1,
            destructiveButtonIndex: 0,
        }, function(buttonIndex) {
            console.log('button index:', buttonIndex);  
            if (buttonIndex == 0) {
                self.quitGroup();
            }
        });
        console.log('Pressed!');
    }
}


const styles = StyleSheet.create({
    container: {
        backgroundColor: '#F5FCFF',
        marginTop: 10,
    },

    block: {
        backgroundColor: '#FFFFFF',
    },

    line: {
        alignSelf: 'stretch',
        height:1,
        backgroundColor: 'gray',
        marginLeft:10,
    },

    item: {
        paddingTop:8,
        paddingBottom:8,
        paddingLeft:16,
        alignSelf:'stretch',
    },
    itemInternal: {
        flex:1,
        flexDirection:'row',
        justifyContent: 'space-between',
    },

    headButton: {
        width:50,
        height:50,
        margin:4,
        borderRadius:4,
    },
    head: {
        width: 50,
        height: 50,
        borderRadius:4,
    },

    quit: {
        margin: 10,
        padding: 10,
        backgroundColor: 'orangered',
        alignSelf: 'stretch',
        alignItems: 'center',
    },
});

export default connect(function(state) {
    return {
        token:state.profile.gobelieveToken,
        topic:state.group.name,
        group_id:state.group.id,
        uid:state.profile.uid,
        name:state.profile.name,
        members:state.group.members,
        is_master:(state.group.master == state.profile.uid),
    };
})(GroupSetting);
