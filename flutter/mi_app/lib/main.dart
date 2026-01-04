import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';        // MethodChannel + rootBundle
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'package:table_calendar/table_calendar.dart';
import 'package:uni_links/uni_links.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null); // ✅ inicializa el formato regional
  runApp(const CarlitosTravelApp()); // ✅ mantiene tu flujo original
}


/// Helper: normaliza nombres de ciudad/país para buscar assets
String _normalizeForAsset(String s) {
  var res = s.toLowerCase();
  final Map<String, String> map = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'à': 'a',
    'è': 'e',
    'ì': 'i',
    'ò': 'o',
    'ù': 'u',
    'ä': 'a',
    'ë': 'e',
    'ï': 'i',
    'ö': 'o',
    'ü': 'u',
    'ñ': 'n',
    'ç': 'c',
    ' ': '_',
    "'": '',
    '’': '',
    '.': '',
    ',': '',
  };
  map.forEach((k, v) {
    res = res.replaceAll(k, v);
  });
  // eliminar caracteres distintos a letras, números y guion bajo
  res = res.replaceAll(RegExp(r'[^a-z0-9_]'), '');
  return res;
}

class CarlitosTravelApp extends StatelessWidget {
  const CarlitosTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Carlitos Travel',
  routes: {
            '/visas': (context) => const VisaGridPage(),
'/': (context) => const HomePage(),
    '/visas_grid_new': (context) => const VisaGridPage(),
  
    '/visas2': (context) => const Visas2Page(),});}
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _aboutKey = GlobalKey();

  final List<String> _heroImages = const [
    'assets/images/hero/hero_1.JPEG',
    'assets/images/hero/hero_2.JPEG',
    'assets/images/hero/hero_3.JPEG',
    'assets/images/hero/hero_4.JPEG',
    'assets/images/hero/hero_5.JPEG',
    'assets/images/hero/hero_6.JPEG',
    'assets/images/hero/hero_7.JPEG',
    'assets/images/hero/hero_8.JPEG',
    'assets/images/hero/hero_9.JPEG',
  ];

  final List<_Destination> _destinations = const [
    _Destination(
      'Japon',
      'Cultura y tecnología',
      'assets/images/destinations/japon/tokio/tokio.jpg'),
    _Destination(
      'Tailandia',
      'Las Mejores Playas del mundo',
      'assets/images/destinations/tailandia/phuket/phuket.jpg'),
  ];

  late Future<List<String>> _tripImagesFuture;

  @override
  void initState() {
    super.initState();
    _tripImagesFuture = _loadTripImages();
  }

  Future<List<String>> _loadTripImages() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      final tripPaths = manifestMap.keys
          .where((path) => path.startsWith('assets/images/trips/'))
          .where(
            (path) =>
                path.endsWith('.jpg') ||
                path.endsWith('.png') ||
                path.endsWith('.jpeg'))
          .toList()
        ..sort();
      return tripPaths;
    } catch (e) {
      return [];
    }
  }

  void _scrollToAbout() {
    if (_aboutKey.currentContext != null) {
      Scrollable.ensureVisible(
        _aboutKey.currentContext!,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [

        
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(6.0),
                      child: _LogoImage())),
                  const SizedBox(height: 10),
                  const Text(
                    "Carlitos Travel",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
                ])),
            // Cotizaciones con submenú
            ExpansionTile(
              leading: const Icon(Icons.request_quote),
              title: const Text('Cotizaciones'),
              children: [
             
                ListTile(
                  leading: const Icon(Icons.flight),
                  title: const Text("Vuelos"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VuelosQuotePage()));
                  }),
                  ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text("Visas"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>  const Visas2Page()));
                  }),
                ListTile(
                  leading: const Icon(Icons.hotel),
                  title: const Text("Hoteles"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CotizacionCategoryPage(category: 'Hoteles')));
                  }),
                ListTile(
                  leading: const Icon(Icons.attractions),
                  title: const Text("Atracciones"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CotizacionCategoryPage(category: 'Atracciones')));
                  }),
                ListTile(
                  leading: const Icon(Icons.support_agent),
                  title: const Text("Asesorías"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AsesoriaFormPage()));
                  }),
              ]),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Sobre nosotros'),
              onTap: () {
                Navigator.pop(context);
                _scrollToAbout();
              }),
            ListTile(
              leading: const Icon(Icons.flight_takeoff),
              title: const Text('Nuestros viajes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NuestrosViajesPage()));
              }),
       ListTile(
  leading: const Icon(Icons.contact_mail),
  title: const Text('Contáctanos'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContactenosPage(),
      ),
    );
  },
),


          ])),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: false,
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openDrawer()),
            title: Row(
              children: const [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.transparent,
                  child: _LogoImage(small: true)),
                SizedBox(width: 8),
                Text('Carlitos Travel'),
              ]),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            ]),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _HeroCarousel(images: _heroImages))),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Destinos destacados',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AllDestinationsPage()));
                    },
                    child: const Text(
                      'Ver todos',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600))),
                ]))),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 210,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) =>
                    _DestinationCard(dest: _destinations[index]),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: _destinations.length))),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Mis viajes por el mundo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: FutureBuilder<List<String>>(
                future: _tripImagesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: CircularProgressIndicator()));
                  }
                  if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'No se pudieron cargar las fotos. Revisa tus assets.'));
                  }
                  final paths = snapshot.data ?? [];
                  if (paths.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Añade tus fotos a assets/images/trips/ y reinicia en modo debug.'));
                  }
                  return _TripsGrid(paths: paths);
                }))),
          SliverToBoxAdapter(
            key: _aboutKey,
            child: const AboutCarlosResponsiveSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.explore),
        label: const Text('Explora el mundo')));
  }
}

class _LogoImage extends StatelessWidget {
  final bool small;
  const _LogoImage({this.small = false});

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/logo/logo.jpg', height: small ? 22 : 40);
  }
}

// ---------------- NUEVAS PÁGINAS: AllDestinationsPage / DestinationBlogPage ----------------

class AllDestinationsPage extends StatelessWidget {
  const AllDestinationsPage({super.key});

  final List<_Destination> allDestinations = const [
    _Destination(
      'Japon',
      'Cultura y tecnología',
      'assets/images/destinations/japon/tokio/tokio.jpg'),
    _Destination(
      'Tailandia',
      'Las Mejores Playas del mundo',
      'assets/images/destinations/tailandia/phuket/phuket.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todos los Destinos')),
      body: ListView.builder(
        itemCount: allDestinations.length,
        itemBuilder: (context, index) {
          final dest = allDestinations[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CityDetailPage(city: dest.title)));
            },
            child: Card(
              margin: const EdgeInsets.all(12),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 180,
                    child: Image.asset(
                      dest.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.photo)))),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dest.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(dest.subtitle, style: TextStyle(color: Colors.grey[700])),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CityDetailPage(city: dest.title)));
                              },
                              child: const Text('Ver ciudad'))
                          ])
                      ]))
                ])));
        }));
  }
}

// ---------------- NUEVAS PÁGINAS YA EXISTENTES EN TU PROYECTO ----------------

class CotizacionCategoryPage extends StatelessWidget {
  final String category;
  const CotizacionCategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cotizaciones - $category')),
      body: Center(
        child: Text(
          'Página de cotizaciones para $category\nAquí puedes integrar formularios o flujos.',
          textAlign: TextAlign.center)));
  }
}

class NuestrosViajesPage extends StatelessWidget {
  const NuestrosViajesPage({super.key});

  /// Mapa de país -> {ciudades} con imagen destacada por ciudad.
  /// Ajusta la ruta de la imagen destacada según tus assets.
  Map<String, Map<String, String>> get countryCityFeatured => const {
        "España 🇪🇸": {
          "Barcelona": "assets/images/destinations/espana/barcelona/barcelona_01.jpg",
          "Madrid": "assets/images/destinations/espana/madrid/madrid_01.jpeg",
          "Toledo": "assets/images/destinations/espana/toledo/toledo_01.jpeg",
          "Segovia": "assets/images/destinations/espana/segovia/segovia_01.jpeg",
          "Pamplona": "assets/images/destinations/espana/pamplona/pamplona_01.jpeg",
          "San Sebastian": "assets/images/destinations/espana/san_sebastian/sanse_01.jpeg",
        },
        "Francia 🇫🇷": {
          "París": "assets/images/destinations/francia/paris/paris_01.jpeg",
        },
        "Grecia 🇬🇷": {
          "Santorini": "assets/images/destinations/grecia/santorini/santorini_01.jpeg",
        },
        "Belgica 🇧🇪": {
          "Brujas": "assets/images/destinations/belgica/brujas/brujas_01.jpeg",
        },
        "Países Bajos 🇳🇱": {
          "Ámsterdam": "assets/images/destinations/paises_bajos/amsterdam/amsterdam_01.jpeg",
        },
        "República Checa 🇨🇿": {
          "Praga": "assets/images/destinations/republica_checa/praga/praga_01.jpeg",
        },
        "Italia 🇮🇹": {
          "Roma": "assets/images/destinations/italia/roma/roma_01.jpeg",
          "Nápoles": "assets/images/destinations/italia/napoles/napoles_01.jpg",
          "Capri": "assets/images/destinations/italia/capri/capri_01.jpg",
          "Florencia": "assets/images/destinations/italia/florencia/florencia_01.jpg",
          "Pisa": "assets/images/destinations/italia/pisa/pisa_01.jpg",
          "Venecia": "assets/images/destinations/italia/venecia/venecia_01.jpg",
        },
        "Austria 🇦🇹": {"Viena": "assets/images/destinations/austria/viena/viena_01.jpeg"},
        "Reino Unido 🇬🇧": {"Londres": "assets/images/destinations/reino_unido/londres/londres_01.jpeg"},
        "Perú 🇵🇪": {"Cusco": "assets/images/destinations/peru/cusco/cusco_01.jpeg"},
        "Argentina 🇦🇷": {"Buenos Aires": "assets/images/destinations/argentina/buenos_aires/buenos_aires_01.jpeg"},
        "Chile 🇨🇱": {"Santiago de Chile": "assets/images/destinations/chile/santiago_de_chile/santiago_01.jpeg"},
        "México 🇲🇽": {"Cancún": "assets/images/destinations/mexico/cancun/cancun_01.jpeg"},
        "EEUU 🇺🇸": {
          "New York": "assets/images/destinations/EEUU/new_york/new_york_01.jpeg",
          "Miami": "assets/images/destinations/EEUU/miami/miami_01.jpeg",
          "Orlando": "assets/images/destinations/usa/orlando/orlando_01.jpg",
          "Las Vegas": "assets/images/destinations/usa/las_vegas/vegas_01.jpg",
          "Washington": "assets/images/destinations/usa/washington/wash_01.jpg",
        },
        "Panamá 🇵🇦": {"Ciudad de Panamá": "assets/images/destinations/panama/ciudad/cdp_01.jpg"},
        "Egipto 🇪🇬": {"El Cairo": "assets/images/destinations/egipto/el_cairo/cairo_01.jpg"},
        "China 🇨🇳": {
          "Chengdu": "assets/images/destinations/china/chengdu/chengdu_01.jpg",
          "Chongqing": "assets/images/destinations/china/chongqing/chongqing_01.jpg",
          "Shanghái": "assets/images/destinations/china/shanghai/shanghai_01.jpg",
        },
        "Japón 🇯🇵": {
          "Tokio": "assets/images/destinations/japon/tokio/tokio.jpg",
          "Yokohama": "assets/images/destinations/japon/yokohama/yokohama_01.jpg",
          "Fukuoka": "assets/images/destinations/japon/fukuoka/fukuoka_01.jpg",
          "Hiroshima": "assets/images/destinations/japon/hiroshima/hiroshima_01.jpg",
          "Kioto": "assets/images/destinations/japon/kioto/kioto_01.jpg",
          "Osaka": "assets/images/destinations/japon/osaka/osaka_01.jpg",
          "Nara": "assets/images/destinations/japon/nara/nara_01.jpg",
          "Okinawa": "assets/images/destinations/japon/okinawa/okinawa_01.jpg",
        },
        "Corea del Sur 🇰🇷": {"Seoul": "assets/images/destinations/corea del sur/seoul/seoul_01.jpeg"},
        "Singapur 🇸🇬": {"Singapur": "assets/images/destinations/singapur/sg/sg_01.jpg"},
        "Tailandia 🇹🇭": {
          "Phuket": "assets/images/destinations/tailandia/phuket/phuket.jpg",
          "Bangkok": "assets/images/destinations/tailandia/bangkok/bangkok_01.jpg",
          "Chiang Mai": "assets/images/destinations/tailandia/chiang_mai/chiangmai_01.jpg",
        },
        "Indonesia 🇮🇩": {"Bali": "assets/images/destinations/indonesia/bali/bali_01.jpg"},
        "Emiratos Árabes Unidos 🇦🇪": {"Dubái": "assets/images/destinations/eua/dubai/dubai_01.jpeg"},
        "Portugal 🇵🇹": {"Lisboa": "assets/images/destinations/portugal/lisboa/lisboa_01.jpeg"},
        "Hungría 🇭🇺": {"Budapest": "assets/images/destinations/hungria/budapest/budapest_01.jpeg"},
      };


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuestros Viajes")),
      body: ListView(
        children: countryCityFeatured.entries.map((entry) {
          final country = entry.key;
          final cities = entry.value;
          return ExpansionTile(
            title: Text(
              country,
              style: const TextStyle(fontWeight: FontWeight.bold)),
            children: cities.entries.map((cityEntry) {
              final cityName = cityEntry.key;
              final featuredPath = cityEntry.value;
              return ListTile(
                leading: Image.asset(
                  featuredPath,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.photo)),
                title: Text(cityName),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CityDetailPage(
                        city: cityName,
                        featuredImage: featuredPath)));
                });
            }).toList());
        }).toList()));
  }
}

// ------------------ CITY DETAIL (ENHANCED) ------------------
// - Imágenes completas (BoxFit.contain) en visor principal
// - Tocar miniaturas abre galería interactiva de pantalla completa (PhotoView)

class CityDetailPage extends StatefulWidget {
  final String city;
  final String? featuredImage;
  const CityDetailPage({super.key, required this.city, this.featuredImage});

  @override
  State<CityDetailPage> createState() => _CityDetailPageState();
}

class _CityDetailPageState extends State<CityDetailPage> {
  late Future<List<String>> _imagesFuture;

