package com.beetle.bauhinia;

import android.app.Activity;
import android.text.TextUtils;
import android.util.Log;

import com.beetle.bauhinia.model.Group;
import com.beetle.bauhinia.model.GroupDB;
import com.beetle.bauhinia.model.Profile;
import com.beetle.bauhinia.tools.event.BusProvider;
import com.beetle.bauhinia.tools.event.GroupEvent;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableMap;

/**
 * Created by houxh on 2017/3/9.
 */

public class TokenModule extends ReactContextBaseJavaModule {

    public TokenModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }
    @Override
    public String getName() {
        return "TokenManager";
    }

    @ReactMethod
    public void getVersion(final Promise promise) {
        WritableMap map = Arguments.createMap();
        map.putString("version", BuildConfig.VERSION_NAME);
        promise.resolve(map);
    }

    @ReactMethod
    public void getToken(final Promise promise) {
        String avatar = Profile.getInstance().avatar;
        if (TextUtils.isEmpty(avatar)) {
            avatar = "";
        }

        String name = Profile.getInstance().name;
        if (TextUtils.isEmpty(name)) {
            name = "";
        }

        long uid = Profile.getInstance().uid;
        String token = Token.getInstance().accessToken;
        WritableMap map = Arguments.createMap();
        map.putDouble("uid", uid);
        map.putString("username", "" + uid);
        map.putString("gobelieveToken", token);
        map.putString("token", token);
        map.putString("name", name);
        map.putString("avatar", avatar);
        if (uid > 0) {
            promise.resolve(map);
        } else {
            promise.reject("non token exists", "");
        }
    }
}
