/*
 * (c) 2018 Sunbridge Inc.
 *
 * LEX名刺で更新Launcherコントローラ
 * @author mao
 * @Version 拡張パッケージ：Lead Ex. 1.12 2018/08/XX
 *
 */

public with sharing class SB_NCL_CardAppLauncherController {
  public class SB_NC_LeadCardAppLauncherControllerException extends Exception {}

  public Id targetId { get; private set; }          // 対象のレコードID 名刺とか 取引先とか、取引先責任者とか、ロードとか
  public String retUrl { get; private set; }     // Lightning Componet 名
  public String component { get; private set; }     // Lightning Componet 名
  // 管理パッケージの名前空間名を
  public String namespace_x { get; private set; }
  public String windowTitle { get; private set; }

  @TestVisible
  private static final Map<String, String> APPCD_COMPONENT = new Map<String, String> {
    'updbycard' => 'SB_NCL_LeadUpdateByCard'       // 名刺で更新
    // 'updbycard' => 'SB_NC_LeadUpdateByCard'       // 名刺で更新
  };

  //  コンストラクタ
  //    LEXで URLで起動させるため、IDを受ける用にVFの中にコンポーネントを展開するので、
  public SB_NCL_CardAppLauncherController() {
    try {
      this.windowTitle = String.format(System.Label.SB_NCLD_Text_BusinessCardList, new String[]{SmartViscaf__NameCard__c.sObjectType.getDescribe().getLabel()});
      List<ApexClass> classes = [SELECT Name, NamespacePrefix FROM ApexClass WHERE Name IN ('SB_NameCard_LeadBulkRegistController', 'SB_NameCard_LeadNameCardListController', 'SB_NameCard_LeadRegistController') OR NamespacePrefix='SmartViscal'];
      String namesp = '';
      if (!classes.isEmpty()) {
        namesp = classes[0].NamespacePrefix;
      }
      this.namespace_x = String.isNotBlank(namesp) ?
            namesp : 'c';
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
        throw new SB_NC_LeadCardAppLauncherControllerException('Invalid URL Parameter.');
      }
    }
    catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }
}