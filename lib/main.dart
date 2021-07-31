import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

void main() => runApp(new MaterialApp(
  debugShowCheckedModeBanner: false,
  home: myhome()//moneycalc(),
));

class myhome extends StatefulWidget {
  @override
  _myhomeState createState() => _myhomeState();
}

class _myhomeState extends State<myhome> {

  DateTime selectedDate;
  
  Future<void> _selectDate1(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: new DateTime(1970, 8),
        lastDate: new DateTime(2101)
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        print(selectedDate);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Slot finder"),centerTitle: true,),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(height: 120,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: MediaQuery.of(context).size.width*0.5,
                height: MediaQuery.of(context).size.height*0.05,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 1)
                ),
                child : selectedDate == null ?
                Center(child: Text("Select Slot Date")) :
                Center(child: Text("${DateFormat("dd-MM-yyyy").format(selectedDate)}"),),
              ),
              RaisedButton(
                onPressed: () => _selectDate1(context),
                child: Text('Select date'),
              ),
            ],
          ),
          GestureDetector(
              onTap: (){
                if(selectedDate!=null)
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> moneycalc(day: selectedDate,)));
                else{

                }
              },
              child: Container(
                  width: MediaQuery.of(context).size.width*0.5,
                  height: MediaQuery.of(context).size.height*0.1,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.redAccent
                  ),
                  child: Center(child: Text("Find Slots !!!",style: TextStyle(color: Colors.white,fontSize: 19)),)
              )
          ),
          SizedBox(height: 120,),
        ],
      ),
    );
  }
}


class moneycalc extends StatefulWidget {
  final DateTime day;

  const moneycalc({Key key, this.day}) : super(key: key);
  @override
  _moneycalcState createState() => _moneycalcState();
}

class _moneycalcState extends State<moneycalc> {
  List data=[];
  var date;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getfun(widget.day);
  }

  void getfun(day) async{
    //day=DateTime.now().add(const Duration(days: 1));
    date=DateFormat('dd-MM-yyyy').format(day);
    var q=["294","265","276"];
    for(int i=0;i<q.length;i++){
      var responce= await get("https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByDistrict?district_id=${q[i]}&date=${date}");
      var decoded = json.decode(responce.body);
      for(int i=0;i<decoded["sessions"].length;i++)
        setState(() {
          data.add(decoded["sessions"][i]);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Slots on ${date}"),centerTitle: true,),
      body: data.isEmpty ? Center(child: CircularProgressIndicator()) :  Center(
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context,index){
            return datarep(data[index]);
          },
        ),
      ),
    );
  }

  Widget datarep(slot){
    if(slot["min_age_limit"]==18 && slot["available_capacity_dose1"]!=0)
    {
      return Container(
      margin: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        color: Colors.lightBlueAccent,
      ),
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Name : ${slot["name"]}",style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold),),
          Text("Pin : ${slot["pincode"]},",style: TextStyle(fontSize: 18),),
          Text("Date : ${slot["date"]}",style: TextStyle(fontSize: 18),),
          Text("Vaccine : ${slot["vaccine"]}",style: TextStyle(fontSize: 18),),
          Text("Dose 1 : ${slot["available_capacity_dose1"]}",style: TextStyle(fontSize: 18),),
          Text("Dose 2 : ${slot["available_capacity_dose2"]}",style: TextStyle(fontSize: 18),),
          Text("Type : ${slot["fee_type"]}",style: TextStyle(fontSize: 18),),

        ],
      ),
    );
    }
    else
    return Container();
  }
}