package com.funkypanda.mobilebilling;

import com.android.vending.util.Inventory;
import com.android.vending.util.Purchase;
import com.android.vending.util.SkuDetails;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;

public class Parsers {

    public static JSONArray inventoryProductsToJSON(Inventory inventory) throws JSONException
    {
        JSONArray productsJSON = new JSONArray();
        List<SkuDetails> products = inventory.getAllProducts();
        for (SkuDetails skuDetails : products)
        {
            JSONObject product = new JSONObject();
            product.put("priceLocale", skuDetails.getPrice());
            product.put("productId", skuDetails.getSku());
            product.put("description", skuDetails.getDescription());
            product.put("title", skuDetails.getTitle());
            productsJSON.put(product);
        }
        return productsJSON;
    }

    public static JSONObject purchaseToJSON(Purchase purchase) throws JSONException
    {
        JSONObject resultObject = new JSONObject();
        resultObject.put("productId", purchase.getSku());
        resultObject.put("quantity", "1");
        resultObject.put("transactionDate", Long.toString(purchase.getPurchaseTime()));
        resultObject.put("transactionId", purchase.getOrderId());
        resultObject.put("transactionReceipt", purchase.getToken());
        resultObject.put("rawData", purchase.toString());
        return resultObject;
    }

}
