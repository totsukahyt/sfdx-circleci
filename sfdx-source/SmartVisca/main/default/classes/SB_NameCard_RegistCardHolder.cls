/**
 *
 * SB_NameCard_RegistCardHolder
 *  アカウント、コンタクト、リードへ登録する 名刺 について、名刺ごとのデータを保持するクラス
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.04.xx
 *  @Version 2      2017.07.xx V1.20.1 取引先のない既存の取引先責任者対応
 *                              SV_DEV-549 自動連係 所有者に関するマッピングが機能していない
 *  @Version 3      2017.12.xx ToDoの任命先を NULL指定のとき 作成・更新した コンタクトのオーナに変更. SV_DEV-715 「取引先・取引先責任者に登録」の更新時のTodoの任命先は取引先責任者の所有者にする
 *                  2018.04.xx v2.0 global にするP
 * @Version 2.2    sawano   2019.03.XX 2.1.1 パッチで で2019.02 コードスキャンをパス → セキュリティレビュー更新 2.2へ反映
 *                          SV_DEV-1497 自動連携で電話番号2を使用しないようにする 
 * @Version 2.4    2019.05.xx  SV_DEV-1638 自動連携の取引先検索で取引先名完全一致の取引先があればあいまい検索一致の取引先があっても重複にしないようにする
 *                             2019.07.xx SV_DEV-437 名刺から子取引先の作成
 * @Version 2.6 全 2020.08.26 PRODUCT-26 自動連携する際に、名刺交換日が最新の場合にのみ取引先・取引先責任者・リードを上書きするようなオプションがほしい
 *
 **/
