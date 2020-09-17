/**
 *
 * SB_NC_RegistQueryMatcher
 *
 *  レコードをクエリしたあと、名刺に該当するアカウント、コンタクトか、項目ごとに調べるクラス
  *
 * (c) 2019 Sunbridge Inc.
 *
 *  @author K.Yoshida
 *  @Version 2.2  2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 *  @Version 2.7  2020.09.08 ohno   PRODUCT-696 取引先登録 個別・一括 メールアドレスが空白値で一致して登録先候補が表示されてしまう。（姓・名が異なるレコードが表示される）
 **/
public with sharing class SB_NC_RegistQueryMatcher {

  // // 検索オプション
  // public enum CompanyMatcing { ExactMatch, CorpMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致
  // public enum DeptMatcing { ExactMatch, PartialMatch } // 法人格含み完全一致、法人格を除いて一致、法人格を除いて部分一致

  // 郵便番号の一致チェック
  private static Boolean isMatchZip(NameCard__c card, List<String> zips) {
    if (String.isBlank(card.zip_code__c)) {
      // 名刺の郵便番号が なし
      for (String zip : zips) {
        if (String.isBlank(zip)) {
          return true;  // いずれかが空白
        }
      }
    }
    else {
      // 名刺の郵便番号が あり
      String c = card.zip_code__c.replaceAll('-', '');
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
  private static Boolean isMatchUrl(NameCard__c card, String website) {
    if (String.isBlank(website) && String.isBlank(card.web_url1__c)) {
      return true;
    }
    if (String.isNotBlank(website)) {
      String a = website.toLowerCase().replaceAll('https://|http://|/', '');
      if (String.isNotBlank(card.web_url1__c)) {
        String c = card.web_url1__c.toLowerCase().replaceAll('https://|http://|/', '');
        if ((a.length() >= c.length() && a.startsWith(c)) || (a.length() < c.length() && c.startsWith(a))) {
          return true;
        }
      }
      if (String.isNotBlank(card.web_url2__c)) {
        String c = card.web_url2__c.toLowerCase().replaceAll('https://|http://|/', '');
        if ((a.length() >= c.length() && a.startsWith(c)) || (a.length() < c.length() && c.startsWith(a))) {
          return true;
        }
      }
    }
    return false;
  }

  //　電話番号 の一致確認
  private static Boolean isMatchPhone(NameCard__c card, String phone) {
    if (String.isBlank(phone) && String.isBlank(card.tel1__c)) {
      return true;
    }
    if (String.isNotBlank(phone)) {
      String a = phone.toLowerCase().replaceAll('[()-]+', '');
      if (String.isNotBlank(card.tel1__c)) {
        String c = card.tel1__c.replaceAll('[()-]+', '');
        if (a == c) {
          return true;
        }
      }
      if (String.isNotBlank(card.tel2__c)) {
        String c = card.tel2__c.replaceAll('[()-]+', '');
        if (a == c) {
          return true;
        }
      }
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
  private static Boolean isMatchSite(NameCard__c card, String dept, SB_NC_RegistQueryOption.DeptMatcing rule) {
    if (card.division__c == dept) {
      return true;
    }
    if (rule == SB_NC_RegistQueryOption.DeptMatcing.PartialMatch && String.isNotBlank(dept) && String.isNotBlank(card.division__c)) {
      // 部分一致
      return SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(dept, SB_NameCard_MojiWidthUtil.toHalfWidth(card.division__c));
    }
    return false;
  }

  //　会社名の一致のチェック
  @TestVisible
  private static Boolean isMatchKaishaMei(NameCard__c card, String company, SB_NC_RegistQueryOption.CompanyMatcing rule) {
    if (card.company_name__c == company) {
      return true;
    }
    NameCardBasicSetting__c setting = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    if (String.isNotBlank(company) && String.isNotBlank(card.company_name__c)) {
      String shamei = SB_NameCard_Util.getCompanyName(card.company_name__c);
      if (rule == SB_NC_RegistQueryOption.CompanyMatcing.PartialMatch) {
        // 法人格抜きで、部分一致
        return SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(company, SB_NameCard_MojiWidthUtil.toHalfWidth(shamei));
      }
      else if (rule == SB_NC_RegistQueryOption.CompanyMatcing.CorpMatch) {
        // 法人格抜きで、完全一致
        String acntShamei = SB_NameCard_Util.getCompanyName(company);
        return shamei == acntShamei;
      }
      // 完全一致
      else if (setting.HojinkakuEquationLongAndAbbr__c == true) { // （完全一致のとき）法人格は略称・正称を同一視する。 null は false
        // SV_DEV-1647 法人格の正式名称と略称をマッチさせる（登録・自動連携）
        return SB_NameCard_HojinkakuParser.isEqualeKaishamei(card.company_name__c, company);
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
      // this.ncField = 'memo__c';     // 名刺の項目 メモ
      this.ncField = ncField;
      this.targetField = targetField;
    }
    // 名刺メモとアカウントの指定項目との一致のチェック
    public Boolean isMatch(NameCard__c card, SObject target) {
      String src = (String)card.get(this.ncField);
      String dest = (String)target.get(this.targetField);
      return src == dest;
    }
  }

  //private static List<FieldComparator> createFieldComparators(NameCardBasicSetting__c setting) {
  //  List<FieldComparator> result = new List<FieldComparator>();
  //  if (String.isNotBlank(setting.RenkeiSpecificItems__c)) {
  //    result.add(new FieldComparator('memo__c', setting.RenkeiSpecificItems__c));
  //  }
  //  return result;
  //}

  //////////////////
  // Matcher
  //////////////////

  public abstract class Matcher {
    private List<FieldComparator> fcomps;     // 名刺 特定の項目と 対象レコードの特定の項目を比べる クラスのインスタンスの リスト
    protected Boolean queryCompany;
    protected SB_NC_RegistQueryOption.CompanyMatcing companyRule;
    protected String altCompanyField;    // アカウント、リードの 会社名 項目を Name や Company 以外の項目として扱う コンタクトではアカウントの会社名を照合するときも使う
    protected Boolean queryDept;
    protected SB_NC_RegistQueryOption.DeptMatcing deptRule;

    public abstract Boolean isMatch(NameCard__c card, SObject dest);
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

    public AccountMatcher(SB_NC_RegistQueryStrategy.AccountQueryStrategy qs) {
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

    private Boolean isMatchExtensions(NameCard__c card, SObject target) {
      for (FieldComparator fcomp : this.fcomps) {
        if (!fcomp.isMatch(card, target)) {
          return false;
        }
      }
      return true;
    }
    // Account
    public override Boolean isMatch(NameCard__c card, SObject target) {
      System.assert(target.getSObjectType() == Account.sObjectType);
      Account acnt = (Account)target;
      String city = '';
      String street = '';
      String street_nobld = '';
      if (this.queryCity || this.queryStreet) {
        Map<String, String> addrs = SB_NameCard_Util.getAddress(card);
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
        acnt.Id == card.account__c ||
        (this.fcomps ==null || this.fcomps.isEmpty() || isMatchExtensions(card, acnt)) &&
        (card.company_name__c == companyName || isMatchKaishaMei(card, companyName, this.companyRule)) &&
        (!this.queryZip || isMatchZip(card, new List<String> { acnt.BillingPostalCode, acnt.ShippingPostalCode })) &&
        (!this.queryUrl || isMatchUrl(card, acnt.WebSite)) &&
        (!this.queryPhone || isMatchPhone(card, acnt.Phone)) &&
        (!this.queryStreet || isMatchStreet(street_nobld, new List<String> { acnt.BillingStreet, acnt.ShippingStreet })) &&
        (!this.queryCity || city == acnt.BillingCity || city == acnt.ShippingCity) &&
        (!this.queryState || card.address_pref__c == acnt.BillingState || card.address_pref__c == acnt.ShippingState) &&
        (!this.queryDept || isMatchSite(card, acnt.Site, this.deptRule));      // containsだと 全角、半角を区別するので、区別しないように
    }

  } // public class AccountMatcher extends Matcher {

  ////////////////
  //  ContactMatcher
  ////////////////
  public class ContactMatcher extends Matcher {
    private Boolean queryOnlyEMail;
    private Boolean queryEmail;
    private Boolean queryFirstName;
    private Boolean queryLastName;
    private Boolean queryNameOrEMail;

    public ContactMatcher(SB_NC_RegistQueryStrategy.ContactQueryStrategy qs) {
      this.queryOnlyEMail = qs.queryOnlyEMail;
      this.queryEmail = qs.queryEmail;
      this.queryFirstName = qs.queryFirstName;
      this.queryLastName = qs.queryLastName;
      this.queryNameOrEMail = qs.queryNameOrEMail;
      this.queryCompany = qs.queryCompany;
      this.queryDept = qs.queryDept;
      this.companyRule = qs.companyRule;
      this.altCompanyField = qs.altCompanyField;
      this.deptRule = qs.deptRule;
    }
    // Contact
    public override Boolean isMatch(NameCard__c card, SObject target) {
      System.assert(target.getSObjectType() == Contact.sObjectType);
      Contact cont = (Contact)target;
      Map<String, String> pnMap = SB_NameCard_Util.getPersonName(card);
      String last_name = pnMap.get('last_name');
      String first_name = pnMap.get('first_name');
      String companyName; //　会社名
      if (String.isNotBlank(this.altCompanyField)) {
        // 会社名 は Name じゃない設定 v.2.4
        companyName = (String)cont.getSObject('Account').get(this.altCompanyField);
      }
      else {
        companyName = cont.Account.Name;
      }
      return
        cont.Id == card.contact__c ||
        (this.queryOnlyEmail && (card.email__c!=null && card.email__c == cont.Email)) || // Emailだけ一致でOK
        ((this.queryNameOrEMail &&    // 姓名 OR EMail どちらか一致 で
          ((!this.queryFirstName || first_name == cont.FirstName) &&
          (!this.queryLastName || last_name == cont.LastName)) ||
          (!this.queryEmail || (card.email__c!=null && card.email__c == cont.Email))) ||  
          // (!this.queryEmail || (card.email__c == cont.Email))) ||  
        ((!this.queryFirstName || first_name == cont.FirstName) &&  // 姓名 AND EMail 一致
        (!this.queryLastName || last_name == cont.LastName) &&
        (!this.queryEmail || (card.email__c!=null && card.email__c == cont.Email)))) &&   
        // (!this.queryEmail || (card.email__c == cont.Email)))) &&   
        (!this.queryCompany || isMatchKaishaMei(card, companyName, this.companyRule)) &&  // 会社名一致で
        (!this.queryDept || isMatchSite(card, cont.Account.Site, this.deptRule) || isMatchSite(card, cont.Department, this.deptRule)); // 部署名一致
    }

  } // public class ContactMatcher extends Matcher {

  ////////////////
  //  LeadMatcher
  ////////////////
  public class LeadMatcher extends Matcher {
    private Boolean queryEmail;
    private Boolean queryFirstName;
    private Boolean queryLastName;
    private Boolean queryZip;
    private Boolean queryUrl;
    private Boolean queryPhone;
    private Boolean queryStreet;
    private Boolean queryCity;
    private Boolean queryState;
    // Lead
    public override Boolean isMatch(NameCard__c card, SObject target) {
      Lead l = (Lead) target;
      String city = '';
      String street = '';
      String street_nobld = '';
      if (this.queryCity || this.queryStreet) {
        Map<String, String> addrs = SB_NameCard_Util.getAddress(card);
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
      Map<String, String> pnMap = SB_NameCard_Util.getPersonName(card);
      String last_name = pnMap.get('last_name');
      String first_name = pnMap.get('first_name');
      return
        l.Id == card.lead__c ||
        (!this.queryEmail || (card.email__c != null && card.email__c == l.Email)) &&
        ((!this.queryFirstName || first_name == l.FirstName) &&
        (!this.queryLastName || last_name == l.LastName) &&
        (!this.queryZip || isMatchZip(card, new List<String> { l.PostalCode })) &&
        (!this.queryUrl || isMatchUrl(card, l.WebSite)) &&
        (!this.queryPhone || isMatchPhone(card, l.Phone)) &&
        (!this.queryStreet || isMatchStreet(street_nobld, new List<String> { l.Street })) &&
        (!this.queryCity || city == l.City) &&
        (!this.queryState || card.address_pref__c == l.State) &&
        (!this.queryCompany || card.company_name__c == companyName || isMatchKaishaMei(card, companyName, this.companyRule)));
      }
  } // public class LeadMatcher extends Matcher {

}