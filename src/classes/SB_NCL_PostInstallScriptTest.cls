/**
 *
 *  SB_NCL_PostInstallScriptTest
 *     インストール後に実行されるクラス SB_NCl_PostInstallScript のテストクラス
 *
 *  @author sawano
 *  @Version 1      2018.04.xx
 *
 **/
@isTest
private class SB_NCL_PostInstallScriptTest {

  //private static final String TODO_SUBJECT = 'カスタム設定での名刺交換TODO件名';
  //private final static String QUERY_FORM = 'SELECT Id, Name, {0} FROM NameCardBasicSetting__c LIMIT 1';

  //public class TestDb extends SB_NC_TestDB {

  //  public override void initializeSmartViscaConfig() {
  //    svConfig = SmartViscaConfig__c.getOrgDefaults();
  //      System.debug('a : ' + svConfig.Id);
  //    svConfig.ToDo__c = false; // ToDo登録しない
  //    svConfig.ToDoName__c = TODO_SUBJECT; // Label.SB_NC_ExchangeCard; // ToDo件名
  //    svConfig.AccountNotOverWrite__c = false; // 取引先を名刺情報で上書きしない
  //    svConfig.ContactNotOverWrite__c = false; // 取引先責任者を名刺情報で上書きしない
  //    svConfig.DispAccountRectype__c = true; // 取引先レコードタイプ選択を表示する
  //    svConfig.DispContactRectype__c = true; //
  //    // +--- 2016.05.xx S1取引先登録対応
  //  }

  //  // 名刺連携項目マッピング レコードの作成 アカウント用だけ
  //  public override void initializeMapping() {
  //    Id rectypeId;
  //    Map<String, Schema.SObjectField> fields;
  //    // Account 用
  //    fields = Account.getSObjectType().getDescribe().fields.getMap();
  //    rectypeId = rectypeInfos.get('Account').getRecordTypeId();
  //    for (String src : SV_TO_ACCOUNT.keySet()) {
  //      for (String dest : SV_TO_ACCOUNT.get(src)) {
  //        if (fields.get(dest) == null) {      // 名前空間があるときとないときと　
  //          continue;
  //        }
  //        listMapping.add(new SmartViscaf__NameCardRenkeiMapping__c(NameCardName__c=src, TargetName__c=dest, RecordTypeId=rectypeId));
  //      }
  //    }
  //  }

  //  public override void initialize() {
  //    // SmartVisca設定
  //    initializeSmartViscaConfig();
  //      System.debug('1');
  //    if (svConfig != null) {
  //      System.debug('2');
  //      upsert svConfig;
  //    }
  //      System.debug('3');
  //    // 名刺連携項目マッピング
  //    initializeMapping();
  //    if (!listMapping.isEmpty()) {
  //      insert listMapping;
  //    }
  //  }
  //} // public class TestDb extends SB_NC_TestDB

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