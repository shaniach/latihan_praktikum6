import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Universitas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => UniversityCubit(),
        child: UniversityList(),
      ),
    );
  }
}

class UniversityCubit extends Cubit<List<dynamic>> {
  UniversityCubit() : super([]);

  Future<void> fetchUniversitas(String country) async {
    final response = await http.get(
        Uri.parse('http://universities.hipolabs.com/search?country=$country'));
    if (response.statusCode == 200) {
      emit(json.decode(response.body));
    } else {
      throw Exception('Gagal menampilkan universitas');
    }
  }
}

class UniversityList extends StatefulWidget {
  @override
  _UniversityListState createState() => _UniversityListState();
}

class _UniversityListState extends State<UniversityList> {
  final List<String> countries = [
    'Indonesia',
    'Malaysia',
    'Singapore',
    'Thailand',
    'Vietnam',
    'Brunei Darussalam',
    'Myanmar',
  ];

  String selectedCountry =
      'Indonesia'; // Variabel untuk menyimpan negara yang dipilih

  @override
  Widget build(BuildContext context) {
    final universityCubit =
        BlocProvider.of<UniversityCubit>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Daftar Perguruan Tinggi - $selectedCountry'), // Menampilkan negara yang dipilih di judul
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: BlocBuilder<UniversityCubit, List<dynamic>>(
        builder: (context, state) {
          return Column(
            children: [
              _buildDropdownButton(universityCubit),
              Expanded(
                child: state.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        itemCount: state.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(
                          color: Colors.black,
                        ),
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Center(child: Text(state[index]['name'])),
                            subtitle: Center(
                                child: Text(state[index]['web_pages'][0])),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDropdownButton(UniversityCubit universityCubit) {
    return DropdownButton<String>(
      value: selectedCountry, // Menyesuaikan nilai dengan negara yang dipilih
      onChanged: (newValue) {
        setState(() {
          selectedCountry = newValue!; // Memperbarui nilai negara yang dipilih
        });
        universityCubit.fetchUniversitas(newValue!);
      },
      items: countries.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
