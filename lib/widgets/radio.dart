import 'package:flutter/material.dart';
import 'package:todo_app/components/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RadioWidget extends StatelessWidget {
  final int value;
  final Function(int) onChanged;

  const RadioWidget({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomRadio(
          label: 'Normal',
          color: kGreenColor,
          isSelected: value == 0,
          onChanged: () {
            onChanged(0);
          },
        ),
        SizedBox(width: 12.w),
        CustomRadio(
          label: 'Urgent',
          color: Colors.red,
          isSelected: value == 1,
          onChanged: () {
            onChanged(1);
          },
        ),
      ],
    );
  }
}

class CustomRadio extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final Function() onChanged;

  const CustomRadio({
    super.key,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged,
      child: Row(
        children: [
          Container(
            width: 20.w,
            height: 20.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2.w),
              color: Colors.white,
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10.w,
                      height: 10.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    ),
                  )
                : null,
          ),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(label, style: kTextStyle3),
          ),
        ],
      ),
    );
  }
}
