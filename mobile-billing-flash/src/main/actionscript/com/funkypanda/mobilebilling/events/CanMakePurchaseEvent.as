package com.funkypanda.mobilebilling.events
{

    import flash.events.Event;

    public class CanMakePurchaseEvent extends Event
    {

        public static const CAN_MAKE_PURCHASE : String = "CAN_MAKE_PURCHASE";

        public function CanMakePurchaseEvent(value : Boolean)
        {
            super(CAN_MAKE_PURCHASE);
            _canMakePurchase = value;
        }
        private var _canMakePurchase : Boolean;

        public function get canMakePurchase() : Boolean
        {
            return _canMakePurchase;
        }
    }
}
