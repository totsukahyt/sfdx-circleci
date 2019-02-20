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
  public Boolean queryTitle;
  public Boolean queryMobile;
  public CompanyMatcing companyRule;  // { FullMatch, CorpMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致
  public DeptMatcing deptRule; // { FullMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致
  public Set<Id> rectypeIds { get; protected set; }  // 検索対称のレコードタイプを絞るとき
  public Set<Id> parentIds { get; protected set; }  // コンタクトの検索で、親アカウントを絞って検索するとき
  public String altCompanyField { get; protected set; }     // アカウント、リードの 会社名 項目を Name や Company 以外の項目として扱う 2018.05.xx for Future Use

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
    this.queryDept = target == Account.sObjecttype ? true : false;
    this.queryUrl = false;
    this.queryLastName = true;
    this.queryFirstName = true;
    this.queryEMail = true;
    this.queryTitle = false;
    this.queryMobile = false;
    this.companyRule = CompanyMatcing.PartialMatch;  // 法人格を除いて部分一致
    this.deptRule = DeptMatcing.PartialMatch; // 部分一致
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
    this.queryCompany = true;
    this.queryDept = target == Account.sObjecttype ? true : false;
    this.queryUrl = false;
    this.queryLastName = true;
    this.queryFirstName = true;
    this.queryEMail = true;
    this.queryTitle = false;
    this.queryMobile = false;
    this.companyRule = CompanyMatcing.PartialMatch;  // 法人格を除いて部分一致
    this.deptRule = DeptMatcing.PartialMatch; // 部分一致
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