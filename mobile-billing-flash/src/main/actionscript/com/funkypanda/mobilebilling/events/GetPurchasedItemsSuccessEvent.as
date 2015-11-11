package com.funkypanda.mobilebilling.events
{

    import flash.events.Event;

    public class GetPurchasedItemsSuccessEvent extends Event
    {

        public static const GET_PURCHASED_ITEMS_SUCCESS : String = "GET_PURCHASED_ITEMS_SUCCESS";

        public function GetPurchasedItemsSuccessEvent(purchaseReceipts : String)
        {
            super(GET_PURCHASED_ITEMS_SUCCESS);
            _purchaseReceipts = purchaseReceipts;
        }
        private var _purchaseReceipts : String;

        public function get purchaseReceipts() : String
        {
            return _purchaseReceipts;
        }
    }
}
