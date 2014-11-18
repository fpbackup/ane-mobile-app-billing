package com.funkypanda.mobilebilling.events
{
    import com.funkypanda.mobilebilling.models.MakePurchaseError;

    import flash.events.Event;

    public class MakePurchaseErrorEvent extends Event
    {

        public static const MAKE_PURCHASE_ERROR : String = "MAKE_PURCHASE_ERROR";

        public function MakePurchaseErrorEvent(errorEnum : MakePurchaseError, errorMsg : String)
        {
            super(MAKE_PURCHASE_ERROR);
            _message = errorMsg;
            _error = errorEnum;
        }

        private var _message : String;
        public function get message() : String
        {
            return _message;
        }

        private var _error : MakePurchaseError;
        public function get error() : MakePurchaseError
        {
            return _error;
        }

    }
}
