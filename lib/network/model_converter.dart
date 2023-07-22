import 'dart:convert'; 
import 'package:chopper/chopper.dart';
import 'model_response.dart';
import 'recipe_model.dart';



class ModelConverter implements Converter {
  @override
  Request convertRequest(Request request) {
    final req = applyHeader( request,
contentTypeKey, jsonHeaders, override: false,
);

return encodeJson(req);
  }

  Request encodeJson(Request request) {
  }

  Response<BodyType> decodeJson<BodyType, InnerType>(Response response) {
  }

  @override
  Response<BodyType> convertResponse<BodyType, InnerType>(Response response) {
  Request encodeJson(Request request) { final contentType = request.headers[contentTypeKey]; 
   if (contentType != null && contentType.contains(jsonHeaders))
{ 3 return request.copyWith(body: json.encode(request.body)); } return request; }
  }
}