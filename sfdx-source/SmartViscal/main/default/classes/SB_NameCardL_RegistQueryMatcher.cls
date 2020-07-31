/**
 *
 * SB_NameCardL_RegistQueryMatcher
 *
 *  レコードをクエリしたあと、名刺に該当するアカウント、コンタクト、リードか、項目ごとに調べるクラス
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2018.4.xx
 *
 * @Version 2.1 全 2020.07.31 PRODUCT-352 【自動連携】リードの自動連携で電話番号2を使用しないようにする 
 * @Version 2.1 全 2020.07.31 PRODUCT-365 【自動連携】リード連携拡張：自動連携でURL2を使用しないようにする
 * 
 **/
public with sharing class SB_NameCardL_RegistQueryMatcher {

  // // 検索オプション
  // public enum CompanyMatcing { FullMatch, CorpMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致
  // public enum DeptMatcing { FullMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致

  // 郵便番号の一致チェック
  private static Boolean isMatchZip(SmartViscaf__NameCard__c card, List<String> zips) {
    if (String.isBlank(card.SmartViscaf__zip_code__c)) {
      // 名刺の郵便番号が なし
      for (String zip : zips) {
        if (String.isBlank(zip)) {
          return true;  // いずれかが空白
        }
      }
    }
    else {
      // 名刺の郵便番号が あり
      String c = card.SmartViscaf__zip_code__c.replaceAll('-', '');
      for (String zip : zips) {
        if (String.isNotBlank(zip)) {
          String a = zip.replaceAll('-', '');
          if (a==c) {
            return true;
          }
        }
      }
    }
    return false;
  }

  //　URL の一致確認
  private static Boolean isMatchUrl(SmartViscaf__NameCard__c card, String website) {
    if (String.isBlank(website) && String.isBlank(card.SmartViscaf__web_url1__c)) {
      return true;
    }
    if (String.isNotBlank(website)) {
      String a = website.toLowerCase().replaceAll('https://|http://|/', '');
      if (String.isNotBlank(card.SmartViscaf__web_url1__c)) {
        String c = card.SmartViscaf__web_url1__c.toLowerCase().replaceAll('https://|http://|/', '');
        if ((a.length() >= c.length() && a.startsWith(c)) || (a.length() < c.length() && c.startsWith(a))) {
          return true;
        }
      }
      // PRODUCT-365
      // if (String.isNotBlank(card.SmartViscaf__web_url2__c)) {
      //   String c = card.SmartViscaf__web_url2__c.toLowerCase().replaceAll('https://|http://|/', '');
      //   if ((a.length() >= c.length() && a.startsWith(c)) || (a.length() < c.length() && c.startsWith(a))) {
      //     return true;
      //   }
      // }
    }
    return false;
  }

  //　電話番号 の一致確認
  private static Boolean isMatchPhone(SmartViscaf__NameCard__c card, String phone) {
    if (String.isBlank(phone) && String.isBlank(card.SmartViscaf__tel1__c)) {
      return true;
    }
    if (String.isNotBlank(phone)) {
      String a = phone.toLowerCase().replaceAll('[()-]+', '');
      if (String.isNotBlank(card.SmartViscaf__tel1__c)) {
        String c = card.SmartViscaf__tel1__c.replaceAll('[()-]+', '');
        if (a == c) {
          return true;
        }
      }
      // PRODUCT-352
      // if (String.isNotBlank(card.SmartViscaf__tel2__c)) {
      //   String c = card.SmartViscaf__tel2__c.replaceAll('[()-]+', '');
      //   if (a == c) {
      //     return true;
      //   }
      // }
    }
    return false;
  }

  // 町名番地  の一致確認  street は 町名・番地 建物なし
  private static Boolean isMatchStreet(String street, List<String> streets) {
    if (String.isBlank(street)) {
      for (String st : streets) {
        if (String.isBlank(street)) {
          return true;
        }
      }
    }
    else {
      for (String st : streets) {
        if (String.isNotBlank(st) && st.toLowerCase().startsWith(street.toLowerCase())) {
          // 前方一致でOK
          return true;
        }
      }
    }
    return false;
  }

  // 部署の一致のチェック
  private static Boolean isMatchSite(SmartViscaf__NameCard__c card, String dept, SB_NameCardL_RegistQueryOption.DeptMatcing rule) {
    if (card.SmartViscaf__division__c == dept) {
      return true;
    }
    if (rule == SB_NameCardL_RegistQueryOption.DeptMatcing.PartialMatch && String.isNotBlank(dept) && String.isNotBlank(card.SmartViscaf__division__c)) {
      // 中間一致
      return SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(dept, SB_NameCard_MojiWidthUtil.toHalfWidth(card.SmartViscaf__division__c));
    }
    return false;
  }

  //　会社名の一致のチェック
  @TestVisible
  private static Boolean isMatchKaishaMei(SmartViscaf__NameCard__c card, String company, SB_NameCardL_RegistQueryOption.CompanyMatcing rule) {
    if (card.SmartViscaf__company_name__c == company) {
      return true;
    }
    if (String.isNotBlank(company) && String.isNotBlank(card.SmartViscaf__company_name__c)) {
      String shamei = SmartViscaf.SB_NameCard_Util.getCompanyName(card.SmartViscaf__company_name__c);
      if (rule == SB_NameCardL_RegistQueryOption.CompanyMatcing.PartialMatch) {
        // 法人格抜きで、中間一致
        return SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(company, SB_NameCard_MojiWidthUtil.toHalfWidth(shamei));
      }
      else if (rule == SB_NameCardL_RegistQueryOption.CompanyMatcing.CorpMatch) {
        // 法人格抜きで、完全一致
        String acntShamei = SmartViscaf.SB_NameCard_Util.getCompanyName(company);
        return shamei == acntShamei;
      }
    }
    return false;
  }


  ////////////////////////////////
  // 名刺の特定の項目と 対象レコードの特定の項目を比べる クラス
  //  任意の項目用のみ。。
  ////////////////////////////////
  public class FieldComparator {
    private String ncField { get; private set; }    // 名刺の項目
    private String targetField { get; private set; }   // それを比較する アカウントとか 抽出対象のオブジェクトの項目API名
    public FieldComparator(String ncField, String targetField) {
      //this.use = SpecificItems_Valid__c;
      // this.ncField = 'SmartViscaf__memo__c';     // 名刺の項目 メモ
      this.ncField = ncField;
      this.targetField = targetField;
    }
    // 名刺メモとアカウントの指定項目との一致のチェック
    public Boolean isMatch(SmartViscaf__NameCard__c card, SObject target) {
      String src = (String)card.get(this.ncField);
      String dest = (String)target.get(this.targetField);
      return src == dest;
    }
  }

  //private static List<FieldComparator> createFieldComparators(SmartViscaf__NameCardBasicSetting__c setting) {
  //  List<FieldComparator> result = new List<FieldComparator>();
  //  if (String.isNotBlank(setting.SmartViscaf__RenkeiSpecificItems__c)) {
  //    result.add(new FieldComparator('SmartViscaf__memo__c', setting.SmartViscaf__RenkeiSpecificItems__c));
  //  }
  //  return result;
  //}

  //////////////////
  // Matcher
  //////////////////

  public abstract class Matcher {
    private List<FieldComparator> fcomps;     // 名刺 特定の項目と 対象レコードの特定の項目を比べる クラスのインスタンスの リスト

    public abstract Boolean isMatch(SmartViscaf__NameCard__c card, SObject dest);
    // fcomps を作る。
    public void setExtensionFields(Map<String, String> card2target) {
      this.fcomps = new List<FieldComparator>();
      for (String key : card2target.keySet()) {
        String target = card2target.get(key);
        this.fcomps.add(new FieldComparator(key, target));
      }
    }
  }

  /////////////////
  // AccountMatcher
  /////////////////
  public class AccountMatcher extends Matcher {
    private Boolean queryZip;
    private Boolean queryUrl;
    private Boolean queryPhone;
    private Boolean queryStreet;
    private Boolean queryCity;
    private Boolean queryState;
    private Boolean queryDept;
    private SB_NameCardL_RegistQueryOption.CompanyMatcing companyRule;
    private SB_NameCardL_RegistQueryOption.DeptMatcing deptRule;
    private String altCompanyField;    // アカウント、リードの 会社名 項目を Name や Company 以外の項目として扱う
    //     // (this.extention == null || !this.extention.use || isMatchExtension(card, acnt)) &&
    //     // (!this.queryZip || isMatchZip(card, new List<String> { acnt.BillingPostalCode, acnt.ShippingPostalCode })) &&
    //     // (!this.queryUrl || isMatchUrl(card, acnt.WebSite)) &&
    //     // (!this.queryPhone || isMatchPhone(card, acnt.Phone)) &&
    //     // (!this.queryStreet || isMatchStreet(street_nobld, new List<String> { acnt.BillingStreet, acnt.ShippingStreet })) &&
    //     // (!this.queryCity || city == acnt.BillingCity || city == acnt.ShippingCity) &&
    //     // (!this.queryState || card.SmartViscaf__address_pref__c == acnt.BillingState || card.SmartViscaf__address_pref__c == acnt.ShippingState) &&
    //     // (!this.queryDept || isMatchSite(card, acnt.Site)) &&      // containsだと 全角、半角を区別するので、区別しないように

    //public AccountMatcher(SB_NameCardL_RegistQueryStrategy.AccountQueryStrategy qs, SmartViscaf__NameCardBasicSetting__c setting) {
    //  this.queryZip = qs.queryZip;
    //  this.queryUrl = qs.queryUrl;
    //  this.queryPhone = qs.queryPhone;
    //  this.queryStreet = qs.queryStreet;
    //  this.queryCity = qs.queryCity;
    //  this.queryState = qs.queryState;
    //  this.queryDept = qs.queryDept;
    //  this.companyRule = qs.companyRule;
    //  this.deptRule = qs.deptRule;
    //  this.fcomps = createFieldComparators(setting);
    //  this.altCompanyField = qs.altCompanyField;
    //  // this.queryZip = qs.queryZip;
    //}

    public AccountMatcher(SB_NameCardL_RegistQueryStrategy.AccountQueryStrategy qs) {
      this.queryZip = qs.queryZip;
      this.queryUrl = qs.queryUrl;
      this.queryPhone = qs.queryPhone;
      this.queryStreet = qs.queryStreet;
      this.queryCity = qs.queryCity;
      this.queryState = qs.queryState;
      this.queryDept = qs.queryDept;
      this.companyRule = qs.companyRule;
      this.deptRule = qs.deptRule;
      this.fcomps = null;
      this.altCompanyField = qs.altCompanyField;
      // this.queryZip = qs.queryZip;
    }

    private Boolean isMatchExtensions(SmartViscaf__NameCard__c card, SObject target) {
      for (FieldComparator fcomp : this.fcomps) {
        if (!fcomp.isMatch(card, target)) {
          return false;
        }
      }
      return true;
    }

    public override Boolean isMatch(SmartViscaf__NameCard__c card, SObject target) {
      System.assert(target.getSObjectType() == Account.sObjectType);
      Account acnt = (Account)target;
      String city = '';
      String street = '';
      String street_nobld = '';
      if (this.queryCity || this.queryStreet) {
        Map<String, String> addrs = SmartViscaf.SB_NameCard_Util.getAddress(card);
        city = addrs.get('city');
        street = addrs.get('street');
        street_nobld = addrs.get('street_nobld');
      }
      String companyName; //　会社名
      if (String.isNotBlank(this.altCompanyField)) {
        // 　会社名 は Name じゃない設定
        companyName = (String)acnt.get(this.altCompanyField);
      }
      else {
        companyName = acnt.Name;
      }
      return
        acnt.Id == card.SmartViscaf__account__c ||
        (this.fcomps ==null || this.fcomps.isEmpty() || isMatchExtensions(card, acnt)) &&
        (card.SmartViscaf__company_name__c == companyName || isMatchKaishaMei(card, companyName, this.companyRule)) &&
        (!this.queryZip || isMatchZip(card, new List<String> { acnt.BillingPostalCode, acnt.ShippingPostalCode })) &&
        (!this.queryUrl || isMatchUrl(card, acnt.WebSite)) &&
        (!this.queryPhone || isMatchPhone(card, acnt.Phone)) &&
        (!this.queryStreet || isMatchStreet(street_nobld, new List<String> { acnt.BillingStreet, acnt.ShippingStreet })) &&
        (!this.queryCity || city == acnt.BillingCity || city == acnt.ShippingCity) &&
        (!this.queryState || card.SmartViscaf__address_pref__c == acnt.BillingState || card.SmartViscaf__address_pref__c == acnt.ShippingState) &&
        (!this.queryDept || isMatchSite(card, acnt.Site, this.deptRule));      // containsだと 全角、半角を区別するので、区別しないように
    }

  } // public class AccountMatcher extends Matcher {

  ////////////////
  //  ContactMatcher
  ////////////////
  public class ContactMatcher extends Matcher {
    @TestVisible private Boolean queryOnlyEMail;     // v2.0.3 2020.02.xx
    @TestVisible private Boolean queryEmail;
    @TestVisible private Boolean queryFirstName;
    @TestVisible private Boolean queryLastName;
    @TestVisible private Boolean queryCompany;
    @TestVisible private Boolean queryDept;
    @TestVisible private Boolean queryNameOrEMail;   // v2.0.3 2020.02.xx
    @TestVisible private SB_NameCardL_RegistQueryOption.CompanyMatcing companyRule;
    @TestVisible private SB_NameCardL_RegistQueryOption.DeptMatcing deptRule;

    public ContactMatcher() {
      this.companyRule = SB_NameCardL_RegistQueryOption.CompanyMatcing.FullMatch;
      this.deptRule = SB_NameCardL_RegistQueryOption.DeptMatcing.FullMatch;
    }

    public ContactMatcher(SB_NameCardL_RegistQueryStrategy.ContactQueryStrategy qs) {
      this.queryEmail = qs.queryEmail;
      this.queryFirstName = qs.queryFirstName;
      this.queryLastName = qs.queryLastName;
      this.queryCompany = qs.queryCompany;
      this.queryDept = qs.queryDept;
      this.companyRule = qs.companyRule;
      this.deptRule = qs.deptRule;
      this.queryOnlyEMail = qs.queryOnlyEMail;  // v2.0.3 2020.02.xx
      this.queryNameOrEMail = qs.queryNameOrEMail;   // v2.0.3 2020.02.xx
    }

    public override Boolean isMatch(SmartViscaf__NameCard__c card, SObject target) {
      System.assert(target.getSObjectType() == Contact.sObjectType);
      Contact cont = (Contact)target;
      Map<String, String> pnMap = SmartViscaf.SB_NameCard_Util.getPersonName(card);
      String last_name = pnMap.get('last_name');
      String first_name = pnMap.get('first_name');
      return
        cont.Id == card.SmartViscaf__contact__c ||
        // 2020.02.xx v2.0.3 SV_DEV-2527 リード拡張の自動連携で取引先責任者について、不適切なレコードを更新する。または、作成されるべき新規取引先責任者レコードが作成されない。
        (this.queryOnlyEMail && (card.SmartViscaf__email__c!=null && card.SmartViscaf__email__c == cont.Email)) ||
        (((this.queryNameOrEMail &&    // 姓名 OR EMail どちらか一致 で
          (((!this.queryFirstName || first_name == cont.FirstName) && (!this.queryLastName || last_name == cont.LastName)) ||
          (!this.queryEmail || (card.SmartViscaf__email__c!=null && card.SmartViscaf__email__c == cont.Email)))) ||
        ((!this.queryEmail || (card.SmartViscaf__email__c!=null && card.SmartViscaf__email__c == cont.Email)) &&
        (!this.queryFirstName || first_name == cont.FirstName) &&
        (!this.queryLastName || last_name == cont.LastName))) &&
        (!this.queryCompany || isMatchKaishaMei(card, cont.Account.Name, this.companyRule)) &&
        (!this.queryDept || isMatchSite(card, cont.Account.Site, this.deptRule) || isMatchSite(card, cont.Department, this.deptRule)));
    }

  } // public class ContactMatcher extends Matcher {

  ////////////////
  //  LeadMatcher
  ////////////////
  public class LeadMatcher extends Matcher {
    private Boolean queryCompany;
    private SB_NameCardL_RegistQueryOption.CompanyMatcing companyRule;
    private Boolean queryEmail;
    private Boolean queryFirstName;
    private Boolean queryLastName;
    private Boolean queryZip;
    private Boolean queryUrl;
    private Boolean queryPhone;
    private Boolean queryStreet;
    private Boolean queryCity;
    private Boolean queryState;
    private String altCompanyField;    // アカウント、リードの 会社名 項目を Name や Company 以外の項目として扱う

    public LeadMatcher(SB_NameCardL_RegistQueryStrategy.LeadQueryStrategy qs) {
      this.queryCompany = qs.queryCompany;
      this.companyRule = qs.companyRule;
      this.queryEmail = qs.queryEmail;
      this.queryFirstName = qs.queryFirstName;
      this.queryLastName = qs.queryLastName;
      this.queryZip = qs.queryZip;
      this.queryUrl = qs.queryUrl;
      this.queryPhone = qs.queryPhone;
      this.queryStreet = qs.queryStreet;
      this.queryCity = qs.queryCity;
      this.queryState = qs.queryState;
    }

    public override Boolean isMatch(SmartViscaf__NameCard__c card, SObject target) {
      Lead l = (Lead) target;
      String city = '';
      String street = '';
      String street_nobld = '';
      if (this.queryCity || this.queryStreet) {
        Map<String, String> addrs = SmartViscaf.SB_NameCard_Util.getAddress(card);
        city = addrs.get('city');
        street = addrs.get('street');
        street_nobld = addrs.get('street_nobld');
      }
      String companyName; //　会社名
      if (String.isNotBlank(this.altCompanyField)) {
        // 　会社名 は Name じゃない設定
        companyName = (String)l.get(this.altCompanyField);
      }
      else {
        companyName = l.Company;
      }
      Map<String, String> pnMap = SmartViscaf.SB_NameCard_Util.getPersonName(card);
      String last_name = pnMap.get('last_name');
      String first_name = pnMap.get('first_name');
      return
        l.Id == card.SmartViscaf__lead__c ||
        (!this.queryEmail || (card.SmartViscaf__email__c != null && card.SmartViscaf__email__c == l.Email)) &&
        ((!this.queryFirstName || first_name == l.FirstName) &&
        (!this.queryLastName || last_name == l.LastName) &&
        (!this.queryZip || isMatchZip(card, new List<String> { l.PostalCode })) &&
        (!this.queryUrl || isMatchUrl(card, l.WebSite)) &&
        (!this.queryPhone || isMatchPhone(card, l.Phone)) &&
        (!this.queryStreet || isMatchStreet(street_nobld, new List<String> { l.Street })) &&
        (!this.queryCity || city == l.City) &&
        (!this.queryState || card.SmartViscaf__address_pref__c == l.State) &&
        (!this.queryCompany || card.SmartViscaf__company_name__c == companyName || isMatchKaishaMei(card, companyName, this.companyRule)));
      }
  } // public class LeadMatcher extends Matcher {

}