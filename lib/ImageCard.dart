import 'package:cocktails/Cocktail.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'main.dart';



var box = Hive.box('favourites');


class ImageCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double height;
  final double borderRadius;
  final Map data;

  const ImageCard({
    Key? key,
    required this.data,
    required this.imageUrl,
    required this.title,
    this.height = 200,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        var stat = Hive.box('stats').get('opened', defaultValue: 0);
        stat = stat + 1;
        Hive.box('stats').put('opened', stat);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CocktailDetails(data: data),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl != "example" ? Hero(
                tag: data['id'],
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                  placeholder: (context, child, ) {
                    return Center(
                      child: CircularProgressIndicator(
                      ),
                    );
                  },
                ),
              ) : Container(),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: ValueListenableBuilder(
                    valueListenable: Hive.box('favourites').listenable(),
                    builder: (context, Box box, widget) {
                      return box.get("ids").contains(data["id"]) ?
                        Icon(Icons.favorite) : const SizedBox.shrink();
                    }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
