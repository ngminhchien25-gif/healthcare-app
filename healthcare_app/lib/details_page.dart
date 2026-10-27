import 'package:flutter/material.dart';
import 'package:trekbikes_app/bike.dart';
import 'package:trekbikes_app/bike_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class DetailPage extends StatefulWidget {
  final String _title;
  const DetailPage({super.key, required this._title});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Bike? _bike;
  List<Bike> _relation = [];
  int? id;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    id ??= ModalRoute.of(context)!.settings.arguments as int;
    _loadBike();
  }
  void _loadBike() async{
    var item = await BikeRepository.getBike(id!);
    var data = await BikeRepository.getBikesRelation(item.id, item.subCategoryId);
    setState((){
      _bike = item;
      _relation = data;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_bike != null) ...[
              Image.network(
                '${dotenv.env['API_URL']}/bikes/${_bike!.imageUrl}',
                width: 512,
              ), 
              Text(_bike!.name),
              Table(
                children: [
                  TableRow(
                    children: [
                      TableCell(child: Text("Price")),
                      TableCell(child: Text(_bike!.price.toString())),
                    ],
                  ), 
                  if (_bike!.fork != null)
                    TableRow(
                      children: [
                        TableCell(child: Text("Fork")),
                        TableCell(child: Text(_bike!.fork!)),
                      ],
                    ), 
                  if (_bike!.brakes != null)
                    TableRow(
                      children: [
                        TableCell(child: Text("Brakes")),
                        TableCell(child: Text(_bike!.brakes!)),
                      ],
                    ),
                  if (_bike!.wheels != null)
                    TableRow(
                      children: [
                        TableCell(child: Text("Wheels")),
                        TableCell(child: Text(_bike!.wheels!)),
                      ],
                    ),
                  if (_bike!.frame != null)
                    TableRow(
                      children: [
                        TableCell(child: Text("Frame")),
                        TableCell(child: Text(_bike!.frame!)),
                      ],
                    ),
                  if (_bike!.weight != null)
                    TableRow(
                      children: [
                        TableCell(child: Text("Weight")),
                        TableCell(child: Text(_bike!.weight!)),
                      ],
                    ), 
                  if (_bike!.drivetrain != null)
                    TableRow(
                      children: [
                        TableCell(child: Text("Drivetrain")),
                        TableCell(child: Text(_bike!.drivetrain!)),
                      ],
                    ),
                  if (_bike!.rearShock != null)
                    TableRow(
                      children: [
                        TableCell(child: Text("Rear Shock")),
                        TableCell(child: Text(_bike!.rearShock!)),
                      ],
                    ), 
                  if (_bike!.tires != null)
                    TableRow(
                      children: [
                        TableCell(child: Text("Tires")),
                        TableCell(child: Text(_bike!.tires!)),
                      ],
                    ), 
                ],
              ),
            ],
            if (_relation.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _relation.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ), 
                itemBuilder: (context, index) {
                  Bike item = _relation[index];
                  return Column(
                    children: [
                      Image.network(
                        '${dotenv.env['API_URL']}/bikes/${item.imageUrl}',
                        width: 128,
                      ), 
                      Text(item.name),
                      Text('Price: ${item.price}'),
                      ElevatedButton.icon(
                        onPressed: () => _details(item.id),
                        label: Text('Details'),
                      ),
                    ],
                  );
                },
              ),
          ],
        ), 
      ), 
    );
  }

  void _details(int id) {
    Navigator.pushNamed(context, '/details', arguments: id);
  }
}