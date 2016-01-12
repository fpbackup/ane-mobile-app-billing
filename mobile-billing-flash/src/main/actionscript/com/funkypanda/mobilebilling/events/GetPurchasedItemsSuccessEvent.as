package com.funkypanda.mobilebilling.events
{

import com.funkypanda.mobilebilling.models.Purchase;

import flash.events.Event;

    public class GetPurchasedItemsSuccessEvent extends Event
    {

        public static const GET_PURCHASED_ITEMS_SUCCESS : String = "GET_PURCHASED_ITEMS_SUCCESS";

        // iOS only, holds an encoded String that are the receipts (iOS 7+ format).
        // You can send this to Apple to verify it.
        public var purchaseReceiptsIOS : String;

        // Android only
        public var purchasesAndroid : Vector.<Purchase>;

        public function GetPurchasedItemsSuccessEvent()
        {
            super(GET_PURCHASED_ITEMS_SUCCESS);
        }

    }
}
