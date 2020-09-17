/**
 *
 * SB_NameCard_RenkeiMappingLcController    (SB_NameCard_Renkei使用するクラス)
 * マッピング設定画面データの取得、切り替え、保存削除など
 *
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.20      2017.02.15
 *  @Version 1.22      2017.07.XX   SV_DEV-501 連携設定で レコードタイプの選択は、チェックボックスのリスト型にする。
 *  @Version 1.22      2017.10.XX   SV_DEV-614 トランスレーションワークベンチの上書き:名刺連携項目マッピングのレコードタイプ表示ラベルの変更
 *  @Version 1.22      2017.11.XX  SV_DEV-690  連携マッピング項目設定する際に、IDの項目設定する際に、URL、Emailが候補一覧に出てしまいました
 *  @Version 1.22      2018.02.XX SV_DEV-735 基本設定レコードが二つ作成される
 *  @Version 2.0.2     2018.07.XX SV_DEV-1063 基本パッケージリード連携マッピングリードデフォルトの時問題があります
 *  @Version 2.0.3     2018.09.XX SV_DEV-1209 [要望]（LEX用・Classic用「SmartVisca設定」SmartVisca連携マッピング画面)連携先オブジェクトの選択プルダウンで一番上をリードにしてほしい
 *  @Version 2.4       2019.05.XX SV_DEV-1630 [要望] 名刺：カスタムオブジェクトID と　取引先責任者：名刺　のマッピング を削除できないようにする(合わせて変数名・メソッド名を修正)
 *                     2019.07.XX SV_DEV-1212 [要望]（LEX用・Classic用「SmartVisca設定」SmartVisca連携マッピング画面)連携マッピングのタイトルと説明が欲しい
 *                     2019.08.XX SV_DEV-1630 固定のマッピングが削除された場合/無効化された場合にエラーメッセージを出すよう変更
 *
 **/


