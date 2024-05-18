import 'package:human_place_app/src/utils/keys.dart';
import 'package:youtube_api/youtube_api.dart';

//SERVICIO DE API DE YOUTUBE

class APIService {
  APIService._instantiate();
  static final APIService instance = APIService._instantiate();

  YoutubeAPI ytApi = new YoutubeAPI(API_KEY);

  Future<YoutubeAPI> fetchVideo({String? urlVideo}) async {
    List<YoutubeAPI> ytResult = [];
    ytResult =
        (await ytApi.search(urlVideo!, type: "video")).cast<YoutubeAPI>();
    return ytResult.first;
  }

  //MÉTODO UTILIZADO PARA ACEPTAR LINKS DE CUALQUIER FORMATO DE YOUTUBE
  //-VIDEO
  //-CANAL
  //-LISTA DE REPRODUCCION

  String getURL(String kind, String id) {
    String baseURL = "https://www.youtube.com/";
    switch (kind) {
      case 'channel':
        return "${baseURL}watch?v=$id";

      case 'video':
        return "${baseURL}watch?v=$id";

      case 'playlist':
        return "${baseURL}watch?v=$id";
    }
    return baseURL;
  }
}
