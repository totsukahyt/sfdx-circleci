//自動連携の有効化

List<SmartViscaf__NameCardBasicSetting__c> basicSetting = [SELECT id, SmartViscaf__RenkeiActive__c FROM SmartViscaf__NameCardBasicSetting__c];
basicSetting[0].SmartViscaf__RenkeiActive__c     = true;
update basicSetting;

 
SmartViscaf__SmartViscaConfig__c setting = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
setting.SmartViscaf__TriggerRenkeiTriggerHandler__c = true;
setting.SmartViscaf__DispRenkeiSetting__c           = true;
update setting;