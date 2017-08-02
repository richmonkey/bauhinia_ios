package com.reactnativenavigation;

import android.app.Application;
import android.os.Handler;
import com.facebook.react.ReactInstanceManager;
import com.reactnativenavigation.bridge.EventEmitter;

public abstract class NavigationApplication extends Application {
    public static NavigationApplication instance;


    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
    }

    abstract public void runOnMainThread(Runnable runnable);
    abstract public void runOnMainThread(Runnable runnable, long delay);
    abstract public ReactInstanceManager getReactInstanceManager();
    abstract public EventEmitter getEventEmitter();
    abstract public boolean isDebug();

}
