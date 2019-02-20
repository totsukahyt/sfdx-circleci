/**
 * SB_NCL_RegistCampaignOptionCreater
 *  SmartVisca リードまたは取引先・取引先責任者へ登録 画面 で選択可能なキャンペーンのオプションを調べて作るクラス
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1  lx v2.0 2018.08.xx
 *
 **/
public with sharing class SB_NCL_RegistCampaignOptionCreater {

  //　getCampaigns で使う 表示するキャンペーンの条件を保持するクラス
  @TestVisible
  private Class CampaignListCondition {
    public Integer max { get; private set; }    // 0 でも LIMIT 0 でクエリする
    public Boolean mine { get; private set; }
    public Set<String> statuss { get; private set; }
    public Set<String> types { get; private set; }
    public CampaignListCondition(String config) {
      this.max = 10;
      this.mine = false;
      this.statuss = new Set<String>();
      this.types = new Set<String>();
      try {
        String[] ss = config.split(';\\s*');
        if (ss != null && !ss.isEmpty() ) {
          this.max = Integer.valueOf(ss[0]);
        }
        if (ss != null && ss.size() > 1) {
          mine = String.isNotBlank(ss[1]) && ss[1].trim() == 'true';
        }
        if (ss != null && ss.size() > 2) {
          statuss.addAll(ss[2].split(',\\s*'));
        }
        if (ss != null && ss.size() > 3) {
          types.addAll(ss[3].split(',\\s*'));
        }
      }
      catch(Exception e) {
        System.debug(e.getMessage());
      }
    }
    public String getQueryExpression(Integer recCount) {
      String result = 'WHERE IsActive=true ';
      if (recCount > this.max && this.mine) {
        result += 'AND OwnerId = \'' + UserInfo.getUserId() + '\''; // 自分所有だけ
      }
      if (recCount > this.max && !this.statuss.isEmpty()) {
        result += 'AND Status IN :statuss ';
      }
      if (recCount > this.max && !this.types.isEmpty()) {
        result += 'AND Type IN :types ';
      }
      result += 'ORDER BY LastModifiedDate DESC '; // 最近更新のあったものから順に
      result += 'LIMIT ' + String.valueOf(this.max);
      return result;
    }
  } // private Class CampaignListCondition

  private static final List<String> CAMPAIGN_SYMMARY_FIELDS = new List<String> {
    'Status', 'Description'
  };
  private static final List<String> CAMPAIGN_POPUP_FIELDS = new List<String> {
    'Type', 'Status', 'Description', 'StartDate', 'EndDate'
  };

  //private static List<Object> buildCampaignValues(Campaign obj, List<String> fields) {
  //  List<Object> result = new List<Object>();
  //  for (String f : fields) {
  //    Object val = obj.get(f);
  //    if (val == null) {
  //      continue;
  //    }
  //    if (val instanceof Date) {
  //      result.add(((Date)val).format());
  //    }
  //    else {
  //      result.add(val);
  //    }
  //  }
  //  return result;
  //}

  public class CampaignOption {
    public Integer index { get; private set; }
    public Integer type { get; private set; }
    public Boolean selected { get; private set; }
    public Id id { get; private set; }
    public String otype { get; private set; }
    public String title { get; private set; }
    public String info { get; private set; }// POPUP で表示する。 values がないとき
    public String description { get; private set; }
    public Date startDate { get; private set; }
    public Date endDate { get; private set; }
    public String status  { get; private set; }
    public String campaignType { get; private set; }
    public String detail { get; private set; }
    public List<Object> summary { get; private set; }
    public List<Object> values { get; private set; }    // POPUP で表示する。
    //List<CampaignMemberStatus> memberStatus;
    public CampaignOption(Integer index, Campaign obj) {
      this.index = index;
      this.type = 1;
      this.selected = false;
      this.otype = 'Campaign';
      init(obj);
    }
    //public CampaignOption(Integer index, Campaign obj, List<CampaignMemberStatus> cmss) {
    //  this.index = index;
    //  this.type = 1;
    //  this.selected = false;
    //  this.otype = 'Campaign';
    //  this.memberStatus = cmss;
    //  init(obj);
    //}
    private void init(Campaign obj) {
      this.id = obj.Id;
      this.title = obj.Name;
      this.info = null;
      this.description = obj.Description;
      this.startDate = obj.StartDate;
      this.endDate = obj.EndDate;
      this.status = obj.Status;
      this.campaignType = obj.Type;
      this.detail = obj.Type + ': ' + obj.Description;
      //this.summary = buildCampaignValues(obj, CAMPAIGN_SYMMARY_FIELDS);
      //this.values = buildCampaignValues(obj, CAMPAIGN_POPUP_FIELDS);
    }
    public void setSummary(List<Object> summary) {
      this.summary = summary;
    }
    public void setvalues(List<Object> values) {
      this.values = values;
    }
    public CampaignOption(Integer index, AltOption alt) {
      String olabel = alt.type == OPT_NOPE ?
              CampaignMember.sObjecttype.getDescribe().getLabel() : Campaign.sObjecttype.getDescribe().getLabel();
      this.index = index;
      this.type = alt.type;
      this.selected = alt.type == OPT_NOPE ? true : false;     // 選択しないはデフォルトで選択
      this.otype = 'Campaign';
      //AltOption alt = ALT_OPTION_LABELS.get(opt);
      this.title = String.format(alt.title_format, new String[]{ olabel });
      this.info = String.format(alt.info_format, new String[]{ olabel });
      this.summary = null;
      this.values = null;
    }
  } //public class getCampaignOptions {
      //this.title =
      //this.optLabel = String.format('<{0}>', new String[]{this.title});
      //this.info =

  private class AltOption {
    public Integer type { get; private set; }
    public String info_format { get; private set; }
    public String title_format { get; private set; }
    public AltOption(Integer type, String title_format, String info_format) {
      this.type = type;
      this.title_format = title_format; // 一覧に表示する文字列
      this.info_format = info_format; // ツールチップに表示する文字列
    }
  }

  private static final Integer OPT_SELECT = 2;    // 既存で選択してもらう アカウント or コンタクトレコードが対象
  private static final Integer OPT_NOPE = 4;    //  一括登録のときの 登録しない
  private enum OptionType { OPT_SELECT, OPT_NOPE }

  private static final Map<OptionType, AltOption> ALT_OPTION_LABELS = new Map<OptionType, AltOption>  {
    OptionType.OPT_SELECT => new AltOption(OPT_SELECT, Label.SB_NCS1R_Text_SelectOther, Label.SB_NCS1R_Text_SelectOtherDiscription),
    OptionType.OPT_NOPE => new AltOption(OPT_NOPE, Label.SB_NCS1R_Text_NoCampaignMember, Label.SB_NCS1R_Text_NoCampaignMemberDiscription)
  };

  private class CampaignOptionCreator {
    private Map<String, String> typeApi2Label;
    private Map<String, String> statusApi2Label;
    public CampaignOptionCreator() {
      this.typeApi2Label = SB_NameCardL_Util.getPickListMap(Campaign.Type);
      this.statusApi2Label = SB_NameCardL_Util.getPickListMap(Campaign.Status);
    }
    public CampaignOption create(Integer index, Campaign obj) {
      CampaignOption result = new CampaignOption(index, obj);
      result.setSummary(buildCampaignValues(obj, CAMPAIGN_SYMMARY_FIELDS));
      result.setvalues(buildCampaignValues(obj, CAMPAIGN_POPUP_FIELDS));
      return result;
    }
    public CampaignOption create(Integer index, AltOption alt) {
      return new CampaignOption(index, alt);
    }

    private List<Object> buildCampaignValues(Campaign obj, List<String> fields) {
      List<Object> result = new List<Object>();
      for (String f : fields) {
        Object val = obj.get(f);
        if (val == null) {
          continue;
        }
        if (val instanceof Date) {
          // 日付型のとき
          result.add(((Date)val).format());
        }
        else {
          //　それ以外
          if (f=='Type') {
            val = this.typeApi2Label.get((String)val);
          }
          else if (f=='Status') {
            val = this.statusApi2Label.get((String)val);
          }
          result.add(val);
        }
      }
      return result;
    }

  }

  // キャンペーンをクエリするクラス WHERE句以降ごとに派生さす
  private abstract class ListBulider {
    protected String makeSelect() {
      Set<String> fields = new Set<String> {'Id', 'Name'};
      fields.addAll(CAMPAIGN_SYMMARY_FIELDS);
      fields.addAll(CAMPAIGN_POPUP_FIELDS);
      return String.format('SELECT {0} FROM Campaign ', new String[]{ String.join(new List<String>(fields), ', ')});
    }
    public abstract List<Campaign> create();
  }

  private class RecentlyViewedListBuilder extends ListBulider {
    public override List<Campaign> create() {
      //return 'WHERE IsActive=true Id IN (SELECT ID FROM RecentlyViewed WHERE Type=\'Campaign\') ORDER BY LastModifiedDate DESC';
      String query = makeSelect();
      Map<Id, RecentlyViewed> vieweds = new Map<Id, RecentlyViewed>([SELECT Id FROM RecentlyViewed WHERE Type='Campaign']);
      Set<Id> ids = new Set<Id>(vieweds.keySet());
      query += 'WHERE IsActive=true AND Id IN :ids ORDER BY LastModifiedDate DESC';
      return Database.query(query);
    }
  }

  private class CustomSettigListBuilder extends ListBulider {
    private CampaignListCondition listcond;
    public CustomSettigListBuilder() {
      this.listcond = new CampaignListCondition(SB_NameCardL_Util.smartViscaConfig.SRegistCampaignList__c);
    }
    public override List<Campaign> create() {
      Set<String> statuss;  // 状況の条件
      Set<String> types;    // 種別の条件
      statuss = this.listcond.statuss;
      types = this.listcond.types;
      // 1. 有効なキャンペーン 数を調べる。
      Integer cnt;
      List<AggregateResult> ars = [SELECT Count(Id) cnt FROM Campaign WHERE IsActive=true];
      for (AggregateResult ar : ars) {
        cnt = (Integer)ar.get('cnt');
        break;
      }
      String query = makeSelect();
      query += this.listcond.getQueryExpression(cnt); // 2. 有効なキャンペーン 数 に応じて クエリを決める。
      return Database.query(query);
    }
  }

  public static List<Campaign> createCampaignList() {
    ListBulider builder = null;
    try {
      if(String.isNotBlank(SB_NameCardL_Util.smartViscaConfig.SRegistCampaignList__c)) {
        builder = new CustomSettigListBuilder();
      }
    }
    catch(Exception e){
      System.debug(e.getMessage());
    }
    if (builder == null) {
      builder = new RecentlyViewedListBuilder();
    }
    return builder.create();
  }


  public static List<CampaignOption> createCampaignOptions() {
    List<CampaignOption> result = new List<CampaignOption>();
    //Set<String> statuss;  // 状況の条件
    //Set<String> types;    // 種別の条件
    //CampaignListCondition listcond = new CampaignListCondition(SB_NameCardL_Util.smartViscaConfig.SRegistCampaignList__c);
    // 1. 有効なキャンペーン 数を調べる。 カスタム設定使う型だとだぶる。。
    Integer cnt;
    List<AggregateResult> ars = [SELECT Count(Id) cnt FROM Campaign WHERE IsActive=true];
    for (AggregateResult ar : ars) {
      cnt = (Integer)ar.get('cnt');
      break;
    }
    //// 2. 有効で設定の条件にあったレコードを取得
    //Set<String> fields = new Set<String> {'Id', 'Name'};
    //fields.addAll(CAMPAIGN_SYMMARY_FIELDS);
    //fields.addAll(CAMPAIGN_POPUP_FIELDS);
    //String query = String.format('SELECT {0} FROM Campaign ', new String[]{ String.join(new List<String>(fields), ', ')});
    //statuss = listcond.statuss;
    //types = listcond.types;
    //query += listcond.getQueryExpression(cnt); // 有効なキャンペーン 数 に応じて クエリを決める。

    //List<Campaign> cams = Database.query(query);
    //// キャンペーンメンバーのステータス
    ////List<CampaignMemberStatus> cmss = [SELECT Id, CampaignId, IsDefault, Label, SortOrder FROM CampaignMemberStatus WHERE CampaignId IN :cams];
    ////Map<Id, List<CampaignMemberStatus>> camIs2CamMemberStatuss = new Map<Id, List<CampaignMemberStatus>>();
    ////for (CampaignMemberStatus cms : cmss) {
    ////  //Id camId = cms.CampaignID;
    ////  List<CampaignMemberStatus> stss = null;
    ////  if (camIs2CamMemberStatuss.containsKey(cms.CampaignID)) {
    ////    stss = camIs2CamMemberStatuss.get(cms.CampaignID);
    ////  }
    ////  else {
    ////    stss = new List<CampaignMemberStatus>();
    ////    camIs2CamMemberStatuss.put(cms.CampaignID, stss);
    ////  }
    ////  stss.add(cms);
    ////}
    ////
    List<Campaign> cams = createCampaignList();
    CampaignOptionCreator builder = new CampaignOptionCreator();
    // キャンペーンメンバーにしない オプション
    result.add(builder.create(0, ALT_OPTION_LABELS.get(OptionType.OPT_NOPE)));
    for(Campaign cam : cams) {
      //result.add(new CampaignOption(result.size(), cam, camIs2CamMemberStatuss.get(cam.Id)));
      result.add(builder.create(result.size(), cam));
    }
    if (cams.size() < cnt) {
      // 有効なキャンペーン 数 より リストするのがすくなかったら、検索可能にする。
      result.add(builder.create(result.size(), ALT_OPTION_LABELS.get(OptionType.OPT_SELECT)));
    }
    return result;

  }


}