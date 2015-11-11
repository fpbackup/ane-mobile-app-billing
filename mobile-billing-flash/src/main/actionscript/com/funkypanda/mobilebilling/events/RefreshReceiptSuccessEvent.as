package com.funkypanda.mobilebilling.events
{

    import flash.events.Event;

    public class RefreshReceiptSuccessEvent extends Event
    {

        public static const REFRESH_RECEIPT_SUCCESS : String = "REFRESH_RECEIPT_SUCCESS";

        public function RefreshReceiptSuccessEvent(value : String)
        {
            super(REFRESH_RECEIPT_SUCCESS);
            _receipt = value;
        }
        private var _receipt : String;

        public function get receipt() : String
        {
            return _receipt;
        }
    }
}
