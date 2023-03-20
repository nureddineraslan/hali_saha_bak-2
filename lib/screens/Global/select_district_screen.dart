import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/il_ilce_model.dart';

class SelectDistrictScreen extends StatefulWidget {
  final Il selectedCity;
  final Ilce? selectedDistrict;
  const SelectDistrictScreen({Key? key, required this.selectedCity, this.selectedDistrict}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<SelectDistrictScreen> createState() => _SelectDistrictScreenState(selectedDistrict);
}

class _SelectDistrictScreenState extends State<SelectDistrictScreen> {
  Ilce? selectedDistrict;

  _SelectDistrictScreenState(this.selectedDistrict);

  List searchedDistricts = [];
  bool searched = false;

  void searchCity(String text) {
    if (text.isEmpty || text == '' || text.length == 0) {
      searched = false;

      setState(() {});
      return;
    }
    searched = true;
    searchedDistricts = widget.selectedCity.ilceler.where((x) => x.ilceAdi.toLowerCase().contains(text.toLowerCase())).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şehir Seçiniz'),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context, selectedDistrict);
          },
        ),
        actions: [
          selectedDistrict != null && widget.selectedDistrict == null ||
                  widget.selectedDistrict != null && selectedDistrict!.ilceAdi != widget.selectedDistrict!.ilceAdi
              ? TextButton(
                  onPressed: () {
                    Navigator.pop(context, selectedDistrict);
                  },
                  child: const Text('Kaydet'))
              : const SizedBox(),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'İlçe ara',
              ),
              onChanged: (val) {
                searchCity(val);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: searched ? searchedDistricts.length : widget.selectedCity.ilceler.length,
              itemBuilder: (context, index) {
                Ilce district = searched ? searchedDistricts[index] : widget.selectedCity.ilceler[index];
                return Column(
                  children: [
                    ListTile(
                      onTap: () {
                        setState(() {
                          selectedDistrict = district;
                        });
                      },
                      leading: Text('${index + 1}'),
                      title: Text(district.ilceAdi),
                      trailing: district == selectedDistrict ? const Icon(Icons.done) : null,
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
