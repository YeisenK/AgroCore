# AgroCore 🌱

AgroCore es una aplicación pensada para la gestión de viveros y sistemas agrícolas. La idea es tener en un solo lugar todo lo que un agricultor, ingeniero o técnico necesita: pedidos, siembras, ubicación de plantas y alertas con datos en tiempo real.

---

## Funcionalidades

- Pedidos → ver, crear y dar seguimiento.  
- Siembras → registrar y controlar cultivos.  
- Ubicación de plantas → saber dónde está cada lote.  
- Alertas → notificaciones basadas en sensores (humedad, temperatura, etc.).  
- Dashboards → diferentes vistas para clientes, ingenieros y agricultores.  
- Usuarios/Roles → control de accesos y permisos.  

---

## Tecnologías

- Flutter / Dart  
- Provider (estado)  
- fl_chart (gráficas)  
- GitHub para el control de versiones  
- Sensores IoT (ESP8266, LoRa, Arduino)  

---

## Estructura básica

agrocore/
│-- .gitignore
│-- agrocore.iml            
│-- pubspec.yaml            
│-- README.md               
│-- analysis_options.yaml   
│
├─ lib/                     ← código fuente Flutter
│   └─ ...                 
│
├─ assets/                  (si usas imágenes/fonts/json)
│   └─ ...
│
├─ test/                    (tests)
│   └─ ...
│
├─ android/                 ← proyecto Android
│   ├─ app/
│   │   └─ src/main/java/... 
│   └─ gradle/wrapper/...
│
├─ ios/                     ← proyecto iOS
│   └─ Runner/...
│
├─ macos/                   ← desktop macOS (si lo usas)
│   └─ Runner/...
│
├─ linux/                   ← desktop Linux (si lo usas)
│   └─ ...
│
└─ windows/                 ← desktop Windows (si lo usas)
    └─ runner/...


---

## Flujo de trabajo con Git

- main → rama principal estable  
- dev → integración de features  
- feature/... → cada módulo en su propia rama  

Reglas rápidas:
- Hacer PRs a dev, no directo a main.  
- Commits con prefijo: feat:, fix:, refactor:.  

---

## Instalación

git clone https://github.com/YeisenK/agrocore.git
cd agrocore
flutter pub get
flutter run

---

## Equipo

- Yeisen K. — PM y dashboards  
- Eduardo — Pedidos  
- René — Ubicación y alertas  
- Sebas — Siembras  

---

## Roadmap

- [ ] Integrar sensores reales  
- [ ] Notificaciones push  
- [ ] Reportes en PDF/Excel  
- [ ] Conexión con Odoo  
- [ ] IA para predicciones  
