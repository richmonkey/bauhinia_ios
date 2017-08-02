package com.reactnativenavigation.controllers;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import com.facebook.react.bridge.Callback;
import com.reactnativenavigation.react.NavigationApplication;
import com.reactnativenavigation.params.ActivityParams;
import com.reactnativenavigation.params.ContextualMenuParams;
import com.reactnativenavigation.params.FabParams;
import com.reactnativenavigation.params.ScreenParams;
import com.reactnativenavigation.params.SnackbarParams;
import com.reactnativenavigation.params.TitleBarButtonParams;
import com.reactnativenavigation.params.TitleBarLeftButtonParams;
import com.reactnativenavigation.params.parsers.ActivityParamsParser;
import com.reactnativenavigation.params.parsers.ScreenParamsParser;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class NavigationCommandsHandler {

    private static final String ACTIVITY_PARAMS_BUNDLE = "ACTIVITY_PARAMS_BUNDLE";

    public static ActivityParams parseActivityParams(Intent intent) {
        return ActivityParamsParser.parse(intent.getBundleExtra(NavigationCommandsHandler.ACTIVITY_PARAMS_BUNDLE));
    }

    private static HashMap<String, Class<?>> activitieClasses = new HashMap<>();
    private static HashMap<String, Activity> activities = new HashMap<>();

    static class Navigator {
        public String navigatorID;
        public ArrayList<Activity> activities;
    }

    private static HashMap<String, Navigator> navigators = new HashMap<>();

    public static void registerNavigationActivity(Activity activity, String navigatorID) {
        if (!navigators.containsKey(navigatorID)) {
            Navigator nav = new Navigator();
            nav.navigatorID = navigatorID;
            nav.activities = new ArrayList<>();
            navigators.put(navigatorID, nav);
        }

        Navigator nav = navigators.get(navigatorID);
        if (!nav.activities.contains(activity)) {
            nav.activities.add(activity);
        }
    }

    public static void unregisterNavigationActivity(Activity activity, String navigatorID) {
        if (!navigators.containsKey(navigatorID)) {
            return;
        }
        Navigator nav = navigators.get(navigatorID);
        if (nav.activities.contains(activity)) {
            nav.activities.remove(activity);
        }
    }

    public static void registerActivity(Activity activity, String id) {
        if (!activities.containsKey(id)) {
            activities.put(id, activity);
        }
    }

    public static void unregisterActivity(String id) {
        if (activities.containsKey(id)) {
            activities.remove(id);
        }
    }

    public static void registerActivityClass(Class<?> cls, String id) {
        activitieClasses.put(id, cls);
    }



    public static void push(final Bundle screenParams, final boolean portraitOnlyMode,
                            final boolean landscapeOnlyMode, final String navigatorID,
                            final String screen) {
        NavigationApplication.instance.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (navigators.containsKey(navigatorID)) {
                    Context context;
                    Navigator nav = navigators.get(navigatorID);
                    if (nav.activities.size() > 0) {
                        context = nav.activities.get(nav.activities.size() - 1);
                    } else {
                        context = NavigationApplication.instance;
                    }

                    Intent intent;
                    if (activitieClasses.containsKey(screen)) {
                        Class<?> cls = activitieClasses.get(screen);
                        intent = new Intent(context, cls);
                        try {
                            Method method = cls.getMethod("convertBundle", Bundle.class, Intent.class);
                            method.invoke(null, screenParams, intent);
                        } catch (NoSuchMethodException e) {

                        } catch (InvocationTargetException e) {
                            e.printStackTrace();
                        } catch (IllegalAccessException e) {
                            e.printStackTrace();
                        }

                    } else if (portraitOnlyMode) {
                        intent = new Intent(context, PortraitNavigationActivity.class);
                    } else if (landscapeOnlyMode) {
                        intent = new Intent(context, LandscapeNavigationActivity.class);
                    } else {
                        intent = new Intent(context, NavigationActivity.class);
                    }
                    if (context == NavigationApplication.instance) {
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    }
                    intent.putExtra(ACTIVITY_PARAMS_BUNDLE, screenParams);
                    context.startActivity(intent);
                }
            }
        });
    }

    public static void pushScreen(Bundle screenParams) {
        final NavigationActivity currentActivity = NavigationActivity.currentActivity;
        if (currentActivity == null) {
            return;
        }

        final ScreenParams params = ScreenParamsParser.parse(screenParams);
        NavigationApplication.instance.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                currentActivity.push(params);
            }
        });
    }

    public static void popScreen(Bundle screenParams) {
        final NavigationActivity currentActivity = NavigationActivity.currentActivity;
        if (currentActivity == null) {
            return;
        }

        final ScreenParams params = ScreenParamsParser.parse(screenParams);
        NavigationApplication.instance.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                currentActivity.pop(params);
            }
        });
    }

    public static void pop(Bundle screenParams) {
        final NavigationActivity currentActivity = NavigationActivity.currentActivity;
        if (currentActivity == null) {
            return;
        }

        final ScreenParams params = ScreenParamsParser.parse(screenParams);
        NavigationApplication.instance.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                currentActivity.finish();
            }
        });
    }

    public static void popToRoot(Bundle screenParams) {
        final ScreenParams params = ScreenParamsParser.parse(screenParams);
        com.reactnativenavigation.NavigationApplication.instance.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                String navigatorID = params.getNavigatorId();
                if (navigators.containsKey(navigatorID)) {
                    Navigator nav = navigators.get(navigatorID);
                    if (nav.activities.size() > 1) {
                        for (int i = nav.activities.size() - 1; i > 0; i--) {
                            nav.activities.get(i).finish();
                        }
                    }
                }
            }
        });
    }

    public static void showModal(Bundle screenParams, boolean portraitOnlyMode, boolean landscapeOnlyMode, final String screen) {
        Intent intent;
        if (activitieClasses.containsKey(screen)) {
            Class<?> cls = activitieClasses.get(screen);
            intent = new Intent(NavigationApplication.instance, cls);
            try {
                Method method = cls.getMethod("convertBundle", Bundle.class, Intent.class);
                method.invoke(null, screenParams, intent);
            } catch (NoSuchMethodException e) {

            } catch (InvocationTargetException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            }
        } else if (portraitOnlyMode) {
            intent = new Intent(NavigationApplication.instance, PortraitNavigationActivity.class);
        } else if (landscapeOnlyMode) {
            intent = new Intent(NavigationApplication.instance, LandscapeNavigationActivity.class);
        } else {
            intent = new Intent(NavigationApplication.instance, NavigationActivity.class);
        }
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra(ACTIVITY_PARAMS_BUNDLE, screenParams);
        NavigationApplication.instance.startActivity(intent);
    }

    public static void dismissTopModal() {
        final NavigationActivity currentActivity = NavigationActivity.currentActivity;
        if (currentActivity == null) {
            return;
        }
        NavigationApplication.instance.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                currentActivity.finish();
            }
        });
    }

    public static void setTopBarVisible(final String screenInstanceID, final boolean hidden, final boolean animated) {
        final NavigationActivity currentActivity = NavigationActivity.currentActivity;
        if (currentActivity == null) {
            return;
        }

        NavigationApplication.instance.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                currentActivity.setTopBarVisible(screenInstanceID, hidden, animated);
            }
        });
    }

    public static void setScreenTitleBarTitle(final String screenInstanceId, final String title) {
        final NavigationActivity currentActivity = NavigationActivity.currentActivity;
        if (currentActivity == null) {
            return;
        }

        NavigationApplication.instance.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                currentActivity.setTitleBarTitle(screenInstanceId, title);
            }
        });
    }

    public static void setScreenTitleBarSubtitle(final String screenInstanceId, final String subtitle) {
        final NavigationActivity currentActivity = NavigationActivity.currentActivity;
        if (currentActivity == null) {
            return;
        }

        NavigationApplication.instance.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                currentActivity.setTitleBarSubtitle(screenInstanceId, subtitle);
            }
        });
    }


    public static void setScreenTitleBarRightButtons(final String screenInstanceId,
                                                     final String navigatorEventId,
                                                     final List<TitleBarButtonParams> titleBarButtons) {
        final NavigationActivity currentActivity = NavigationActivity.currentActivity;
        if (currentActivity == null) {
            return;
        }

        NavigationApplication.instance.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                currentActivity.setTitleBarButtons(screenInstanceId, navigatorEventId, titleBarButtons);
            }
        });
    }

    public static void setScreenTitleBarLeftButtons(final String screenInstanceId,
                                                    final String navigatorEventId,
                                                    final TitleBarLeftButtonParams titleBarButtons) {
        final NavigationActivity currentActivity = NavigationActivity.currentActivity;
        if (currentActivity == null) {
            return;
        }

        NavigationApplication.instance.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                currentActivity.setTitleBarLeftButton(screenInstanceId, navigatorEventId, titleBarButtons);
            }
        });
    }

    public static void setScreenFab(final String screenInstanceId, final String navigatorEventId, final FabParams fab) {
        final NavigationActivity currentActivity = NavigationActivity.currentActivity;
        if (currentActivity == null) {
            return;
        }
        NavigationApplication.instance.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                currentActivity.setScreenFab(screenInstanceId, navigatorEventId, fab);
            }
        });
    }




    public static void showSnackbar(final SnackbarParams params) {
        final NavigationActivity currentActivity = NavigationActivity.currentActivity;
        if (currentActivity == null) {
            return;
        }

        NavigationApplication.instance.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                currentActivity.showSnackbar(params);
            }
        });
    }

    public static void showContextualMenu(final String screenInstanceId, final ContextualMenuParams params, final Callback onButtonClicked) {
        final NavigationActivity currentActivity = NavigationActivity.currentActivity;
        if (currentActivity == null) {
            return;
        }

        NavigationApplication.instance.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                currentActivity.showContextualMenu(screenInstanceId, params, onButtonClicked);
            }
        });
    }

    public static void dismissContextualMenu(final String screenInstanceId) {
        final NavigationActivity currentActivity = NavigationActivity.currentActivity;
        if (currentActivity == null) {
            return;
        }

        NavigationApplication.instance.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                currentActivity.dismissContextualMenu(screenInstanceId);
            }
        });
    }
}
