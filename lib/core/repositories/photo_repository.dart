import '../models/photo_model.dart';
import '../services/database_service.dart';

class PhotoRepository {
  final DatabaseService _databaseService;

  PhotoRepository(this._databaseService);

  Future<void> savePhoto(PhotoMetadata photo) async {
    await _databaseService.insertPhoto(photo);
  }

  Future<List<PhotoMetadata>> getAllPhotos() async {
    return await _databaseService.getAllPhotos();
  }

  Future<void> deletePhoto(int id) async {
    await _databaseService.deletePhoto(id);
  }
}
