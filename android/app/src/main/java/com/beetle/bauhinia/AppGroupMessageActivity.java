package com.beetle.bauhinia;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import com.beetle.bauhinia.activity.GroupSettingActivity;
import com.beetle.bauhinia.api.types.User;
import com.beetle.bauhinia.model.Contact;
import com.beetle.bauhinia.model.ContactDB;
import com.beetle.bauhinia.model.Group;
import com.beetle.bauhinia.model.GroupDB;
import com.beetle.bauhinia.model.PhoneNumber;
import com.beetle.bauhinia.model.UserDB;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.reactnativenavigation.NavigationApplication;

import java.util.ArrayList;

/**
 * Created by houxh on 15/3/21.
 */
public class AppGroupMessageActivity extends GroupMessageActivity {
    private boolean leaved = false;


    @Override
    protected User getUser(long uid) {
        if (uid == 0) {
            User u = new User();
            u.name = "";
            u.avatarURL = "";
            return u;
        }
        com.beetle.bauhinia.api.types.User u = UserDB.getInstance().loadUser(uid);
        Contact c = ContactDB.getInstance().loadContact(new PhoneNumber(u.zone, u.number));
        if (c != null) {
            u.name = c.displayName;
        } else {
            u.name = u.number;
        }
        User user = new User();
        user.name = u.name;
        user.avatarURL = u.avatar != null ? u.avatar : "";
        return user;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        leaved = GroupDB.getInstance().isLeaved(groupID);
        if (leaved) {
            inputMenu.setVisibility(View.GONE);
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        if (!leaved) {
            getMenuInflater().inflate(R.menu.menu_group_chat, menu);
        }
        return true;
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        if (id == R.id.action_setting) {
            Group group = GroupDB.getInstance().loadGroup(groupID);
            if (group == null) {
                return true;
            }
            WritableMap g = this.getGroupMap(group);
            WritableArray contacts = this.getContacts();
            WritableMap map = Arguments.createMap();
            map.putMap("group", g);
            map.putArray("contacts", contacts);

            ReactContext reactContext = NavigationApplication.instance.getReactGateway().getReactContext();
            this.sendEvent(reactContext, "group_setting_android", map);
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private WritableMap getGroupMap(Group group) {
        WritableArray users = Arguments.createArray();
        ArrayList<Long> members = group.getMembers();
        for (int i = 0; i < members.size(); i++) {
            long m = members.get(i);

            com.beetle.bauhinia.api.types.User u = UserDB.getInstance().loadUser(m);
            Contact c = ContactDB.getInstance().loadContact(new PhoneNumber(u.zone, u.number));
            if (c != null) {
                u.name = c.displayName;
            } else {
                u.name = u.number;
            }

            WritableMap map = Arguments.createMap();
            map.putDouble("uid", m);
            map.putDouble("id", m);
            map.putString("name", u.name);
            users.pushMap(map);
        }

        WritableMap map = Arguments.createMap();
        map.putArray("members", users);
        map.putDouble("id", this.groupID);
        map.putString("name", groupName);
        map.putDouble("master", group.master);
        return map;
    }

    private WritableArray getContacts() {
        WritableArray users = Arguments.createArray();
        ContactDB db = ContactDB.getInstance();
        final ArrayList<Contact> contacts = db.getContacts();
        for (int i = 0; i < contacts.size(); i++) {
            Contact c = contacts.get(i);
            for (int j = 0; j < c.phoneNumbers.size(); j++) {
                Contact.ContactData data = c.phoneNumbers.get(j);
                PhoneNumber number = new PhoneNumber();
                if (!number.parsePhoneNumber(data.value)) {
                    continue;
                }

                UserDB userDB = UserDB.getInstance();
                com.beetle.bauhinia.api.types.User u = userDB.loadUser(number);
                if (u != null) {
                    u.name = c.displayName;

                    WritableMap map = Arguments.createMap();
                    map.putString("name", u.name);
                    map.putDouble("uid", u.uid);
                    map.putDouble("id", u.uid);
                    users.pushMap(map);
                }
            }
        }
        return users;
    }

    private void sendEvent(ReactContext reactContext,
                           String eventName,
                           @Nullable WritableMap params) {
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }


}
