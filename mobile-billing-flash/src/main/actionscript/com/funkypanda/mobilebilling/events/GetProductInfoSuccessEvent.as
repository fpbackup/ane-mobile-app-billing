package com.funkypanda.mobilebilling.events
{
    import com.funkypanda.mobilebilling.models.Product;

    import flash.events.Event;

    public class GetProductInfoSuccessEvent extends Event
    {

        public static const GET_PRODUCT_INFO_SUCCESS : String = "GET_PRODUCT_INFO_SUCCESS";

        public function GetProductInfoSuccessEvent(products : Vector.<Product>)
        {
            super(GET_PRODUCT_INFO_SUCCESS);
            _products = products;
        }
        private var _products : Vector.<Product>;

        public function get products() : Vector.<Product>
        {
            return _products;
        }
    }
}
