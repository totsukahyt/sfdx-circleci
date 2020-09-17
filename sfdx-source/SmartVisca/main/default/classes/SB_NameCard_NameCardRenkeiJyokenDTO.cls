/**
 *
 * SB_NameCard_NameCardRenkeiJyokenDTO
 * Lightning SB_NameCard_RenkeiSettingページにNameCardRenkeiJyoken__cを使うためのbinクラス
 *
 *
 *
 *  Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.20      2017.02.XX
 *
 **/

public with sharing class SB_NameCard_NameCardRenkeiJyokenDTO {
  public static final String NC_QUERY_FIELDS = 'Id,Name,Operator__c,NameCardDataType__c,NameCardName__c,Value__c';
  @AuraEnabled public String Operator { get; public set; }
  @AuraEnabled public String NameCardDataType { get; public set; }
  @AuraEnabled public String NameCardName { get; public set; }
  @AuraEnabled public String Value { get; public set; }
  @AuraEnabled public String Id { get; public set; }
  @AuraEnabled public String LastModifiedById { get; public set; }//最終更新者ID
  @AuraEnabled public String LastModifiedByName { get; public set; }//最終更新者名前
  @AuraEnabled public String LastModifiedByDate { get; public set; }//最終更新者日
  public SB_NameCard_NameCardRenkeiJyokenDTO() {
  }

  //NameCardRenkeiJyoken__c -> bin
  public void bind(NameCardRenkeiJyoken__c jyouken){
    this.Id = jyouken.Id;
    this.Operator = String.isBlank(jyouken.Operator__c) ? '' : jyouken.Operator__c;
    this.NameCardName = jyouken.NameCardName__c;
    this.NameCardDataType = jyouken.NameCardDataType__c;
    this.Value = String.isBlank(jyouken.Value__c) ? '' : jyouken.Value__c;
    this.LastModifiedByName = String.isBlank(jyouken.LastModifiedBy.Name) ? System.Label.SB_NC_MAPPING_NOUPDATE : jyouken.LastModifiedBy.Name;
    this.LastModifiedByDate = String.valueOf(jyouken.LastModifiedDate);
    this.LastModifiedById = jyouken.LastModifiedById;
  }

  //bin -> NameCardRenkeiJyoken__c
  public NameCardRenkeiJyoken__c debind(){
    NameCardRenkeiJyoken__c jyouken = new NameCardRenkeiJyoken__c();
    jyouken.Id = this.Id;
    jyouken.Operator__c = this.Operator;
    jyouken.NameCardName__c = this.NameCardName;
    jyouken.NameCardDataType__c = this.NameCardDataType;
    jyouken.Value__c = this.Value;
    return jyouken;
  }
}