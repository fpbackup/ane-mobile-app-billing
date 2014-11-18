package com.funkypanda.mobilebilling;


import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.funkypanda.mobilebilling.functions.*;

import java.util.HashMap;
import java.util.Map;

public class ExtensionContext extends FREContext
{
    public ExtensionContext() {}

    @Override
    public void dispose() {}

    @Override
    public Map<String, FREFunction> getFunctions()
    {
        Map<String, FREFunction> functionMap = new HashMap<String, FREFunction>();

        functionMap.put(FlashConstants.FUNCTION_SET_ANDROID_KEY, new SetKeyFunction());
        functionMap.put(FlashConstants.FUNCTION_GET_PRODUCT_INFO, new GetProductsInfoFunction());
        functionMap.put(FlashConstants.FUNCTION_MAKE_PURCHASE, new MakePurchaseFunction());
        functionMap.put(FlashConstants.FUNCTION_GET_PURCHASED_ITEMS, new GetPurchasedItemsFunction());
        functionMap.put(FlashConstants.FUNCTION_CONSUME_PURCHASE, new ConsumePurchaseFunction());


        return functionMap;
    }


}