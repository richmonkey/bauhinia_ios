
export function profileReducer(state={}, action) {
    switch(action.type) {
        case "set_profile":
            return action.profile;
        default:
            return state;
    }
    
}

