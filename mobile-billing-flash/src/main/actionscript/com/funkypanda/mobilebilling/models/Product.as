package com.funkypanda.mobilebilling.models
{
    public class Product
    {
        /** Use this field in the makePurchase() call */
        public var id : String;

        public var title : String;

        public var description : String;

        /** Localized price, e.g. £1.99 or 2.5$ */
        public var priceString : String;

        public function toString() : String
        {
            return "[Product Id: " + id + " Title: " + title + "]";
        }
    }

}
