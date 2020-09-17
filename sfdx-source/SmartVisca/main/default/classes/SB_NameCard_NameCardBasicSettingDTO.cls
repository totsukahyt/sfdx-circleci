/**
 *
 * SB_NameCard_NameCardBasicSettingDTO
 * Lightning SB_NameCard_NameCardBasicSettingページにNameCardBasicSetting__cを使うためのbinクラス
 *
 *
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.20      2017.02.XX
 *  @Version 2.4       2019.06.XX SV_DEV-XXXX SmartVisca 基本設定機能追加
 *  @Version 2.5       2019.12.XX SV_DEV-2390 Classic SV設定：リード登録時のToDo登録機能に関する設定項目の追加
 *  @Version 2.6   全  2020.09.xx PRODUCT-835 SmartVisca設定 画面 「リードまたは取引先・取引先責任者に登録」 の 「ToDo登録」の初期値オン の反映先項目が不適切
 *
 **/

public with sharing class SB_NameCard_NameCardBasicSettingDTO {

  /*
  public static final String NC_QUERY_SIMPLE_FIELDS = 'Id,Name,RegistNoToDo__c,RenkeiActive__c,RegistToDoSubject__c,RegistAccountNotOverWrite__c,RegistContactNotOverWrite__c,LastModifiedById,SaishinInheritValues__c,RegistDispLeadRectype__c,RenkeiCampaignStatus__c,' + 
                                                       'RegistDispAccountRectype__c,RegistDispContactRectype__c,RegistDispOverWriteCheckbox__c,ScanSelectCampaign__c,RenkeiLeadActive__c,RegistLeadNotOverWrite__c,RenkeiActiveCampaignMember__c,RegistDispLeadOverWriteCheckbox__c,' + 
                                                       'RegistDispAccountOverWriteCheckbox__c,RegistDispContactOverWriteCheckbox__c';
  */
  public static final String NC_QUERY_SIMPLE_FIELDS = 'Id,Name,RegistNoToDo__c,RenkeiActive__c,RegistToDoSubject__c,RegistAccountNotOverWrite__c,RegistContactNotOverWrite__c,LastModifiedById,SaishinInheritValues__c,RegistDispLeadRectype__c,RenkeiCampaignStatus__c,' + 
                                                       'RegistDispAccountRectype__c,RegistDispContactRectype__c,RegistDispOverWriteCheckbox__c,ScanSelectCampaign__c,RenkeiLeadActive__c,RegistLeadNotOverWrite__c,RenkeiActiveCampaignMember__c,RegistDispLeadOverWriteCheckbox__c,' + 
                                                       'RegistDispAccountOverWriteCheckbox__c,RegistDispContactOverWriteCheckbox__c,' +
                                                       'RegistAccountCompareCustomize__c,RegistAccountCompareField__c,RegistLeadCompareCustomize__c,RegistLeadCompareField__c,' +
                                                       'RegistToDoOwner__c,RegistAccountQueryRecordTypeIds__c,RegistContactQueryRecordTypeIds__c,RegistLeadQueryRecordTypeIds__c,' +
                                                       'NayoseJyoken__c,RegistLeadToDoSubject__c,RegistLeadNoToDo__c,RegistLeadToDoOwner__c';

  public static final String NC_QUERY_FIELDS = 'Id,Name,LastModifiedById,RenkeiContactMail__c,RenkeiAccountCity__c,RenkeiExcludeHojinkaku__c,RenkeiExcludeHojinkakuPartial__c,RenkeiLeadNOExistCreateNew__c,RegistLeadNotOverWrite__c,' + 
                                                                             'RenkeiAccountSite__c,RenkeiAccountURL__c,RenkeiSpecificItems__c,RenkeiContactRecordTypes__c,' +
                                                                             'RenkeiAccountPhone__c,RenkeiAccount_Street__c,RenkeiAccountZipCode__c,RenkeiContactOverwrite__c,' + 
                                                                             'RenkeiAccountCompany__c,RenkeiAccountOverwrite__c,RenkeiContactLastName__c,RenkeiContactFirstName__c,' + 
                                                                             'RenkeiAccountAddressPref__c,RenkeiAccountRecordTypes__c,RenkeiLeadRecordTypes__c,' + 
                                                                             'RenkeiContactNOExistCreateNew__c,RenkeiAccountNOExistCreateNew__c,RenkeiContactQueryRecordTypeIds__c,RenkeiAccountQueryRecordTypeIds__c,RenkeiLeadQueryRecordTypeIds__c,RenkeiInheritEvent__c,' +
                                                                             'HojinkakuEquationLongAndAbbr__c,' +
                                                                             // リード
                                                                             'RenkeiLeadCompany__c,RenkeiLeadPhone__c,RenkeiLeadMail__c,RenkeiLeadURL__c,RenkeiLeadStreet__c,RenkeiLeadExcludeHojinkaku__c,RenkeiLeadExcludeHojinkakuPartial__c,' +
                                                                             'RenkeiLeadCity__c,RenkeiLeadLastName__c,RenkeiLeadAddressPref__c,RenkeiLeadFirstName__c,RenkeiLeadZipCode__c,' +
                                                                             'RenkeiActive__c,RenkeiLeadActive__c,RenkeiActiveCampaignMember__c,RenkeiCampaignStatus__c,RenkeiLeadOverwrite__c,' +
                                                                             // リードの自動連携に関する応用設定
                                                                             'RenkeiCreateContactOnAcountWithLead__c,RenkeiCreateContactOnAcountWithoutLead__c,RenkeiCreateLeadOnTooManyAccounts__c,RenkeiUpdateAllLeadsOnCondition__c';
  private static final Set<String> box = new Set<String>{'RegistAccountNotOverWrite__c','RegistContactNotOverWrite__c','RegistNoToDo__c','RegistLeadNoToDo__c','RegistLeadNotOverWrite__c'};
  //NameCardBasicSetting__c から map
  public static Map<String,String> bind(NameCardBasicSetting__c basicsetting){
    Map<String,String> dto = new Map<String,String>();
    for(String str : NC_QUERY_FIELDS.split(',')){
      dto.put(str,String.valueOf(basicsetting.get(str)));
    }
    dto.put('LastModifiedByName',String.isBlank(basicsetting.LastModifiedBy.Name) ? System.Label.SB_NC_MAPPING_NOUPDATE : basicsetting.LastModifiedBy.Name);
    dto.put('LastModifiedByDate',String.valueOf(Datetime.valueOf(basicsetting.LastModifiedDate)));
    return dto;
  }

  //NameCardBasicSetting__c から map
  public static Map<String,String> bindSimple(NameCardBasicSetting__c basicsetting){
    Map<String,String> dto = new Map<String,String>();
    for(String str : NC_QUERY_SIMPLE_FIELDS.split(',')){
      if(box.contains(str)){
        dto.put(str,String.valueOf(String.valueOf(basicsetting.get(str)) == 'false'));
        continue;
      }
      dto.put(str,String.valueOf(basicsetting.get(str)));
    }
    dto.put('LastModifiedByName',String.isBlank(basicsetting.LastModifiedBy.Name) ? System.Label.SB_NC_MAPPING_NOUPDATE : basicsetting.LastModifiedBy.Name);
    dto.put('LastModifiedByDate',String.valueOf(basicsetting.LastModifiedDate));
    return dto;
  }

  //mapから NameCardBasicSetting__c
  public static NameCardBasicSetting__c DebindSimple(Map<String,String> bs){
    return SB_NameCard_NameCardBasicSettingDTO.DebindSimple(bs, null);
  }

  //mapから NameCardBasicSetting__c
  public static NameCardBasicSetting__c DebindSimple(Map<String,String> bs, NameCardBasicSetting__c bass){
    NameCardBasicSetting__c basicsetting;
    if (bass == null) {
      basicsetting = new NameCardBasicSetting__c();
    } else {
      basicsetting = bass;
    }
    Map<String,String> o1 = new Map<String,String>();
    Map<String,String> o2 = new Map<String,String>();
    SB_NameCard_RenkeiMapperUtil.createApiNameKeyDataTypeMap(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('NameCardBasicSetting__c'),o1,o2,'',false);
    System.debug(o1);
    for(String str : NC_QUERY_SIMPLE_FIELDS.split(',')){
      if(str == 'LastModifiedByName' || str == 'LastModifiedByDate' || str == 'LastModifiedById'){
        continue;
      }
      if(o1.get(SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCardBasicSetting__c',str)) == 'BOOLEAN'){
        if(box.contains(str)){
          basicsetting.put(str,String.valueOf(bs.get(str)) == 'false');
          continue;
        }
        basicsetting.put(str,String.valueOf(bs.get(str)) == 'true');
        continue;
      }
      System.debug(str + '   ' + bs.get(str));
      basicsetting.put(str,String.valueOf(bs.get(str)));
    }
    System.debug(basicsetting);
    return basicsetting;
  }

  //mapから NameCardBasicSetting__c
  public static NameCardBasicSetting__c Debind(Map<String,String> bs){
    return SB_NameCard_NameCardBasicSettingDTO.Debind(bs, null);
  }

  //mapから NameCardBasicSetting__c
  public static NameCardBasicSetting__c Debind(Map<String,String> bs, NameCardBasicSetting__c bass){
    NameCardBasicSetting__c basicsetting;
    if (bass == null) {
      basicsetting = new NameCardBasicSetting__c();
    } else {
      basicsetting = bass;
    }
    Map<String,String> o1 = new Map<String,String>();
    Map<String,String> o2 = new Map<String,String>();
    SB_NameCard_RenkeiMapperUtil.createApiNameKeyDataTypeMap(SB_NameCard_RenkeiMapperUtil.getManagedObjectName('NameCardBasicSetting__c'),o1,o2,'',false);
    System.debug(o1);
    for(String str : NC_QUERY_FIELDS.split(',')){
      if(str == 'LastModifiedByName' || str == 'LastModifiedByDate' || str == 'LastModifiedById'){
        continue;
      }
      if(o1.get(SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCardBasicSetting__c',str)) == 'BOOLEAN'){
        System.debug(bs);
        System.debug(o1.get(str) + '  ' + str + '   ');
        basicsetting.put(str,String.valueOf(bs.get(str)) == 'true');
      } else{
        basicsetting.put(str,String.valueOf(bs.get(str)));
      }
    }
    System.debug(basicsetting);
    return basicsetting;
  }

}