  final Map<String, String> _cityDescriptions = {
  'amsterdam': '''
Ámsterdam — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
Desde su origen como un modesto pueblo pesquero en el siglo XII, Ámsterdam creció alrededor de canales estratégicos que conectaban comercio y cultura. Su Edad de Oro en el siglo XVII la convirtió en epicentro de arte, comercio y tolerancia.

• Dónde late  
Recorre el Jordaan y De Negen Straatjes, donde cafés y boutiques conviven con la historia de sus canales.

• Hitos  
Museos de renombre mundial, casas flotantes y eventos como el Día del Rey definen su espíritu vibrante.

• Identidad cultural  
Arquitectura típica de casas altas y estrechas, bicicletas por doquier, mercados de flores y cafés que conservan la esencia local.

Top 10 actividades
1. Paseo por los canales — 90–120 min. Mejor temprano. Tip: free tour.
2. Museo Van Gogh — Reserva con antelación.
3. Barrio Jordaan — Explora galerías y cafés.
4. Casa de Ana Frank — Entrada anticipada obligatoria.
5. Vondelpark — Picnic y paseo en bici.
6. Mercado de Albert Cuyp — Degusta street food local.
7. Negen Straatjes — Compras y boutiques artesanales.
8. Crucero nocturno por canales — Vistas iluminadas.
9. Excursión a Zaanse Schans — Molinos y tradición a 20 min.
10. Stroopwafel + queso local — Cierra con sabor auténtico.
''',
'bali': '''
Bali — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
Desde antiguos reinos balineses hasta influencia colonial, Bali se ha forjado entre templos, arrozales y comercio marítimo, manteniendo su espiritualidad intacta.

• Dónde late  
Ubud, Canggu y Seminyak son el corazón cultural y creativo de la isla, entre galerías, cafés y surf.

• Hitos  
Templos sobre acantilados, campos de arroz y festivales como Galungan y Nyepi marcan la tradición y la modernidad.

• Identidad cultural  
Rituales, danzas y gastronomía local —babi guling y sate lilit— conviven con mercados vibrantes y playas paradisíacas.

Top 10 actividades
1. Templo de Uluwatu — Atardecer y danza kecak.
2. Campos de arroz de Tegalalang — Paseo fotográfico.
3. Monkey Forest en Ubud — Naturaleza y cultura.
4. Surf en Canggu — Lecciones o alquiler de tabla.
5. Cascadas de Sekumpul — Excursión de día completo.
6. Mercados artesanales de Ubud — Artesanía y souvenirs.
7. Templo Tanah Lot — Fotografía icónica al atardecer.
8. Jardines de flores en Bali Botanic Garden — Picnic y relajación.
9. Clase de cocina balinesa — Aprende platos locales.
10. Relajación en spa tradicional — Masaje con aceite de coco.
''',
'bangkok': '''
Bangkok — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
Desde pequeña aldea ribereña del río Chao Phraya a capital próspera de Siam, Bangkok ha mezclado templos dorados con comercio global desde el siglo XVIII.

• Dónde late  
Templos como Wat Pho y Wat Arun, mercados flotantes y rooftops con vistas al río son su alma.

• Hitos  
Festivales como Songkran y Loy Krathong llenan de color la ciudad, mientras rascacielos y tuk-tuks definen su skyline.

• Identidad cultural  
La gastronomía callejera es legendaria, la vida nocturna intensa y la hospitalidad tailandesa palpita en cada esquina.

Top 10 actividades
1. Gran Palacio y Wat Phra Kaew — Historia y arquitectura impresionante.
2. Templo Wat Pho — Reclinado gigante y masaje tradicional.
3. Mercado flotante Damnoen Saduak — Experiencia auténtica.
4. Khao San Road — Vida nocturna y street food.
5. Chinatown (Yaowarat) — Sabores y cultura.
6. Asiatique The Riverfront — Compras y entretenimiento.
7. Rooftop bar en Sukhumvit — Vistas panorámicas.
8. Crucero nocturno por el río Chao Phraya — Magia urbana.
9. Museo Jim Thompson — Arte y arquitectura tailandesa.
10. Clase de cocina tailandesa — Aprende currys y pad thai.
''',
'barcelona': '''
Barcelona — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
Desde asentamientos romanos hasta ciudad modernista, Barcelona se ha forjado entre mar y montaña, combinando historia y creatividad.

• Dónde late  
Barrio Gótico, El Born y la Rambla laten con cafés, tiendas y arte callejero.

• Hitos  
Obras de Gaudí, festivales como La Mercè y eventos deportivos definen su identidad.

• Identidad cultural  
Tapas, vermut y mercados locales conviven con arquitectura modernista y playas mediterráneas.

Top 10 actividades
1. Sagrada Familia — Reserva online.
2. Parc Güell — Colores y vistas.
3. Barrio Gótico — Calles históricas y plazas.
4. La Rambla — Paseo y artistas callejeros.
5. Mercado de la Boquería — Gastronomía local.
6. Montjuïc — Jardines y vistas panorámicas.
7. Museo Picasso — Arte y cultura.
8. Playas de la Barceloneta — Relax y sol.
9. Bares de tapas en El Born — Tapas auténticas.
10. Excursión a Montserrat — Naturaleza y monasterio.
''',
'brujas': '''
Brujas — esencia local en pocas horas: rincones fotogénicos, sabores auténticos y paseos relajados.

• Orígenes  
Fundada en la Edad Media, Brujas creció como ciudad mercante y portuaria, conservando su casco antiguo intacto.

• Identidad  
Callejones empedrados, canales y arquitectura gótica se combinan con chocolaterías y cervezas locales.

Plan exprés
1) Paseo por el centro histórico (60–90 min)
2) Mirador de Belfort para vistas panorámicas
3) Mercado de Grote Markt para picar algo
4) Barrio de Begijnhof — tranquilo y fotogénico
5) Degustación de chocolate y cerveza belga
''',
'budapest': '''
Budapest — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
Formada por la unión de Buda y Pest en el siglo XIX, Budapest combina siglos de historia entre castillos, baños termales y puentes emblemáticos.

• Dónde late  
Baños termales, Puente de las Cadenas y bares en ruinas definen la esencia local.

• Hitos  
Festivales de música, cine y arte se suman a su impresionante arquitectura.

• Identidad cultural  
Cafés históricos, gastronomía húngara y vida nocturna en ruinas de bares crean un ambiente único.

Top 10 actividades
1. Castillo de Buda — Historia y vistas.
2. Baños Széchenyi — Relax termal.
3. Parlamento de Hungría — Icono arquitectónico.
4. Puente de las Cadenas — Fotografía panorámica.
5. Bares en ruinas — Experiencia nocturna.
6. Mercado Central — Productos locales.
7. Iglesia de Matías — Arte gótico.
8. Basílica de San Esteban — Historia y arquitectura.
9. Crucero por el Danubio — Vistas nocturnas.
10. Pastel lángos + dulce local — Sabor auténtico.
''',
'buenos_aires': '''
Buenos Aires — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
De puerto colonial a capital cosmopolita, Buenos Aires mezcla influencias españolas, italianas y europeas desde el siglo XVI.

• Dónde late  
San Telmo, Palermo y Recoleta concentran vida cultural, cafés y mercados.

• Hitos  
Teatros, tango y ferias callejeras como San Telmo y Mataderos marcan su carácter.

• Identidad cultural  
Tango, parrillas, cafés históricos y mercados locales reflejan un estilo de vida vibrante y apasionado.

Top 10 actividades
1. Caminito en La Boca — Arte y color.
2. Plaza de Mayo y Casa Rosada — Historia argentina.
3. Teatro Colón — Icono cultural.
4. San Telmo — Antigüedades y tango.
5. Recoleta y Cementerio — Historia y arquitectura.
6. Palermo Soho — Arte y cafés modernos.
7. Puerto Madero — Paseo y gastronomía.
8. Milonga nocturna — Bailar tango auténtico.
9. Museo de Bellas Artes — Arte clásico y moderno.
10. Parrilla local + dulce tradicional — Experiencia culinaria.
''',
'cancun': '''
Cancún — esencia local en pocas horas: rincones fotogénicos, sabores auténticos y paseos relajados.

• Orígenes  
De pequeña villa pesquera a destino turístico internacional, Cancún combina playas caribeñas y cultura maya.

• Identidad  
Playas de arena blanca, mercados locales y vida nocturna con ritmos latinos.

Plan exprés
1) Paseo por la zona hotelera y playas (60–90 min)
2) Mirador del Parque de las Palapas
3) Mercado 28 para compras y gastronomía
4) Calle más pintoresca de la ciudad
5) Degustación de tacos y marquesitas
''',
'capri': '''
Capri — esencia local en pocas horas: rincones fotogénicos, sabores auténticos y paseos relajados.

• Orígenes  
Isla con historia romana y medieval, Capri ha sido refugio de artistas y aristócratas.

• Identidad  
Acantilados, villas y jardines se mezclan con cafés y tiendas exclusivas.

Plan exprés
1) Paseo por la Piazzetta (60–90 min)
2) Mirador de los Jardines de Augusto
3) Excursión a la Gruta Azul
4) Calle más pintoresca de Anacapri
5) Degustación de limoncello y pastelería local
''',
'chengdu': '''
Chengdu — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
Desde ciudad imperial a capital de Sichuan, Chengdu combina historia milenaria con gastronomía picante y cultura del té.

• Dónde late  
Pandas, mercados y el barrio antiguo de Jinli reflejan la vida local.

• Hitos  
Templos, teatros de ópera de Sichuan y festivales culturales llenan su skyline de tradición.

• Identidad cultural  
Hotpot picante, té y mercado callejero reflejan la hospitalidad de sus habitantes.

Top 10 actividades
1. Centro histórico a pie — Jinli y Wuhou Shrine.
2. Panda Base — Icono mundial.
3. Calle Kuanzhai Xiangzi — Arquitectura y cafés.
4. Mercado local de Sichuan — Street food y souvenirs.
5. Museo de Sichuan — Arte y cultura.
6. Templo Wuhou — Historia y rituales.
7. Parque People’s Park — Té y vida cotidiana.
8. Opera de Sichuan — Máscara cambiante.
9. Excursión cercana — Leshan Giant Buddha.
10. Hotpot tradicional + dulces locales — Cierra con sabor auténtico.
''',


'chiang_mai': '''
Chiang Mai — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
Fundada en 1296 como capital del Reino de Lanna, Chiang Mai conserva murallas y templos que narran siglos de historia y comercio en el norte de Tailandia.

• Dónde late  
Templos, cafés artesanales y mercados nocturnos crean el alma de la ciudad.

• Hitos  
Festivales como Yi Peng (linternas flotantes) y Songkran destacan la cultura local.

• Identidad cultural  
Artesanía, gastronomía del norte, yoga y vida relajada contrastan con el bullicio de sus mercados.

Top 10 actividades
1. Templo Doi Suthep — Vistas panorámicas.
2. Old City Walk — Murallas, templos y callejones.
3. Night Bazaar — Compras y street food.
4. Clase de cocina tailandesa — Experiencia práctica.
5. Templo Wat Chedi Luang — Historia y arquitectura.
6. Parque Doi Inthanon — Naturaleza y cascadas.
7. Café artesanal en Nimmanhaemin Road — Relax y estilo.
8. Elephant Nature Park — Voluntariado y experiencia ética.
9. Festival Yi Peng — Linternas y fotografía.
10. Plato khao soi + dulce local — Sabor auténtico.
''',
'chongqing': '''
Chongqing — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
Con raíces de más de 3.000 años, esta ciudad montañosa del suroeste de China ha sido un puerto clave en el Yangtsé y centro industrial y cultural.

• Dónde late  
Rascacielos sobre colinas, puentes y trenes que atraviesan edificios definen su skyline único.

• Hitos  
Templos antiguos, museos y festivales tradicionales resaltan la historia y resiliencia local.

• Identidad cultural  
Gastronomía picante, mercados bulliciosos y cultura del té crean una experiencia urbana intensa y auténtica.

Top 10 actividades
1. Centro histórico a pie — Ciqikou y Jiefangbei.
2. Mirador Hongya Cave — Fotografía y compras.
3. Crucero por el río Yangtsé — Skyline nocturno.
4. Museo de Chongqing — Historia y arte.
5. Baños termales en el área de Huaqiao — Relax urbano.
6. Puente Chaotianmen — Ingeniería y vistas.
7. Ruta gastronómica de hotpot — Picante auténtico.
8. Teleférico sobre el río — Experiencia urbana.
9. Excursión cercana a Dazu — Tallas budistas.
10. Dulces y snacks locales — Mercado callejero.
''',
'ciudad_de_panama': '''
Ciudad de Panamá — esencia local en pocas horas: rincones fotogénicos, sabores auténticos y paseos relajados.

• Orígenes  
Desde su fundación en 1519 como puerto colonial, la ciudad se convirtió en puerta de comercio entre océanos y culturas.

• Identidad  
Mezcla de rascacielos modernos y casco antiguo histórico, con gastronomía de fusión y vida de barrio.

Plan exprés
1) Paseo por Casco Viejo (60–90 min)
2) Mirador Cerro Ancón
3) Mercado de Mariscos — degustación fresca
4) Calle peatonal Santa Ana
5) Cafetería local + dulce típico
''',
'cusco': '''
Cusco — esencia local en pocas horas: rincones fotogénicos, sabores auténticos y paseos relajados.

• Orígenes  
Capital del Imperio Inca, Cusco mantiene su trazado original y arquitectura que combina piedra incaica con colonial española.

• Identidad  
Calles empedradas, plazas históricas, mercados artesanales y gastronomía andina se fusionan en cada esquina.

Plan exprés
1) Plaza de Armas y Catedral (60–90 min)
2) Barrio de San Blas
3) Mercado de San Pedro — productos locales
4) Callejones fotogénicos
5) Degustación de cuy y alfajores
''',
'dubai': '''
Dubái — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
De humilde pueblo pesquero a metrópolis global, Dubái ha crecido en el desierto gracias a comercio, petróleo y turismo.

• Dónde late  
Marina, Downtown y zocos muestran el lujo futurista fusionado con tradición árabe.

• Hitos  
Rascacielos, islas artificiales y eventos como el Dubai Shopping Festival marcan su modernidad.

• Identidad cultural  
Gastronomía internacional, mercados tradicionales y vida nocturna de lujo definen su estilo.

Top 10 actividades
1. Burj Khalifa — Observatorio y fotografía.
2. Dubai Mall — Compras y entretenimiento.
3. Dubai Fountain — Show nocturno.
4. Old Dubai & Gold Souk — Cultura y comercio.
5. Safari por el desierto — Aventura y cena típica.
6. Palm Jumeirah — Paseo y vistas.
7. Museo de Dubái — Historia y tradición.
8. Marina Walk — Paseo y cafés.
9. Skyline desde dhow cruise — Experiencia fotográfica.
10. Plato shawarma + dulce árabe — Sabor local.
''',
'el_cairo': '''
El Cairo — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
Desde asentamientos antiguos cerca del Nilo, El Cairo creció como epicentro de cultura, comercio y poder islámico y faraónico.

• Dónde late  
Pirámides de Giza, bazares tradicionales y callejones del histórico Khan el-Khalili.

• Hitos  
Museos, mezquitas y festivales de música y danza reflejan su riqueza cultural.

• Identidad cultural  
Gastronomía callejera, arquitectura monumental y la vida cotidiana en mercados y cafés locales.

Top 10 actividades
1. Pirámides de Giza y Esfinge — Historia milenaria.
2. Museo Egipcio — Tesoros faraónicos.
3. Khan el-Khalili — Compras y ambiente.
4. Calle Al-Muizz — Arquitectura islámica.
5. Citadel de Saladino — Vistas y mezquita.
6. Café tradicional egipcio — Té y narguile.
7. Crucero por el Nilo — Atardecer inolvidable.
8. Museo Copto — Historia cristiana en Egipto.
9. Excursión a Saqqara — Pirámides escalonadas.
10. Plato koshari + baklava — Sabor auténtico.
''',
'florencia': '''
Florencia — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
Cuna del Renacimiento, Florencia floreció gracias al comercio y mecenazgo de familias como los Medici.

• Dónde late  
Plazas, puentes y mercados conservan la esencia artística de la ciudad.

• Hitos  
Galerías de arte, catedrales y eventos culturales han dejado huella en su skyline renacentista.

• Identidad cultural  
Arte, gastronomía toscana y cafés históricos invitan a recorrer la ciudad a cada paso.

Top 10 actividades
1. Catedral de Santa María del Fiore — Arte y arquitectura.
2. Galería Uffizi — Obras maestras.
3. Ponte Vecchio — Fotografía y joyerías.
4. Mercado Central — Gastronomía local.
5. Palazzo Pitti y Jardines Boboli — Historia y paseo.
6. Plaza de la Signoria — Monumentos y ambiente.
7. Basilica di Santa Croce — Arte y cultura.
8. Excursión a Fiesole — Vista panorámica.
9. Cafés históricos en el centro — Relax y ambiente.
10. Plato ribollita + dulce cantucci — Cierra con sabor auténtico.
''',
'fukuoka': '''
Fukuoka — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
Puerto estratégico desde la antigüedad, Fukuoka creció como ciudad comercial y cultural en Kyushu.

• Dónde late  
Yatai de ramen, bahía y barrios creativos muestran su vida local.

• Hitos  
Castillo de Fukuoka, templos y festivales como Hakata Gion Yamakasa destacan su identidad.

• Identidad cultural  
Ramen callejero, festivales tradicionales y cultura pop japonesa hacen de la ciudad un punto vibrante del sur de Japón.

Top 10 actividades
1. Castillo de Fukuoka — Historia y vistas.
2. Hakata Machiya Folk Museum — Cultura local.
3. Yatai food stalls — Experiencia culinaria.
4. Templo Shofukuji — Tranquilidad y tradición.
5. Parque Ohori — Relax y paseo.
6. Canal City Hakata — Compras y entretenimiento.
7. Festival Hakata Gion Yamakasa — Color y tradición.
8. Excursión a Nokonoshima Island — Naturaleza.
9. Ruta gastronómica ramen — Prueba especialidades.
10. Dulces y mochis locales — Cierra con sabor auténtico.
''',
'hiroshima': '''
Hiroshima — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
Desde ciudad feudal hasta epicentro de memoria mundial, Hiroshima combina resiliencia con cultura contemporánea.

• Dónde late  
Parques ribereños, museos de paz y la isla de Miyajima muestran su identidad.

• Hitos  
Museo de la Paz, Cúpula de la Bomba Atómica y festivales locales narran la historia y esperanza.

• Identidad cultural  
Gastronomía local —okonomiyaki y ostras—, templos y vida cotidiana reflejan una ciudad que renace.

Top 10 actividades
1. Parque Conmemorativo de la Paz — Historia y reflexión.
2. Museo de la Paz — Exhibiciones conmovedoras.
3. Cúpula de la Bomba Atómica — Símbolo mundial.
4. Isla Miyajima y Torii flotante — Icono fotográfico.
5. Castillo de Hiroshima — Historia samurái.
6. Okonomimura — Okonomiyaki local.
7. Shukkeien Garden — Jardines tradicionales.
8. Templo Mitaki-dera — Tranquilidad y naturaleza.
9. Excursión en ferry a Itsukushima — Vista panorámica.
10. Dulces y sake locales — Sabor auténtico.
''',
'kioto': '''
Kioto — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
Capital imperial durante más de mil años, Kioto conserva templos, santuarios y jardines zen de tradición milenaria.

• Dónde late  
Gion, callejones tradicionales y mercados artesanales concentran cultura y gastronomía.

• Hitos  
Templos Kinkaku-ji y Fushimi Inari, festivales y arquitectura tradicional definen su skyline histórico.

• Identidad cultural  
Ceremonias de té, kaiseki y artesanía conviven con vida callejera y cultura pop japonesa.

Top 10 actividades
1. Templo Kinkaku-ji (Pabellón Dorado) — Fotografía icónica.
2. Fushimi Inari Taisha — Paseo por torii.
3. Barrio Gion — Geishas y callejones.
4. Mercado Nishiki — Gastronomía local.
5. Templo Kiyomizu-dera — Vistas panorámicas.
6. Castillo Nijo — Historia samurái.
7. Jardín Shoren-in — Paz y naturaleza.
8. Excursión a Arashiyama — Bosque de bambú.
9. Clase de cocina kaiseki — Experiencia culinaria.
10. Dulces y matcha tradicionales — Sabor auténtico.
''',
'las_vegas': '''
Las Vegas — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
De oasis en el desierto a capital del entretenimiento mundial, Las Vegas creció gracias al ferrocarril y al juego legalizado a mediados del siglo XX.

• Dónde late  
The Strip, Fremont Street y resorts temáticos son el corazón de su espectáculo urbano.

• Hitos  
Hoteles icónicos, casinos, espectáculos y festivales definen su skyline luminoso.

• Identidad cultural  
Entre neon, gastronomía gourmet, conciertos y shows de primer nivel, la ciudad nunca duerme.

Top 10 actividades
1. Paseo por The Strip — Casinos y arquitectura temática.
2. Fremont Street Experience — Show de luces y música.
3. Espectáculo de Cirque du Soleil — Reserva anticipada.
4. High Roller Observation Wheel — Vistas panorámicas.
5. Bellagio Fountains — Show gratuito icónico.
6. Neon Museum — Historia de letreros luminosos.
7. Excursión al Red Rock Canyon — Naturaleza cerca del desierto.
8. Compras en Forum Shops o Fashion Show Mall — Moda y lujo.
9. Bares y clubs en The Strip — Vida nocturna intensa.
10. Buffet típico + postre local — Cierra con sabor auténtico.
''',
'lisboa': '''
Lisboa — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
Desde asentamientos fenicios y romanos hasta capital del descubrimiento marítimo, Lisboa creció sobre colinas frente al Atlántico.

• Dónde late  
Alfama, Bairro Alto y Baixa concentran vida cultural, miradores y tranvías históricos.

• Hitos  
Torre de Belém, Monasterio de los Jerónimos y festivales como Festas de Lisboa destacan en su skyline.

• Identidad cultural  
Fado, pasteles de nata, arquitectura azulejada y cafés tradicionales definen la esencia lisboeta.

Top 10 actividades
1. Torre de Belém — Fotografía y paseo histórico.
2. Monasterio de los Jerónimos — Patrimonio cultural.
3. Barrio de Alfama — Calles empedradas y fado.
4. Tranvía 28 — Recorrido panorámico.
5. Mirador de Santa Luzia — Vista al casco antiguo.
6. Mercado da Ribeira (Time Out Market) — Gastronomía y ambiente.
7. Castillo de San Jorge — Historia y panorámicas.
8. Bairro Alto — Vida nocturna y bares.
9. Excursión a Sintra — Palacios y naturaleza.
10. Plato bacalhau + dulce pastel de nata — Experiencia culinaria.
''',
'londres': '''
Londres — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
De asentamiento romano a capital mundial, Londres ha tejido siglos de historia política, cultural y artística.

• Dónde late  
Museos gratuitos, parques reales y mercados de barrio son su pulso cotidiano.

• Hitos  
Big Ben, Tower Bridge y eventos como el Notting Hill Carnival definen su skyline.

• Identidad cultural  
Teatros, pubs históricos, gastronomía multicultural y mercados callejeros crean un Londres vibrante.

Top 10 actividades
1. Tour por Westminster y Big Ben — Historia política.
2. British Museum — Arte y antigüedades.
3. Tower of London — Corona y leyendas.
4. Camden Market — Compras y street food.
5. Covent Garden — Arte callejero y tiendas.
6. Paseo por South Bank — Río Támesis y vistas.
7. Hyde Park — Picnic y relajación.
8. London Eye — Panorama urbano.
9. Espectáculo en West End — Teatro y música.
10. Fish & chips + té tradicional — Sabor londinense.
''',
'madrid': '''
Madrid — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
De asentamiento árabe a capital moderna, Madrid creció entre palacios, mercados y plazas, fusionando tradición y modernidad.

• Dónde late  
Entre el Triángulo del Arte, La Latina y el Retiro se concentra vida cultural, gastronómica y nocturna.

• Hitos  
Museos, festivales y arquitectura emblemática marcan su skyline.

• Identidad cultural  
Tapas, vermut, tertulias en cafés históricos y vida nocturna activa definen la esencia madrileña.

Top 10 actividades
1. Museo del Prado — Arte clásico y renacentista.
2. Parque del Retiro — Paseo y relax.
3. Barrio de La Latina — Tapas y ambiente.
4. Plaza Mayor — Historia y fotografía.
5. Palacio Real — Arquitectura y cultura.
6. Mercado de San Miguel — Gastronomía local.
7. Gran Vía — Compras y teatros.
8. Templo de Debod — Atardecer fotográfico.
9. Barrio de Malasaña — Arte urbano y vida nocturna.
10. Cocido madrileño + dulce local — Sabor auténtico.
''',
'miami': '''
Miami — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
De asentamiento costero a ciudad internacional, Miami creció gracias a inmigración, comercio y turismo.

• Dónde late  
Art Deco en South Beach, barrios latinos y vibrante vida en Wynwood y Little Havana.

• Hitos  
Playas, festivales de música y diseño y eventos deportivos destacan en su skyline moderno.

• Identidad cultural  
Gastronomía latina, arte urbano y vida nocturna hacen de Miami un lugar cosmopolita y creativo.

Top 10 actividades
1. Recorrido Art Deco en South Beach — Historia y arquitectura.
2. Wynwood Walls — Arte callejero y fotografía.
3. Little Havana — Cultura cubana y cafés.
4. Miami Beach Boardwalk — Paseo junto al mar.
5. Vizcaya Museum & Gardens — Historia y jardines.
6. Parque Bayfront — Relax y eventos.
7. Crucero por Biscayne Bay — Vistas urbanas y naturaleza.
8. Museo PAMM — Arte moderno.
9. Excursión a Key Biscayne — Playas y naturaleza.
10. Ceviche + pastelitos cubanos — Sabor auténtico.
''',
'napoles': '''
Nápoles — esencia local en pocas horas: rincones fotogénicos, sabores auténticos y paseos relajados.

• Orígenes  
Fundada por griegos y romanos, Nápoles se convirtió en puerto vital del sur de Italia y puerta a historia y gastronomía.

• Identidad  
Calles estrechas, mercados y pizzerías tradicionales conviven con vistas al Vesubio y al golfo.

Plan exprés
1) Paseo por Spaccanapoli (60–90 min)
2) Mirador de Castel Sant’Elmo
3) Mercado Pignasecca — street food
4) Barrio de Quartieri Spagnoli
5) Pizza napolitana + sfogliatella
''',
'nara': '''
Nara — esencia local en pocas horas: rincones fotogénicos, sabores auténticos y paseos relajados.

• Orígenes  
Capital del Japón antiguo en el siglo VIII, Nara conserva templos y parques que narran su historia imperial.

• Identidad  
Templos, ciervos libres y callejones tradicionales hacen de Nara un lugar tranquilo y fotogénico.

Plan exprés
1) Paseo por Todai-ji y Parque de Nara (60–90 min)
2) Kasuga Taisha — Templo emblemático
3) Calle principal Naramachi — Artesanía y cafés
4) Callejones tradicionales
5) Dulces locales y mochi
''',
'new_york': '''
New York — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
De colonia holandesa a metrópolis global, Nueva York creció como epicentro de comercio, inmigración y cultura.

• Dónde late  
Manhattan y Brooklyn concentran skyline, arte, gastronomía y vida urbana.

• Hitos  
Times Square, Statue of Liberty y museos icónicos definen su carácter.

• Identidad cultural  
Gastronomía internacional, vida nocturna, Broadway y mercados urbanos crean una ciudad inagotable.

Top 10 actividades
1. Central Park — Paseo y relax.
2. Empire State Building — Vistas panorámicas.
3. Times Square — Luces y energía.
4. Museo Metropolitano — Arte global.
5. Brooklyn Bridge — Fotografía y paseo.
6. High Line — Parque elevado y arte urbano.
7. Museo de Historia Natural — Exhibiciones icónicas.
8. Broadway Show — Teatro y música.
9. Excursión a Staten Island Ferry — Estatua de la Libertad.
10. Bagel + cheesecake local — Sabor auténtico.
''',
'okinawa': '''
Okinawa — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
Desde reino Ryukyu hasta prefectura japonesa, Okinawa creció entre comercio, cultura y playas paradisíacas.

• Dónde late  
Playas turquesa, cultura Ryukyu, mercados y festivales isleños definen su ritmo.

• Hitos  
Castillos históricos, museos de la guerra y parques costeros reflejan su historia y resiliencia.

• Identidad cultural  
Gastronomía local, música tradicional y vida isleña relajada crean un ambiente único.

Top 10 actividades
1. Castillo Shuri — Historia Ryukyu.
2. Aquarium Churaumi — Vida marina.
3. Playas de Tokashiki — Snorkel y relax.
4. Mercado Makishi — Gastronomía local.
5. Museo de la Paz — Historia y memoria.
6. Ruta de la cerveza local — Degustación.
7. Templo Okinawa — Tradición y arquitectura.
8. Festival Eisa — Música y danza.
9. Excursión a Kerama Islands — Naturaleza y snorkel.
10. Soba okinawense + dulce local — Sabor auténtico.
''',
'orlando': '''
Orlando — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
De villa rural a centro mundial de parques temáticos y entretenimiento, Orlando creció gracias al turismo y la innovación.

• Dónde late  
Parques temáticos, centros comerciales y lagos urbanos concentran su energía.

• Hitos  
Disney, Universal y eventos internacionales definen su skyline y atractivo turístico.

• Identidad cultural  
Vida familiar, entretenimiento, gastronomía y compras hacen de Orlando un destino completo.

Top 10 actividades
1. Magic Kingdom (Disney) — Diversión familiar.
2. Universal Studios — Experiencia temática.
3. Epcot — Cultura y gastronomía global.
4. Parque Lake Eola — Paseo urbano.
5. ICON Park y Wheel — Vistas y entretenimiento.
6. Disney Springs — Compras y gastronomía.
7. Parque temático Island of Adventure — Aventuras intensas.
8. Excursión a Kennedy Space Center — Ciencia y historia.
9. Downtown Orlando — Arte, cafés y cultura.
10. Plato local + snack temático — Cierra con sabor auténtico.
''',
'osaka': '''
Osaka — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
De fortaleza samurái a ciudad comercial, Osaka ha sido el corazón económico de Japón, conectando historia y modernidad.

• Dónde late  
Dotonbori, castillo y food scene callejera concentran cultura urbana y gastronomía vibrante.

• Hitos  
Castillo de Osaka, templos históricos y festivales locales definen su skyline dinámico.

• Identidad cultural  
Ramen callejero, takoyaki y festivales tradicionales conviven con tecnología y vida nocturna.

Top 10 actividades
1. Castillo de Osaka — Historia y jardines.
2. Dotonbori — Street food y luces de neón.
3. Shinsaibashi — Compras y boutiques.
4. Templo Shitennoji — Arquitectura y espiritualidad.
5. Umeda Sky Building — Vistas panorámicas.
6. Mercado Kuromon Ichiba — Productos frescos.
7. Universal Studios Japan — Diversión temática.
8. Namba Parks — Compras y arquitectura.
9. Excursión a Nara o Kobe — Historia y gastronomía cercana.
10. Takoyaki + dulce local — Sabor auténtico.
''',
'pamplona': '''
Pamplona — esencia local en pocas horas: rincones fotogénicos, sabores auténticos y paseos relajados.

• Orígenes  
De asentamiento medieval a ciudad famosa por los encierros de San Fermín, Pamplona mantiene su casco histórico intacto.

• Identidad  
Calles empedradas, plazas y mercados tradicionales reflejan su cultura local.

Plan exprés
1) Paseo por el centro histórico (60–90 min)
2) Mirador del Parque de la Ciudadela
3) Mercado de Santo Domingo — productos locales
4) Calle más pintoresca de la ciudad
5) Pintxo y dulce navarro típico
''',
'paris': '''
París — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
De asentamiento romano a capital mundial de la cultura y el arte, París ha marcado la historia de Europa con su estilo único.

• Dónde late  
A orillas del Sena, entre el Louvre, Montmartre y los bulevares de Haussmann se concentra la vida parisina.

• Hitos  
Torre Eiffel, Notre-Dame, Sacré-Cœur y festivales culturales definen su skyline romántico y moderno.

• Identidad cultural  
Cafés, gastronomía gourmet, museos y mercados callejeros crean la esencia parisina.

Top 10 actividades
1. Torre Eiffel — Vistas panorámicas.
2. Louvre — Arte y cultura.
3. Barrio de Montmartre — Calles pintorescas y artistas.
4. Notre-Dame — Historia y arquitectura.
5. Paseo por el Sena — Crucero romántico.
6. Jardines de Luxemburgo — Picnic y relax.
7. Le Marais — Compras y gastronomía.
8. Centre Pompidou — Arte moderno.
9. Excursión a Versalles — Palacio y jardines.
10. Croissant + macaron local — Sabor auténtico.
''',
'phuket': '''
Phuket — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
De puerto comercial a destino turístico internacional, Phuket combina playas paradisíacas y cultura tailandesa.

• Dónde late  
Patong, Phuket Town y playas secretas concentran vida local, gastronomía y ocio.

• Hitos  
Templos, miradores y festivales como Vegetarian Festival definen su skyline costero.

• Identidad cultural  
Playas, gastronomía callejera, mercados nocturnos y cultura isleña crean un ambiente vibrante.

Top 10 actividades
1. Patong Beach — Playa y deportes acuáticos.
2. Phuket Old Town — Arquitectura y cafés.
3. Gran Buda de Phuket — Vista panorámica.
4. Excursión a Phi Phi Islands — Naturaleza y snorkel.
5. Mercados nocturnos de Phuket — Comida y artesanía.
6. Templo Wat Chalong — Historia y tradición.
7. Mirador Karon — Fotografía y paisaje.
8. Clase de cocina tailandesa — Gastronomía práctica.
9. Spa y masajes locales — Relajación.
10. Plato local + dulce tailandés — Sabor auténtico.
''',
'pisa': '''
Pisa — esencia local en pocas horas: rincones fotogénicos, sabores auténticos y paseos relajados.

• Orígenes  
Ciudad medieval famosa por su poder marítimo y su influencia en Toscana.

• Identidad  
Calles históricas, plazas emblemáticas y mercados de barrio reflejan la vida local.

Plan exprés
1) Piazza dei Miracoli y Torre inclinada (60–90 min)
2) Baptisterio y Catedral
3) Calle Borgo Stretto — compras y cafés
4) Mercados locales
5) Gelato italiano y dulces típicos
''',
'praga': '''
Praga — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
Desde asentamientos eslavos hasta capital bohemia, Praga combina historia medieval con arte y cultura centroeuropea.

• Dónde late  
Casco antiguo, Malá Strana y Puente de Carlos concentran vida urbana y patrimonio.

• Hitos  
Castillo de Praga, Reloj Astronómico y festivales locales definen su skyline histórico.

• Identidad cultural  
Cerveza artesanal, gastronomía tradicional, cafés y música clásica hacen de Praga un destino vibrante.

Top 10 actividades
1. Castillo de Praga — Historia y vistas.
2. Puente de Carlos — Fotografía y paseo.
3. Old Town Square — Reloj Astronómico y ambiente.
4. Barrio de Malá Strana — Calles pintorescas.
5. Catedral de San Vito — Arquitectura gótica.
6. Mercado Havelské — Artesanía y productos locales.
7. Excursión a Kutná Hora — Historia y cultura cercana.
8. Teatro Nacional — Arte y espectáculos.
9. Cerveza checa + pastel tradicional — Sabor auténtico.
10. Crucero por el río Moldava — Vistas panorámicas.
''',
'roma': '''
Roma — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
De asentamiento etrusco a imperio mundial, Roma es un museo viviente donde cada calle narra historia.

• Dónde late  
Foro Romano, Coliseo y Trastevere concentran cultura, gastronomía y vida cotidiana.

• Hitos  
Panteón, Fontana di Trevi y festivales culturales definen su skyline histórico.

• Identidad cultural  
Pasta, gelato, cafés y plazas con historia crean una experiencia italiana única.

Top 10 actividades
1. Coliseo — Historia y arquitectura.
2. Foro Romano — Ruinas y cultura.
3. Panteón — Arte y religión.
4. Plaza Navona — Esculturas y cafés.
5. Fontana di Trevi — Fotografía y tradición.
6. Vaticano y Basílica de San Pedro — Arte y espiritualidad.
7. Barrio Trastevere — Callejones y gastronomía.
8. Museos Vaticanos — Arte y cultura.
9. Excursión a Villa Borghese — Jardines y museos.
10. Plato pasta + gelato — Cierra con sabor auténtico.
''',
'san_sebastian': '''
San Sebastian — esencia local en pocas horas: rincones fotogénicos, sabores auténticos y paseos relajados.

• Orígenes  
De villa pesquera a capital cultural del País Vasco, San Sebastián mantiene su casco histórico y playas icónicas.

• Identidad  
Calles pintorescas, paseos costeros y mercados reflejan tradición y estilo de vida local.

Plan exprés
1) Paseo por Parte Vieja (60–90 min)
2) Mirador Monte Urgull
3) Mercado de La Bretxa — productos locales
4) Calle más pintoresca del casco antiguo
5) Pintxo + dulce vasco típico
''',
'santiago de chile': '''
Santiago de Chile — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
Fundada en 1541 por Pedro de Valdivia, Santiago se desarrolló entre cerros y ríos, combinando historia colonial con modernidad urbana.

• Dónde late  
Barrio Bellavista, Lastarria y Providencia concentran cultura, gastronomía y vida urbana.

• Hitos  
Cerro San Cristóbal, Plaza de Armas y museos destacan en su skyline montañoso.

• Identidad cultural  
Vinos, gastronomía local, arte callejero y vida nocturna reflejan la esencia santiaguina.

Top 10 actividades
1. Cerro San Cristóbal — Vistas y teleférico.
2. Barrio Bellavista — Arte, bares y cultura.
3. Museo de la Memoria y los Derechos Humanos — Historia reciente.
4. Plaza de Armas — Centro histórico.
5. La Chascona (Casa de Neruda) — Cultura literaria.
6. Mercado Central — Gastronomía chilena.
7. Cerro Santa Lucía — Paseo y fotografía.
8. Barrio Lastarria — Cafés y arte.
9. Excursión a Viña del Mar o Valparaíso — Historia y color.
10. Plato pastel de choclo + dulce local — Sabor auténtico.
''',
'santorini': '''
Santorini — esencia local en pocas horas: rincones fotogénicos, sabores auténticos y paseos relajados.

• Orígenes  
Isla volcánica habitada desde la antigüedad, Santorini creció entre calderas, arquitectura blanca y tradiciones marítimas.

• Identidad  
Calles empedradas, casas encaladas y atardeceres icónicos crean un escenario único para los visitantes.

Plan exprés
1) Paseo por Oia y Fira (60–90 min)
2) Mirador de la Caldera
3) Playa Roja o Negra
4) Calle más pintoresca del pueblo
5) Vino local + postre tradicional
''',
'segovia': '''
Segovia — esencia local en pocas horas: rincones fotogénicos, sabores auténticos y paseos relajados.

• Orígenes  
Ciudad histórica de Castilla y León, famosa por su acueducto romano y su arquitectura medieval.

• Identidad  
Plazas, calles empedradas y gastronomía local crean un recorrido lleno de historia y sabor.

Plan exprés
1) Acueducto romano (60–90 min)
2) Alcázar de Segovia — Castillo icónico
3) Plaza Mayor — Centro histórico
4) Calle más pintoresca del casco antiguo
5) Cochinillo asado + dulce local
''',
'shanghai': '''
Shanghái — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
De pequeño puerto pesquero a metrópolis global, Shanghái se convirtió en epicentro de comercio, cultura y modernidad en China.

• Dónde late  
Bund, rascacielos de Pudong y shikumen tradicionales concentran su vida urbana y comercial.

• Hitos  
Torre de la Perla, Museo de Shanghái y festivales locales destacan en su skyline futurista.

• Identidad cultural  
Gastronomía local, mercados, arquitectura colonial y modernidad tecnológica crean una experiencia única.

Top 10 actividades
1. Paseo por el Bund — Skyline y fotografía.
2. Torre de Shanghái — Vistas panorámicas.
3. Jardín Yuyuan — Tranquilidad y arquitectura.
4. Templo del Buda de Jade — Cultura y religión.
5. Barrio Xintiandi — Cafés y boutiques.
6. Museo de Shanghái — Arte y historia.
7. Mercado de Nanjing Road — Compras y street food.
8. Crucero por el río Huangpu — Skyline nocturno.
9. Excursión a Zhujiajiao — Pueblo acuático cercano.
10. Dumplings + dulces locales — Sabor auténtico.
''',
'singapur': '''
Singapur — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
De puerto estratégico colonial a ciudad-estado moderna, Singapur combina comercio, tecnología y multiculturalidad.

• Dónde late  
Gardens by the Bay, Marina Bay Sands y hawker centres concentran su vida urbana y cultural.

• Hitos  
Rascacielos futuristas, festivales multiculturales y barrios étnicos definen su skyline moderno.

• Identidad cultural  
Gastronomía variada, arquitectura innovadora y vida de calle reflejan su carácter cosmopolita.

Top 10 actividades
1. Gardens by the Bay — Naturaleza y arquitectura.
2. Marina Bay Sands Skypark — Vistas panorámicas.
3. Merlion Park — Fotografía icónica.
4. Chinatown — Cultura y compras.
5. Little India y Kampong Glam — Callejones y gastronomía.
6. Sentosa Island — Playa y entretenimiento.
7. Museo ArtScience — Ciencia y arte.
8. Singapore Flyer — Panorámica urbana.
9. Hawker Centres — Street food local.
10. Plato laksa + kueh local — Sabor auténtico.
''',
'tokio': '''
Tokio — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
De Edo a capital mundial, Tokio combina tradición japonesa con tecnología y cultura pop.

• Dónde late  
Akihabara, Shinjuku y Shibuya conectan templos, rascacielos y callejones de izakayas.

• Hitos  
Shibuya Crossing, Tokyo Skytree y festivales locales destacan en su skyline moderno.

• Identidad cultural  
Gastronomía callejera, moda, anime y vida nocturna crean una experiencia urbana única.

Top 10 actividades
1. Cruzar Shibuya Crossing — Icono urbano.
2. Tokyo Skytree — Vistas panorámicas.
3. Akihabara — Electrónica y cultura otaku.
4. Shinjuku Golden Gai — Bares y vida nocturna.
5. Palacio Imperial y jardines — Historia y relax.
6. Tsukiji Outer Market — Gastronomía local.
7. Odaiba — Tecnología y entretenimiento.
8. Templo Senso-ji en Asakusa — Cultura y tradición.
9. Paseo por Harajuku — Moda y subcultura.
10. Plato sushi + dulce local — Sabor auténtico.
''',
'toledo': '''
Toledo — esencia local en pocas horas: rincones fotogénicos, sabores auténticos y paseos relajados.

• Orígenes  
De asentamiento romano a ciudad medieval, Toledo combina historia cristiana, musulmana y judía.

• Identidad  
Calles empedradas, plazas históricas y gastronomía local reflejan siglos de cultura.

Plan exprés
1) Paseo por el centro histórico (60–90 min)
2) Mirador del Valle
3) Mercado de abastos — productos locales
4) Calle más pintoresca del casco antiguo
5) Mazapán + plato local típico
''',
'venecia': '''
Venecia — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
De asentamientos en islas a ciudad marítima medieval, Venecia creció entre canales y comercio.

• Dónde late  
Plaza de San Marcos, Rialto y barrios de islas concentran vida urbana y turismo.

• Hitos  
Basílica de San Marcos, Palacio Ducal y góndolas icónicas definen su skyline acuático.

• Identidad cultural  
Canales, góndolas, cafés históricos y gastronomía veneciana crean un ambiente romántico y único.

Top 10 actividades
1. Plaza de San Marcos — Historia y arquitectura.
2. Basílica de San Marcos — Arte y tradición.
3. Palacio Ducal — Cultura y fotografía.
4. Paseo en góndola — Experiencia veneciana.
5. Puente de Rialto — Compras y vistas.
6. Murano y Burano — Artesanía y color.
7. Mercado de Rialto — Gastronomía y ambiente.
8. Teatro La Fenice — Arte y cultura.
9. Excursión a islas cercanas — Naturaleza y color.
10. Plato risotto + dulce local — Sabor auténtico.
''',
'viena': '''
Viena — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
De fortaleza romana a capital imperial, Viena se consolidó como centro cultural y político de Europa Central.

• Dónde late  
Ringstrasse, Stephansplatz y barrios de cafés concentran vida urbana y patrimonio.

• Hitos  
Palacio de Schönbrunn, Ópera Estatal y festivales de música clásica destacan en su skyline histórico.

• Identidad cultural  
Cafés históricos, pastelería vienesa, música clásica y mercados tradicionales crean la esencia urbana.

Top 10 actividades
1. Palacio de Schönbrunn — Historia y jardines.
2. Ópera Estatal de Viena — Música y arquitectura.
3. Stephansdom — Catedral gótica.
4. MuseumsQuartier — Arte moderno y cultura.
5. Paseo por Ringstrasse — Monumentos y palacios.
6. Mercado Naschmarkt — Gastronomía y ambiente.
7. Café Sacher — Pastelería icónica.
8. Belvedere Palace — Arte y jardines.
9. Excursión al Danubio — Naturaleza y paisajes.
10. Plato wiener schnitzel + strudel — Sabor auténtico.
''',
'washington': '''
Washington — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
Planeada como capital de Estados Unidos, Washington combina política, historia y cultura urbana desde finales del siglo XVIII.

• Dónde late  
National Mall, Georgetown y museos Smithsonian concentran vida cultural y turística.

• Hitos  
Capitolio, Casa Blanca y monumentos históricos destacan en su skyline monumental.

• Identidad cultural  
Museos gratuitos, gastronomía variada y parques urbanos crean una experiencia educativa y entretenida.

Top 10 actividades
1. Capitolio de Estados Unidos — Historia política.
2. Casa Blanca — Icono mundial.
3. Museo Nacional de Historia Natural — Ciencia y cultura.
4. Smithsonian Air & Space Museum — Tecnología y aviación.
5. Monumento a Lincoln — Historia y fotografía.
6. Georgetown — Compras y cafés.
7. National Gallery of Art — Arte clásico y moderno.
8. Paseo por el National Mall — Monumentos y memoriales.
9. Excursión a Mount Vernon — Historia de Washington.
10. Plato local + postre estadounidense — Experiencia culinaria.
''',
'yokohama': '''
Yokohama — historia viva, barrios con carácter y una energía que se siente en plazas, mercados y miradores.

• Fundación / orígenes  
Puerto estratégico desde el siglo XIX, Yokohama creció como centro de comercio internacional y cultura moderna japonesa.

• Dónde late  
Minato Mirai, Chinatown y zonas portuarias reflejan la mezcla de tradición y modernidad.

• Hitos  
Torre Landmark, Yamashita Park y festivales culturales destacan en su skyline costero.

• Identidad cultural  
Gastronomía diversa, cafés modernos, festivales y arquitectura contemporánea crean un ambiente vibrante.

Top 10 actividades
1. Minato Mirai 21 — Paseo y fotografía.
2. Torre Landmark — Vistas panorámicas.
3. Chinatown — Gastronomía y cultura.
4. Yamashita Park — Paseo junto al mar.
5. Museo de CupNoodles — Innovación y diversión.
6. Red Brick Warehouse — Compras y eventos.
7. Sankeien Garden — Jardines tradicionales.
8. Cosmo World — Parque de atracciones.
9. Excursión a Enoshima — Naturaleza y cultura cercana.
10. Plato ramen + dulce local — Sabor auténtico.
''',

  };

