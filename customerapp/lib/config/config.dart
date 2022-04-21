// here goes the config for the application

// store accepts user orders in this range, otherwise will show a store out of
//range notice (user cannot order), measures in meters
const int STORE_ORDER_DISTANCE = 5000;

// if  the distance of prev coord (saved in hive) and device sensor is greater
// than this, pop up location change dialog, measures in meters
const int COORD_RELOCATE_THRESHOLD = 5000;

const String APP_COUNTRY_CODE = "AU";

const String APP_CURRENCY_CODE = "AUD";

const String IOS_PAYMENT_MERCHANT_ID = "merchant.com.gisglobal.vplus";
