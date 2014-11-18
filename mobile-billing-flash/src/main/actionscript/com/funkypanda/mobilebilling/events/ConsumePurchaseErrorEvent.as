package com.funkypanda.mobilebilling.events
{

    import flash.events.Event;

    public class ConsumePurchaseErrorEvent extends Event
    {

        static public const CONSUME_PURCHASE_ERROR : String = "CONSUME_PURCHASE_ERROR";

        public function ConsumePurchaseErrorEvent(msg : String)
        {
            super(CONSUME_PURCHASE_ERROR);
            _message = msg;
        }
        private var _message : String;

        public function get message() : String
        {
            return _message;
        }
    }
}
