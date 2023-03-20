import 'package:flutter/material.dart';
import 'package:hali_saha_bak/utilities/my_snackbar.dart';
import 'package:hali_saha_bak/widgets/my_button.dart';
import 'package:time_range/time_range.dart';

class CloseRangeScreen extends StatefulWidget {
  const CloseRangeScreen({Key? key}) : super(key: key);

  @override
  State<CloseRangeScreen> createState() => _CloseRangeScreenState();
}

class _CloseRangeScreenState extends State<CloseRangeScreen> {
  TimeRangeResult? selectedRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kapalı Saat Aralığı'),
      ),
      body: Padding(
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
              textStyle: const TextStyle(fontWeight: FontWeight.normal, color: Colors.white),
              activeTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              borderColor: Colors.green,
              backgroundColor: Colors.black,
              activeBackgroundColor: Colors.green,
              firstTime: const TimeOfDay(hour: 0, minute: 00),
              lastTime: const TimeOfDay(hour: 24, minute: 00),
              timeStep: 60,
              timeBlock: 60,
              onRangeCompleted: (range) => setState(() => selectedRange = range),
            ),
            const SizedBox(height: 20),
            MyButton(
              text: 'Ekle',
              onPressed: () {
                if (selectedRange != null) {
                  Navigator.pop(context, {'range': selectedRange});
                } else {
                  MySnackbar.show(context, message: 'Tüm alanları doldurunuz.');
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
