package com.funkypanda.mobilebilling.functions;

import android.content.Intent;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.android.vending.util.IabHelper;
import com.funkypanda.mobilebilling.ANEUtils;
import com.funkypanda.mobilebilling.Extension;
import com.funkypanda.mobilebilling.FlashConstants;
import com.funkypanda.mobilebilling.activity.PurchaseActivity;
import com.funkypanda.mobilebilling.init.BillingSetupCommand;
import org.json.JSONObject;

public class MakePurchaseFunction implements FREFunction
{

    @Override
    public FREObject call(FREContext ctx, FREObject[] args)
    {
        final String purchaseId = ANEUtils.getStringFromFREObject(args[0]);
        final FREContext context = ctx;

        if (purchaseId == null)
        {
            sendError(-1, "Can't make purchase with null purchaseId");
            return null;
        }

        new BillingSetupCommand().initBillingLibraryIfNeeded(new BillingSetupCommand.OnSetupFinishedListener() {
            @Override
            public void onInitFinished() {
                Intent i = new Intent(context.getActivity().getApplicationContext(), PurchaseActivity.class);
                i.putExtra("type", PurchaseActivity.MAKE_PURCHASE);
                i.putExtra("purchaseId", purchaseId);
                context.getActivity().startActivity(i);
                // the end of the purchase flow is in PurchaseActivity
            }

            @Override
            public void onInitError(String errorMsg) {
                sendError(-1, errorMsg);
            }
        });
        return null;
    }

    public static void sendError(int iabError, String message)
    {
        FlashConstants.MakePurchaseError errorCode;
        switch (iabError) {
            case IabHelper.IABHELPER_USER_CANCELLED:
                errorCode = FlashConstants.MakePurchaseError.PURCHASE_ERROR_CANCELLED;
                break;
            default:
                errorCode = FlashConstants.MakePurchaseError.PURCHASE_ERROR_OTHER;
        }
        try
        {
            JSONObject resultObject = new JSONObject();
            resultObject.put("error", errorCode.toString());
            resultObject.put("message", message);
            Extension.dispatchStatusEventAsync(FlashConstants.MAKE_PURCHASE_ERROR, resultObject.toString());
        }
        catch (Exception ex)
        {
            Extension.dispatchStatusEventAsync(FlashConstants.MAKE_PURCHASE_ERROR,
                "{error:'" + FlashConstants.MakePurchaseError.PURCHASE_ERROR_OTHER +"', message:'JSON parsing error'}");
        }


    }

}