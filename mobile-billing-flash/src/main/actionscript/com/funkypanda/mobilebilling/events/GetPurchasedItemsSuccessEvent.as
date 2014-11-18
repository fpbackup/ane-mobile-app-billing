package com.funkypanda.mobilebilling.events
{
    import com.funkypanda.mobilebilling.models.Purchase;

    import flash.events.Event;

    public class GetPurchasedItemsSuccessEvent extends Event
    {

        public static const GET_PURCHASED_ITEMS_SUCCESS : String = "GET_PURCHASED_ITEMS_SUCCESS";

        public function GetPurchasedItemsSuccessEvent(purchases : Vector.<Purchase>)
        {
            super(GET_PURCHASED_ITEMS_SUCCESS);
            _purchases = purchases;
        }
        private var _purchases : Vector.<Purchase>;

        public function get purchases() : Vector.<Purchase>
        {
            return _purchases;
        }
    }
}
