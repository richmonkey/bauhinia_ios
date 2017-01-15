/*
 * Copyright (C) 2011 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.beetle.push.core.log;

import android.content.Context;


/**
 * Logging helper class.
 */
public class PushLog {
    private static boolean DEBUG = true;

    public static void v(String tag, String content) {
        android.util.Log.v(tag, content);
    }

    public static void d(String tag, String content) {
        android.util.Log.d(tag, content);
    }

    public static void e(String tag, String content) {
        android.util.Log.e(tag, content);
    }

    public static void e(String tag, Throwable tr) {
        String content = tr.toString();
        android.util.Log.e(tag, content, tr);
    }

    public static void e(String tag, Throwable tr, String content) {
        android.util.Log.e(tag, content, tr);
    }
}
