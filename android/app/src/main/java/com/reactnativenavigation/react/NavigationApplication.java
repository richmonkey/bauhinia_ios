package com.reactnativenavigation.react;

import android.os.Handler;
import android.support.annotation.Nullable;

import com.facebook.react.ReactApplication;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.ReactContext;

import java.util.List;

public abstract class NavigationApplication extends com.reactnativenavigation.NavigationApplication implements ReactApplication {

    public static NavigationApplication instance;

    private NavigationReactGateway reactGateway;
    private EventEmitter eventEmitter;
    private Handler handler;


    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
        handler = new Handler(getMainLooper());
        reactGateway = new NavigationReactGateway();
        eventEmitter = new EventEmitter(reactGateway);
    }

    public void startReactContextOnceInBackgroundAndExecuteJS() {
        reactGateway.startReactContextOnceInBackgroundAndExecuteJS();
    }

    @Override
    public void runOnMainThread(Runnable runnable) {
        handler.post(runnable);
    }

    @Override
    public void runOnMainThread(Runnable runnable, long delay) {
        handler.postDelayed(runnable, delay);
    }

    @Override
    public ReactInstanceManager getReactInstanceManager() {
        return reactGateway.getReactInstanceManager();
    }

    public ReactGateway getReactGateway() {
        return reactGateway;
    }


    public boolean isReactContextInitialized() {
        return reactGateway.isInitialized();
    }

    public boolean hasStartedCreatingContext() {
        return reactGateway.hasStartedCreatingContext();
    }

    public void onReactInitialized(ReactContext reactContext) {
        // nothing
    }

    @Override
    public ReactNativeHost getReactNativeHost() {
        return reactGateway.getReactNativeHost();
    }

    @Override
    public com.reactnativenavigation.bridge.EventEmitter getEventEmitter() {
        return eventEmitter;
    }

    /**
     * @see ReactNativeHost#getJSMainModuleName()
     */
    @Nullable
    public String getJSMainModuleName() {
        return null;
    }

    /**
     * @see ReactNativeHost#getJSBundleFile()
     */
    @Nullable
    public String getJSBundleFile() {
        return null;
    }

    /**
     * @see ReactNativeHost#getBundleAssetName()
     */
    @Nullable
    public String getBundleAssetName() {
        return null;
    }

    public abstract boolean isDebug();

    @Nullable
    public abstract List<ReactPackage> createAdditionalReactPackages();
}
