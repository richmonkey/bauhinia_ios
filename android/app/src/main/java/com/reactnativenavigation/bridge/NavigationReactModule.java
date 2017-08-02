package com.reactnativenavigation.bridge;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.reactnativenavigation.controllers.NavigationCommandsHandler;
import com.reactnativenavigation.params.ContextualMenuParams;
import com.reactnativenavigation.params.FabParams;
import com.reactnativenavigation.params.SnackbarParams;
import com.reactnativenavigation.params.TitleBarButtonParams;
import com.reactnativenavigation.params.TitleBarLeftButtonParams;
import com.reactnativenavigation.params.parsers.ContextualMenuParamsParser;
import com.reactnativenavigation.params.parsers.FabParamsParser;
import com.reactnativenavigation.params.parsers.SnackbarParamsParser;
import com.reactnativenavigation.params.parsers.TitleBarButtonParamsParser;
import com.reactnativenavigation.params.parsers.TitleBarLeftButtonParamsParser;

import java.util.List;

/**
 * The basic abstract components we will expose:
 * BottomTabs (app) - boolean
 * TopBar (per screen)
 * - TitleBar
 * - - RightButtons
 * - - LeftButton
 * - TopTabs (segmented control / view pager tabs)
 * DeviceStatusBar (app) (colors are per screen)
 * AndroidNavigationBar (app) (colors are per screen)
 * SideMenu (app) - boolean, (menu icon is screen-based)
 */
public class NavigationReactModule extends ReactContextBaseJavaModule {
    public static final String NAME = "NavigationReactModule";

    public NavigationReactModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return NAME;
    }


    @ReactMethod
    public void setScreenTitleBarTitle(String screenInstanceId, String title) {
        NavigationCommandsHandler.setScreenTitleBarTitle(screenInstanceId, title);
    }

    @ReactMethod
    public void setScreenTitleBarSubtitle(String screenInstanceId, String subtitle) {
        NavigationCommandsHandler.setScreenTitleBarSubtitle(screenInstanceId, subtitle);
    }

    @ReactMethod
    public void setScreenButtons(String screenInstanceId, String navigatorEventId,
                                 ReadableArray rightButtonsParams, ReadableMap leftButtonParams, ReadableMap fab) {
        if (rightButtonsParams != null) {
            setScreenTitleBarRightButtons(screenInstanceId, navigatorEventId, rightButtonsParams);
        }
        if (leftButtonParams != null) {
            setScreenTitleBarLeftButton(screenInstanceId, navigatorEventId, leftButtonParams);
        }
        if (fab != null) {
            setScreenFab(screenInstanceId, navigatorEventId, fab);
        }
    }

    private void setScreenTitleBarRightButtons(String screenInstanceId, String navigatorEventId, ReadableArray rightButtonsParams) {
        List<TitleBarButtonParams> rightButtons = new TitleBarButtonParamsParser()
                .parseButtons(BundleConverter.toBundle(rightButtonsParams));
        NavigationCommandsHandler.setScreenTitleBarRightButtons(screenInstanceId, navigatorEventId, rightButtons);
    }

    private void setScreenTitleBarLeftButton(String screenInstanceId, String navigatorEventId, ReadableMap leftButtonParams) {
        TitleBarLeftButtonParams leftButton = new TitleBarLeftButtonParamsParser()
                .parseSingleButton(BundleConverter.toBundle(leftButtonParams));
        NavigationCommandsHandler.setScreenTitleBarLeftButtons(screenInstanceId, navigatorEventId, leftButton);
    }

    private void setScreenFab(String screenInstanceId, String navigatorEventId, ReadableMap fab) {
        FabParams fabParams = new FabParamsParser().parse(BundleConverter.toBundle(fab), navigatorEventId, screenInstanceId);
        NavigationCommandsHandler.setScreenFab(screenInstanceId, navigatorEventId, fabParams);
    }


    @ReactMethod
    public void toggleTopBarVisible(final ReadableMap params) {
    }

    @ReactMethod
    public void setTopBarVisible(String screenInstanceId, boolean hidden, boolean animated) {
        NavigationCommandsHandler.setTopBarVisible(screenInstanceId, hidden, animated);
    }



    @ReactMethod
    public void pushScreen(final ReadableMap params) {
        NavigationCommandsHandler.pushScreen(BundleConverter.toBundle(params));
    }


    @ReactMethod
    public void push(final ReadableMap params) {
        boolean portraitOnlyMode = false;
        boolean landscapeOnlyMode = false;
        String navigatorID = "";
        String screen = "";
        if (params.hasKey("portraitOnlyMode")) {
            portraitOnlyMode = params.getBoolean("portraitOnlyMode");
        }

        if (params.hasKey(("landscapeOnlyMode"))) {
            landscapeOnlyMode = params.getBoolean("landscapeOnlyMode");
        }

        if (params.hasKey("navigatorID")) {
            navigatorID = params.getString("navigatorID");
        }
        if (params.hasKey("screen")) {
            screen = params.getString("screen");
        }

        NavigationCommandsHandler.push(BundleConverter.toBundle(params), portraitOnlyMode, landscapeOnlyMode, navigatorID, screen);
    }

    @ReactMethod
    public void pop(final ReadableMap params) {
        NavigationCommandsHandler.pop(BundleConverter.toBundle(params));
    }

    @ReactMethod
    public void popToRoot(final ReadableMap params) {
        NavigationCommandsHandler.popToRoot(BundleConverter.toBundle(params));
    }

    @ReactMethod
    public void showModal(final ReadableMap params) {
        boolean portraitOnlyMode = false;
        boolean landscapeOnlyMode = false;
        String screen = "";
        if (params.hasKey("portraitOnlyMode")) {
            portraitOnlyMode = params.getBoolean("portraitOnlyMode");
        }

        if (params.hasKey(("landscapeOnlyMode"))) {
            landscapeOnlyMode = params.getBoolean("landscapeOnlyMode");
        }
        if (params.hasKey("screen")) {
            screen = params.getString("screen");
        }

        NavigationCommandsHandler.showModal(BundleConverter.toBundle(params), portraitOnlyMode, landscapeOnlyMode, screen);
    }

    @ReactMethod
    public void dismissTopModal() {
        NavigationCommandsHandler.dismissTopModal();
    }


    @ReactMethod
    public void showSnackbar(final ReadableMap params) {
        SnackbarParams snackbarParams = new SnackbarParamsParser().parse(BundleConverter.toBundle(params));
        NavigationCommandsHandler.showSnackbar(snackbarParams);
    }

    @ReactMethod
    public void showContextualMenu(final String screenInstanceId, final ReadableMap params, final Callback onButtonClicked) {
        ContextualMenuParams contextualMenuParams =
                new ContextualMenuParamsParser().parse(BundleConverter.toBundle(params));
        NavigationCommandsHandler.showContextualMenu(screenInstanceId, contextualMenuParams, onButtonClicked);
    }

    @ReactMethod
    public void dismissContextualMenu(String screenInstanceId) {
        NavigationCommandsHandler.dismissContextualMenu(screenInstanceId);
    }
}
