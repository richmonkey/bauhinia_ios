package com.reactnativenavigation.layouts;

import com.reactnativenavigation.params.ScreenParams;
import com.reactnativenavigation.views.LeftButtonOnClickListener;

public interface ScreenStackContainer extends LeftButtonOnClickListener {
    void push(ScreenParams screenParams);

    void pop(ScreenParams screenParams);

    void destroy();
}
