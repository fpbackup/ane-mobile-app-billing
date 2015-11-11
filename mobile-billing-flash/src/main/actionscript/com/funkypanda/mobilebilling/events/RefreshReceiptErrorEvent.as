package com.funkypanda.mobilebilling.events
{

    import flash.events.Event;

    public class RefreshReceiptErrorEvent extends Event
    {

        static public const REFRESH_RECEIPT_ERROR : String = "REFRESH_RECEIPT_ERROR";

        public function RefreshReceiptErrorEvent(msg : String)
        {
            super(REFRESH_RECEIPT_ERROR);
            _message = msg;
        }
        private var _message : String;

        public function get message() : String
        {
            return _message;
        }
    }
}
