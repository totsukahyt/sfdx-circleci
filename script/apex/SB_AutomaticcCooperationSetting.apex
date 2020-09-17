//自動連携の有効化

List<smvTest__NameCardBasicSetting__c> basicSetting = [SELECT id, smvTest__RenkeiActive__c FROM smvTest__NameCardBasicSetting__c];
basicSetting[0].smvTest__RenkeiActive__c     = true;
update basicSetting;

 
smvTest__SmartViscaConfig__c setting = smvTest__SmartViscaConfig__c.getOrgDefaults();
setting.smvTest__TriggerRenkeiTriggerHandler__c = true;
setting.smvTest__DispRenkeiSetting__c           = true;
update setting;