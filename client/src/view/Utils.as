package view {
public class Utils {
    /**
     * Returns a Number and Converts it into a HEX-String
     *
     * @param number            Number variable as uint that supposed to be converted
     * @param minimumLength    Maximum number of chars that will be returned as a String
     *
     * @return                    The Value of the Input as a Hex-String
     */
    public static function getNumberAsHexString(number:uint, minimumLength:uint = 6):String {
        // The string that will be the output at the end of the function.
        var string:String = number.toString(16).toLowerCase();
        // While the minimumLength argument is higher than the length of the string, add a leading zero.
        while (minimumLength > string.length) {
            string = "0" + string;
        }
        // Return the result with a "0x" in front of the result.
        return string;
    }
}
}
