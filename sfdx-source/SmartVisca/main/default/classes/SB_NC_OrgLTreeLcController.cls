/**
 *
 *  SB_NC_OrgLTreeLcController
 *  Lightning Component による 組織ツリー Lightning Component の Controller
 * *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.11.xx v1.22 SV_DEV-412 LEXの組織情報
 *
 *
 **/
public with sharing class SB_NC_OrgLTreeLcController {

  private final sObject target;

  public SB_NC_OrgLTreeLcController(ApexPages.StandardController stdController) {
      this.target = (sObject)stdController.getRecord();
  }

  public String getRecordName() {
      return 'Hello ' + (String)target.get('name') + ' (' + (Id)target.get('Id') + ')';
  }

  // getOrgTreeItems の レスポンス
  public class GetOrgTreeItemsResponse {
    @AuraEnabled public Boolean success { get; private set; }
    @AuraEnabled public String error { get; private set; }
    @AuraEnabled public String rootLabel { get; private set; } // NULL
    @AuraEnabled public List<SB_NameCard_OrgTreeBuilder.Item> items { get; private set; }    // lightning:tree の items で表示する用
    @AuraEnabled public Id targetId  { get; private set; }     // 対象のレコードID
    //@AuraEnabled public String company  { get; private set; }   // 対象のレコードのName 値
    @AuraEnabled public boolean mineOnly  { get; private set; }   // 対象のレコードのName 値
    public GetOrgTreeItemsResponse(Id targetId) {
      this.targetId = targetId;
      this.mineOnly = false;
      this.success = false;
    }

    private void setLabel(SB_NameCard_OrgTreeBuilder.Item item) {
      if (item.mine) {
        item.label += '★';
      }
      if (item.selected) {
        item.label += '←';
      }
      if (item.items == null) {
        return;
      }
      for(SB_NameCard_OrgTreeBuilder.Item i : item.items) {
        setLabel(i);
      }
    }

    public void build(Boolean showTitle, Integer maxRecs) {
      try {
        this.items = SB_NameCard_OrgTreeBuilder.getOrgTreeItems(this.targetId, showTitle, maxRecs);
        if (this.items != null && !this.items.isEmpty()) {
          setLabel(this.items[0]);
          this.success = true;
        }
      } catch(Exception e) {
        System.debug(e.getMessage());
        this.error = e.getMessage();
      }
    }

  }// class GetOrgTreeItemsResponse

  // getOrgTreeItems の リクエスト
  public class GetOrgTreeItemsRequest {
    @TestVisible public Id targetId { get; private set; }       // 対象のレコードID
    @TestVisible public Boolean showTitle { get; private set; } // 役職を表示する
    @TestVisible public Integer maxRecs { get; private set; }   // クエリ  リミット
    public GetOrgTreeItemsRequest(Id targetId, Boolean showTitle, Integer maxRecs) {
      this.targetId = targetId;
      this.showTitle = showTitle;
      this.maxRecs = maxRecs;
    }
  }

  /**
  *  lightning:tree の items で表示する用のデータを含むクラスのインスタンスを返す
  *   個別の引数にすると、Integer がうまく渡せないので シリアライズ された 文字列を引数でうけて、デシリアライズ
  **/
  @RemoteAction
  @AuraEnabled
  public static GetOrgTreeItemsResponse getOrgTreeItems(String req) {
    GetOrgTreeItemsRequest request = (GetOrgTreeItemsRequest)JSON.deserialize(req, GetOrgTreeItemsRequest.class);
    GetOrgTreeItemsResponse result = new GetOrgTreeItemsResponse(request.targetId);
    result.build(request.showTitle, request.maxRecs);  // v2.4 2019.10.xx JSON.serialize すると 1400件くらいで ヒープの合計サイズ 6 MB をこえて例外発生するので、serialize しないようにする
    return result;
  }
}