import {NativeModules} from 'react-native';
var instance = null;
export default class ProfileDB {
    static getInstance() {
        if (!instance) {
            instance = new ProfileDB()
        }
        return instance;
    }
    
    constructor() {
        
    }
    
    setAvatar(avatar) {
        var p = NativeModules.ProfileManager;
        p.setAvatar(avatar);
    }

    setName(name) {
        var p = NativeModules.ProfileManager;
        p.setName(name);
    }
}
