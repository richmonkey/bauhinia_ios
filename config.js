import {Platform} from 'react-native';

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

