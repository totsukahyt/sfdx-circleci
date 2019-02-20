/**
 *
 *  SB_NCL_PageDispacherController
 * SB_NC_SVCameraLauncherController.cls の 流用
 *  Lightning Express 用に Edgeを識別してVFページを開く用の コントローラ
 *    テストは おもに SB_NC_AccountRegistCommonControllerTest で実施
 *
 *  Version 1 2017.01.0x
 *  Version 2 2018.01.xx v1.22 // SV_DEV-559 IEにてLEX 取引先登録画面に遷移すると取引先選択が表示されない IEはClassic画面に振る
 *  SB_NCL_PageDispacherController
 *
 * Copyright (C) 2017-2018 SunBridge Inc. All Rights Reserved.
 *
 **/
public with sharing class SB_NCL_PageDispacherController {
  public class SB_NCL_PageDispacherControllerException extends Exception {}

  private static final Integer MAX_COOKIE = 4096; //
  private static final Integer MAX_IDS = 170;     // Cookieに保存可能なレコードIDの上限  2017.06.xx V1.20 で 200 →　170に変更
  // ビューで選択されたオブジェクト VF の方にはIDのリストでバインドされる。
  public List<String> targetIds { get; private set; }
  public List<SObject> targets { get; private set; }
  // 詳細画面で開いたら名刺レコードID
  public Id targetId { get; private set; }
  public String retUrl { get; private set; }
  public String viewId { get; private set; }   // 選択したビューのId
  public String toPage { get; private set; }   // リダイレクト先のVFページ名
  public String message { get; private set; }   // リダイレクト先のVFページ名

  public SB_NCL_PageDispacherController() {
    this.targetIds = null;
  }

  public SB_NCL_PageDispacherController(ApexPages.StandardSetController controller) {
    this.targets = controller.getSelected();
    this.targetIds = new List<String>();
    for (SObject obj : controller.getSelected()) {
      targetIds.add(obj.Id);
    }
    System.debug('SB_NCL_PageDispacherController ids size: ' +  targetIds.size());
    System.debug(targetIds);
  }

  public PageReference init() {
    PageReference result;
    try {
      Integer maxIds = Test.isRunningTest() ? 10 : MAX_IDS;
      if (this.targetIds != null && this.targetIds.size() > maxIds) {
        this.message = String.format(Label.SB_NC_TEXT_SELECTEDCARDOVER, new String[] {MAX_IDS.format(), targetIds.size().format()});
        throw new SB_NCL_PageDispacherControllerException(this.message);
      }
      PageReference page = ApexPages.currentPage();
      Map<String, String> paras = page.getParameters();
      Boolean bLex = false;
      if (paras.containsKey('vfRetURLInSFX')) {
        bLex = true;
        this.retUrl = paras.get('vfRetURLInSFX');
        this.viewId = getViewidFromUrl(this.retUrl, bLex);
      }
      else if (paras.containsKey('retURL')) {
        bLex = false;
        this.retUrl = paras.get('retUrl');
        this.viewId = getViewidFromUrl(this.retUrl, bLex);
      }
      // 詳細画面からのとき。個別
      if (paras.containsKey('id')) {
        this.targetId = (Id)paras.get('id');
      }
      //if (this.targetIds !=null && !this.targetIds.isEmpty()) {
      //  // リストビューからきた  一括登録
      //  this.toPage = 'SB_NC_AccountBulkRegist';
      //}
      String pageParam = (String)System.currentPageReference().getParameters().get('page');
      if (String.isNotBlank(pageParam)) {
        // 個別
        this.toPage = pageParam;
      }
      else {
        // リストビューからきた  一括登録
        this.toPage = 'SB_NCL_TwowayBulkRegist';
      }
      String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
      if (String.isNotBlank(userAgent) && userAgent.containsIgnoreCase('Windows')) {
        // Windows!  USER-AGENT に Windows がある場合
        // SV_DEV-559 IEにてLEX 取引先登録画面に遷移すると取引先選択が表示されない
        // 2. Classicの 取引先登録画面を使う。LEX用の取引先登録ボタン押下後に IE11 だった場合に Classicの登録画面に振り分ける。
        // 個別登録だけ！ 一括は Edge用
        if (userAgent.containsIgnoreCase('Trident/7.0') ||
            (Label.SB_Text_IE11Identity != 'none' && userAgent.containsIgnoreCase(Label.SB_Text_IE11Identity))) {
          // IE 11 →
          if (this.toPage == 'SB_NCL_TwowayRegist') {
            // 個別登録 → Classic 個別登録
            this.toPage = 'SB_NameCardL_TwowayRegist';
          }
          else {
            // 一括登録　→ Edge用 ページ
            // → v1.22 18.03.xx IE11 で ハングしてしまう。未対応、ドキュメントで回避 → SV_DEV-559 IEにてLEX 取引先登録画面に遷移すると取引先選択が表示されない
            this.toPage += 'Edge';  // Edge 用のVFページを呼ぶようにする。
          }
        }
        //
        else if (userAgent.containsIgnoreCase('edge') ||
            (Label.SB_Text_WindowsEdgeIdentity != 'none' || userAgent.containsIgnoreCase(Label.SB_Text_WindowsEdgeIdentity))) {
          // Windows Edge　→ Edge用 ページ
          this.toPage += 'Edge';  // Edge 用のVFページを呼ぶようにする。このためだけのこのVF
        }

      }

      result = new PageReference('/apex/' + this.toPage);
      Map<String, String> toParas = result.getParameters();
      if (String.isNotBlank(this.targetId)) {
        toParas.put('id', this.targetId);
      }
      if (String.isNotBlank(this.viewId)) {
        toParas.put('viewId', this.viewId);
      }
      if (String.isNotBlank(this.retUrl)) {
        toParas.put('retUrl', this.retUrl);
      }
      if (this.targetIds !=null && !this.targetIds.isEmpty()) {
        // Cookie に 対象のID達をいれる
        String ids = String.join(this.targetIds, ',');
        String key = 'ids' + String.valueOf(Crypto.getRandomInteger());
        List<Cookie> cookies = new Cookie[] {new Cookie(key, ids, null, -1, false)};
        //System.debug(cookies);
        result.setCookies(cookies);
        toParas.put('idskey', key);   // Cookie名を idskey  といクエリパラメータで渡す。
      }
      result.setRedirect(true);
    }
    catch (Exception e) {
      ApexPages.addMessages(e);
    }
    return result;
  }

  private String getViewidFromUrl(String u, Boolean bLex) {
    if (String.isBlank(u)) {    // LEXのときはない
      return '';
    }
    //String[] ss= u.substringAfter('?').split('&');
    String[] ss= u.split('[?&]');     // LEX のとき、URLが不定かも？
    if (bLex) {
      for(String s : ss) {
        if (s.startsWithIgnoreCase('filterName=')) {
          return s.substringAfter('filterName=');
        }
      }
    }
    else {
      for(String s : ss) {
        if (s.startsWithIgnoreCase('fcf=')) {
          return s.substringAfter('fcf=');
        }
      }
    }
    return '';
  }

}