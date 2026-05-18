import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalBazaaroDatabase {
  LocalBazaaroDatabase({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  Database? _db;
  Map<String, List<Map<String, Object?>>>? _webRecords;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = p.join(await getDatabasesPath(), 'bazaaro_catalog_v1.db');
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE catalog_records(
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            payload TEXT NOT NULL
          )
        ''');
      },
    );
    await _seedIfNeeded(_db!);
    return _db!;
  }

  Future<List<Map<String, Object?>>> records(String type) async {
    if (kIsWeb) {
      await _seedWebIfNeeded();
      return _webRecords![type] ?? const [];
    }
    final db = await database;
    return db.query('catalog_records', where: 'type = ?', whereArgs: [type]);
  }

  /// Replace all records for a given [type] with [payloads].
  /// [payloads] must each contain an `id` key.
  Future<void> replaceTypeRecords(
    String type,
    List<Map<String, Object?>> payloads,
  ) async {
    if (kIsWeb) {
      await _seedWebIfNeeded();
      _webRecords![type] = payloads
          .map((payload) => {'payload': jsonEncode(payload)})
          .toList(growable: false);
      return;
    }

    final db = await database;
    final batch = db.batch();
    batch.delete('catalog_records', where: 'type = ?', whereArgs: [type]);
    for (final payload in payloads) {
      batch.insert('catalog_records', {
        'id': payload['id'] as String,
        'type': type,
        'payload': jsonEncode(payload),
      });
    }
    await batch.commit(noResult: true);
  }

  Future<void> _seedWebIfNeeded() async {
    if (_webRecords != null) return;
    final raw = await _bundle.loadString(
      'assets/data/bazaaro_catalog_seed.json',
    );
    final json = jsonDecode(raw) as Map<String, Object?>;
    Map<String, Object?> wrap(Map<String, Object?> payload) {
      return {'payload': jsonEncode(payload)};
    }

    _webRecords = {
      'category': (json['categories'] as List)
          .cast<Map<String, Object?>>()
          .map(wrap)
          .toList(),
      'banner': (json['banners'] as List)
          .cast<Map<String, Object?>>()
          .map(wrap)
          .toList(),
      'product': [
        ...(json['products'] as List).cast<Map<String, Object?>>(),
        ..._extraProducts,
      ].map(wrap).toList(),
    };
  }

  Future<void> _seedIfNeeded(Database db) async {
    final count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM catalog_records'),
        ) ??
        0;
    if (count > 0) return;

    final raw = await _bundle.loadString(
      'assets/data/bazaaro_catalog_seed.json',
    );
    final json = jsonDecode(raw) as Map<String, Object?>;

    final categories = (json['categories'] as List)
        .cast<Map<String, Object?>>();
    final banners = (json['banners'] as List).cast<Map<String, Object?>>();
    final products = [
      ...(json['products'] as List).cast<Map<String, Object?>>(),
      ..._extraProducts,
    ];

    // Initial seed = replaceTypeRecords per type (simpler & keeps code consistent).
    await replaceTypeRecords('category', categories.toList());
    await replaceTypeRecords('banner', banners.toList());
    await replaceTypeRecords('product', products.toList());
  }
}

const _extraProducts = <Map<String, Object?>>[
  {
    'id': 'cotton-bath-towels',
    'title': 'Cotton Bath Towels Pack',
    'slug': 'cotton-bath-towels-pack',
    'description': 'Soft absorbent towels for daily home use.',
    'shortDescription': 'Soft absorbent towel pack.',
    'categoryId': 'home-kitchen',
    'categoryName': 'Home & Kitchen',
    'brandId': 'home-soft',
    'brandName': 'Home Soft',
    'images': [
      'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=1000',
    ],
    'price': 699,
    'mrp': 1299,
    'discountPercent': 46,
    'taxPercent': 18,
    'sku': 'BZ-TOWELS',
    'stock': 80,
    'status': 'active',
    'sellerId': 'seller-bazaaro-select',
    'ratingAvg': 4.2,
    'ratingCount': 650,
    'totalSold': 2810,
    'isFeatured': true,
    'isTrending': false,
  },
  {
    'id': 'wireless-keyboard-mouse',
    'title': 'Wireless Keyboard and Mouse',
    'slug': 'wireless-keyboard-and-mouse',
    'description': 'Silent keys, compact mouse, and long battery life.',
    'shortDescription': 'Daily work desk combo.',
    'categoryId': 'electronics',
    'categoryName': 'Electronics',
    'brandId': 'logitech',
    'brandName': 'Logitech',
    'images': [
      'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=1000',
    ],
    'price': 1199,
    'mrp': 2295,
    'discountPercent': 48,
    'taxPercent': 18,
    'sku': 'BZ-KEYMOUSE',
    'stock': 70,
    'status': 'active',
    'sellerId': 'seller-bazaaro-select',
    'ratingAvg': 4.4,
    'ratingCount': 920,
    'totalSold': 4210,
    'isFeatured': true,
    'isTrending': true,
  },
  {
    'id': 'daily-coffee-mug',
    'title': 'Ceramic Coffee Mug',
    'slug': 'ceramic-coffee-mug',
    'description': 'Minimal ceramic mug for tea, coffee, and desk rituals.',
    'shortDescription': 'Clean ceramic mug.',
    'categoryId': 'home-kitchen',
    'categoryName': 'Home & Kitchen',
    'brandId': 'clay-studio',
    'brandName': 'Clay Studio',
    'images': [
      'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?w=1000',
    ],
    'price': 299,
    'mrp': 599,
    'discountPercent': 50,
    'taxPercent': 18,
    'sku': 'BZ-MUG',
    'stock': 150,
    'status': 'active',
    'sellerId': 'seller-bazaaro-select',
    'ratingAvg': 4.3,
    'ratingCount': 410,
    'totalSold': 1980,
    'isFeatured': false,
    'isTrending': true,
  },
  {
    'id': 'formal-office-shirt',
    'title': 'Formal Office Shirt',
    'slug': 'formal-office-shirt',
    'description': 'Crisp cotton blend shirt for office and events.',
    'shortDescription': 'Crisp work shirt.',
    'categoryId': 'fashion',
    'categoryName': 'Fashion',
    'brandId': 'allen-solly',
    'brandName': 'Allen Solly',
    'images': [
      'https://images.unsplash.com/photo-1603252109303-2751441dd157?w=1000',
    ],
    'price': 999,
    'mrp': 1999,
    'discountPercent': 50,
    'taxPercent': 12,
    'sku': 'BZ-SHIRT',
    'stock': 60,
    'status': 'active',
    'sellerId': 'seller-bazaaro-select',
    'ratingAvg': 4.1,
    'ratingCount': 550,
    'totalSold': 1720,
    'isFeatured': true,
    'isTrending': false,
  },
  {
    'id': 'daily-moisturizer',
    'title': 'Daily Face Moisturizer',
    'slug': 'daily-face-moisturizer',
    'description': 'Light gel moisturizer for everyday hydration.',
    'shortDescription': 'Light everyday hydration.',
    'categoryId': 'beauty',
    'categoryName': 'Beauty',
    'brandId': 'plum',
    'brandName': 'Plum',
    'images': [
      'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=1000',
    ],
    'price': 399,
    'mrp': 699,
    'discountPercent': 43,
    'taxPercent': 18,
    'sku': 'BZ-MOIST',
    'stock': 190,
    'status': 'active',
    'sellerId': 'seller-bazaaro-select',
    'ratingAvg': 4.2,
    'ratingCount': 830,
    'totalSold': 5120,
    'isFeatured': false,
    'isTrending': true,
  },
  {
    'id': 'breakfast-cereal',
    'title': 'Healthy Breakfast Cereal',
    'slug': 'healthy-breakfast-cereal',
    'description': 'Crunchy multigrain cereal with nuts and seeds.',
    'shortDescription': 'Crunchy multigrain cereal.',
    'categoryId': 'grocery',
    'categoryName': 'Grocery',
    'brandId': 'soulfull',
    'brandName': 'Soulfull',
    'images': [
      'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?w=1000',
    ],
    'price': 329,
    'mrp': 499,
    'discountPercent': 34,
    'taxPercent': 5,
    'sku': 'BZ-CEREAL',
    'stock': 230,
    'status': 'active',
    'sellerId': 'seller-bazaaro-select',
    'ratingAvg': 4.3,
    'ratingCount': 740,
    'totalSold': 3880,
    'isFeatured': true,
    'isTrending': false,
  },
];
