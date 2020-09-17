/**
 *
 * SB_NC_RegistQueryOption
 *
 *  レコード抽出の条件を保持してる クラス  画面の連携でついか
 *    これから SB_NC_RegistQueryStrategy を作る。
 *
 * (c) 2019 Sunbridge Inc.
 *
 *  @author K.Yoshida
 *  @Version 2.2  2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 *  @Version 2.4  2019.06.XX sawano 整理
 *                  queryOrgType から 
 *
 **/
public virtual class SB_NC_RegistQueryOption {
  public class SB_NC_RegistQueryOptionException extends Exception {}

  //public enum QueryTarget { Account, Contact, Lead }

  public enum CompanyMatcing { CorpMatch, // 法人格を除いて一致
                        PartialMatch,   // 法人格を除いて部分一致
                        ExactMatch,     // 完全一致。ただし法人格の正式・略称同一視設定オンの場合は、部分一致検索したあとに照合 SV_DEV-1647 法人格の正式名称と略称をマッチさせる（登録・自動連携）
                        PerfectMatch }  // 完全一致。法人格の正式・略称同一視設定オフの場合、または、個別登録で部分一致で件数が多かった場合にこれで絞る
  public enum DeptMatcing { PartialMatch, ExactMatch } //部分一致、完全一致

  //public class SB_NC_RegistQueryOption {
  public Boolean bulkRegist;      // TURE:一括登録 FALSE:個別登録
  public Boolean forceSoql;     // SOQL強制
  public SObjectType target;      // 検索対象オブジェクトは１つ。 一括登録 や Classicでは SB_NC_RegistQueryOption  のリストを作って、
  public Integer queryOrgType;    // クライアントからの指定専用 companyRule に反映する。 0:CorpMatch 1:PartialMatch 2:ExactMatch
  public Boolean queryState;
  public Boolean queryCity;
  public Boolean queryStreet;
  public Boolean queryZip;
  public Boolean queryPhone;
  public Boolean queryCompany;
  @TestVisible private Boolean querySite;     // v2.4 後方互換用
  public Boolean queryDept; 
  public Boolean queryUrl;
  public Boolean queryEMail;
  public Boolean queryOnlyEMail; // コンタクトのクエリで アカウントに関係なくメアドだけで該当にする。 個別では、アカウントのクエリで メアドの一致するコンタクトの親アカウントを該当にする。一括ではコンタクト自体をだすので、不要
  public Boolean queryPersonName;   // lx 2.0
  public Boolean queryLastName;     // v2.4
  public Boolean queryFirstName;    // v2.4
  public Boolean queryNameOrEMail;    // v2.4   姓名 か EMail いずれかが一致してればいい
  public Boolean queryTitle;
  public Boolean queryMobile;
  public CompanyMatcing companyRule;  // { ExactMatch, CorpMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致
  public DeptMatcing deptRule; // { ExactMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致
  // public Set<Id> rectypeIds { get; protected set; }  // 検索対称のレコードタイプを絞るとき
  public List<Id> acntRecTypeIds;  // v2.4アカウントのレコードタイプ名を条件にする
  public List<Id> contRecTypeIds;  // v2.4コンタクトのレコードタイプ名を条件にする
  public List<Id> leadRecTypeIds;  // v2.4 lx 2.0 リードのレコードタイプ名を条件にする
  @TestVisible public List<Id> parentIds { get; protected set; }  // コンタクトの検索で、親アカウントを絞って検索するとき
  @TestVisible public String altCompanyField { get; protected set; }     // アカウント、リードの 会社名 項目を Name や Company 以外の項目として扱う 2018.05.xx for Future Use
  //public Set<String> queryFields { get; protected set; }   // 取得刷る項目

  public SB_NC_RegistQueryOption() {
    this.bulkRegist = false;
    this.forceSoql = false;
    this.target = null;
    this.queryOrgType = null;
    this.queryState = false;
    this.queryCity = false;
    this.queryStreet = false;
    this.queryZip = false;
    this.queryPhone = false;
    this.queryCompany = true;
    this.queryDept = false;
    this.queryUrl = false;
    this.queryPersonName = true;
    this.queryLastName = true;
    this.queryFirstName = true;
    this.queryNameOrEMail = true;
    this.queryEMail = true;
    this.queryOnlyEMail = false;
    this.queryTitle = false;
    this.queryMobile = false;
    this.companyRule = CompanyMatcing.PartialMatch;  // 法人格を除いて部分一致
    this.deptRule = DeptMatcing.PartialMatch; // 部分一致
    this.acntRecTypeIds = new List<Id>();
    this.contRecTypeIds = new List<Id>();
    this.leadRecTypeIds = new List<Id>();
    this.parentIds = new List<Id>();
    this.altCompanyField = SB_NameCard_BasicSetting.getAltCompanyField(target); // v2.4; コードカバレッジ用
  }

  public SB_NC_RegistQueryOption(SObjectType target) {
    this.bulkRegist = false;
    this.forceSoql = false;
    this.target = target;
    this.queryState = false;
    this.queryCity = false;
    this.queryStreet = false;
    this.queryZip = false;
    this.queryPhone = false;
    this.queryCompany = target == Lead.sObjecttype ? false : true;
    this.queryDept = target == Account.sObjecttype ? true : false;
    this.queryUrl = false;
    this.queryPersonName = true;
    this.queryLastName = true;
    this.queryFirstName = true;
    this.queryNameOrEMail = true;
    this.queryEMail = true;
    this.queryOnlyEMail = target == Contact.sObjecttype ? true : false;
    this.queryTitle = false;
    this.queryMobile = false;
    this.companyRule = CompanyMatcing.PartialMatch;  // 法人格を除いて部分一致
    this.deptRule = DeptMatcing.PartialMatch; // 部分一致
    this.acntRecTypeIds = new List<String>();
    this.contRecTypeIds = new List<String>();
    this.leadRecTypeIds = new List<String>();
    this.parentIds = new List<Id>();
    if (target == Contact.getSObjectType()) {
      // コンタクトのとき、アカウントの会社名を調べるケースがあるので、セットしとく
      this.altCompanyField = SB_NameCard_BasicSetting.getAltCompanyField(Account.getSObjectType()); // v2.4 
    }
    else {
      this.altCompanyField = SB_NameCard_BasicSetting.getAltCompanyField(target); // v2.4
    }
  }

  public Boolean haveParents() { // v2.4
    return this.parentIds != null && !this.parentIds.isEmpty();
  }

  public void addParentId(Id parentId) { // v2.4
    if (!this.parentIds.contains(parentId)) {
      this.parentIds.add(parentId);
    }
  }

  public SB_NC_RegistQueryOption(SB_NC_RegistQueryOption qo) {
    copy(qo);
    this.altCompanyField = String.isNotBlank(qo.altCompanyField) ? qo.altCompanyField : SB_NameCard_BasicSetting.getAltCompanyField(this.target); // v2.4;
  }

  public SB_NC_RegistQueryOption(SObjectType target, SB_NC_RegistQueryOption qo) {
    copy(qo);
    this.target = target;
    this.altCompanyField = String.isNotBlank(qo.altCompanyField) ? qo.altCompanyField : SB_NameCard_BasicSetting.getAltCompanyField(this.target); // v2.4;
  }

  private void copy(SB_NC_RegistQueryOption qo) {
    this.bulkRegist = qo.bulkRegist != null ? qo.bulkRegist : false;
    this.forceSoql = qo.forceSoql != null ? qo.forceSoql : false;
    this.target = qo.target;
    this.queryState = qo.queryState != null ? qo.queryState : false;
    this.queryCity = qo.queryCity != null ? qo.queryCity : false;
    this.queryStreet = qo.queryStreet != null ? qo.queryStreet : false;
    this.queryZip = qo.queryZip != null ? qo.queryZip : false;
    this.queryPhone = qo.queryPhone != null ? qo.queryPhone : false;
    this.queryCompany = qo.queryCompany != null ? qo.queryCompany : true;
    this.queryDept = qo.querySite !=null ? qo.querySite : (qo.queryDept != null ? qo.queryDept : false);
    this.queryUrl = qo.queryUrl != null ? qo.queryUrl : false;
    this.queryPersonName = qo.queryPersonName != null ? qo.queryPersonName : true;
    this.queryLastName = qo.queryPersonName != null ? qo.queryPersonName : (qo.queryLastName != null ? qo.queryLastName : true);
    this.queryFirstName = qo.queryPersonName != null ? qo.queryPersonName : (qo.queryFirstName != null ? qo.queryFirstName : true);
    this.queryNameOrEMail = qo.queryNameOrEMail != null ? qo.queryNameOrEMail :true;
    this.queryEMail = qo.queryEMail != null ? qo.queryEMail : true;
    this.queryOnlyEMail = qo.queryOnlyEMail != null ? qo.queryOnlyEMail : false;
    this.queryTitle = qo.queryTitle != null ? qo.queryTitle : false;
    this.queryMobile = qo.queryMobile != null ? qo.queryMobile : false;
    this.companyRule = qo.companyRule != null ? qo.companyRule : CompanyMatcing.PartialMatch;  // 法人格を除いて部分一致
    this.deptRule = qo.deptRule != null ? qo.deptRule : DeptMatcing.PartialMatch; // 部分一致
    // v2.4 取引先登録のときの検索方法  会社名の一致ルール クライアントからの指定があったとき
    if (qo.queryOrgType != null) {
      switch on qo.queryOrgType {
        when 0 {
          this.companyRule = CompanyMatcing.CorpMatch;
        }
        when 2 {
          this.companyRule = CompanyMatcing.ExactMatch;
        }
        when else {
          this.companyRule = CompanyMatcing.PartialMatch;
        }
      }
    }
    else {
      //  初期値
      this.companyRule = SB_NameCard_BasicSetting.getNameCardBasicSetting().RenkeiExcludeHojinkaku__c ? CompanyMatcing.CorpMatch : 
                            (SB_NameCard_BasicSetting.getNameCardBasicSetting().RenkeiExcludeHojinkakuPartial__c ? CompanyMatcing.PartialMatch : CompanyMatcing.ExactMatch);
    }
    this.acntRecTypeIds = new List<Id>();
    if (qo.acntRecTypeIds != null && !qo.acntRecTypeIds.isEmpty()) {
      this.acntRecTypeIds.addAll(qo.acntRecTypeIds);
    }
    else if (!SB_NameCard_BasicSetting.registAccountQueryRecordTypeIds.isEmpty()) {
      // 設定されてる検索対象にしぼる
      this.acntRecTypeIds.addAll(SB_NameCard_BasicSetting.registAccountQueryRecordTypeIds);
    }
    this.contRecTypeIds = new List<Id>();
    if (qo.contRecTypeIds != null && !qo.contRecTypeIds.isEmpty()) {
      this.contRecTypeIds.addAll(qo.contRecTypeIds);
    }
    else if (!SB_NameCard_BasicSetting.registContactQueryRecordTypeIds.isEmpty()) {
      // 設定されてる検索対象にしぼる
      this.contRecTypeIds.addAll(SB_NameCard_BasicSetting.registContactQueryRecordTypeIds);
    }
    this.leadRecTypeIds = new List<Id>();
    if (qo.leadRecTypeIds != null && !qo.leadRecTypeIds.isEmpty()) {
      this.leadRecTypeIds.addAll(qo.leadRecTypeIds);
    }
    else if (!SB_NameCard_BasicSetting.registLeadQueryRecordTypeIds.isEmpty()) {
      // 設定されてる検索対象にしぼる
      this.leadRecTypeIds.addAll(SB_NameCard_BasicSetting.registLeadQueryRecordTypeIds);
    }
    this.parentIds = new List<Id>();
    if (qo.parentIds != null && !qo.parentIds.isEmpty()) {
      this.parentIds.addAll(qo.parentIds);
    }
  }
  // // @RemoteAction 経由の QueryOption から SB_NC_RegistQueryOption を作るメソッド
  // public static SB_NC_RegistQueryOption convertQueryOption(SObjectType otype, SB_NC_RegistOptionCreater.QueryOption qo) {
  //   QueryOptionConverter cnvr;
  //   if (otype == Account.sObjecttype) {
  //     cnvr =  new AccountQueryOptionConverter();
  //   }
  //   else if (otype == Contact.sObjecttype) {
  //     cnvr =  new ContactQueryOptionConverter();
  //   }
  //   else if (otype == Lead.sObjecttype) {
  //     cnvr =  new LeadQueryOptionConverter();
  //   }
  //   else {
  //     throw new SB_NC_RegistQueryOptionException('Invalid request');
  //   }
  //   return cnvr.run(qo);
  // }

  // // SB_NC_RegistOptionCreater.QueryOption から SB_NC_RegistQueryOption を作る クラス用の Interface
  // private interface QueryOptionConverter {
  //   SB_NC_RegistQueryOption run(SB_NC_RegistOptionCreater.QueryOption qo);
  // }

  // // アカウント用の SB_NC_RegistOptionCreater.QueryOption から SB_NC_RegistQueryOption を作る クラス
  // private class AccountQueryOptionConverter implements QueryOptionConverter {
  //   public SB_NC_RegistQueryOption run(SB_NC_RegistOptionCreater.QueryOption qo) {
  //     SB_NC_RegistQueryOption result = new SB_NC_RegistQueryOption(Account.sObjecttype);
  //     result.queryCompany = true;
  //     result.queryState = qo.queryState != null ? qo.queryState : false;
  //     result.queryCity = qo.queryCity != null ? qo.queryCity : false;
  //     result.queryStreet = false;
  //     result.queryZip = qo.queryZip != null ? qo.queryZip : false;
  //     result.queryPhone = false;
  //     result.queryDept = qo.querySite != null ? qo.querySite : false;
  //     result.queryUrl = false;
  //     result.queryTitle = false;
  //     result.queryMobile = false;
  //     result.companyRule = CompanyMatcing.PartialMatch;  // 法人格を除いて部分一致
  //     result.deptRule = DeptMatcing.PartialMatch; // 部分一致
  //     if (qo.acntRecTypeIds!=null && !qo.acntRecTypeIds.isEmpty()) {
  //       result.acntRecTypeIds.addAll((List<Id>)qo.acntRecTypeIds);
  //     }
  //     return result;
  //   }
  // }

  // // コンタクト用の SB_NC_RegistOptionCreater.QueryOption から SB_NC_RegistQueryOption を作る クラス
  // private class ContactQueryOptionConverter implements QueryOptionConverter {
  //   public SB_NC_RegistQueryOption run(SB_NC_RegistOptionCreater.QueryOption qo) {
  //     SB_NC_RegistQueryOption result = new SB_NC_RegistQueryOption(Contact.sObjecttype);
  //     result.queryLastName = qo.queryLastName != null ? qo.queryLastName : true;
  //     result.queryFirstName = qo.queryFirstName != null ? qo.queryFirstName : true;
  //     result.queryEMail = qo.queryEMail != null ? qo.queryEMail : true;
  //     if (qo.parentIds != null && !qo.parentIds.isEmpty()) {
  //      result.parentIds.addAll(qo.parentIds);
  //     }
  //     if (qo.contRecTypeIds!= null && !qo.contRecTypeIds.isEmpty()) {
  //       result.contRecTypeIds.addAll((List<Id>)qo.contRecTypeIds);
  //     }
  //     return result;
  //   }
  // }

  // // リード用の SB_NC_RegistOptionCreater.QueryOption から SB_NC_RegistQueryOption を作る クラス
  // private class LeadQueryOptionConverter implements QueryOptionConverter {
  //   public SB_NC_RegistQueryOption run(SB_NC_RegistOptionCreater.QueryOption qo) {
  //     SB_NC_RegistQueryOption result = new SB_NC_RegistQueryOption(Lead.sObjecttype);
  //     result.queryLastName = qo.queryLastName != null ? qo.queryLastName : true;
  //     result.queryFirstName = qo.queryFirstName != null ? qo.queryFirstName : true;
  //     // result.queryLastName = qo.queryPersonName != null ? qo.queryPersonName : true;
  //     // result.queryFirstName = qo.queryPersonName != null ? qo.queryPersonName : true;
  //     result.queryEMail = qo.queryEMail != null ? qo.queryEMail : true;
  //     if (qo.leadRecTypeIds!= null && !qo.leadRecTypeIds.isEmpty()) {
  //      result.leadRecTypeIds.addAll((List<Id>)qo.leadRecTypeIds);
  //     }
  //     return result;
  //   }
  // }

  // 検索対称のレコードタイプを絞るとき
  public void setRectypeIds(Set<Id> ids) {
    if (this.target == Account.sObjectType) {
      this.acntRecTypeIds.clear();
      this.acntRecTypeIds.addAll(ids);
    }
    else if (this.target == Contact.sObjectType) {
      this.contRecTypeIds.clear();
      this.contRecTypeIds.addAll(ids);
    }
    else if (this.target == Lead.sObjectType) {
      this.leadRecTypeIds.clear();
      this.leadRecTypeIds.addAll(ids);
    }
  }

  // コンタクトの検索で、親アカウントを絞って検索するとき
  public void setParentIds(Set<Id> ids) {
    this.parentIds.clear();
    this.parentIds.addAll(ids);
  }

  // public void setAltCompanyField(Schema.SObjectType target) {
  //   this.altCompanyField =  SB_NameCard_BasicSetting.getAltCompanyField(target);
  // }

  // SOQL、SOSLでは法人格を除いた部分一致条件にする。
  public Boolean isCompanyQueryPartial() {
    return this.companyRule != CompanyMatcing.ExactMatch || 
      SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c == true; // （完全一致のとき）会社名の法人格は略称・正称を区別 
  }

  // 会社名を SOQLで 完全一致検索する ?
  //  完全一致検索の指定でも、 法人格の正称・略称を区別する = FALSE の場合は SOQLやSOQLの中間一致検索をする。
  public Boolean isCompanyMatchStrict() {
    return !isCompanyQueryPartial();
  }

  // // 個別で 
  // //  アカウントのクエリで 取引先名は法人格を除いて一致か、取引先名は完全一致（法人格の正称・略称を区別する = FALSE) か
  // //  コンタクトのクエリで 部署も条件 
  // //  → 個別のときに、クエリしたレコードと名刺レコードの内容の照合が必要
  // public Boolean isNeedMatching() { 
  //   return 
  //         // アカウントのクエリで 取引先名は法人格を除いて一致か、取引先名は完全一致（法人格の正称・略称を区別する = FALSE) か
  //         (this.target == Account.getSObjectType() &&
  //         this.companyRule == CompanyMatcing.CorpMatch || 
  //         (this.companyRule == CompanyMatcing.ExactMatch && 
  //           SB_NameCard_BasicSetting.getNameCardBasicSetting().HojinkakuEquationLongAndAbbr__c == true)) || 
  //         // コンタクトのクエリで 部署も条件 
  //         (this.target == Contact.getSObjectType() && this.queryDept); 
      
  // }
  // オプションによって SOSLではなく、SOQLを使うことになる？
  //  isSoqlOption
  //    一括で カスタム設定が SOQL
  //    個別で カスタム設定が SOQL
  //    検索オプションで会社名の比較が Name 以外が指定されてる。 → それでも SOSL
  //    会社名が完全一致検索 で 会社名の法人格は略称・正称を区別 じゃない。=> (NULL か FALSE)でない
  public Boolean isUseSoqlOption() {
    return this.forceSoql || 
      (this.bulkRegist && SB_NameCard_Util.smartViscaConfig.AccountBulkRegistSearchMethod__c == 0) || // 一括で カスタム設定が SOQL
      (!this.bulkRegist && SB_NameCard_Util.smartViscaConfig.AccountRegistSearchMethod__c == 0) || // 個別で カスタム設定が SOQL
      // (String.isNotBlank(this.altCompanyField) && this.altCompanyField != 'Name') ||  // 検索オプションで会社名の比較が Name 以外が指定されてる。 → それでも SOSL
      String.isNotBlank(this.altCompanyField) ||   // Name 以外の項目では SOSL IN ALL FIELDS では ひっかからないので、SOQLにします。
        this.isCompanyMatchStrict(); // 会社名が完全一致 で会社名の法人格は略称・正称を区別 じゃない。=> (NULL か FALSE)でない
  }

}