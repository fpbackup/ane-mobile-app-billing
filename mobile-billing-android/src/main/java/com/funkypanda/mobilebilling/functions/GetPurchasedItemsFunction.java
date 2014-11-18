package com.funkypanda.mobilebilling.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.android.vending.util.IabHelper;
import com.android.vending.util.IabResult;
import com.android.vending.util.Inventory;
import com.android.vending.util.Purchase;
import com.funkypanda.mobilebilling.ANEUtils;
import com.funkypanda.mobilebilling.Extension;
import com.funkypanda.mobilebilling.FlashConstants;
import com.funkypanda.mobilebilling.Parsers;
import com.funkypanda.mobilebilling.init.BillingSetupCommand;
import org.json.JSONArray;
import org.json.JSONObject;

import java.util.List;

public class GetPurchasedItemsFunction implements FREFunction
{

    @Override
    public FREObject call(FREContext context, FREObject[] args)
    {
        new BillingSetupCommand().initBillingLibraryIfNeeded(new BillingSetupCommand.OnSetupFinishedListener() {
            @Override
            public void onInitFinished() {
                ANEUtils.iabHelper.queryPurchasedItemsAsync(listener);
            }

            @Override
            public void onInitError(String errorMsg) {
                Extension.dispatchStatusEventAsync(FlashConstants.GET_PURCHASED_ITEMS_ERROR, errorMsg);
            }
        });
        return null;
    }

    IabHelper.QueryInventoryFinishedListener listener = new IabHelper.QueryInventoryFinishedListener()
    {
        public void onQueryInventoryFinished(IabResult result, Inventory inventory)
        {
            if (!result.isSuccess()) {
                Extension.dispatchStatusEventAsync(FlashConstants.GET_PURCHASED_ITEMS_ERROR,
                        "Failed to query inventory: " + result.getMessage());
                return;
            }
            try
            {
                Extension.log("User owns " + inventory.getAllPurchasedItems().size() + " items");
                JSONArray arrJSON = new JSONArray();
                List<Purchase> purchases = inventory.getAllPurchasedItems();
                for (Purchase purchase : purchases)
                {
                    JSONObject purchaseJSON = Parsers.purchaseToJSON(purchase);
                    arrJSON.put(purchaseJSON);
                }
                Extension.dispatchStatusEventAsync(FlashConstants.GET_PURCHASED_ITEMS_SUCCESS, arrJSON.toString());
            }
            catch (Exception e)
            {
                Extension.dispatchStatusEventAsync(FlashConstants.GET_PURCHASED_ITEMS_ERROR, "ERROR parsing reply" + e.toString());
            }

        }
    };

}