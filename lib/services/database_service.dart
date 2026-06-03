// lib/services/database_service.dart
//
// DATABASE SERVICE — MongoDB Atlas CRUD Manager
// ─────────────────────────────────────────────
// Manages database connection state and handles all CRUD operations
// on the MongoDB collection. Auto-seeds mock data if the collection is empty.

import 'package:mongo_dart/mongo_dart.dart';
import '../config.dart';
import '../models/flash_card.dart';
import '../data/mock_cards.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Db? _db;
  DbCollection? _collection;
  bool _isConnected = false;
  String? _connectionError;

  /// Check if the database is currently connected
  bool get isConnected => _isConnected;

  /// Get the last connection error message if any
  String? get connectionError => _connectionError;

  /// Establishes connection to MongoDB Atlas
  Future<bool> connect() async {
    if (_isConnected && _db != null) {
      return true;
    }
    _connectionError = null;

    // Check for unconfigured placeholder connection string
    if (MongoConfig.mongoDbUrl.contains('<username>') ||
        MongoConfig.mongoDbUrl.contains('<password>') ||
        MongoConfig.mongoDbUrl.contains('cluster0.xxxxxxx')) {
      _connectionError =
          'Connection string is not configured. Please edit lib/config.dart with your MongoDB Atlas credentials.';
      _isConnected = false;
      return false;
    }

    try {
      _db = await Db.create(MongoConfig.mongoDbUrl);
      await _db!.open();
      _collection = _db!.collection(MongoConfig.collectionName);
      _isConnected = true;

      // Auto-seed mock cards if database is empty
      await _seedMockData();
      return true;
    } catch (e) {
      _connectionError = 'Database connection failed:\n$e';
      _isConnected = false;
      _db = null;
      _collection = null;
      return false;
    }
  }

  /// Seeds mock data if the collection has zero documents
  Future<void> _seedMockData() async {
    if (_collection == null) return;
    try {
      final count = await _collection!.count();
      if (count == 0) {
        final cardsData = mockCards.map((c) => c.toMap()).toList();
        // Remove individual mock client-side IDs to let Mongo generate ObjectIds
        for (var map in cardsData) {
          map.remove('_id');
        }
        await _collection!.insertMany(cardsData);
      }
    } catch (e) {
      // Log seeding error but don't fail the connection
      print('Database seeding failed: $e');
    }
  }

  /// Fetches all flashcards from MongoDB
  Future<List<FlashCard>> getCards() async {
    final connected = await connect();
    if (!connected || _collection == null) {
      throw Exception(_connectionError ?? 'Database not connected.');
    }

    try {
      final List<Map<String, dynamic>> documents =
          await _collection!.find().toList();
      return documents.map((doc) => FlashCard.fromMap(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch cards from MongoDB: $e');
    }
  }

  /// Inserts a new flashcard into MongoDB
  Future<void> addCard(FlashCard card) async {
    final connected = await connect();
    if (!connected || _collection == null) {
      throw Exception(_connectionError ?? 'Database not connected.');
    }

    try {
      final doc = card.toMap();
      doc.remove('_id'); // Mongo generates the _id automatically
      await _collection!.insertOne(doc);
    } catch (e) {
      throw Exception('Failed to add card: $e');
    }
  }

  /// Updates an existing flashcard in MongoDB
  Future<void> updateCard(FlashCard card) async {
    final connected = await connect();
    if (!connected || _collection == null) {
      throw Exception(_connectionError ?? 'Database not connected.');
    }
    if (card.id == null) {
      throw Exception('Cannot update a card without a valid ID.');
    }

    try {
      final objectId = ObjectId.fromHexString(card.id!);
      final doc = card.toMap();
      doc.remove('_id'); // Protect _id from being modified

      await _collection!.updateOne(
        where.id(objectId),
        modify
            .set('subject', doc['subject'])
            .set('topic', doc['topic'])
            .set('formatType', doc['formatType'])
            .set('content', doc['content']),
      );
    } catch (e) {
      throw Exception('Failed to update card: $e');
    }
  }

  /// Deletes a flashcard from MongoDB by its ID
  Future<void> deleteCard(String id) async {
    final connected = await connect();
    if (!connected || _collection == null) {
      throw Exception(_connectionError ?? 'Database not connected.');
    }

    try {
      final objectId = ObjectId.fromHexString(id);
      await _collection!.deleteOne(where.id(objectId));
    } catch (e) {
      throw Exception('Failed to delete card: $e');
    }
  }

  /// Closes database connection
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
      _collection = null;
      _isConnected = false;
    }
  }
}
