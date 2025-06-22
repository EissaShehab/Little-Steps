import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';

class DatePickerField extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateSelected;
  final String labelText;
  final String placeholder;
  final BuildContext context;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final InputDecoration? decoration;
  final String? Function(DateTime?)? validator;

  const DatePickerField({
    super.key,
    this.initialDate,
    required this.onDateSelected,
    required this.labelText,
    required this.placeholder,
    required this.context,
    this.firstDate,
    this.lastDate,
    this.decoration,
    this.validator,
    DateTime? selectedDate,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  late DateTime? _selectedDate = widget.initialDate;

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      validator: widget.validator ??
          (value) {
            return value == null
                ? AppLocalizations.of(widget.context)!.dateOfBirthRequired
                : null;
          },
      builder: (field) => InkWell(
        onTap: () => _selectDate(context, field),
        child: InputDecorator(
          decoration: (widget.decoration ??
                  InputDecoration(
                    labelText: widget.labelText,
                    hintText: widget.placeholder,
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ))
              .copyWith(
            errorText: field.errorText,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDate != null
                    ? DateFormat.yMMMd().format(_selectedDate!)
                    : widget.placeholder,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Icon(
                Icons.calendar_today,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, FormFieldState<DateTime> field) async {
    // تحديد النطاق الافتراضي: منذ 5 سنوات حتى اليوم
    final now = DateTime.now();
    final defaultFirstDate = now.subtract(const Duration(days: 365 * 5));
    final defaultLastDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: widget.firstDate ?? defaultFirstDate,
      lastDate: widget.lastDate ?? defaultLastDate,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Theme.of(context).colorScheme.primary,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      widget.onDateSelected(picked);
      field.didChange(picked);
    }
  }
}
