import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';

class MultiSelectDialogItem<V> {
  const MultiSelectDialogItem(this.value, this.labelWidget);

  final V value;
  final Widget labelWidget;
}

class MultiSelectDialog<V> extends StatefulWidget {
  MultiSelectDialog(
      {Key key,
      this.items,
      this.initialSelectedValues,
      this.allowMultiSelect = false,
      this.maxMultiSelect = 0})
      : super(key: key);

  final List<MultiSelectDialogItem<V>> items;
  final Set<V> initialSelectedValues;
  final bool allowMultiSelect;
  final int maxMultiSelect; // max selections, 0 for no limit

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState<V>();
}

class _MultiSelectDialogState<V> extends State<MultiSelectDialog<V>> {
  final _selectedValues = Set<V>();

  void initState() {
    super.initState();
    if (widget.initialSelectedValues != null) {
      _selectedValues.addAll(widget.initialSelectedValues);
    }
  }

  void _onItemCheckedChange(V itemValue, bool checked) {
    setState(() {
      if (checked) {
        if (!widget.allowMultiSelect) {
          _selectedValues.clear();
          _selectedValues.add(itemValue);
        } else if (widget.maxMultiSelect != 0 &&
            _selectedValues.length >= widget.maxMultiSelect) {
          Helper().showToastError(
              "${AppLocalizationHelper.of(context).translate('SelectMaximum')} " +
                  widget.maxMultiSelect.toString() +
                  " ${AppLocalizationHelper.of(context).translate('Items')}");
        } else {
          _selectedValues.add(itemValue);
        }
      } else {
        _selectedValues.remove(itemValue);
      }
    });
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    if (_selectedValues.isNotEmpty) {
      Navigator.pop(context, _selectedValues);
    } else {
      // Alert
      print("errr");
      _showNoInputWarning();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.maxMultiSelect != 0
          ? Text(
              '${AppLocalizationHelper.of(context).translate('SelectMaximum')} ' +
                  widget.maxMultiSelect.toString() +
                  ' ${AppLocalizationHelper.of(context).translate('Items')}',
              style: GoogleFonts.lato())
          : Text('${AppLocalizationHelper.of(context).translate('Select')}',
              style: GoogleFonts.lato()),
      contentPadding: EdgeInsets.only(top: 12.0),
      content: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
          child: ListBody(
            children: widget.items.map(_buildItem).toList(),
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child:
              Text('${AppLocalizationHelper.of(context).translate('Cancel')}'),
          onPressed: _onCancelTap,
        ),
        FlatButton(
          child: Text(
            '${AppLocalizationHelper.of(context).translate('Confirm')}',
            style: GoogleFonts.lato(),
          ),
          onPressed: _onSubmitTap,
        )
      ],
    );
  }

  Widget _buildItem(MultiSelectDialogItem<V> item) {
    final checked = _selectedValues.contains(item.value);
    return CheckboxListTile(
      value: checked,
      title: item.labelWidget,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) => _onItemCheckedChange(item.value, checked),
    );
  }

  Future<void> _showNoInputWarning() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${AppLocalizationHelper.of(context).translate('Notice')}',
            style: GoogleFonts.lato(),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    '${AppLocalizationHelper.of(context).translate('SelectItemOrCancelToGoBack')}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                '${AppLocalizationHelper.of(context).translate('Confirm')}',
                style: GoogleFonts.lato(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

// ===================
