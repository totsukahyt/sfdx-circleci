//自動連携の有効化

List<ficuspop__NameCardBasicSetting__c> basicSetting = [SELECT id, ficuspop__RenkeiActive__c FROM ficuspop__NameCardBasicSetting__c];
basicSetting[0].ficuspop__RenkeiActive__c     = true;
update basicSetting;

 
ficuspop__SmartViscaConfig__c setting = ficuspop__SmartViscaConfig__c.getOrgDefaults();
setting.ficuspop__TriggerRenkeiTriggerHandler__c = true;
setting.ficuspop__DispRenkeiSetting__c           = true;
update setting;