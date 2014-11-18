package com.funkypanda.mobilebilling.init;

import com.android.vending.util.IabHelper;
import com.android.vending.util.IabResult;
import com.funkypanda.mobilebilling.ANEUtils;
import com.funkypanda.mobilebilling.Extension;

public class BillingSetupCommand implements IabHelper.OnIabSetupFinishedListener
{

    private OnSetupFinishedListener _listener;

    public void initBillingLibraryIfNeeded(OnSetupFinishedListener listener)
    {
        if (Extension.base64EncodedKey == null)
        {
            _listener.onInitError("Google API key must be set before making queries to the Google app store");
            return;
        }
        _listener = listener;

        if (ANEUtils.iabHelper == null)
        {
            Extension.log("Initializing IAB Helper with Key: " + Extension.base64EncodedKey);
            try
            {
                ANEUtils.iabHelper = new IabHelper(Extension.getActivity(), Extension.base64EncodedKey);
                ANEUtils.iabHelper.enableDebugLogging(true);
                ANEUtils.iabHelper.startSetup(this);
            }
            catch (Exception ex)
            {
                _listener.onInitError("Failed to setup the app billing library " + ex.toString());
            }
        }
        else
        {
            _listener.onInitFinished();
        }
    }

    @Override
    public void onIabSetupFinished(IabResult result) {
        if (result.isSuccess())
        {
            _listener.onInitFinished();
        }
        else
        {
            _listener.onInitError("Failed to setup the app billing library " + result.getMessage());
        }
    }

    public interface OnSetupFinishedListener {

        public void onInitFinished();

        public void onInitError(String errorMsg);
    }
}
