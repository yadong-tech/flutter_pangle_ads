import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Banner 广告组件
class AdBannerWidget extends StatefulWidget {
  AdBannerWidget({
    Key key,
    @required this.posId,
    this.width = 300,
    this.height = 150,
    this.interval = 0,
    this.show = true,
  }) : super(key: key);
  // 广告 id
  final String posId;
  // 请求模板广告素材的尺寸宽度（对应 expressViewWidth 参数）
  final int width;
  // 请求模板广告素材的尺寸高度（对应 expressViewWidth 参数）
  final int height;
  // 广告轮播间隔，0 或[30~120]之间的数字，单位为 s,默认 0 不轮播
  final int interval;
  // 是否显示广告
  final bool show;

  @override
  _AdBannerWidgetState createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  // View 类型
  final String viewType = 'flutter_pangle_ads_banner';
  // 创建参数
  Map<String, dynamic> creationParams;

  @override
  void initState() {
    creationParams = <String, dynamic>{
      "posId": widget.posId,
      "width": widget.width,
      "height": widget.height,
      "interval": widget.interval
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) {
      return SizedBox.shrink();
    }
    if (Platform.isIOS) {
      return UiKitView(
        viewType: viewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return AndroidView(
        viewType: viewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
  }
}
