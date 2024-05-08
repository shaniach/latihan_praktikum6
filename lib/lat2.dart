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
        create: (context) => UniversityBloc(),
        child: UniversityList(),
      ),
    );
  }
}

abstract class UniversityEvent {}

class FetchUniversities extends UniversityEvent {
  final String country;

  FetchUniversities(this.country);
}

class UniversityState {
  final List<dynamic> universities;

  UniversityState(this.universities);
}

class UniversityBloc extends Bloc<UniversityEvent, UniversityState> {
  UniversityBloc() : super(UniversityState([]));

  @override
  // ignore: override_on_non_overriding_member
  Stream<UniversityState> mapEventToState(UniversityEvent event) async* {
    if (event is FetchUniversities) {
      try {
        final response = await http.get(Uri.parse(
            'http://universities.hipolabs.com/search?country=${event.country}'));
        if (response.statusCode == 200) {
          final universities = json.decode(response.body);
          yield UniversityState(universities);
        } else {
          throw Exception('Gagal menampilkan universitas');
        }
      } catch (e) {
        throw Exception('Gagal menampilkan universitas');
      }
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

  String selectedCountry = 'Indonesia';

  @override
  Widget build(BuildContext context) {
    final universityBloc = BlocProvider.of<UniversityBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Perguruan Tinggi - $selectedCountry'),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: BlocBuilder<UniversityBloc, UniversityState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildDropdownButton(universityBloc),
              Expanded(
                child: state.universities.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        itemCount: state.universities.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(
                          color: Colors.black,
                        ),
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Center(
                                child: Text(state.universities[index]['name'])),
                            subtitle: Center(
                                child: Text(
                                    state.universities[index]['web_pages'][0])),
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

  Widget _buildDropdownButton(UniversityBloc universityBloc) {
    return DropdownButton<String>(
      value: selectedCountry,
      onChanged: (newValue) {
        setState(() {
          selectedCountry = newValue!;
        });
        universityBloc.add(FetchUniversities(newValue!));
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
