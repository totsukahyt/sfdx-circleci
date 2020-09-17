/*
 * SB_NC_AccountBulkRegistController
 * LEX 取引先・取引先責任者一括登録画面 コントローラ
 *
 * (c) 2019 Sunbridge Inc.
 *
 *  @author K.Yoshida
 *  @Version 2.2  2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 */
public with sharing class SB_NC_AccountBulkRegistController {
  public String namespace_x { get; private set; } // 管理パッケージの名前空間名
  public String windowTitle { get; private set; }     // ウィンドウのタイトル
  public String targetIds { get; private set; }// 対象の名刺ID
  public String retUrl { get; private set; }     // 戻り先URL

  public String viewLabel { get; private set; } // パンくず用 リストビューのラベル
  public String viewId { get; private set; }   // パンくず用 リストビューのID
  public String fromLabel { get; private set; } // パンくず用 名刺オブジェクトのラベル
  public String fromId { get; private set; } // パンくず用 名刺オブジェクトのID
    
  public SB_NC_AccountBulkRegistController(ApexPages.StandardSetController controller) {
    // 名前空間特定
    this.namespace_x = String.isNotBlank(SB_NameCard_Util.getNamespacePrefix()) ?
            SB_NameCard_Util.getNamespacePrefix() : 'c';
    this.namespace_x += ':';
    
    // ウィンドウタイトル設定
    this.windowTitle = String.format(NameCard__c.sObjecttype.getDescribe().getLabel() + ': ' + System.Label.SB_NC_RegisterAllToAccountAndContactDEV, new String[] {Account.sObjectType.getDescribe().getLabel(), Contact.sObjectType.getDescribe().getLabel()});

    // 選択された名刺IDリスト取得
    List<String> targetIdList = new List<String>();
    for (SObject obj : controller.getSelected()) {
      targetIdList.add(obj.Id);
    }
    this.targetIds = String.join(targetIdList, ',');

    // 戻り先URL・ラベル等 次画面へ引き継ぐ情報の格納
    this.retUrl = System.currentPageReference().getParameters().get('vfRetURLInSFX');
    this.viewId = this.retUrl;
    this.viewLabel = SB_NC_ListViewConfig.getViewLabel('NameCard__c', getViewidFromUrl(this.retUrl));
    this.fromId = '/' + NameCard__c.getSObjectType().getDescribe().getKeyPrefix();
    this.fromLabel = NameCard__c.SObjectType.getDescribe().getLabel();
  }

  private String getViewidFromUrl(String u) {
    if (String.isBlank(u)) {    // LEXのときはない
      return '';
    }
    String[] ss= u.split('[?&]');
    for(String s : ss) {
      if (s.startsWithIgnoreCase('filterName=')) {
        return s.substringAfter('filterName=');
      }
    }
    return '';
  }
}