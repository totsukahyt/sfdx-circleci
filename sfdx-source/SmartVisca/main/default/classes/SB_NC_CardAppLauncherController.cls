/**
 * SB_NC_CardAppLauncherController
 *  SmartVisca LEX対応
 *   Lightning Component 起動用 Lightning Application 起動用 VFページ 用 APEXコントローラ
 *
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.10.xx
 *  @Version 2      2018.01.xx
 *  @Version 2.4    2019.06.XX SV_DEV-1652 SB_NC_CardAppLauncher.pageのapex:pageタグtitle属性対応
 *
 **/
public with sharing class SB_NC_CardAppLauncherController {
  public class SB_NC_CardAppLauncherControllerException extends Exception {}

  public Id targetId { get; private set; }          // 対象のレコードID 名刺とか 取引先とか、取引先責任者とか、ロードとか
  public String retUrl { get; private set; }     // Lightning Componet 名
  public String component { get; private set; }     // Lightning Componet 名
  // 管理パッケージの名前空間名を
  public String namespace_x { get; private set; }
  public String windowTitle { get; private set; }   // 画面タイトル

  @TestVisible
  private static final Map<String, String> APPCD_COMPONENT = new Map<String, String> {
    'newcareer' => 'SB_NC_SetNewCareer'    // 転職先を設定
    , 'updbycard' => 'SB_NC_UpdateByCard'       // 名刺で更新
    , 'orgtree' => 'SB_NC_OrgLTree'       // 組織ツリー   2018.01.xx
    , 'edgetest' => 'LT_Edge_Test'       // 名刺で更新
  };
  //  コンストラクタ
  //    LEXで URLで起動させるため、IDを受ける用にVFの中にコンポーネントを展開するので、
  public SB_NC_CardAppLauncherController() {
    try {
      this.namespace_x = String.isNotBlank(SB_NameCard_Util.getNamespacePrefix()) ?
            SB_NameCard_Util.getNamespacePrefix() : 'c';
      this.namespace_x += ':';
      this.targetId = (Id)System.currentPageReference().getParameters().get('id');
      SObjectType otype = this.targetId.getSObjectType();
      this.retUrl = (Id)System.currentPageReference().getParameters().get('retUrl');
      String app = (String)System.currentPageReference().getParameters().get('app');
      this.component = APPCD_COMPONENT.get(app);
      if (this.component == null && app.startsWithIgnoreCase('SB_NC_')) {
        this.component = app;     // SB_NC_ で始まってたら Lightningコンポーネントだと判断しちゃう。
      }
      else if (this.component == null) {
        throw new SB_NC_CardAppLauncherControllerException('Invalid URL Parameter.');
      }
      // 起動するapp名から画面タイトルをセット
      if (app == 'newcareer'){
        this.windowTitle = System.Label.SB_NC_BusinessCard + '：' + System.Label.SB_NC_SetNewCareer;
      }else if (app == 'updbycard'){
        this.windowTitle = System.Label.SB_NC_BusinessCard + '：' + System.Label.SB_NC_CardList;
      }else if (app == 'orgtree'){
        //「組織情報*」の定義が『/apex/smvTest__SB_NameCard_CompanyTree#/detail/{!smvTest__NameCard__c.Id}』なので、
        // このelse if文が実行されることは現時点ではないですが、一応ロジックは書いておきます
        this.windowTitle = System.Label.SB_NC_BusinessCard + '：' + System.Label.SB_NCOTL_AppTitle;
      }else if (app == 'edgetest'){
        this.windowTitle = System.Label.SB_NC_BusinessCard + '：' + System.Label.SB_NC_CardList;
      }
        

    }
    catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }

}