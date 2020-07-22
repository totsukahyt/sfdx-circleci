/**
 *
 * SB_NameCardL_RegistQueryOption
 *
 *  レコード抽出の条件を保持してる クラス  画面の連携でついか
 *    これから SB_NameCardL_RegistQueryStrategy を作る。
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2018.4.xx
 *
 **/
public virtual class SB_NameCardL_RegistQueryOption {
  public class SB_NameCardL_RegistQueryOptionException extends Exception {}

  //public enum QueryTarget { Account, Contact, Lead }

  public enum CompanyMatcing { FullMatch, CorpMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致
  public enum DeptMatcing { FullMatch, PartialMatch } //完全一致、部分一致

  //public class SB_NameCardL_RegistQueryOption {
  public SObjectType target;
  public Boolean queryState;
  public Boolean queryCity;
  public Boolean queryStreet;
  public Boolean queryZip;
  public Boolean queryPhone;
  public Boolean queryCompany;
  public Boolean queryDept;
  public Boolean queryUrl;
  public Boolean queryLastName;
  public Boolean queryFirstName;
  public Boolean queryEMail;
  public Boolean queryOnlyEMail; // コンタクトのクエリで メアドだけで該当にする。
  public Boolean queryNameOrEMail;    // v2.0.3 ← 基本 v2.4   姓名 か EMail いずれかが一致してればいい
  public Boolean queryTitle;
  public Boolean queryMobile;
  public CompanyMatcing companyRule;  // { FullMatch, CorpMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致
  public DeptMatcing deptRule; // { FullMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致
  public Set<Id> rectypeIds { get; protected set; }  // 検索対称のレコードタイプを絞るとき
  public Set<Id> parentIds { get; protected set; }  // コンタクトの検索で、親アカウントを絞って検索するとき
  public String altCompanyField { get; protected set; }     // アカウント、リードの 会社名 項目を Name や Company 以外の項目として扱う 2018.05.xx for Future Use
  //public Set<String> queryFields { get; protected set; }   // 取得刷る項目

  public SB_NameCardL_RegistQueryOption() {
    this.target = null;
    this.rectypeIds = new Set<Id>();
    this.parentIds = new Set<Id>();
    this.queryState = false;
    this.queryCity = false;
    this.queryStreet = false;
    this.queryZip = false;
    this.queryPhone = false;
    // this.queryCompany = target == Account.sObjecttype ? true : false;
    this.queryCompany = true;
    this.queryDept = false;
    this.queryUrl = false;
    this.queryLastName = true;
    this.queryFirstName = true;
    this.queryEMail = true;
    this.queryOnlyEMail = false;
    this.queryNameOrEMail = false;
    this.queryTitle = false;
    this.queryMobile = false;
    this.companyRule = CompanyMatcing.PartialMatch;  // 法人格を除いて部分一致
    this.deptRule = DeptMatcing.PartialMatch; // 部分一致
    //this.queryFields = new Set<String>();
  }

  public SB_NameCardL_RegistQueryOption(SObjectType target) {
    this.target = target;
    this.rectypeIds = new Set<Id>();
    this.parentIds = new Set<Id>();
    this.queryState = false;
    this.queryCity = false;
    this.queryStreet = false;
    this.queryZip = false;
    this.queryPhone = false;
    // this.queryCompany = target == Account.sObjecttype ? true : false;
    //this.queryCompany = true;
    this.queryCompany = target == Lead.sObjecttype ? false : true;
    this.queryDept = target == Account.sObjecttype ? true : false;
    this.queryUrl = false;
    this.queryLastName = true;
    this.queryFirstName = true;
    this.queryEMail = true;
    this.queryOnlyEMail = target == Contact.sObjecttype ? true : false;
    this.queryNameOrEMail = this.queryOnlyEMail; //
    this.queryTitle = false;
    this.queryMobile = false;
    this.companyRule = CompanyMatcing.PartialMatch;  // 法人格を除いて部分一致
    this.deptRule = DeptMatcing.PartialMatch; // 部分一致
    //this.queryFields = new Set<String>();
  }

  //public SB_NameCardL_RegistQueryOption(SObjectType target, SB_NCL_RegistOptionCreater.QueryOption qo) {
  //  this.target = target;
  //  this.rectypeIds = new Set<Id>();
  //  this.parentIds = new Set<Id>();
  //  this.queryState = qo.queryState != null ? qo.queryState : false;
  //  this.queryCity = qo.queryCity != null ? qo.queryCity : false;
  //  this.queryStreet = false;
  //  this.queryZip = qo.queryZip != null ? qo.queryZip : false;
  //  this.queryPhone = false;
  //  // this.queryCompany = target == Account.sObjecttype ? true : qo.queryCompany != null ? qo.queryCompany : false;
  //  this.queryCompany = target == Lead.sObjecttype ? false : true;
  //  this.queryDept = qo.querySite != null ? qo.querySite : false;
  //  this.queryUrl = false;
  //  this.queryLastName = target == Lead.sObjecttype  && qo.queryPersonName != null ? qo.queryPersonName : true;
  //  this.queryFirstName = target == Lead.sObjecttype && qo.queryPersonName != null ? qo.queryPersonName : true;
  //  this.queryEMail = target == Lead.sObjecttype && qo.queryPersonEMail != null ? qo.queryPersonEMail : true;
  //  this.queryTitle = false;
  //  this.queryMobile = false;
  //  this.companyRule = CompanyMatcing.PartialMatch;  // 法人格を除いて部分一致
  //  this.deptRule = DeptMatcing.PartialMatch; // 部分一致
  //}


  // @RemoteAction 経由の QueryOption から SB_NameCardL_RegistQueryOption を作るメソッド
  public static SB_NameCardL_RegistQueryOption convertQueryOption(SObjectType otype, SB_NCL_RegistOptionCreater.QueryOption qo) {
    QueryOptionConverter cnvr;
    if (otype == Account.sObjecttype) {
      cnvr =  new AccountQueryOptionConverter();
    }
    else if (otype == Contact.sObjecttype) {
      cnvr =  new ContactQueryOptionConverter();
    }
    else if (otype == Lead.sObjecttype) {
      cnvr =  new LeadQueryOptionConverter();
    }
    else {
      throw new SB_NameCardL_RegistQueryOptionException('Invalid request');
    }
    return cnvr.run(qo);
  }

  // SB_NCL_RegistOptionCreater.QueryOption から SB_NameCardL_RegistQueryOption を作る クラス用の Interface
  private interface QueryOptionConverter {
    SB_NameCardL_RegistQueryOption run(SB_NCL_RegistOptionCreater.QueryOption qo);
  }

  // アカウント用の SB_NCL_RegistOptionCreater.QueryOption から SB_NameCardL_RegistQueryOption を作る クラス
  private class AccountQueryOptionConverter implements QueryOptionConverter {
    public SB_NameCardL_RegistQueryOption run(SB_NCL_RegistOptionCreater.QueryOption qo) {
      SB_NameCardL_RegistQueryOption result = new SB_NameCardL_RegistQueryOption(Account.sObjecttype);
      result.queryCompany = true;
      result.queryState = qo.queryState != null ? qo.queryState : false;
      result.queryCity = qo.queryCity != null ? qo.queryCity : false;
      result.queryStreet = false;
      result.queryZip = qo.queryZip != null ? qo.queryZip : false;
      result.queryPhone = false;
      result.queryDept = qo.querySite != null ? qo.querySite : false;
      result.queryUrl = false;
      result.queryTitle = false;
      result.queryMobile = false;
      result.companyRule = CompanyMatcing.PartialMatch;  // 法人格を除いて部分一致
      result.deptRule = DeptMatcing.PartialMatch; // 部分一致
      if (qo.acntRecTypeIds!=null && !qo.acntRecTypeIds.isEmpty()) {
        result.rectypeIds.addAll((List<Id>)qo.acntRecTypeIds);
      }
      return result;
    }
  }

  // コンタクト用の SB_NCL_RegistOptionCreater.QueryOption から SB_NameCardL_RegistQueryOption を作る クラス
  private class ContactQueryOptionConverter implements QueryOptionConverter {
    public SB_NameCardL_RegistQueryOption run(SB_NCL_RegistOptionCreater.QueryOption qo) {
      SB_NameCardL_RegistQueryOption result = new SB_NameCardL_RegistQueryOption(Contact.sObjecttype);
      result.queryLastName = qo.queryPersonName != null ? qo.queryPersonName : true;
      result.queryFirstName = qo.queryPersonName != null ? qo.queryPersonName : true;
      result.queryEMail = qo.queryPersonEMail != null ? qo.queryPersonEMail : true;
      if (qo.parentIds != null && !qo.parentIds.isEmpty()) {
        result.parentIds.addAll(qo.parentIds);
      }
      if (qo.contRecTypeIds!= null && !qo.contRecTypeIds.isEmpty()) {
        result.rectypeIds.addAll((List<Id>)qo.contRecTypeIds);
      }
      return result;
    }
  }

  // リード用の SB_NCL_RegistOptionCreater.QueryOption から SB_NameCardL_RegistQueryOption を作る クラス
  private class LeadQueryOptionConverter implements QueryOptionConverter {
    public SB_NameCardL_RegistQueryOption run(SB_NCL_RegistOptionCreater.QueryOption qo) {
      SB_NameCardL_RegistQueryOption result = new SB_NameCardL_RegistQueryOption(Lead.sObjecttype);
      result.queryLastName = qo.queryPersonName != null ? qo.queryPersonName : true;
      result.queryFirstName = qo.queryPersonName != null ? qo.queryPersonName : true;
      result.queryEMail = qo.queryPersonEMail != null ? qo.queryPersonEMail : true;
      if (qo.leadRecTypeIds!= null && !qo.leadRecTypeIds.isEmpty()) {
        result.rectypeIds.addAll((List<Id>)qo.leadRecTypeIds);
      }
      return result;
    }
  }

  // 検索対称のレコードタイプを絞るとき
  public void setRectypeIds(Set<Id> ids) {
    this.rectypeIds.clear();
    this.rectypeIds.addAll(ids);
  }

  // コンタクトの検索で、親アカウントを絞って検索するとき
  public void setParentIds(Set<Id> ids) {
    this.parentIds.clear();
    this.parentIds.addAll(ids);
  }

  public void setAltCompanyField(String f) {
    this.altCompanyField = f;
  }

}