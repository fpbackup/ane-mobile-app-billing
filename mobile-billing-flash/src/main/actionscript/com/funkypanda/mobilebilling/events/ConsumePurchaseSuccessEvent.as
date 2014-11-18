package com.funkypanda.mobilebilling.events
{

    import flash.events.Event;

    public class ConsumePurchaseSuccessEvent extends Event
    {

        public static const CONSUME_PURCHASE_SUCCESS : String = "CONSUME_PURCHASE_SUCCESS";

        public function ConsumePurchaseSuccessEvent(value : String)
        {
            super(CONSUME_PURCHASE_SUCCESS);
            _message = value;
        }
        private var _message : String;

        public function get message() : String
        {
            return _message;
        }
    }
}
