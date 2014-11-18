package com.funkypanda.mobilebilling.events
{

    import flash.events.Event;

    public class GetPurchasedItemsErrorEvent extends Event
    {

        public static const GET_PURCHASED_ITEMS_ERROR : String = "GET_PURCHASED_ITEMS_ERROR";

        public function GetPurchasedItemsErrorEvent(errorStr : String)
        {
            super(GET_PURCHASED_ITEMS_ERROR);
            _message = errorStr;
        }
        private var _message : String;

        public function get message() : String
        {
            return _message;
        }

    }
}
