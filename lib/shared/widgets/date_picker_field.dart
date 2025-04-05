import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DatePickerField extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateSelected;
  final String labelText;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final InputDecoration? decoration;

  const DatePickerField({
    super.key,
    this.initialDate,
    required this.onDateSelected,
    required this.labelText,
    this.firstDate,
    this.lastDate,
    this.decoration, DateTime? selectedDate, required String placeholder, required BuildContext context,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  late DateTime? _selectedDate = widget.initialDate;

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      validator: (value) => value == null ? 'Please select a date' : null,
      builder: (field) => InkWell(
        onTap: () => _selectDate(context, field),
        child: InputDecorator(
          decoration: (widget.decoration ?? const InputDecoration()).copyWith(
            labelText: widget.labelText,
            errorText: field.errorText,
            border: const OutlineInputBorder(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDate != null
                    ? DateFormat.yMMMd().format(_selectedDate!)
                    : 'Select Date',
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime.now(),
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
