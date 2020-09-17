/**
 *
 * SB_NameCard_RenkeiTargetsPicker
 * 自動連携機能で、名刺に対応する対象のアカウント、コンタクト、リードなどを抽出する Helperクラス
 *  createCardHolders に名刺レコードを渡して
 *    CardHolder　-> AccountCardHolder  で名刺ごとの情報をくるんでる のを得る
 *
 * Copyright (C) 2017-2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.02.xx
 *  @Version 2      2017.05.xx   トリガ版、UI版の統一化
 *  @Version 3      2017.07.21  v1.20.1  検索対象のレコードタイプ設定取得のためのパースの仕方を変更
 *  @Version 4      2017.09.06  v1.21  SV_DEV-598 デフォルトのレコードタイプがないユーザで自動連携を行なった場合にエラーメッセージの表示
 *  @Version 5      2017.11.xx  v1.22 SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生
 *  @Version 6      2019.05.xx  v2.4   SV_DEV-1647 法人格の正式名称と略称をマッチさせる（登録・自動連携）
 *                                      SV_DEV-1665 自動連携での取引先一致条件（確認用）-> 自動連携での名刺と取引先の一致条件でURLについては URL2は使わない
 *  @Version 2.6 全 2020.08.26 PRODUCT-26 自動連携する際に、名刺交換日が最新の場合にのみ取引先・取引先責任者・リードを上書きするようなオプションがほしい
 *
 **/
