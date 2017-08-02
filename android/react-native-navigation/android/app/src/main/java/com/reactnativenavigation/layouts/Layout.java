package com.reactnativenavigation.layouts;

import android.view.View;

import com.facebook.react.bridge.Callback;
import com.reactnativenavigation.params.ContextualMenuParams;
import com.reactnativenavigation.params.FabParams;
import com.reactnativenavigation.params.SnackbarParams;
import com.reactnativenavigation.params.TitleBarButtonParams;
import com.reactnativenavigation.params.TitleBarLeftButtonParams;
import com.reactnativenavigation.screens.Screen;

import java.util.List;

public interface Layout extends ScreenStackContainer {
    View asView();

    boolean onBackPressed();

    void setTopBarVisible(String screenInstanceId, boolean hidden, boolean animated);

    void setTitleBarTitle(String screenInstanceId, String title);

    void setTitleBarSubtitle(String screenInstanceId, String subtitle);

    void setTitleBarRightButtons(String screenInstanceId, String navigatorEventId, List<TitleBarButtonParams> titleBarButtons);

    void setTitleBarLeftButton(String screenInstanceId, String navigatorEventId, TitleBarLeftButtonParams titleBarLeftButtonParams);

    void setFab(String screenInstanceId, String navigatorEventId, FabParams fabParams);

    void showSnackbar(SnackbarParams params);


    void showContextualMenu(String screenInstanceId, ContextualMenuParams params, Callback onButtonClicked);

    void dismissContextualMenu(String screenInstanceId);

    Screen getCurrentScreen();
}
