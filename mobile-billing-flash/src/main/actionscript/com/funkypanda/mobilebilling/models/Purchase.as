package com.funkypanda.mobilebilling.models
{

    public class Purchase
    {

        public var productId : String = "";
        public var quantity : int = 1;
        public var transactionDate : Date;
        public var transactionId : String = "";
        public var rawData : Object;
        public var receipt : String;

        public function toString() : String
        {
            return "[Purchase product Id: " + productId + " transaction Id: " + transactionId + "]";
        }
    }
}
