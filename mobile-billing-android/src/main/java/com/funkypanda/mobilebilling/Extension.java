package com.funkypanda.mobilebilling;

import android.app.Activity;
import android.util.Log;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class Extension implements FREExtension
{
    private static final String TAG = "AirInAppPurchase";

    private static ExtensionContext context;

    public static String base64EncodedKey;

    public static void dispatchStatusEventAsync(String eventCode, String message)
    {
        if (context != null)
        {
            log(eventCode + " " + message);
            context.dispatchStatusEventAsync(eventCode, message);
        }
        else
        {
            Log.e(TAG, "ERROR: Extension context is null, was the extension disposed? Tried to send event " +
                 eventCode + " with message " + message);
        }
    }

    public static Activity getActivity()
    {
        return context.getActivity();
    }

    // Called automatically from Flash: ExtensionContext.createExtensionContext()
    public FREContext createContext(String extId)
    {
        return context = new ExtensionContext();
    }

    public void dispose()
    {
        // after calling this dispose() the library will not be usable!
        ANEUtils.iabHelper.dispose();
        context = null;
    }

    public void initialize() {}

    public static void log(String message)
    {
        Log.d(TAG, message);
        context.dispatchStatusEventAsync(FlashConstants.CODE_DEBUG, message);
    }
}