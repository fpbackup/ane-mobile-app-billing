package com.funkypanda.mobilebilling.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.android.vending.util.IabHelper;
import com.android.vending.util.IabResult;
import com.funkypanda.mobilebilling.ANEUtils;
import com.funkypanda.mobilebilling.Extension;
import com.funkypanda.mobilebilling.FlashConstants;
import com.funkypanda.mobilebilling.init.BillingSetupCommand;

public class ConsumePurchaseFunction implements FREFunction
{

    @Override
    public FREObject call(FREContext ctx, FREObject[] args)
    {
        // Receipt is the token property in Android
        final String receipt = ANEUtils.getStringFromFREObject(args[0]);

        Extension.log("Starting consume with receipt " + receipt);

        if (receipt == null)
        {
            Extension.dispatchStatusEventAsync(FlashConstants.CONSUME_PURCHASE_ERROR, "Receipt cannot be null");
            return null;
        }

        new BillingSetupCommand().initBillingLibraryIfNeeded(new BillingSetupCommand.OnSetupFinishedListener() {
            @Override
            public void onInitFinished() {
                ANEUtils.iabHelper.consumeAsync(IabHelper.ITEM_TYPE_INAPP, receipt, listener);
            }

            @Override
            public void onInitError(String errorMsg) {
                Extension.dispatchStatusEventAsync(FlashConstants.CONSUME_PURCHASE_ERROR, errorMsg);
            }
        });
        return null;
    }

    public IabHelper.OnConsumeFinishedListener listener = new IabHelper.OnConsumeFinishedListener() {
        @Override
        public void onConsumeFinished(IabResult result) {
            Extension.log("Consume finished, success: " + result.isSuccess());
            if (result.isSuccess()) {
                Extension.dispatchStatusEventAsync(FlashConstants.CONSUME_PURCHASE_SUCCESS, result.getMessage());
            }
            else {
                Extension.dispatchStatusEventAsync(FlashConstants.CONSUME_PURCHASE_ERROR, result.getMessage());
            }
        }
    };

}