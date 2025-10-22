import 'package:flutter/material.dart';

class AlertDetailPage extends StatelessWidget {
  final Map<String, dynamic> alerta;

  const AlertDetailPage({super.key, required this.alerta});

  @override
  Widget build(BuildContext context) {
    Color nivelColor;
    IconData nivelIcon;

    switch (alerta['nivel']) {
      case 'Alto':
        nivelColor = Colors.redAccent;
        nivelIcon = Icons.error;
        break;
      case 'Medio':
        nivelColor = Colors.orangeAccent;
        nivelIcon = Icons.warning;
        break;
      case 'Bajo':
        nivelColor = Colors.yellowAccent;
        nivelIcon = Icons.info;
        break;
      default:
        nivelColor = Colors.white;
        nivelIcon = Icons.help;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Alerta #${alerta["id"].toString().substring(0, 8)}"),
        backgroundColor: const Color(0xFF12121D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(
            color: const Color(0xFF402A2A),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(nivelIcon, color: nivelColor),
                  const SizedBox(width: 10),
                  Text(alerta['nivel'],
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: nivelColor)),
                ]),
                const SizedBox(height: 15),
                Text(alerta['mensaje'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 15),
                _row('Fecha', alerta['fecha']),
                _row('Detalles', alerta['detalles']),
                if (alerta['resuelta'] == true)
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Row(children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 5),
                      Text('RESUELTA', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ]),
                  ),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Acciones:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Alerta marcada como resuelta')));
                Navigator.pop(context);
              },
              label: const Text('Marcar Resuelta'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.notifications_off),
              onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Alerta silenciada por 24 horas')));
                Navigator.pop(context);
              },
              label: const Text('Silenciar'),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white)),
      ]),
    );
  }
}