  @override
  void initState() {
    super.initState();
    _imagesFuture = _loadCityImages(widget.city, widget.featuredImage);
  }

  Future<List<String>> _loadCityImages(String city, String? featured) async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final normalized = _normalizeForAsset(city);

      final paths = manifestMap.keys
          .where((path) => path.startsWith('assets/images/destinations/'))
          .where((path) {
            final low = path.toLowerCase();
            return low.contains(normalized);
          })
          .where((path) =>
              path.endsWith('.jpg') || path.endsWith('.png') || path.endsWith('.jpeg'))
          .toList()
        ..sort();

      // Si hay featured, colócala al inicio si existe
      if (featured != null && paths.contains(featured)) {
        paths.remove(featured);
        paths.insert(0, featured);
      } else if (featured != null && manifestMap.containsKey(featured)) {
        paths.insert(0, featured);
      }

      // Si no hay coincidencias, intenta base
      if (paths.isEmpty) {
        final base = 'assets/images/destinations/$normalized.jpg';
        if (manifestMap.containsKey(base)) {
          return [base];
        }
      }
      return paths;
    } catch (e) {
      return [];
    }
  }

  String _getDescriptionForCity(String city) {
    final normalized = _normalizeForAsset(city);
    if (_cityDescriptions.containsKey(normalized)) {
      return _cityDescriptions[normalized]!;
    }
    return '''
${city} — descubre lo mejor de esta ciudad con recorridos por sus sitios emblemáticos, su gastronomía y su cultura local.

✨ Imperdibles
- Centro histórico y puntos icónicos
- Gastronomía local
- Actividades al aire libre

📝 Consejos
- Visitas temprano para evitar filas
- Mercados locales para comida auténtica
- Barrios menos turísticos para experiencias genuinas
''';
  }

  String _getVideoPathForCity(String city) {
    final normalized = _normalizeForAsset(city);
    return 'assets/videos/${normalized}_v.mp4';
  }

  void _openGallery(BuildContext context, List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullscreenGalleryPage(images: images, initialIndex: initialIndex)));
  }

  @override
  Widget build(BuildContext context) {
    final desc = _getDescriptionForCity(widget.city);
    final videoPath = _getVideoPathForCity(widget.city);

    return Scaffold(
      appBar: AppBar(title: Text(widget.city)),
      body: FutureBuilder<List<String>>(
        future: _imagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final images = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Carrusel principal con imagen completa (contain)
              if (images.isNotEmpty)
                SizedBox(
                  height: 260,
                  child: CarouselSlider.builder(
                    itemCount: images.length,
                    itemBuilder: (context, index, realIdx) {
                      final path = images[index];
                      return GestureDetector(
                        onTap: () => _openGallery(context, images, index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Imagen completa dentro del contenedor (sin recorte)
                                Center(
                                  child: Image.asset(
                                    path,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                        const Center(child: Icon(Icons.image_not_supported, color: Colors.white)))),
                              ]))));
                    },
                    options: CarouselOptions(
                      viewportFraction: 1,
                      height: 260,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 4))))
              else
                Container(
                  height: 220,
                  color: Colors.black,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 80, color: Colors.white70))),
              const SizedBox(height: 12),
              Text(widget.city, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(desc, style: const TextStyle(fontSize: 16, height: 1.5), textAlign: TextAlign.justify),
              const SizedBox(height: 16),

              // Miniaturas scroll horizontal
              if (images.isNotEmpty) ...[
                Text('Galería', style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemCount: images.length > 20 ? 20 : images.length,
                    itemBuilder: (_, i) {
                      final p = images[i];
                      return InkWell(
                        onTap: () => _openGallery(context, images, i),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 140,
                            color: Colors.black,
                            child: Center(
                              child: Image.asset(p, fit: BoxFit.contain)))));
                    })),
                const SizedBox(height: 16),
              ],

              // Video placeholder section
              Text('Video destacado', style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => VideoPlaceholderPage(videoPath: videoPath, city: widget.city)));
                },
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                    image: (images.isNotEmpty)
                        ? DecorationImage(image: AssetImage(images.first), fit: BoxFit.cover, colorFilter: const ColorFilter.mode(Colors.black45, BlendMode.darken))
                        : null),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(32)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Reproducir video', style: TextStyle(color: Colors.white)),
                        ]))))),
              const SizedBox(height: 24),
            ]);
        }));
  }
}

class FullscreenGalleryPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const FullscreenGalleryPage({super.key, required this.images, this.initialIndex = 0});

  @override
  State<FullscreenGalleryPage> createState() => _FullscreenGalleryPageState();
}

class _FullscreenGalleryPageState extends State<FullscreenGalleryPage> {
  late PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: _index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('${_index + 1}/${widget.images.length}', style: const TextStyle(color: Colors.white))),
      body: PhotoViewGallery.builder(
        pageController: _pageController,
        itemCount: widget.images.length,
        builder: (context, index) {
          final img = widget.images[index];
          return PhotoViewGalleryPageOptions(
            imageProvider: AssetImage(img),
            heroAttributes: PhotoViewHeroAttributes(tag: img),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3);
        },
        onPageChanged: (i) => setState(() => _index = i),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        loadingBuilder: (context, event) => const Center(child: CircularProgressIndicator())));
  }
}
class VideoPlaceholderPage extends StatefulWidget {
  final String videoPath;
  final String city;
  const VideoPlaceholderPage({super.key, required this.videoPath, required this.city});

  @override
  State<VideoPlaceholderPage> createState() => _VideoPlaceholderPageState();
}

class _VideoPlaceholderPageState extends State<VideoPlaceholderPage> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset(widget.videoPath);
      await _videoController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: false,
        looping: true,
      );
      setState(() {});
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = e.toString();
      });
      debugPrint('❌ Error al inicializar el video: $e');
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video — ${widget.city}')),
      body: Center(
        child: _isError
            ? Text(
                '⚠️ No se pudo cargar el video:\n$_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              )
            : _chewieController != null && _videoController.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: Chewie(controller: _chewieController!),
                  )
                : const CircularProgressIndicator(),
      ),
    );
  }
}


