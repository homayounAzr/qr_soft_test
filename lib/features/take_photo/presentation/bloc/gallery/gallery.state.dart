part of 'gallery.bloc.dart';

abstract class GalleryState {}

class GalleryLoading extends GalleryState {}

class GalleryReady extends GalleryState {
  final List<Photo> photos;

  GalleryReady(this.photos);
}
