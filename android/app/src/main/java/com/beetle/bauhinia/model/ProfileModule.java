package com.beetle.bauhinia.model;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;

/**
 * Created by houxh on 2017/3/11.
 */

public class ProfileModule extends ReactContextBaseJavaModule {
    public ProfileModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "ProfileManager";
    }

    @ReactMethod
    public void setAvatar(String avatar) {
        Profile.getInstance().avatar = avatar;
        Profile.getInstance().save(this.getReactApplicationContext());
    }

    @ReactMethod
    public void setName(String name) {
        Profile.getInstance().name = name;
        Profile.getInstance().save(this.getReactApplicationContext());
    }

    @ReactMethod
    public void getProfile(final Promise promise) {
        Profile p = Profile.getInstance();

        WritableMap map = Arguments.createMap();
        map.putDouble("uid", p.uid);
        map.putString("name",  p.name != null ? p.name : "");
        map.putString("avatar", p.avatar != null ? p.avatar : "");
        promise.resolve(map);
    }
}
