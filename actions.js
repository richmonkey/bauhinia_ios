


export const UPDATE_NAME = "update_name";
export const ADD_MEMBERS = "add_members";
export const REMOVE_MEMBERS = "remove_members"

export function updateGroupName(name) {
    return {
        type:"update_name",
        name
    };
}

export function addGroupMembers(members) {
    return {
        type:"add_members",
        members
    };
}

export function removeGroupMembers(members) {
    return {
        type:"remove_members",
        members
    };
}


function arrayObjectIndexOf(myArray, searchTerm, property) {
    for(var i = 0, len = myArray.length; i < len; i++) {
        if (myArray[i][property] === searchTerm) return i;
    }
    return -1;
}

export function groupApp(state = {topic:"", members:[]}, action) {
    switch(action.type) {
        case UPDATE_NAME:
            console.log("update name:" + action.name);
            return {...state, topic:action.name};
        case ADD_MEMBERS:
            return {...state, members:[...state.members, ...action.members]};
        case REMOVE_MEMBERS:
            var members = state.members.slice();
            action.members.forEach(function(member) {
                var index = arrayObjectIndexOf(members, member.uid, "uid");
                if (index != -1) {
                    members.splice(index, 1);
                }
            });
            return {
                ...state,
                members:members
            };
        default:
            return state;
    }
}

