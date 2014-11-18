package com.funkypanda.mobilebilling.events
{

    import flash.events.Event;

    public class GetProductInfoErrorEvent extends Event
    {

        public static const GET_PRODUCT_INFO_ERROR : String = "GET_PRODUCT_INFO_ERROR";

        public function GetProductInfoErrorEvent(errorStr : String)
        {
            super(GET_PRODUCT_INFO_ERROR);
            _message = errorStr;
        }
        private var _message : String;

        public function get message() : String
        {
            return _message;
        }

    }
}
