/**
 *
 *  SB_NCL_PostInstallScriptTest
 *     インストール後に実行されるクラス SB_NCl_PostInstallScript のテストクラス
 *
 *  @author sawano
 *  @Version 1      2018.04.xx
 *  lx v1.12    SV_DEV-1251 【カスタム設定】移行済みリード項目の値が反映されない。 → setupBasicSetting のテスト追加
 *
 **/
@isTest
private class SB_NCL_PostInstallScriptTest {

  // 連携用マッピングのセットアップのテスト
  @isTest(SeeAllData=true)
  static void test_setupLeadRenkeiMapping() {
    Test.startTest();
    List<SmartViscaf__NameCardRenkeiMapping__c> beforeMappings = [SELECT Id FROM SmartViscaf__NameCardRenkeiMapping__c WHERE RecordType.Name = 'Lead'];
    List<SmartViscaf__DefaultRenkeiMapping__mdt> defaults = [SELECT Id FROM SmartViscaf__DefaultRenkeiMapping__mdt WHERE SmartViscaf__RecordType__c = 'Lead'];
    SB_NCl_PostInstallScript postinstall = new SB_NCl_PostInstallScript();
    Test.testInstall(postinstall, null);
    List<SmartViscaf__NameCardRenkeiMapping__c> afterMappings = [SELECT Id, Name FROM SmartViscaf__NameCardRenkeiMapping__c WHERE RecordType.Name = 'Lead'];
    System.assert((beforeMappings.isEmpty() && defaults.size() == afterMappings.size()) ||
        (!beforeMappings.isEmpty() && afterMappings.size() == beforeMappings.size()));
    Test.stopTest();
  }

  @isTest
  static void test_setupLeadRenkeiMappingCreate() {
    Test.startTest();
    List<SmartViscaf__NameCardRenkeiMapping__c> beforeMappings = [SELECT Id FROM SmartViscaf__NameCardRenkeiMapping__c WHERE RecordType.Name = 'Lead'];
    List<SmartViscaf__DefaultRenkeiMapping__mdt> defaults = [SELECT Id FROM SmartViscaf__DefaultRenkeiMapping__mdt WHERE SmartViscaf__RecordType__c = 'Lead'];
    SB_NCl_PostInstallScript postinstall = new SB_NCl_PostInstallScript();
    Test.testInstall(postinstall, null);
    List<SmartViscaf__NameCardRenkeiMapping__c> afterMappings = [SELECT Id, Name FROM SmartViscaf__NameCardRenkeiMapping__c WHERE RecordType.Name = 'Lead'];
    System.assert(beforeMappings.isEmpty() && defaults.size() == afterMappings.size());
    Test.stopTest();
  }

  // カスタム設定 SmartViscaConfig が 基本設定に移行されてるのをテスト
  // 実際には Lead拡張の前バージョンがあるわけでないので、移行ではなく、デフォルト値が入ってることを確認
  //@isTest
  //static void test_setupBasicSetting_1toCurrent() {
  //  SB_NCL_PostInstallScript postinstall = new SB_NCL_PostInstallScript();
  //  Test.testInstall(postinstall, new Version(1, 10), false);
  //  List<SmartViscaf__NameCardBasicSetting__c> settings = [SELECT Id, Name,
  //          SmartViscaf__RegistDispLeadRectype__c, SmartViscaf__RegistLeadNotOverWrite__c FROM SmartViscaf__NameCardBasicSetting__c];
  //  System.assert(settings.isEmpty() == false);
  //  System.assertEquals(true, settings[0].SmartViscaf__RegistDispLeadRectype__c);
  //  System.assertEquals(false, settings[0].SmartViscaf__RegistLeadNotOverWrite__c);
  //}

  @isTest
  static void test_setupBasicSetting_1toCurrent() {
    // 基本設定を作っておく
    SmartViscaf__NameCardBasicSetting__c setting = new SmartViscaf__NameCardBasicSetting__c();
    setting.SmartViscaf__RegistDispLeadRectype__c = false;
    setting.SmartViscaf__RegistLeadNotOverWrite__c = true;
    insert setting;
    SB_NCL_PostInstallScript postinstall = new SB_NCL_PostInstallScript();
    Test.testInstall(postinstall, new Version(1, 10), false);
    List<SmartViscaf__NameCardBasicSetting__c> settings = [SELECT Id, Name,
            SmartViscaf__RegistDispLeadRectype__c, SmartViscaf__RegistLeadNotOverWrite__c FROM SmartViscaf__NameCardBasicSetting__c];
    System.assert(settings.isEmpty() == false);
    // アップグレードのデフォルト値になってる。
    System.assertEquals(true, settings[0].SmartViscaf__RegistDispLeadRectype__c);
    System.assertEquals(false, settings[0].SmartViscaf__RegistLeadNotOverWrite__c);
  }

  @isTest
  static void test_setupBasicSetting_2toCurrent() {
    // 基本設定を作っておく
    SmartViscaf__NameCardBasicSetting__c setting = new SmartViscaf__NameCardBasicSetting__c();
    setting.SmartViscaf__RegistDispLeadRectype__c = false;
    setting.SmartViscaf__RegistLeadNotOverWrite__c = true;
    insert setting;
    SB_NCL_PostInstallScript postinstall = new SB_NCL_PostInstallScript();
    Test.testInstall(postinstall, new Version(2, 10), false);
    List<SmartViscaf__NameCardBasicSetting__c> settings = [SELECT Id, Name,
            SmartViscaf__RegistDispLeadRectype__c, SmartViscaf__RegistLeadNotOverWrite__c FROM SmartViscaf__NameCardBasicSetting__c];
    System.assert(settings.isEmpty() == false);
    // アップグレードのデフォルト値でない
    System.assertEquals(false, settings[0].SmartViscaf__RegistDispLeadRectype__c);
    System.assertEquals(true, settings[0].SmartViscaf__RegistLeadNotOverWrite__c);
  }

  @isTest
  static void test_getNamespacePrefix() {
    String ns = SB_NCl_PostInstallScript.getNamespacePrefix();
    System.assert(String.isNotBlank(ns));
  }

  @isTest
  static void test_supdate() {
    SB_NCl_PostInstallScript.SB_NameCard_CrudFlsInt crudFls = new SB_NCl_PostInstallScript.SB_NameCard_CrudFlsInt();
    List<Lead> cLead = new List<Lead>();
    cLead.add(new Lead(LastName='山田', FirstName='太郎', Company='テスト商事有限会社'));
    cLead.add(new Lead(LastName='山田', FirstName='花子', Company='テスト商事有限会社'));
    crudFls.screate(cLead, false);
    Test.startTest();
    List<Lead> uLead = [SELECT Id, LastName, FirstName FROM Lead];
    for (Lead l : uLead) {
      l.LastName='鈴木';
    }
    crudFls.supdate(uLead, false);
    uLead = [SELECT Id, LastName, FirstName FROM Lead];
    System.assertEquals('鈴木', uLead[0].LastName);
    Test.stopTest();
  }


}