public with sharing class SB_NameCard_RenkeiMappingLcController {

  //取引先デフォルトマッピング
  private static final Map<String,String> ACCOUNT_DEF = new Map<String,String>{SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','company_name__c')=>'Name', 'OwnerId' => 'OwnerId', 'Id' => SB_NameCard_Util.getNamespacePrefix_x() + 'NameCard__c'};
  //取引先責任者デフォルトマッピング
  private static final Map<String,String> CONTACT_DEF = new Map<String,String>{'last_name'=>'LastName',SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','account__c')=>'AccountId', 'OwnerId' => 'OwnerId', 'Id' => SB_NameCard_Util.getNamespacePrefix_x() + 'NameCard__c'};
  //リードデフォルトマッピング
  private static final Map<String,String> LEAD_DEF = new Map<String,String>{'last_name'=>'LastName',SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','company_name__c')=>'Company', 'OwnerId' => 'OwnerId', 'Id' => SB_NameCard_Util.getLeadExNamespacePrefix_x() + 'NameCard__c'};

  private static final String NRM = SB_NameCard_RenkeiMapperUtil.getManagedObjectName('NameCardRenkeiMapping__c');

  private static Map<String,String> recTypeMap{
    get{
      if (recTypeMap == null) {
        recTypeMap = new Map<String,String>();
        List<Schema.RecordTypeInfo> rectypeInfos = NameCardRenkeiMapping__c.getSObjectType().getDescribe().getRecordTypeInfos();
        for (Schema.RecordTypeInfo rectypeInfo : rectypeInfos) {
          recTypeMap.put(rectypeInfo.getRecordTypeId(),rectypeInfo.getName());
        }
      }
      return recTypeMap;
    }set;
  }

  @TestVisible
  public class RenkeiMappingAlldata{
    @AuraEnabled public Map<String,String> namecardDataTypeMap{get; private set;}                         //名刺項目タイプ
    @AuraEnabled public Map<String,String> obj2DataTypeMap{get; private set;}                             //連携先項目タイプ
    @AuraEnabled public Map<String,String> namecardLabelNameMap{get; private set;}                        //名刺項目表示ラベル
    @AuraEnabled public Map<String,String> obj2LabelNameMap{get; private set;}                            //連携先項目表示ラベル
    @AuraEnabled public Map<String,String> recordTypeMap{get; private set;}                               //レコードタイプName->Id
    @AuraEnabled public String             nameSpace{get; private set;}                                   //ネームスペースw
    @AuraEnabled public String             recordTypeId{get; private set;}                                //使ってない？
    @AuraEnabled public String             recordTypeName{get; private set;}                              //使ってない？
    @AuraEnabled public String             namecardLabel{get; private set;}                               //名刺オブジェクト表示ラベル
    @AuraEnabled public String             obj2Label{get; private set;}                                   //参照先表示ラベル
    @AuraEnabled public List<String>       namecardLabelKeyList{get; private set;}                        //名刺項目List
    @AuraEnabled public List<SB_NameCard_NameCardRenkeiMappingDTO> mappingList{get; private set;}             //連携マッピング
    @AuraEnabled public List<SB_NameCard_NameCardRenkeiMappingDTO> requiredAccMappingList{get; private set;}   //取引先必須マッピング
    @AuraEnabled public List<SB_NameCard_NameCardRenkeiMappingDTO> requiredConMappingList{get; private set;}   //取引先責任者必須マッピング
    @AuraEnabled public List<SB_NameCard_NameCardRenkeiMappingDTO> requiredLeadMappingList{get; private set;}  //リード必須マッピング
    @AuraEnabled public Map<String,List<String>> dataTypeMap{get; private set;}                           //連携先項目タイプMap
    @AuraEnabled public List<String> typeList{get; private set;}  //全てのデータタイプ
    @AuraEnabled public String lastId{get; private set;}  //最新更新者ID
    @AuraEnabled public String lastName{get; private set;}  //最新更新者名
    @AuraEnabled public String lastTime{get; private set;}  //最新更新日
    @AuraEnabled public List<String> namecardMsgList{get; private set;}//名刺項目エラーメッセージ
    @AuraEnabled public List<String> obj2MsgList{get; private set;}//オブジェクト２項目エラーメッセージ
    @AuraEnabled public String warningMsg{get; private set;}// ウォーニングメッセージ


    public RenkeiMappingAlldata() {
      this.obj2DataTypeMap = new Map<String,String>();
      this.obj2LabelNameMap = new Map<String,String>();
      this.recordTypeMap = new Map<String,String>();
      this.dataTypeMap = new Map<String,List<String>>();
      this.mappingList = new List<SB_NameCard_NameCardRenkeiMappingDTO>();
      this.requiredConMappingList = new List<SB_NameCard_NameCardRenkeiMappingDTO>();
      this.requiredAccMappingList = new List<SB_NameCard_NameCardRenkeiMappingDTO>();
      this.requiredLeadMappingList = new List<SB_NameCard_NameCardRenkeiMappingDTO>();
      this.namecardLabelKeyList = new List<String>();
      this.typeList = new List<String>();
      this.namecardLabel = '';
      this.obj2Label = '';
      this.namecardMsgList = new List<String>();
      this.obj2MsgList = new List<String>();
    }

    //連携に関するデータを取得
    public RenkeiMappingAlldata(String record){
      Integer ind = String.isBlank(SB_NameCard_Util.getNamespacePrefix_x()) ? 0 : 1;
      this.nameSpace = SB_NameCard_Util.getNamespacePrefix_x();
      this.requiredConMappingList = new List<SB_NameCard_NameCardRenkeiMappingDTO>();
      this.requiredAccMappingList = new List<SB_NameCard_NameCardRenkeiMappingDTO>();
      this.requiredLeadMappingList = new List<SB_NameCard_NameCardRenkeiMappingDTO>();

      this.obj2DataTypeMap = new Map<String,String>();
      this.obj2LabelNameMap = new Map<String,String>();
      this.recordTypeMap = new Map<String,String>();

      this.setRecordType(record);

      this.setNamecard();

      NameCardBasicSetting__c bb = SB_NameCard_BasicSetting.getNameCardBasicSetting();

      if (String.isBlank(bb.Id)) {
        this.warningMsg = System.Label.SB_NC_SETTING_ERROR_No_NameCardBasicSetting;
      }

      this.dataTypeMap = SB_NameCard_RenkeiMapperUtil.createApiNameKeyDataTypeMap(record,this.obj2DataTypeMap,this.obj2LabelNameMap,this.obj2Label + ' : ',false);
      List<NameCardRenkeiMapping__c> maps = SB_NameCard_BasicSettingUtil.getNameCardMapping(this.recordTypeMap.get(record), null);

      this.mappingList = new List<SB_NameCard_NameCardRenkeiMappingDTO>();
      //削除されたのAPIを保存
      this.namecardMsgList = new List<String>();
      this.obj2MsgList = new List<String>();
      Set<String> itiset = new Set<String>();
      //不具合マッピングデータを削除
      //List<NameCardRenkeiMapping__c> dele = new List<NameCardRenkeiMapping__c>();
      for (NameCardRenkeiMapping__c ma : maps) {
        if ((!obj2LabelNameMap.containsKey(ma.TargetName__c) || !namecardLabelNameMap.containsKey(ma.NameCardName__c))  && (ma.TargetName__c != 'AccountId' && ma.NameCardName__c != SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','account__c'))) {
          if (!obj2LabelNameMap.containsKey(ma.TargetName__c)) {
            this.obj2MsgList.add(String.format(System.Label.SB_NC_MAPPING_Mapping_errorMessage,new String[]{obj2Label,ma.TargetName__c}));
          }
          if (!namecardLabelNameMap.containsKey(ma.NameCardName__c)) {
            this.namecardMsgList.add(String.format(System.Label.SB_NC_MAPPING_Mapping_errorMessage,new String[]{namecardLabel,ma.NameCardName__c}));
            //this.nameCardMsg.add(new MyMsgBean(String.format(String.format(String.format(System.Label.SB_NC_MAPPING_Mapping_errorMessage,new String[]{nameCardLabel,ma.NameCardName__c}),!this.nameCardMsg.isEmpty())));
          }
          //dele.add(ma);
          continue;
        }
        SB_NameCard_NameCardRenkeiMappingDTO dto = new SB_NameCard_NameCardRenkeiMappingDTO();

        if (itiset.contains(ma.recordTypeId+ma.TargetName__c.removeEnd('Longitude__s'))) {
          continue;
        }

        if (itiset.contains(ma.recordTypeId+ma.TargetName__c.removeEnd('Latitude__s'))) {
          continue;
        }

        if (!this.namecardLabelNameMap.keySet().contains(ma.NameCardName__c)) {
          ma.NameCardName__c = SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c',ma.NameCardName__c);
        }

        if (ma.NameCardName__c.endswith('Latitude__s')) {
          ma.NameCardName__c = ma.NameCardName__c.removeEnd('Latitude__s') + 'c';
          itiset.add(ma.recordTypeId+ma.TargetName__c.removeEnd('Latitude__s'));
          ma.TargetName__c = ma.TargetName__c.removeEnd('Latitude__s') + 'c';
        }
        if (ma.NameCardName__c.endswith('Longitude__s')) {
          ma.NameCardName__c = ma.NameCardName__c.removeEnd('Longitude__s') + 'c';
          itiset.add(ma.recordTypeId+ma.TargetName__c.removeEnd('Longitude__s'));
          ma.TargetName__c = ma.TargetName__c.removeEnd('Longitude__s') + 'c';
        }

        dto.bind(ma);
        //必須表示を設定
        if (record == 'Account') {
          if (ACCOUNT_DEF.containsKey(ma.NameCardName__c) && ACCOUNT_DEF.get(ma.NameCardName__c) == ma.TargetName__c) {
            dto.NameCardLabel = this.namecardLabelNameMap.get(ma.NameCardName__c);
            dto.TagetLabel = obj2LabelNameMap.get(ACCOUNT_DEF.get(ma.NameCardName__c));
            // 有効なもののみ表示させる・無効なものは警告メッセージ
            if (dto.IsActive == 'true'){
              // 会社名は必ず先頭
              if (ma.NameCardName__c == SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c', 'company_name__c') && this.requiredAccMappingList.size() > 0) {
                this.requiredAccMappingList.add(0, dto);
              } else {
                this.requiredAccMappingList.add(dto);
              }
            } else {
              String ncName = this.namecardLabelNameMap.get(ma.NameCardName__c);
              String targetName = obj2LabelNameMap.get(ACCOUNT_DEF.get(ma.NameCardName__c));
              this.namecardMsgList.add(String.format(System.Label.SB_NC_MAPPING_KoteiMappingInactivate_ErrorMessage,new String[]{ncName,targetName}));
            }
            continue;
          }
        } else if (record == 'Contact') {
          if (CONTACT_DEF.containsKey(ma.NameCardName__c) && CONTACT_DEF.get(ma.NameCardName__c) == ma.TargetName__c) {
            dto.NameCardLabel = this.namecardLabelNameMap.get(ma.NameCardName__c);
            dto.TagetLabel = obj2LabelNameMap.get(CONTACT_DEF.get(ma.NameCardName__c));
            // 有効なもののみ表示させる・無効なものは警告メッセージ
            if (dto.IsActive == 'true'){
              // 姓は必ず先頭
              if (ma.NameCardName__c == 'last_name' && this.requiredConMappingList.size() > 0) {
                this.requiredConMappingList.add(0, dto);
              // 取引先ID
              } else if (ma.NameCardName__c == SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','account__c')){
                dto.TagetLabel = this.obj2Label + ' : ' + Contact.AccountId.getDescribe().getLabel(); // 例外的にラベルを上書き
                // 2番目に来るように入れる
                if (this.requiredConMappingList.size() > 0) {
                  if (this.requiredConMappingList[0].NameCardName == 'last_name') {
                    if (this.requiredConMappingList.size() > 1) {
                      this.requiredConMappingList.add(1, dto);
                    } else {
                      this.requiredConMappingList.add(dto);
                    }
                  } else {
                    this.requiredConMappingList.add(0,dto);
                  }
                } else {
                  this.requiredConMappingList.add(dto);
                }
              } else {
                this.requiredConMappingList.add(dto);
              }
            } else {
              String ncName = this.namecardLabelNameMap.get(ma.NameCardName__c);
              String targetName = ma.NameCardName__c == SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','account__c') ?
                                    this.obj2Label + ' : ' + Contact.AccountId.getDescribe().getLabel() :
                                    obj2LabelNameMap.get(CONTACT_DEF.get(ma.NameCardName__c));
              this.namecardMsgList.add(String.format(System.Label.SB_NC_MAPPING_KoteiMappingInactivate_ErrorMessage,new String[]{ncName,targetName}));
            }
            continue;
          }
        } else if (record == 'Lead') {
          if (LEAD_DEF.containsKey(ma.NameCardName__c) && LEAD_DEF.get(ma.NameCardName__c) == ma.TargetName__c){
            dto.NameCardLabel = this.namecardLabelNameMap.get(ma.NameCardName__c);
            dto.TagetLabel = obj2LabelNameMap.get(LEAD_DEF.get(ma.NameCardName__c));
            // 有効なもののみ表示させる・無効なものは警告メッセージ
            if (dto.IsActive == 'true'){
              // 姓は必ず先頭
              if (ma.NameCardName__c == 'last_name' && this.requiredLeadMappingList.size() > 0) {
                this.requiredLeadMappingList.add(0, dto);
              } else {
                this.requiredLeadMappingList.add(dto);
              }
            } else {
              String ncName = this.namecardLabelNameMap.get(ma.NameCardName__c);
              String targetName = obj2LabelNameMap.get(LEAD_DEF.get(ma.NameCardName__c));
              this.namecardMsgList.add(String.format(System.Label.SB_NC_MAPPING_KoteiMappingInactivate_ErrorMessage,new String[]{ncName,targetName}));
            }
            continue;
          }
        }
        this.mappingList.add(dto);
      }

      // 削除されたマッピングがあったら明示
      if (record == 'Account' && this.requiredAccMappingList.size() != ACCOUNT_DEF.size()){
        checkKoteiMappingDeleted(ACCOUNT_DEF,requiredAccMappingList);
      }
      if (record == 'Contact' && this.requiredConMappingList.size()  != CONTACT_DEF.size()){
        checkKoteiMappingDeleted(CONTACT_DEF,requiredConMappingList);
      }
      if (record == 'Lead' && this.requiredLeadMappingList.size() != LEAD_DEF.size()){
        checkKoteiMappingDeleted(LEAD_DEF,requiredLeadMappingList);
      }

      if (String.isNotBlank(bb.Id)) {
        this.lastId = String.isBlank(bb.MappingLastModifiedUser__c) ? '' : bb.MappingLastModifiedUser__c;
        //this.lastName = String.isBlank(bb.MappingLastModifiedUser__r.Name) ? System.Label.SB_NC_MAPPING_NOUPDATE : bb.MappingLastModifiedUser__r.Name;
        this.lastTime = bb.MappingLastModifiedDateTime__c == null ? '' : String.valueOf(bb.MappingLastModifiedDateTime__c);
      } else {
        this.lastId = '';
        this.lastName = System.Label.SB_NC_MAPPING_NOUPDATE;
      }

      this.namecardLabelKeyList = new List<String>();
      for (String str : this.namecardLabelNameMap.keySet()) {
        if (str == SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','account__c') || str.endswith('__Latitude__s') || str.endswith('__Longitude__s')) {
          continue;
        }
        this.namecardLabelKeyList.add(str);
      }
      this.typeList = new List<String>();
      for (String str : this.dataTypeMap.keySet()) {
       typeList.add(str);
      }
    }

    //固定マッピングの削除チェック
    private void checkKoteiMappingDeleted(Map<String,String> defMap,List<SB_NameCard_NameCardRenkeiMappingDTO> reqMappingList){
      for (String key : defMap.keySet()){
        Boolean findFlg = false;
        for (SB_NameCard_NameCardRenkeiMappingDTO dto : reqMappingList){
          if (dto.NameCardName == key && dto.TargetName == defMap.get(key)){
            findFlg = true;
            break;
          }
        }
        if (!findFlg){
          String ncName = this.namecardLabelNameMap.get(key);
          String targetName = key == SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','account__c') ?
                                  this.obj2Label + ' : ' + Contact.AccountId.getDescribe().getLabel() :
                                  obj2LabelNameMap.get(defMap.get(key));
          if (!this.namecardMsgList.contains(String.format(System.Label.SB_NC_MAPPING_KoteiMappingInactivate_ErrorMessage,new String[]{ncName,targetName}))){
            this.namecardMsgList.add(String.format(System.Label.SB_NC_MAPPING_KoteiMappingDeleted_ErrorMessage,new String[]{ncName,targetName}));
          }
        }
      }
    }

    //レコードタイプIDを取得
    private void setRecordType(String record) {
      this.recordTypeName = record;
      this.namecardLabel = NameCard__c.sObjectType.getDescribe().getLabel();
      this.obj2Label  = Schema.getGlobalDescribe().get(record).getDescribe().getLabel();

      List<Schema.RecordTypeInfo> rectypeInfos = NameCardRenkeiMapping__c.getSObjectType().getDescribe().getRecordTypeInfos();

      // List<Recordtype> recordTypes = [Select DeveloperName, Id From Recordtype Where SobjectType = :NRM AND IsActive = true];
      for (Schema.RecordTypeInfo rectypeInfo : rectypeInfos) {
        this.recordTypeMap.put(rectypeInfo.Name, rectypeInfo.getRecordTypeId());
      }
      //this.recordTypeMap = SB_NameCard_RenkeiMappingLcController.recTypeMap;
      this.recordTypeId = this.recordTypeMap.get(this.recordTypeName);
    }

    //名刺の項目リストを作成
    private void setNamecard() {
      this.namecardDataTypeMap = new Map<String,String>();
      this.namecardLabelNameMap = new Map<String,String>();
      this.namecardLabelNameMap.put('',System.Label.SB_NC_SETTING_LABEL_NONE);
      SB_NameCard_RenkeiMapperUtil.createApiNameKeyDataTypeMap('NameCard__c',this.namecardDataTypeMap,this.namecardLabelNameMap,this.namecardLabel + ' : ',false);
      this.namecardDataTypeMap.put('first_name','STRING');
      this.namecardDataTypeMap.put('last_name','STRING');
      this.namecardLabelNameMap.put('first_name',this.namecardLabel  + + ' : ' + NameCard__c.person_name_first__c.getDescribe().getLabel() + ' ' + System.Label.SB_NC_MAPPING_LABEL_OR + ' ' + NameCard__c.first_name__c.getDescribe().getLabel());
      this.namecardLabelNameMap.put('last_name',this.namecardLabel  + ' : ' + NameCard__c.person_name_last__c.getDescribe().getLabel() + ' ' + System.Label.SB_NC_MAPPING_LABEL_OR + ' ' + NameCard__c.last_name__c.getDescribe().getLabel());
    }

 }

 //メタデータ設定
  @TestVisible
  private class Metadata{
    @AuraEnabled public List<SB_NameCard_NameCardRenkeiMappingDTO> mappingList{get;  private set;}

    public Metadata() {}
    @AuraEnabled public Map<String,String> namecardDataTypeMap{get; private set;}                       //名刺項目タイプ
    @AuraEnabled public Map<String,String> namecardLabelNameMap{get; private set;}                      //名刺項目表示らべる
    @AuraEnabled public Map<String,String> obj2LabelNameMap{get; private set;}                          //連携先項目表示ラベル
    @AuraEnabled public Map<String,String> obj2DataTypeMap{get; private set;}                           //連携先項目タイプ
    @AuraEnabled public List<SB_NameCard_NameCardRenkeiMappingDTO> requiredAccMappingList{get; private set;}   //取引先必須マッピング
    @AuraEnabled public List<SB_NameCard_NameCardRenkeiMappingDTO> requiredConMappingList{get; private set;}   //取引先責任者必須マッピング
    @AuraEnabled public List<SB_NameCard_NameCardRenkeiMappingDTO> requiredLeadMappingList{get; private set;}  //リード必須マッピング
    @AuraEnabled public String             obj2Label{get; private set;}                                 //連携先表示ラベル
    @AuraEnabled public String             namecardLabel{get; private set;}                             //名刺表示ラベル
    @AuraEnabled public String             ob2api{get; private set;}                                    //連携先API名


    //デフォルト値を設定
    public void setRenkeiMappingDef(String reid,Map<String,String> obj2LabelName,String reids){
      this.ob2api = reid;
      this.namecardDataTypeMap = new Map<String,String>();
      this.namecardLabelNameMap = new Map<String,String>();
      this.obj2LabelNameMap = new Map<String,String>();
      this.obj2DataTypeMap = new Map<String,String>();
      this.requiredConMappingList = new List<SB_NameCard_NameCardRenkeiMappingDTO>();
      this.requiredLeadMappingList = new List<SB_NameCard_NameCardRenkeiMappingDTO>();
      this.requiredAccMappingList = new List<SB_NameCard_NameCardRenkeiMappingDTO>();
      this.obj2Label  = Schema.getGlobalDescribe().get(reid).getDescribe().getLabel();
      SB_NameCard_RenkeiMapperUtil.createApiNameKeyDataTypeMap(reid,this.obj2DataTypeMap,this.obj2LabelNameMap,this.obj2Label + ' : ',false);
      this.setNamecard();
      this.mappingList = new List<SB_NameCard_NameCardRenkeiMappingDTO>();
      //メタデータ取得
      List<DefaultRenkeiMapping__mdt> metas = SB_NameCard_BasicSettingUtil.getMappingMetadata(reid);
      //List<DefaultRenkeiMapping__mdt> metas = [Select ID,TargetName__c,NameCardName__c,IsActive__c,recordtype__c
      //                                                  From DefaultRenkeiMapping__mdt
      //                                                  Where recordtype__c = :reid] ;
      // SV_DEV-1063 基本パッケージリード連携マッピングリードデフォルトの時問題があります
      String ra = reid == 'Lead' ? 'lead' : 'All';
      String namecard = SB_NameCard_RenkeiMapperUtil.getManagedObjectName('NameCard__c');
      Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
      Schema.SObjectType leadSchema = schemaMap.get(namecard);
      Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
      this.mappingList = new List<SB_NameCard_NameCardRenkeiMappingDTO>();
      for (Integer i =0;i<metas.size();i++) {
        SB_NameCard_NameCardRenkeiMappingDTO dto = new SB_NameCard_NameCardRenkeiMappingDTO();
        //if (metas[i].recordtype__c == 'Contact' && ((metas[i].NameCardName__c == 'account__c' || metas[i].NameCardName__c == 'smvTest__account__c') && metas[i].TargetName__c == 'AccountId')) {
            //continue;
        //}
        DefaultRenkeiMapping__mdt meta = metas[i];
        String fp = SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c',meta.NameCardName__c);
        if (reid == 'Account') {
          if ((ACCOUNT_DEF.containsKey(fp) && ACCOUNT_DEF.get(fp) == meta.TargetName__c)
              || (meta.NameCardName__c == 'OwnerId' && meta.TargetName__c == ACCOUNT_DEF.get(meta.NameCardName__c))
              || (meta.NameCardName__c == 'Id' && SB_NameCard_Util.getNamespacePrefix_x() + meta.TargetName__c == ACCOUNT_DEF.get(meta.NameCardName__c))) {

            if (meta.NameCardName__c == 'OwnerId' || meta.NameCardName__c == 'Id') {
              dto.NameCardLabel = this.namecardLabelNameMap.get(meta.NameCardName__c);
              dto.TagetLabel = obj2LabelNameMap.get(ACCOUNT_DEF.get(meta.NameCardName__c));
              this.requiredAccMappingList.add(dto);
            }
            else {
              dto.NameCardLabel = this.namecardLabelNameMap.get(SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c',fp));
              dto.TagetLabel = obj2LabelNameMap.get(ACCOUNT_DEF.get(fp));
              if (meta.NameCardName__c == 'company_name__c' && this.requiredAccMappingList.size() > 0) {
                this.requiredAccMappingList.add(0, dto);
              } else {
                this.requiredAccMappingList.add(dto);
              }
            }
            continue;
          }
        } else if (reid == 'Contact') {
          if ((CONTACT_DEF.containsKey(fp) && CONTACT_DEF.get(fp) == meta.TargetName__c) 
                || ((meta.NameCardName__c == 'last_name' || meta.NameCardName__c == 'OwnerId')
                    && meta.TargetName__c == CONTACT_DEF.get(meta.NameCardName__c))
                || (meta.NameCardName__c == 'Id' && SB_NameCard_Util.getNamespacePrefix_x() + meta.TargetName__c == CONTACT_DEF.get(meta.NameCardName__c))) {
            String acf = 'account__c';
            if (meta.NameCardName__c == 'last_name') {
              dto.NameCardLabel = this.namecardLabelNameMap.get(meta.NameCardName__c);
              dto.TagetLabel = obj2LabelNameMap.get(CONTACT_DEF.get(meta.NameCardName__c));
              if (this.requiredConMappingList.size() > 0) {
                this.requiredConMappingList.add(0, dto);
              } else {
                this.requiredConMappingList.add(dto);
              }
            } else if (meta.NameCardName__c == acf) {
              dto.NameCardLabel = this.namecardLabelNameMap.get(SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','account__c'));
              dto.TagetLabel = this.obj2Label + ' : ' + Contact.AccountId.getDescribe().getLabel();
              if (this.requiredConMappingList.size() > 0) {
                if (this.requiredConMappingList[0].NameCardName == 'last_name') {
                  if (this.requiredConMappingList.size() > 1) {
                    this.requiredConMappingList.add(1, dto);
                  } else {
                    this.requiredConMappingList.add(dto);
                  }
                } else {
                  this.requiredConMappingList.add(0,dto);
                }
              } else {
                 this.requiredConMappingList.add(dto);
              }
            } else if (meta.NameCardName__c == 'OwnerId' || meta.NameCardName__c == 'Id') {
              dto.NameCardLabel = this.namecardLabelNameMap.get(meta.NameCardName__c);
              dto.TagetLabel = obj2LabelNameMap.get(CONTACT_DEF.get(meta.NameCardName__c));
              this.requiredConMappingList.add(dto);

            } else {
              dto.NameCardLabel = this.namecardLabelNameMap.get(SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c',fp));
              dto.TagetLabel = obj2LabelNameMap.get(CONTACT_DEF.get(fp));
              this.requiredConMappingList.add(dto);
            }
            continue;
          }
        } else if (reid == 'Lead') {
          if ((LEAD_DEF.containsKey(fp) && LEAD_DEF.get(fp) == meta.TargetName__c)
              || ((meta.NameCardName__c == 'last_name' || meta.NameCardName__c == 'OwnerId'))
                  && meta.TargetName__c == LEAD_DEF.get(meta.NameCardName__c)
              || (meta.NameCardName__c == 'Id' && SB_NameCard_Util.getLeadExNamespacePrefix_x() + meta.TargetName__c == LEAD_DEF.get(meta.NameCardName__c))) {

            if (meta.NameCardName__c == 'last_name') {
              dto.NameCardLabel = this.namecardLabelNameMap.get('last_name');
              dto.TagetLabel = obj2LabelNameMap.get(LEAD_DEF.get('last_name'));
              if (this.requiredLeadMappingList.size() > 0) {
                this.requiredLeadMappingList.add(0, dto);
              } else {
                this.requiredLeadMappingList.add(dto);
              }
            } else if (meta.NameCardName__c == 'OwnerId' || meta.NameCardName__c == 'Id') {
              dto.NameCardLabel = this.namecardLabelNameMap.get(meta.NameCardName__c );
              dto.TagetLabel = obj2LabelNameMap.get(LEAD_DEF.get(meta.NameCardName__c));
              this.requiredLeadMappingList.add(dto);
            } else {
              dto.NameCardLabel = this.namecardLabelNameMap.get(fp);
              dto.TagetLabel = obj2LabelNameMap.get(LEAD_DEF.get(fp));
              this.requiredLeadMappingList.add(dto);
            }
            continue;
          }
        }
        NameCardRenkeiMapping__c renkeiMapping = new NameCardRenkeiMapping__c();
        if (obj2LabelName.containsKey(meta.TargetName__c)) {
            renkeiMapping.TargetName__c = meta.TargetName__c;
        } else {
          renkeiMapping.TargetName__c = SB_NameCard_RenkeiMapperUtil.getManagedfileName(ra, meta.TargetName__c);
        }
        String hsf = SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c',meta.NameCardName__c);
        if ((fieldMap.containsKey(meta.NameCardName__c) && !fieldMap.containsKey(hsf)) || SB_NameCard_RenkeiMapperUtil.ADDRESS_FIELDS.contains(meta.NameCardName__c) || meta.NameCardName__c == 'first_name' || meta.NameCardName__c == 'last_name') {
          renkeiMapping.NameCardName__c = meta.NameCardName__c;
        } else {
          renkeiMapping.NameCardName__c = hsf;
        }
        renkeiMapping.IsActive__c = true;
        renkeiMapping.RecordTypeId = reids;
        SB_NameCard_NameCardRenkeiMappingDTO dto1 = new SB_NameCard_NameCardRenkeiMappingDTO();
        dto1.bind(renkeiMapping);
        this.mappingList.add(dto1);
      }
    }

    private void setNamecard(){
      this.namecardLabel = NameCard__c.sObjectType.getDescribe().getLabel();
      this.namecardDataTypeMap = new Map<String,String>();
      this.namecardLabelNameMap = new Map<String,String>();
      this.namecardLabelNameMap.put('',System.Label.SB_NC_SETTING_LABEL_NONE);
      SB_NameCard_RenkeiMapperUtil.createApiNameKeyDataTypeMap('NameCard__c',this.namecardDataTypeMap,this.namecardLabelNameMap,this.namecardLabel + ' : ',false);
      this.namecardDataTypeMap.put('first_name','STRING');
      this.namecardDataTypeMap.put('last_name','STRING');
      this.namecardLabelNameMap.put('first_name',this.namecardLabel  + + ' : ' + NameCard__c.person_name_first__c.getDescribe().getLabel() + ' ' + System.Label.SB_NC_MAPPING_LABEL_OR + ' ' + NameCard__c.first_name__c.getDescribe().getLabel());
      this.namecardLabelNameMap.put('last_name',this.namecardLabel  + ' : ' + NameCard__c.person_name_last__c.getDescribe().getLabel() + ' ' + System.Label.SB_NC_MAPPING_LABEL_OR + ' ' + NameCard__c.last_name__c.getDescribe().getLabel());
    }
    // public void setobj2s(String record)
    //{
    //    SB_NameCard_RenkeiMapperUtil.createApiNameKeyDataTypeMap(record,this.obj2DataTypeMap,this.obj2LabelNameMap,this.obj2Label + ' : ',false);
    //}
  }

  @TestVisible
  private class RecordTypedata{
    @AuraEnabled public List<SB_NameCard_NameCardRenkeiMappingDTO> mappingList{get;set;}
    @AuraEnabled public Map<String,String> obj2DataTypeMap{get; private set;}
    @AuraEnabled public Map<String,String> obj2LabelNameMap{get; private set;}
    @AuraEnabled public Map<String,List<String>> dataTypeMap{get; private set;}
    @AuraEnabled public List<String> namecardLabelKeyList{get; private set;}
    @AuraEnabled public List<String> typeList{get; private set;}
    @AuraEnabled public String             obj2Label{get; private set;}
    @AuraEnabled public String lastId{get; private set;}  //最新更新者ID
    @AuraEnabled public String lastName{get; private set;}  //最新更新者名
    @AuraEnabled public String lastTime{get; private set;}  //最新更新日

    public RecordTypedata() {}

    //レコードタイプ変更
    public void changeRecordType(String re,String reid) {
      try{

        this.obj2DataTypeMap = new Map<String,String>();
        this.obj2LabelNameMap = new Map<String,String>();
        this.setobj2s(re);
        this.obj2Label  = Schema.getGlobalDescribe().get(re).getDescribe().getLabel();
        List<NameCardRenkeiMapping__c> maps = SB_NameCard_BasicSettingUtil.getNameCardMapping(reid, obj2LabelNameMap.Keyset());
        //List<NameCardRenkeiMapping__c> maps = [select Id,Name,RecordTypeId,TargetName__c,NameCardName__c,IsActive__c,LastModifiedDate,LastModifiedById,LastModifiedBy.Name
        //                                    from NameCardRenkeiMapping__c Where RecordTypeId = :reid AND BasicSetting__c != null AND TargetName__c IN :obj2LabelNameMap.Keyset()
        //                                    limit 10000 ];
        this.mappingList = new List<SB_NameCard_NameCardRenkeiMappingDTO>();
        for (NameCardRenkeiMapping__c ma : maps) {
          SB_NameCard_NameCardRenkeiMappingDTO dto = new SB_NameCard_NameCardRenkeiMappingDTO();
          dto.bind(ma);
          this.mappingList.add(dto);
        }
        if (this.mappingList.size() > 0) {
          this.lastId = this.mappingList[0].LastModifiedById;
          this.lastName = this.mappingList[0].LastModifiedByName;
          this.lastTime = this.mappingList[0].LastModifiedByDate;
        }else {
          this.lastTime = System.Label.SB_NC_MAPPING_NOUPDATE;
        }
     }
     catch (Exception e) {
         ApexPages.addMessages(e);
     }
     return;
    }

    //連携先の選択リストを作成
    public void setobj2s(String record){
      this.dataTypeMap = SB_NameCard_RenkeiMapperUtil.createApiNameKeyDataTypeMap(record,this.obj2DataTypeMap,this.obj2LabelNameMap,this.obj2Label + ' : ',false);
      this.namecardLabelKeyList = new List<String>();
      this.typeList = new List<String>();
      for (String str : this.dataTypeMap.keySet()) {
        typeList.add(str);
      }
    }
 }


  //レコードタイプを取得
  @RemoteAction
  @AuraEnabled
  public static String getMyMap(){
    return JSON.serialize(new RecordTypebin());
  }

  public static RecordTypebin getMyRecordType(){
    return new RecordTypebin();
  }

  @TestVisible
  public class RecordTypebin{
    @AuraEnabled public List<String> keys{get; private set;}
    @AuraEnabled public List<String> os{get; private set;}
    @AuraEnabled public Map<String,String> typeMaps{get; private set;}
    @AuraEnabled public Map<String,String> labelMaps{get; private set;}
    @AuraEnabled public Map<String,String> labMap{get; private set;}
    //@AuraEnabled public String errorMessage{get;set;}
    //@AuraEnabled public String avMessage{get;set;}
    @AuraEnabled public List<String> errorMessage{get; private set;}
    @AuraEnabled public List<String> avMessage{get; private set;}
    @AuraEnabled public Boolean isEnableLeadExtention{get; private set;}  //リード拡張パッケージ存在するか

    //レコードタイプを取得
    public RecordTypebin(){
      this.labMap = SB_NameCard_RenkeiMapperUtil.changeLabeltoMap('mapping');
      this.typeMaps = new Map<String,String>();
      this.labelMaps = new Map<String,String>();
      Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
      List<Schema.RecordTypeInfo> rectypeInfos = NameCardRenkeiMapping__c.getSObjectType().getDescribe().getRecordTypeInfos();
      // List<Recordtype> recordTypes = [Select DeveloperName, Id, Name, IsActive From Recordtype 
      //                      Where SobjectType = :NRM];
      this.errorMessage = new List<String>();
      this.avMessage = new List<String>();
      String objname = NameCardRenkeiMapping__c.sObjectType.getDescribe().getLabel();
      this.isEnableLeadExtention = SB_NameCard_Util.isEnableLeadExt112();
      for (Schema.RecordTypeInfo rectypeInfo : rectypeInfos) {
        if (rectypeInfo.isMaster()) {
          continue;
        }
        //オブジェクトがないのレコードタイプは使用しない
        if (!schemaMap.containsKey(rectypeInfo.Name) && rectypeInfo.isAvailable()) {
          // errob += rectypeInfo.getName() + ',';
          // this.errorMessage.add(new MyMsgBean(String.format(System.Label.SB_NC_MAPPING_NoObject_errorMessage,new String[]{objname,rectypeInfo.Name}),!this.errorMessage.isEmpty()));
          this.errorMessage.add(String.format(System.Label.SB_NC_MAPPING_NoObject_errorMessage,new String[]{objname,rectypeInfo.Name}));
          continue;
        }

        if (rectypeInfo.Name == 'Lead' && !SB_NameCard_Util.isEnableLeadExt112()) {
          continue;
        }

        if (rectypeInfo.isAvailable()) {
            this.typeMaps.put(rectypeInfo.getRecordTypeId(),rectypeInfo.Name);
        } else {
          //選択出きないのレコードタイプを選択させない
          // this.avMessage.add(new MyMsgBean(String.format(System.Label.SB_NC_MAPPING_NoAvailable_errorMessage,new String[]{Schema.getGlobalDescribe().get(rectypeInfo.Name).getDescribe().getLabel()}),!this.avMessage.isEmpty()));
          // aver += Schema.getGlobalDescribe().get(rectypeInfo.getName()).getDescribe().getLabel() + ',';
          continue;
        }
      }
      //this.errorMessage = String.isBlank(errob) ? '' : String.format(System.Label.SB_NC_MAPPING_NoObject_errorMessage,new String[]{Schema.getGlobalDescribe().get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('NameCardRenkeiMapping__c')).getDescribe().getLabel(),errob.removeEnd(',')});
      //this.avMessage = String.isBlank(aver) ? '' : String.format(System.Label.SB_NC_MAPPING_NoAvailable_errorMessage,new String[]{aver.removeEnd(',')});
      this.keys = new List<String>();
      this.os = new List<String>();
      for (String str :  typeMaps.keySet()) {
        String label = schemaMap.get(typeMaps.get(str)).getDescribe().getLabel();
        labelMaps.put(str,label);
        if (typeMaps.get(str).toLowerCase() == 'lead') {
          this.os.add(0, typeMaps.get(str));
          this.keys.add(0, str);
        }
        else {
          this.os.add(typeMaps.get(str));
          this.keys.add(str);
        }
      }
    }
  }

  @TestVisible
  public class Renkeidata{
    @AuraEnabled public String lastId{get; private set;}  //最新更新者ID
    @AuraEnabled public String lastName{get; private set;}  //最新更新者名
    @AuraEnabled public String lastTime{get; private set;}  //最新更新日
    @AuraEnabled public String state{get; private set;}  //最新更新日
    @AuraEnabled public String message{get; private set;}  //最新更新日

    public Renkeidata() {}

    //データを保存
    public  void saveData(List<NameCardRenkeiMapping__c> maps,String record,String reco) {
        NameCardBasicSetting__c bs = SB_NameCard_BasicSetting.getNameCardBasicSetting();
        if (String.isBlank(bs.Id)) {
          insert bs;
        }
        Map<String,Set<Schema.SObjectType>> t1 = SB_NameCard_RenkeiMapperUtil.getTypeMap('NameCard__c');
        if (String.isBlank(reco)) {
          this.message = System.Label.SB_NC_MAPPING_NO_SELECT_RENKEIOBJECT_ERRORMESSAGE;
          this.state = 'ng';
          return;
        }
        Map<String,Set<Schema.SObjectType>> t2 = SB_NameCard_RenkeiMapperUtil.getTypeMap(reco);
        Map<Id,NameCardRenkeiMapping__c> mapss =  new Map<Id,NameCardRenkeiMapping__c>(SB_NameCard_BasicSettingUtil.getNameCardMapping(record, null));//[Select id,Name,TargetName__c,NameCardName__c,IsActive__c   From NameCardRenkeiMapping__c Where RecordTypeId=:record AND BasicSetting__c != null AND BasicSetting__c = :bs.Id]);
        List<NameCardRenkeiMapping__c> updatemap = new List<NameCardRenkeiMapping__c>();
        List<NameCardRenkeiMapping__c> insertmap = new List<NameCardRenkeiMapping__c>();

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName(reco));
        Schema.SObjectType leadSchema1 = schemaMap.get(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('NameCard__c'));
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> fieldMap1 = leadSchema1.getDescribe().fields.getMap();

        String reconame = recTypeMap.get(record);
        //必須のマッピングを保存
        Map<String,String>def = new Map<String,String>();
        if (reconame == 'Account') {
          def = SB_NameCard_RenkeiMappingLcController.ACCOUNT_DEF.clone();
        }
        else if (reconame == 'Contact') {
          def = SB_NameCard_RenkeiMappingLcController.CONTACT_DEF.clone();
        }
        else if (reconame == 'Lead') {
          def = SB_NameCard_RenkeiMappingLcController.LEAD_DEF.clone();
        }

        Map<String,Schema.DisplayType> nameType = new Map<String,Schema.DisplayType>();
        for (Schema.SObjectField str : SB_NameCard_RenkeiMapperUtil.getObjMap('NameCard__c').Values()) {
          Schema.describefieldresult dfield = str.getDescribe();
          nameType.put(dfield.name,dfield.gettype());
        }

        Map<String,Schema.DisplayType> obj2Type = new Map<String,Schema.DisplayType>();
        for (Schema.SObjectField str : SB_NameCard_RenkeiMapperUtil.getObjMap(reconame).Values()) {
          Schema.describefieldresult dfield = str.getDescribe();
          obj2Type.put(dfield.name,dfield.gettype());
        }

        for (NameCardRenkeiMapping__c ma : maps) {
          if (t2.containsKey(ma.TargetName__c) && t1.containsKey(ma.NameCardName__c) && ma.IsActive__c == true) {
            Boolean aa = false;
            String cc = '';
            for (Schema.SObjectType sp : t2.get(ma.TargetName__c)) {
              for (Schema.SObjectType sp1 : t1.get(ma.NameCardName__c)) {
                if (sp1 == sp) {
                  aa = true;
                  break;
                }
              }
            }

            if (aa == false) {
              this.message = System.Label.SB_NC_MAPPING_LABEL_WRONGMAPPING + ' ';
              this.message += NameCard__c.sObjectType.getDescribe().getLabel() + ' : ' + fieldMap1.get(ma.NameCardName__c).getDescribe().getLabel() + '-->' + Schema.getGlobalDescribe().get(reco).getDescribe().getLabel() + ' : ' + fieldMap.get(ma.TargetName__c).getDescribe().getLabel();
              this.state = 'ng';
              return;
            }
          }
          String fp = SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c',ma.NameCardName__c);
          if (def.containsKey(fp)) {
            if (def.get(fp) == ma.TargetName__c) {
              def.remove(fp);
            }
          } else if (ma.NameCardName__c == 'last_name' && def.get('last_name') == ma.TargetName__c) {
            def.remove('last_name');
          } else if (ma.NameCardName__c == 'Id' && def.get('Id') == ma.TargetName__c) {
            def.remove('Id');
          } else if (ma.NameCardName__c == 'OwnerId' && def.get('OwnerId') == ma.TargetName__c) {
            def.remove('OwnerId');
          }
          if (nameType.get(ma.NameCardName__c) == Schema.DisplayType.LOCATION) {
            NameCardRenkeiMapping__c m1 = new NameCardRenkeiMapping__c(RecordTypeId = record,BasicSetting__c = bs.Id,NameCardName__c = ma.NameCardName__c.substringBeforeLast('__') + '__Latitude__s' , TargetName__c = ma.TargetName__c.substringBeforeLast('__') + '__Latitude__s');
            NameCardRenkeiMapping__c m2 = new NameCardRenkeiMapping__c(RecordTypeId = record,BasicSetting__c = bs.Id,NameCardName__c = ma.NameCardName__c.substringBeforeLast('__') + '__Longitude__s', TargetName__c = ma.TargetName__c.substringBeforeLast('__') + '__Longitude__s');
            insertmap.add(m1);
            insertmap.add(m2);
            continue;
          }
          if (String.isBlank(ma.Id)) {
            ma.RecordTypeId = record;
            ma.BasicSetting__c = bs.Id;
            insertmap.add(ma);
          }
          else {
            updatemap.add(ma);
            mapss.remove(ma.Id);
          }
        }
        //必須のマッピングがなければ新規作成
        if (def.keySet().size()>0) {
          for (String str : def.keySet()) {
            insertmap.add(newmapping(t1,bs.Id,record,def.get(str),str));
          }
        }
        String error = '';
        Savepoint sp;
        try{
          sp = Database.setSavepoint();
          if (mapss.keySet().size()>0) {
              SB_NameCard_CrudFls.sdelete(mapss.values());
          }
          if (updatemap.size()>0) {
              SB_NameCard_CrudFls.supdate(updatemap,true);
          }

          if (insertmap.size()>0) {
              SB_NameCard_CrudFls.screate(insertmap,true);
          }
        }
        catch(Exception e) {
          Database.rollback(sp);
          this.message = e.getMessage();
          this.state = 'saveerror';
          return;
        }
        String isok = '';
        if (String.isBlank(error)) {
          error = System.Label.SB_NC_MAPPING_MSG_SAVEOK;
          isok = 'ok';
          this.lastId = UserInfo.getUserId();
          this.lastName = UserInfo.getName();
          this.lastTime = String.valueOf([SELECT LastModifiedDate FROM NameCardBasicSetting__c ORDER BY CreatedDate ASC limit 1][0].LastModifiedDate);
        }
        this.message = error;
        this.state = String.isBlank(isok) ? 'ng' : isok;
    }

    //マッピングを新規作成
    public NameCardRenkeiMapping__c newmapping(Map<String,Set<Schema.SObjectType>> cards,Id basic ,Id record,String tar,String namecard) {
      NameCardRenkeiMapping__c amap = new NameCardRenkeiMapping__c();
      amap.IsActive__c=true;
      amap.TargetName__c = tar;
      amap.NameCardName__c = cards.containsKey(SB_NameCard_RenkeiMapperUtil.getManagedfileName('all', namecard)) ? SB_NameCard_RenkeiMapperUtil.getManagedfileName('all', namecard) : namecard;
      amap.BasicSetting__c = basic;
      amap.RecordtypeId = record;
      return amap;
    }
  }



  @RemoteAction
  @AuraEnabled
  //データを保存
  public static String saveMaps(String mapstr,String record,String reco) {
    SB_NameCard_NameCardRenkeiMappingDTO[] lstFilters = new List<SB_NameCard_NameCardRenkeiMappingDTO>();
    if (String.isNotBlank(mapstr)) {
      lstFilters = (List<SB_NameCard_NameCardRenkeiMappingDTO> )System.JSON.deserializeStrict(mapstr, List<SB_NameCard_NameCardRenkeiMappingDTO> .Class);
    }

    List<NameCardRenkeiMapping__c> maps = new List<NameCardRenkeiMapping__c>();
    for (SB_NameCard_NameCardRenkeiMappingDTO dto : lstFilters) {
      maps.add(dto.debind());
    }
    Renkeidata myRenkeiData = new Renkeidata();
    myRenkeiData.saveData(maps,record,reco);
    return JSON.serialize(myRenkeiData);
  }

  @RemoteAction
  @AuraEnabled
  //レコードタイプを変更
  public static String changerecord(String relabel,String reid) {
    RecordTypedata ma = new RecordTypedata();
    ma.changeRecordType(relabel,reid);
    return JSON.serialize(ma);
  }

  @RemoteAction
  @AuraEnabled
  //デフォルト値に戻る
  public static String changetodefault(String relabel,Map<String,String> obj2LabelName,String reid) {
    Metadata ma = new Metadata();
    ma.setRenkeiMappingDef(relabel,obj2LabelName,reid);
    return JSON.serialize(ma);
  }


  @RemoteAction
  @AuraEnabled
  //データを取得
  public static String getMapping(String record) {
    String re = '';
    if (String.isBlank(record)) {
      RecordTypebin r = new RecordTypebin();
      if (r.keys.size() > 0) {
          re = r.typeMaps.get(r.keys[0]);
      } else {
        return JSON.serialize(new RenkeiMappingAlldata());
      }
    } else {
      re = record;
    }
    RenkeiMappingAlldata ma = new RenkeiMappingAlldata(re);
    return JSON.serialize(ma);
  }
}