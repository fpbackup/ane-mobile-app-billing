package com.funkypanda.mobilebilling.functions;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.android.vending.util.IabHelper;
import com.android.vending.util.IabResult;
import com.android.vending.util.Inventory;
import com.funkypanda.mobilebilling.ANEUtils;
import com.funkypanda.mobilebilling.Extension;
import com.funkypanda.mobilebilling.FlashConstants;
import com.funkypanda.mobilebilling.Parsers;
import com.funkypanda.mobilebilling.init.BillingSetupCommand;
import org.json.JSONArray;

import java.util.List;

public class GetProductsInfoFunction implements FREFunction
{

    @Override
    public FREObject call(FREContext context, FREObject[] args)
    {
        final List<String> skusList = ANEUtils.getListOfStringFromFREArray((FREArray)args[0]);

        new BillingSetupCommand().initBillingLibraryIfNeeded(new BillingSetupCommand.OnSetupFinishedListener() {
            @Override
            public void onInitFinished() {
                Extension.log("Querying inventory for " + skusList.size() + " items");
                ANEUtils.iabHelper.queryItemDetailsAsync(skusList, listener);
            }

            @Override
            public void onInitError(String errorMsg) {
                Extension.dispatchStatusEventAsync(FlashConstants.GET_PRODUCT_INFO_ERROR, errorMsg);
            }
        });
        return null;
    }

    IabHelper.QueryInventoryFinishedListener listener = new IabHelper.QueryInventoryFinishedListener()
    {
        public void onQueryInventoryFinished(IabResult result, Inventory inventory)
        {
            if (!result.isSuccess()) {
                Extension.dispatchStatusEventAsync(FlashConstants.GET_PRODUCT_INFO_ERROR,
                        "Failed to query inventory: " + result.getMessage());
                return;
            }
            try
            {
                JSONArray productsJSON = Parsers.inventoryProductsToJSON(inventory);
                Extension.dispatchStatusEventAsync(FlashConstants.GET_PRODUCT_INFO_SUCCESS, productsJSON.toString());
            }
            catch (Exception e)
            {
                Extension.dispatchStatusEventAsync(FlashConstants.GET_PRODUCT_INFO_ERROR, "ERROR parsing reply" + e.toString());
            }
        }
    };
}