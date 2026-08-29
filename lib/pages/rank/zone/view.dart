import 'package:PiliPlus/common/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/video_card/video_card_h.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/horizontal_video_model.dart';
import 'package:PiliPlus/models/model_hot_video_item.dart';
import 'package:PiliPlus/pages/rank/zone/controller.dart';
import 'package:PiliPlus/pages/rank/zone/widget/pgc_rank_item.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class ZonePage extends StatefulWidget {
  const ZonePage({
    super.key,
    required this.tag,
    this.rid,
    this.seasonType,
    this.keyword,
    this.searchTid,
  });

  final String tag;
  final int? rid;
  final int? seasonType;
  final String? keyword;
  final int? searchTid;

  @override
  State<ZonePage> createState() => _ZonePageState();
}

class _ZonePageState extends State<ZonePage>
    with AutomaticKeepAliveClientMixin, GridMixin {
  late final ZoneController controller;

  @override
  void initState() {
    controller = Get.put(
      ZoneController(
        rid: widget.rid,
        seasonType: widget.seasonType,
        keyword: widget.keyword,
        searchTid: widget.searchTid,
      ),
      tag: widget.tag,
    );
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return refreshIndicator(
      onRefresh: controller.onRefresh,
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 7, bottom: 100),
            sliver: Obx(() => _buildBody(controller.loadingState.value)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(LoadingState<List<dynamic>?> loadingState) {
    return switch (loadingState) {
      Loading() => gridSkeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  final item = response[index];
                  if (index == response.length - 1 &&
                      widget.keyword != null) {
                    controller.onLoadMore();
                  }
                  if (item is HorizontalVideoModel) {
                    return VideoCardH(
                      videoItem: item,
                      onRemove: item is HotVideoItemModel
                          ? () => controller.loadingState
                              ..value.data!.removeAt(index)
                              ..refresh()
                          : null,
                    );
                  }
                  return PgcRankItem(item: item);
                },
                itemCount: response.length,
              )
            : HttpError(onReload: controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: controller.onReload,
      ),
    };
  }
}
