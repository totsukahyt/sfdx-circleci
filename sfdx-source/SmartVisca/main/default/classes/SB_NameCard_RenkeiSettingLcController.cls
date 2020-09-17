/*
 *fSB_NameCard_RenkeiSettingLcController
 * SB_NameCard_RenkeiSettingLcController   (SB_NameCard_RenkeiSetting)
 * Lightning連携設定コンポーネントコントローラクラス
 * データの取得、保存、更新、削除
 *
 *
 * Copyright (c) 2017 SunBridge Inc.
 *
 *  @author gao
 *  History :
 *  @Version 1.20      2017.3.XX
 *  @Version 1.20.1    SV_DEV-545  SmartVisca   連携設定での取引先/取引先責任者レコードタイプ設定が有効化されていないレコードタイプが選択できてしまう
 *  @Version 1.22      2017.10.xx  SV_DEV-640   個人取引先を有効化している場合、マッピングで取引差責任者のカスタム項目を区別するか表示しない
 *  @Version 1.22      SV_DEV-648  SmartVisca   連携設定:既存の取引先の検索条件の指定項目「取引先 説明」を設定した場合のエラー
 *  @Version 1.22      2018.02.XX  SV_DEV-735   基本設定レコードが二つ作成される
 *  @Version 2.1       2018.04.XX  SV_DEV-876   連携設定条件に名刺項目に参照項目が選択できないことを変更
 *  @Version 2.1       2018.04.XX  SV_DEV-885 基本設定、連携条件設定、連携マッピングタブ切り替えの見直し
 *  @Version 2.1       2018.04.XX  SV_DEV-1106 SmartVisca基本設定レコードの一部項目の値が反転して表示される。
 *  @Version 2.0.1     2018.04.XX  SV_DEV-881   SmartVisca 連携設定で指定項目を設定して保存できているのに「指定項目が存在しません」メッセージが表示される。
 *  @Version 2.4       2019.05.XX  SV_DEV-1630対応に伴いマッピングタブに施したリファクタリングと同様の対応を実施
 *                     2019.06.XX SV_DEV-1634   SmartVisca設定タブの自動連携に関する設定の表示/非表示を切り替えるカスタム設定を作る
 *
 */

