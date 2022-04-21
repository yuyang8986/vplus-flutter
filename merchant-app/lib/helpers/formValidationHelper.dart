import 'package:flutter/material.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';

class FormValidateService {
  BuildContext context;

  FormValidateService(this.context);

  String validateOrgName(String value) {
    if (value.isEmpty)
      return AppLocalizationHelper.of(context)
          .translate('EmptyOrganizationNameNote');

    if (value.length > 40)
      return AppLocalizationHelper.of(context)
          .translate('InvliadOrganizationnameNote');
    else
      return null;
  }

  String validateOrgAddress(String value) {
    if (value.isEmpty)
      return AppLocalizationHelper.of(context)
          .translate('EmptyOrganizationAddressNote');

    if (value.length > 40)
      return AppLocalizationHelper.of(context)
          .translate('InvalidOrganizationAddressNote');
    else
      return null;
  }

  String validateOrgMobile(String value) {
    if (value.isEmpty || value == null) return null;
    Pattern pattern = r'(\(+61\)|\+61|\(0[1-9]\)|0[1-9])?( ?-?[0-9]){6,9}';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value) || value.length > 12)
      return AppLocalizationHelper.of(context)
          .translate('InvalidPhoneNumberNote');
    else
      return null;
  }

  String validateOrgMobileNotNull(String value) {
    if (value.isEmpty || value == null)
      return AppLocalizationHelper.of(context)
          .translate('EmptyPhoneNumberNote');
    Pattern pattern = r'(\(+61\)|\+61|\(0[1-9]\)|0[1-9])?( ?-?[0-9]){6,9}';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value) || value.length > 12)
      return AppLocalizationHelper.of(context)
          .translate('InvalidPhoneNumberNote');
    else
      return null;
  }

  String validateUserName(String value) {
    if (value.isEmpty)
      return AppLocalizationHelper.of(context).translate('EmpryUsernameNote');

    if (value.length < 6 || value.length > 25)
      return AppLocalizationHelper.of(context).translate('InvalidUserNameNote');
    else
      return null;
  }

  String validatePassword(String value) {
    if (value.isEmpty)
      return AppLocalizationHelper.of(context).translate('PasswordEmptyNote');

    if (value.length < 7 || value.length > 20)
      return AppLocalizationHelper.of(context)
          .translate('PasswordInvalidLengthNote');
    else
      return null;
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (value.length > 0 && !regex.hasMatch(value))
      return AppLocalizationHelper.of(context).translate('InvalidEmailNote');
    else
      return null;
  }

  String validateEmailNotNull(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (value.isEmpty)
      return AppLocalizationHelper.of(context).translate('EmptyEmailNote');
    if (value.length > 0 && !regex.hasMatch(value))
      return AppLocalizationHelper.of(context).translate('InvalidEmailNote');
    else
      return null;
  }

  String validateMobile(String value) {
    if (value.isEmpty || value == null) return null;
    Pattern pattern = r'(\(+61\)|\+61|\(0[1-9]\)|0[1-9])?( ?-?[0-9]){6,9}';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value) || value.length > 12)
      return AppLocalizationHelper.of(context)
          .translate('InvalidPhoneNumberNote');
    else
      return null;
  }

  String validateStoreCode(String value) {
    if (value.isEmpty || value == null)
      return AppLocalizationHelper.of(context).translate('EmptyStoreCodeNote');
    if (value.length > 50)
      return AppLocalizationHelper.of(context)
          .translate('InvalidStoreCodeNote');
  }

  String validateStoreName(String value) {
    if (value.isEmpty || value == null)
      return AppLocalizationHelper.of(context).translate('EmptyStoreNameNote');
    if (value.length < 1 || value.length > 50)
      return AppLocalizationHelper.of(context)
          .translate('InvalidStoreNameNote');
  }

  String validateEmailVerificationCode(String value) {
    if (value.isEmpty || value == null)
      return AppLocalizationHelper.of(context)
          .translate('EmptyVerficationCodeNote');
    if (value.length < 6)
      return AppLocalizationHelper.of(context)
          .translate('InvliadVerficationCodeNote');
    else
      return null;
  }

  String validateMenuCategoryName(String value) {
    if (value.isEmpty || value == null)
      return AppLocalizationHelper.of(context)
          .translate('EmptyCategoryNameNote');
    if (value.length > 35)
      return AppLocalizationHelper.of(context)
          .translate('InvalidCategoryNameNote');
    else
      return null;
  }

  String validateMenuItemName(String value) {
    if (value.isEmpty || value == null)
      return AppLocalizationHelper.of(context)
          .translate('EmptyMenuItemNameNote');
    if (value.length < 1 || value.length > 35)
      return AppLocalizationHelper.of(context)
          .translate('InvalidMenuItemNameNote');
    return null;
  }

  String validateMenuItemSubtitle(String value) {
    if (value.length > 35)
      return AppLocalizationHelper.of(context)
          .translate('InvalidMenuSubtitleAlert');
    return null;
  }

  String validateMenuItemDescription(String value) {
    if (value.length > 50)
      return AppLocalizationHelper.of(context)
          .translate('InvalidMenuItemDescriptionNote');
    return null;
  }

  String validatePrice(String value) {
    if (value.isEmpty || value == null)
      return AppLocalizationHelper.of(context).translate('EmptyPriceNote');

    Pattern pattern = r'^(\-|\+?)\d+(.\d{1,2})?$';
    RegExp regex = new RegExp(pattern);
    if (value.length > 0 && !regex.hasMatch(value))
      return AppLocalizationHelper.of(context).translate('InvalidPriceNote');

    double price = double.parse(value);
    if (price < 0)
      return AppLocalizationHelper.of(context).translate('ZeroPriceNote');

    return null;
  }

  String validateOrderTableName(String value) {
    if (value.isEmpty || value == null)
      return AppLocalizationHelper.of(context).translate('EmptyTableNameNote');

    if (value.length > 10)
      return AppLocalizationHelper.of(context)
          .translate('InvalidTableNameNote');
    else
      return null;
  }
}
