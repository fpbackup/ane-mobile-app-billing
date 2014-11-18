package com.funkypanda.mobilebilling.events
{
    import com.funkypanda.mobilebilling.models.Purchase;

    import flash.events.Event;

    public class MakePurchaseSuccessEvent extends Event
    {

        public static const MAKE_PURCHASE_SUCCESS : String = "MAKE_PURCHASE_SUCCESS";

        public function MakePurchaseSuccessEvent(purchases : Vector.<Purchase>)
        {
            super(MAKE_PURCHASE_SUCCESS);
            _purchases = purchases;
        }

        private var _purchases : Vector.<Purchase>;
        public function get purchases() : Vector.<Purchase>
        {
            return _purchases;
        }

    }
}
