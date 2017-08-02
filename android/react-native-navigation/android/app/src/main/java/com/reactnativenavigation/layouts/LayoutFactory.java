package com.reactnativenavigation.layouts;

import android.support.v7.app.AppCompatActivity;

import com.reactnativenavigation.params.ActivityParams;

public class LayoutFactory {
    public static Layout create(AppCompatActivity activity, ActivityParams params) {
        switch (params.type) {
            case SingleScreen:
            default:
                return createSingleScreenLayout(activity, params);
        }
    }
    private static Layout createSingleScreenLayout(AppCompatActivity activity, ActivityParams params) {
        return new SingleScreenLayout(activity, params.screenParams);
    }
}
