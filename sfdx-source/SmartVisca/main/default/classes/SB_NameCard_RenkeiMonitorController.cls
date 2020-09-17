/**
 *
 * SB_NameCard_RenkeiMonitorController
 *    自動連携検証画面のコントローラ ビューからの一括と レコード詳細からの個別 に対応
 *    SmartViscaT05 パケージから
 *
 *  @author sawano
 *  @Version 1      2017.08.xx
 *  @Version 2      2017.12.xx  名刺が処理対象か表示
 *  @Version 3      2017.12.xx  SV_DEV-724 自動連携検証用ツール(SmartViscaT05) : 連携対象の名刺の条件「名刺：作成日」を設定した状態で自動連携の検証ボタンを押した場合にエラーになる
 *                  2018.02.xx v1.22 SV_DEV-585 自動連携で既存取引先責任者が一意に特定できるなら取引先があいまいでも重複エラーにしない
 *  @Version 2.2    sawano   2019.03.XX 2.1.1 パッチで で2019.02 コードスキャンをパス → セキュリティレビュー更新 2.2へ反映
 *  @Version 2.4    2019.08.xx SV_DEV-1704 自動連携の検証（LEX画面 / 一括登録）でキャンセルボタンを押下した場合に「Attempt to de-reference a null object」になる。
 *                              SV_DEV-652 自動連携検証用ツール(SmartViscaT05) : 英語名刺を検証した場合に処理結果のリンクが反応しない
 *                              SV_DEV-1676 【例外】「自動連携の検証」で コレクションサイズ XXXX は、1,000 の最大サイズを超えています。エラーがでる。
 *                              SV_DEV-1677 【例外】「自動連携の検証」で SmartViscaf:Too many query rows: 50001エラーがでる。
 *  @Version 2.5.1  2020.05.22 SV_DEV-2599 コードスキャン対応 2コードスキャンで Query: URL Redirection Attack になってしまうので、修正
 *  @Version 2.5.3  2020.07.20 コードスキャン対応で、戻り先ページ指定しない。 リストビューの識別しない。retUrlパラメータを使わない。PRODUCT-480 SmartVisca コードスキャン対応の v2.5.3 の修正の v2.6 へ向けての反映
 *
 * Copyright (c) 2017-2020 SunBridge Inc.
 *
 **/
