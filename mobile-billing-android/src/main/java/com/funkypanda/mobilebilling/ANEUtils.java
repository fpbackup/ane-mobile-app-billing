package com.funkypanda.mobilebilling;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREObject;
import com.android.vending.util.IabHelper;

import java.util.ArrayList;
import java.util.List;

public class ANEUtils {

    public static IabHelper iabHelper;

    public static String getStringFromFREObject(FREObject object)
    {
        try
        {
            return object.getAsString();
        }
        catch (Exception e)
        {
            e.printStackTrace();
            return null;
        }
    }

    public static Boolean getBooleanFromFREObject(FREObject object)
    {
        try
        {
            return object.getAsBool();
        }
        catch(Exception e)
        {
            e.printStackTrace();
            return false;
        }
    }

    public static List<String> getListOfStringFromFREArray(FREArray array)
    {
        List<String> result = new ArrayList<String>();

        try
        {
            for (int i = 0; i < array.getLength(); i++)
            {
                try
                {
                    result.add(getStringFromFREObject(array.getObjectAt((long)i)));
                }
                catch (Exception e)
                {
                    e.printStackTrace();
                }
            }
        }
        catch (Exception e)
        {
            e.printStackTrace();
            return null;
        }

        return result;
    }
}
