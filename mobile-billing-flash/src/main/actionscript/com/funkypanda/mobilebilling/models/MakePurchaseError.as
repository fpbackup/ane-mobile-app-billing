package com.funkypanda.mobilebilling.models
{

    public class MakePurchaseError
    {

        public static const PURCHASE_ERROR_OTHER : MakePurchaseError = new MakePurchaseError("PURCHASE_ERROR_OTHER");
        public static const PURCHASE_ERROR_CANCELLED : MakePurchaseError = new MakePurchaseError("PURCHASE_ERROR_CANCELLED");

        public function MakePurchaseError(state : String)
        {
            _state = state;
        }
        private var _state : String;

        public function toString() : String
        {
            return _state;
        }


        public static function fomString(str : String) : MakePurchaseError
        {
            if (str == PURCHASE_ERROR_CANCELLED.toString())
            {
                return MakePurchaseError.PURCHASE_ERROR_CANCELLED;
            }
            return MakePurchaseError.PURCHASE_ERROR_OTHER;
        }
    }
}