public with sharing class SB_NameCard_RenkeiMonitorController {
  public class SB_NameCard_RenkeiTraceControllerException extends Exception {}

  // 名前空間名プレフィックス
  private static final String NS_X = SB_NameCard_Util.getNamespacePrefix_x();
  @TestVisible
  private static Integer MAX_RECORDS = 50000;
  //private List<SB_NameCard_RegistCardHolder.AccountCardHolder> holders;
  @TestVisible
  private List<String> cardIds { get; private set; }

  public NameCard__c nameCard { get; set; }  // 個別のときは 名刺の情報を画面に出す用
  public String buttonLabel { get; private set; }
  public Boolean buttonStatus { get; private set; }
  public String terminateTime { get; private set; }

  public String createAccountUrlParam { get; private set; }    // 新規Account作成 のパラメータ　Classic用
  public String createAccountJsonParam { get; private set; }   // 新規Account作成 のパラメータ　LEX用

  public String createContactUrlParam { get; private set; }    // 新規Contact作成 のパラメータ　Classic用
  public String createContactJsonParam { get; private set; }   // 新規Contact作成 のパラメータ　LEX用

  public List<AccountCandidate> candidates { get; private set; }
  public String over1000Caption { get; private set; }   // v2.4 個別で該当が1000件を超えたときのキャプション
  public Boolean disableRun { get; private set; } // v2.4 例外とかで実行不可

  public List<TestResult> results { get; private set; }

  public Boolean getIsSelectOne() {
    return cardIds != null && cardIds.size() == 1;
  }

  public Boolean getHaveResults() {
    return results != null && !results.isEmpty();
  }

  private static NameCardBasicSetting__c setting;
  public static Id accountRectypeId { get; private set; }   // 作成するアカウントのレコードタイプID
  public static Id contactRectypeId { get; private set; }   // 作成するアカウントのレコードタイプID
  static {
    setting = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    // ToDo レコードタイプID正当性の確認
    accountRectypeId = setting.RenkeiAccountRecordTypes__c;
    contactRectypeId = setting.RenkeiContactRecordTypes__c;
  }

  // Classic ?
  public static Boolean isClassicUI() {
    return UserInfo.getUiThemeDisplayed() != 'Theme4d';
  }

  // 名刺のカスタム項目 + α の API名のコレクションを取得
  private static Set<String> ncFields {
    get {
      if (ncFields == null) {
        ncFields = new Set<String>();
        Map<String, Schema.SObjectField > fields = NameCard__c.getSObjectType().getDescribe().fields.getMap();
        for(Schema.SObjectField f : fields.values()) {
          Schema.DescribeFieldResult dfr = f.getDescribe();
          if (dfr.isCustom()) {
            ncFields.add(dfr.getName());
          }
        }
        ncFields.add('Id');
        ncFields.add('Name');
        ncFields.add('OwnerID');
        ncFields.add('LastModifiedDate');     // 2017.06.16
        ncFields.add('LastModifiedById');       // 2017.06.16
        ncFields.add('CreatedDate');      // 2017.12.xx SV_DEV-724 自動連携検証用ツール(SmartViscaT05) : 連携対象の名刺の条件「名刺：作成日」を設定した状態で自動連携の検証ボタンを押した場合にエラーになる
        ncFields.add('CreatedById');      // 2017.12.xx SV_DEV-724 自動連携検証用ツール(SmartViscaT05) : 連携対象の名刺の条件「名刺：作成日」を設定した状態で自動連携の検証ボタンを押した場合にエラーになる

        ncFields.add(NS_X + 'company_name__c');
        ncFields.add(NS_X + 'address_pref__c');
        ncFields.add(NS_X + 'division__c');
        ncFields.add(NS_X + 'title_name__c');
      }
      return ncFields;
    }
  }

  private void buildCreateAccountParam(List<SB_NameCard_RegistCardHolder.AccountCardHolder> holders) {
    if (holders == null || holders.isEmpty()) {
      return;
    }
    holders[0].preProcess(true); // 2018.02.xx v1.22
    Account acnt = holders[0].buildNewAccount(accountRectypeId, UserInfo.getUserId());
    if (acnt == null) {
      return;
      //throw new SB_NameCard_RenkeiTraceControllerException('新規登録先を作成できません');
    }
    if (isClassicUI()) {
      // Cassic 用
      this.createAccountUrlParam = SB_NameCard_CreateRecordParameterBuilder.buildClassic(acnt);
    }
    else {
      // LEX用
      this.createAccountJsonParam = SB_NameCard_CreateRecordParameterBuilder.buildLex(acnt);
    }
    Contact cont = holders[0].buildNewContact(contactRectypeId, UserInfo.getUserId());
    if (holders[0].isAccountExistOne()) {
      cont.AccountId = holders[0].getTargetAccountId();
    }
    //if (cont == null || cont.AccountId == null ) {
    if (cont == null) {   // 取引先を指定できてなくてもパラメータを作る
      return;
      //throw new SB_NameCard_RenkeiTraceControllerException('新規登録先を作成できません');
    }
    if (isClassicUI()) {
      // Cassic 用
      this.createContactUrlParam = SB_NameCard_CreateRecordParameterBuilder.buildClassic(cont);
    }
    else {
      // LEX用
      this.createContactJsonParam = SB_NameCard_CreateRecordParameterBuilder.buildLex(cont);
    }
  }

  public SB_NameCard_RenkeiMonitorController() {
    this.buttonLabel = System.Label.SB_NC_RenkeiMon_TryRegistration;    // '登録を試す';
    this.buttonStatus = false;
    this.createAccountUrlParam = null;
    this.createAccountJsonParam = null;
    this.createContactUrlParam = null;
    this.createContactJsonParam = null;
    this.nameCard = null;
    this.cardIds = new List<String>();
    this.disableRun = false;  // v2.4
  }

  public SB_NameCard_RenkeiMonitorController(ApexPages.StandardSetController controller) {
    this.buttonLabel = System.Label.SB_NC_RenkeiMon_TryRegistration;    // '登録を試す';
    this.buttonStatus = false;
    this.createAccountUrlParam = null;
    this.createAccountJsonParam = null;
    this.createContactUrlParam = null;
    this.createContactJsonParam = null;
    this.nameCard = null;
    this.cardIds = new List<String>();
    for (SObject obj : controller.getSelected()) {
      this.cardIds.add(obj.Id);
    }
    System.debug('SB_NC_PageDispacherController ids size: ' +  cardIds.size());
    System.debug(cardIds);
    this.disableRun = false;  // v2.4
  }

  private static final String QUERY_FORM = 'SELECT {0} FROM NameCard__c WHERE Id IN :ids';

  private static List<NameCard__c> getCards(List<Id> ids) {

    String query = String.format(QUERY_FORM, new String[] { String.join(new List<String>(ncFields), ', ') });
    System.debug(query);
    return Database.query(query);
  }

  public class AccountCandidate {
    public Boolean ignore { get; private set; }
    public NameCard__c card { get; private set; }
    public Account acnt { get; private set; }
    public Contact cont { get; private set; }
    public AccountCandidate(NameCard__c card, Account acnt) {
      this.ignore = false;
      this.card = card;
      this.acnt = acnt;
    }
    public AccountCandidate(NameCard__c card, Account acnt, Contact cont) {
      this.ignore = false;
      this.card = card;
      this.acnt = acnt;
      this.cont = cont;
    }
    public void setIgnore(Boolean b) {
      this.ignore = b;
    }
  }

  private void buildCandidateList(List<SB_NameCard_RegistCardHolder.AccountCardHolder> holders) {
    Set<Id> acntIds = new Set<Id>();
    Set<Id> contIds = new Set<Id>();
    for (SB_NameCard_RegistCardHolder.AccountCardHolder h : holders) {
      List<SB_NameCard_RegistCardHolder.AccountTarget> targets = h.getAccountTargets();
      for(SB_NameCard_RegistCardHolder.AccountTarget t : targets) {
        acntIds.add(t.targetId);
        if (!t.childIds.isEmpty()) {
          contIds.addAll(t.childIds);
        }
      }
    }
    if (acntIds.isEmpty()) {
      System.debug('該当する既存取引先なし');
      return;
    }
    if (acntIds.size() > MAX_RECORDS || contIds.size() > MAX_RECORDS) {
      // v2.4 2019.08.xx SV_DEV-1677 【例外】「自動連携の検証」で SmartViscaf:Too many query rows: 50001エラーがでる。
      throw new SB_NameCard_RenkeiTraceControllerException(SYstem.Label.SB_NC_MSG_CandidateRecordTooMuch);
    }
    Map<Id, Account> acnts = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :acntIds]);
    Map<Id, Contact> conts;
    if (!contIds.isEmpty()) {
      conts = new Map<Id, Contact>([SELECT Id, Name FROM Contact WHERE Id IN :contIds]);
    }
    else {
      System.debug('該当する既存取引先責任者なし');
      conts = new Map<Id, Contact>();
    }
    this.candidates = new List<AccountCandidate>();
    for (SB_NameCard_RegistCardHolder.AccountCardHolder h : holders) {
      Boolean ignore = SB_NameCard_RenkeiChecker.getInstance().isIgnore(h.card);
      List<SB_NameCard_RegistCardHolder.AccountTarget> targets = h.getAccountTargets();
      System.debug('targets.size(): ' +  targets.size());
      for(SB_NameCard_RegistCardHolder.AccountTarget t : targets) {
        Account acnt = acnts.get(t.targetId);
        if (acnt == null) continue;
        if (!t.childIds.isEmpty()) {
          for (Id cId : t.childIds) {
            Contact cont = conts.get(cId);
            if (cont == null) continue;
            //can.addContact(cont);
            AccountCandidate can = new AccountCandidate(h.card, acnt, cont);
            this.candidates.add(can);
          }
        }
        else {
          AccountCandidate can = new AccountCandidate(h.card, acnt);
          this.candidates.add(can);
        }
      }
    }
    if (this.candidates.size() > 1000) {
      // v2.4 SV_DEV-1676 【例外】「自動連携の検証」で コレクションサイズ XXXX は、1,000 の最大サイズを超えています。エラーがでる。
      for (Integer n = this.candidates.size()-1; n >= 1000; n--) {
        this.candidates.remove(n);
      }
      this.over1000Caption = String.format(System.Label.SB_NC_FORM_RenkeiMonitorOver1000,
                                new String[]{ String.valueOf(acnts.size()), String.valueOf(conts.size()) });
    }
  }

  // 初期化
  public void init() {
    try {
      Map<String, String> paras = ApexPages.currentPage().getParameters();
      // LEXの一括のとき、所定の戻り先パラメータからとります。
      // SV_DEV-1704 自動連携の検証（LEX画面 / 一括登録）でキャンセルボタンを押下した場合に「Attempt to de-reference a null object」になる。
      // if (paras.containsKey('vfRetURLInSFX')) {
      //   // LEX: Do nothing.
      // }
      // else if (paras.containsKey('retURL')) {
      //   this.retUrl = paras.get('retUrl');
      // }
      // else if (paras.containsKey('id')) {
      //   this.retUrl = '/' + paras.get('id');
      // }
      if (this.cardIds.isEmpty()) {
        String ncId = paras.get('id');
        if (ncId != null) {
          this.cardIds.add(ncId);
        }
      }
      if (this.cardIds.isEmpty()) {
        return;
      }
      //String query = String.format(QUERY_FORM, new String[] { String.join(new List<String>(ncFields), ', ') });
      //System.debug(query);
      //List<NameCard__c> cards = Database.query(query);
      List<NameCard__c> cards = getCards(this.cardIds);
      if (!cards.isEmpty() && this.cardIds.size() == 1) {
        this.nameCard = cards[0];
      }
      // 名刺と登録先候補情報の収集
      List<SB_NameCard_RegistCardHolder.AccountCardHolder>  holders
            = (List<SB_NameCard_RegistCardHolder.AccountCardHolder>)SB_NameCard_RenkeiTargetsPicker.createCardHolders(cards, Account.sObjectType);
      // 既存の登録先の候補リストを作成
      buildCandidateList(holders);
      if (holders.size() == 1) {
        // 新規作成画面のパラメータ作成
        buildCreateAccountParam(holders);
      }
    }
    catch(Exception e) {
      System.debug(e.getMessage());
      this.disableRun = true;  // v2.4
      ApexPages.addMessages(e);
    }
  }

  public class TestResult {
    public Boolean success { get; private set; }
    public Boolean ignore { get; private set; } // 処理対象の名刺ではない
    public String acntProcess { get; private set; } //
    public String contProcess { get; private set; } //
    public String message { get; private set; }
    public NameCard__c card { get; private set; }
    public String accountValues { get; private set; }
    public String contactValues { get; private set; }
    //public Map<String, Object> accountItems { get; private set; }
    //public Map<String, Object> contactItems { get; private set; }

    public TestResult(SB_NameCard_RegistCardHolder.AccountCardHolder holder) {
      this.success = holder.isSuccess();
      this.message = holder.renkeiMessage;
      this.card = holder.card;
      this.ignore = SB_NameCard_RenkeiChecker.getInstance().isIgnore(this.card);   // 処理対象の名刺ではない
      this.acntProcess = SB_NameCard_RegistProcessor.getProcessName(holder.acntProcess);
      this.contProcess = SB_NameCard_RegistProcessor.getProcessName(holder.contProcess);
      if (holder.acnt != null) {
        accountValues = buildValuesText(holder.acnt);
        //accountItems = buildValuesMap(holder.acnt);
        //accountItems = holder.acnt.getPopulatedFieldsAsMap();
        accountValues = SB_NameCard_RenkeiMonitorController.getEscapedJSONString(holder.acnt.getPopulatedFieldsAsMap());
      }
      if (holder.cont != null) {
        //contactValues = buildValuesText(holder.cont);
        //contactItems = buildValuesMap(holder.cont);
        //contactItems = holder.cont.getPopulatedFieldsAsMap();
        contactValues = SB_NameCard_RenkeiMonitorController.getEscapedJSONString(holder.cont.getPopulatedFieldsAsMap());
      }
    }
    private String buildValuesText(SObject obj) {
      String result;
      Map<String,Object> values = obj.getPopulatedFieldsAsMap();
      List<String> items = new List<String>();
      for (String key : values.keySet()) {
        Object o = values.get(key);
        String t = String.valueOf(o);
        items.add(key + ': ' + t);
      }
      result = String.join(items, ', ');
      return result;
    }
    //private Map<String, String> buildValuesMap(SObject obj) {
    //  Map<String, String> result = new Map<String, String> ();
    //  Map<String,Object> values = obj.getPopulatedFieldsAsMap();
    //  List<String> items = new List<String>();
    //  for (String key : values.keySet()) {
    //    Object o = values.get(key);
    //    String t = String.valueOf(o);
    //    result.put(key, t);
    //  }
    //  return result;
    //}
  } //public class TestResult {

  // SV_DEV-652 自動連携検証用ツール(SmartViscaT05) : 英語名刺を検証した場合に処理結果のリンクが反応しない
  @TestVisible
  private static String getEscapedJSONString(Map<String, Object> values) {
    Map<String, Object> escaped = new Map<String, Object>();
    for (String key : values.keySet()) {
      Object val = values.get(key);
      if (val != null && val instanceOf String) {
        escaped.put(key, ((String)val).escapeEcmaScript());
      }
      else {
        escaped.put(key, val);
      }
    }
    return JSON.serialize(escaped);
  }

  public void startProcess() {
    this.buttonLabel = System.Label.SB_NC_RenkeiMon_Running; // '実行中…';
    this.buttonStatus = true;
  }

  //
  public PageReference runAll() {
    Savepoint sp = Database.setSavepoint();
    try {
    // SV_DEV-952 「自動連携の検証」で Query of LOB fields caused heap usage to exceed limit エラーがでる。  ↓ よけいなので外します。
    // String query = String.format('SELECT {0} FROM NameCard__c', new String[] { String.join(new List<String>(ncFields), ', ') });
    // System.debug(query);
    // List<NameCard__c> temps = Database.query(query);


      if (this.cardIds.isEmpty()) {
        return null;
      }

      List<NameCard__c> cards = getCards(this.cardIds);
      List<SB_NameCard_RegistCardHolder.AccountCardHolder> holders =
        SB_NameCard_RenkeiTriggerHelper.doRenkei(cards, SB_NameCard_RenkeiTriggerHelper.ProcType.Account);

      this.results = new List<TestResult>();
      for (SB_NameCard_RegistCardHolder.AccountCardHolder h : holders) {
        this.results.add(new TestResult(h));
      }

      Database.rollback(sp);
    }
    catch(Exception e) {
      if (sp != null) {
        Database.rollback(sp);
      }
    }
    this.buttonLabel = System.Label.SB_NC_RenkeiMon_TryRegistration;  // '登録を試す';
    this.buttonStatus = false;
    this.terminateTime = Datetime.now().format('yyyy/MM/dd HH:mm:ss:SS' );
    return null;
  }


  // 戻り先のURLを作ります。
  // https://svt01-dev-ed.lightning.force.com/lightning/o/smvTest__NameCard__c/list?filterName=00B0I00000B2kx4UAB
  // https://svdev-sawano-dev-ed.my.salesforce.com/a06?fcf=00B6F00000Iya1x
  private static String RETURN_URL_FORM_LEX = '{0}/lightning/o/{1}/list?filterName={3}';
  private static String RETURN_URL_FORM = '{0}/{2}?fcf={3}';
  @TestVisible
  private static String getRetunrUrl(String viewId, Boolean bLex) {
    DescribeSObjectResult dsr = NameCard__c.getSObjectType().getDescribe();
    return String.format(bLex ? RETURN_URL_FORM_LEX : RETURN_URL_FORM,
                  new String[] { System.URL.getSalesforceBaseUrl().toExternalForm(), dsr.getName(), dsr.getKeyPrefix(), viewId });
  }

  // クエリパラメータからリストビューのIDを取得します。
  @TestVisible
  private static String getViewidFromUrl(String u, Boolean bLex) {
    if (String.isBlank(u)) {    // LEXのときはない
      return '';
    }
    String[] ss= u.split('[?&]');     // LEX のとき、URLが不定かも？
    if (bLex) {
      for(String s : ss) {
        if (s.startsWithIgnoreCase('filterName=')) {
          return s.substringAfter('filterName=');
        }
      }
    }
    else {
      for(String s : ss) {
        if (s.startsWithIgnoreCase('fcf=')) {
          return s.substringAfter('fcf=');
        }
      }
    }
    return '';
  }

  @RemoteAction
  public static String getCreateParameters(String cardId) {
    String result;
    System.debug('cardId: ' + cardId);
    // ID の正当性チェック
    try {
      Id cId = (Id)cardId;
      if (cId.getSobjectType() != NameCard__c.sObjectType) {
        throw new SB_NameCard_RenkeiTraceControllerException();
      }
    }
    catch(Exception e) {
      throw new SB_NameCard_RenkeiTraceControllerException('Invalid Record Id.');
    }
    // アカウントを作って、各値を取得
    try {
      List<Id> cardIds = new List<Id>();
      cardIds.add(cardId);
      List<NameCard__c> cards = getCards(cardIds);
      List<SB_NameCard_RegistCardHolder.AccountCardHolder> holders
                = (List<SB_NameCard_RegistCardHolder.AccountCardHolder>)SB_NameCard_RenkeiTargetsPicker.createCardHolders(cards, Account.sObjectType);
      Account acnt = holders[0].buildNewAccount(accountRectypeId, UserInfo.getUserId());
      if (acnt == null) {
        throw new SB_NameCard_RenkeiTraceControllerException();
      }
      if (isClassicUI()) {
        // Cassic 用
        result = SB_NameCard_CreateRecordParameterBuilder.buildClassic(acnt);
      }
      else {
        // LEX用
        result = SB_NameCard_CreateRecordParameterBuilder.buildLex(acnt);
      }
      System.debug(result);
    }
    catch(Exception e) {
      throw new SB_NameCard_RenkeiTraceControllerException('Failed to create Account data');
    }
    return result;
  }

}