/* Copyright (c) 2012 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.android.vending.util;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Represents an in-app billing purchase.
 */
public class Purchase {
    String mItemType;  // ITEM_TYPE_INAPP or ITEM_TYPE_SUBS
    String mOrderId;
    String mPackageName;
    String mSku;
    long mPurchaseTime;
    int mPurchaseState;
    String mDeveloperPayload;
    String mToken;
    String mOriginalJson;
    String mSignature;

    public Purchase(String itemType, String jsonPurchaseInfo, String signature) throws JSONException {
        mItemType = itemType;
        mOriginalJson = jsonPurchaseInfo;
        JSONObject o = new JSONObject(mOriginalJson);
        // A unique order identifier for the transaction. This corresponds to the Google Wallet Order ID.
        mOrderId = o.optString("orderId");
        // The application package from which the purchase originated.
        mPackageName = o.optString("packageName");
        // The item's product identifier. Every item has a product ID, which you must specify in the application's
        // product list on the Google Play Developer Console.
        mSku = o.optString("productId");
        // The time the product was purchased, in milliseconds since the epoch (Jan 1, 1970).
        mPurchaseTime = o.optLong("purchaseTime");
        // The purchase state of the order. Possible values are 0 (purchased), 1 (canceled), or 2 (refunded).
        mPurchaseState = o.optInt("purchaseState");
        // A developer-specified string that contains supplemental information about an order.
        // You can specify a value for this field when you make a getBuyIntent request.
        mDeveloperPayload = o.optString("developerPayload");
        // A token that uniquely identifies a purchase for a given item and user pair.
        mToken = o.optString("token", o.optString("purchaseToken"));
        mSignature = signature;
    }

    public String getItemType() { return mItemType; }
    public String getOrderId() { return mOrderId; }
    public String getPackageName() { return mPackageName; }
    public String getSku() { return mSku; }
    public long getPurchaseTime() { return mPurchaseTime; }
    public int getPurchaseState() { return mPurchaseState; }
    public String getDeveloperPayload() { return mDeveloperPayload; }
    public String getToken() { return mToken; }
    public String getOriginalJson() { return mOriginalJson; }
    public String getSignature() { return mSignature; }

    @Override
    public String toString() { return "PurchaseInfo(type:" + mItemType + "):" + mOriginalJson; }
}
