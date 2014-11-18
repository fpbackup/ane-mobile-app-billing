package com.funkypanda.mobilebilling.events
{
    import flash.events.Event;

    public class PurchaseDebugEvent extends Event
    {

        public static const DEBUG : String = "DEBUG";

        public function PurchaseDebugEvent(data : String)
        {
            super(DEBUG);
            _message = data;
        }

        private var _message : String;
        public function get message() : String
        {
            return _message;
        }

    }
}
