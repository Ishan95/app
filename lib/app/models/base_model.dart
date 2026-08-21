class BaseModel {
  bool? status;
  dynamic message;

  BaseModel({this.status});

  BaseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['data'] = message;
    return data;
  }
}