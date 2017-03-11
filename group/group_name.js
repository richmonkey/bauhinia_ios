import React, { Component } from 'react';
import {
    AppRegistry,
    StyleSheet,
    Text,
    Image,
    ScrollView,
    TouchableHighlight,
    TextInput,
    Platform,
    View
} from 'react-native';

import { connect } from 'react-redux';
import {updateGroupName} from "./actions";
import Spinner from 'react-native-loading-spinner-overlay';
import {API_URL, NAVIGATOR_STYLE} from './config';

class GroupName extends Component {
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
        this.state = {
            topic:this.props.topic,
            visible:false
        };
        
        this.props.navigator.setOnNavigatorEvent(this.onNavigatorEvent.bind(this));
    }

    onNavigatorEvent(event) {
        if (event.type == 'NavBarButtonPress') { 
            if (event.id == 'setting') {
                this.updateName();
            }     
        }
    }

    updateName() {
        if (this.state.topic == this.props.topic) {
            return;
        }
        console.log("update group name...:", this.props.token, this.props.group_id);
        this.setState({visible:true});
        var name = this.state.topic;
        var url = API_URL + "/client/groups/" + this.props.group_id;
        fetch(url, {
            method:"PATCH",
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                "Authorization": "Bearer " + this.props.token,
            },
            body:JSON.stringify({name:name}),
        }).then((response) => {
            console.log("update group name status:", response.status);
            if (response.status == 200) {
                this.setState({visible:false});
                this.props.dispatch(updateGroupName(name));
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

    render() {
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



export default connect((state) => {
    return {
        topic:state.group.name,
        group_id:state.group.id,
        token:state.profile.gobelieveToken
    };
})(GroupName);

