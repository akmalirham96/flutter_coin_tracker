import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyHomePage();

}

class MyHomePage extends State<MyApp> {

  var list;
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    refreshListCoin();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COIN TRACKER',
      theme: ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(title : Text('COIN TRACKER')),
        body: Center(
          child: RefreshIndicator(
              key: refreshKey,
              child: FutureBuilder<List<CoinMarket>>(
                future: list,
                builder: (context,snapshot){
                  if(snapshot.hasData)
                    {
                      List<CoinMarket> coin = snapshot.data;

                      return ListView(
                        children: coin.map((coin)=> Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[

                            Row(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.only(left: 8.0,bottom: 8.0),
                                      child: Image.network('https://res.cloudinary.com/dxi90ksom/image/upload/${coin.symbol.toLowerCase()}.png'),
                                      width: 56.0,
                                      height: 56.0,

                                    )
                                  ],
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text('${coin.symbol} | ${coin.name}'),
                                    )
                                  ],
                                ),

                                Expanded(
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('\$${double.parse(coin.price_usd).toStringAsFixed(2)}'),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),


                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('1h:${coin.percent_change_1h}%',style: TextStyle(color: getColor(coin.percent_change_1h)),),
                                  Text('24h:${coin.percent_change_24h}%',style: TextStyle(color: getColor(coin.percent_change_24h)),),
                                  Text('7d:${coin.percent_change_7d}%',style: TextStyle(color: getColor(coin.percent_change_7d)),),
                                ],
                              ),
                            )

                          ],
                        )).toList(),
                      );


                    }
                    else if(snapshot.hasError){
                      Text('Error while loading coin list: ${snapshot.error}');
                  }

                  return new CircularProgressIndicator();
                },
              ),
              onRefresh: refreshListCoin),
        ),
      ),
    );
  }
  Future<Null> refreshListCoin() async{
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      list = fetchListCoin(); //asign data to list
    });

    return null;

  }
}

getColor(String percent) {
  if(percent.contains("-"))
    return hexToColor('#FF0000');
  else
    return hexToColor('#32CD32');
}

hexToColor(String color) {
  return new Color(int.parse(color.substring(1,7),radix: 16)+0xFF000000);
}






Future<List<CoinMarket>> fetchListCoin() async{
  final api_endpoint = await http.get('https://api.coinmarketcap.com/v1/ticker/');
  if(api_endpoint.statusCode == 200) //HTTP OK
    {
     List coins = json.decode(api_endpoint.body);
     return coins.map((coin)=> new CoinMarket.fromJson(coin)).toList();
  }
  else
    throw Exception('Failed to load coin list');
}

class CoinMarket {
  final String id;
  final String name;
  final String symbol;
  final String price_usd;
  final String percent_change_1h;
  final String percent_change_24h;
  final String percent_change_7d;


  CoinMarket({this.id, this.name, this.symbol, this.price_usd,
    this.percent_change_1h, this.percent_change_24h, this.percent_change_7d});

  factory CoinMarket.fromJson (Map<String,dynamic> json)
  {
    return CoinMarket(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      price_usd: json['price_usd'],
      percent_change_1h: json['percent_change_1h'],
      percent_change_24h: json['percent_change_24h'],
      percent_change_7d: json['percent_change_7d']
    );
  }

}