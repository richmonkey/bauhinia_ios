package com.reactnativenavigation.react;

import com.facebook.react.bridge.WritableMap;


public class EventEmitter implements com.reactnativenavigation.bridge.EventEmitter{
    private ReactGateway reactGateway;

    public EventEmitter(ReactGateway reactGateway) {
        this.reactGateway = reactGateway;
    }

    public void sendNavigatorEvent(String eventId, String navigatorEventId) {
        if (!NavigationApplication.instance.isReactContextInitialized()) {
            return;
        }
        reactGateway.getReactEventEmitter().sendNavigatorEvent(eventId, navigatorEventId);
    }

    public void sendNavigatorEvent(String eventId, String navigatorEventId, WritableMap data) {
        if (!NavigationApplication.instance.isReactContextInitialized()) {
            return;
        }
        reactGateway.getReactEventEmitter().sendNavigatorEvent(eventId, navigatorEventId, data);
    }

    public void sendEvent(String eventId, String navigatorEventId) {
        if (!NavigationApplication.instance.isReactContextInitialized()) {
            return;
        }
        reactGateway.getReactEventEmitter().sendEvent(eventId, navigatorEventId);
    }

    public void sendNavigatorEvent(String eventId, WritableMap arguments) {
        if (!NavigationApplication.instance.isReactContextInitialized()) {
            return;
        }
        reactGateway.getReactEventEmitter().sendEvent(eventId, arguments);
    }
}
