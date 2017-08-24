package com.beetle.bauhinia;

import android.support.annotation.NonNull;

import com.facebook.react.modules.core.PermissionListener;
import com.imagepicker.permissions.OnImagePickerPermissionsCallback;

/**
 * Created by houxh on 2017/8/24.
 */

public class NavigationActivity extends com.reactnativenavigation.controllers.NavigationActivity
        implements OnImagePickerPermissionsCallback {

    @Override
    public void setPermissionListener(@NonNull PermissionListener listener) {
        mPermissionListener = listener;
    }
}
