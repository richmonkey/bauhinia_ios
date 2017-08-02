package com.reactnativenavigation.layouts;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.RelativeLayout;
import com.facebook.react.bridge.Callback;
import com.reactnativenavigation.events.EventBus;
import com.reactnativenavigation.events.ScreenChangedEvent;
import com.reactnativenavigation.params.ContextualMenuParams;
import com.reactnativenavigation.params.FabParams;
import com.reactnativenavigation.params.ScreenParams;
import com.reactnativenavigation.params.SnackbarParams;
import com.reactnativenavigation.params.TitleBarButtonParams;
import com.reactnativenavigation.params.TitleBarLeftButtonParams;
import com.reactnativenavigation.screens.Screen;
import com.reactnativenavigation.screens.ScreenStack;

import com.reactnativenavigation.views.SnackbarAndFabContainer;

import java.util.List;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;

public class SingleScreenLayout extends RelativeLayout implements Layout {

    private final AppCompatActivity activity;
    protected final ScreenParams screenParams;

    protected ScreenStack stack;
    private SnackbarAndFabContainer snackbarAndFabContainer;

    public SingleScreenLayout(AppCompatActivity activity, ScreenParams screenParams) {
        super(activity);
        this.activity = activity;
        this.screenParams = screenParams;

        createLayout();
    }

    private void createLayout() {
        createStack(getScreenStackParent());
        createFabAndSnackbarContainer();
        sendScreenChangedEventAfterInitialPush();
    }

    private RelativeLayout getScreenStackParent() {
        return this;
    }

    private void createStack(RelativeLayout parent) {
        if (stack != null) {
            stack.destroy();
        }
        stack = new ScreenStack(activity, parent, screenParams.getNavigatorId(), this);
        LayoutParams lp = new LayoutParams(MATCH_PARENT, MATCH_PARENT);
        pushInitialScreen(lp);
    }

    protected void pushInitialScreen(LayoutParams lp) {
        stack.pushInitialScreen(screenParams, lp);
        stack.show();
    }

    private void sendScreenChangedEventAfterInitialPush() {
        if (screenParams.topTabParams != null) {
            EventBus.instance.post(new ScreenChangedEvent(screenParams.topTabParams.get(0)));
        } else {
            EventBus.instance.post(new ScreenChangedEvent(screenParams));
        }
    }

    private void createFabAndSnackbarContainer() {
        snackbarAndFabContainer = new SnackbarAndFabContainer(getContext(), this);
        RelativeLayout.LayoutParams lp = new LayoutParams(MATCH_PARENT, MATCH_PARENT);
        lp.addRule(ALIGN_PARENT_BOTTOM);
        snackbarAndFabContainer.setLayoutParams(lp);
        getScreenStackParent().addView(snackbarAndFabContainer);
    }

    @Override
    public boolean onBackPressed() {
        if (stack.handleBackPressInJs()) {
            return true;
        }

        if (stack.canPop()) {
            stack.pop(true);
            EventBus.instance.post(new ScreenChangedEvent(stack.peek().getScreenParams()));
            return true;
        } else {
            this.activity.finish();
            return true;
        }
    }

    @Override
    public void destroy() {
        stack.destroy();
        snackbarAndFabContainer.destroy();
    }

    @Override
    public void push(ScreenParams params) {
        LayoutParams lp = new LayoutParams(MATCH_PARENT, MATCH_PARENT);
        stack.push(params, lp);
        EventBus.instance.post(new ScreenChangedEvent(params));
    }

    @Override
    public void pop(ScreenParams params) {
        stack.pop(params.animateScreenTransitions);
        EventBus.instance.post(new ScreenChangedEvent(stack.peek().getScreenParams()));
    }



    @Override
    public void setTopBarVisible(String screenInstanceID, boolean visible, boolean animate) {
        stack.setScreenTopBarVisible(screenInstanceID, visible, animate);
    }

    @Override
    public void setTitleBarTitle(String screenInstanceId, String title) {
        stack.setScreenTitleBarTitle(screenInstanceId, title);
    }

    @Override
    public void setTitleBarSubtitle(String screenInstanceId, String subtitle) {
        stack.setScreenTitleBarSubtitle(screenInstanceId, subtitle);
    }

    @Override
    public View asView() {
        return this;
    }

    @Override
    public void setTitleBarRightButtons(String screenInstanceId, String navigatorEventId,
                                        List<TitleBarButtonParams> titleBarRightButtons) {
        stack.setScreenTitleBarRightButtons(screenInstanceId, navigatorEventId, titleBarRightButtons);
    }

    @Override
    public void setTitleBarLeftButton(String screenInstanceId, String navigatorEventId, TitleBarLeftButtonParams titleBarLeftButtonParams) {
        stack.setScreenTitleBarLeftButton(screenInstanceId, navigatorEventId, titleBarLeftButtonParams);
    }

    @Override
    public void setFab(String screenInstanceId, String navigatorEventId, FabParams fabParams) {
        stack.setFab(screenInstanceId, navigatorEventId, fabParams);
    }


    @Override
    public void showSnackbar(SnackbarParams params) {
        final String navigatorEventId = stack.peek().getNavigatorEventId();
        snackbarAndFabContainer.showSnackbar(navigatorEventId, params);
    }


    @Override
    public void showContextualMenu(String screenInstanceId, ContextualMenuParams params, Callback onButtonClicked) {
        stack.showContextualMenu(screenInstanceId, params, onButtonClicked);
    }

    @Override
    public void dismissContextualMenu(String screenInstanceId) {
        stack.dismissContextualMenu(screenInstanceId);
    }

    @Override
    public Screen getCurrentScreen() {
        return stack.peek();
    }

    @Override
    public boolean onTitleBarBackButtonClick() {
        return onBackPressed();
    }
}
