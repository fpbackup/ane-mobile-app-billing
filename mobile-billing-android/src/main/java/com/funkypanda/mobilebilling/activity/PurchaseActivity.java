package com.funkypanda.mobilebilling.activity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import com.android.vending.util.IabHelper;
import com.android.vending.util.IabResult;
import com.android.vending.util.Purchase;
import com.funkypanda.mobilebilling.ANEUtils;
import com.funkypanda.mobilebilling.Extension;
import com.funkypanda.mobilebilling.FlashConstants;
import com.funkypanda.mobilebilling.Parsers;
import com.funkypanda.mobilebilling.functions.MakePurchaseFunction;
import org.json.JSONException;
import org.json.JSONObject;

public class PurchaseActivity extends Activity implements IabHelper.OnIabPurchaseFinishedListener
{

    public static String MAKE_PURCHASE = "MakePurchase";
    public static String MAKE_SUBSCRIPTION = "MakeSubscription";

    static final int RC_REQUEST = 10001;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        Bundle extras = getIntent().getExtras();
        String type = extras.getString("type");
        String purchaseId = extras.getString("purchaseId");
        if (MAKE_PURCHASE.equals(type))
        {
            try
            {
                // this calls onIabPurchaseFinished() on error
                ANEUtils.iabHelper.launchPurchaseFlow(this, purchaseId, RC_REQUEST, this, null);
            }
            catch (Exception e)
            {
                MakePurchaseFunction.sendError(-1, e.toString());
                finish();
                return;
            }
        }
        else if (MAKE_SUBSCRIPTION.equals(type))
        {
            try
            {
                ANEUtils.iabHelper.launchSubscriptionPurchaseFlow(this, purchaseId, RC_REQUEST, this);
            }
            catch (IllegalStateException e)
            {
                MakePurchaseFunction.sendError(-1, e.toString());
                finish();
                return;
            }
        }
        else
        {
            MakePurchaseFunction.sendError(-1, "Unsupported billing type: " + type);
            finish();
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        // this calls onIabPurchaseFinished()
        ANEUtils.iabHelper.handleActivityResult(requestCode, resultCode, data);
    }

    public void onIabPurchaseFinished(IabResult result, Purchase purchase)
    {
        if (result.isSuccess())
        {
            try
            {
                Parsers.purchaseToJSON(purchase);
                JSONObject resultObject = Parsers.purchaseToJSON(purchase);
                Extension.dispatchStatusEventAsync(FlashConstants.MAKE_PURCHASE_SUCCESS, "[" + resultObject.toString() + "]");
            }
            catch (JSONException e)
            {
                e.printStackTrace();
                MakePurchaseFunction.sendError(-1, e.toString());
            }
        }
        else
        {
            MakePurchaseFunction.sendError(result.getResponse(), result.getMessage());
        }
        finish();
    }

}

