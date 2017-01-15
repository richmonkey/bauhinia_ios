package com.beetle.bauhinia.activity;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;
import android.view.KeyEvent;
import android.widget.Toast;


import com.beetle.bauhinia.BuildConfig;
import com.beetle.bauhinia.Config;
import com.beetle.bauhinia.Token;
import com.beetle.bauhinia.api.types.User;
import com.beetle.bauhinia.model.Contact;
import com.beetle.bauhinia.model.ContactDB;
import com.beetle.bauhinia.model.Group;
import com.beetle.bauhinia.model.GroupDB;
import com.beetle.bauhinia.model.PhoneNumber;
import com.beetle.bauhinia.model.Profile;
import com.beetle.bauhinia.model.UserDB;


import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactPackage;
import com.facebook.react.ReactRootView;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.JavaScriptModule;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.common.LifecycleState;
import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler;
import com.facebook.react.modules.core.RCTNativeAppEventEmitter;
import com.facebook.react.shell.MainReactPackage;
import com.facebook.react.uimanager.ViewManager;


import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class GroupSettingActivity extends Activity implements DefaultHardwareBackBtnHandler {
    private static String TAG = "bauhinia";
    public static final int PERMISSION_REQ_CODE = 1234;
    public static final int OVERLAY_PERMISSION_REQ_CODE = 1235;

    String[] perms = {
            "android.permission.READ_EXTERNAL_STORAGE",
            "android.permission.WRITE_EXTERNAL_STORAGE"
    };

    private long groupID;
    private ReactRootView mReactRootView;
    private ReactInstanceManager mReactInstanceManager;


    ProgressDialog dialog;
    public class GroupSettingModule extends ReactContextBaseJavaModule {
        public GroupSettingModule(ReactApplicationContext reactContext) {
            super(reactContext);
        }

        @Override
        public String getName() {
            return "GroupSettingActivity";
        }


        @ReactMethod
        public void finish() {
            GroupSettingActivity.this.finish();
        }

        @ReactMethod
        public void loadUsers(Callback successCallback) {
            WritableArray users = new WritableNativeArray();

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
                    User u = userDB.loadUser(number);
                    if (u != null) {
                        u.name = c.displayName;

                        WritableMap obj = new WritableNativeMap();
                        obj.putDouble("uid", (double)u.uid);
                        obj.putString("name", u.name);
                        users.pushMap(obj);
                    }
                }
            }
            successCallback.invoke(users);
        }

        @ReactMethod
        public void handleBack() {
            GroupSettingActivity.this.finish();
        }

        @ReactMethod
        public void handleClickMember(Double uid) {
            Log.i(TAG, "click member:" + uid);
        }

        @ReactMethod
        public void quitGroup() {
            GroupSettingActivity.this.finish();
        }

        @ReactMethod
        public void showHUD() {
            GroupSettingActivity.this.dialog = ProgressDialog.show(GroupSettingActivity.this, null, "");
        }

        @ReactMethod
        public void hideHUD() {
            if (GroupSettingActivity.this.dialog != null) {
                GroupSettingActivity.this.dialog.dismiss();
                GroupSettingActivity.this.dialog = null;
            }
        }

        @ReactMethod
        public void hideTextHUD(String text) {
            if (GroupSettingActivity.this.dialog != null) {
                GroupSettingActivity.this.dialog.dismiss();
                GroupSettingActivity.this.dialog = null;
            }
            Toast.makeText(getApplicationContext(), text, Toast.LENGTH_SHORT).show();
        }
    }



    class GroupSettingPackage implements ReactPackage {

        @Override
        public List<Class<? extends JavaScriptModule>> createJSModules() {
            return Collections.emptyList();
        }

        @Override
        public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
            return Collections.emptyList();
        }

        @Override
        public List<NativeModule> createNativeModules(
                ReactApplicationContext reactContext) {
            List<NativeModule> modules = new ArrayList<NativeModule>();

            modules.add(new GroupSettingModule(reactContext));

            return modules;
        }
    }



    public void checkPerms() {
        // Checking if device version > 22 and we need to use new permission model
        if(BuildConfig.DEBUG && Build.VERSION.SDK_INT>Build.VERSION_CODES.LOLLIPOP_MR1) {
            // Checking if we can draw window overlay
            if (!Settings.canDrawOverlays(this)) {
                // Requesting permission for window overlay(needed for all react-native apps)
                Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:" + getPackageName()));
                startActivityForResult(intent, OVERLAY_PERMISSION_REQ_CODE);
            }
            for(String perm : perms){
                // Checking each persmission and if denied then requesting permissions
                if(checkSelfPermission(perm) == PackageManager.PERMISSION_DENIED){
                    requestPermissions(perms, PERMISSION_REQ_CODE);
                    break;
                }
            }
        }
    }

    // Window overlay permission intent result
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == OVERLAY_PERMISSION_REQ_CODE) {
            checkPerms();
        }
    }

    // Permission results
    @Override
    public void onRequestPermissionsResult(int permsRequestCode, String[] permissions, int[] grantResults){
        switch(permsRequestCode){
            case PERMISSION_REQ_CODE:
                // example how to get result of permissions requests (there can be more then one permission dialog)
                // boolean readAccepted = grantResults[0]==PackageManager.PERMISSION_GRANTED;
                // boolean writeAccepted = grantResults[1]==PackageManager.PERMISSION_GRANTED;
                // checking permissions to prevent situation when user denied some permission
                checkPerms();
                break;

        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        checkPerms();

        Intent intent = getIntent();
        groupID = intent.getLongExtra("group_id", 0);
        if (groupID == 0) {
            return;
        }

        Group group = GroupDB.getInstance().loadGroup(groupID);
        if (group == null) {
            return;
        }

        mReactRootView = new ReactRootView(this);
        mReactInstanceManager = ReactInstanceManager.builder()
                .setApplication(getApplication())
                .setBundleAssetName("index.android.bundle")
                .setJSMainModuleName("index.android")
                .addPackage(new MainReactPackage())
                .addPackage(new GroupSettingPackage())
                .setUseDeveloperSupport(BuildConfig.DEBUG)
                .setInitialLifecycleState(LifecycleState.RESUMED)
                .build();


        Bundle props = new Bundle();
        props.putLong("group_id", groupID);
        props.putBoolean("disbanded", group.disbanded);
        props.putString("topic", group.topic);
        props.putLong("master_id", group.master);
        props.putBoolean("is_master", group.master == Profile.getInstance().uid);
        props.putLong("uid", Profile.getInstance().uid);
        props.putString("token", Token.getInstance().accessToken);
        props.putString("url", Config.SDK_API_URL);
        props.putInt("hash_code", hashCode());

        ArrayList<Long> members = group.getMembers();
        Bundle bundles[] = new Bundle[members.size()];
        for (int i = 0; i < members.size(); i++) {
            Long uid = members.get(i);
            User u = UserDB.getInstance().loadUser(uid);
            Contact c = ContactDB.getInstance().loadContact(new PhoneNumber(u.zone, u.number));
            if (c != null) {
                u.name = c.displayName;
            } else {
                u.name = u.number;
            }

            Bundle b = new Bundle();
            b.putString("name", u.name);
            b.putLong("uid", uid);

            bundles[i] = b;
        }

        props.putParcelableArray("members", bundles);

        mReactRootView.startReactApplication(mReactInstanceManager, "GroupSettingIndex", props);
        setContentView(mReactRootView);
    }

    @Override
    public void invokeDefaultOnBackPressed() {
        super.onBackPressed();
    }


    @Override
    protected void onPause() {
        super.onPause();

        if (mReactInstanceManager != null) {
            mReactInstanceManager.onHostPause(this);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();

        if (mReactInstanceManager != null) {
            mReactInstanceManager.onHostResume(this, this);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mReactInstanceManager != null) {
            mReactInstanceManager.onHostDestroy(this);
        }
    }


    @Override
    public void onBackPressed() {
        if (mReactInstanceManager != null) {
            mReactInstanceManager.onBackPressed();
        } else {
            super.onBackPressed();
        }
    }


    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_MENU && mReactInstanceManager != null) {
            mReactInstanceManager.showDevOptionsDialog();
            return true;
        }
        return super.onKeyUp(keyCode, event);
    }


}
