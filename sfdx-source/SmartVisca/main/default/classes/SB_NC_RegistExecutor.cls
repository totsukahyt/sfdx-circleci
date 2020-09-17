/**
 *
 * SB_NC_RegistExecutor
 *   Lightning Express 対応 取引先・取引先責任者  一括登録画面
 *    v1.20 から Classic版 取引先登録もこちらを使ってマッピングを反映する。
 *
 * Copyright (C) 2016-2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.11.xx
 *  @Version 2      2017.04.xx   クラッシク版取引先登録もこちらを使うので 調整　トリガ版、UI版の統一化
 *  @Version 2.2    sawano   2019.03.XX 2.1.1 パッチで で2019.02 コードスキャンをパス → セキュリティレビュー更新 2.2へ反映
 *  @Version 4      2019.07.xx sawano   v2.4 SV_DEV-437 名刺から子取引先の作成
 *                          複数名刺項目から 連携先項目合成対応 SV_DEV-395 医療法人のデータ納品について
 *                          SV_DEV-1742 取引先・取引先責任者に登録の上書きで取責の所有者が無効なユーザである場合、Todo登録をエラーにしないでほしい 個別登録改修
 *
 **/
global with sharing class SB_NC_RegistExecutor extends SB_NameCard_RegistProcessor {
  global class SB_NC_RegistExecutorException extends Exception {}

  // 処理の実行は この 　staticメソッドを外部から呼び出します。
  global static RegistResponse doRegist(RegistRequest req) {
    System.debug('RegistRequest: ' +  req);
    SB_NC_RegistExecutor proc = new SB_NC_RegistExecutor(req);
    proc.run();
    return proc.getRegistResponse();
  }

  private final static String NAMECARD_QUERY_FROM = 'SELECT {0} FROM NameCard__c WHERE Id IN :ids';

  /////////////
  // CardHolder配列を作るクラスの基底
  /////////////
  private abstract class CardHolderBuilder {
    //public CardHolderBuilder() {}
    public abstract List<SB_NameCard_RegistCardHolder.CardHolder> create(List<RegistTarget> targets);

    protected abstract List<SB_NameCard_RenkeiMapper> getMappers();

    protected Map<Id, NameCard__c> createNameCardMap(Set<Id> cardIds) {
      Set<Id> ids = new Set<Id>(cardIds);
      //String query = 'SELECT ';
      Set<String> fields = new Set<String>();
      for (SB_NameCard_RenkeiMapper mapper : getMappers()) {
        fields.addAll(mapper.getNameCardQueryFields());
      }
      String ns = SB_NameCard_Util.getNamespacePrefix_x();
      // Name
      fields.add('Name');
      // 所有者
      fields.add('OwnerId');
      // 名刺交換日  2017.04.25
      fields.add(ns + 'card_exchange_date__c');
      // 会社名
      fields.add(ns + 'company_name__c');
      // 住所用の項目
      fields.add(ns + 'address_pref__c');
      fields.add(ns + 'address__c');
      fields.add(ns + 'address_eng__c');
      fields.add(ns + 'address_bld__c');
      // 姓名用の項目
      fields.add(ns + 'person_name_last__c');
      fields.add(ns + 'person_name_first__c');
      fields.add(ns + 'last_name__c');
      fields.add(ns + 'first_name__c');
      // 上書きしない
      fields.add(ns + 'isNotOverwrite__c');
      fields.add(ns + 'isNotOverContactwrite__c');
      // 参照項目
      fields.add(ns + 'account__c');
      fields.add(ns + 'contact__c');
      fields.add(ns + 'lead__c');
      //  CardHolder で 識別用に使っている項目
      fields.add(ns + 'division__c');
      fields.add(ns + 'zip_code__c');
      fields.add(ns + 'tel1__c');
      fields.add(ns + 'tel2__c');
      fields.add(ns + 'web_url1__c');
      fields.add(ns + 'web_url2__c');
      fields.add(ns + 'memo__c');
      fields.add(ns + 'email__c');

      //removeAddressLabel(fields);
      fields.remove('city');
      fields.remove('street');
      fields.remove('pref_address_bld');
      fields.remove('address_bld');
      fields.remove('street_nobld');
      fields.remove('last_name');
      fields.remove('first_name');
      // クエリ文字列
      String query = String.format(NAMECARD_QUERY_FROM, new String[] { String.join(new List<String>(fields), ', ') });
      System.debug('+++createNameCardMap: ' + query);
      return new Map<Id, NameCard__c>((List<NameCard__c>)Database.query(query));
    }
  }

  /////////////
  // 取引先登録用の CardHolder配列を作るクラス
  /////////////
  private class RegistCardHolderBuilder extends CardHolderBuilder {
    // 名詞から マッピングをもとに対象のレコードを作る クラス たち 、必要な名詞の項目を知るため
    private List<SB_NameCard_RenkeiMapper> mappers;

    public RegistCardHolderBuilder() {
      mappers = new List<SB_NameCard_RenkeiMapper>();
    }

    protected override List<SB_NameCard_RenkeiMapper> getMappers() {
      return mappers;
    }

    public void createMappers(RegistParam acntParam, RegistParam contParam) {
      // アカウントの
      if (acntParam.orgNameWithDept == true) {
        // v2.4 2019.07.xx 複数名刺項目から 連携先項目合成対応 SV_DEV-395 医療法人のデータ納品について
        mappers.add(SB_NameCard_RenkeiMapper.getInstance(Account.sObjectType.getDescribe().getName(), false,
                      new Map<String, List<String>> { 'name' => new List<String> {'company_name__c', 'division__c'}},
                      new Set<String> { 'site' } ));
      }
      else {
        // 通常
        mappers.add(SB_NameCard_RenkeiMapper.getInstance(Account.sObjectType.getDescribe().getName(), false));
      }
      // コンタクトの
      if (contParam.orgNameWithDept == true) {
        // v2.4 2019.07.xx 複数名刺項目から 連携先項目合成対応 SV_DEV-395 医療法人のデータ納品について
        mappers.add(SB_NameCard_RenkeiMapper.getInstance(Contact.sObjectType.getDescribe().getName(), false,
                      null, new Set<String> { 'department' }));
      }
      else {
        // 通常
        mappers.add(SB_NameCard_RenkeiMapper.getInstance(Contact.sObjectType.getDescribe().getName(), false));
      }
    }

    // 登録元名刺と 対象レコードの情報を装填
    public override List<SB_NameCard_RegistCardHolder.CardHolder> create(List<RegistTarget> targets) {
      List<SB_NameCard_RegistCardHolder.RegistCardHolder> result = new List<SB_NameCard_RegistCardHolder.RegistCardHolder>();
      Set<Id> sourceCardIds = new Set<Id>();
      Set<Id> acntIds = new Set<Id>();
      Set<Id> contIds = new Set<Id>();
      Set<Id> someIds = new Set<Id>();
      for (RegistTarget t : targets) {
        sourceCardIds.add(t.cardId);
        if (t.acntId != null) {
          acntIds.add(t.acntId);
        }
        if (t.contId != null) {
          contIds.add(t.contId);
        }
        if (t.someId != null) {
          someIds.add(t.someId);
        }
      }

      Map<Id, NameCard__c> cards; // 名刺レコード
      Map<Id, Account> acnts; // 既存の アカウント
      Map<Id, Contact> conts; // 既存の コンタクト
      Map<Id, SObject> somes; // 既存の 何か

      if (!sourceCardIds.isEmpty()) {
        cards = createNameCardMap(sourceCardIds);
        if (sourceCardIds.size() != cards.size()) {
          throw new SB_NC_RegistExecutorException(String.format(MSG_INVALIDOBJECTID, new String[]{NameCard__c.SObjectType.getDescribe().getLabel()}));
        }
      }
      if (!acntIds.isEmpty()){
        acnts = new Map<Id, Account>([SELECT Id, Name, OwnerId, Owner.Name FROM Account WHERE Id IN :acntIds]);
        if (acntIds.size() != acnts.size()) {
          throw new SB_NC_RegistExecutorException(String.format(MSG_INVALIDOBJECTID, new String[]{Account.SObjectType.getDescribe().getLabel()}));
        }
      }
      if (!contIds.isEmpty()) {
        conts = new Map<Id, Contact>([SELECT Id, Name, OwnerId, Owner.Name FROM Contact WHERE Id IN :contIds]);
        if (contIds.size() != conts.size()) {
          throw new SB_NC_RegistExecutorException(String.format(MSG_INVALIDOBJECTID, new String[]{Contact.SObjectType.getDescribe().getLabel()}));
        }
      }
      //if (!someIds.isEmpty()) {
      //  somes = createSobjects(req.someParam.getSObjectType(), someIds);
      //  if (someIds.size() != somes.size()) {
      //    throw new SB_NC_RegistExecutorException(String.format(MSG_INVALIDOBJECTID, new String[]{req.someParam.getSObjectType().getDescribe().getLabel()}));
      //  }
      //}

      for (Integer n = 0; n < targets.size(); n++) {
        RegistTarget t = targets.get(n);
        NameCard__c card = cards.get(t.cardId);
        SB_NameCard_RegistCardHolder.RegistCardHolder holder = new SB_NameCard_RegistCardHolder.RegistCardHolder(card);
        holder.setNumber(n);    // リストの順番
        // SV_DEV-437 名刺から子取引先の作成 に対応して、
        if (t.acntId != null && !t.createChildAccount) {
          // 更新する 子アカウントでないとき
          holder.setAccountId(t.acntId);
          holder.setAccount(acnts.get(t.acntId));
        }
        else if (t.acntId != null && t.createChildAccount) {
          // 親アカウント指定で 子アカウントを作る。
          holder.setParentAccountId(t.acntId);
        }
        if (t.contId != null) {
          holder.setContactId(t.contId);
          holder.setContact(conts.get(t.contId));
        }
        holder.setCreateTodo(t.createTodo);
        holder.setTodoDate(t.todoDate);
        result.add(holder);
      }
      return result;
    }

  }

  // +--------------------------------------------------------+
  // +---- リクエスト用 ----+
  // +---- リクエスト全体 ----+
  global virtual class RegistRequest {
    @TestVisible global List<RegistTarget> targets { get; private set; } // 対象のレコード達のID
    @TestVisible global RegistParam acntParam { get; private set; }      // アカウント登録のパラメータ
    @TestVisible global RegistParam contParam { get; private set; }      // コンタクト登録のパラメータ
    @TestVisible global RegistParam someParam { get; private set; }      // リード登録のパラメータ を想定  未実装
    @TestVisible global TodoParam todoParam { get; private set; }     // 作成するToDo用のパラメータ
    global RegistRequest() {}
    // 2017.04.xx
    global RegistRequest(List<RegistTarget> targets, RegistParam acntParam, RegistParam contParam, RegistParam someParam, TodoParam todoParam) {
      this.targets = targets;
      this.acntParam = acntParam;
      this.contParam = contParam;
      this.someParam = someParam;
      this.todoParam = todoParam;
    }
    global Boolean isAccountContact() {
      return someParam == null;
    }
    global Set<SObjectType> getTargetSObject() {
      Set<SObjectType> result = new Set<SObjectType>();
      if (isAccountContact()) {
        result.add(Account.getSObjectType());
        result.add(Contact.getSObjectType());
      }
      else {
        result.add(someParam.getSObjectType());
      }
      return result;
    }
  }
  // +---- リクエスト 対象のオブジェクトID と ToDo オン・オフ を保持する用 クラス----+
  global virtual class RegistTarget {
    @TestVisible global Id cardId { get; private set; }     //  名刺のID 必須
    @TestVisible global Id acntId { get; private set; }     //  アカウントのID acntParam で NULL なら 新規作成する
    @TestVisible global Id contId { get; private set; }     //  コンタクトのID contParam で NULL なら 新規作成する
    @TestVisible global Id someId { get; private set; }     //  リードのIDを想定 someParam で NULL なら 新規作成する 未実装
    @TestVisible global Boolean createTodo { get; private set; }   // TRUE： ToDoを作る
    @TestVisible global Date todoDate { get; private set; }        // ToDoの日付
    @TestVisible global Boolean createChildAccount { get; private set; }   // 選択した acntId を親アカウントとした子アカウントを新規作成、コンタクト新規作成
    global RegistTarget() {
       this.cardId = null;
       this.acntId = null;
       this.contId = null;
       this.someId = null;
       this.createTodo = false;
       this.todoDate = Date.today();      // 2017.04.25 null だったら名刺交換日、名刺交換日もNULLなら Date.today();
       this.createChildAccount = false;
    }
    // 2017.04.xx
    global RegistTarget(Id cardId, Id acntId, Id contId, Id someId, Boolean createTodo, Date todoDate) {
       this.cardId = cardId;
       this.acntId = acntId;
       this.contId = contId;
       this.someId = someId;
       this.createTodo = createTodo;
       this.todoDate = todoDate;      // 2017.04.25 null だったら名刺交換日、名刺交換日もNULLなら Date.today();
       this.createChildAccount = false;
    }
    // v2.4 2019.07.xx 
    global RegistTarget(Id cardId, Id acntId, Id contId, Id someId, Boolean createTodo, Date todoDate, Boolean createChildAccount) {
       this.cardId = cardId;
       this.acntId = acntId;
       this.contId = contId;
       this.someId = someId;
       this.createTodo = createTodo;
       this.todoDate = todoDate;      // 2017.04.25 null だったら名刺交換日、名刺交換日もNULLなら Date.today();
       this.createChildAccount = createChildAccount; // SV_DEV-437 名刺から子取引先の作成
    }

    //// 名刺レコードの値が必要かどうか
    // 新規作成がある？  some TRUE:アカウント・コンタク 登録でないとき
    global Boolean isCopyCardValues(RegistRequest req) {
      //return (req.isAccountContact() && (acntId ==null || req.acntParam.overwrite || contId ==null || req.contParam.overwrite))
      //  || (!req.isAccountContact() && (someId ==null || req.someParam.overwrite));
      return true;
    }
  }

  // +---- リクエスト 登録条件用クラス ----+
  global virtual class RegistParam {
    @TestVisible global String objName { get; private set; }
    @TestVisible global Boolean overwrite { get; private set; }
    @TestVisible global Id recTypeId { get; private set; }
    @TestVisible global Id ownerId { get; private set; }   //
    @TestVisible global Boolean allowSave { get; private set; }      // 重複してても作成・更新する。
    @TestVisible global Map<String, Object> filed2value { get; private set; }  // 特定の項目の値を指定してよこす リードの キャンペーンIDとか
    @TestVisible global Boolean orgNameWithDept { get; private set; }      // 取引先名（リード会社名）は 名刺の会社名と所属 からSV_DEV-65 医療法人・学校法人の会社名・部署名編集 -> リード・取引先・取引先責任者に登録時に編集する
    global RegistParam() {
      this.overwrite = false;
      this.allowSave = false;
      this.orgNameWithDept = false;
    }
    // 2017.04.xx
    global RegistParam(String objName, Boolean overwrite, Id recTypeId, Id ownerId, Boolean allowSave) {
      this.objName = objName;
      this.overwrite = overwrite;
      this.recTypeId = recTypeId;
      this.ownerId = ownerId;
      this.allowSave = allowSave;
      this.orgNameWithDept = false;
    }
    // 2019.07.xx v2.4
    global RegistParam(String objName, Boolean overwrite, Id recTypeId, Id ownerId, Boolean allowSave, Boolean orgNameWithDept) {
      this.objName = objName;
      this.overwrite = overwrite;
      this.recTypeId = recTypeId;
      this.ownerId = ownerId;
      this.allowSave = allowSave;
      this.orgNameWithDept = orgNameWithDept;
    }
    global SObjectType getSObjectType() {
      return Schema.getGlobalDescribe().get(objName);
    }
  }

  // +---- リクエスト 登録するToDo の内容用クラス ----+
  global virtual class TodoParam {
    @TestVisible global String subject { get; private set; }        // ToDoの件名
    @TestVisible global Date activityDate { get; private set; }     // 未使用？
    @TestVisible global String comment { get; private set; }        // コメント
    @TestVisible global Id ownerId { get; private set; }   // ToDoの所有者
    global TodoParam() {}
    // 2017.04.xx
    global TodoParam(String subject, Date activityDate, String comment, Id ownerId) {
      this.subject = subject;
      this.activityDate = activityDate;
      this.comment = comment;
      this.ownerId = ownerId;
    }
  }
  // +---- リクエスト用 ----+
  // +--------------------------------------------------------+


  // +--------------------------------------------------------+
  // +---- レスポンス用 ----+
  // +---- レスポンス全体 ----+
  global with sharing class RegistResponse { // v2.1.1 コードスキャン対応で with sharing 追加
    global RegistRequest req { get; private set; }
    global Boolean success { get; private set; }
    global String process { get; private set; }       // 何の処理をやるとこか  エラーの通知用
    global Map<Id, SB_NameCard_SaveResult.DbErrorHolder> dbErrors;
    global Map<Id, RegistedSummary> registeds; // new
    global String title { get; private set; }       // エラーのタイトル
    global String message { get; private set; }        // エラーメッセージ
    global List<String> messages { get; private set; } // エラーメッセージ DMLでのエラー
    global String errorObject { get; private set; }    // エラーのあったオブジェクト
    //global Boolean htmMsg { get; private set; }       // title が HTML タグを含むとき TRUE
    global Boolean allowRetry { get; private set; }    // 再試行を許可する場合 TRUE  重複エラーの場合にありえる。


    private Map<Id, SObject> querySObjects(String objName, Set<Id> ids) {
      Set<Id> targetIds = ids;
      String query = 'SELECT Id, Name, OwnerId, Owner.Name FROM ' + objName + ' WHERE Id IN :targetIds';
      return new Map<Id, SObject> (Database.query(query));
    }

    global RegistResponse(RegistRequest req) {
      this.req = req;
      this.success = false;
      this.allowRetry = false;
      this.errorObject = null;
    }

    public void finalize(List<SB_NameCard_RegistCardHolder.RegistCardHolder> holders) {
      this.success = true;
      Set<Id> acntIds = new Set<Id>();
      Set<Id> contIds = new Set<Id>();
      Set<Id> someIds = new Set<Id>();
      for (SB_NameCard_RegistCardHolder.RegistCardHolder holder : holders ) {
        acntIds.add(holder.acnt.Id);
        contIds.add(holder.cont.Id);
      }
      Map<Id, SObject> acnts = querySObjects('Account', acntIds);
      Map<Id, SObject> conts = querySObjects('Contact', contIds);
      //resetRegistedSObjects(cardId2Registed);   // Inseet or Update 後のレコードに 入れ換え  TODO 入れ換えずに RegistedSummary をあたしいレコードで作る。
      this.registeds = new Map<Id, RegistedSummary>();
      for (SB_NameCard_RegistCardHolder.RegistCardHolder holder : holders) {
        RegistedSummary sum = new RegistedSummary(holder.card.Id);
        SObject acnt = acnts.get(holder.acnt.Id);
        sum.addRecord(acnt);
        SObject cont = conts.get(holder.cont.Id);
        sum.addRecord(cont);
        if (holder.todo != null) {
          sum.addRecord(holder.todo);
        }
        this.registeds.put(holder.card.Id, sum);
      }
    }

    global void falt(String title, String message, Integer lineNumber) {
      this.title = title;
      this.message = String.format('{0} ({1})', new String[] {message, String.valueOf(lineNumber)});
    }
    // 例外が発生したとき
    global void falt(String message) {
      this.title = message;   // 残します。 ← SV_DEV-816 重複ルール設定時のClassic画面の一括登録でのエラーメッセージ内がnullで表示される箇所がある。
      this.success = false;
      this.message = message;
    }
    // DML でエラーがあったらこれをよんで、エラー内容をセット して、終わる。
    public void setError(SB_NameCard_DMLProcessor.UiDmlProcessor error) {
      this.success = false;
      this.dbErrors = error.id2dbError;
      this.allowRetry = error.allowRetry;
      this.messages = error.messages;
    }

  }   // RegistResponse

  global class RegistedSummary {
    global Id cardId { get; private set; }
    global SObjectInfo acnt { get; private set; }
    global SObjectInfo cont { get; private set; }
    global SObjectInfo some { get; private set; }
    global SObjectInfo todo { get; private set; }
    public RegistedSummary(RegistedSObjects registed) {
      this.cardId = registed.cardId;
      for (SObjectType otype : registed.objs.keySet()) {
        SObject obj = registed.objs.get(otype);
        SObjectInfo info = new SObjectInfo(obj);
        if (otype == Account.sObjectType) {
          acnt = info;
        }
        else if (otype == Contact.sObjectType) {
          cont = info;
        }
        else if (otype == Task.sObjectType) {
          todo = info;
        }
        else {
          some = info;
        }
      }
    }
    public RegistedSummary(Id cardId) {
      this.cardId = cardId;
    }
    public void addRecord(SObject obj) {
      SObjectInfo info = new SObjectInfo(obj);
      if (obj.getSObjectType() == Account.sObjectType) {
        acnt = info;
      }
      else if (obj.getSObjectType() == Contact.sObjectType) {
        cont = info;
      }
      else if (obj.getSObjectType() == Task.sObjectType) {
        todo = info;
      }
      else {
        some = info;
      }
    }
  }

  global class SObjectInfo {
    global Id id { get; private set; }
    global Object name { get; private set; }
    global Id ownerId { get; private set; }
    global Object ownerName { get; private set; }
    global SObjectInfo(SObject obj) {
      this.id = obj.Id;
      this.ownerid = (Id)obj.get('OwnerId');
      SObject ownerUser = obj.getSObject('Owner');
      this.ownerName = ownerUser != null ? ownerUser.get('Name') : null;
      if (obj.getSObjectType() == Task.sObjectType || obj.getSObjectType() == Event.sObjectType) {
        this.name = obj.get('Subject');
      }
      else {
        this.name = obj.get('Name');
      }

      System.debug(this.name);
    }
  }

  // 作成・更新したレコードを持ってるクラス
  private class RegistedSObjects {
    private Id cardId { get; private set; }
    private Map<SObjectType, SObject> objs { get; private set; }
    public RegistedSObjects(Id cardIed) {
      this.cardId = cardId;
      objs = new Map<SObjectType, SObject>();
    }
    public void putSObject(SObject obj) {
      objs.put(obj.getSObjectType(), obj);
    }
    public SOBject getSObject(SObjectType otype) {
      return objs.get(otype);
    }
  }
  // +---- レスポンス用 ----+
  // +--------------------------------------------------------+

  private RegistRequest req;
  private RegistResponse result;

  global RegistResponse getRegistResponse() {
    return result;
  }

  private Boolean success;
  private Map<SObjectType, SB_NameCard_RenkeiMapper> mappers;

  // SB_NCL_RegistExecutor 
  // +--------------------------------------------------------+
  global SB_NC_RegistExecutor() {
    super();
    this.success = false;
    this.req = null;
    this.result = new RegistResponse(this.req);
  }

  global SB_NC_RegistExecutor(RegistRequest req) {
    super();
    this.success = false;
    this.req = req;
    this.result = new RegistResponse(this.req);
  }

  global override void run() {
    Savepoint sp = null;
    try {
      // 関連する既存のレコードを集める
      this.result.process = 'start';
      // 対象のアカウントとコンタクトのIDを収集
      RegistCardHolderBuilder builder = new RegistCardHolderBuilder();
      builder.createMappers(this.req.acntParam, this.req.contParam);
      this.holders = (List<SB_NameCard_RegistCardHolder.RegistCardHolder> )builder.create(this.req.targets);

      ownerCheckProc();  // 2019.09.xx v2.4 所有者のチェック

      sp = Database.setSavepoint();

      this.result.process = 'account';
      accountProc();

      this.result.process = 'contact';
      contactProc();

      this.result.process = 'namecard';
      cardProc();

      // ToDo を作成
      this.result.process = 'todo';
      todoProc();

      // 既存の行動、ToDoの 名前WhoIdを作成したコンタクトにする。
      this.result.process = 'activity';
      activityProc();

      this.result.process = 'finalize';
      //this.result.finalize(this.cardId2Registed);
      this.result.finalize(this.holders);
      this.result.process = 'end';
    }
    catch(Exception e) {
      if (sp != null) {
        Database.rollback(sp);
      }
      this.success = false;
      if (e instanceOf SB_NC_RegistExecutorException) {
        this.result.falt(e.getMessage());
      }
      else if (e instanceOf SB_NameCard_CrudFls.CrudFlsException) {
        this.result.falt(e.getMessage());
      }
      else {
        throw e;
      }
    }
    //return this.result;
  }

  private void ownerCheckProc() {
    if (this.req.targets.size() != 1) {
      // 一括ではここでチェックしない。
      return;
    } 
    Id cardId = this.req.targets.get(0).cardId;
    Map<Id, String> ownerErrorMap = SB_NameCard_RegistOwnerCheckHelper.doCheck(this.req, setting.RegistToDoOwner__c == 'NameCardOwner');
    if (!ownerErrorMap.isEmpty() && ownerErrorMap.containsKey(cardId)) {
      throw new SB_NC_RegistExecutorException(ownerErrorMap.get(cardId));
    }
  }

  // private static final String MSG_INVALIDOBJECTID = 'リクエストに不正な{0}IDがあります。';
  private static final String MSG_INVALIDOBJECTID = 'Invalid {0} record Id in request.';

  // アカウントを作成 か 更新 
  // アカウントについて処理する工程
  public override void accountProc() {
    Map<Id, Account> acntId2UpdAccount = new Map<Id, Account>();
    Map<String, Account> companyId2NewAccount = new Map<String, Account>();
    SB_NameCard_DMLProcessor.UiDmlProcessor newAcntProc = new SB_NameCard_DMLProcessor.UiDmlProcessor(Account.sObjectType, this.req.acntParam.allowSave);
    SB_NameCard_DMLProcessor.UiDmlProcessor updAcntProc = new SB_NameCard_DMLProcessor.UiDmlProcessor(Account.sObjectType, this.req.acntParam.allowSave);

    for(SB_NameCard_RegistCardHolder.RegistCardHolder holder : this.holders) {
      if (holder.isExistAccount()) {
        // 既存の更新
        if (this.req.acntParam.overwrite) {
          // 更新するとき
          Id acntId = holder.getTargetAccountId();
          if (acntId2UpdAccount.containsKey(acntId)) {
            // すでに別の名刺で更新用アカウントを作ってた。
            Account acnt = acntId2UpdAccount.get(acntId);
            holder.putAccount(acnt);
          }
          else {
            Account acnt = holder.buildUpdAccount();
            acntId2UpdAccount.put(acnt.Id, acnt);
            updAcntProc.addCardHolder(holder);
          }
        }
        else {
          // 更新せずリンクのみ
          //holder.bindExistAccount();
          System.debug('Account: not overwrite');
        }
      }
      else {
        // 新規作成する。
        if (companyId2NewAccount.containsKey(holder.companyId)) {
          // すでに別の名刺で新規アカウントを作ってた。
          Account acnt = companyId2NewAccount.get(holder.companyId);
          holder.putAccount(acnt);
        }
        else {
          Id ownerId = this.req.acntParam.ownerId == null ? holder.card.OwnerId : this.req.acntParam.ownerId; // NULL は一括登録のとき、
          Account acnt = holder.buildNewAccount(this.req.acntParam.recTypeId, ownerId);
          companyId2NewAccount.put(holder.companyId, acnt);
          newAcntProc.addCardHolder(holder);
        }
      }
    } // for
    // 更新処理
    if (updAcntProc.haveSObjects()) {
      updAcntProc.dbUpdate();
      if (!updAcntProc.success) {
        this.result.setError(updAcntProc);
        throw new SB_NC_RegistExecutorException(String.format(Label.SB_NC_Regist_Error_Occured, new String[]{Account.SObjectType.getDescribe().getLabel()}));
      }
    }
    // 作成処理
    if (newAcntProc.haveSObjects()) {
      newAcntProc.dbCreate();
      if (!newAcntProc.success) {
        this.result.setError(newAcntProc);
        throw new SB_NC_RegistExecutorException(String.format(Label.SB_NC_Regist_Error_Occured, new String[]{Account.SObjectType.getDescribe().getLabel()}));
      }
    }
  } // protected void accountProc()

  // コンタクトを作成 か 更新
  // コンタクトについて処理する工程
  public override void contactProc() {
    Map<Id, Contact> contId2UpdContact = new Map<Id, Contact>();
    Map<String, Contact> personId2NewContact = new Map<String, Contact>();
    SB_NameCard_DMLProcessor.UiDmlProcessor newContProc = new SB_NameCard_DMLProcessor.UiDmlProcessor(Contact.sObjectType, this.req.contParam.allowSave);
    SB_NameCard_DMLProcessor.UiDmlProcessor updContProc = new SB_NameCard_DMLProcessor.UiDmlProcessor(Contact.sObjectType, this.req.contParam.allowSave);

    for(SB_NameCard_RegistCardHolder.RegistCardHolder holder : this.holders) {
      //if (holder.getAccountId()== null || holder.isContactTooMuch()) {    // アカウントがない（作れなかった） OR 既存のコンタクが複数いる
      //  continue;
      //}
      if (holder.isExistContact()) {
        // 既存の更新
        if (this.req.contParam.overwrite) {
          Id contId = holder.getTargetContactId();
          if (contId2UpdContact.containsKey(contId)) {
            // すでに別の名刺で更新用コンタクトを作ってた。
            Contact cont = contId2UpdContact.get(contId);
            holder.putContact(cont);
          }
          else {
            Contact cont = holder.buildUpdContact();
            contId2UpdContact.put(contId, cont);
            updContProc.addCardHolder(holder);
          }
        }
        else {
          // 更新せずリンクのみ
          //holder.bindExistContact();
          System.debug('Contact: not overwrite');
        }
      }
      else {
        // 新規作成する。
        if (personId2NewContact.containsKey(holder.personId)) {
          // すでに別の名刺で新規コンタクトを作ってた。
          Contact cont = personId2NewContact.get(holder.personId);
          holder.putContact(cont);
        }
        else {
          Id ownerId = this.req.contParam.ownerId == null ? holder.card.OwnerId : this.req.contParam.ownerId; // NULL は一括登録のとき、
          Contact cont = holder.buildNewContact(this.req.contParam.recTypeId, ownerId);
          personId2NewContact.put(holder.personId, cont);
          newContProc.addCardHolder(holder);
        }
      }
    } // for
    // 更新処理
    if (updContProc.haveSObjects()) {
      updContProc.dbUpdate();
      if (!updContProc.success) {
        this.result.setError(updContProc);
        throw new SB_NC_RegistExecutorException(String.format(Label.SB_NC_Regist_Error_Occured, new String[]{Contact.SObjectType.getDescribe().getLabel()}));
      }
    }
    // 作成処理
    if (newContProc.haveSObjects()) {
      newContProc.dbCreate();
      if (!newContProc.success) {
        this.result.setError(newContProc);
        throw new SB_NC_RegistExecutorException(String.format(Label.SB_NC_Regist_Error_Occured, new String[]{Contact.SObjectType.getDescribe().getLabel()}));
      }
    }
  } // protected void contactProc()

  // 無効なユーザがいたら ユーザの名前を返す。
  //  順番は無視
  // v2.4 
  private List<String> validateUserActivity(Set<Id> userIds) {
    List<String> result = new List<String>();
    List<User> inactives = [SELECT Id, Name FROM User WHERE Id IN :userIds AND IsActive= false];
    for (User u : inactives) {
      result.add(u.Name);
    }
    return result;
  }

  // ToDo を作成
  protected override void todoProc() {
    List<Task> tasks = new List<Task>();
    Set<Id> ownerIds = new Set<Id>();
    for(SB_NameCard_RegistCardHolder.RegistCardHolder holder : this.holders) {
      if (holder.getCreateTodo() == false) {
        continue;
      }
      Task todo = holder.createTodoPrototype(req.todoParam.ownerId);
      todo.Subject = this.req.todoParam.subject;
      todo.Description = this.req.todoParam.comment;
      if (todo.ActivityDate <= Date.today() || todo.ActivityDate == null)  {
        todo.Status = SB_NameCard_Util.taskStatusValues.get('Completed');
      }
      else {
        todo.Status = SB_NameCard_Util.taskStatusValues.get('NotStarted');
      }
      tasks.add(todo);
      ownerIds.add(todo.OwnerId);
    }
    // v2.4 SV_DEV-1742 取引先・取引先責任者に登録の上書きで取責の所有者が無効なユーザである場合、Todo登録をエラーにしないでほしい 個別登録改修
    // ownerCheckProc を入れたのでここでは無効なユーザはいないはずだけど、念の為そのまま
    List<String> inactives = validateUserActivity(ownerIds);
    if (!inactives.isEmpty()) {
      throw new SB_NC_RegistExecutorException(String.format(System.Label.SB_NC_MSG_CanNotSetInActiveUserToOwnerToDo, new String[] { String.join(inactives, ', ')}));
    }
    SB_NameCard_CrudFls.screate(tasks, true);
  }// 

  // 名刺に着いてた 活動の WhoId がNULLだったら、 コンタクト、リードのIDをセットする。
  protected override void activityProc() {
    if (this.cardId2ContactLeadId.isEmpty()) {
      return;
    }
    attachTask();
    attachEvent();
  }

  // 名刺 参照項目をセットして更新
  protected override void cardProc() {
    List<NameCard__c> cards = new List<NameCard__c>();
    for(SB_NameCard_RegistCardHolder.RegistCardHolder holder : this.holders) {
      NameCard__c card = updateCard(holder);
      cards.add(card);
    }
    SB_NameCard_CrudFls.supdate(cards, true);
  }

  // 名刺レコードに 名刺に関連付けた アカウント、コンタクト、リードへの参照項目をセットする。
  //   v1.22 2018.01.xx Beforeトリガでよばれるならレコードはそのまま使うけど、UIでは更新したい項目だけ持ったインスタンスを作るように override する。
  protected override NameCard__c updateCard(SB_NameCard_RegistCardHolder.RegistCardHolder holder) {
    NameCard__c result = new NameCard__c(Id=holder.card.Id);
    //NameCard__c card = holder.card;
    if (holder.isNewAccount() || (holder.isExistAccount() && setting.RenkeiAccountOverwrite__c)) {
      // アカウントを追加・更新していたら => 既存取引先上書き不可
      result.isNotOverwrite__c = !holder.card.isNotOverwrite__c && !setting.RenkeiAccountOverwrite__c && holder.card.account__c == null;
    }
    if (holder.isNewContact() || (holder.isExistContact() && setting.RenkeiContactOverwrite__c)) {
      // コンタクトを追加・更新していたら => 既存取引先責任者上書き不可
      result.isNotOverContactwrite__c = !holder.card.isNotOverContactwrite__c && !setting.RenkeiContactOverwrite__c && holder.card.contact__c == null;
    }
    result.account__c = holder.getAccountId() != null ? holder.getAccountId() : holder.card.account__c;  // アカウントの参照 NULL かも
    result.contact__c = holder.getContactId() !=null ? holder.getContactId() : holder.card.contact__c;   // コンタクトの参照 NULL かも
    if (result.Id != null && result.contact__c != null) { //
      putContactLead(result.Id, result.contact__c);   // 名刺ID- Contact Id  あとで活動のWhoIdにコンタクトIDをつけるのにつかう
    }
    holder.modifySomeCardFields(result);
    return result;
  }


}