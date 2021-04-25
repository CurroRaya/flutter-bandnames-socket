import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:pie_chart/pie_chart.dart';

import 'package:bandnamesapp/services/socket_service.dart';

import 'package:bandnamesapp/models/band.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [];

  @override
  void initState() {
    
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  _handleActiveBands( dynamic payload ){
    this.bands = (payload as List)
      .map((band) => Band.fromMap(band))
      .toList();

    setState(() {});
  }

  @override
  void dispose() {
    
    final socketService = Provider.of<SocketService>(context);
    socketService.socket.off('active-bands');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online)
            ? Icon(Icons.check_circle, color: Colors.blue[300],) 
            : Icon(Icons.offline_bolt, color: Colors.red,),
          ),
        ],
      ),
      body: Column(
        children: [
          if(bands.length > 0)
            _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, i) 
                  => _bandTile(bands[i])
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNewBand();
        },
        child: Icon(Icons.add),
        elevation: 1,
      ),
   );
  }

  Widget _bandTile(Band band) {
    
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0,2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}', 
          style: TextStyle(fontSize: 20),
        ),
        onTap: (){
          socketService.socket.emit('vote-band', { 'id': band.id });
        },
      ),
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Borrar Band',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      onDismissed: (_){
        socketService.emit('delete-band', { 'id' : band.id });
      },
    );
  }

  addNewBand(){
    final textController = TextEditingController();

    if(Platform.isAndroid){
      showDialog(
        context: context, 
        builder: (_) {
          return AlertDialog(
            title: Text('Nueva banda:'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                child: Text('Add'),
                textColor: Colors.blue,
                elevation: 5,
                onPressed: () => addBandToList(textController.text)
              )
            ],
          );
        },
      );
      return;
    }

    showCupertinoDialog(
      context: context, 
      builder: (_){
        return CupertinoAlertDialog(
          title: Text('Nueva banda:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              onPressed: () => addBandToList(textController.text)
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Dismiss'),
              onPressed: () => Navigator.pop(context)
            )
          ],
        );
      }
    );
    
  }

  void addBandToList(String name){
    if(name.length > 1){
      //emitir evento: add-band
      //{name: nombreBanda}
      
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit('add-band', { 'name' : name });

      /* this.bands.add(Band(
        id: DateTime.now().toString(),
        name: name,
        votes: 0
      ));

      setState(() {}); */
    }

    Navigator.pop(context);
  }

  Widget _showGraph(){
    Map<String, double> dataMap = new Map();
    bands.forEach((band) { 
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    final List<Color> colorList = [
      Colors.blue[50],
      Colors.blue[200],
      Colors.pink[50],
      Colors.pink[200],
      Colors.yellow[50],
      Colors.yellow[200],
    ];

    return Container(
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 15,
          colorList: colorList,
          initialAngleInDegree: 0,
          legendOptions: LegendOptions(
            legendPosition: LegendPosition.right,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            decimalPlaces: 0,
          ),
      )
    ) ;
  }

}	