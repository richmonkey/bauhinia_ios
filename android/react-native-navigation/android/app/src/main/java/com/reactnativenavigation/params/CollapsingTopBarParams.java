package com.reactnativenavigation.params;

import android.support.annotation.Nullable;

import com.reactnativenavigation.views.collapsingToolbar.behaviours.CollapseBehaviour;

public class CollapsingTopBarParams {
    public @Nullable String imageUri;
    public StyleParams.Color scrimColor;
    public CollapseBehaviour collapseBehaviour;

    public boolean hasBackgroundImage() {
        return imageUri != null;
    }
}