// ------------------ COMPONENTES ORIGINALES (completos) ------------------

class _HeroCarousel extends StatefulWidget {
  final List<String> images;
  const _HeroCarousel({required this.images});

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final sliderHeight = isMobile ? MediaQuery.of(context).size.height * 0.45 : 240.0;

    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24)),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CarouselSlider(
                items: widget.images.map((path) {
                  return Builder(
                    builder: (context) => Stack(
                      fit: StackFit.expand,
                      children: [
                        SizedBox(
                          height: sliderHeight,
                          child: Image.asset(
                            path,
                            fit: BoxFit.cover,
                            width: double.infinity)),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.0),
                                Colors.black.withOpacity(0.55),
                              ]))),
                        const Positioned(
                          left: 16,
                          right: 16,
                          bottom: 28,
                          child: Text(
                            'Descubre el mundo con Carlitos Travel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.2))),
                      ]));
                }).toList(),
                options: CarouselOptions(
                  height: sliderHeight,
                  viewportFraction: 1,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  onPageChanged: (i, _) => setState(() => _index = i))),
              Positioned(
                bottom: 8,
                child: Row(
                  children: List.generate(widget.images.length, (i) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _index ? Colors.white : Colors.white38));
                  }))),
            ])),
      ]);
  }
}

class _DestinationCard extends StatelessWidget {
  final _Destination dest;
  const _DestinationCard({super.key, required this.dest});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CityDetailPage(city: dest.title, featuredImage: dest.imagePath)));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.asset(
                  dest.imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity)),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dest.title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      dest.subtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ])),
            ]))));
  }
}

class _TripsGrid extends StatelessWidget {
  final List<String> paths;
  const _TripsGrid({required this.paths});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1),
      itemCount: paths.length,
      itemBuilder: (context, i) {
        final path = paths[i];
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: Colors.black),
              Center(child: Image.asset(path, fit: BoxFit.contain)),
              const Positioned(
                right: 8,
                top: 8,
                child: _FullscreenBadge()),
            ]));
      });
  }
}

class _FullscreenBadge extends StatelessWidget {
  const _FullscreenBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12)),
      child: const Icon(
        Icons.fullscreen,
        color: Colors.white,
        size: 18));
  }
}

class _Destination {
  final String title;
  final String subtitle;
  final String imagePath;
  const _Destination(this.title, this.subtitle, this.imagePath);
}

// ------------------ COTIZACIÓN DE VUELOS (Mock + Pago placeholder) ------------------

enum TripType { ida, idaVuelta, multidestino }

class VuelosQuotePage extends StatefulWidget {
  const VuelosQuotePage({super.key});

  @override
  State<VuelosQuotePage> createState() => _VuelosQuotePageState();
}

class _VuelosQuotePageState extends State<VuelosQuotePage> {
  final _formKey = GlobalKey<FormState>();
  final _origenCtrl = TextEditingController();
  final _destinoCtrl = TextEditingController();
  DateTime? _fechaIda;
  DateTime? _fechaVuelta;
  TripType _tipo = TripType.ida;
  final List<Map<String, String>> _segmentos = []; // para multidestino
  List<_CotizacionVuelo> _resultados = [];

  double comision = 0.10; // 10% configurable

  Future<void> _pickDate(BuildContext context, bool isDeparture) async {
    final initial = DateTime.now().add(const Duration(days: 3));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)));
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _fechaIda = picked;
          if (_tipo == TripType.idaVuelta && (_fechaVuelta == null || _fechaVuelta!.isBefore(_fechaIda!))) {
            _fechaVuelta = picked.add(const Duration(days: 7));
          }
        } else {
          _fechaVuelta = picked;
        }
      });
    }
  }

  // Mock de web service de cotización
  Future<List<_CotizacionVuelo>> _cotizar() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Regla simple de precios mock
    final base = 1200000.0 +
        (_destinoCtrl.text.trim().length * 13000) +
        (_origenCtrl.text.trim().length * 9000) +
        (_tipo == TripType.idaVuelta ? 800000 : 0) +
        (_tipo == TripType.multidestino ? 1100000 : 0);
    return List.generate(3, (i) {
      final precio = base + i * 150000;
      return _CotizacionVuelo(
        aerolinea: ['Avianca', 'LATAM', 'Copa'][i % 3],
        duracion: ['5h 20m', '6h 45m', '8h 10m'][i % 3],
        escalas: i == 0 ? 0 : 1,
        precioTotal: precio,
        precioConComision: precio * (1 + comision));
    });
  }

  void _agregarSegmento() {
    setState(() {
      _segmentos.add({'origen': '', 'destino': ''});
    });
  }

  void _irAPago(_CotizacionVuelo cot) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PagoPlaceholderPage(cotizacion: cot, comision: comision)));
  }

  @override
  void dispose() {
    _origenCtrl.dispose();
    _destinoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cotización de Vuelos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Completa los datos para cotizar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _origenCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Origen (ciudad o aeropuerto)',
                      prefixIcon: Icon(Icons.flight_takeoff)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _destinoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Destino (ciudad o aeropuerto)',
                      prefixIcon: Icon(Icons.flight_land)),
                    validator: (v) => (_tipo != TripType.multidestino && (v == null || v.trim().isEmpty)) ? 'Requerido' : null),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<TripType>(
                          value: TripType.ida,
                          groupValue: _tipo,
                          onChanged: (v) => setState(() => _tipo = v!),
                          title: const Text('Sólo ida'))),
                      Expanded(
                        child: RadioListTile<TripType>(
                          value: TripType.idaVuelta,
                          groupValue: _tipo,
                          onChanged: (v) => setState(() => _tipo = v!),
                          title: const Text('Ida y vuelta'))),
                    ]),
                  RadioListTile<TripType>(
                    value: TripType.multidestino,
                    groupValue: _tipo,
                    onChanged: (v) => setState(() => _tipo = v!),
                    title: const Text('Multidestino')),
                  const SizedBox(height: 8),
                  if (_tipo != TripType.multidestino) ...[
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickDate(context, true),
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Fecha de ida', prefixIcon: Icon(Icons.calendar_today)),
                              child: Text(_fechaIda == null ? 'Selecciona fecha' : _fechaIda!.toString().split(' ').first)))),
                        const SizedBox(width: 8),
                        if (_tipo == TripType.idaVuelta)
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(context, false),
                              child: InputDecorator(
                                decoration: const InputDecoration(labelText: 'Fecha de regreso', prefixIcon: Icon(Icons.calendar_month)),
                                child: Text(_fechaVuelta == null ? 'Selecciona fecha' : _fechaVuelta!.toString().split(' ').first)))),
                      ]),
                  ] else ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        onPressed: _agregarSegmento,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar tramo'))),
                    const SizedBox(height: 8),
                    Column(
                      children: List.generate(_segmentos.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(labelText: 'Origen tramo ${i + 1}'),
                                  onChanged: (v) => _segmentos[i]['origen'] = v)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(labelText: 'Destino tramo ${i + 1}'),
                                  onChanged: (v) => _segmentos[i]['destino'] = v)),
                              IconButton(
                                onPressed: () => setState(() => _segmentos.removeAt(i)),
                                icon: const Icon(Icons.delete_outline)),
                            ]));
                      })),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() != true) return;
                            final res = await _cotizar();
                            setState(() => _resultados = res);
                          },
                          icon: const Icon(Icons.search),
                          label: const Text('Cotizar'))),
                    ]),
                ])),
            const SizedBox(height: 16),
            if (_resultados.isNotEmpty) ...[
              const Text('Resultados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Column(
                children: _resultados.map((r) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.flight),
                      title: Text('${r.aerolinea} • ${r.duracion} • ${r.escalas} ${r.escalas == 1 ? 'escala' : 'escalas'}'),
                      subtitle: Text('Precio base: \$${r.precioTotal.toStringAsFixed(0)} • Con 10%: \$${r.precioConComision.toStringAsFixed(0)}'),
                      trailing: ElevatedButton(
                        onPressed: () => _irAPago(r),
                        child: const Text('Pagar'))));
                }).toList()),
            ],
          ])));
  }
}

class _CotizacionVuelo {
  final String aerolinea;
  final String duracion;
  final int escalas;
  final double precioTotal;
  final double precioConComision;
  _CotizacionVuelo({
    required this.aerolinea,
    required this.duracion,
    required this.escalas,
    required this.precioTotal,
    required this.precioConComision,
  });
}

class PagoPlaceholderPage extends StatelessWidget {
  final _CotizacionVuelo cotizacion;
  final double comision;
  const PagoPlaceholderPage({super.key, required this.cotizacion, required this.comision});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago (simulado)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumen del vuelo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Aerolínea: ${cotizacion.aerolinea}'),
            Text('Duración: ${cotizacion.duracion}'),
            Text('Escalas: ${cotizacion.escalas}'),
            const SizedBox(height: 8),
            Text('Precio base: \$${cotizacion.precioTotal.toStringAsFixed(0)}'),
            Text('Comisión ${(comision * 100).toStringAsFixed(0)}%: \$${(cotizacion.precioTotal * comision).toStringAsFixed(0)}'),
            Text('Total a pagar: \$${cotizacion.precioConComision.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            const Text('Proveedor de pago (placeholder): Wompi / ePayco / PlacetoPay'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pago simulado exitoso. ¡Gracias!')));
                Navigator.pop(context);
              },
              icon: const Icon(Icons.lock_open),
              label: const Text('Simular pago')),
          ])));
  }
}

// ------------------ VISAS ------------------

class VisasGridPage extends StatelessWidget {
  // Cambiado a VisaCountry para que coincida con el uso de propiedades
  final List<VisaCountry> visas = const [];

  const VisasGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visas')),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1),
        itemCount: visas.length,
        itemBuilder: (context, index) {
          final v = visas[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VisaDetailPage(visa: v)));
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Image.asset(
                        v.flagUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.flag_outlined,
                          size: 48))),
                    const SizedBox(height: 8),
                    Text(
                      v.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                  ]))));
        }));
  }
}







// ------------------ SOBRE NOSOTROS RESPONSIVE ------------------

class AboutCarlosResponsiveSection extends StatelessWidget {
  const AboutCarlosResponsiveSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    final bioTextStyle = kIsWeb
        ? GoogleFonts.lato(
            fontSize: 16,
            height: 1.5,
            fontWeight: FontWeight.w400,
            color: Colors.grey[900])
        : TextStyle(
            fontSize: 16,
            height: 1.5,
            fontWeight: FontWeight.w400,
            color: Colors.grey[900]);

    final bioContent = Text(
      'Soy ingeniero de sistemas, especialista en bases de datos y magíster en Big Data e Inteligencia Artificial. '
      'Durante años trabajé en diversas empresas, liderando investigaciones y proyectos publicados en revistas científicas de renombre, '
      'pero pronto descubrí que la vida no se trata solo de horarios de oficina y contratos mal remunerados.\n\n'
      'Mi pasión por viajar comenzó con el fútbol, pero rápidamente se transformó en una fascinación por el mundo. '
      'Desde entonces, he recorrido más de 30 países:\n'
      '🇨🇴 Colombia\n'
      '🇪🇸 España\n'
      '🇺🇸 Estados Unidos\n'
      '🇵🇦 Panamá\n'
      '🇫🇷 Francia\n'
      '🇧🇪 Bélgica\n'
      '🇳🇱 Países Bajos\n'
      '🇩🇪 Alemania\n'
      '🇨🇿 República Checa\n'
      '🇮🇹 Italia\n'
      '🇬🇷 Grecia\n'
      '🇲🇽 México\n'
      '🇦🇷 Argentina\n'
      '🇭🇺 Hungría\n'
      '🇦🇹 Austria\n'
      '🇬🇧 Reino Unido\n'
      '🇵🇹 Portugal\n'
      '🇦🇪 Emiratos Árabes Unidos\n'
      '🇯🇵 Japón\n'
      '🇨🇭 Suiza\n'
      '🇲🇦 Marruecos\n'
      '🇵🇪 Perú\n'
      '🇨🇱 Chile\n'
      '🇰🇷 Corea del Sur\n'
      '🇮🇩 Indonesia\n'
      '🇲🇾 Malasia\n'
      '🇹🇭 Tailandia\n'
      '🇸🇬 Singapur\n'
      '🇨🇳 China\n'
      '🇪🇬 Egipto\n\n'
      'Hoy, trabajo de manera remota, lo que me permite seguir explorando el mundo mientras aplico mi experiencia en datos y tecnología. '
      'Creo firmemente que nuestro propósito real en la vida es vivir experiencias auténticas, conocer nuevas culturas, probar sabores distintos '
      'y conectar con personas alrededor del planeta. Esta filosofía es la que inspira mi agencia de viajes y la manera en que deseo acompañar '
      'a otros viajeros a descubrir el mundo.',
      textAlign: TextAlign.justify,
      style: bioTextStyle);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (isMobile) ...[
            ClipOval(
              child: Image.asset(
                'assets/images/biografia/biografia_01.JPEG',
                width: 120,
                height: 120,
                fit: BoxFit.cover)),
            const SizedBox(height: 12),
            const Text(
              'Carlos Fernando Tovar Yepes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              'CEO',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary),
              textAlign: TextAlign.center),
            const SizedBox(height: 16),
            bioContent,
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/biografia/biografia_01.JPEG',
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover)),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Carlos Fernando Tovar Yepes',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        'CEO',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary)),
                      const SizedBox(height: 16),
                      bioContent,
                    ])),
              ]),
          ],
        ]));
  }
}


// ====== VISAS: Grid premium y detalle ======
class VisasGridPageX extends StatelessWidget {
  const VisasGridPageX({super.key});
  @override
  Widget build(BuildContext context) {
    final items = <VisaCountryX>[
      VisaCountryX(country: 'Estados Unidos', title: 'Visa Americana', flagUrl: 'https://flagcdn.com/w320/us.png'),
      VisaCountryX(country: 'Japón', title: 'Visa Japonesa', flagUrl: 'https://flagcdn.com/w320/jp.png'),
      VisaCountryX(country: 'China', title: 'Visa China', flagUrl: 'https://flagcdn.com/w320/cn.png'),
      VisaCountryX(country: 'Canadá', title: 'Visa Canadiense', flagUrl: 'https://flagcdn.com/w320/ca.png'),
      VisaCountryX(country: 'Reino Unido', title: 'Visa del Reino Unido', flagUrl: 'https://flagcdn.com/w320/gb.png'),
      VisaCountryX(country: 'Australia', title: 'Visa Australiana', flagUrl: 'https://flagcdn.com/w320/au.png'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Visas')),
      body: LayoutBuilder(
        builder: (context, c) {
          final cross = c.maxWidth < 600 ? 1 : 2;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.1
            ),
            itemCount: items.length,
            itemBuilder: (context, i) => _VisaCardX(data: items[i]));
        }));
  }
}