public with sharing class SB_NameCard_RenkeiTargetsPicker {
  public class SB_NameCard_RenkeiTargetsPickerException extends Exception {}

  ////////////////////////////////
  // 値の一致をチェックするときの対応付けを保持するクラス
  //  任意の項目用のみ。。
  private class Comparator {
    private Boolean use;      //  使う・使わない
    public String ncField { get; private set; }    // 名刺の項目
    public List<String> targetFields { get; private set; }   // それを比較する アカウントとか 抽出対象のオブジェクトの項目API名
    public Comparator(NameCardBasicSetting__c setting) {
      //this.use = SpecificItems_Valid__c;
      this.ncField = 'memo__c';     // 名刺の項目 メモ
      this.use = String.isNotBlank(setting.RenkeiSpecificItems__c); //setting.RenkeiSpecificItems_Valid__c;      //
      //this.use = String.isNotBlank(setting.RenkeiSpecificItems__c);
      if (this.use) {
        this.targetFields = new List<String> { setting.RenkeiSpecificItems__c };
      }
    }
  }

  ////////////////////////////////
  // 既存レコードを探すときの条件とうする項目について保持するクラス の抽象クラス
  ////////////////////////////////
  private abstract class QueryOption {
    public QueryOption() {}
    private abstract void init(NameCardBasicSetting__c setting);
  }

  ////////////////////////////////
  // アカウント用の 既存レコードを探すときの条件とうする項目について保持するクラス
  ////////////////////////////////
  private class AccountQueryOption extends QueryOption {
    //public Boolean name { get; private set; }
    public Boolean querySite { get; private set; }
    public Boolean queryState { get; private set; }
    public Boolean queryCity { get; private set; }
    public Boolean queryStreet { get; private set; }
    public Boolean queryZip { get; private set; }
    public Boolean queryPhone { get; private set; }
    public Boolean queryUrl { get; private set; }
    public Comparator extention { get; private set; }
    public AccountQueryOption(NameCardBasicSetting__c setting) {
      init(setting);
    }
    private override void init(NameCardBasicSetting__c setting) {
      this.querySite = setting.RenkeiAccountSite__c;
      this.queryState = setting.RenkeiAccountAddressPref__c;
      this.queryCity = setting.RenkeiAccountCity__c;
      this.queryStreet = setting.RenkeiAccount_Street__c;
      this.queryZip = setting.RenkeiAccountZipCode__c;
      this.queryPhone = setting.RenkeiAccountPhone__c;
      this.queryUrl = setting.RenkeiAccountURL__c;
      this.extention = new Comparator(setting);
    }
  }

  ////////////////////////////////
  // コンタクト用の 既存レコードを探すときの条件とうする項目について保持するクラス
  ////////////////////////////////
  private class ContactQueryOption extends QueryOption {
    public Boolean queryLastName { get; private set; }    //  画面上 ON 必須だけれど OFFで条件も可能にする。
    public Boolean queryFirstName { get; private set; }
    public Boolean queryEMail { get; private set; }
    public Boolean queryDept { get; private set; }
    public Boolean queryTitle { get; private set; }
    public Boolean queryMobile { get; private set; }
    public ContactQueryOption(NameCardBasicSetting__c setting) {
      init(setting);
    }
    private override void init(NameCardBasicSetting__c setting) {
      this.queryLastName = setting.RenkeiContactLastName__c;
      this.queryFirstName = setting.RenkeiContactFirstName__c;
      this.queryEMail = setting.RenkeiContactMail__c;
      //  注意  3つともオフなら、姓 だけはオンにしてしまう。
      this.queryLastName = !setting.RenkeiContactLastName__c && !setting.RenkeiContactFirstName__c && !setting.RenkeiContactMail__c ? true :  setting.RenkeiContactLastName__c;
      this.queryDept = false;
      this.queryTitle = false;
      this.queryMobile = false;
    }
  }

  private static final String QUERY_TEMPL = 'SELECT Id, Name, {0} FROM {1} WHERE {2}';
  private static final String QUERY_TEMPL2 = 'SELECT Id, Name, {0}, ({1}) FROM {2} WHERE {3}';

  /********************************************
  * 名刺レコードsと 一致する既存の アカウントやコンタクトとのマップを作るクラス の 抽象クラス
  ********************************************/
  private abstract class CardHolderBuilder {
    protected Schema.DescribeSObjectResult dsr;
    protected NameCardBasicSetting__c setting;
    // 既存の検索の仕方の構築
    protected abstract void createQueryOption();   // 検索条件に使う項目についてのクラスを作る
    // 既存の検索の対象の レコードタイプの構築
    protected abstract void createQueryRecordTypeIds();
    protected Set<Id> getValidRectypIds(SObjectType otype, String text_ids) {
      Set<Id> result = new Set<Id>();
      if (String.isBlank(text_ids)) {
        return result;
      }
      //String[] ss = text_ids.split('[,\\s]+');
      String[] ss = text_ids.split('[^0-9a-zA-Z]+');    // 2017.07.21 レコードIDなので、英数以外で分割  SV_DEV-528  自動連係 既存の取引先の検索条件 検索対象の取引先レコードタイプが全て選択されていると自動連係処理時にエラーとなる
      if (!ss.isEmpty()) {
        Map<ID, Schema.RecordTypeInfo> id2info = otype.getDescribe().getRecordTypeInfosById();
        for (String s : ss) {
          if (id2info.containsKey(s) && id2info.get(s).isAvailable()) { // 2017.09.06 SV_DEV-598 デフォルトのレコードタイプがないユーザで自動連携を行なった場合にエラーメッセージの表示
            result.add(s);
          }
        }
      }
      return result;
    }
    protected abstract String getFields();    // Id と Name 以外でクエリで取得する項目
    protected abstract void setupValues(List<NameCard__c> cards); // 検索条件となる項目の値を詰める
    protected abstract String createWhere();  // WHERE 句
    //　対象のオブジェクトへのクエリ文
    protected virtual String createQuery() {
      return String.format(QUERY_TEMPL, new String[] { getFields(), this.dsr.getName(), createWhere() });
    }
    // 名刺に対応する既存のレコードか？
    protected abstract Boolean isMatch(NameCard__c card, SObject target);

    public CardHolderBuilder(SObjectType otype) {
      this.dsr = otype.getDescribe();
      setting = SB_NameCard_BasicSetting.getNameCardBasicSetting();   // 基本設定
      createQueryOption(); // 検索条件に使う項目についてのクラスを作る
      createQueryRecordTypeIds(); // 既存の検索の対象の レコードタイプの構築
    }

    // 名刺レコードから CardHolder を初期化、リストを作成
    protected abstract List<SB_NameCard_RegistCardHolder.CardHolder> initCardHolder(List<NameCard__c> cards);

    // 初期霞の SB_NameCard_RegistCardHolder.CardHolder に該当する 連携候補レコード情報を装填
    public abstract List<SB_NameCard_RegistCardHolder.CardHolder> create(List<NameCard__c> cards);
  } // class CardHolderBuilder

  /********************************************
  * 名刺レコードsと 一致する既存の アカウント レコード のマップを作るクラス
  ********************************************/
  @TestVisible
  private class AccountsCardHolderBuilder extends CardHolderBuilder {
    private AccountQueryOption acntOpt;
    private ContactQueryOption contOpt;
    // 比較する値たち SOQL の バインドの関係でこちらのクラスで持つ
    // アカウントのクエリ用
    private Set<Id> acntRecTypeIds;   // アカウントのレコードタイプ
    private Set<Id> contRecTypeIds;   // コンタクトのレコードタイプ
    private Set<String> names;    // 会社名
    private Set<String> sites;
    private Set<String> prefs;
    private Set<String> cities;
    //private Set<String> streets;
    //private Set<String> zipCodes;
    //private Set<String> phones;
    //private Set<String> urls;
    private Set<String> acntExtentions;      // 所定の項目以外で　既存チェックする項目の値  実際は、名刺のメモの値
    // コンタクトのクエリ用
    private Set<String> lastnames;
    private Set<String> firstnames;
    private Set<String> emails;

    public AccountsCardHolderBuilder() {
      super(Account.SObjectType);
    }

    //
    protected override void createQueryOption() {
      // アカウントのクエリ用
      this.acntOpt  = new AccountQueryOption(setting);
      this.names = new Set<String>();
      //if (this.acntOpt.queryState) {
        this.prefs = new Set<String>();
      //}
      //if (this.acntOpt.querySite) {
        this.sites = new Set<String>();
      //}
      //if (this.acntOpt.queryCity) {
        this.cities = new Set<String>();
      //}
      //if (this.acntOpt.extention.use) {
        this.acntExtentions = new Set<String>();
      //}
      // コンタクトのクエリ用
      this.contOpt = new ContactQueryOption(setting);
      this.lastnames = new Set<String>();
      this.firstnames = new Set<String>();
      this.emails = new Set<String>();
    }

    protected override void createQueryRecordTypeIds() {
      this.acntRecTypeIds = getValidRectypIds(Account.sObjectType, setting.RenkeiAccountQueryRecordTypeIds__c);
      this.contRecTypeIds = getValidRectypIds(Contact.sObjectType, setting.RenkeiContactQueryRecordTypeIds__c);
    }

    // コンタクトのサブクエリ 部分 の 取得する項目
    private String getSubFields() {
      return 'FirstName, LastName, Email, Title, Department, AccountId, NameCard__c, NameCard__r.card_exchange_date__c';
    }

    // コンタクトのサブクエリ 部分 の WHERE句
    private String createSubWhere() {
      List<String> conditions = new List<String>();
      if (this.contOpt.queryLastName) {
        conditions.add('LastName IN :lastnames');
      }
      if (this.contOpt.queryFirstName) {
        conditions.add('FirstName IN :firstnames');
      }
      if (this.contOpt.queryEMail) {
        conditions.add('Email IN :emails');
      }
      // レコードタイプの条件
      if (!contRecTypeIds.isEmpty()) {
        conditions.add('RecordTypeId IN :contRecTypeIds');
      }
      return String.join(conditions, ' AND ');
    }

    // コンタクトのサブクエリ
    private String getSubQuery() {
      return String.format(QUERY_TEMPL, new String[] { getSubFields(), 'Contacts', createSubWhere() });
    }

    // Id と Name 以外でクエリで取得する項目
    @TestVisible
    protected override String getFields() {
      String result = ' Site, BillingState, ShippingState, BillingCity, ShippingCity, BillingStreet, ShippingStreet'
               + ', BillingPostalCode, ShippingPostalCode, Phone, Website, NameCard__c, NameCard__r.card_exchange_date__c';
      if (this.acntOpt.extention.use) {
        // 指定項目の 照合がある場合
        String f = this.acntOpt.extention.targetFields[0];
        if (f != 'Name' && f != 'Id' && !result.containsIgnoreCase(' ' + f)) {
          result += ', ' + f;
        }
      }

      return result;
    }

    // Account 部のWHERE句
    protected override String createWhere() {
      String result;
      // 2019.05.xx v.24 SV_DEV-1647 法人格の正式名称と略称をマッチさせる（登録・自動連携） の関係で完全一致検索はしない
      // if (setting.RenkeiExcludeHojinkakuPartial__c || setting.RenkeiExcludeHojinkaku__c) {  // 法人格抜き一致でも 部分一致検索してから、後で絞り込む
        result = 'Name LIKE :names';
      // }
      // //else if (setting.RenkeiExcludeHojinkaku__c){
      // //  result = 'Name IN :names';
      // //}
      // else {
      //   result = 'Name IN :names';
      // }
      if (this.acntOpt.querySite) {
        if (setting.RenkeiAccountSitePartialMatch__c) {
          result += ' AND Site LIKE :sites';
        }
        else {
          result += ' AND Site IN :sites';
        }
      }
      if (this.acntOpt.queryState) {
        result += ' AND (BillingState IN :prefs OR ShippingState IN :prefs)';
      }
      if (this.acntOpt.queryCity) {
        result += ' AND (BillingCity IN :cities OR ShippingCity IN :cities)';
      }
      if (this.acntOpt.extention.use) {
        result += ' AND ' + this.acntOpt.extention.targetFields[0] + ' IN :acntExtentions';
      }
      // レコードタイプの条件
      if (!acntRecTypeIds.isEmpty()) {
        result += ' AND RecordTypeId IN :acntRecTypeIds';
      }
      return result;
    }

    //　対象のオブジェクトへのクエリ文
    @TestVisible
    protected override String createQuery() {
      String subQuery = getSubQuery();
      return String.format(QUERY_TEMPL2, new String[] { getFields(), subQuery, this.dsr.getName(), createWhere() });
    }

    // 検索条件となる項目の値を詰める
    protected override void setupValues(List<NameCard__c> cards) {
      for (NameCard__c card : cards) {
        // アカウント 用の検索用の 値
        //if (String.isNotBlank(card.company_name__c)) {
        // if (setting.RenkeiExcludeHojinkakuPartial__c || setting.RenkeiExcludeHojinkaku__c) {
          // 会社名は法人格を除いて検索
          // 2017.11.xx 1.22 SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01423.9エラーが発生  → 部分一致のとき発生
          //String shamei = SB_NameCard_Util.getZenkakuBackslashToWildcard(SB_NameCard_Util.getCompanyName(card.company_name__c));  ← これあだと // があるとだめ
      // 2019.05.xx v.24 SV_DEV-1647 法人格の正式名称と略称をマッチさせる（登録・自動連携） の関係で完全一致検索はしない
          String shamei = SB_NameCard_Util.getStringForPartialMatch(SB_NameCard_Util.getCompanyName(card.company_name__c));
          if (String.isNotBlank(shamei)) {
            //names.add(String.format((setting.RenkeiExcludeHojinkakuPartial__c ? '%{0}%' : '{0}'), new String[]{shamei}));
            names.add(String.format('%{0}%', new String[]{shamei}));    // 法人格抜き一致でも 部分一致検索してから、後で絞り込む
          }
        // }
        // else {
        //   // 2017.11.xx 1.22 SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生 → 完全一致のときは発生しない
        //   names.add(card.company_name__c);
        // }
        //}
        if (this.acntOpt.querySite) {   // NULL もありとする } && String.isNotBlank(card.division_name__c)) {
          if (setting.RenkeiAccountSitePartialMatch__c) {
            if (String.isNotBlank(card.division__c)) {
              // 2017.11.xx 1.22 SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01423.9エラーが発生  → 部署名も部分一致なら同様
              //sites.add('%' + SB_NameCard_Util.getZenkakuBackslashToWildcard(card.division__c) + '%');  ← これあだと // があるとだめ
              sites.add('%' + SB_NameCard_Util.getStringForPartialMatch(card.division__c) + '%');
            }
          }
          else {
            sites.add(card.division__c);
          }
        }
        if (this.acntOpt.queryState) {   // && String.isNotBlank(card.address_pref__c)) {
          prefs.add(card.address_pref__c);
        }
        if (this.acntOpt.queryCity) {
          Map<String, String> address = SB_NameCard_Util.getAddress(card);
          cities.add(address.get('city'));    // NULL もあり
        }
        String val = (String)card.get(this.acntOpt.extention.ncField);
        if (this.acntOpt.extention.use) {   // NULL でも 一致とする。
          acntExtentions.add(val);
        }
        // コンタクト 用の検索用の 値
        //Map<String, String> names = SB_NameCard_Util.getPersonName(card);
        // 姓
        if (String.isNotBlank(card.person_name_last__c)) {
          lastnames.add(card.person_name_last__c);
        }
        // ラストネーム
        if (String.isNotBlank(card.last_name__c)) {
          lastnames.add(card.last_name__c);
        }
        // 名
        if (String.isNotBlank(card.person_name_first__c)) {
          firstnames.add(card.person_name_first__c);
        }
        // ファーストネーム
        if (String.isNotBlank(card.first_name__c)) {
          firstnames.add(card.first_name__c);
        }
        if (card.person_name_first__c == null && card.first_name__c == null) {
          firstnames.add(null);
        }
        // メール
        //if (String.isNotBlank(card.email__c )) {
        if (this.contOpt.queryEmail) {
          emails.add(card.email__c);
        }
        //}

        //if (this.acntOpt.queryStreet && String.isNotBlank(address.get('street'))) {
        //  String s = address.get('street') + '%';     // 町名番地は前方一致
        //  streets.add(s);
        //}
        //if (this.acntOpt.queryPhone && String.isNotBlank(card.tel1__c)) {
        //  phones.add(card.tel1__c);
        //}
        //if (this.acntOpt.queryPhone && String.isNotBlank(card.tel2__c)) {
        //  phones.add(card.tel2__c);
        //}
        //if (this.acntOpt.queryZip && String.isNotBlank(card.zip_code__c)) {
        //  zipCodes.add(card.zip_code__c);
        //}
        //if (this.acntOpt.queryZip && String.isNotBlank(card.web_url1__c)) {
        //  urls.add(card.web_url1__c);
        //}
        //if (this.acntOpt.queryZip && String.isNotBlank(card.web_url2__c)) {
        //  urls.add(card.web_url2__c);
        //}
      }
    }

    //　ZIP の一致確認
    private Boolean isMatchZip(NameCard__c card, Account acnt) {
      if ((String.isBlank(acnt.BillingPostalCode) || String.isBlank(acnt.ShippingPostalCode))
            && String.isBlank(card.zip_code__c)) {      // 2017.06.xx すいません。。
        return true;
      }
      if (String.isNotBlank(card.zip_code__c)) {
        String c = card.zip_code__c.replaceAll('-', '');
        if (String.isNotBlank(acnt.BillingPostalCode)) {
          String a = acnt.BillingPostalCode.replaceAll('-', '');
          if (a==c) {
            return true;
          }
        }
        if (String.isNotBlank(acnt.ShippingPostalCode)) {
          String a = acnt.ShippingPostalCode.replaceAll('-', '');
          if (a==c) {
            return true;
          }
        }
      }
      return false;
    }

    //　URL の一致確認
    private Boolean isMatchUrl(NameCard__c card, Account acnt) {
      if (String.isBlank(acnt.Website) && String.isBlank(card.web_url1__c)) {
        return true;
      }
      if (String.isNotBlank(acnt.Website)) {
        String a = acnt.Website.toLowerCase().replaceAll('https://|http://|/', '');
        if (String.isNotBlank(card.web_url1__c)) {
          String c = card.web_url1__c.toLowerCase().replaceAll('https://|http://|/', '');
          if ((a.length() >= c.length() && a.startsWith(c)) || (a.length() < c.length() && c.startsWith(a))) {
            return true;
          }
        }
        // SV_DEV-1665 自動連携での取引先一致条件（確認用） 
        // 　　-> 自動連携での名刺と取引先の一致条件でURLについては URL2は使わない
        // if (String.isNotBlank(card.web_url2__c)) {
        //   String c = card.web_url2__c.toLowerCase().replaceAll('https://|http://|/', '');
        //   if ((a.length() >= c.length() && a.startsWith(c)) || (a.length() < c.length() && c.startsWith(a))) {
        //     return true;
        //   }
        // }
      }
      return false;
    }

    //　電話番号 の一致確認
    private Boolean isMatchPhone(NameCard__c card, Account acnt) {
      if (String.isBlank(acnt.Phone) && String.isBlank(card.tel1__c)) {
        return true;
      }
      if (String.isNotBlank(acnt.Phone)) {
        String a = acnt.Phone.toLowerCase().replaceAll('[()-]+', '');
        if (String.isNotBlank(card.tel1__c)) {
          String c = card.tel1__c.replaceAll('[()-]+', '');
          if (a == c) {
            return true;
          }
        }
        if (!SB_NameCard_Util.smartViscaConfig.AutoConvAccountSearchNotUsePhone2__c // 2019.03.xx v2.2 自動連携: 電話番号2 は取引先候補の条件に使わない
            && String.isNotBlank(card.tel2__c)) {
          String c = card.tel2__c.replaceAll('[()-]+', '');
          if (a == c) {
            return true;
          }
        }
      }
      return false;
    }

    // 町名番地  の一致確認  street は 町名・番地 建物なし
    private Boolean isMatchStreet(String street, Account acnt) {
      if (String.isBlank(street) && (String.isBlank(acnt.BillingStreet) || String.isBlank(acnt.ShippingStreet))) {
        return true;
      }
      if (String.isNotBlank(street)) {
        if (String.isNotBlank(acnt.BillingStreet)) {
          if (acnt.BillingStreet.toLowerCase().startsWith(street.toLowerCase())) {
            return true;
          }
        }
        if (String.isNotBlank(acnt.ShippingStreet)) {
          if (acnt.ShippingStreet.toLowerCase().startsWith(street.toLowerCase())) {
            return true;
          }
        }
      }
      return false;
    }

    // 名刺メモとアカウント任意の項目との一致のチェック
    private Boolean isMatchExtension(NameCard__c card, SObject target) {
      System.assert(this.acntOpt.extention.use);
      String src = (String)card.get(this.acntOpt.extention.ncField);
      String dest = (String)target.get(this.acntOpt.extention.targetFields[0]);
      //return (String.isNotBlank(src) && String.isNotBlank(dest) && src == dest);
      return src == dest;
    }

    // 部署の一致のチェック
    private Boolean isMatchSite(NameCard__c card, Account acnt) {
      if (card.division__c == acnt.Site) {
        return true;
      }
      if (setting.RenkeiAccountSitePartialMatch__c && String.isNotBlank(acnt.Site) && String.isNotBlank(card.division__c)) {
        // 中間一致
        return SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(acnt.Site, SB_NameCard_MojiWidthUtil.toHalfWidth(card.division__c));
      }
      return false;
    }

    //　会社名の一致のチェック
    @TestVisible
    private Boolean isMatchKaishaMei(NameCard__c card, Account acnt) {
      if (card.company_name__c == acnt.Name) {
        return true;
      }
      if (String.isNotBlank(acnt.Name) && String.isNotBlank(card.company_name__c)) {
        String shamei = SB_NameCard_Util.getCompanyName(card.company_name__c);
        if (setting.RenkeiExcludeHojinkakuPartial__c) {
          // 法人格抜きで、中間一致
          return SB_NameCard_MojiWidthUtil.findIgnoreCaseWidth(acnt.Name, SB_NameCard_MojiWidthUtil.toHalfWidth(shamei));
        }
        else if (setting.RenkeiExcludeHojinkaku__c) {
          // 法人格抜きで、完全一致
          String acntShamei = SB_NameCard_Util.getCompanyName(acnt.Name);
          return shamei == acntShamei;
        }
        else if (setting.HojinkakuEquationLongAndAbbr__c == true) { // （完全一致のとき）法人格は略称・正称を同一視する。 null は false
          // SV_DEV-1647 法人格の正式名称と略称をマッチさせる（登録・自動連携）
          return SB_NameCard_HojinkakuParser.isEqualeKaishamei(card.company_name__c, acnt.Name);
        }
      }
      return false;
    }

    // クエリしたアカウントレコードが一致するか
    @TestVisible
    protected override Boolean isMatch(NameCard__c card, SObject target) {
      Account acnt = (Account)target;
      String city = '';
      String street = '';
      String street_nobld = '';
      if (this.acntOpt.queryCity || this.acntOpt.queryStreet) {
        Map<String, String> addrs = SB_NameCard_Util.getAddress(card);
        city = addrs.get('city');
        street = addrs.get('street');
        street_nobld = addrs.get('street_nobld');
      }
      //if (this.acntOpt.queryZip && !isMatchZip(card, target)) {
      //  return false;
      //}
      //if (this.acntOpt.queryUrl && !isMatchUrl(card, target)) {
      //  return false;
      //}
      //if (this.acntOpt.queryPhone && !isMatchPhone(card, target)) {
      //  return false;
      //}
      //if (this.acntOpt.queryStreet && !isMatchStreet(street, target)) {
      //  return false;
      //}
      //if (this.acntOpt.queryZip && card.zip_code__c != acnt.BillingPostalCode && card.zip_code__c != acnt.ShippingPostalCode) {
      //  return false;
      //}
      //if (this.acntOpt.queryCity && city != acnt.BillingCity && city != acnt.ShippingCity) {
      //  return false;
      //}
      //if (this.acntOpt.queryState && card.address_pref__c != acnt.BillingState && card.address_pref__c != acnt.ShippingState) {
      //  return false;
      //}
      //if (this.acntOpt.querySite && String.isNotBlank(acnt.Site) && !acnt.Site.contains(card.division__c))  {
      //  return false;
      //}
      //if (String.isNotBlank(card.company_name__c) && !acnt.Name.contains(card.company_name__c)) {
      //  return false;
      //}
      //return true;
      return
        (!this.acntOpt.extention.use || isMatchExtension(card, acnt)) &&
        (!this.acntOpt.queryZip || isMatchZip(card, acnt)) &&
        (!this.acntOpt.queryUrl || isMatchUrl(card, acnt)) &&
        (!this.acntOpt.queryPhone || isMatchPhone(card, acnt)) &&
        (!this.acntOpt.queryStreet || isMatchStreet(street_nobld, acnt)) &&
        (!this.acntOpt.queryCity || city == acnt.BillingCity || city == acnt.ShippingCity) &&
        (!this.acntOpt.queryState || card.address_pref__c == acnt.BillingState || card.address_pref__c == acnt.ShippingState) &&
        (!this.acntOpt.querySite || isMatchSite(card, acnt)) &&      // containsだと 全角、半角を区別するので、区別しないように
        (card.company_name__c == acnt.Name || isMatchKaishaMei(card, acnt));
    }

    // クエリしたコンタクトレコードが一致するか
    private Boolean isMatchContact(NameCard__c card, Contact cont) {
      Map<String, String> pnMap = SB_NameCard_Util.getPersonName(card);
      String last_name = pnMap.get('last_name');
      String first_name = pnMap.get('first_name');
      return
        (!this.contOpt.queryEmail || card.email__c == cont.Email) &&
        (!this.contOpt.queryFirstName || first_name == cont.FirstName) &&
        (!this.contOpt.queryLastName || last_name == cont.LastName);
    }

    // 名刺レコードから SB_NameCard_RegistCardHolder.CardHolder を初期化、リストを作成
    protected override List<SB_NameCard_RegistCardHolder.CardHolder> initCardHolder(List<NameCard__c> cards) {
      List<SB_NameCard_RegistCardHolder.AccountCardHolder> result = new List<SB_NameCard_RegistCardHolder.AccountCardHolder>();
      for (NameCard__c card : cards) {
        result.add(new SB_NameCard_RegistCardHolder.AccountCardHolder(card));
      }
      return result;
    }

    // 初期霞の SB_NameCard_RegistCardHolder.CardHolder に該当する 連携候補レコード情報を装填
    public override List<SB_NameCard_RegistCardHolder.CardHolder> create(List<NameCard__c> cards) {
     List<SB_NameCard_RegistCardHolder.AccountCardHolder> result = (List<SB_NameCard_RegistCardHolder.AccountCardHolder>)initCardHolder(cards); //
      setupValues(cards);
      String query = createQuery();
      System.debug('QUERY: ' + query);
      for (SObject obj : Database.query(query)) {
        Account acnt = (Account)obj;
        for (SB_NameCard_RegistCardHolder.AccountCardHolder ch : result) { 
          if (Limits.getLimitCpuTime() - Limits.getCpuTime() < 500) { // 2019.10.xx v2.4 SV_DEV-1677 【例外】「自動連携の検証」で SmartViscaf:Too many query rows: 50001エラーがでる。
            throw new SB_NameCard_RenkeiTargetsPickerException(SYstem.Label.SB_NC_MSG_CandidateRecordTooMuch + ' Apex CPU time limit exceeded');
          }
          NameCard__c card = ch.card;
          if (isMatch(card, acnt)) {
            // 一致していた既存のレコードの場合
            //List<AccountTarget> targets = null;
            //if (result.containsKey(card.Id)) {
            //  targets = result.get(card.Id);
            //}
            //if (targets == null) {
            //  targets = new List<AccountTarget>();
            //  result.put(card.Id, targets);
            //}
            SB_NameCard_RegistCardHolder.AccountTarget t = new SB_NameCard_RegistCardHolder.AccountTarget(acnt);
            //targets.add(t);
            // サブクエリのコンタクトを調べる。
            List<SObject> conts = acnt.Contacts;
            for (SObject cont : conts) {
              if (isMatchContact(card, (Contact)cont)) {
                t.addChild(cont);
              }
            }
            ch.addAccountTarget(t);
          }
          //else if (!result.containsKey(card.Id)) {
          //  // 一致してなくて、始めてチェックした名刺のとき
          //  result.put(card.Id, null);
          //}
        }
      }
      result.sort();
      return result;
    }

  } // AccountsCardHolderBuilder


  private static CardHolderBuilder createCardHolderBuilder(SObjectType otype) {
    CardHolderBuilder result = null;
    if (otype == Account.SObjectType) {
      result = new AccountsCardHolderBuilder();
    }
    return result;
  }

  /********************************************
  * 名刺のレコードIDと既存の対象（アカウントとかコンタクト）のレコードsのマップ、
  *
  * 既存の対象レコードがない名刺もキーにある。
  ********************************************/
  public static List<SB_NameCard_RegistCardHolder.CardHolder> createCardHolders(List<NameCard__c> cards, SObjectType otype) {
    CardHolderBuilder builder = createCardHolderBuilder(otype);
    return builder.create(cards);
  }

}