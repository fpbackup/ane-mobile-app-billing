package com.funkypanda.mobilebilling.models
{

    public class MakePurchaseError
    {

        public static const PURCHASE_ERROR_OTHER : MakePurchaseError = new MakePurchaseError("PURCHASE_ERROR_OTHER");
        public static const PURCHASE_ERROR_CANCELLED : MakePurchaseError = new MakePurchaseError("PURCHASE_ERROR_CANCELLED");
        public static const MAKE_PURCHASE_ERROR_NEEDS_REFRESH : MakePurchaseError = new MakePurchaseError("MAKE_PURCHASE_ERROR_NEEDS_REFRESH");

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
            else if (str == MAKE_PURCHASE_ERROR_NEEDS_REFRESH.toString())
            {
                return MakePurchaseError.MAKE_PURCHASE_ERROR_NEEDS_REFRESH;
            }
            return MakePurchaseError.PURCHASE_ERROR_OTHER;
        }
    }
}
