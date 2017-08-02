package com.reactnativenavigation.bridge;

import com.facebook.react.bridge.WritableMap;


public interface EventEmitter {

    public void sendNavigatorEvent(String eventId, String navigatorEventId);

    public void sendNavigatorEvent(String eventId, String navigatorEventId, WritableMap data);

    public void sendEvent(String eventId, String navigatorEventId);

    public void sendNavigatorEvent(String eventId, WritableMap arguments);

}
