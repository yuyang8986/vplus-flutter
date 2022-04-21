class Carousel {
  int carouselId;
  String imageUrl;
  Carousel(
      {this.carouselId,
      this.imageUrl,
        });

  Carousel.fromJson(Map<String, dynamic> json) {
    carouselId = json['carouselId'];
    imageUrl = json['imageUrl'];
  }
}