public with sharing class SB_NameCard_RenkeiSettingLcController {

  //演算子ラベル設定
  public static String NONE = Label.SB_NC_SETTING_LABEL_NONE;//―なし―
  public static String OP_EQUAL = Label.SB_NC_SETTING_LABEL_OP_EQUAL;//次の文字列と一致する
  public static String OP_NOT_EQUAL = Label.SB_NC_SETTING_LABEL_OP_NOT_EQUAL;//次の文字列と一致しない
  public static String OP_START_WITH = Label.SB_NC_SETTING_LABEL_OP_START_WITH;//次の文字列で始まる
  public static String OP_CONTAINS = Label.SB_NC_SETTING_LABEL_OP_CONTAINS;//次の文字列を含む
  public static String OP_NOT_CONTAINS = Label.SB_NC_SETTING_LABEL_OP_NOT_CONTAINS;//次の文字列を含まない
  public static String OP_REGEX = Label.SB_NC_SETTING_LABEL_OP_REGEX;//次の正規表現に合致する
  public static String OP_LESS_THAN = Label.SB_NC_SETTING_LABEL_OP_LESS_THAN;//＜
  public static String OP_GREATER_THAN = Label.SB_NC_SETTING_LABEL_OP_GREATER_THAN;//＞
  public static String OP_LESS_EQUAL_THAN = Label.SB_NC_SETTING_LABEL_OP_LESS_EQUAL_THAN;//＜＝
  public static String OP_GREATER_EQUAL_THAN = Label.SB_NC_SETTING_LABEL_OP_GREATER_EQUAL_THAN;//＞＝

  //全てのデータを取得
  @TestVisible
  private class RenkeiPageAllDate{
    @AuraEnabled public Map<String,String> mappingSetMap{get; private set;}                           //#Todo 使わないため削除べき?
    @AuraEnabled public List<Map<String,String>> accountListMap{get; private set;}                    //取引先項目リスト
    @AuraEnabled public Map<String,String> baseSet{get; private set;}                                 //基本設定
    @AuraEnabled public List<SB_NameCard_NameCardRenkeiJyokenDTO> PardotIgnore {get; private set;}    //連携条件リスト
    @AuraEnabled public List<SB_NameCard_NameCardRenkeiJyokenDTO> disList {get; private set;}         //必須条件
    @AuraEnabled public Map<String,String> namecardDataTypeMap{get; private set;}                     //名刺項目タイプMap
    @AuraEnabled public Map<String,String> namecardLabelNameMap{get; private set;}                    //名刺項目表示ラベルMap
    @AuraEnabled public String namecardLabel{get; private set;}                                       //オブジェクト名刺表示ラベル
    @AuraEnabled public List<String> namecardLabelKeyList{get; private set;}                          //名刺項目List
    @AuraEnabled public Map<String,List<Map<String,String>>> typeCondition{get; private set;}         //タイプによる演算子
    @AuraEnabled public List<RecordTypeBean> accUpsertRecordType{get; private set;}                   //取引先レコードタイプ
    @AuraEnabled public List<RecordTypeBean> accQueryRecordTypeList{get; private set;}                //自動連携で検索対象の取引先レコードタイプ
    @AuraEnabled public List<String> accQuerySelectedList{get; private set;}                          //選択済み 自動連携検索対象取引先レコードタイプ
    @AuraEnabled public List<RecordTypeBean> conUpsertRecordType{get; private set;}                   //取引先責任者レコードタイプ
    @AuraEnabled public List<RecordTypeBean> conQueryRecordTypeList{get; private set;}                //自動連携で検索対象の取引先責任者レコードタイプ
    @AuraEnabled public List<String> conQuerySelectedList{get; private set;}                          //選択済み 自動連携検索対象取引先責任者レコードタイプ
    @AuraEnabled public List<RecordTypeBean> leadUpsertRecordType{get; private set;}                  //リードレコードタイプ
    @AuraEnabled public List<RecordTypeBean> leadQueryRecordTypeList{get; private set;}               //自動連携で検索対象のリードレコードタイプ
    @AuraEnabled public List<String> leadQuerySelectedList{get; private set;}                         //選択済み 自動連携検索対象リードレコードタイプ
    @AuraEnabled public String helpText{get; private set;}                                            //ヘルプtext
    @AuraEnabled public Map<String,String> labMap{get; private set;}                                  //ラベルMap
    @AuraEnabled public List<String> warMsg{get; private set;}                                        //warningメッセージ
    //#Todo 使わないため削除べき?
    @AuraEnabled public String lastName{get; private set;}
    @AuraEnabled public String lastTime{get; private set;}
    @AuraEnabled public String lastId{get; private set;}
    @AuraEnabled public Boolean isEnableLeadExtention{get; private set;}  //リード拡張パッケージ存在するか
    @AuraEnabled public Boolean isEnableLeadExtention21{get; private set;}  //リード拡張パッケージ v2.1以降存在するか
    //キャンペーンメンバーの値リスト(BasicSettingからベタ移植)
    @AuraEnabled public List<Map<String, String>> campaignMemberStatusOptions{get;set;}

    //データを取得
    public RenkeiPageAllDate(){
      this.labMap = SB_NameCard_RenkeiMapperUtil.changeLabeltoMap('renkeisetting');
      //this.mappingSetMap = this.getmappingSetMap();
      this.accountListMap = this.getAccountFieldListMap();
      this.warMsg = new List<String>();
      //基本設定を取得
      NameCardBasicSetting__c ba = SB_NameCard_BasicSetting.getNameCardBasicSetting();
      if (String.isBlank(ba.Id)) {
        this.warMsg.add(System.Label.SB_NC_SETTING_ERROR_No_NameCardBasicSetting);
      }
      //this.helpText = NameCardBasicSetting__c.RenkeiSpecificItems__c.getDescribe().getInlineHelpText();
      this.helpText = System.Label.SB_NC_MAPPING_RenkeiSpecificItemsHelpMessage;
      this.baseSet = new Map<String,String>();
      //指定項目チェック
      this.isEnableLeadExtention = SB_NameCard_Util.isEnableLeadExt112();
      this.isEnableLeadExtention21 = SB_NameCard_Util.isEnableLeadExt21();
      this.accUpsertRecordType = new List<RecordTypeBean>();
      this.accQueryRecordTypeList = new List<RecordTypeBean>();
      this.accQuerySelectedList = new List<String>();
      this.conUpsertRecordType = new List<RecordTypeBean>();
      this.conQueryRecordTypeList = new List<RecordTypeBean>();
      this.conQuerySelectedList = new List<String>();
      this.leadUpsertRecordType = new List<RecordTypeBean>();
      this.leadQueryRecordTypeList = new List<RecordTypeBean>();
      this.leadQuerySelectedList = new List<String>();
      
       if (String.isNotBlank(ba.RenkeiSpecificItems__c)) {
        // SV_DEV-881 SmartVisca 連携設定で指定項目を設定して保存できているのに「指定項目が存在しません」メッセージが表示される。
        if (!Account.sObjectType.getDescribe().fields.getMap().containsKey(ba.RenkeiSpecificItems__c)) {
          this.warMsg.add(String.format(System.Label.SB_NC_SETTING_ERROR_Wrong_RenkeiSpecificItems,new String[]{ba.RenkeiSpecificItems__c}));
          ba.RenkeiSpecificItems__c = '';
        }
      }
      this.baseSet = SB_NameCard_NameCardBasicSettingDTO.bind(ba);
      if (this.isEnableLeadExtention == true) {
        //キャンペーンメンバーoptionを設定
        setCampaignStatus();
      }

      //既存のレコードタイプを取得
      this.setRecordTypeList(Account.SObjectType, this.baseSet, 'RenkeiAccountRecordTypes__c', 'RenkeiAccountQueryRecordTypeIds__c', this.accUpsertRecordType, this.accQueryRecordTypeList,this.accQuerySelectedList);
      this.setRecordTypeList(Contact.SObjectType, this.baseSet, 'RenkeiContactRecordTypes__c', 'RenkeiContactQueryRecordTypeIds__c', this.conUpsertRecordType, this.conQueryRecordTypeList,this.conQuerySelectedList);
      this.setRecordTypeList(Lead.SObjectType, this.baseSet, 'RenkeiLeadRecordTypes__c', 'RenkeiLeadQueryRecordTypeIds__c', this.leadUpsertRecordType, this.leadQueryRecordTypeList,this.leadQuerySelectedList);
      this.spardotIgnore(ba.Id);
      this.setPageData();
    }

    //SV_DEV-527 リード登録時にキャンペーン内での状況を選択
    //キャンペーンメンバーoptionを設定(BasicSettingからベタ移植)
    private void setCampaignStatus(){
      campaignMemberStatusOptions = new List<Map<String, String>>();
      Map<String, String> non = new Map<String, String>();
      // SV_DEV-1073 SmartVisca 基本設定の「キャンペーンメンバーの状況」の「ーなしー」を選択ができる。
      non.put('label','--' + Label.SB_NC_TEXT_NotSelected + '--');
      non.put('value','');
      campaignMemberStatusOptions.add(non);
      Schema.DescribeFieldResult fieldResult = getCmpPick();
      if (fieldResult != null) {
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
          if (!f.isActive()) {
            continue;
          }
          Map<String, String> non1 = new Map<String, String>();
          non1.put('label',f.getLabel());
          non1.put('value',f.getValue());
          campaignMemberStatusOptions.add(non1);
        }
      }
    }

    //(BasicSettingからベタ移植)
    private Schema.DescribeFieldResult  getCmpPick(){
      Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
      if (schemaMap.containsKey('CampaignMember')) {
        return schemaMap.get('CampaignMember').getDescribe().fields.getMap().get('status').getDescribe();
      } else {
        return null;
      }
    }

    public void setRecordTypeList(Schema.SObjectType obj, Map<String,String> baseSet, String selectKey, String selectKeys,List<RecordTypeBean> recod,List<RecordTypeBean> recods,List<String> selectedValueList){
      String selectId = baseSet.get(selectKey);
      String selectIds = baseSet.get(selectKeys);
      List<Schema.RecordTypeInfo> res = obj.getDescribe().getRecordTypeInfos();

      Set<String> serea = new Set<String>();
      if (String.isNotBlank(selectIds)) {
        for (String str : selectIds.split(';')) {
          serea.add(str);
        }
      }

      Set<String> sere = new Set<String>();
      if (String.isNotBlank(selectId)) {
        sere.add(selectId);
      }

      RecordTypeBean rb = new RecordTypeBean();
      rb.label = NONE;
      rb.value = '';
      rb.check = 'false';
      recod.add(rb);

      Set<String> seraSet = new Set<String>();
      selectId = '';

      for (Schema.RecordTypeInfo re : res) {
        if (!re.isAvailable() || re.isMaster()) {
          if (!re.isMaster() && (serea.contains(re.getRecordTypeId()) || sere.contains(re.getRecordTypeId()))) {
            sere.remove(re.getRecordTypeId());
            serea.remove(re.getRecordTypeId());
            // this.warMsg.add(new MyMsgBean(String.format(System.Label.SB_NC_MAPPING_NoAvailableR_ErrorMessage,new String[]{obj.getDescribe().getLabel(),re.Name}),!this.warMsg.isEmpty()));
            this.warMsg.add(String.format(System.Label.SB_NC_MAPPING_NoAvailableR_ErrorMessage,new String[]{obj.getDescribe().getLabel(),re.Name}));

          }
          continue;
        }
        RecordTypeBean ma = new RecordTypeBean(re,sere.contains(re.getRecordTypeId()));
        RecordTypeBean maa = new RecordTypeBean(re,serea.contains(re.getRecordTypeId()));

        if (ma.check == 'true') {
          sere.remove(re.getRecordTypeId());
          selectId = re.getRecordTypeId();
          //ma.check = 'true';
        }

        if (maa.check == 'true') {
          serea.remove(re.getRecordTypeId());
          seraSet.add(re.getRecordTypeId());
          selectedValueList.add(re.getRecordTypeId());
          //maa.check = 'true';
        }
        recod.add(ma);
        recods.add(maa);
      }

      selectIds = '';
      for (Id str : seraSet) {
        if (String.isNotBlank(selectIds)) {
          selectIds += ';';
        }
         selectIds += str;
      }

      this.baseSet.put(selectKey, selectId);
      this.baseSet.put(selectKeys, selectIds);


      if (!sere.isEmpty()) {
        for (String str : sere) {
          this.warMsg.add(String.format(System.Label.SB_NC_MAPPING_NoObject_ErrorMessage,new String[]{obj.getDescribe().getLabel(),str}));
        }
      }

      if (!serea.isEmpty()) {
        for (String str : serea) {
          if (sere.contains(str)) {
            continue;
          }
          this.warMsg.add(String.format(System.Label.SB_NC_MAPPING_NoObject_ErrorMessage,new String[]{obj.getDescribe().getLabel(),str}));
        }
      }
    }

    //連携設定データを設定
    public void setPageData(){
      this.namecardLabel = NameCard__c.SobjectType.getDescribe().getLabel();
      this.namecardDataTypeMap = new Map<String,String>();
      this.namecardLabelNameMap = new Map<String,String>(); 
      this.namecardLabelNameMap.put('null',System.Label.SB_NC_SETTING_LABEL_NONE);
      this.namecardLabelKeyList = new List<String>();
      SB_NameCard_RenkeiMapperUtil.createApiNameKeyDataTypeMap('NameCard__c',this.namecardDataTypeMap,this.namecardLabelNameMap,this.namecardLabel + ' : ',true);

      for (String str : this.namecardLabelNameMap.keySet()) {
        System.debug(namecardDataTypeMap.get(str) + str);
        if (namecardDataTypeMap.get(str) == 'LOCATION'
              || namecardDataTypeMap.get(str) == 'ENCRYPTEDSTRING'
              || namecardDataTypeMap.get(str) == 'PICKLIST'
              || namecardDataTypeMap.get(str) == 'MULTIPICKLIST'
              || namecardDataTypeMap.get(str) == 'CURRENCY'
              || namecardDataTypeMap.get(str) == 'TIME'
              || namecardDataTypeMap.get(str) == 'PERCENT'
              || str.endsWith('__s')
              ) {
          continue;
        }
        if (namecardDataTypeMap.get(str) == 'PICKLIST' || namecardDataTypeMap.get(str) == 'MULTIPICKLIST' ) {
          namecardDataTypeMap.put(str,'STRING');
        }
        this.namecardLabelKeyList.add(str);
      }
      //演算子のラベル変換
      this.setConditionMap();
      this.disList = new List<SB_NameCard_NameCardRenkeiJyokenDTO>();
      NameCardRenkeiJyoken__c j1 = new NameCardRenkeiJyoken__c();
      j1.NameCardName__c = this.namecardLabelNameMap.get(SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','company_name__c'));
      j1.Operator__c = System.Label.SB_NC_SETTING_LABEL_OP_NOT_EQUAL;
      j1.Value__c = System.Label.SB_NC_SETTING_LABEL_Blank;
      NameCardRenkeiJyoken__c j2 = new NameCardRenkeiJyoken__c();
      // j2.NameCardName__c = this.namecardLabelNameMap.get(SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','person_name_last__c')) + ' ' + System.Label.SB_NC_MAPPING_LABEL_OR + ' ' +    this.namecardLabelNameMap.get(SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','last_name__c')).split(':')[1];
      j2.NameCardName__c = NameCard__c.sObjectType.getDescribe().getLabel() + ' : ' + NameCard__c.person_name_last__c.getDescribe().getLabel() + ' ' + System.Label.SB_NC_MAPPING_LABEL_OR + ' ' + NameCard__c.last_name__c.getDescribe().getLabel();
      j2.Operator__c = System.Label.SB_NC_SETTING_LABEL_OP_NOT_EQUAL;
      j2.Value__c = System.Label.SB_NC_SETTING_LABEL_Blank;
      SB_NameCard_NameCardRenkeiJyokenDTO j11 = new SB_NameCard_NameCardRenkeiJyokenDTO();
      j11.bind(j1);
      SB_NameCard_NameCardRenkeiJyokenDTO j22 = new SB_NameCard_NameCardRenkeiJyokenDTO();
      j22.bind(j2);
      this.disList.add(j11);
      this.disList.add(j22);
    }

    //連携條件を取得
    public void spardotIgnore(Id bs){

      List<NameCardRenkeiJyoken__c> jyous = SB_NameCard_BasicSettingUtil.getNameCardRenkeiJyoken(bs);
      this.PardotIgnore = new List<SB_NameCard_NameCardRenkeiJyokenDTO>();
      Map<String, Schema.SObjectField> nameCardFieldMap = NameCard__c.sObjectType.getDescribe().fields.getMap();
      for (NameCardRenkeiJyoken__c jyo : jyous) {
        SB_NameCard_NameCardRenkeiJyokenDTO aa = new SB_NameCard_NameCardRenkeiJyokenDTO();
        aa.bind(jyo);
        if (!nameCardFieldMap.containsKey(aa.NameCardName)) {
          this.warMsg.add(String.format(System.Label.SB_NC_SETTING_WrongNCField_ErrorMessage,
                    new String[]{aa.NameCardName}));
          
        } else {
          this.PardotIgnore.add(aa);
        }
      }

      for (SB_NameCard_NameCardRenkeiJyokenDTO j : this.PardotIgnore) {
        if (String.isBlank(j.Value)) {
          j.Value = '';
        }
      }
    }

    //取引先項目リスト取得
    public  List<Map<String,String>> getAccountFieldListMap(){
      Map<String,Schema.SObjectField> fieldMap = Account.SobjectType.getDescribe().fields.getMap();
      List<Map<String,String>> accountListMap = new List<Map<String,String>>();
      Map<String,String> mappingmap1 = new Map<String,String>();
      mappingmap1.put('label',System.Label.SB_NC_SETTING_LABEL_NONE);
      mappingmap1.put('value','');
      accountListMap.add(mappingmap1);
      for (Schema.SObjectField sfield : fieldMap.Values()) {
        Map<String,String> mappingmap = new Map<String,String>();
        Schema.describefieldresult dfield = sfield.getDescribe();
        //DisplayTypeはロングテキストエリアがないので、項目の長さでロングテキストエリア項目を外します
        if ((dfield.getType() == Schema.DisplayType.STRING || dfield.getType() == Schema.DisplayType.TEXTAREA)
                && dfield.getLength() <= 255 && dfield.name != 'JigsawCompanyId') {
          String label = dfield.getLabel();
          //SV_DEV-640   個人取引先を有効化している場合、マッピングで取引差責任者のカスタム項目を区別するか表示しない
          if (SB_NameCard_Util.isEnablePersonAccount()) {
            label = SB_NameCard_RenkeiMapperUtil.changePersonAccountLabel(dfield);
          }
          mappingmap.put('label',label);
          mappingmap.put('value',dfield.name);
          accountListMap.add(mappingmap);
        }
      }
      return accountListMap;
    }


    //演算子のラベル変換
    public void setConditionMap(){
      this.typeCondition = new Map<String,List<Map<String,String>>>();
      Map<String,String> none1 = new Map<String,String>();
      //―なし―
      none1.put('value','');
      none1.put('label',NONE);

      Map<String,String> equal = new Map<String,String>();
      //次の文字列と一致する
      equal.put('value','Matches_next_character_string');
      equal.put('label',OP_EQUAL);

      Map<String,String> noequal = new Map<String,String>();
      //次の文字列と一致しない
      noequal.put('value','Does_not_match_next_character_string');
      noequal.put('label',OP_NOT_EQUAL);

      Map<String,String> startwith = new Map<String,String>();
      //次の文字列で始まる
      startwith.put('value','Start_with_the_following_string');
      startwith.put('label',OP_START_WITH);

      Map<String,String> contain = new Map<String,String>();
      //次の文字列を含む
      contain.put('value','Contains_the_following_character_string');
      contain.put('label',OP_CONTAINS);

      Map<String,String> nocontain = new Map<String,String>();
      //次の文字列を含まない
      nocontain.put('value','Not_contain_the_following_character_string');
      nocontain.put('label',OP_NOT_CONTAINS);

      Map<String,String> regex = new Map<String,String>();
      //次の正規表現に合致する
      regex.put('value','Matches_the_following_regular_expression');
      regex.put('label',OP_REGEX);

      Map<String,String> lessthan = new Map<String,String>();
      //＜
      lessthan.put('value',OP_LESS_THAN);
      lessthan.put('label',OP_LESS_THAN);

      Map<String,String> greaterthan = new Map<String,String>();
      //＞
      greaterthan.put('value',OP_GREATER_THAN);
      greaterthan.put('label',OP_GREATER_THAN);

      Map<String,String> equalthan = new Map<String,String>();
      //＜＝
      equalthan.put('value',OP_LESS_EQUAL_THAN);
      equalthan.put('label',OP_LESS_EQUAL_THAN);

      Map<String,String> greaterequalthan = new Map<String,String>();
      //＞＝
      greaterequalthan.put('value',OP_GREATER_EQUAL_THAN);
      greaterequalthan.put('label',OP_GREATER_EQUAL_THAN);

      //チェックボックス選択できる演算子
      List<Map<String,String>> bol = new List<Map<String,String>>();
      bol.add(none1);
      bol.add(equal);
      bol.add(noequal);
      this.typeCondition.put('BOOLEAN',bol);

      List<Map<String,String>> str = new List<Map<String,String>>();
      str.add(none1);
      str.add(equal);
      str.add(noequal);
      str.add(startwith);
      str.add(contain);
      str.add(nocontain);
      str.add(regex);
      str.add(lessthan);
      str.add(greaterthan);
      str.add(equalthan);
      str.add(greaterequalthan);

      //文字列選択できる演算子
      this.typeCondition.put('STRING',str);
      this.typeCondition.put('EMAIL',str);
      this.typeCondition.put('PHONE',str);
      this.typeCondition.put('URL',str);
      this.typeCondition.put('TEXTAREA',str);
      // SV_DEV-876 連携設定条件に名刺項目に参照項目が選択できないことを変更
      // ID と REFERENCEタイプ追加 演算子は文字列と同じ判断
      this.typeCondition.put('ID',str);
      this.typeCondition.put('REFERENCE',str);


      //数値時間選択できる演算子
      List<Map<String,String>> da = new List<Map<String,String>>();
      da.add(none1);
      da.add(equal);
      da.add(noequal);
      da.add(lessthan);
      da.add(greaterthan);
      da.add(equalthan);
      da.add(greaterequalthan);


      this.typeCondition.put('DOUBLE',da);
      this.typeCondition.put('INTEGER',da);
      this.typeCondition.put('DATE',da);
      this.typeCondition.put('DATETIME',da);
    }
  }


  //連携設定の保存(基本設定も含む)
  @TestVisible
  private class SaveRenkeiData{

    @AuraEnabled public String state{get; private set;}
    @AuraEnabled public String message{get; private set;}
    @AuraEnabled public String lastName{get; private set;}
    @AuraEnabled public String lastTime{get; private set;}
    @AuraEnabled public String lastId{get; private set;}
    @AuraEnabled public List<String> messages{get; private set;}                         //基本設定 Lastなし
    public SaveRenkeiData() {}

    //データの保存
    public void save(List<NameCardRenkeiJyoken__c> settings, Map<String,String> baseMap, Boolean jyoukenErrorBreak){

      NameCardBasicSetting__c bs = SB_NameCard_BasicSetting.getNameCardBasicSetting();
      NameCardBasicSetting__c base;
      String LastModifiedDate = String.valueOf(Datetime.valueOf(bs.LastModifiedDate));
      if (baseMap.get('LastModifiedByDate') != LastModifiedDate) {
        this.message = System.Label.SB_NC_SETTING_ERROR_OtherSection_Saved;
        // this.message = baseMap.get('LastModifiedByDate') + '    ' + LastModifiedDate;
        this.state = 'warning';
        return;
      }
      if (String.isBlank(bs.Id)) {
         base = SB_NameCard_NameCardBasicSettingDTO.Debind(baseMap, bs);
      } else {
        base = SB_NameCard_NameCardBasicSettingDTO.Debind(baseMap);
        base.Id = bs.Id;
      }

      if ((base.RenkeiContactLastName__c == false || base.RenkeiContactFirstName__c == false)&& base.RenkeiContactMail__c == false) {
        this.message = String.format(System.Label.SB_NC_SETTING_MSG_ConLeadSearchContRequireCheck, new String[]{Contact.sObjectType.getDescribe().getLabel()});
        this.state = 'ng';
        return;
      }

      if ((base.RenkeiLeadLastName__c == false || base.RenkeiLeadFirstName__c == false) && base.RenkeiLeadMail__c == false && SB_NameCard_Util.isEnableLeadExt112()) {
        this.message = String.format(System.Label.SB_NC_SETTING_MSG_ConLeadSearchContRequireCheck, new String[]{Lead.sObjectType.getDescribe().getLabel()});
        this.state = 'ng';
        return;
      }

      this.messages = new List<String>();
      Map<String, Schema.SObjectField> nameCardFieldMap = NameCard__c.sObjectType.getDescribe().fields.getMap();
      Map<ID,NameCardRenkeiJyoken__c> allData = new Map<Id,NameCardRenkeiJyoken__c>(SB_NameCard_BasicSettingUtil.getNameCardRenkeiJyoken(base.Id));

      List<NameCardRenkeiJyoken__c> updataset = new List<NameCardRenkeiJyoken__c>();
      List<NameCardRenkeiJyoken__c> insertset = new List<NameCardRenkeiJyoken__c>();
      if (settings != null) {
        for (Integer i = 0;i<settings.size();i++) {
          NameCardRenkeiJyoken__c se = settings[i];
          if (!nameCardFieldMap.containsKey(se.NameCardName__c)) {
            if (jyoukenErrorBreak) {
              continue;
            }
            this.messages.add(String.format(System.Label.SB_NC_SETTING_NoNCField_ErrorMessage,
                    new String[]{se.NameCardName__c}));
            this.state = 'ngs';
            continue;
          }
          if (String.isNotBlank(se.Id)) {
            updataset.add(se);
            if (allData.containsKey(se.Id)) {
              allData.remove(se.Id);
            }
          }
          else {
            insertset.add(se);
          }
        }
      }
      if (state == 'ngs') {
        return;
      }
      String error = '';
      Savepoint sp;
      try{
            sp = Database.setSavepoint();
            if (String.isBlank(base.Id)) {
              SB_NameCard_CrudFls.screate(new NameCardBasicSetting__c[]{base},true);
            } else {
                SB_NameCard_CrudFls.supdate(new NameCardBasicSetting__c[]{base},true);
             }


            if (updataset.size()>0) {
              SB_NameCard_CrudFls.supdate(updataset,true);
            }

            if (insertset.size()>0) {
              SB_NameCard_CrudFls.screate(insertset,true);
            }

            if (allData.values().size()>0) {
              SB_NameCard_CrudFls.sdelete(allData.values());
            }
    }
    catch(Exception e) {
      Database.rollback(sp);
      this.message = e.getMessage();
      this.state = 'ng';
      return;
    }
      String isok = '';
      if (String.isBlank(error)) {
        error =System.Label.SB_NC_MAPPING_MSG_SAVEOK;
        isok = 'ok';
        this.lastId = UserInfo.getUserId();
        this.lastName = UserInfo.getName();
        this.lastTime = String.valueOf(Datetime.valueOf([SELECT LastModifiedDate FROM NameCardBasicSetting__c ORDER BY CreatedDate ASC][0].LastModifiedDate));
      }

      Map<String,String> resp = new Map<String,String>();
      this.message = error;
      this.state = String.isBlank(isok) ? 'ng' : isok;

    }
  }

  @TestVisible

  public class RecordTypeBean{
      @AuraEnabled public String label{get;private set;}
      @AuraEnabled public String value{get;private set;}
      @AuraEnabled public String check{get;private set;}
      public RecordTypeBean(Schema.RecordTypeInfo reco,Boolean ch) {
        this.label = reco.Name;
        this.value = reco.getRecordTypeId();
        this.check = String.valueof(ch);
      }

      public RecordTypeBean() {}
  }




  @RemoteAction
  @AuraEnabled
  //データを取得
  public static String getAllData(){
    List<NameCardRenkeiJyoken__c> sl = SB_NameCard_BasicSettingUtil.getNameCardRenkeiJyoken(null);
    List<SB_NameCard_NameCardRenkeiJyokenDTO> maps = new List<SB_NameCard_NameCardRenkeiJyokenDTO>();
    for (NameCardRenkeiJyoken__c jyo : sl) {
      SB_NameCard_NameCardRenkeiJyokenDTO n = new SB_NameCard_NameCardRenkeiJyokenDTO();
      n.bind(jyo);
      maps.add(n);
    }
    return JSON.serialize(maps);
  }

  @RemoteAction
  @AuraEnabled
  //データを保存
  public static String saveSetting(String settings,Map<String,String> base, Boolean jyoukenErrorBreak){
    SB_NameCard_NameCardRenkeiJyokenDTO[] lstFilters = new List<SB_NameCard_NameCardRenkeiJyokenDTO>();
    if (String.isNotBlank(settings)) {
      lstFilters = (List<SB_NameCard_NameCardRenkeiJyokenDTO> )System.JSON.deserializeStrict(settings, List<SB_NameCard_NameCardRenkeiJyokenDTO> .Class);
    }

    SaveRenkeiData sa = new SaveRenkeiData();
    List<NameCardRenkeiJyoken__c> jss = new List<NameCardRenkeiJyoken__c>();
    for (SB_NameCard_NameCardRenkeiJyokenDTO dto : lstFilters) {
      jss.add(dto.debind());
    }
    sa.save(jss, base, jyoukenErrorBreak);
    return JSON.serialize(sa);

  }


  @RemoteAction
  @AuraEnabled
  //連携條件の選択リストを
  public static String getAllMap(){
    return JSON.serialize(new RenkeiPageAllDate());
  }

}