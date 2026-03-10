//import 'package:flutter/material.dart';

void main(){

  String dia = "Domingo";
  var mensaje = switch(dia){
    'Sabado' || 'Domingo' => 'Fin de samana',
    _ => 'Dia laboral'
  };

  print (mensaje);
}
