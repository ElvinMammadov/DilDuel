package com.example.test;

import android.content.Context;
import android.os.Build;
import android.util.Log;

import androidx.annotation.RequiresApi;

public class Application extends android.app.Application {

    private static Application applicationInstance;

    public static synchronized Application getInstance() {
        return applicationInstance;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        applicationInstance = this;
    }

    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN_MR1)
    public void initAppLanguage(Context context) {
        LocaleUtils.initialize(context, LocaleUtils.getSelectedLanguageId());


    }

}