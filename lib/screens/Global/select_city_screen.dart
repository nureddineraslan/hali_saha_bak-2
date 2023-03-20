import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hali_saha_bak/models/il_ilce_model.dart';

class SelectCityScreen extends StatefulWidget {
  const SelectCityScreen({Key? key, this.selectedCity}) : super(key: key);

  final Il? selectedCity;

  @override
  // ignore: no_logic_in_create_state
  State<SelectCityScreen> createState() => _SelectCityScreenState(selectedCity);
}

class _SelectCityScreenState extends State<SelectCityScreen> {
  List cities = [];

  Il? selectedCity;

  _SelectCityScreenState(this.selectedCity);

  Future<void> loadCityData() async {
    String jsonString = await rootBundle.loadString('assets/json/il-ilce.json');

    final dynamic jsonResponse = json.decode(jsonString);

    setState(() {
      cities = jsonResponse.map((x) => Il.fromJson(x)).toList();
    });
  }

  List searchedCities = [];
  bool searched = false;

  void searchCity(String text) {
    if (text.isEmpty) {
      searched = false;
      setState(() {});
      return;
    }
    searched = true;
    searchedCities = cities.where((x) => x.ilAdi.toLowerCase().contains(text.toLowerCase())).toList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadCityData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şehir Seçiniz'),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context, selectedCity);
          },
        ),
        actions: [
          selectedCity != null && widget.selectedCity == null || widget.selectedCity != null && selectedCity!.ilAdi != widget.selectedCity!.ilAdi
              ? TextButton(
                  onPressed: () {
                    Navigator.pop(context, selectedCity);
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
                fillColor: Theme.of(context).colorScheme.onPrimaryContainer,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Şehir ara',
              ),
              onChanged: (val) {
                searchCity(val);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: searched ? searchedCities.length : cities.length,
              itemBuilder: (context, index) {
                Il city = searched ? searchedCities[index] : cities[index];
                return Column(
                  children: [
                    ListTile(
                      onTap: () {
                        setState(() {
                          selectedCity = city;
                        });
                      },
                      leading: Text(city.plakaKodu),
                      title: Text(city.ilAdi),
                      trailing: selectedCity != null && city.ilAdi == selectedCity!.ilAdi ? const Icon(Icons.done) : null,
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