class _VisaCardX extends StatelessWidget {
  final VisaCountryX data;
  const _VisaCardX({required this.data});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_)=> VisaDetailPageX(data: data))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'flag-${data.country}',
                child: Image.network(
                  data.flagUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.flag_outlined, size: 48))))),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(children: const [Icon(Icons.open_in_new, size: 16), SizedBox(width: 6), Text('Ver detalles', style: TextStyle(fontSize: 12))])
                ]))
          ])));
  }
}

class VisaCountryX {
  final String country;
  final String title;
  final String flagUrl;
  const VisaCountryX({required this.country, required this.title, required this.flagUrl});
}

class VisaDetailPageX extends StatefulWidget {
  final VisaCountryX data;
  const VisaDetailPageX({super.key, required this.data});
  @override
  State<VisaDetailPageX> createState() => _VisaDetailPageStateX();
}

class _VisaDetailPageStateX extends State<VisaDetailPageX> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _pasaporteCtrl = TextEditingController();
  final _nacionalidadCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();
  final _observCtrl = TextEditingController();

  DateTime? _fechaViaje;
  DateTime? _fechaCita;

  double tasaConsular = 0.0;
  static const double honorariosFijos = 2000000.0;
  double get total => tasaConsular + honorariosFijos;

  String visaIntroFor(String country){
    switch(country){
      case 'Estados Unidos':
        return 'Tramitar tu visa para Estados Unidos no tiene por qué ser abrumador. Diligenciamos tu DS-160, guiamos el pago de la tasa consular, agendamos tu cita y te preparamos con entrevistas personalizadas. Acompañamiento real hasta el día de tu entrevista.';
      case 'Canadá':
        return 'Visa canadiense con guía completa: formularios, pago de tasas y acompañamiento a biométricos. Checklist claro y orientación práctica paso a paso.';
      case 'Reino Unido':
        return 'Visa del Reino Unido (visitante/estudios/corta estancia). Te guiamos en formularios, tasas, cita y documentación. Simulacro de entrevista cuando aplique.';
      case 'Japón':
        return 'Visa turística para Japón: checklist de requisitos, reservas y documentos de soporte. Diligenciamiento y preparación previa a la cita.';
      case 'China':
        return 'Para China te orientamos con carta de invitación o sponsor cuando aplique, formularios, tasas y cita. Revisión de soportes y tips de viaje.';
      case 'Australia':
        return 'Australia (ETA/eVisitor/Visitor). Te ayudamos a elegir la subclass correcta, diligenciar, pagar y agendar. Acompañamiento de principio a fin.';
      default:
        return 'Te asistimos integralmente: formulario, pago de tasa, programación de cita y entrevistas de preparación. Acompañamiento real hasta el día de tu cita.';
    }
  }

  @override
  void dispose(){
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _pasaporteCtrl.dispose();
    _nacionalidadCtrl.dispose();
    _telefonoCtrl.dispose();
    _ciudadCtrl.dispose();
    _observCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return Scaffold(
      appBar: AppBar(title: Text(d.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'flag-${d.country}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(d.flagUrl, height: 160, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height:160, alignment: Alignment.center, child: const Icon(Icons.flag_outlined, size: 48))))),
            const SizedBox(height: 16),
            Text(visaIntroFor(d.country), textAlign: TextAlign.justify, style: const TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 16),
            Card(
              elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Costeo transparente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Tasa consular vigente (COP)', prefixIcon: Icon(Icons.payments_outlined), hintText: 'Ej: 704000'),
                    keyboardType: TextInputType.number,
                    onChanged: (v){ final only=v.replaceAll(RegExp(r'[^0-9]'), ''); setState(()=>tasaConsular = double.tryParse(only)??0.0); }),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[const Text('Tasa consular'), Text('COP ' + tasaConsular.toStringAsFixed(0))]),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Honorarios fijos'), Text('COP 2000000')]),
                  const Divider(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total estimado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('COP ' + total.toStringAsFixed(0), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ]),
                ]))),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: (){ Scrollable.ensureVisible(_formKey.currentContext!, duration: const Duration(milliseconds: 350)); },
                icon: const Icon(Icons.edit),
                label: const Text('Rellenar formulario'))),
            const SizedBox(height: 24),
            const Text('Formulario de asesoría', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre completo', prefixIcon: Icon(Icons.person)), validator: (v)=> (v==null||v.trim().isEmpty)?'Requerido':null),
                TextFormField(controller: _correoCtrl, decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email)), keyboardType: TextInputType.emailAddress, validator: (v){
                  if(v==null || v.trim().isEmpty) return 'Requerido';
                  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
                  return ok? null : 'Correo inválido';
                }),
                TextFormField(controller: _pasaporteCtrl, decoration: const InputDecoration(labelText: 'Número de pasaporte', prefixIcon: Icon(Icons.badge)), validator: (v)=> (v==null||v.trim().isEmpty)?'Requerido':null),
                TextFormField(controller: _nacionalidadCtrl, decoration: const InputDecoration(labelText: 'Nacionalidad', prefixIcon: Icon(Icons.flag)), validator: (v)=> (v==null||v.trim().isEmpty)?'Requerido':null),
                TextFormField(controller: _telefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono', prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone),
                TextFormField(controller: _ciudadCtrl, decoration: const InputDecoration(labelText: 'Ciudad de residencia', prefixIcon: Icon(Icons.location_city))),
                const SizedBox(height: 8),
                _DatePickerRowX(label:'Fecha tentativa de viaje', icon: Icons.flight_takeoff, value:_fechaViaje, onPicked:(d)=> setState(()=> _fechaViaje=d)),
                const SizedBox(height: 8),
                _DatePickerRowX(label:'Fecha tentativa para la cita', icon: Icons.event, value:_fechaCita, onPicked:(d)=> setState(()=> _fechaCita=d)),
                const SizedBox(height: 8),
                TextFormField(controller: _observCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Observaciones adicionales', alignLabelWithHint: true, prefixIcon: Icon(Icons.notes))),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: (){
                    if((_formKey.currentState?.validate() ?? false)){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud enviada. Te contactaremos para pago (placeholder).')));
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Enviar y continuar a pago (próximamente)')),
              ])),
          ])));
  }
}

class _DatePickerRowX extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final ValueChanged<DateTime?> onPicked;
  const _DatePickerRowX({required this.label, required this.icon, required this.value, required this.onPicked});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final d = await showDatePicker(
          context: context,
          initialDate: now.add(const Duration(days:30)),
          firstDate: now,
          lastDate: now.add(const Duration(days:365)));
        if(d!=null) onPicked(d);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value==null ? 'Toca para seleccionar' : value!.toLocal().toString().split(' ').first),
            const Icon(Icons.calendar_today, size: 18),
          ])));
  }
}



// ===============================
// VISAS - Añadido por ChatGPT (no invasivo, al final del archivo)
// ===============================









class _CostBreakdown extends StatelessWidget {
  final VisaCountry visa;
  final double total;
  const _CostBreakdown({required this.visa, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05))),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payments_outlined),
              const SizedBox(width: 8),
              Text('Costos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            ]),
          const SizedBox(height: 12),
          _costRow('Tasa consular', _usd(visa.consularFee)),
          const SizedBox(height: 6),
          _costRow('Asesoría Carlitos Travel', _usd(visa.serviceFee)),
          const Divider(height: 24),
          _costRow('Total', _usd(total), isTotal: true),
        ]));
  }

  Widget _costRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600)),
        Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700)),
      ]);
  }
}



class _VisaFormPageState extends State<VisaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passportCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  DateTime? _preferredDate;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passportCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Formulario - ${widget.visa.shortName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _textField(controller: _nameCtrl, label: 'Nombre completo', icon: Icons.person_outline,
                         validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null),
              const SizedBox(height: 12),
              _textField(controller: _emailCtrl, label: 'Correo electrónico', icon: Icons.email_outlined,
                         keyboardType: TextInputType.emailAddress,
                         validator: (v) {
                           if (v == null || v.trim().isEmpty) return 'Requerido';
                           final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim());
                           return ok ? null : 'Correo inválido';
                         }),
              const SizedBox(height: 12),
              _textField(controller: _phoneCtrl, label: 'Teléfono / WhatsApp', icon: Icons.phone_outlined,
                         keyboardType: TextInputType.phone,
                         validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null),
              const SizedBox(height: 12),
              _textField(controller: _passportCtrl, label: 'Número de pasaporte', icon: Icons.badge_outlined,
                         validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null),
              const SizedBox(height: 12),
              _textField(controller: _cityCtrl, label: 'Ciudad de residencia', icon: Icons.location_city_outlined,
                         validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null),
              const SizedBox(height: 12),
              _datePickerField(context: context, label: 'Fecha tentativa de viaje', value: _preferredDate,
                               onPick: (d) => setState(() => _preferredDate = d)),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.lock_outline),
                label: const Text('Pagar/Enviar solicitud (demo)'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52))),
              const SizedBox(height: 8),
              Text(
                'Demo: Este envío solo muestra un mensaje de confirmación. '
                'Luego puedes integrarlo con tu pasarela de pagos y backend.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
            ]))));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_preferredDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la fecha tentativa de viaje')));
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Solicitud enviada'),
        content: Text(
          'Gracias, ${_nameCtrl.text.trim()}.\n\n'
          'Recibimos tu solicitud para la ${widget.visa.title}.\n'
          'Te contactaremos a ${_emailCtrl.text.trim()} en breve.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cerrar')),
        ]));
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.08))),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary))));
  }

  Widget _datePickerField({
    required BuildContext context,
    required String label,
    required DateTime? value,
    required void Function(DateTime) onPick,
  }) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          firstDate: now,
          lastDate: DateTime(now.year + 2),
          initialDate: value ?? now);
        if (picked != null) onPick(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_month_outlined),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.08)))),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            value == null
                ? 'Selecciona una fecha'
                : '${value.year.toString().padLeft(4, '0')}-'
                  '${value.month.toString().padLeft(2, '0')}-'
                  '${value.day.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.bodyMedium))));
  }
}

// DATA para Visas




String _usd(double value) {
  final intPart = value.truncate();
  final thousands = _thousandsSeparator(intPart);
  final decimals = (value - intPart).abs() < 0.005 ? '00' : value.toStringAsFixed(2).split('.')[1];
  return 'USD \$'+thousands +'.'+decimals;
}

String _thousandsSeparator(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idxFromEnd = s.length - i;
    buf.write(s[i]);
    if (idxFromEnd > 1 && idxFromEnd % 3 == 1) {
      buf.write(',');
    }
  }
  return buf.toString();
}

// ===============================
// SECCIÓN DE VISAS
// ===============================
class VisasPage extends StatelessWidget {
  static const routeName = '/visas';
  const VisasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visas')),
      body: const _VisaGrid());
  }
}

class _VisaGrid extends StatelessWidget {
  const _VisaGrid();

  @override
  Widget build(BuildContext context) {
    final items = VisaRepository.all;
    final crossAxisCount = MediaQuery.of(context).size.width > 700 ? 3 : 2;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3 / 3.8),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final visa = items[i];
          return _VisaCard(visa: visa);
        }));
  }
}

class _VisaCard extends StatelessWidget {
  final VisaCountry visa;
  const _VisaCard({required this.visa});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VisaDetailPage(visa: visa)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      visa.flagUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.flag_outlined, size: 48))))),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(12)),
                      child: Text(visa.emoji, style: const TextStyle(fontSize: 16, color: Colors.white)))),
                ])),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visa.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on_outlined, size: 18),
                      const SizedBox(width: 6),
                      Text('Desde ${_usd(visa.consularFee + visa.serviceFee)}',
                        style: Theme.of(context).textTheme.bodyMedium),
                    ]),
                ]))
          ])));
  }
}

class VisaDetailPage extends StatelessWidget {
  final VisaCountry visa;
  const VisaDetailPage({super.key, required this.visa});

  @override
  Widget build(BuildContext context) {
    final total = visa.consularFee + visa.serviceFee;
    return Scaffold(
      appBar: AppBar(title: Text(visa.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  visa.flagUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.flag_outlined, size: 64)))))),
            const SizedBox(height: 16),
            Text(visa.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(visa.pitch, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            _CostBreakdown(visa: visa, total: total),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => VisaFormPage(visa: visa)));
              },
              icon: const Icon(Icons.edit_note),
              label: const Text('Rellenar formulario y pagar'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52))),
          ])));
  }
}

class VisaFormPage extends StatefulWidget {
  final VisaCountry visa;
  const VisaFormPage({super.key, required this.visa});

  @override
  State<VisaFormPage> createState() => _VisaFormPageState();
}

class VisaRepository {
  static final List<VisaCountry> all = [
    VisaCountry(
      code: 'US', shortName: 'USA', title: 'Visa Americana (Estados Unidos)',
      emoji: '🇺🇸', flagUrl: 'https://flagcdn.com/w1280/us.png',
      consularFee: 185, serviceFee: 100,
      pitch: 'DS-160, citas y preparación para entrevista. Todo contigo 🇺🇸.'),
    VisaCountry(
      code: 'CN', shortName: 'China', title: 'Visa China',
      emoji: '🇨🇳', flagUrl: 'https://flagcdn.com/w1280/cn.png',
      consularFee: 140, serviceFee: 120,
      pitch: 'Checklist, formulario y citas para China 🇨🇳.'),
    VisaCountry(
      code: 'CA', shortName: 'Canadá', title: 'Visa Canadá',
      emoji: '🇨🇦', flagUrl: 'https://flagcdn.com/w1280/ca.png',
      consularFee: 100, serviceFee: 100,
      pitch: 'Te guiamos en tu visa canadiense 🇨🇦 sin estrés.'),
    VisaCountry(
      code: 'GB', shortName: 'Reino Unido', title: 'Visa Reino Unido',
      emoji: '🇬🇧', flagUrl: 'https://flagcdn.com/w1280/gb.png',
      consularFee: 130, serviceFee: 110,
      pitch: 'Documentación y acompañamiento completo 🇬🇧.'),
    VisaCountry(
      code: 'JP', shortName: 'Japón', title: 'Visa Japón',
      emoji: '🇯🇵', flagUrl: 'https://flagcdn.com/w1280/jp.png',
      consularFee: 30, serviceFee: 90,
      pitch: 'Requisitos y formatos para Japón 🇯🇵.'),
    VisaCountry(
      code: 'AU', shortName: 'Australia', title: 'Visa Australia',
      emoji: '🇦🇺', flagUrl: 'https://flagcdn.com/w1280/au.png',
      consularFee: 145, serviceFee: 120,
      pitch: 'Checklist y formularios para Australia 🇦🇺.'),
  ];
}

// Shim: VisaDetailPageX compatible with older calls



// =============================
// 🌐 VisaGridPage Moderna
// =============================

class VisaCountry {
  final String code;
  final String shortName;
  final String title;
  final String pitch;
  final String emoji;
  final double consularFee;
  final double serviceFee;
  final String flagUrl;
  final String? name;         // Opcional para compatibilidad moderna
  final String? description;  // Opcional para compatibilidad moderna

  const VisaCountry({
    required this.code,
    required this.shortName,
    required this.title,
    required this.pitch,
    required this.emoji,
    required this.consularFee,
    required this.serviceFee,
    required this.flagUrl,
    this.name,
    this.description,
  });
}
final List<VisaCountry> visaCountries = [
  VisaCountry(
    code: 'US',
    shortName: 'USA',
    title: 'Visa Americana',
    pitch: 'Visa de turismo y negocios para Estados Unidos. Incluye guía completa.',
    emoji: '🇺🇸',
    consularFee: 160,
    serviceFee: 50,
    flagUrl: 'https://flagcdn.com/w320/us.png',
    name: 'Estados Unidos',
    description: 'Visa de turismo y negocios para Estados Unidos. Asesoría completa para tu trámite.'
  ),
  VisaCountry(
    code: 'ES',
    shortName: 'ESP',
    title: 'Visa Schengen - España',
    pitch: 'Visa Schengen para viajar por España y Europa.',
    emoji: '🇪🇸',
    consularFee: 90,
    serviceFee: 60,
    flagUrl: 'https://flagcdn.com/w320/es.png',
    name: 'España',
    description: 'Visa Schengen para España y países asociados. Incluye formulario y entrevista.'
  ),
  VisaCountry(
    code: 'CN',
    shortName: 'CHN',
    title: 'Visa China',
    pitch: 'Visa de turismo y negocios para China.',
    emoji: '🇨🇳',
    consularFee: 140,
    serviceFee: 55,
    flagUrl: 'https://flagcdn.com/w320/cn.png',
    name: 'China',
    description: 'Tramitamos tu visa para China: turismo, negocios y estudios.'
  ),
  VisaCountry(
    code: 'JP',
    shortName: 'JPN',
    title: 'Visa Japón',
    pitch: 'Visa de corta estancia para Japón.',
    emoji: '🇯🇵',
    consularFee: 30,
    serviceFee: 50,
    flagUrl: 'https://flagcdn.com/w320/jp.png',
    name: 'Japón',
    description: 'Visa de corta estancia para Japón. Incluye guía para entrevista.'
  ),
  VisaCountry(
    code: 'FR',
    shortName: 'FRA',
    title: 'Visa Schengen - Francia',
    pitch: 'Visa Schengen para Francia y Europa.',
    emoji: '🇫🇷',
    consularFee: 90,
    serviceFee: 60,
    flagUrl: 'https://flagcdn.com/w320/fr.png',
    name: 'Francia',
    description: 'Visa Schengen para Francia. Asesoría integral paso a paso.'
  ),
];

