/*
 * (c) 2016 Sunbridge Inc.
 *
 * リードに登録this.isAllowDuplicateSave;
 *
 * @Version 1 2018/01/XX  SV_DEV-753 リードに登録（個別画面）でキャンペーン選択後の「キャンペーンメンバー状況」の値がデフォルト値にならない。
 *                        SV_DEV-747 リード拡張パッケージのカスタム設定：リードに登録 リードレコードタイプ表示の初期値がOFF
 *                        SV_DEV-727 リードへ登録、名刺所有者がキューおよリード所有者がキューの場合
 *                        SV_DEV-751 リードに登録で追加された、キャンペーンメンバーの種別が「取引先責任者」になる。
 *                        SV_DEV-750 既存リードの更新時にもキャンペーンの選択が反映される。
 *                        SV_DEV-762 名刺オブジェクトの編集権限がない場合にリードに登録の処理が終了しない。
 *                        SV_DEV-542 重複エラーが出たときのラジオボタン選択について
 *                        SV_DEV-760 既存リードを更新した場合に名刺のキャンペーン項目が更新される。
 *                        SV_DEV-565 リード登録のリード所有者の修正
 */

public with sharing class SB_NameCardL_TwowayRegistController {
  public class LeadRegistControllerException extends exception {}

  public Boolean showLead { get{
    if (showLead == null) {
      return  true;
    } else {
      return showLead;
    }
  } set; }


  private static final String createAccountLabel;
  private static final String createContactLabel;
  private static final String createLeadLabel;
  static {
    createAccountLabel = String.format(System.Label.SB_NCLD_Label_CreateNewLeadDEV, new String[]{ Account.sObjectType.getDescribe().getLabel() });
    createContactLabel = String.format(System.Label.SB_NCLD_Label_CreateNewLeadDEV, new String[]{ Contact.sObjectType.getDescribe().getLabel() });
    createLeadLabel = String.format(System.Label.SB_NCLD_Label_CreateNewLeadDEV, new String[]{ Lead.sObjectType.getDescribe().getLabel() });
  }

  @TestVisible
  private static SB_NameCardL_RegistCanPickerAbstract searchMethod = new SB_NameCardL_RegistSoqlCountCanPicker();

  public Integer searchField { get; set; }  // 検索条件の項目
  public Integer queryMatch { get; set; }   // 完全一致もする？
  @TestVisible private static final Integer SEARCHTYPE_DEFAULT = 0;    // 検索方法のデフォルト値
  @TestVisible private static final Integer FIELD_NAMESITE = 0;  // 検索条件の項目
  @TestVisible private static final Integer FIELD_NAME = 1;
  @TestVisible private static final Integer QUERY_PERFECT_NO = 0;  //
  @TestVisible private static final Integer QUERY_PERFECT = 1;   // 完全一致もする

  public String selectedSearchMethod { get; private set;}

  private static final String NAMECARD_QUERY = 'SELECT Id, Name, OwnerId, Owner.Name, LastModifiedDate, SmartViscaf__division__c,'
    + ' SmartViscaf__zip_code__c, SmartViscaf__address_pref__c, SmartViscaf__address__c,'
    + ' SmartViscaf__address_bld__c, SmartViscaf__address_eng__c,'
    + ' SmartViscaf__company_name__c, SmartViscaf__web_url1__c, SmartViscaf__tel1__c, SmartViscaf__fax1__c, SmartViscaf__title_name__c,'
    + ' SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c, SmartViscaf__last_name__c, SmartViscaf__first_name__c,'
    + ' SmartViscaf__email__c, SmartViscaf__mobile__c, SmartViscaf__lead__c,'
    + ' SmartViscaf__list_name__c, SmartViscaf__memo__c, SmartViscaf__freehandmemo__c, SmartViscaf__card_exchange_date__c,'
    + ' SmartViscaf__account__c, SmartViscaf__contact__c'
    + ' FROM SmartViscaf__NameCard__c'
    + ' WHERE {0}';

      // 登録先の候補のタイプ
  public enum CandidateType { NO_REGIST, // なし
              UPDATE_ACCOUNT,   // 既存取引先 + 新規取引先責任者
              UPDATE_CONTACT,   // 既存取引先 + 既存取引先責任者
              UPDATE_LEAD,      // 既存リード
              LOOKUP_ACCOUNT,   // 取引先ルックアップ + 新規取引先責任者
              LOOKUP_CONTACT,   // 取引先責任者ルックアップ + 既存取引先
              LOOKUP_LEAD,      // リードルックアップ
              CREATE_ACCOUNT,   // 新規取引先 + 新規取引先責任者
              CREATE_CONTACT,   // => UPDATE_ACCOUNT なし
              CREATE_LEAD       // 新規リード
            }

  private static final Map<CandidateType, Integer> CANDIDATETYPE_INT = new Map<CandidateType, Integer> {
      CandidateType.NO_REGIST => 0, // なし
      CandidateType.UPDATE_ACCOUNT => 1,   // 既存取引先 + 新規取引先責任者
      CandidateType.UPDATE_CONTACT => 2,   // 既存取引先 + 既存取引先責任者
      CandidateType.UPDATE_LEAD => 3,      // 既存リード
      CandidateType.LOOKUP_ACCOUNT => 4,   // 取引先ルックアップ + 新規取引先責任者
      CandidateType.LOOKUP_CONTACT => 5,   // 取引先責任者ルックアップ + 既存取引先
      CandidateType.LOOKUP_LEAD => 6,      // リードルックアップ
      CandidateType.CREATE_ACCOUNT => 7,   // 新規取引先 + 新規取引先責任者
      CandidateType.CREATE_CONTACT => 8,   // => UPDATE_ACCOUNT なし
      CandidateType.CREATE_LEAD => 9       // 新規リード
  };

  //
  // 登録先候補テーブルの基底
  //
  public abstract class CandidateRecord {
    public Integer index { get; set; }           // インデクス
    // 0: 既存取引先+既存取引先責任者 1: 既存取引先+既存取引先責任者ルックアップ 2: 既存取引先+新規取引先責任者
    // 3: 既存取引先ルックアップ+新規取引先責任者  4: 既存取引先責任者ルックアップ 5: 新規取引先+新規取引先責任者
    // 6: 、７:、8:リード新規作成
    public CandidateType type { get; private set; }
    public Integer getCandidateType() { return CANDIDATETYPE_INT.get(type); }
    public SmartViscaf__NameCard__c card4Lookup { get; set; }  // 取引先、取引先責任者、リード をルックアップルする時用
    public Boolean getLookupAccount() { return type == CandidateType.LOOKUP_ACCOUNT; }
    public Boolean getLookupContact() { return type == CandidateType.LOOKUP_CONTACT; }
    public Boolean getLookupLead() { return type == CandidateType.LOOKUP_LEAD; }
    public virtual String getOrgName() { return null; }       // 会社名 = 取引先名 or リード会社名
    public virtual String getPersonName() { return null; }      //　 個人名 =  取引先責任者名、リード名
    public virtual Id getAccountId() { return null; }      // 既存取引先ID
    public virtual Id getContactId() { return null; }      // 既存取引先責任者ID
    public virtual Id getLeadId() { return null; }      // 既存取引先責任者ID
    public virtual String getAccountOwnerName() { return null; }     // 取引先所有者
    public virtual String getContactOwnerName() { return null; }     // 取引先責任者所有者
    public virtual String getLeadOwnerName() { return null; }     // リード所有者
    public virtual String getDivision() { return null; }         // 部署
    public virtual String getState() { return null; }            // 都道府県
    public virtual String getTitle() { return null; }            // 取引先責任者役職
    public virtual String getMobile() { return null; }           // 取引先責任者携帯
    public virtual String getEmail() { return null; }            // メールアドレス
    public virtual Datetime getLastModifiedDate() { return null; } // 最終更新日
    public virtual String getAccountName() { return null; }       //取引先名
    public virtual String getContactName() { return null; }      //取引先責任者名
    public virtual String getLeadName() { return null; }      //リード名

    public virtual Id getAccountOwnerId() { return null; }     //取引先所有者Id
    public virtual Id getContactOwnerId() { return null; }     //取引先責任者所有者Id
    public virtual Id getLeadOwnerId() { return null; }     //リード所有者Id
    public virtual String getLeadCompany() { return null; }     //リード会社名
    // 実行
    // 選択されて アカウント、コンタクトを 作成、または 更新
    public abstract Boolean adopt(SmartViscaf__NameCard__c card);
    // ルックアップするタイプのとき
    public virtual void postLookup() {}
  }


    // 0: 既存取引先+既存取引先責任者
  public class ContactCandidate extends CandidateRecord {
    private Contact cont;
    public override String getAccountName() { return this.cont.Account.Name; }      //取引先名
    public override String getContactName() { return this.cont.Name; }      //取引先責任者名
    public override Id getAccountId() { return this.cont.Account.Id; }      // 既存取引先ID
    public override Id getContactId() { return cont.Id; }      //既存取引先責任者ID
    public override String getAccountOwnerName() { return this.cont.Account.Owner.Name; }     //取引先所有者
    public override String getContactOwnerName() { return this.cont.Owner.Name; }     //取引先責任者所有者
    public override Id getAccountOwnerId() { return this.cont.Account.OwnerId; }     //取引先所有者Id
    public override Id getContactOwnerId() { return this.cont.OwnerId; }     //取引先責任者所有者Id
    public override String getDivision() { return this.cont.Department; }         //部署
    public override String getState() { return this.cont.MailingState; }            // 都道府県
    public override String getTitle() { return this.cont.Title; }            //取引先責任者役職
    public override String getMobile() { return this.cont.MobilePhone; }           //取引先責任者携帯
    public override String getEmail() { return this.cont.Email; }            //メールアドレス
    public override Datetime getLastModifiedDate() { return this.cont.LastModifiedDate; } //最終更新日
    public ContactCandidate(Integer index, Contact c) {
      this.type = CandidateType.UPDATE_CONTACT;
      this.card4Lookup = null;
      this.index = index;
      this.cont = c;
    }
    // 選択されて アカウント、コンタクト を 更新
    public override Boolean adopt(SmartViscaf__NameCard__c card) {
      card.SmartViscaf__account__c = cont.Account.Id;
      card.SmartViscaf__contact__c = cont.Id;
      return true;
    }
  }

  // 1: 既存取引先+既存取引先責任者ルックアップ  2: 既存取引先+新規取引先責任者
  public class AccountCandidate extends CandidateRecord {
    private Account acnt;
    public override String getAccountName() { return this.acnt.Name; }      //取引先名
    public override String getContactName() { return SB_NameCardL_TwowayRegistController.createContactLabel; }      //取引先責任者名
    public override Id getAccountId() { return acnt.Id; }      //既存取引先ID
    public override String getAccountOwnerName() { return this.acnt.Owner.Name; }     //取引先所有者
    public override String getDivision() { return this.acnt.Site; }         //部署
    public override String getState() { return this.acnt.BillingState; }            // 都道府県
    public override Datetime getLastModifiedDate() { return this.acnt.LastModifiedDate; } //最終更新日
    public override Id getAccountOwnerId() { return this.acnt.OwnerId; }     //取引先所有者Id

    public AccountCandidate(Integer index, Account acnt) {
      this.type = CandidateType.UPDATE_CONTACT;
      this.card4Lookup = null;
      this.index = index;
      this.acnt = acnt;
    }
    //public AccountCandidate(Integer index, Account acnt, Boolean lookUpContact) {
    //  this.candidateType = lookUpContact ? 1 : 2;
    //  this.card4Lookup = lookUpContact ? new SmartViscaf__NameCard__c(SmartViscaf__account__c=acnt.Id) : null;
    //  this.index = index;
    //  this.acnt = acnt;
    //}
    // 選択されて アカウント、コンタクトを 作成、または 更新
    public override Boolean adopt(SmartViscaf__NameCard__c card) {
      Contact cont = new Contact(AccountId=acnt.Id);
      card.SmartViscaf__account__c = cont.Account.Id;
      card.SmartViscaf__contact__c = cont.Id;
      return true;
    }
  }

  // 3: 既存取引先ルックアップ + 新規取引先責任者
  public class AccountLookupCandidate extends CandidateRecord {
    private Account acnt;
    public override String getDivision() { return this.acnt == null ? null : this.acnt.Site; }         //部署
    public override String getState() { return this.acnt == null ? null : this.acnt.BillingState; }            // 都道府県
    public override String getContactName() { return SB_NameCardL_TwowayRegistController.createContactLabel; }      //取引先責任者名
    public override Id getAccountOwnerId() { return this.acnt.OwnerId; }     //取引先所有者Id

    public AccountLookupCandidate(Integer index) {
      this.type = CandidateType.LOOKUP_ACCOUNT;
      this.card4Lookup = new SmartViscaf__NameCard__c();
      this.index = index;
    }
    // 選択されて アカウント、コンタクトを 作成、または 更新
    public override Boolean adopt(SmartViscaf__NameCard__c card) {
      Map<String, String> names = SmartViscaf.SB_NameCard_Util.getPersonName(card);
      Contact cont = new Contact(AccountId=this.card4Lookup.SmartViscaf__account__c, FirstName=names.get('first_name'), LastName=names.get('last_name') );
      card.SmartViscaf__account__c = cont.Account.Id;
      card.SmartViscaf__contact__c = cont.Id;
      return true;
    }
    public override void postLookup() {
      List<Account> acnts = [SELECT Id, Name, OwnerId, Owner.Name, BillingState, Site FROM Account WHERE Id = :card4Lookup.SmartViscaf__account__c];
      System.assert(!acnts.isEmpty());
      this.acnt = acnts[0];
    }
  }

  // 4: 既存取引先責任者ルックアップ
  public class ContactLookupCandidate extends CandidateRecord {
    private Contact cont;
    public override String getAccountName() { return this.cont != null ? cont.Account.Name : null; }      //取引先名
    public override String getAccountOwnerName() { return this.cont != null ? cont.Account.Owner.Name : null; }      //取引先所有者
    //public override String getContactName() { return SB_SvTool06_AccountRegistController.createContactLabel; }      //取引先責任者名
    public override Datetime getLastModifiedDate() { return this.cont != null ? this.cont.LastModifiedDate : null; } //最終更新日
    public override Id getAccountOwnerId() { return this.cont.Account.OwnerId; }     //取引先所有者Id
    public override Id getContactOwnerId() { return this.cont.OwnerId; }     //取引先責任者所有者Id

    public ContactLookupCandidate(Integer index) {
      this.type = CandidateType.LOOKUP_CONTACT;
      this.card4Lookup = new SmartViscaf__NameCard__c();
      this.index = index;
    }
    // 選択されて アカウント、コンタクトを 作成、または 更新
    public override Boolean adopt(SmartViscaf__NameCard__c card) {
      card.SmartViscaf__account__c = cont.Account.Id;
      card.SmartViscaf__contact__c = cont.Id;
      return true;
    }
    public override void postLookup() {
      List<Contact> conts = [SELECT Id, Name, OwnerId, Account.OwnerId, Account.Name, Account.Owner.Name, MailingState, Department, MobilePhone, Email,
                                    LastModifiedDate
                               FROM Contact
                              WHERE Id = :card4Lookup.SmartViscaf__contact__c];
      System.assert(!conts.isEmpty());
      this.cont = conts[0];
    }
  }

  // 5: 新規取引先+新規取引先責任者
  public class NewAccountCandidate extends CandidateRecord {
    public override String getAccountName() { return SB_NameCardL_TwowayRegistController.createAccountLabel; }      //取引先名
    public override String getContactName() { return SB_NameCardL_TwowayRegistController.createContactLabel; }      //取引先責任者名
    public NewAccountCandidate(Integer index) {
      this.type = candidateType.CREATE_ACCOUNT;
      this.index = index;
    }
    // 選択されて アカウント、コンタクトを 作成、または 更新
    public override Boolean adopt(SmartViscaf__NameCard__c card) {
      Account acnt = new Account(Name=card.SmartViscaf__company_name__c, Site=card.SmartViscaf__division__c);
      insert acnt;
      Map<String, String> names = SmartViscaf.SB_NameCard_Util.getPersonName(card);
      Contact cont = new Contact(AccountId=acnt.Id, FirstName=names.get('first_name'), LastName=names.get('last_name'));
      insert cont;
      card.SmartViscaf__account__c = cont.AccountId;
      card.SmartViscaf__contact__c = cont.Id;
      return true;
    }
  }

  // 6: 既存リード
  public class LeadCandidate extends CandidateRecord {
    private Lead le;
    public override String getLeadName() { return this.le.Name; }      //リード
    public override Id getLeadId() { return this.le.Id; }      // 既存取リードID
    public override String getLeadOwnerName() { return this.le.Owner.Name; }     //リード所有者
    public override String getTitle() { return this.le.Title; }            //リード役職
    public override String getMobile() { return this.le.MobilePhone; }           //取引先責任者携帯
    public override String getEmail() { return this.le.Email; }            //メールアドレス
    public override Datetime getLastModifiedDate() { return this.le.LastModifiedDate; } //最終更新日
    public override String getLeadCompany() { return this.le.Company; } //会社名
    public override Id getLeadOwnerId() { return this.le.OwnerId; }     //リード所有者Id
    public override String getState() { return this.le.State; }            // 都道府県

    public LeadCandidate(Integer index, Lead l) {
      this.type = CandidateType.UPDATE_LEAD;
      this.card4Lookup = null;
      this.index = index;
      this.le = l;
    }
    // 選択されて アカウント、コンタクト を 更新
    public override Boolean adopt(SmartViscaf__NameCard__c card) {
      card.SmartViscaf__lead__c = le.Id;
      return true;
    }
  }

  // 7: リードルックアップ
  public class LeadLookupCandidate extends CandidateRecord {
    private Lead le;
    public override String getLeadName() { return this.le == null ? null : this.le.Name; }      //リード
    public override Id getLeadId() { return this.le == null ? null : this.le.Id; }      // 既存取リードID
    public override String getLeadOwnerName() { return this.le == null ? null : this.le.Owner.Name; }     //リード所有者
    public override String getTitle() { return this.le == null ? null: this.le.Title; }            //リード役職
    public override String getMobile() { return this.le == null ? null: this.le.MobilePhone; }           //取引先責任者携帯
    public override String getEmail() { return this.le == null ? null : this.le.Email; }            //メールアドレス
    public override Datetime getLastModifiedDate() { return this.le.LastModifiedDate; } //最終更新日
    public override String getLeadCompany() { return this.le == null ? null : this.le.Company; } //会社名
    public override Id getLeadOwnerId() { return this.le.OwnerId; }     //リード所有者Id

    public LeadLookupCandidate(Integer index) {
      this.type = CandidateType.LOOKUP_LEAD;
      this.card4Lookup = new SmartViscaf__NameCard__c();
      this.index = index;
    }
    // 選択されて アカウント、コンタクト を 更新
    public override Boolean adopt(SmartViscaf__NameCard__c card) {
      card.SmartViscaf__lead__c = le.Id;
      return true;
    }

    public override void postLookup() {
      List<Lead> les = [SELECT Id, Company, State, Title, Name, Email, LastModifiedDate, OwnerId, Owner.Name, MobilePhone FROM Lead WHERE Id = :card4Lookup.SmartViscaf__lead__c];
      System.assert(!les.isEmpty());
      this.le = les[0];
    }
  }

   // 8: 新規リード
  public class NewLeadCandidate extends CandidateRecord {
    public override String getAccountName() { return SB_NameCardL_TwowayRegistController.createAccountLabel; }      //取引先名
    public override String getContactName() { return SB_NameCardL_TwowayRegistController.createContactLabel; }      //取引先責任者名
    public override String getLeadName() { return SB_NameCardL_TwowayRegistController.createLeadLabel; }      //取引先責任者名
    public NewLeadCandidate(Integer index) {
      this.type = CandidateType.CREATE_LEAD;
      this.index = index;
    }
    // 選択されて アカウント、コンタクトを 作成、または 更新
    public override Boolean adopt(SmartViscaf__NameCard__c card) {
      Map<String, String> names = SmartViscaf.SB_NameCard_Util.getPersonName(card);
      Lead le = new Lead(FirstName=names.get('first_name'), LastName=names.get('last_name'));
      // insert le;
      card.SmartViscaf__lead__c = le.Id;
      return true;
    }
  }

  // public class LeadRecord {
  //   public Integer index { get; set; }
  //   public Lead pageLead { get; set; }
  //   public SmartViscaf__NameCard__c lookUpNameCard { get; set; }
  //   public Boolean isNew { get; set; }

  //   public LeadRecord(Integer index, Lead lead) {
  //     this.index = index;
  //     this.pageLead = lead;
  //     this.isNew = false;
  //   }

  //   public LeadRecord(Integer index, Boolean isLookup){
  //     this.index = index;
  //     if (isLookUp) {
  //       this.lookUpNameCard = new SmartViscaf__NameCard__c();
  //       this.isNew = false;
  //     } else {
  //       this.isNew = true;
  //     }
  //   }
  // }


  //
  private class ScreenData {
    public Boolean dispAccountOwner { get; private set; } //取引先所有者表示
    public Boolean dispContactOwner { get; private set; } //取引先責任者所有者表示
    public Boolean dispState { get; private set; }//都道府県表示
    public Boolean dispTitle { get; private set; }//役職表示
    public Boolean dispMail { get; private set; }//メールアドレス表示
    public Boolean dispLastModifiedDate { get; private set; }//最終更新日表示
    public Boolean dispMobile { get; private set; }//携帯電話表示
    public String  accountOwnerlabel { get; private set; }//取引先(所有者)
    public String  contactOwnerlabel { get; private set; }//取引先責任者(所有者)
    public ScreenData() {
      this.dispAccountOwner = true; //取引先所有者表示
      this.dispContactOwner = true; //取引先責任者所有者表示
      this.dispState  = true;//都道府県表示
      this.dispTitle  = true;//SB_SvTool06_RegistSoqlTwiceCanCreater役職表示
      this.dispMail = true;//メールアドレス表示
      this.dispLastModifiedDate = true;//最終更新日表示
      this.dispMobile = true;//携帯電話表示
      this.accountOwnerlabel = String.format('{0} ({1})',new String[]{ Account.sObjectType.getDescribe().getLabel(), System.Label.SB_NCLD_Label_Owner});//取引先(所有者)
      this.contactOwnerlabel = String.format('{0} ({1})',new String[]{ Contact.sObjectType.getDescribe().getLabel(), System.Label.SB_NCLD_Label_Owner});//取引先責任者(所有者)
    }
  } // private class ScreenData


  private static final String LEADLABEL = Lead.sObjectType.getDescribe().getLabel();

  //テスト addMessageキャッチ用
  @TestVisible
  private String testError;

  public SmartViscaf__NameCard__c nameCard { get; set; }
  public Lead pageLead { get; set; }

  public SB_NameCard_LeadRegist.svConfig svConfig { get { return SB_NameCard_LeadRegist.svConfig; } }
  public Integer searchType { get; set; }
  public Integer leadRecordListIndex { get; set; }
  public Integer lookUpIndex { get; set; }
  public List<CandidateRecord> leadRecordList { get; set; }
  public List<CandidateRecord> candidateTable { get; private set; } // 登録先候補テーブル
  public Boolean leadOverwrite { get; set; }

  public Task todo { get; set; }
  public Boolean registTodo { get; set; }

  private Map<Integer, String> soqlMap = new Map<Integer, String>();
  private List<Id> emailIdList = new List<Id>();
  private List<String> emailList = new List<String>();
  private List<Id> nameIdList = new List<Id>();
  private Set<String> nameSet = new Set<String>();
  private Set<String> lastNameSet = new Set<String>();
  private Set<String> firstNameSet = new Set<String>();
  private Id campaign;
  public   Boolean  canEditTodo{get;set;}

  //
  public String registerToLeadLabel{get;set;}
  public String overwriteLeadInfoLabel{get;set;}
  public String createNewLeadLabel{get;set;}
  public String specifiedWhenCreateNew{get;set;}
  public Boolean leadCreateable{get;set;}
  public Boolean leadRecTypeEdit{get; private set;} //リードレコードタイプを変更できるflag
  public Boolean showLeadRecType{get;private set;} //リードレコードタイプ選択を表示フラグ
  public String leadRecType{get;set;}    //ラベルSB_NCLD_Label_LeadRecType リードレコードタイプ
  public String leadRecordTypeId{get;set;} //リードレコードタイプID

  //SV_DEV-175 リード登録時にキャンペーン内での状況を選択
  public String campStatus{get;set;} //キャンペーンStatus
  public Boolean campDisabled{get;set;} //キャンペーンStatus Disabled フラグ
  public Boolean campLookUpDisabled{get;set;} //キャンペーン Disabled フラグ
  public  List<SelectOption> campaignStatus {get; set;}
  public String renkeiType {get; set;}

  public ScreenData screenData { get; private set; }


  public String  recordTypeExplain{get; private set;}//新規作成の場合、レコードタイプを選択します。
  public String  updateForContact{get; private set;}//既存の取引先の情報を名刺情報で上書きする
  public String  updateForAccount{get; private set;}//既存の取引先責任者の情報を名刺情報で上書きする

  public Integer accountTableIndex { get; set;} // 取引先テーブルIndex
  public String  accountRecTypeId{get; set;}//選んだの取引先レコードタイプ
  public String  contactRecTypeId{get; set;}//選んだの取引先責任者レコードタイプ
  public String  accountRecType{get; private set;}//取引先レコードタイプの表示ラベル
  public String  contactRecType{get; private set;}//取引先責任者レコードタイプの表示ラベル
  public Boolean accountRecTypeEdit{get; private set;}//取引先レコードタイプ編集不可
  public Boolean contactRecTypeEdit{get; private set;}//取引先責任者レコードタイプ編集不可
  public Boolean showAccountRecType{get; private set;}//取引先レコードタイプ表示するか
  public Boolean showContactRecType{get; private set;}//取引先責任者レコードタイプ表示するか
  public Boolean showRecTypeSectionItem{get; private set;}//レコードタイプのSectionItemを表示するか
  public Boolean cannotUpdataAccount{get; private set;}//取引先更新不可フラグ
  public Boolean cannotUpdataContact{get; private set;}//取引先責任者更新不可フラグ
  public Boolean cannotUpdataLead{get; private set;}//取引先責任者更新不可フラグ
  public String  cannotUseStyleAcc{get; private set;}//取引先上書き表示ラベルCSS
  public String  cannotUseStyleCon{get; private set;}//取引先責任者上書き表示ラベルCSS
  public Boolean showUpdate{get; private set;}//基本設定上書き表示
  public Boolean showUpdateAccount{get; private set;}//基本設定 既存の取引先を名刺情報で上書きする」を表示する
  public Boolean showUpdateContact{get; private set;}//「既存の取引先責任者を名刺情報で上書きする」を表示する
  public Boolean showUpdateLead{get; private set;}//「既存のリードを名刺情報で上書きする」を表示する
  public Boolean accountOverwrite { get; set; } // 取引先を上書き
  public Boolean contactOverwrite { get; set; } // 取引責任者を上書きs
  public Boolean dispDuplicateCheck { get; set; }
  public Account pageAccount { get; set; }

  public Boolean isFirst = true;


  private SB_NameCardL_RegistQueryOption accountQueryOption;  // アカウント検索オプション
  private SB_NameCardL_RegistQueryOption contactQueryOption; // コンタクト検索オプション
  private SB_NameCardL_RegistQueryOption leadQueryOption;  // リード検索オプション
  private enum RegistType { AccountContact, AccountContactLead, Lead }
  private RegistType registObjs;

  private static final List<RecordTypeInfo> ACNT_RECORDTYPES;
  private static final List<RecordTypeInfo> CONT_RECORDTYPES;
  //複数Account.sObjectType.でオブジェクトとらないようにため
  //取引先オブジェクト表示ラベル
  public static final String AC_LABEL;
  //取引先責任者オブジェクト表示ラベル
  public static final String CO_LABEL;
  //SV_DEV-605 changeLabelを何回もコールしないようにstaticプロパテイに設定 -> 取引先新規作成
  //ラベル:取引先を新規作成
  public static final String ACCOUNT_NEW;
  //ラベル:取引先責任者を新規作成
  public static final String CONTACT_NEW;

  static {
    ACNT_RECORDTYPES = SB_NameCardL_TwowayRegistController.getRecordType(Account.sObjectType);
    CONT_RECORDTYPES = SB_NameCardL_TwowayRegistController.getRecordType(Contact.sObjectType);
    AC_LABEL = Account.sObjectType.getDescribe().getLabel();
    CO_LABEL = Contact.sObjectType.getDescribe().getLabel();
    ACCOUNT_NEW = String.format(System.Label.SB_NCLD_Label_CreateNewLeadDEV, new String[]{AC_LABEL});
    CONTACT_NEW = String.format(System.Label.SB_NCLD_Label_CreateNewLeadDEV, new String[]{CO_LABEL});
  }



  public Boolean isAllowDuplicateSave { get; private set; }

  public SmartViscaf__NameCardBasicSetting__c  baseSetting{
    get{
      if (baseSetting == null) {
        baseSetting = SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting();
      }
      return baseSetting;
    }
    set;
  }

  public static List<RecordTypeInfo> getRecordType(Schema.sObjectType obj) {

    List<Schema.RecordTypeInfo> rs =  obj.getDescribe().getRecordTypeInfos();
    List<RecordTypeInfo> recordtypes = new List<RecordTypeInfo>();
    for (RecordTypeInfo r : rs) {
      if (r.isAvailable()) {
        recordtypes.add(r);
      }
    }
    //isMasterメソード使えるにはWinter'16　APIバージョン35.0以降でなければならない、
    //そのため、今最後のレコードタイプMasterをリストから削除します
    if (recordtypes.size()>0) {
      recordtypes.remove(recordtypes.size()-1);
    }
    return recordtypes;
  }

    //取引先レコードタイプOption取得
  public List<SelectOption> getAccRecTypeSelectOpts() {
    List<SelectOption> options = new List<SelectOption>();
    //options.add(new SelectOption('', ''));
    for (RecordTypeInfo r : ACNT_RECORDTYPES) {
      options.add(new SelectOption(r.getRecordTypeId(), r.getName()));
    }

    return options;
  }

  //取引先責任者レコードタイプOption取得
  public List<SelectOption> getContRecTypeSelectOpts() {
    List<SelectOption> options = new List<SelectOption>();
    //options.add(new SelectOption('', ''));
    for (RecordTypeInfo r : CONT_RECORDTYPES) {
      options.add(new SelectOption(r.getRecordTypeId(), r.getName()));
    }

    return options;
  }

  //すべてのレコードタイプを取得
  private static final List<RecordTypeInfo> LEADRECORDTYPES = SB_NameCardL_TwowayRegistController.getRecordType(Lead.sObjecttype);

  public SB_NameCardL_TwowayRegistController(ApexPages.StandardController sc) {
    try {
          this.candidateTable = new List<CandidateRecord>();
          this.leadCreateable = Lead.sObjectType.getDescribe().isCreateable();
          this.screenData = new ScreenData();
          this.registObjs = RegistType.AccountContactLead;
          this.accountQueryOption = getQueryOption(Account.sObjecttype);
          this.contactQueryOption =  getQueryOption(Contact.sObjecttype);
          if (this.registObjs == RegistType.AccountContactLead || this.registObjs == RegistType.Lead) {
            this.leadQueryOption =  getQueryOption(Lead.sObjecttype);
          }

          String accstr = SB_NameCardL_Util.getDefaultRecordType(Account.sObjectType);

          String constr = SB_NameCardL_Util.getDefaultRecordType(Contact.sObjectType);

          this.accountRecTypeEdit = !Account.sObjectType.getDescribe().isCreateable() || (ACNT_RECORDTYPES.size() < 1);

          this.contactRecTypeEdit = !Contact.sObjectType.getDescribe().isCreateable() || (CONT_RECORDTYPES.size() < 1);

          this.accountRecTypeId = String.isBlank(accstr) ? 'nano' : accstr;

          this.contactRecTypeId = String.isBlank(constr) ? 'nano' : constr;

          // --------------------- changelabel start ---------------------
          // this.createNewLeadLabel = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Label_CreateNewLeadDEV);
          this.createNewLeadLabel = String.format(System.Label.SB_NCLD_Label_CreateNewLeadDEV, new String[] {LEADLABEL});
          // this.registerToLeadLabel = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Text_RegisterToLeadDEV);
          //this.registerToLeadLabel = String.format(System.Label.SB_NCLD_Text_RegisterToLeadDEV, new String[] {LEADLABEL});
          this.registerToLeadLabel = System.Label.SB_NCLD_Text_RegisterToLead_OR_Account_Contact;
          // this.overwriteLeadInfoLabel = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV);
          this.overwriteLeadInfoLabel = String.format(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV, new String[] {LEADLABEL});
          // this.specifiedWhenCreateNew = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Text_SpecifiedWhenCreateNew);
          this.specifiedWhenCreateNew = String.format(System.Label.SB_NCLD_Text_SpecifiedWhenCreateNew, new String[] {LEADLABEL});
          // --------------------- changelabel end ---------------------

          if (this.svConfig.config.id == null) {
            this.searchField = FIELD_NAMESITE;
          } else if (this.svConfig.config.SmartViscaf__AccountSearchType__c == null) {
            this.searchField = FIELD_NAMESITE;
          } else {
            this.searchField = this.svConfig.config.SmartViscaf__AccountSearchType__c ? QUERY_PERFECT : FIELD_NAMESITE;
          }
          Boolean ab = ACNT_RECORDTYPES.size() > 1;

          Boolean cb = CONT_RECORDTYPES.size() > 1;

          if (basesetting == null) {
            this.showAccountRecType = ab;
            this.showContactRecType = cb;
          } else {
            this.showAccountRecType = basesetting.SmartViscaf__RegistDispAccountRectype__c && ab;
            this.showContactRecType = basesetting.SmartViscaf__RegistDispContactRectype__c && cb;
          }

          //  取引先レコードタイプ Classic画面で名刺登録を「言語：英語」（英語表示）の状態で登録した場合にレコードタイプ設定のラベル名変更が反映されない
          this.accountRecType = String.format(System.Label.SB_NCLD_Label_LeadRecType,new String[]{SB_NameCardL_TwowayRegistController.AC_LABEL});
          //  取引先責任者レコードタイプ
          this.contactRecType = String.format(System.Label.SB_NCLD_Label_LeadRecType,new String[]{SB_NameCardL_TwowayRegistController.CO_LABEL});

          this.showRecTypeSectionItem = this.showAccountRecType || this.showContactRecType;
          //既存の取引先を名刺情報で上書きする」を表示する
          this.showUpdateAccount = basesetting.SmartViscaf__RegistDispAccountOverWriteCheckbox__c;
          //既存の取引先責任者を名刺情報で上書きする」を表示する
          this.showUpdateContact = basesetting.SmartViscaf__RegistDispContactOverWriteCheckbox__c;
          //既存のリードを名刺情報で上書きする」を表示する
          this.showUpdateLead = basesetting.SmartViscaf__RegistDispLeadOverWriteCheckbox__c;

          this.showUpdate = this.showUpdateAccount || this.showUpdateContact;

          //  新規作成の場合、レコードタイプを選択します。 
          this.recordTypeExplain = String.format(System.Label.SB_NCLD_Label_RecordTypeExplain, new String[]{SB_NameCardL_TwowayRegistController.AC_LABEL, SB_NameCardL_TwowayRegistController.CO_LABEL});

          //ラベル:既存の取引先の情報を名刺情報で上書きする
          this.updateForAccount = String.format(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV,new String[]{SB_NameCardL_TwowayRegistController.AC_LABEL});
          //ラベル:既存の取引先責任者の情報を名刺情報で上書きする
          this.updateForContact = String.format(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV,new String[]{SB_NameCardL_TwowayRegistController.CO_LABEL});

          this.accountOverWrite = !baseSetting.SmartViscaf__RegistAccountNotOverWrite__c && Account.sObjectType.getDescribe().isUpdateable();
          this.contactOverWrite = !baseSetting.SmartViscaf__RegistContactNotOverWrite__c && Contact.sObjectType.getDescribe().isUpdateable();

          this.cannotUpdataAccount = !Account.sObjectType.getDescribe().isUpdateable();
          this.cannotUpdataContact = !Contact.sObjectType.getDescribe().isUpdateable();
          this.cannotUpdataLead = !Lead.sObjectType.getDescribe().isUpdateable();

          if (!cannotUpdataAccount) {
            // デフォルトチェックはカスタム設定から取得
            if (basesetting == null){
              this.accountOverwrite = true;
            }
            else {
              this.accountOverwrite = !basesetting.SmartViscaf__RegistAccountNotOverWrite__c;
            }
          }

          if (!cannotUpdataContact) {
            if (basesetting == null) {
              this.contactOverwrite = true;
            } else {
              this.contactOverwrite = !basesetting.SmartViscaf__RegistContactNotOverWrite__c;
            }
          }

          if (!canNotUpdataLead) {
            if (baseSetting == null) {
              this.leadOverwrite = true;
            } else {
              this.leadOverwrite = baseSetting.SmartViscaf__RegistLeadNotOverWrite__c;
            }
          }


          this.leadRecTypeEdit = leadCreateable && LEADRECORDTYPES.size() > 1;

          this.canEditTodo = true;

          this.campLookUpDisabled = !SmartViscaf__NameCard__c.campaign__c.getDescribe().isAccessible();

          this.campDisabled = !CampaignMember.sObjectType.getDescribe().isCreateable() || campLookUpDisabled;

          this.searchType = SB_NameCard_LeadRegist.SEARCHTYPE_EMAIL;
          this.leadRecordListIndex = -1;
          this.accountTableIndex = -1;
          this.lookUpIndex = -1;
          this.leadRecordList = new List<CandidateRecord>();
          this.todo = new Task();
          this.isAllowDuplicateSave = false;
          this.todo.Subject  = baseSetting.SmartViscaf__RegistToDoSubject__c;
          this.registTodo    = !baseSetting.SmartViscaf__RegistNoToDo__c;
          // SV_DEV-747 リード拡張パッケージのカスタム設定：リードに登録 リードレコードタイプ表示の初期値がOFF
          this.showLeadRecType = LEADRECORDTYPES.size() > 1 && baseSetting.SmartViscaf__RegistDispLeadRectype__c;

          // SV_DEV-753 リードに登録（個別画面）でキャンペーン選択後の「キャンペーンメンバー状況」の値がデフォルト値にならない。
          if (String.isNotBlank(this.namecard.campaign__c)) {
            campStatus = this.namecard.campaign__r.Status;
          }

          //レコードタイプに関する設定
          setRecord();
          String ncId = sc.getId();
          Set<String> fields = SB_NameCardL_RegistQueryExecutor.getNameCardFields();
          if (!fields.contains('Owner.IsAvtive')) {
            fields.add('Owner.IsActive');
          }
          String query = String.format('SELECT {0} FROM SmartViscaf__NameCard__c WHERE Id = :ncId', new String[] { String.join(new List<String>(fields), ', ')});
          List<SmartViscaf__NameCard__c> cards = Database.query(query);
          if (cards.isEmpty()) {
            throw new LeadRegistControllerException('');
          }
          this.nameCard = cards[0];
          this.campaignStatus = getCampaign();
          this.pageLead = new Lead();
          if (this.nameCard.Owner.IsActive) {
            if (this.nameCard.OwnerId.getSObjectType() == User.getSobjectType()) {
               this.pageLead = new Lead(OwnerId=this.nameCard.OwnerId);
            }
            else {
              List<QueueSobject> qss = [Select QueueId, SobjectType, Queue.Name
                                      FROM QueueSobject
                                     WHERE QueueId = :this.nameCard.OwnerId
                                       AND SobjectType = 'Lead'];
              if (qss.size() > 0) {
                  this.pageLead = new Lead(OwnerId = this.nameCard.OwnerId);
              }
            }
          }
          this.pageAccount = new Account();
          if (String.valueOf(this.nameCard.OwnerId).startsWith('005')) {
            this.pageAccount.OwnerId = this.nameCard.OwnerId;
          }
          //if (this.nameCard == null) throw new SB_NameCard_LeadRegist.LeadRegistException('名刺がみつかりません');
          if (this.nameCard == null) {
            throw new SB_NameCard_LeadRegist.LeadRegistException(System.Label.SB_NCLD_Msg_BusinessCardNotFound);
          }

          if (String.isBlank(this.nameCard.SmartViscaf__email__c) && (String.isNotBlank(this.nameCard.SmartViscaf__person_name_last__c) || String.isNotBlank(this.nameCard.SmartViscaf__person_name_first__c))) {
            this.searchType = SB_NameCard_LeadRegist.SEARCHTYPE_NAME;
          }
          this.todo.ActivityDate = this.nameCard.SmartViscaf__card_exchange_date__c;
          this.campaign = this.nameCard.Campaign__c;

          List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c> { this.nameCard };
          SB_NameCard_LeadRegist.setEmailSoql(this.soqlMap, this.emailIdList, this.emailList, ncList);
          //SB_NameCard_LeadRegist.setNameSoql(this.soqlMap, this.nameIdList, this.nameSet, ncList);
          SB_NameCard_LeadRegist.setLastFirstNameSoql(this.soqlMap, this.nameIdList, this.nameSet,this.lastNameSet,this.firstNameSet, ncList);
          this.search();
          if (nameCard.SmartViscaf__company_name__c == null || String.isBlank(SmartViscaf.SB_NameCard_Util.getPersonName(nameCard).get('last_name'))) {
            if (!SmartViscaf.SB_NameCard_Util.isEnablePersonAccount()) {
              throw new SB_NameCard_LeadRegist.LeadRegistException(System.Label.SB_NCLD_MSG_CompanyNameMissing);
            }
            else {
              String str = Account.sObjecttype.getDescribe().getLabel() + '・' + Contact.sObjecttype.getDescribe().getLabel() + ' : ' + System.Label.SB_NCLD_MSG_CompanyNameMissing;
              if (String.isBlank(SmartViscaf.SB_NameCard_Util.getPersonName(nameCard).get('last_name'))) {
                str += '<br/>' + Lead.sObjectType.getDescribe().getLabel() + ' : ' + System.Label.SB_NCLD_MSG_NameMissing;
              }
              throw new SB_NameCard_LeadRegist.LeadRegistException(str);
            }
          }
    } catch (Exception e) {
      ApexPages.addMessages(e);
      testError = e.getMessage();
    }
  }

  //レコードタイプをに関する初期設定
  public void setRecord() {
      leadRecordTypeId = SB_NameCardL_Util.getDefaultRecordType(Lead.sObjectType);
      // leadRecType = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Label_LeadRecType);
      leadRecType = String.format(System.Label.SB_NCLD_Label_LeadRecType, new String[] {LEADLABEL});
  }

  public void checkRadio() {
      CandidateRecord lea = this.leadRecordList[this.leadRecordListIndex];

      if (Lead.sObjectType.getDescribe().isCreateable()) {
          this.leadRecTypeEdit = lea.getLeadId() == null && LEADRECORDTYPES.size() > 1;
      }
  }

  //リードレコードタイプ選択リストoptopn
  public List<SelectOption> getleadRecordTypeOptions() {
      List<SelectOption> options = new List<SelectOption>();
      for (RecordTypeInfo r : LEADRECORDTYPES) {
          options.add(new SelectOption(r.getRecordTypeId(), r.getName()));
      }
      return options;
  }

  public void changeCampaign() {
      this.campaignStatus = getCampaign();
  }

  //SV_DEV-175 リード登録時にキャンペーン内での状況を選択
  public  List<SelectOption> getCampaign() {
    List<SelectOption> options = new List<SelectOption>();
    //キャンペーンがない時登録しないで表示
    List<CampaignMemberStatus> cpms = [SELECT id, CampaignID, HasResponded, IsDefault, Label, SortOrder
                                         FROM CampaignMemberStatus Where CampaignId = :namecard.campaign__c];
    for (CampaignMemberStatus f: cpms) {
      if (f.IsDefault == true) {
        campStatus = f.Label;
      }
      options.add(new SelectOption(f.Label, f.Label));
    }
    campDisabled = options.size() <= 0 || campLookUpDisabled;
    return options;
  }

  // 検索条件
  public static List<SelectOption> getSearchTypeList() {
      return SB_NameCard_LeadRegist.getSearchTypeList();
  }

   // selectOptions 取引先検索条件
  public List<SelectOption> getSearchTypeSelectOpts(){
    List<SelectOption> opts = new List<SelectOption>();
    String str = String.format(System.Label.SB_NCLD_SearchForAccountAndDepartment,new String[]{SB_NameCardL_TwowayRegistController.AC_LABEL});
    String str1 = String.format(System.Label.SB_NCLD_SearchForAccount,new String[]{SB_NameCardL_TwowayRegistController.AC_LABEL});
    opts.add(new SelectOption(String.valueOf(FIELD_NAMESITE), str));
    opts.add(new SelectOption(String.valueOf(FIELD_NAME), str1));
    //ラベル:取引先名と所属名で検索
    // String str = String.format(System.Label.SB_NC_SearchForAccountAndDepartmentDEV,new String[]{SB_NameCard_AccountRegistController.AC_LABEL});
    // opts.add(new SelectOption(String.valueOf(SB_NameCard_Util.SEARCHTYPE_NAME_SITE), str));
    //ラベル:取引先名のみで検索
    // String str1 = String.format(System.Label.SB_NC_SearchForAccountDEV,new String[]{SB_NameCard_AccountRegistController.AC_LABEL});
    // opts.add(new SelectOption(String.valueOf(SB_NameCard_Util.SEARCHTYPE_NAME), str1));

    return opts;
  }

  // 連携タイプ
  public static List<SelectOption> getRenkeiTypeList() {
    List<SelectOption> os = new List<SelectOption>();
    os.add(new SelectOption('Lead', Lead.sObjectType.getDescribe().getLabel()));
    os.add(new SelectOption('Contact', Account.sObjecttype.getDescribe().getLabel() + '・' + Contact.sObjecttype.getDescribe().getLabel()));
    return os;
  }

    // 検索してテーブルを更新
  public PageReference search() {
    try {
      buildCandidateList();
      //buildCandidateList();
    }
    catch(Exception e) {
      System.debug(e.getStackTraceString());
      ApexPages.addMessages(e);
    }
    return null;
  }

  // リード
  // private List<Lead> getLeadList() {
  //   String soql = this.soqlMap.get(this.searchType);
  //   if (String.isBlank(soql)) return new List<Lead>();
  //   System.debug(soql);
  //   return Database.query(soql);
  // }

  // リードルックアップ
  public void setLookUp() {
    try {
      if (this.lookUpIndex >= this.leadRecordList.size()) return;
        LeadLookupCandidate leadRec = (LeadLookupCandidate)this.leadRecordList.get(this.lookUpIndex);
        Id leadId = leadRec.card4Lookup.SmartViscaf__lead__c;
      if (leadId == null) {
        return;
      }
      leadRec.postLookup();
      // for (Lead lead : [SELECT Id, Company, State, Title, Name, Email, LastModifiedDate, OwnerId, Owner.Name, MobilePhone FROM Lead WHERE Id = :leadId]) {
      //   leadRec.le = lead;
      // }
    } catch (Exception e) {
      ApexPages.addMessages(e);
      testError = e.getMessage();
    }
  }


  public PageReference saveRenkei() {
    if (renkeiType == 'Lead') {
      return saveLead();
    } else if (renkeiType == 'Contact') {
      return saveContact();
    } else {
      return null;
    }
  }

  public PageReference saveContact() {
    try {
      CandidateRecord accRec;
      //System.debug('save: accountTable: size: ' + this.accountTable.size() + ' index: ' + this.accountTableIndex);
      System.debug('accountTableIndex is ' + this.accountTableIndex);
      if (this.accountTableIndex >= 0) {
        accRec = this.candidateTable[this.accountTableIndex];
      } else {
        throw new LeadRegistControllerException(System.Label.SB_NCLD_Msg_SelectRegisterDestination);
      }
      if (accRec == null) {
        //  ToDo 仮ラベルSB_NCLD_Msg_SelectRegisterDestination
        throw new LeadRegistControllerException(System.Label.SB_NCLD_Msg_SelectRegisterDestination);
      }
      Account acc;
      Contact c;

      if (!this.accountRecTypeEdit) {
        acc = (Account)Account.sObjectType.newSObject(this.accountRecTypeId, false);
        acc.put('RecordTypeId',this.accountRecTypeId);
      } else {
        acc = (Account)Account.sObjectType.newSObject(null, false);
      }

      if (!this.contactRecTypeEdit) {
        c = (Contact)Contact.sObjectType.newSObject(this.contactRecTypeId, false);
        c.put('RecordTypeId',this.contactRecTypeId);
      } else {
        c = (Contact)Contact.sObjectType.newSObject(null, false);
      }
      //ラベル:取引先を入力してください
      String straccount = String.format(System.Label.SB_NCLD_MSG_Enter,new String[]{SB_NameCardL_TwowayRegistController.AC_LABEL});
      //ラベル:取引先責任者を入力してください
      String strcontact = String.format(System.Label.SB_NCLD_MSG_Enter,new String[]{SB_NameCardL_TwowayRegistController.CO_LABEL});
      if (accRec instanceof AccountLookupCandidate) {
        System.debug('ccccccc');
        AccountLookupCandidate cdata =  (AccountLookupCandidate) accRec;
        if (cdata.card4Lookup.SmartViscaf__account__c == null) {
          throw new LeadRegistControllerException(straccount);
        }

        acc.Id=cdata.card4Lookup.SmartViscaf__account__c;
        //c = new Contact();
      } else if (accRec instanceof ContactLookupCandidate) {
        System.debug('bbbbbbb');
        ContactLookupCandidate cdata =  (ContactLookupCandidate) accRec;
        if (cdata.card4Lookup.SmartViscaf__contact__c == null) {
          throw new LeadRegistControllerException(strcontact);
        }

        acc.Id = cdata.card4Lookup.SmartViscaf__account__c;
        c.Id=cdata.card4Lookup.SmartViscaf__contact__c;
      } else{
        System.debug('aaaaaaa');
        if (!String.isBlank(accRec.getAccountId())) {
          acc.Id=accRec.getAccountId();
        }
        if (!String.isBlank(accRec.getContactId())) {
          c.Id=accRec.getContactId();
        }
      }
      c.AccountId = acc.Id;
      if (this.accountRecTypeEdit) {
        this.accountRecTypeId = null;
      }
      // SV_DEV-781  個別取引先登録 で 既存の アカウント、コンタクトを選択していても、「新規作成時の指定」の所有者をしていしていないとエラーになる。
      if ((String.isBlank(acc.Id) || String.isBlank(c.Id)) && String.isBlank(pageLead.OwnerId)) {
        // 取引先、取引先責任者を新規作成する場合は「所有者」を指定してください
        // SB_NC_SpecifyOwnerWhenCreateAcCo
        throw new LeadRegistControllerException(System.Label.SB_NCLD_SpecifyOwnerWhenCreateAcCo);
      }
      SB_NameCardL_RegistHelper.RegistParam acre = new SB_NameCardL_RegistHelper.RegistParam('Account',this.accountOverwrite,this.accountRecTypeId,acc.Id == null ? pageAccount.OwnerId : acc.OwnerId,this.isAllowDuplicateSave);

      if (this.contactRecTypeEdit) {
        this.contactRecTypeId = null;
      }
      SB_NameCardL_RegistHelper.RegistParam conre = new SB_NameCardL_RegistHelper.RegistParam('Contact',this.contactOverwrite,this.contactRecTypeId,c.Id == null ? pageAccount.OwnerId : c.OwnerId,this.isAllowDuplicateSave);

      SB_NameCardL_RegistHelper.TodoParam todo = new SB_NameCardL_RegistHelper.TodoParam(this.todo.Subject,this.todo.ActivityDate,this.todo.Description,null);

      System.debug(this.registTodo + 'nid ' + ' ' +  this.nameCard.Id + 'aid ' + acc.Id + 'cid' + c.Id);
      SB_NameCardL_RegistHelper.RegistTarget tar = new SB_NameCardL_RegistHelper.RegistTarget(SB_NameCardL_RegistHelper.ProcType.ACCOUNT,
                                                                                              this.nameCard.Id,
                                                                                              acc.Id,
                                                                                              c.Id,
                                                                                              null,
                                                                                              this.registTodo,
                                                                                              this.todo.ActivityDate);
      System.debug(acre);
      System.debug(conre);
      System.debug(tar);
      SB_NameCardL_RegistHelper.RegistRequest re = new SB_NameCardL_RegistHelper.RegistRequest(new List<SB_NameCardL_RegistHelper.RegistTarget>{tar},acre,conre,null,todo);
      Map<Id, String> ownerErrorMap = SB_NameCardL_RegistOwenrCheckHelper.doCheck(re);
        System.debug(ownerErrorMap);
        if (!ownerErrorMap.isEmpty()) {
          String str = '';
          str += ownerErrorMap.get(this.nameCard.Id);
          throw new LeadRegistControllerException(str);
        }
      //doRegist内既にrollbackしていますので、ここは二度目はしません
      SB_NameCardL_RegistHelper.RegistResponse result = SB_NameCardL_RegistHelper.doRegist(re);
      if (result.success == false) {
        System.debug(result.title);
        System.debug(result.errorObject);
        System.debug(result.message);
        System.debug(result.dbErrors);
        this.isAllowDuplicateSave = result.allowRetry;
        this.dispDuplicateCheck = result.allowRetry;
        String str = '';
        if (result.dbErrors != null) {
          str = result.dbErrors.get(this.nameCard.Id).msg;
        }
        str = String.isBlank(str) ? result.title : result.title + '<br/>' + str;
        throw new LeadRegistControllerException(str);
      }
      PageReference retUrl;
      SB_NameCardL_RegistHelper.SObjectInfo cc = result.registeds.get(this.nameCard.Id).cont;
      System.debug(cc);
      if (cc.Id != null) {
        retUrl = new PageReference('/' + cc.Id);
      }

      return retUrl;
    }
    catch (Exception e){
      System.debug(e.getStackTraceString());
      ApexPages.addMessages(e);
      // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, e.getStackTraceString()));
      return null;
    }
  }

  // 保存
  // SV_DEV-762 名刺オブジェクトの編集権限がない場合にリードに登録の処理が終了しない。
  public PageReference saveLead() {
    PageReference pageRef;
    Savepoint sp;

    try {
      if (this.leadRecordListIndex < 0 || this.leadRecordListIndex >= this.leadRecordList.size()) {
        //throw new SB_NameCard_LeadRegist.LeadRegistException('登録先を選択してください');
        throw new SB_NameCard_LeadRegist.LeadRegistException(System.Label.SB_NCLD_Msg_SelectRegisterDestination);
      }
      CandidateRecord leadRec = this.leadRecordList.get(this.leadRecordListIndex);
      Id leadId, ownerId;
      if (leadRec.type == CandidateType.CREATE_LEAD) {
        Schema.DescribeSObjectResult tar = Lead.sObjectType.getDescribe();
        if(!Lead.sObjectType.getDescribe().isCreateable()) {
          throw new LeadRegistControllerException(String.format(System.Label.SB_NCLD_MSG_CrudNotCreateable,new String[]{tar.label})) ;
        }

        if (this.pageLead.OwnerId == null) {
          // String str = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Msg_SpecifyOwnerWhenCreateLeadDEV);
          String str = String.format(System.Label.SB_NCLD_Msg_SpecifyOwnerWhenCreateLeadDEV, new String[] {LEADLABEL});
          //throw new SB_NameCard_LeadRegist.LeadRegistException('リードを新規作成する場合は「所有者」を指定してください');
          throw new SB_NameCard_LeadRegist.LeadRegistException(str);
        }
        ownerId = this.pageLead.OwnerId;
      } else {
        Schema.DescribeSObjectResult tar = Lead.sObjectType.getDescribe();
        if(!Lead.sObjectType.getDescribe().isUpdateable() && this.leadOverwrite) {
          throw new LeadRegistControllerException(String.format(System.Label.SB_NCLD_MSG_CrudNotUpdateable, new String[]{tar.label}));
        }
        if (this.leadRecordListIndex < 0) {
          // String str = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Msg_SelectLeadDEV);
          String str = String.format(System.Label.SB_NCLD_Msg_SelectLeadDEV, new String[] {LEADLABEL});
          //throw new SB_NameCard_LeadRegist.LeadRegistException('リードを選択してください');
          throw new SB_NameCard_LeadRegist.LeadRegistException(str);
        }
        leadId = leadRec.getLeadId();
        ownerId = leadRec.getLeadId();
      }
      List<Lead>leads = new List<Lead>();
      // System.debug(ownerId);
      // // SV_DEV-565 リード登録のリード所有者の修正
      // if (!String.valueOf(ownerId).startsWith('005') && String.isNotBlank(ownerId)) {
      //   List<QueueSobject> qss = [Select QueueId, Queue.Name, SobjectType
      //                        FROM QueueSobject
      //                       WHERE QueueId = :ownerId];
      //   Boolean canUserLead = false;
      //   String qName = qss[0].Queue.Name;
      //   for (QueueSobject qs : qss) {
      //     if (qs.SobjectType == 'Lead') {
      //       canUserLead = true;
      //       break;
      //     }
      //   }
      //   if (canUserLead == false) {
      //     throw new SB_NameCard_LeadRegist.LeadRegistException(String.format(System.Label.SB_NCLD_MSG_QUEUES_LEAD_ERROR,new String[]{qName}));
      //   }
      // }

      // if (this.registTodo) {
      //   // SV_DEV-727 リードへ登録、名刺所有者がキューおよリード所有者がキューの場合
      //   if (!String.valueOf(ownerId).startsWith('005')) {
      //     throw new SB_NameCard_LeadRegist.LeadRegistException(System.Label.SB_NCLD_MSG_QUEUES_ERROR);
      //   }
      // }



      SB_NameCardL_RegistHelper.RegistParam leadRP = new SB_NameCardL_RegistHelper.RegistParam('Lead', this.leadOverwrite, this.leadRecordTypeId, ownerId, this.isAllowDuplicateSave );
      SB_NameCardL_RegistHelper.TodoParam todoRP = new SB_NameCardL_RegistHelper.TodoParam(this.todo.Subject, this.todo.ActivityDate,this.todo.Description,null);
      SB_NameCardL_RegistHelper.RegistTarget tar = new SB_NameCardL_RegistHelper.RegistTarget(SB_NameCardL_RegistHelper.ProcType.LEAD,
                                                                                              this.nameCard.Id,
                                                                                              null,
                                                                                              null,
                                                                                              leadId,
                                                                                              registTodo,
                                                                                              null);
      if (String.isNotBlank(nameCard.campaign__c) && String.isBlank(leadId)) {
        tar.setLeadCampaign(nameCard.campaign__c, campStatus);
      }

      SB_NameCardL_RegistHelper.RegistRequest re = new SB_NameCardL_RegistHelper.RegistRequest(new SB_NameCardL_RegistHelper.RegistTarget[]{tar}, null, null, leadRP, todoRP);
      //doRegist内既にrollbackしていますので、ここは二度目はしません
      SB_NameCardL_RegistHelper.RegistResponse result = SB_NameCardL_RegistHelper.doRegist(re);
      if (result.success == false) {
        this.isAllowDuplicateSave = result.allowRetry;
        // this.dispDuplicateCheck = result.allowRetry;
        String str = '';
        if (result.dbErrors != null) {
          str = result.dbErrors.get(this.nameCard.Id).msg;
        }
        str = String.isBlank(str) ? result.title : result.title + '<br/>' + str;
        throw new LeadRegistControllerException(str);
      }
      PageReference retUrl;
      SB_NameCardL_RegistHelper.SObjectInfo le = result.registeds.get(this.nameCard.Id).lead;
      System.debug(le);
      if (le.Id != null) {
        retUrl = new PageReference('/' + le.Id);
      }

      return retUrl;
    } catch (Exception e) {
        System.debug(e.getStackTraceString());
        if (sp != null) Database.rollback(sp);
        ApexPages.addMessages(e);
        // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, e.getStackTraceString()));
        testError = e.getMessage();
    }
    return pageRef;
  }

  // リード
  // private void upsertLead(List<Lead> lead, Boolean isInsert) {
  //   Database.DMLOptions dmlOpts = new Database.DMLOptions();
  //   dmlOpts.DuplicateRuleHeader.allowSave = this.isAllowDuplicateSave; // 重複レコードを保存するか
  //   System.debug(lead);
  //   List<Database.SaveResult> sr = isInsert ? SmartViscaf.SB_NameCard_CrudFls.screate(lead, dmlOpts) : SmartViscaf.SB_NameCard_CrudFls.supdate(lead, dmlOpts);
  //   if (sr[0].isSuccess()) return;
  //   SB_NameCard_LeadSaveResult dbError = new SB_NameCard_LeadSaveResult();
  //   dbError.putSaveResults(sr);
  //    if (dbError.isError())
  //   {
  //       this.isAllowDuplicateSave = dbError.isAllowSave();
  //       String msg = lead[0].getSObjectType().getDescribe().getLabel() + ': ' + dbError.getDbErrorHolder(0).msg;
  //       throw new SB_NameCard_LeadRegist.LeadRegistException(msg);
  //   }

  // }

  public List<CandidateRecord> buildCandidateList() {
    List<SB_NameCardL_RegistQueryOption> queryOptions = new List<SB_NameCardL_RegistQueryOption>();
    if (this.accountQueryOption != null) {
      // 部門を検索する？
      this.accountQueryOption.queryDept = (this.searchField == FIELD_NAMESITE);
      // 取引先名 は完全に一致？
      this.accountQueryOption.companyRule = this.queryMatch == QUERY_PERFECT_NO ?
            SB_NameCardL_RegistQueryOption.CompanyMatcing.PartialMatch : SB_NameCardL_RegistQueryOption.CompanyMatcing.FullMatch;
      // 部門の検索は完全一致？
      this.accountQueryOption.deptRule = this.queryMatch == QUERY_PERFECT_NO ?
            SB_NameCardL_RegistQueryOption.DeptMatcing.PartialMatch : SB_NameCardL_RegistQueryOption.DeptMatcing.FullMatch;
      queryOptions.add(this.accountQueryOption);
    }
    if (this.contactQueryOption !=null) {
      queryOptions.add(this.contactQueryOption);
    }
    if (this.leadQueryOption != null) {
      if (this.searchType == SB_NameCard_LeadRegist.SEARCHTYPE_EMAIL) {
        this.leadQueryOption.queryLastName = false;
        this.leadQueryOption.queryFirstName = false;
        this.leadQueryOption.queryEMail = true;
      }
      else {
        this.leadQueryOption.queryLastName = true;
        this.leadQueryOption.queryFirstName = true;
        this.leadQueryOption.queryEMail = false;
      }
      queryOptions.add(this.leadQueryOption);
    }
    System.assert(!queryOptions.isEmpty());
    SB_NameCardL_RegistCanPickerAbstract picker = searchMethod;
    // クエリする対象のオブエジェクト ごとに　SB_NameCardL_RegistQueryOption を作って、検索の条件を指定して渡します。
    picker.init(queryOptions);
    //picker.setQueryStrategys(qss);
    SB_NameCardL_RegistQueryExecutor qExecutor = SB_NameCardL_RegistQueryExecutor.getInstance();
    qExecutor.init(this.nameCard);      // init は オーバーロード されてて、 個別の場合は、これか、 Id をt１つ渡すメソッドをつかって、一括の場合は 複数を渡すのを使います。
    // picker の create もオーバーロード されてて、個別ならこれとかで、一括の場合は Map<Id, List<SObject>> create(Set<Id> cardIds); を名刺レコードIDと 一致するSObjectのリストのマップを返すのを使います。
    Map<SObjectType, List<SObject>> otype2objs = picker.create();
    Boolean haveAc = otype2objs.get(Account.sObjecttype).size() > 0;
    Boolean haveLead = otype2objs.get(Lead.sObjecttype).size() > 0;
    if (((haveAC && haveLead) || (haveAC && !haveLead)) && isFirst) {
       renkeiType = 'Contact';
       isFirst = false;
     } else if (!haveAC && haveLead) {
       renkeiType = 'Lead';
       isFirst = false;
     } else {
       if (svConfig.defaultDisplayExistingLead()) {
         renkeiType = 'Lead';
       } else {
         renkeiType = 'Contact';
       }
       isFirst = false;
     }
    return createCandidateRecordList(otype2objs);
  }

  //
  // RegistType ct 0: 取引先・取引先責任者とリード 1: 取引先・取引先責任者 2: リード
  // ToDo
  //1. 既存取引先と既存リードが両方存在する場合、取引先のリストを表示する。
  //2. 既存取引先か既存リードの一方が存在する場合、存在するほうのリストを表示する。
  //3. 両方とも存在しない場合、リードのリストを表示する。
  // 更新したときは、これにかかわらず、該当のリストの更新
  private List<CandidateRecord> createCandidateRecordList(Map<SObjectType, List<SObject>> otype2Recs) {
    this.candidateTable.clear();
    this.leadRecordList.clear();
    if (String.isNotBlank(nameCard.SmartViscaf__company_name__c) && String.isNotBlank(SmartViscaf.SB_NameCard_Util.getPersonName(nameCard).get('last_name'))) {
    // 1. 既存の取引先・取引先責任者 登録用の行の追加
      if ((this.registObjs == RegistType.AccountContactLead || this.registObjs == RegistType.AccountContact) &&
        otype2Recs.containsKey(Contact.sObjectType)) {
        // 1.1 コンタクトの候補
          addContact2Table((List<Contact>)otype2Recs.get(Contact.sObjectType));
        }
      if (this.registObjs == RegistType.AccountContactLead || this.registObjs == RegistType.AccountContact) {
        // 1.2 アカウントの候補
        //if (method.isRelationQuery()) {
        //  // Accountのクエリで Contactをリレーションクエリしてるとき、アカウント単位に コンタクトからテーブルに追加
        //  addAccountContact2Table((List<Account>)otype2Recs.get(Account.sObjectType));
        //}
        //else {
          if (otype2Recs.containsKey(Account.sObjectType)) {// && Schema.SObjectType.Contact.isCreateable()) {
            // 既存取引先＋新規取引先責任者 をリストへ追加
            addAccount2Table((List<Account>)otype2Recs.get(Account.sObjectType));
          }
        //}
      }
            // 3. 取引先・取引先責任者 の 新規レコード追加系 の行追加
      if (this.registObjs == RegistType.AccountContactLead || this.registObjs == RegistType.AccountContact) {
        addLookupAndNewAccount2Table();
      }
    }

    if ((nameCard.SmartViscaf__company_name__c != null && String.isNotBlank(SmartViscaf.SB_NameCard_Util.getPersonName(nameCard).get('last_name'))
      && !SmartViscaf.SB_NameCard_Util.isEnablePersonAccount())
      || (String.isNotBlank(SmartViscaf.SB_NameCard_Util.getPersonName(nameCard).get('last_name')))
      && SmartViscaf.SB_NameCard_Util.isEnablePersonAccount()) {
      // 2. 既存のリードの行の追加
      if ((this.registObjs == RegistType.AccountContactLead || this.registObjs == RegistType.Lead) &&
          otype2Recs.containsKey(Lead.sObjectType)) {
        addLead2Table((List<Lead>)otype2Recs.get(Lead.sObjectType));
      }
      // 4. リード の 新規レコード追加系 の行追加 s
      if (this.registObjs == RegistType.AccountContactLead || this.registObjs == RegistType.Lead) {
        addLookupAndNewLead2Table();
      }
    }
    return this.candidateTable;
  }

  // 取引先・取引先責任者登録のときの ルックアップ と 新規レコード追加の行の追加
  private void addLookupAndNewAccount2Table() {
    // 1: 既存取引先責任者ルックアップ
    this.candidateTable.add(new ContactLookupCandidate(this.candidateTable.size()));
    // 2: 既存取引先ルックアップ+新規取引先責任者
    if (Schema.SObjectType.Contact.isCreateable()) {
      this.candidateTable.add(new AccountLookupCandidate(this.candidateTable.size()));
    }
    // 3: 新規取引先+新規取引先責任者
    if (Schema.SObjectType.Account.isCreateable() && Schema.SObjectType.Contact.isCreateable()) {
      this.candidateTable.add(new NewAccountCandidate(this.candidateTable.size()));
    }
  }

  // Lead をリストへ追加
  private void addLead2Table(List<Lead> leads) {
    for (Lead lead : leads) {
      // 1: 既存取引先+既存取引先責任者ルックアップ
      //this.candidateList.add(new AccountCandidate(this.candidateList.size(), lead, true));
      // 2: 既存取引先+新規取引先責任者
      this.leadRecordList.add(new LeadCandidate(this.leadRecordList.size(), lead));
    }
  }

    // リード登録のときの ルックアップ と 新規レコード追加の行の追加
  private void addLookupAndNewLead2Table() {
    // 1: リードルックアップ
    this.leadRecordList.add(new LeadLookupCandidate(this.leadRecordList.size()));
    // 2: 新規リード
    if (Schema.SObjectType.Lead.isCreateable()) {
      this.leadRecordList.add(new NewLeadCandidate(this.leadRecordList.size()));
    }
  }

  public void changeOwner()
  {
    if (this.canEditTodo == false) {
      this.registTodo = false;
    }
  }

  // キャンセル
  public PageReference cancel() {
    if (this.nameCard == null) {
      return null;
    }
    return (new ApexPages.StandardController(this.nameCard)).view();
  }


  // COntact をテーブルへ追加
  private void addContact2Table(List<Contact> conts) {
    for (Contact cont : conts) {
      // 0: 既存取引先+既存取引先責任者
      this.candidateTable.add(new ContactCandidate(this.candidateTable.size(), cont));
    }
  }

  // Account をテーブルへ追加
  private void addAccount2Table(List<Account> acnts) {
    for (Account acnt : acnts) {
      //// 1: 既存取引先+既存取引先責任者ルックアップ
      //this.candidateTable.add(new AccountCandidate(this.candidateTable.size(), acnt, true));
      // 2: 既存取引先+新規取引先責任者
      this.candidateTable.add(new AccountCandidate(this.candidateTable.size(), acnt));
    }
  }

  // コンタクトルックアップ 後
  public void postLookupContact() {
    Integer index = Integer.valueOf(System.currentPageReference().getParameters().get('lookUpContactIndex'));
    try {
      if (index >= this.candidateTable.size()) return;
        ContactLookupCandidate contachRec = (ContactLookupCandidate)this.candidateTable.get(index);
        contachRec.postLookup();
    } catch (Exception e) {
      ApexPages.addMessages(e);
      testError = e.getMessage();
    }
  }

  private SB_NameCardL_RegistQueryOption getQueryOption(sObjectType type) {
    SB_NameCardL_RegistQueryOption ot = new SB_NameCardL_RegistQueryOption(type);
    ot.queryState = false;
    ot.queryCity = false;
    ot.queryStreet = false;
    ot.queryZip = false;
    ot.queryPhone = false;
    ot.queryCompany = false;
    ot.queryDept = false;
    ot.queryUrl = false;
    ot.queryLastName = false;
    ot.queryFirstName = false;
    ot.queryEMail = false;
    ot.queryTitle = false;
    ot.queryMobile = false;
    return ot;
  }
}