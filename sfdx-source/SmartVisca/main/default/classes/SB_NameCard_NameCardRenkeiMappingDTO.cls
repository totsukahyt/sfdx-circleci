/**
 *
 * SB_NameCard_NameCardRenkeiMappingDTO
 * Lightning SB_NameCard_RenkeiMappingページにNameCardRenkeiMapping__cを使うためのbinクラス
 *
 *
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.20      2017.02.XX
 *
 **/
public with sharing class SB_NameCard_NameCardRenkeiMappingDTO {
  @AuraEnabled public String TargetName { get; public set; }
  @AuraEnabled public String TagetLabel { get; public set; }
  @AuraEnabled public String NameCardName { get; public set; }
  @AuraEnabled public String NameCardLabel { get; public set; }
  @AuraEnabled public String IsActive { get; public set; }
  @AuraEnabled public String Id { get; public set; }
  @AuraEnabled public String LastModifiedById { get; public set; }//最終更新者ID
  @AuraEnabled public String LastModifiedByName { get; public set; }//最終更新者名前
  @AuraEnabled public String LastModifiedByDate { get; public set; }//最終更新者日

  //NameCardRenkeiMapping__c -> bin
  public void bind(NameCardRenkeiMapping__c mapping){
    this.Id = mapping.Id;
    this.LastModifiedByName = String.isBlank(mapping.LastModifiedBy.Name) ? System.Label.SB_NC_MAPPING_NOUPDATE : mapping.LastModifiedBy.Name;
    this.LastModifiedByDate = String.valueOf(mapping.LastModifiedDate);
    this.LastModifiedById = mapping.LastModifiedById;
    this.TargetName = mapping.TargetName__c;
    this.NameCardName = mapping.NameCardName__c;
    this.IsActive = String.valueOf(mapping.IsActive__c);

  }

  //bin -> NameCardRenkeiMapping__c
  public NameCardRenkeiMapping__c debind(){
    NameCardRenkeiMapping__c mapping = new NameCardRenkeiMapping__c();
    mapping.Id = this.Id;
    mapping.IsActive__c = this.IsActive == 'true';
    mapping.TargetName__c = this.TargetName;
    mapping.NameCardName__c = this.NameCardName;
    return mapping;
  }

}