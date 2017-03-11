import {Platform} from 'react-native';

export const API_URL = "http://bauhinia.gobelieve.io";
export const SDK_API_URL = "https://api.gobelieve.io";

export const NAVIGATOR_STYLE = Platform.select({
    ios: {

    },
    android: {
        navBarBackgroundColor: '#212121',
        navBarTextColor: '#ffffff',
        navBarSubtitleTextColor: '#ff0000',
        navBarButtonColor: '#ffffff',
        statusBarTextColorScheme: 'light',
    }
});

