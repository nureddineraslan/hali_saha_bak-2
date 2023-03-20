import 'package:flutter/material.dart';
import 'package:hali_saha_bak/utilities/enums.dart';
import 'package:hali_saha_bak/utilities/my_snackbar.dart';
import 'package:hali_saha_bak/widgets/my_button.dart';
import 'package:time_range/time_range.dart';

import '../../../widgets/my_textfield.dart';

class SubscriberRangeScreen extends StatefulWidget {
  const SubscriberRangeScreen({Key? key}) : super(key: key);

  @override
  State<SubscriberRangeScreen> createState() => _SubscriberRangeScreenState();
}

class _SubscriberRangeScreenState extends State<SubscriberRangeScreen> {
  TextEditingController subscriberController = TextEditingController();
  TimeRangeResult? selectedRange;
  List<int> days = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abonelik Aralığı'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TimeRange(
                fromTitle: const Text(
                  'Başlangıç Saati',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                toTitle: const Text(
                  'Bitiş Saati',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.normal, color: Colors.white),
                activeTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
                borderColor: Colors.green,
                backgroundColor: Colors.black,
                activeBackgroundColor: Colors.green,
                firstTime: const TimeOfDay(hour: 0, minute: 00),
                lastTime: const TimeOfDay(hour: 24, minute: 00),
                timeStep: 60,
                timeBlock: 60,
                onRangeCompleted: (range) =>
                    setState(() => selectedRange = range),
              ),
              const SizedBox(height: 20),
              MyTextfield(
                hintText: 'Müşteri adı giriniz',
                title: 'Müşteri',
                controller: subscriberController,
              ),
              const SizedBox(height: 20),
              Builder(
                builder: (context) {
                  return Column(
                    children: [
                      for (var i = 1; i < 8; i++)
                        CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          value: days.contains(i),
                          onChanged: (val) {
                            if (days.contains(i)) {
                              print('contains');
                              days.remove(i);
                            } else {
                              days.add(i);
                            }
                            setState(() {});
                          },
                          title: Text(dayStrings[i - 1]),
                        )
                    ],
                  );
                },
              ),
              MyButton(
                text: 'Ekle',
                onPressed: () {
                  if (selectedRange != null &&
                      subscriberController.text.isNotEmpty &&
                      days.isNotEmpty) {
                    Navigator.pop(context, {
                      'range': selectedRange,
                      'subscriber': subscriberController.text,
                      'days': days,
                    });
                  } else {
                    MySnackbar.show(context,
                        message: 'Tüm alanları doldurunuz.');
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
