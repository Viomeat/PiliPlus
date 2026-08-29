import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/search.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/common/search/search_type.dart';
import 'package:PiliPlus/models/search/result.dart';
import 'package:PiliPlus/pages/common/common_list_controller.dart';

class ZoneController extends CommonListController {
  ZoneController({
    this.rid,
    this.seasonType,
    this.keyword,
    this.searchTid,
  });

  int? rid;
  int? seasonType;
  String? keyword;
  int? searchTid;
  String? gaiaVtoken;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  Future<LoadingState> customGetData() {
    if (keyword != null) {
      return SearchHttp.searchByType<SearchVideoData>(
        searchType: SearchType.video,
        keyword: keyword!,
        page: page,
        tids: searchTid,
        order: 'totalrank',
        gaiaVtoken: gaiaVtoken,
        onSuccess: (token) {
          gaiaVtoken = token;
          queryData(page == 1);
        },
      );
    }
    if (rid != null) {
      return VideoHttp.getRankVideoList(rid!);
    }
    if (seasonType == 1) {
      return VideoHttp.pgcRankList(seasonType: seasonType!);
    }
    return VideoHttp.pgcSeasonRankList(seasonType: seasonType!);
  }

  @override
  List<dynamic>? getDataList(response) {
    if (response is SearchVideoData) {
      return response.list;
    }
    return super.getDataList(response);
  }
}
