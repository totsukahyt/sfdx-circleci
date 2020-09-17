/**
 *
 *  SB_NC_PostInstallScriptTest
 *     インストール後に実行されるクラス SB_NC_PostInstallScript のテストクラス
 *
 *  @author sawano
 *  @Version 1      2017.01.xx
 *
 **/
@isTest
private class SB_NC_PostInstallScriptTest {

  private static final String TODO_SUBJECT = 'カスタム設定での名刺交換TODO件名';
  private final static String QUERY_FORM = 'SELECT Id, Name, {0} FROM NameCardBasicSetting__c LIMIT 1';

  public class TestDb extends SB_NC_TestDB {

    public override void initializeSmartViscaConfig() {
      svConfig = SmartViscaConfig__c.getOrgDefaults();
        System.debug('a : ' + svConfig.Id);
      svConfig.ToDo__c = false; // ToDo登録しない
      svConfig.ToDoName__c = TODO_SUBJECT; // Label.SB_NC_ExchangeCard; // ToDo件名
      svConfig.AccountNotOverWrite__c = false; // 取引先を名刺情報で上書きしない
      svConfig.ContactNotOverWrite__c = false; // 取引先責任者を名刺情報で上書きしない
      svConfig.DispAccountRectype__c = true; // 取引先レコードタイプ選択を表示する
      svConfig.DispContactRectype__c = true; //
      // +--- 2016.05.xx S1取引先登録対応
    }

    // 名刺連携項目マッピング レコードの作成 アカウント用だけ
    public override void initializeMapping() {
      Id rectypeId;
      Map<String, Schema.SObjectField> fields;
      // Account 用
      fields = Account.getSObjectType().getDescribe().fields.getMap();
      rectypeId = rectypeInfos.get('Account').getRecordTypeId();
      for (String src : SV_TO_ACCOUNT.keySet()) {
        for (String dest : SV_TO_ACCOUNT.get(src)) {
          if (fields.get(dest) == null) {      // 名前空間があるときとないときと　
            continue;
          }
          listMapping.add(new NameCardRenkeiMapping__c(NameCardName__c=src, TargetName__c=dest, RecordTypeId=rectypeId));
        }
      }
    }

    public override void initialize() {
      // SmartVisca設定
      initializeSmartViscaConfig();
        System.debug('1');
      if (svConfig != null) {
        System.debug('2');
        upsert svConfig;
      }
        System.debug('3');
      // 名刺連携項目マッピング
      initializeMapping();
      if (!listMapping.isEmpty()) {
        insert listMapping;
      }
    }
  } // public class TestDb extends SB_NC_TestDB

  // 連携用マッピングのセットアップのテスト
  static void test_setupRenkeiMapping() {
    Test.startTest();
    TestDb db = new TestDb();
    db.initialize();
    List<NameCardRenkeiMapping__c> beforeMappings = [SELECT Id FROM NameCardRenkeiMapping__c];
    List<DefaultRenkeiMapping__mdt> defaults = [SELECT Id FROM DefaultRenkeiMapping__mdt];
    SB_NC_PostInstallScript postinstall = new SB_NC_PostInstallScript();
    Test.testInstall(postinstall, null);
    List<NameCardRenkeiMapping__c> afterMappings = [SELECT Id, Name FROM NameCardRenkeiMapping__c];
    System.assert((beforeMappings.isEmpty() && defaults.size() == afterMappings.size()) ||
        (!beforeMappings.isEmpty() && afterMappings.size()>= beforeMappings.size()));
    Test.stopTest();
  }

  // 名刺基本設定のセットアップのテスト
  @isTest
  static void test_setupBasicSetting() {
    List<NameCardBasicSetting__c> beforeSetteings = [SELECT Id, Name FROM NameCardBasicSetting__c];
    SB_NC_PostInstallScript postinstall = new SB_NC_PostInstallScript();
    Test.testInstall(postinstall, null);
    List<NameCardBasicSetting__c> affterSetteings = [SELECT Id, Name FROM NameCardBasicSetting__c];
    System.assert(!beforeSetteings.isEmpty() || !affterSetteings.isEmpty());
  }

  // カスタム設定 SmartViscaConfig のセットアップのテスト
  @isTest
  static void test_setupSmartViscaConfig() {
    SmartViscaConfig__c beforeConfig = SmartViscaConfig__c.getOrgDefaults();
    SB_NC_PostInstallScript postinstall = new SB_NC_PostInstallScript();
    Test.testInstall(postinstall, null);
    SmartViscaConfig__c afterConfig = SmartViscaConfig__c.getOrgDefaults();
    System.assert(beforeConfig.Id !=null || afterConfig.TriggerHistoryIsActive__c);
  }