class _VisaCountryDetail extends StatelessWidget {
  final VisaCountry country;
  const _VisaCountryDetail({required this.country});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(country.name ?? country.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                country.flagUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover)),
            const SizedBox(height: 16),
            Text(country.description ?? country.pitch, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Formulario en construcción 🚧')));
                },
                child: const Text('Rellenar formulario'))),
          ])));
  }
}



class VisaGridPage extends StatelessWidget {
  const VisaGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visas'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: visaCountries.length,
        itemBuilder: (context, index) {
          final visa = visaCountries[index];
          return Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(visa.emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(
                    visa.name ?? visa.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    visa.description ?? visa.pitch,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}




// ====== Carlitos Travel: Visas (CT) - módulo aislado para evitar conflictos ======
class VisaCountryCT {
  final String code;
  final String name;
  final String title;
  final String imageUrl;
  final String description;
  final int advisoryFee;
  final int consularFee;
  final List<String> requirements;
  final List<String> steps;
  final String? infoUrl;

  const VisaCountryCT({
    required this.code,
    required this.name,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.advisoryFee,
    required this.consularFee,
    required this.requirements,
    required this.steps,
    this.infoUrl,
  });

  String get flagEmoji {
    if (code.length != 2) return '🏳️';
    final base = 0x1F1E6;
    final A = 'A'.codeUnitAt(0);
    final c1 = base + (code[0].toUpperCase().codeUnitAt(0) - A);
    final c2 = base + (code[1].toUpperCase().codeUnitAt(0) - A);
    return String.fromCharCode(c1) + String.fromCharCode(c2);
  }
}

const List<VisaCountryCT> _visaCatalogCT = [
  VisaCountryCT(
    code: 'US',
    name: 'Estados Unidos',
    title: 'Visa Americana',
    imageUrl: 'https://flagcdn.com/w1280/us.png',
    description: 'Asesoría B1/B2: DS-160, pago y cita.',
    advisoryFee: 120,
    consularFee: 185,
    requirements: [
      'Pasaporte vigente (6+ meses).',
      'Soportes económicos y vínculos.',
      'Historial de viajes (si aplica).',
    ],
    steps: [
      'Evaluación de perfil.',
      'Diligenciamiento DS-160.',
      'Pago y programación de cita.',
      'Preparación de entrevista.',
    ],
    infoUrl: 'https://ceac.state.gov/',
  ),
  VisaCountryCT(
    code: 'CA',
    name: 'Canadá',
    title: 'Visa Canadiense / eTA',
    imageUrl: 'https://flagcdn.com/w1280/ca.png',
    description: 'Definimos eTA o visa y subimos tu expediente.',
    advisoryFee: 110,
    consularFee: 100,
    requirements: [
      'Pasaporte y fondos.',
      'Carta laboral o de ingresos.',
      'Viajes previos (si aplica).',
    ],
    steps: [
      'Elección de tipo (eTA/visa).',
      'Perfil y carga documental.',
      'Pago y biométricos (si aplica).',
      'Seguimiento a la decisión.',
    ],
    infoUrl: 'https://www.canada.ca/',
  ),
  VisaCountryCT(
    code: 'EU',
    name: 'Espacio Schengen',
    title: 'Visa Schengen',
    imageUrl: 'https://flagcdn.com/w1280/eu.png',
    description: 'Corta estancia (hasta 90 días).',
    advisoryFee: 120,
    consularFee: 90,
    requirements: [
      'Seguro médico mínimo 30.000€.',
      'Itinerario y reservas.',
      'Soportes económicos y laborales.',
    ],
    steps: [
      'Seleccionar consulado competente.',
      'Cita (VFS/BLS) y biometría.',
      'Radicación del expediente.',
      'Retiro de pasaporte.',
    ],
    infoUrl: 'https://home-affairs.ec.europa.eu/',
  ),
  VisaCountryCT(
    code: 'GB',
    name: 'Reino Unido',
    title: 'Visa Reino Unido',
    imageUrl: 'https://flagcdn.com/w1280/gb.png',
    description: 'Standard Visitor con TLS/UKVCAS.',
    advisoryFee: 125,
    consularFee: 133,
    requirements: [
      'Pasaporte y fotos.',
      'Fondos y respaldos.',
      'Itinerario.',
    ],
    steps: [
      'Formulario online.',
      'Pago y biométricos.',
      'Carga documental.',
      'Decisión.',
    ],
    infoUrl: 'https://www.gov.uk/standard-visitor',
  ),
  VisaCountryCT(
    code: 'JP',
    name: 'Japón',
    title: 'Visa Japonesa',
    imageUrl: 'https://flagcdn.com/w1280/jp.png',
    description: 'Turismo o visita. Tasas variables.',
    advisoryFee: 115,
    consularFee: 0,
    requirements: [
      'Pasaporte vigente.',
      'Itinerario y reservas.',
      'Soportes económicos.',
    ],
    steps: [
      'Definición de tipo de visa.',
      'Preparación de anexos.',
      'Radicación y seguimiento.',
    ],
    infoUrl: 'https://www.mofa.go.jp/',
  ),
];

class VisaListPageCT extends StatelessWidget {
  const VisaListPageCT({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cross = w >= 1100 ? 4 : (w >= 750 ? 3 : 2);
    return Scaffold(
      appBar: AppBar(title: const Text('Visas'), centerTitle: true),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cross,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemCount: _visaCatalogCT.length,
        itemBuilder: (_, i) => _VisaCardCT(country: _visaCatalogCT[i]),
      ),
    );
  }
}

class _VisaCardCT extends StatelessWidget {
  final VisaCountryCT country;
  const _VisaCardCT({required this.country});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => VisaDetailPageCT(country: country)),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16/9,
              child: Image.network(
                country.imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black12),
                loadingBuilder: (c, child, p) => p == null ? child : const Center(child: CircularProgressIndicator()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Text(
                '${country.title} ${country.flagEmoji}',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(country.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Asesoría: \$${country.advisoryFee} • Consular: \$${country.consularFee}',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VisaDetailPageCT extends StatelessWidget {
  final VisaCountryCT country;
  const VisaDetailPageCT({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(country.title), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16/9,
              child: Image.network(
                country.imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${country.title} • ${country.name} ${country.flagEmoji}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(country.description),
          const SizedBox(height: 16),
          _InfoTileCT(
            icon: Icons.attach_money_rounded,
            title: 'Costos',
            subtitle: 'Asesoría: \$${country.advisoryFee} • Tasa consular: \$${country.consularFee}\n'
                      'Nota: Puede variar según tipo de trámite y tasa del día.',
          ),
          const SizedBox(height: 12),
          _InfoTileCT(
            icon: Icons.rule_folder_outlined,
            title: 'Requisitos principales',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: country.requirements.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(e)),
                  ],
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _InfoTileCT(
            icon: Icons.timeline_rounded,
            title: 'Cómo es el proceso',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < country.steps.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12, backgroundColor: cs.primaryContainer,
                          child: Text('${i + 1}', style: const TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(country.steps[i])),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Rellenar formulario'),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Aquí enlazaremos tu formulario real.')),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (country.infoUrl != null)
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Sitio oficial'),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Enlace'),
                        content: Text(country.infoUrl!),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('¿Dudas? Te acompañamos de principio a fin.',
              style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _InfoTileCT extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? child;
  const _InfoTileCT({required this.icon, required this.title, this.subtitle, this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(subtitle!.replaceAll('\\n', '\n')),
                ],
                if (child != null) ...[
                  const SizedBox(height: 8),
                  child!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}





class Visas2Page extends StatelessWidget {
  const Visas2Page({super.key});

  @override
  Widget build(BuildContext context) {
    final visas = _visa2Cards;
    return Scaffold(
      appBar: AppBar(title: const Text('Visas')),
      body: LayoutBuilder(
        builder: (context, c) {
          final cross = c.maxWidth > 1100 ? 4 : c.maxWidth > 800 ? 3 : c.maxWidth > 550 ? 2 : 1;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 3/2,
            ),
            itemCount: visas.length,
            itemBuilder: (context, i) {
              final v = visas[i];
              return InkWell(
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => Visas2DetailPage(country: v))
                ),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(v.imageUrl, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v.displayTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Tasa consular: ${v.feeLabel}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Visas2DetailPage extends StatelessWidget {
  final _Visa2Card country;
  const Visas2DetailPage({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(country.displayTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Image.network(country.imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            Text(country.displayTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Tasa consular actual: ${country.feeLabel}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            const Text(
              '¿Qué hacemos por ti?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Somos una agencia que te acompaña en todo el proceso: diligenciamos el formulario, hacemos asesoría personalizada, pre-entrevista y coaching para mejorar tu perfil, '
              'y te guiamos para aumentar las probabilidades de aprobación.',
            ),
            const SizedBox(height: 16),
            const Text('Incluye:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text('• Revisión de documentos\n• Diligenciamiento de formularios\n• Preparación para entrevista (si aplica)\n• Soporte por WhatsApp/Email\n• Agendamiento de citas (si aplica)'),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blueGrey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pago de ejemplo (Colombia)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Asesoría Carlitos Travel'), const Text('COP \$3.000.000'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tasa consular'), Text(country.feeLabel),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total estimado', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(_totalConFee(country.feeCOP ?? 0)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit_note),
                label: const Text('Rellenar formulario'),
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => Visas2FormPage(country: country))
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('Fuente de la tasa consular: ${country.feeSourceTitle}',
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  String _totalConFee(int feeCOP) {
    final total = 3000000 + feeCOP;
    final s = total.toString();
    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return 'COP \$' + s.replaceAllMapped(regex, (m) => '${m[1]}.'); // puntos como separador
  }
}




/// clase contactenos///
class ContactenosPage extends StatefulWidget {
  const ContactenosPage({super.key});

  @override
  State<ContactenosPage> createState() => _ContactenosPageState();
}

class _ContactenosPageState extends State<ContactenosPage> {
  late List<VideoPlayerController> _controllers;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      6,
      (index) => VideoPlayerController.asset(
        'assets/contactenos/contactenos_v0${index + 1}.mp4',
      )..initialize().then((_) => setState(() {})),
    );

    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _showFullScreenVideo(VideoPlayerController controller) {
    final chewieController = ChewieController(
      videoPlayerController: controller,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowPlaybackSpeedChanging: true,
      showControls: true,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Center(child: Chewie(controller: chewieController)),
                Positioned(
                  top: 20,
                  left: 15,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () {
                      chewieController.pause();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) => chewieController.dispose());
  }

  Widget _buildVideo(VideoPlayerController controller) {
    return GestureDetector(
      onDoubleTap: () => _showFullScreenVideo(controller),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              AspectRatio(
                aspectRatio: controller.value.isInitialized
                    ? controller.value.aspectRatio
                    : 16 / 9,
                child: controller.value.isInitialized
                    ? VideoPlayer(controller)
                    : const Center(child: CircularProgressIndicator()),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    setState(() {
                      controller.value.isPlaying
                          ? controller.pause()
                          : controller.play();
                    });
                  },
                  child: Icon(
                    controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: const Color(0xFF6A4CAF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Conéctate con nosotros',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF6A4CAF),
        elevation: 3,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de encabezado
            Container(
              height: 220,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/contactenos/contactenos_01.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Introducción narrativa
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: const Text(
                'En Carlitos Travel creemos que cada viaje comienza con una buena conversación. '
                'Por eso, estamos siempre listos para escucharte, responder tus preguntas y ayudarte '
                'a planear la próxima aventura con la atención personalizada que nos caracteriza.',
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 17, color: Colors.black87, height: 1.5),
              ),
            ),

            // Información de contacto
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A4CAF), Color(0xFF9575CD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '📧 Correo',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    SelectableText(
                      'cftovar@utp.edu.co',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '📱 Celular',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    SelectableText(
                      '+57 314 768 7328',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Carrusel de videos (testimonios reales)
            const Padding(
              padding: EdgeInsets.only(left: 18.0, bottom: 10),
              child: Text(
                'Testimonios reales',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A4CAF),
                ),
              ),
            ),

            SizedBox(
              height: 280,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _controllers.length,
                itemBuilder: (context, index) {
                  final controller = _controllers[index];
                  if (controller.value.isInitialized) {
                    return _buildVideo(controller);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class Visas2FormPage extends StatelessWidget {
  final _Visa2Card country;
  const Visas2FormPage({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    final fields = country.formFields;
    return Scaffold(
      appBar: AppBar(title: Text('Formulario – ${country.shortTitle}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Datos requeridos (${country.shortTitle})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...fields.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              decoration: InputDecoration(
                labelText: f,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.payment),
            label: const Text('Pagar (ejemplo)'),
            onPressed: () {
              showDialog(context: context, builder: (_) => AlertDialog(
                title: const Text('Pago de ejemplo'),
                content: Text('Se cobrarán COP \$3.000.000 + tasa consular (${country.feeLabel}).'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
                ],
              ));
            },
          )
        ],
      ),
    );
  }
}

// ---- DATA for Visas2Page ----

class _Visa2Card {
  final String code;
  final String shortTitle;
  final String displayTitle;
  final String imageUrl;
  final String feeLabel;
  final int? feeCOP;
  final String feeSourceTitle;
  final List<String> formFields;

  const _Visa2Card({
    required this.code,
    required this.shortTitle,
    required this.displayTitle,
    required this.imageUrl,
    required this.feeLabel,
    required this.feeSourceTitle,
    required this.formFields,
    this.feeCOP,
  });
}

final List<_Visa2Card> _visa2Cards = [
  _Visa2Card(
    code: 'US',
    shortTitle: 'Visa Americana',
    displayTitle: 'Visa Americana (B1/B2)',
    imageUrl: 'https://flagcdn.com/w1280/us.png',
    feeLabel: 'USD \$185 (MRV)',
    feeSourceTitle: 'travel.state.gov – Fees for Visa Services (B1/B2)',
    feeCOP: 185 * 4200,
    formFields: [
      'Nombre completo (como en el pasaporte)',
      'Número de pasaporte',
      'Fecha de emisión y vencimiento del pasaporte',
      'Estado civil',
      'Dirección y teléfono en Colombia',
      'Itinerario/propósito del viaje',
      'Empleo actual (empresa, cargo, salario)',
      'Historial laboral y educativo',
      'Ingresos mensuales',
      'Contacto/host en EE. UU. (si aplica)',
      'Historial de viajes a EE. UU. y otros países',
    ],
  ),
  _Visa2Card(
    code: 'UK',
    shortTitle: 'Visa Reino Unido',
    displayTitle: 'Visa de Visitante (UK)',
    imageUrl: 'https://flagcdn.com/w1280/gb.png',
    feeLabel: 'GBP £127 (hasta 6 meses)',
    feeSourceTitle: 'gov.uk – Fees 1 July 2025',
    feeCOP: 127 * 5400,
    formFields: [
      'Datos personales y pasaporte',
      'Fechas de viaje y alojamiento',
      'Fondos disponibles y ocupación',
      'Historial de viajes',
      'Datos de acompañantes (si aplica)',
      'Itinerario y propósito de visita',
      'Dirección en UK durante la estancia',
    ],
  ),
  _Visa2Card(
    code: 'JP',
    shortTitle: 'Visa Japonesa',
    displayTitle: 'Visa de corta estancia (Japón)',
    imageUrl: 'https://flagcdn.com/w1280/jp.png',
    feeLabel: 'USD \$20 (entrada simple)*',
    feeSourceTitle: 'MOFA Japan (tarifas & online payment)',
    feeCOP: 20 * 4200,
    formFields: [
      'Datos personales y pasaporte',
      'Itinerario en Japón (fechas, ciudades)',
      'Prueba de fondos/empleo',
      'Carta de invitación/garante (si aplica)',
      'Reservas (hotel/vuelos) o plan de viaje',
    ],
  ),
  _Visa2Card(
    code: 'CN',
    shortTitle: 'Visa China',
    displayTitle: 'Visa de turista (L) – China',
    imageUrl: 'https://flagcdn.com/w1280/cn.png',
    feeLabel: '≈ COP \$311.000 (entrada simple)*',
    feeSourceTitle: 'Embajada de China en Colombia (referencias)',
    feeCOP: 311000,
    formFields: [
      'Datos personales y pasaporte',
      'Formulario COVA e impresión de confirmación',
      'Itinerario en China (ciudades y fechas)',
      'Reserva de vuelos y hotel (o carta invitación)',
      'Historial de viajes y ocupación',
      'Dirección domiciliar y contacto',
    ],
  ),
  _Visa2Card(
    code: 'AU',
    shortTitle: 'Visa Australiana',
    displayTitle: 'Visitor visa (subclass 600) – Australia',
    imageUrl: 'https://flagcdn.com/w1280/au.png',
    feeLabel: 'AUD \$200 (offshore)*',
    feeSourceTitle: 'homeaffairs.gov.au (Visitor 600)',
    feeCOP: 200 * 2700,
    formFields: [
      'Datos personales y pasaporte',
      'Itinerario y propósito de visita',
      'Fondos/soporte financiero',
      'Historial de viajes y salud',
      'Dirección de estancia y contacto en Australia',
    ],
  ),
];




// 🌐 ===================================================
// 🌐 SERVICIO API
// 🌐 ===================================================
class ApiService {
  /// Base URL configurable por entorno:
  /// - iOS Simulator: http://localhost:8000
  /// - Android Emulator: http://10.0.2.2:8000
  /// - iPhone físico (misma Wi‑Fi): http://<IP_DE_TU_MAC>:8000
  ///
  /// Ejemplos:
  /// flutter run --dart-define=API_BASE_URL=http://localhost:8000
  /// flutter run --dart-define=API_BASE_URL=http://192.168.1.41:8000
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (fromEnv.trim().isNotEmpty) return fromEnv.trim();

    // Defaults inteligentes (sin tocar código cada vez)
    if (kIsWeb) return 'http://localhost:8000';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      case TargetPlatform.iOS:
        return 'http://localhost:8000'; // iOS Simulator
      default:
        return 'http://localhost:8000';
    }
  }

  static Future<int?> registrarAsesoria(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/asesoria');
    http.Response response;
    try {
      response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
      ).timeout(const Duration(seconds: 20));
    } on TimeoutException {
      debugPrint('⏱️ Timeout llamando $url');
      return null;
    } on Exception catch (e) {
      debugPrint('❌ Error de red llamando $url: $e');
      return null;
    }

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['id'];
    } else {
      print("❌ Error al registrar asesoría (${response.statusCode})");
      return null;
    }
  }

  static Future<bool> confirmarHorario(int idAsesoria, String fechaHora) async {
    final url = Uri.parse('$baseUrl/api/asesoria/confirmar');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': idAsesoria, 'fecha_horario': fechaHora}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['error'] == null;
    }

    print("❌ Error HTTP ${response.statusCode} al confirmar horario");
    return false;
  }

  static Future<Set<String>> obtenerHorariosOcupados() async {
    final url = Uri.parse('$baseUrl/api/horarios-ocupados');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('ocupados')) {
          return data['ocupados'].map<String>((e) => e.toString()).toSet();
        }
      }
      return {};
    } catch (e) {
      print("❌ Error API horarios: $e");
      return {};
    }
  }
}



// 🧩 ===================================================
// 🧩 FORMULARIO DE ASESORÍAS
// 🧩 ===================================================
class AsesoriaFormPage extends StatefulWidget {
  const AsesoriaFormPage({super.key});

  @override
  State<AsesoriaFormPage> createState() => _AsesoriaFormPageState();
}

class _AsesoriaFormPageState extends State<AsesoriaFormPage>
    with WidgetsBindingObserver {

  // 🔗 Canal nativo
  static const MethodChannel _deepLinkChannel =
      MethodChannel('carlitostravel/deeplink');

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _sexo;
  String? _pais;
  String? _ciudad;

  int? _idAsesoria;
  bool _procesandoPago = false;

  final RegExp _emailRegex =
      RegExp(r'^[\w\.-]+@[a-zA-Z\d\.-]+\.[a-zA-Z]{2,}$');

  final Map<String, List<String>> _paisesYciudades = {
    'Colombia': [
      'Bogotá','Medellín','Cali','Barranquilla','Cartagena','Pereira',
      'Bucaramanga','Manizales','Cúcuta','Ibagué','Santa Marta','Armenia',
      'Villavicencio','Montería','Neiva','Sincelejo','Popayán','Tunja',
      'Pasto','Palmira'
    ],
    'España': [
      'Madrid','Barcelona','Valencia','Sevilla','Zaragoza','Málaga','Murcia',
      'Palma de Mallorca','Bilbao','Granada','Valladolid','Córdoba',
      'Alicante','San Sebastián','Salamanca','Toledo','Oviedo'
    ],
    'México': [
      'Ciudad de México','Guadalajara','Monterrey','Puebla','Tijuana',
      'Cancún','Mérida','Querétaro'
    ],
    'Estados Unidos': [
      'Miami','Nueva York','Los Ángeles','Chicago','Houston','Dallas',
      'Orlando','San Francisco','Las Vegas'
    ],
    'Argentina': [
      'Buenos Aires','Córdoba','Rosario','Mendoza','La Plata','Salta'
    ],
    'Chile': [
      'Santiago','Valparaíso','Viña del Mar','Concepción','Antofagasta'
    ],
    'Perú': ['Lima','Cusco','Arequipa','Trujillo','Piura']
  };

  List<String> _ciudadesDisponibles = [];

  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Listener de uni_links
    _sub = uriLinkStream.listen(
      (Uri? uri) {
        debugPrint("📥 RAW URI RECIBIDO (uni_links): $uri");
        if (!mounted || uri == null) return;
        _procesarDeepLink(uri);
      },
      onError: (err) => debugPrint("❌ Error en uriLinkStream: $err"),
    );

    // Listener nativo Android
    _deepLinkChannel.setMethodCallHandler((call) async {
      if (call.method == 'onDeepLink') {
        final String? raw = call.arguments as String?;
        debugPrint("📥 RAW DEEPLINK ANDROID: $raw");
        if (raw == null || raw.isEmpty) return;

        try {
          _procesarDeepLink(Uri.parse(raw));
        } catch (e) {
          debugPrint("❌ Error parseando deeplink Android: $e");
        }
      }
    });
  }


  // ✔ FUNCIÓN CORREGIDA
  void _procesarDeepLink(Uri uri) {
    debugPrint("🔗 URI PROCESADO: $uri");

    if (uri.scheme != "carlitostravel") return;

    // 1) Algunos redirects incluyen 'status', otros SOLO incluyen 'id' (transaction id).
    String status = (uri.queryParameters["status"] ??
            uri.queryParameters["transactionStatus"] ??
            uri.queryParameters["transaction_status"] ??
            "")
        .trim()
        .toUpperCase();

    final transactionId = (uri.queryParameters["id"] ??
            uri.queryParameters["transactionId"] ??
            uri.queryParameters["transaction_id"] ??
            "")
        .trim();

    debugPrint("🔎 STATUS RECIBIDO: '$status'");
    debugPrint("🧾 TRANSACTION ID RECIBIDO: '$transactionId'");

    if (_idAsesoria == null) return;

    // 2) Si no viene status (muy común en Wompi), consultamos a Wompi por el ID de transacción.
    if (status.isEmpty && transactionId.isNotEmpty) {
      _verificarPagoWompiYContinuar(transactionId);
      return;
    }

    // 3) Si viene status, actuamos con él.
    if (status.isEmpty) status = "FAILED";

    if (status == "APPROVED") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SeleccionHorarioPage(idAsesoria: _idAsesoria!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pago fallido o cancelado ($status)")),
      );
    }
  }

  /// Consulta el estado real de la transacción en Wompi usando el transactionId,
  /// y si queda APPROVED, continúa al agendamiento.
  ///
  /// Docs: Wompi recomienda validar por API usando GET /v1/transactions/<ID>. 
  /// Base URL Prod: https://production.wompi.co/v1 citeturn2search0
  Future<void> _verificarPagoWompiYContinuar(String transactionId) async {
    if (_procesandoPago) return;

    setState(() => _procesandoPago = true);

    final wompiUrl = Uri.parse("https://production.wompi.co/v1/transactions/$transactionId");

    try {
      // Wompi puede tardar unos segundos en reflejar estado final (PENDING -> APPROVED/DECLINED/etc.)
      // Hacemos polling corto.
      const maxIntentos = 10;
      const espera = Duration(seconds: 2);

      String? status;
      for (var i = 0; i < maxIntentos; i++) {
        final resp = await http.get(wompiUrl).timeout(const Duration(seconds: 15));

        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          final jsonBody = jsonDecode(resp.body) as Map<String, dynamic>;
          final data = (jsonBody["data"] ?? {}) as Map<String, dynamic>;
          status = (data["status"] ?? "").toString().trim().toUpperCase();
          debugPrint("📡 Wompi status (intento ${i + 1}/$maxIntentos): $status");

          // Estados finales típicos: APPROVED / DECLINED / VOIDED / ERROR (tarjeta),
          // y en algunos flujos: FAILED / REJECTED / CANCELLED. citeturn0search7turn0search2
          if (status == "APPROVED") break;
          if (status == "DECLINED" ||
              status == "VOIDED" ||
              status == "ERROR" ||
              status == "FAILED" ||
              status == "REJECTED" ||
              status == "CANCELLED") {
            break;
          }
        } else {
          debugPrint("❌ Error consultando Wompi: ${resp.statusCode} ${resp.body}");
          // Si Wompi responde error, no seguimos insistiendo demasiado.
          break;
        }

        await Future.delayed(espera);
      }

      if (!mounted) return;

      if (status == "APPROVED") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SeleccionHorarioPage(idAsesoria: _idAsesoria!),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pago no confirmado en Wompi (${status ?? "DESCONOCIDO"})")),
        );
      }
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⏱️ Timeout verificando pago en Wompi")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error verificando pago: $e")),
      );
    } finally {
      if (mounted) setState(() => _procesandoPago = false);
    }
  }



  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    super.dispose();
  }


  // 🔗 Abrir link de pago
  Future<void> _abrirWompiPago() async {
    final url = Uri.parse(
      "https://checkout.wompi.co/l/YIKgAf?redirectUrl=https://carlitostravelfly-art.github.io/wompi-redirect/redirect.html",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }


  // 📤 Enviar formulario
  Future<void> _enviarFormulario() async {
    if (_procesandoPago) return;

    if (_formKey.currentState!.validate()) {
      setState(() => _procesandoPago = true);

      final data = {
        'nombre': _nameController.text.trim(),
        'correo': _emailController.text.trim(),
        'telefono': _phoneController.text.trim(),
        'pais': _pais ?? '',
        'ciudad': _ciudad ?? '',
        'sexo': _sexo ?? '',
      };

      final id = await ApiService.registrarAsesoria(data);

      if (id != null) {
        _idAsesoria = id;
        await _abrirWompiPago();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error guardando asesoría")),
        );
      }

      setState(() => _procesandoPago = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Asesoría personalizada"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("💰 Costo asesoría: \$100.000 COP"),

              SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Nombre completo",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Ingresa tu nombre" : null,
              ),

              SizedBox(height: 15),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Correo",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Ingresa tu correo";
                  if (!_emailRegex.hasMatch(v)) return "Correo inválido";
                  return null;
                },
              ),

              SizedBox(height: 15),

              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Teléfono",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Ingresa tu teléfono" : null,
              ),

              SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _pais,
                decoration: InputDecoration(border: OutlineInputBorder()),
                items: _paisesYciudades.keys
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _pais = v;
                    _ciudad = null;
                    _ciudadesDisponibles = _paisesYciudades[v] ?? [];
                  });
                },
                validator: (v) => v == null ? "Selecciona un país" : null,
              ),

              SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _ciudad,
                decoration: InputDecoration(border: OutlineInputBorder()),
                items: _ciudadesDisponibles
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _ciudad = v),
                validator: (v) => v == null ? "Selecciona una ciudad" : null,
              ),

              SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _sexo,
                decoration: InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: "Masculino", child: Text("Masculino")),
                  DropdownMenuItem(value: "Femenino", child: Text("Femenino")),
                  DropdownMenuItem(value: "Otro", child: Text("Otro")),
                ],
                onChanged: (v) => setState(() => _sexo = v),
                validator: (v) => v == null ? "Selecciona una opción" : null,
              ),

              SizedBox(height: 25),

              ElevatedButton.icon(
                onPressed: _procesandoPago ? null : _enviarFormulario,
                icon: Icon(Icons.payment),
                label: Text(_procesandoPago ? "Procesando…" : "Pagar asesoría"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}



// 🗓️ ===================================================
// 🗓️ SELECCIÓN DE HORARIO
// 🗓️ ===================================================
class SeleccionHorarioPage extends StatefulWidget {
  final int idAsesoria;
  const SeleccionHorarioPage({super.key, required this.idAsesoria});

  @override
  State<SeleccionHorarioPage> createState() =>
      _SeleccionHorarioPageState();
}

class _SeleccionHorarioPageState extends State<SeleccionHorarioPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _horaSeleccionada;

  bool _cargando = false;
  Set<String> _horasOcupadas = {};

  final List<String> _horasDisponibles = [
    "09:00","10:00","11:00","12:00",
    "13:00","14:00","15:00","16:00","17:00"
  ];

  bool _esDiaHabil(DateTime d) =>
      d.weekday >= 1 && d.weekday <= 5;


  @override
  void initState() {
    super.initState();
    _cargarHorarios();
  }


  Future<void> _cargarHorarios() async {
    setState(() => _cargando = true);
    _horasOcupadas = await ApiService.obtenerHorariosOcupados();
    setState(() => _cargando = false);
  }


  Future<void> _confirmarHorario() async {
    if (_selectedDay == null || _horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecciona fecha y hora")),
      );
      return;
    }

    final partes = _horaSeleccionada!.split(":");
    final fecha = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      int.parse(partes[0]),
      int.parse(partes[1]),
    );

    final clave = DateFormat('yyyy-MM-dd HH:mm').format(fecha);

    if (_horasOcupadas.contains(clave)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hora ocupada")),
      );
      return;
    }

    final ok =
        await ApiService.confirmarHorario(widget.idAsesoria, clave);

    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FinalizacionAsesoriaPage(),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seleccionar horario"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _cargando
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "Selecciona un día hábil",
                    style: TextStyle(fontSize: 16),
                  ),

                  SizedBox(height: 10),

                  TableCalendar(
                    locale: "es_ES",
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(Duration(days: 30)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (d) =>
                        isSameDay(_selectedDay, d),
                    enabledDayPredicate: _esDiaHabil,
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      });
                    },
                  ),

                  SizedBox(height: 20),

                  if (_selectedDay != null) ...[
                    Text("Selecciona una hora"),

                    SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      children: _horasDisponibles.map((hora) {
                        final clave =
                            "${DateFormat('yyyy-MM-dd').format(_selectedDay!)} $hora";

                        final ocupado =
                            _horasOcupadas.contains(clave);
                        final seleccionado =
                            _horaSeleccionada == hora;

                        return ChoiceChip(
                          label: Text(hora),
                          selected: seleccionado,
                          selectedColor: Colors.green,
                          backgroundColor:
                              ocupado ? Colors.red.shade300 : null,
                          onSelected: ocupado
                              ? null
                              : (_) {
                                  setState(() =>
                                      _horaSeleccionada = hora);
                                },
                        );
                      }).toList(),
                    ),
                  ],

                  SizedBox(height: 30),

                  ElevatedButton.icon(
                    onPressed: _confirmarHorario,
                    icon: Icon(Icons.check_circle),
                    label: Text("Confirmar horario"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}



// 🎉 ===================================================
// 🎉 FINALIZACIÓN
// 🎉 ===================================================
class FinalizacionAsesoriaPage extends StatelessWidget {
  const FinalizacionAsesoriaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Asesoría agendada"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 120, color: Colors.green),
            SizedBox(height: 20),
            Text(
              "¡Tu asesoría ha sido agendada exitosamente!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              "Recibirás confirmación por correo.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
