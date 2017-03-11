
export function profileReducer(state={}, action) {
    switch(action.type) {
        case "set_profile":
            return action.profile;
        case "set_avatar":
            return Object.assign({}, state, {avatar:action.avatar})
        case "set_name":
            return Object.assign({}, state, {name:action.name});
        default:
            return state;
    }
    
}