  // 名前空間名 付きの 項目API名を 取得するクラス ApiNameResolver のテスト
  @isTest
  static void test_ApiNameResolver() {
    Set<SObjectType> otypes = new Set<SObjectType>{Account.SObjectType, Contact.SObjectType, NameCard__c.SObjectType};
    SB_NC_PostInstallScript.ApiNameResolver resolver = new SB_NC_PostInstallScript.ApiNameResolver(otypes);
    System.assertEquals('Name', resolver.getProperApiName(Account.SObjectType, 'Name'));
    System.assertEquals(SB_NameCard_Util.getNamespacePrefix_x() + 'NameCard__c', resolver.getProperApiName(Account.SObjectType, 'NameCard__c'));
    System.assertEquals('FirstName', resolver.getProperApiName(Contact.SObjectType, 'FirstName'));
    System.assertEquals(SB_NameCard_Util.getNamespacePrefix_x() + 'NameCard__c', resolver.getProperApiName(Contact.SObjectType, 'NameCard__c'));
    System.assertEquals(SB_NameCard_Util.getNamespacePrefix_x() + 'email__c', resolver.getProperApiName(Contact.SObjectType, 'email__c'));
    System.assertEquals('city', resolver.getProperApiName(NameCard__c.SObjectType, 'city'));
  }

  //　
  private static final Map<String, String> SVCONFIG2SVSETTING_VER2 = new Map<String, String> {
    'ToDo__c' => 'RegistNoToDo__c',   // ToDo登録しない
    'ToDoName__c' => 'RegistToDoSubject__c', // ToDo件名
    'AccountNotOverWrite__c' => 'RegistAccountNotOverWrite__c', // 取引先を名刺情報で上書きしない
    'ContactNotOverWrite__c' => 'RegistContactNotOverWrite__c', // 取引先責任者を名刺情報で上書きしない
    'DispAccountRectype__c' => 'RegistDispAccountRectype__c', // 取引先レコードタイプ選択を表示する
    'DispContactRectype__c' => 'RegistDispContactRectype__c' //  取引先責任者レコードタイプ選択を表示する
  };

  //private static final Map<String, String> SVCONFIG2SVSETTING_VER3 = new Map<String, String> {
    //'SmartViscal__LeadRegist_DispLeadRectype__c' => 'RegistDispLeadRectype__c',   // リードに登録 リードレコードタイプ選択を表示する  Lead EX  V1.11 から
    //'SmartViscal__LeadRegist_Overwrite__c' => 'RegistLeadNotOverWrite__c' // 取引先登録:リードを名刺情報で上書きしない リードに登録 名刺情報で上書きする  反転させるので注意！
  //};

  // カスタム設定から名刺基本設定へ移行のテスト
  @isTest
  static void test_setupConvertSVConfig2BasicSetting() {
    Test.startTest();
    TestDb db = new TestDb();
    db.initialize();

    SB_NC_PostInstallScript postinstall = new SB_NC_PostInstallScript();
    Test.testInstall(postinstall, null);
    String f = String.join(SVCONFIG2SVSETTING_VER2.values(), ', ');
    String query = String.format(QUERY_FORM, new String[]{f});
    System.debug(query);
    List<NameCardBasicSetting__c> settings = Database.query(query);
    System.assertEquals(false, settings.isEmpty());
    SmartViscaConfig__c svConfig = SmartViscaConfig__c.getOrgDefaults();
    System.assertEquals(TODO_SUBJECT, settings[0].RegistToDoSubject__c);
    for (String key : SVCONFIG2SVSETTING_VER2.keySet()) {
      Object val = svConfig.get(key);
      String d = SVCONFIG2SVSETTING_VER2.get(key);
      System.assertEquals(val, settings[0].get(d));
    }
    Test.stopTest();
  }

  // 基本設定
  private static final Map<String, String> CNVT_BASICSETTING = new Map<String, String> {
    'RegistDispAccountOverWriteCheckbox__c' => 'RegistDispOverWriteCheckbox__c',          //「既存の取引先を名刺情報で上書きする」を表示する
    'RegistDispContactOverWriteCheckbox__c' => 'RegistDispOverWriteCheckbox__c'          //「既存の取引先責任者を名刺情報で上書きする」を表示する
  };

  @isTest
  static void test_setupConvertBasicSetting2BasicSetting() {
    Test.startTest();
    TestDb db = new TestDb();
    db.initialize();

    SB_NC_PostInstallScript postinstall = new SB_NC_PostInstallScript();
    Test.testInstall(postinstall, null);

    Set<String> fields = new Set<String>(CNVT_BASICSETTING.keySet());
    fields.addAll(CNVT_BASICSETTING.values());
    String f = String.join(new List<String>(fields), ', ');
    String query = String.format(QUERY_FORM, new String[]{f});
    System.debug(query);
    List<NameCardBasicSetting__c> settings = Database.query(query);
    System.assertEquals(false, settings.isEmpty());
    for (String key : CNVT_BASICSETTING.keySet()) {
      String oldField = CNVT_BASICSETTING.get(key);
      System.assertEquals(settings[0].get(oldField), settings[0].get(key));
    }
    Test.stopTest();
  }

}