global with sharing class SB_NameCard_RegistCardHolder {
  ////////////////////////////////////////
  // 名刺に対する既存のレコードの IDを保持するようのクラス
  ////////////////////////////////////////
  global virtual class Target {
    public Id targetId { get; private set; }
    public Target(SObject obj) {
      targetId = obj.Id;
    }
    //public virtual Integer getChildCount() { return 0; }
  }

  ////////////////////////////////////////
  // 名刺に対する既存のアカウント、コンタクト レコードの IDを保持するようのクラス
  ////////////////////////////////////////
  global class AccountTarget extends Target {
    public String name { get; private set; }  // v.2.4 会社名
    public List<Id> childIds { get; private set; }
    public Account account { get; private set; }
    public Map<Id,Contact> childMap { get; private set; }

    public AccountTarget(SObject obj) {
      super(obj);
      this.childIds = new List<Id>();
      this.childMap = new Map<Id,Contact>();
      this.name = (String)obj.get('Name');
      this.account = (Account)obj;
    }
    public void addChild(SObject obj) {
      childIds.add(obj.Id);
      childMap.put(obj.Id, (Contact)obj);
    }
    public Integer getChildCount() { return childIds.size(); }
  }

  ////////////////////////////////////////
  // 名刺と関連するレコードに関する情報を保持する用のクラス
  ////////////////////////////////////////
  global abstract class CardHolder {
    public NameCard__c card { get; private set; }
    public String companyId { get; private set; }   // この名刺の会社の識別用文字列
    public String personId { get; private set; }   // この名刺の個人の識別用文字列
    protected NameCardBasicSetting__c setting;      // 基本設定
    //public String getKaishaKojinName() { return companyId + personId; }
    public CardHolder(NameCard__c card) {
      this.setting = SB_NameCard_BasicSetting.getNameCardBasicSetting();   // 基本設定
      this.card =card;
      buildCompanyId();
      buildPersonId();
      this.personId = this.companyId + 'L=' + this.personId;
    }
    // 指定された方の SObject を返す。
    global abstract SObject getSObject(SObjectType otype);
    // 必要なら、処理状況を保持する。
    public virtual void putMessage(String msg) {}
    // 名刺の項目を更新する。派生クラスごと、名刺の項目の更新する要素が違うときは
    public virtual void modifySomeCardFields(NameCard__c nc) {}
    // この名刺の会社の識別用文字列 同時に処理される同内容の名刺を識別するよう
    private void buildCompanyId() {
      this.companyId = this.card.company_name__c;
      Map<String, String> address = SB_NameCard_Util.getAddress(this.card);
      if (this.setting.RenkeiAccountSite__c) {
        this.companyId += 'D=' + this.card.division__c;
      }
      if (this.setting.RenkeiAccountAddressPref__c) {
        this.companyId += 'P=' + this.card.address_pref__c;
      }
      if (this.setting.RenkeiAccountCity__c) {
        this.companyId += 'C=' + address.get('city');
      }
      if (this.setting.RenkeiAccount_Street__c) {
        this.companyId += 'S=' + address.get('street_nobld'); // 町名・番地 建物なし
      }
      if (this.setting.RenkeiAccountZipCode__c) {
        this.companyId += 'Z=' + this.card.zip_code__c;
      }
      if (this.setting.RenkeiAccountPhone__c) {
        this.companyId += 'T=' + this.card.tel1__c;
        if (!SB_NameCard_Util.smartViscaConfig.AutoConvAccountSearchNotUsePhone2__c) { // 自動連携: 電話番号2 は取引先候補の条件に使わない がFALSE
          // 2019.03.xx v2.2 SV_DEV-1497 自動連携で電話番号2を使用しないようにする の対応、デフォルトのFALSEなら
          this.companyId += ',' + this.card.tel2__c;
        }
      }
      if (this.setting.RenkeiAccountURL__c) {
        this.companyId += 'W=' + this.card.web_url1__c + ',' + this.card.web_url2__c;
      }
      if (String.isNotBlank(this.setting.RenkeiSpecificItems__c)) {
        this.companyId += 'E=' + this.card.memo__c;
      }
    }
    // この名刺の個人の識別用文字列 同時に処理される同内容の名刺を識別するよう
    private void buildPersonId() {
      if (String.isNotBlank(this.card.person_name_last__c)) {
        this.personId = this.card.person_name_last__c;
      }
      else if (String.isNotBlank(this.card.last_name__c)) {
        this.personId = this.card.last_name__c;
      }

      if (this.setting.RenkeiContactFirstName__c) {
        if (String.isNotBlank(this.card.person_name_first__c)) {
          this.personId += 'F=' + this.card.person_name_first__c;
        }
        else if (String.isNotBlank(this.card.first_name__c)) {
          this.personId += 'F=' + this.card.first_name__c;
        }
      }
      if (this.setting.RenkeiContactMail__c) {
        this.personId += 'M=' + this.card.email__c;
      }
    }

  }  // class CardHolder

  ////////////////////////////////////////
  // 名刺と関連するアカウント、コンタクト レコードに関する情報を保持し、アカウント、コンタクト レコードを更新、作成する用のクラス
  //  取引先登録 = UI で 操作するとき用
  ////////////////////////////////////////
  global with sharing virtual class RegistCardHolder extends CardHolder {
    public Integer num { get; protected set; } // リストにしたときの順番 = リクエストの順番
    protected Id acntId;    //
    protected Id contId;    //
    protected Id parentId;  // 親アカウント 指定で子アカウントを作るとき  2019.07.xx SV_DEV-437 名刺から子取引先の作成
    protected Id targetOwnerId; // 2017.12.xx ToDo の任命先用 作成・更新するレコードの所有者、更新の場合は コンタクトあるいはリードの所有者 年のため、NULLなら 名刺の所有者 //
    private Boolean createTodo;     //  名刺交換ToDOを作る？
    private Date todoDate;          // 名刺交換ToDO の日付の指定
    public Account acnt { get; protected set; }            // この名刺に紐付けるアカウント  新規 OR 更新 OR ヒモ付のみ
    public Contact cont { get; protected set; }            // この名刺に紐付けるコンタクト  新規 OR 更新 OR ヒモ付のみ
    public Task todo { get; private set; }
    public Boolean createChildAccount { get; private set; } //  2019.07.xx SV_DEV-437 名刺から子取引先の作成

    //public Boolean isAccountUpsert() { return acnt != null;}    // アカウントの新規作成または 上書き（更新）をする。
    //public Boolean isContactUpsert() { return cont != null;}    // コンタクトの新規作成または 上書き（更新）をする。
    public Id getAccountId() { return acntId !=null ? acntId : (acnt !=null ? acnt.Id : null); }
    public Id getContactId() { return contId !=null ? contId : (cont !=null ? cont.Id : null); }

    public RegistCardHolder(NameCard__c card) {
      super(card);
      this.acnt = null;
      this.cont = null;
      this.createTodo = false;
      this.createChildAccount = false;
    }

    // リストにしたときの順番 = リクエストの順番 のセット
    public void setNumber(Integer n) {
      this.num = n;
    }

    //  名刺交換ToDOを作る？
    public void setCreateTodo(Boolean b) {
      this.createTodo = b;
    }

    //  名刺交換ToDOを作る？
    public Boolean getCreateTodo() {
      return this.createTodo;
    }

    // 名刺交換ToDO の日付の指定
    public void setTodoDate(Date d) {
      this.todoDate = d;
    }

    // TODO 任命先
    // 2017.04.25 NULLの場合、UserInfo.getUserId();からthis.card.OwnerIdへ変更
    // 2017.12.xx 作成・更新した コンタクトのオーナに変更. SV_DEV-715 「取引先・取引先責任者に登録」の更新時のTodoの任命先は取引先責任者の所有者にする
    // 2019.07.xx v2.4 SV_DEV-1644 取引先・取引先責任者に登録(更新時)のToDo任命先を名刺の所有者にする
    private Boolean isTodoOwnerCardOwner() {
      return this.setting.RegistToDoOwner__c == 'NameCardOwner';
    }
    private Id getDefaultTodoOwnerId() {
      if (isTodoOwnerCardOwner()) {
        return this.card.OwnerId;
      }
      return this.targetOwnerId != null ? this.targetOwnerId : this.card.OwnerId;
    }

    public Task createTodoPrototype(Id ownerId) {
      System.debug(this.cont);
      this.todo = new Task();
      this.todo.WhatId = getAccountId();  // 関連先は 取引先
      this.todo.WhoId = getContactId();   // 名前は 取引先責任者
      this.todo.ActivityDate = todoDate != null ? todoDate : this.card.card_exchange_date__c;     //  日付 は指定された日付か 名刺交換日
      this.todo.OwnerId = ownerId != null ? ownerId : getDefaultTodoOwnerId();    // v2.4 任命先は設定による
      return todo;
    }

    public override SObject getSObject(SObjectType otype) {
      if (otype == Account.sObjectType) {
        return acnt;
      }
      else if (otype == Contact.sObjectType) {
        return cont;
      }
      return null;
    }

    public Boolean isNewAccount() {
      return this.acntId == null || this.createChildAccount;
    }

    public Boolean isExistAccount() {
      return this.acntId != null && !this.createChildAccount;
    }

    // 既存のアカウント IDをセットする。
    public void setAccountId(Id acntId) {
      this.acntId = acntId;
    }

    // 既存のアカウント をセットする。
    public void setAccount(Account acnt) {
      this.acnt = acnt;
    }

    // SV_DEV-437 名刺から子取引先の作成
    public void setParentAccountId(Id parentId) {
      this.parentId = parentId;
    }
    
    //public void addAccountTarget(AccountTarget target) {
    //  targets.add(target);
    //}

    //// 一致する既存のアカウントが複数ある
    //public Boolean isAccountTooMuch() {
    //  return targets.size() > 1;
    //}

    //// 一致する既存のアカウントが1つだけある。
    //public Boolean isAccountExistOne() {
    //  return targets.size() == 1;
    //}

    public virtual Id getTargetAccountId() {
      //System.assert(targets.size() == 1);
      return this.acntId;
    }

    // 一致する既存のアカウントがない
    public virtual Boolean isAccountNotExist() {
      return this.acntId == null;
    }

    // 既存のアカウントを更新用に作成
    public virtual Account buildUpdAccount() {
      //bindExistAccount();
      SB_NameCard_RenkeiMapper mapper = SB_NameCard_RenkeiMapper.getInstance('Account', true);
      this.acnt = (Account)mapper.updateRecord(this.card, this.acntId);
      return this.acnt;
    }

    // 新規にアカウントを作成
    public Account buildNewAccount(Id rectypeId, Id ownerId) {
      System.assert(this.acnt==null);
      SB_NameCard_RenkeiMapper mapper = SB_NameCard_RenkeiMapper.getInstance('Account', true);      
      this.acnt = (Account)mapper.createRecord(this.card, rectypeId);
      System.debug('buildNewAccount: ' + this.card);
      if (ownerId != null) {
        // 所有者を指定されていたら変更 SV_DEV-549 自動連係 所有者に関するマッピングが機能していない
        this.acnt.OwnerId = ownerId;
      }
      //  2019.07.xx SV_DEV-437 名刺から子取引先の作成
      if (this.parentId != null) {
        this.acnt.ParentId = this.parentId;   // 親アカウントを指定
      }
      return this.acnt;
    }
    //// 既存のアカウントを採用したとき呼ぶ
    //public virtual void bindExistAccount() {
    //  System.assert(this.acnt==null);
    //  this.acntId = this.acnt.Id;
    //}

    // 新規作成中の アカウントをセット  同一トランザクションに同じ名刺（会社）が他にあったときはこれ
    public void putAccount(Account acnt) {
      //System.assert(this.acnt==null);
      this.acnt = acnt;
      this.acntId = acnt.Id;    // NULLかも
    }

    public Boolean isNewContact() {
      return this.contId == null;
    }

    public Boolean isExistContact() {
      return this.contId != null;
    }


    //// 一致する既存のコンタクトが複数ある
    //public Boolean isContactTooMuch() {
    //  return targets.size() > 1 || (targets.size() == 1  && targets[0].childIds.size() > 1);
    //}

    //// 一致する既存のコンタクトが1つだけある。
    //public Boolean isContactExistOne() {
    //  return targets.size() == 1 && targets[0].childIds.size() == 1;
    //}

    // 既存のコンタクト IDをセットする
    public void setContactId(Id contId) {
      this.contId = contId;
    }

    // 既存のコンタクト をセットする。
    public void setContact(Contact cont) {
      System.debug(cont);
      this.cont = cont;
      this.targetOwnerId = cont.OwnerId;    // 2017.12.xx コンタクトの所有者ID をとっておく 更新のときのToDo所有者用
      System.debug(this.cont);
    }

    public virtual Id getTargetContactId() {
      return this.contId;
    }

    //// アカウントはある（作った OR 既存）けど、一致する既存のコンタクトがない
    //public Boolean isContactNotExistWithAccount() {
    //  //return (targets.isEmpty() && this.acnt !=null) || (targets.size() == 1 && targets[0].childIds.isEmpty());
    //  return this.acntId != null && this.contId != null;
    //}

    // 既存のコンタクトを更新用に作成
    public virtual Contact buildUpdContact() {
      //bindExistContact();
      SB_NameCard_RenkeiMapper mapper = SB_NameCard_RenkeiMapper.getInstance('Contact', true);
      this.cont = (Contact)mapper.updateRecord(this.card, this.contId);
      //this.cont.AccountId = this.acntId;
      this.cont.AccountId = this.acnt != null && this.acnt.Id != null ? this.acnt.Id : this.acntId;  // 新規作成したアカウントの場合か、既存のアカウントの場合か
      return this.cont;
    }

    public Contact buildNewContact(Id rectypeId, Id ownerId) {
      System.assert(this.cont==null);
      SB_NameCard_RenkeiMapper mapper = SB_NameCard_RenkeiMapper.getInstance('Contact', true);
      this.cont = (Contact)mapper.createRecord(this.card, rectypeId);
      this.cont.AccountId = this.acnt != null && this.acnt.Id != null ? this.acnt.Id : this.acntId;  // 新規作成したアカウントの場合か、既存のアカウントの場合か
      if (ownerId != null) {
        // 所有者を指定されていたら変更 SV_DEV-549 自動連係 所有者に関するマッピングが機能していない
        this.cont.OwnerId = ownerId;
      }
      // コンタクトの所有者ID をとっておく 新規のときのToDo所有者用
      this.targetOwnerId = this.cont.OwnerId;
      return this.cont;
    }

    //// 既存のコンタクトを採用したとき呼ぶ
    //public virtual void bindExistContact() {
    //  System.assert(this.cont==null);
    //  //System.assert(!targets[0].childIds.isEmpty());
    //  this.contId = this.cont.Id;
    //}

    // 既存のコンタクトか 新規作成中の コンタクトをセット  同一トランザクションに同じ名刺が他にあったときはこれ
    public void putContact(Contact cont) {
      //System.assert(this.cont==null);
      this.cont = cont;
      this.contId = cont.Id;    // 新規ならNULL
      if (cont.Id == null) {
        this.targetOwnerId = this.cont.OwnerId;  // 別の名刺で作成したコンタクトの所有者ID をとっておく  v2.4 SV_DEV-2045 LEX 取引先登録 一括：同一の名刺レコードを複数新規作成した場合にToDo任命先が名刺の所有者になる場合がある
      }
    }

  }  // class RegistCardHolder

  global static final String MSG_SEPARATOR = ' ; ';

  ////////////////////////////////////////
  // 名刺と関連するアカウント、コンタクト レコードに関する情報を保持し、アカウント、コンタクト レコードを更新、作成する用のクラス
  //  トリガ用 = 自動連携用
  ////////////////////////////////////////
  global with sharing class AccountCardHolder extends RegistCardHolder implements Comparable {

    // この名刺に検索条件を満たすアカウント、コンタクトの情報
    @TestVisible private List<AccountTarget> targets;
    public List<AccountTarget> getAccountTargets() { return targets; }
    public String renkeiMessage { get; private set; }
    public SB_NameCard_RegistProcessor.Process acntProcess;
    public SB_NameCard_RegistProcessor.Process contProcess;
    public Boolean isSuccess() { return this.messages != null && this.messages.isEmpty(); }   // 連携成功
    public Boolean isOldAccount { get; private set; }
    public Boolean isOldContact { get; private set; }
    public AccountCardHolder(NameCard__c card) {
      super(card);
      this.targets = new List<AccountTarget>();
      this.acnt = null;
      this.cont = null;
      this.messages = new List<String>();
      this.useTarget = null;
      this.isOldAccount = false;
      this.isOldContact = false;
    }
    //public Boolean useExist;
    private AccountTarget useTarget;
    public Boolean useExistAccount() { return useTarget != null; }

    // 2018.02.xx v1.22 SV_DEV-585 自動連携で既存取引先責任者が一意に特定できるなら取引先があいまいでも重複エラーにしない
    //  → 最初に 既存を調べて 採用する アカウント、コンタクトを決めておく
    public void preProcess(Boolean withCotact) {
      if (targets.isEmpty()) {
        return;
      }
      if (this.targets.size() == 1) {
        // 既存取引先が１つだけのとき
        this.useTarget = targets.get(0);
      }
      else {
        // 既存取引先が複数あったとき
        Integer index = -1;  // 採用するアカウントのインデックス
        // SV_DEV-1638 自動連携の取引先検索で取引先名完全一致の取引先があればあいまい検索一致の取引先があっても重複にしないようにする
        SB_NameCard_HojinkakuParser cardKaisha = new SB_NameCard_HojinkakuParser(this.card.company_name__c);
        // SB_NameCard_HojinkakuParser のチェックは 完全一致条件のときはいみないけど、その場合も同様に処理する。
        for (Integer n=0; n < this.targets.size(); n++) {
          AccountTarget t = targets.get(n);
          if (cardKaisha.isEqual(t.name)) {
            // 法人格含めて一致
            index = index == -1 ? n : -1;
            if (index == -1) {
              break;      // 2つめがあった
            }
          }
        }
        if (index == -1 && withCotact == true) {
          for (Integer n=0; n < this.targets.size(); n++) {
            AccountTarget t = targets.get(n);
            if (t.getChildCount() > 0) {
              // コンタクトが1つ以上ある。
              index = index == -1 ? n : -1;
              if (index == -1) {
                break;      // 2つめがあった
              }
            }
          }
        }
        if (index != -1) {
          this.useTarget = targets.get(index);
        }
      }
      if (this.useTarget !=null) {
        this.acntId = this.useTarget.targetId;
        this.contId = this.useTarget.getChildCount() == 1 ? this.useTarget.childIds[0] : null;
        
        // PRODUCT-26 取引先・取引先責任者を上書きするか判断
        compareExchangeDate(); 
      }
    }

    // PRODUCT-26 取引先・取引先責任者を上書きするか判断
    private void compareExchangeDate(){
      if(this.useTarget.account.NameCard__c != null) {
        if (this.card.card_exchange_date__c == null) {
          this.isOldAccount = false;
        } else {
          if (this.useTarget.account.NameCard__r.card_exchange_date__c == null) {
            this.isOldAccount = true;
          } else {
            this.isOldAccount = this.card.card_exchange_date__c >= this.useTarget.account.NameCard__r.card_exchange_date__c;
          }
        }
      } else {
        this.isOldAccount = true;
      }
      if (this.contId != null) {
        if (this.useTarget.childMap.get(this.contId).NameCard__c != null) {
          if (this.card.card_exchange_date__c == null) {
            this.isOldContact = false;
          } else {
            if (this.useTarget.childMap.get(this.contId).NameCard__r.card_exchange_date__c == null) {
              this.isOldContact = true;
            } else {
              this.isOldContact = this.card.card_exchange_date__c >= this.useTarget.childMap.get(this.contId).NameCard__r.card_exchange_date__c;
            }
          }
        } else {
          this.isOldContact = true;
        }
      } 
    }

    // 連携処理情報を保存するよう
    private List<String> messages;
    // 連携処理情報を追加する。 2017.04.xx
    public override void putMessage(String msg) {
      this.messages.add(msg);
    }
    // 連携処理情報を書き出す
    public override void modifySomeCardFields(NameCard__c nc) {
      String msg = this.messages.isEmpty() ?  'OK' : String.join(this.messages, ' ');
      // 前に 付け足す
      nc.RenkeiMessage__c = String.isNotBlank(this.card.RenkeiMessage__c) ? msg + MSG_SEPARATOR + this.card.RenkeiMessage__c : msg;
      // 文字列が長くなってるかもしれないので切り詰める 。 画面上では切り詰められない。多分 Triggrt でも
      Schema.DescribeFieldResult dfr = NameCard__c.RenkeiMessage__c.getDescribe();
      nc.RenkeiMessage__c = nc.RenkeiMessage__c.left(dfr.getLength());
      // v1.19 ではRenkeiMessage__c がないので、SmartViscaT05　では 項目にはいれず、このクラスのプロパティで保持 → 画面の結果表示にはこれを使う
      this.renkeiMessage = msg;
    }

    public void addAccountTarget(AccountTarget target) {
      targets.add(target);
    }

    // 一致する既存のアカウントが複数ある
    public Boolean isAccountTooMuch() {
      return targets.size() > 1;
    }

    // 一致する既存のアカウントが1つだけある。
    public Boolean isAccountExistOne() {
      return targets.size() == 1;
    }

    // 1つだけコンタクトを持つアカウントが1つだけある ？
    public Boolean have1AccountWith1Contact() {
      Integer withOneContact = 0;
      for (AccountTarget t : this.targets) {
        if (t.getChildCount() == 1) {
          withOneContact++;
        }
      }
      return (withOneContact == 1);
    }

    public override Id getTargetAccountId() {
      System.assert(useTarget != null); // 2018.02.xx v 1.22  決めた1つがある。
      return this.acntId;
    }

    //// 一致する既存のアカウントがない
    //public Boolean isAccountNotExist() {
    //  return targets.isEmpty();
    //}

    // 既存のアカウントを更新用に作成
    public override Account buildUpdAccount() {
      //bindExistAccount();
      SB_NameCard_RenkeiMapper mapper = SB_NameCard_RenkeiMapper.getInstance('Account', true);
      this.acnt = (Account)mapper.updateRecord(this.card, this.acntId);
      return this.acnt;
    }

    //// 新規にアカウントを作成
    //public Account buildNewAccount(Id rectypeId) {
    //  System.assert(this.acnt==null);
    //  SB_NameCard_RenkeiMapper mapper = SB_NameCard_RenkeiMapper.getInstance('Account', true);
    //  this.acnt = (Account)mapper.createRecord(card, rectypeId);
    //  return this.acnt;
    //}
    //// 既存のアカウントを採用したとき呼ぶ
    //public void bindExistAccount() {
    //  System.assert(this.acnt == null && this.useTarget !=null);
    //  this.acntId = this.useTarget.targetId;
    //}

    // 既存のアカウントか 新規作成中の アカウントをセット  同一トランザクションに同じ名刺（会社）が他にあったときはこれ
    //public void putAccount(Account acnt) {
    //  System.assert(this.acnt==null);
    //  this.acnt = acnt;
    //  this.acntId = acnt.Id;    // NULLかも
    //  this.putMessage(String.format('[Account {0}: another]', new String[] { acnt.Id == null ? 'create' : 'update' })); // 2017.04.xx
    //}

    // 一致する既存のコンタクトが複数ある
    public Boolean isContactTooMuch() {
      return useTarget != null && useTarget.childIds.size() > 1;
    }

    //// 一致する既存のコンタクトが1つだけある。
    //public Boolean isContactExistOne() {
    //  return targets.size() == 1 && targets[0].childIds.size() == 1;
    //}
    public Boolean useExistContact() {
      return useTarget != null && useTarget.childIds.size() == 1;
    }

    public override Id getTargetContactId() {
      //System.assert(this.useTarget != null);
      //System.assert(!this.useTarget.childIds.isEmpty());
      //return this.useTarget.childIds[0];
      return this.contId;
    }

    // アカウントはある（作った OR 既存）けど、一致する既存のコンタクトがない
    public Boolean isContactNotExistWithAccount() {
      //return (targets.isEmpty() && this.acnt !=null) || (targets.size() == 1 && targets[0].childIds.isEmpty());
      return (targets.isEmpty() && this.acnt !=null) || (useTarget != null && useTarget.childIds.isEmpty());
    }

    // 既存のコンタクトを更新用に作成
    public override Contact buildUpdContact() {
      //bindExistContact();
      SB_NameCard_RenkeiMapper mapper = SB_NameCard_RenkeiMapper.getInstance('Contact', true);
      this.cont = (Contact)mapper.updateRecord(this.card, this.contId);
      this.cont.AccountId = this.acntId;
      return this.cont;
    }

    //public Contact buildNewContact(Id rectypeId) {
    //  System.assert(this.cont==null);
    //  SB_NameCard_RenkeiMapper mapper = SB_NameCard_RenkeiMapper.getInstance('Contact', true);
    //  this.cont = (Contact)mapper.createRecord(card, rectypeId);
    //  this.cont.AccountId = this.acnt != null && this.acnt.Id != null ? this.acnt.Id : this.acntId;  // 新規作成したアカウントの場合か、既存のアカウントの場合か
    //  return this.cont;
    //}

    //// 既存のコンタクトを採用したとき呼ぶ
    //public void bindExistContact() {
    //  System.assert(this.cont==null);
    //  System.assert(!targets[0].childIds.isEmpty());
    //  this.contId = targets[0].childIds[0];
    //}

    //// 既存のコンタクトか 新規作成中の コンタクトをセット  同一トランザクションに同じ名刺が他にあったときはこれ
    //public void putContact(Contact cont) {
    //  System.assert(this.cont==null);
    //  this.cont = cont;
    //  this.contId = cont.Id;    // NULLかも
    //  this.putMessage(String.format('[Contact {0}: another]', new String[] { cont.Id == null ? 'create' : 'update' }));   // 2017.04.xx
    //}

    // PRODUCT-26 名刺のソート:ORDER BY card_exchange_date__c DESC NULLSLAST, Saishin__c DESC
    public Integer compareTo(Object compareTo) {
      SB_NameCard_RegistCardHolder.AccountCardHolder cardHolder = (SB_NameCard_RegistCardHolder.AccountCardHolder)compareTo;
      if (this.card.card_exchange_date__c == cardHolder.card.card_exchange_date__c) {
        if (this.card.Saishin__c && !cardHolder.card.Saishin__c){
          return -1;
        } else if(!this.card.Saishin__c && cardHolder.card.Saishin__c){
          return 1;
        } else {
          return 0;
        }
      }
      if (this.card.card_exchange_date__c != null && cardHolder.card.card_exchange_date__c == null ) {
        return -1;
      }
      if (this.card.card_exchange_date__c == null && cardHolder.card.card_exchange_date__c != null ) {
        return 1;
      }
      if (this.card.card_exchange_date__c > cardHolder.card.card_exchange_date__c) {
        return -1;
      } else {
        return 1;
      }
    }
  }  // class AccountCardHolder

}