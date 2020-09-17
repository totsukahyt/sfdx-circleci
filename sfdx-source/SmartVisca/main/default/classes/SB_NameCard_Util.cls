/**
 *
 *  SB_NameCard_Util
 *  ユーティリティ クラス
 *
 *  @author etc.
 *  @Version 1    2011.xx.xx
 *  @Version .
 *  @Version .
 *  @Version 10?    2017.10.xx  with sharing  v1.21 for code scan
 *  @Version 11     2017.10.xx  v1.20.3 法人格の除外処理を 正規表現で行う ← SV_DEV-629 取引先の登録数が20万を超える組織に対して会社名が「医療法人〇〇」等の名刺が納品されると自動連係処理でエラーが発生する
 *  @Version 12     2017.11.xx v1.20.4 SV_DEV-677 法人格と法人名の間の 半角・全角スペースを除外して照合する
 *                  2017.11.xx v1.20.4 SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生
 *                  2018.01.xx オブジェクトを指定してクエリ文を取得
 *                  Publisher をクエリするので、 APIバージョンを 41.0
 *  @Version 2.1  2018.12.xx SV_DEV-1383 S1 SmartVisca での 検索で ワイルドカードが機能していない。
 *  @Version 2.1.1 2019.02.xx コードスキャン対応 WHERE句追加
 *  @Version 2.2    sawano   2019.03.XX 2.2へ反映
 *  @Version 2.4    yoshida  2019.06.XX SV_DEV-1634 SmartVisca設定タブの自動連携に関する設定の表示/非表示を切り替えるカスタム設定を作る
 *  @Version 2.6  ohno     2020.09.04 PRODUCT-781 "取引先登録:リードToDo件名"と"取引先登録:リードToDoの任命先"がSmartVIsca基本設定に表示されない コメント修正 sawano
 *
 * Copyright (c) 2011-2020 SunBridge Inc.
 *
 **/
global with sharing class SB_NameCard_Util
{
  global static final Integer SEARCHTYPE_NAME_SITE { get; private set; } // 取引先名と所属名
  global static final Integer SEARCHTYPE_NAME { get; private set; } // 取引先名のみ
  static {
    SEARCHTYPE_NAME_SITE = 1;
    SEARCHTYPE_NAME = 2;
  }

  //// 法人格として扱う文字列のリスト
  //// v1.21 SV_DEV-586 取引先名の法人格について
  ////        合同会社 のカッコつき文字だけはない
  //@TestVisible
  //private static final List<String> SHOGO_LIST = new List<String> {
  //  '株式会社', '有限会社', '合名会社', '合資会社', '合同会社', '学校法人', '社団法人', '特殊法人', '財団法人', '監査法人', '企業組合', '協同組合', '労働組合',
  //  '（株）', '（有）', '（名）', '（資）', '（同）', '（学）','（社）', '（特）', '（財）', '（監）', '（企）', '（協）', '（労）',
  //  '(株)', '(有)', '(名)', '(資)', '(同)', '(学)', '(社)', '(特)', '(財)', '(監)', '(企)', '(協)', '(労)',
  //  '（株)', '（有)', '（名)', '（資)', '（同)', '（学)','（社)', '（特)', '（財)', '（監)', '（企)', '（協)', '（労)',
  //  '(株）', '(有）', '(名）', '(資）', '(同）', '(学）','(社）', '(特）', '(財）', '(監）', '(企）', '(協）', '(労）',
  //  '㈱', '㈲', '㈴', '㈾', '㈻','㈳', '㈵', '㈶', '㈼', '㈽', '㈿', '㈸'
  //};

  public static String getStr(String s) {
    return (s == null) ? '' : s;
  }

  public static String addslashes(String s) {
    s = s.replace('\\', '\\\\');
    s = s.replace('\'', '\\\'');
    return s;
  }

  // ページのパラメーター
  public static Map<String, String> getPageParameters(String prefix) {
    Map<String, String> params = new Map<String, String>();
    Map<String, String> paramsAll = System.currentPageReference().getParameters();

    for (String key : paramsAll.keySet()) {
      if (key.startsWith(prefix)) {
        params.put(key.substring(prefix.length()), paramsAll.get(key));
      }
    }
    return params;
  }

  //// 商号を削除
  //global static String getCompanyName(String cn) {
  //  if (String.isNotBlank(cn)) {
  //    for (String syougou : SHOGO_LIST) {
  //      if (cn.startsWith(syougou)) {
  //        cn = cn.removeStart(syougou).trim();
  //        break;
  //      } else if (cn.endsWith(syougou)) {
  //        cn = cn.removeEnd(syougou).trim();
  //        break;
  //      }
  //    }
  //  }
  //  return cn;
  //}

  //private static final String HOJIN_REGEX0 = '(株式会社|有限会社|合名会社|合資会社|合同会社|学校法人|社団法人|特殊法人|財団法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|一般財団法人|公益社団法人|公益財団法人|宗教法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人|[(（]([株有名資同学社特財監企協労医]|一社|公社|特非|地独)[）)]|[㈱㈲㈴㈾㈻㈳㈵㈶㈼㈽㈿㈸])';
  // 2017.11.xx v1.20.4 法人格との間の 半角・全角スペース 除去
  private static final String HOJIN_REGEX = '^(' + Label.SB_NC_HojinKakuRegex + '[\\s　]*)' + '|' + '([\\s　]*' + Label.SB_NC_HojinKakuRegex + ')$';

  // 2017.10.xx 1.20.3 or 1.21.1 商号を削除 V2  正規表現で
  // 2017.12.xx v1.22 SV_DEV-718 取引先・取引先責任者に一括登録の際に会社名がnullのデータが含まれていた場合に日本語でエラーを表示させてほしい
  global static String getCompanyName(String cn) {
    String result = String.isBlank(cn) ? cn : cn.replaceFirst(HOJIN_REGEX, '');
    return result;
  }

  // 姓名
  global static Map<String, String> getPersonName(NameCard__c nameCard) {
    Map<String, String> personName = new Map<String, String>();
    String lastName = '';
    String firstName = '';

    if (nameCard.person_name_last__c != null) {
      lastName = nameCard.person_name_last__c;

      if (nameCard.person_name_first__c != null)
        firstName = nameCard.person_name_first__c;
    } else if (nameCard.last_name__c != null) {
      lastName = nameCard.last_name__c;

      if (nameCard.first_name__c != null)
        firstName = nameCard.first_name__c;
    } else {
      if (nameCard.person_name_first__c != null)
        firstName = nameCard.person_name_first__c;
      else if (nameCard.first_name__c != null)
        firstName = nameCard.first_name__c;
    }

    if (String.isBlank(lastName) == false && lastName.length() > 80) {    // 2014.4.2 sawano nullでないときだけ確認
      lastName = lastName.substring(0, 80);
    }

    if (String.isBlank(firstName) == false && firstName.length() > 40) { // 2014.4.2 sawano nullでないときだけ確認
      firstName = firstName.substring(0, 40);
    }
    personName.put('last_name', lastName);
    personName.put('first_name', firstName);

    return personName;
  }

  // 市区郡、町名・番地
  //global static Map<String, String> getAddress(NameCard__c nameCard)
  //{
  //    Map<String, String> address = new Map<String, String>();
  //    String city = '';
  //    String street = '';
  //    Integer i;

  //    if (nameCard.address__c != null) {
  //        i = nameCard.address__c.indexOf('市');
  //        if (i >= 1 && i <= 6) {
  //            city = nameCard.address__c.substring(0, i + 1);
  //        } else {
  //            i = nameCard.address__c.indexOf('区');
  //            if (i >= 1 && i <= 6) {
  //                city = nameCard.address__c.substring(0, i + 1);
  //            } else {
  //                i = nameCard.address__c.indexOf('郡');
  //                if (i >= 1 && i <= 6) {
  //                    city = nameCard.address__c.substring(0, i + 1);
  //                }
  //            }
  //        }

  //        if (i >= 1 && i <= 6)
  //            street = nameCard.address__c.substring(i + 1);
  //        else
  //            street = nameCard.address__c;
  //    } else if (nameCard.address_eng__c != null) {
  //        street = nameCard.address_eng__c;
  //    }

  //    if (nameCard.address_bld__c != null)
  //        street += nameCard.address_bld__c;

  //    if (String.isBlank(city) == false && city.length() > 40)    // 2014.4.2 sawano nullでないときだけ確認
  //        city = city.substring(0, 40);

  //    if (String.isBlank(street) == false && street.length() > 255)   // 2014.4.2 sawano nullでないときだけ確認
  //        street = street.substring(0, 255);

  //    address.put('city', city);
  //    address.put('street', street);

  //    return address;
  //}
//private static final String ADDRESS_REGEX = // '^(北海道|青森県|岩手県|秋田県|山形県|宮城県|福島県|新潟県|栃木県|群馬県|茨城県|埼玉県|千葉県|東京都|神奈川県|山梨県|静岡県|長野県|富山県|石川県|福井県|岐阜県|愛知県|三重県|奈良県|和歌山県|滋賀県|京都府|大阪府|兵庫県|岡山県|広島県|鳥取県|島根県|山口県|香川県|徳島県|愛媛県|高知県|福岡県|佐賀県|長崎県|熊本県|大分県|宮崎県|鹿児島県|沖縄県) +
//  '^(四日市市|大和郡山市|小郡市|市原市|市川市|廿日市市|蒲郡市|郡上市|郡山市|野々市市|今市市|八日市場市|八日市市|余市郡|高市郡|.+?郡|.+?市|.+?区|)(.*)$';

  // 名刺の 市区郡、町名・番地+建物
  // city => 市区郡
  // street => 町名・番地+建物
  global static Map<String, String> getAddress(NameCard__c card) {
    String city = '';
    String street = '';
    Map<String, String> result = new Map<String, String>();
    if (String.isNotBlank(card.address__c)) {
      Pattern ptn = Pattern.compile(Label.SB_NC_AddressRegex);
      Matcher matcher = ptn.matcher(card.address__c);
      while (matcher.find()) {
        if (matcher.groupCount()> 0 && matcher.groupCount() <2) {
          city = matcher.group(1);
        }
        else if (matcher.groupCount() > 1) {
          city = matcher.group(1);
          street = matcher.group(2);
        }
      }
    }
    else if (String.isNotBlank(card.address_eng__c)) {
      street = card.address_eng__c;
    }
    result.put('street_nobld', street.left(255));          //  2017.03.xx   自動連携対応のとき
    if (String.isNotBlank(card.address_bld__c)) {
      street += card.address_bld__c;
    }
    result.put('city', city.left(40));               // 長い場合 DML で切り捨てたいが、既存のコードがあるので、ここで切っとく
    result.put('street', street.left(255));          //
    return result;
  }

  // 2012.02.25 - 名刺リンクTrigger関連
  // recursiveにupdate triggerが処理されないためのフラグ
  private static boolean updateFromTrigger = false;
  public static boolean isUpdateFromTrigger () {
    return updateFromTrigger;
  }

  public static void setUpdateFromTrigger () {
    updateFromTrigger = true;
  }

  // 名刺の一覧を、"姓_名_メールアドレス"をキーにしたmapに振り分け
  global static Map<String, List<NameCard__c>> getNameCardMap(List<NameCard__c> cardList) {
    Map<String, List<NameCard__c>> cardMap = new Map<String, List<NameCard__c>>();

    for (NameCard__c thisCard: cardList) {
      if (thisCard.delivery_type__c != '2') {
        // 最終納品でない名刺は何もしない
        continue;
      }
      if (thisCard.person_name_last__c == null || thisCard.person_name_first__c == null) {
        // 姓名が指定されていないものはマッチさせない。
        continue;
      }
      String key = getSearchkey(thisCard);

      List<NameCard__c> cardListByKey = cardMap.get(key);
      if (cardListByKey==null) {
        cardListByKey = new List<NameCard__c>();
      }
      cardListByKey.add(thisCard);
      cardMap.put(key, cardListByKey);
    }
    return cardMap;
  }

  public static String getSearchKey(NameCard__c card) {
    String key = card.person_name_last__c + '_' + card.person_name_first__c + '_';
    if (card.email__c!=null)
      // アドレスに'_'が含まれる場合は' 'に置換
      key += card.email__c.replaceAll('_',' ');
    else
      key += 'null';
    return key;
  }

  //// "姓_名_メールアドレス"のキーのリストを元に、マッチする名刺を全て取得
  //public static List<NameCard__c> getExistingCardListByKeys(Set<String> keys) {
  //  String[] lastnames = new List<String>();
  //  String[] firstnames = new List<String>();
  //  String[] emails = new List<String>();

  //  for (String thisKey:keys) {
  //    String[] items = thisKey.split('_');

  //    if (items.size()<3)
  //      continue;

  //    lastnames.add(items[0]);
  //    firstnames.add(items[1]);
  //    if (items[2]!='null')
  //      emails.add(items[2].replace(' ','_'));
  //    else
  //      emails.add('');
  //  }

  //  return [SELECT Id, person_name_last__c, person_name_first__c, email__c, Parent__c, date__c, delivery_type__c FROM NameCard__c
  //                  WHERE (delivery_type__c = '2')
  //                  AND (person_name_last__c In :lastnames)
  //                  AND (person_name_first__c In :firstnames)
  //                  AND (email__c IN :emails)
  //                  ORDER BY date__c DESC];
  //}

  //// 指定された名刺がParent__cに指定されている名刺について、 姓と名とメールアドレスが
  //// すべて一致する名刺の中で、最新の名刺のIDを、 他の名詞のParent__cに設定
  //public static void resetChildCards(List<NameCard__c> parentCardToReset)
  //{
  //  // 変更・削除しようとしている名刺が親になっている名刺を検索
  //  List<NameCard__c> childCards = [SELECT Id, person_name_last__c, person_name_first__c, email__c, Parent__c, date__c, delivery_type__c FROM NameCard__c
  //  WHERE (delivery_type__c = '2') AND (Parent__c IN :parentCardToReset) ORDER BY date__c DESC];

  //  if (childCards.size() > 0) {
  //    System.debug('*** SB_NameCard_resetCardLinks: update childCards ->' + childCards);
  //    Map<String, List<NameCard__c>> childCardMap = SB_NameCard_Util.getNameCardMap(childCards);

  //    List<NameCard__c> cardsToUpdate = new List<NameCard__c>();

  //    for (List<NameCard__c> childCardList: childCardMap.values()) {
  //      if (childCardList!=null) {
  //        for (Integer i=0; i<childCardList.size(); i++) {
  //          if (i==0)
  //          childCardList[i].parent__c=null;
  //          else
  //          childCardList[i].parent__c = childCardList[0].Id;
  //        }
  //        cardsToUpdate.addAll(childCardList);
  //      }
  //    }

  //    System.debug('*** SB_NameCard_resetCardLinks: cardsToUpdate is ' + cardsToUpdate);
  //    update cardsToUpdate;
  //  }
  //}

  // 運用版のSmartVisca サーバ の名刺送信API 系の URL
  private static final String SMARTVISCA_SERVER_URL = 'https://namecard.sf.sunbridge.com';
  // SmartVisca サーバ のサービスID
  private static final String SMARTVISCA_SERVER_SERVICEID = 'SFDCAPEX';
  // 取引先・取引先責任者登録 の 取引先の表示項目設定
  private static final String REGIST_ACCOUNT_QUERYFIELD = 'BillingPostalCode,BillingState:2,BillingCity, BillingStreet, Site:2';
  // 取引先・取引先責任者登録 の 取引先責任者の表示項目設定
  private static final String REGIST_CONTACT_QUERYFIELD = 'Department:2,Title:2,Email:2, MailingPostalCode, MailingState, MailingCity,MailingStreet';
  // SmartVisca設定 の値の参照 2014.4.2x
  // トリガで取込日時をセットする
  public static Boolean isTriggerRegDateTime() { return smartViscaConfig.TriggerRegDateTime__c; }
  // トリガで同じ人と名刺交換したらフィードで知らせる
  public static Boolean isTriggerCreateFeedOnName() { return smartViscaConfig.TriggerCreateFeedOnName__c; }
  // トリガで名刺データを名寄せする
  public static Boolean isTriggerMergeNameCards() { return smartViscaConfig.TriggerMergeNameCards__c; }
  // 2019.07.xx v2.4   トリガで実施する名寄せの条件を拡張する
  public static Boolean isTriggerMergeExpandCriteria() { return smartViscaConfig.TriggerMergeExpandCriteria__c; }
  // トリガで名刺履歴を保存する
  public static Boolean isTriggerHistoryIsActive() { return smartViscaConfig.TriggerHistoryIsActive__c; }
  //// 2018.03.xx v1.22  トリガでキャンペーンIDをセットする。 基本設定 の指定　との AND
  //public static Boolean isTriggerCampaignHandler() { return smartViscaConfig.TriggerLeadExCampaignHandler__c; }
  // 2018.03.xx v1.22  自動連携のトリガハンドラを呼ぶ
  public static Boolean isTriggerRenkeiHandler() { return smartViscaConfig.TriggerRenkeiTriggerHandler__c; }
  // 2018.03.xx v1.22  Lead連携拡張パッケージの中にある 自動連携のトリガハンドラを呼ぶ
  public static Boolean isTriggerLeadExRenkeiHandler() { return smartViscaConfig.TriggerLeadExRenkeiTriggerHandler__c; }
  // 2019.06.xx v2.4   自動連携に関する設定を表示
  public static Boolean isDispRenkeiSetting() { return smartViscaConfig.DispRenkeiSetting__c; }

  // カスタム設定 SmartVisca設定 の取得
  public static SmartViscaConfig__c smartViscaConfig {
    get {
      if (smartViscaConfig == null) {
        smartViscaConfig = SmartViscaConfig__c.getInstance(UserInfo.getUserId());   //  個人の設定
        if (smartViscaConfig.Id ==null) {
            smartViscaConfig =  SmartViscaConfig__c.getInstance(UserInfo.getProfileId());   //プロファイルの設定
        }
        if (smartViscaConfig.id == null) {
          smartViscaConfig = SmartViscaConfig__c.getOrgDefaults();    // 組織の設定
        }
        if (smartViscaConfig.id == null) {
          smartViscaConfig.TriggerRegDateTime__c = true;
          smartViscaConfig.TriggerCreateFeedOnName__c = true;
          smartViscaConfig.TriggerMergeNameCards__c = true;
          smartViscaConfig.TriggerHistoryIsActive__c = false;
          //smartViscaConfig.TriggerLeadExCampaignHandler__c = true; // 2018.03.xx v1.22  トリガでキャンペーンIDをセットする。 基本設定 の指定　との AND
          smartViscaConfig.TriggerRenkeiTriggerHandler__c = true; // 2018.03.xx v1.22  自動連携のトリガハンドラを呼ぶ
          smartViscaConfig.TriggerLeadExRenkeiTriggerHandler__c = false; // 2018.03.xx v1.22  Lead連携拡張パッケージの中にある 自動連携のトリガハンドラを呼ぶ
          smartViscaConfig.OrgTreeUseRegex__c = false; // 2018.03.xx SV_DEV-787 組織情報の部署（所属）が意図的でない箇所で改行されるケース
          smartViscaConfig.DispRenkeiSetting__c = false; // 2019.06.XX SV_DEV-1634 SmartVisca設定タブの自動連携に関する設定の表示/非表示を切り替えるカスタム設定を作る
          smartViscaConfig.TriggerMergeExpandCriteria__c = false; // 2019.07.xx v2.4   トリガで実施する名寄せの条件を拡張する
          // S1 行動やToDoは標準の画面を使う
          smartViscaConfig.SUseStandardActivityUI__c = false;
          // S1 名刺詳細は標準の画面を使う
          smartViscaConfig.SUseStandardNamecardViewUI__c = false;
          // S1 名刺編集は標準の画面を使う
          smartViscaConfig.SUseStandardNamecardEditUI__c = false;
          // 名刺の編集を行う
          smartViscaConfig.SEnableNameCardEdit__c = true;
          // 名刺データをセッションストレージに保持する
          smartViscaConfig.SUseSessionStrage__c = true;
          // Sみんなの名刺でも2次納品以外も検索の対象にする
          smartViscaConfig.SSearchAllIgnoreDeliveryType__c = false;
          // 地理情報を使う
          smartViscaConfig.SUseGIS__c = false;
          // 名刺詳細画面に表示する項目系
          // S名刺詳細：ニュースリンクを表示する
          smartViscaConfig.SDetailShowNewsLink__c = true;
          // S名刺詳細：FAX番号を表示する
          smartViscaConfig.SDetailShowFax__c = true;
          // S名刺詳細：URLを表示する
          smartViscaConfig.SDetailShowURL__c = false;
          // S名刺詳細：メールアドレスを表示する
          smartViscaConfig.SDetailShowEMail__c = true;
          // S名刺詳細：メモを表示する
          smartViscaConfig.SDetailShowMemo__c = false;
          // S名刺詳細：リスト名を表示する
          smartViscaConfig.SDetailShowListName__c = true;
          // S名刺詳細：英語住所を表示する
          smartViscaConfig.SDetailShowAddressEng__c = false;
          // S名刺詳細：会社名カナを表示する
          smartViscaConfig.SDetailShowCompanyKana__c = false;
          // S名刺詳細：携帯電話番号を表示する
          smartViscaConfig.SDetailShowMobile__c = true;
          // S名刺詳細：氏名カナを表示する
          smartViscaConfig.SDetailShowNameKana__c = false;
          // S名刺詳細：手書きメモを表示する
          smartViscaConfig.SDetailShowFreeHandMemo__c = false;
          // S名刺詳細：住所を表示する
          smartViscaConfig.SDetailShowAddress__c = true;
          // S名刺詳細：所有者を表示する
          smartViscaConfig.SDetailShowOtherOwner__c = true;
          // S名刺詳細：電話番号を表示する
          smartViscaConfig.SDetailShowTel__c = true;
          // S名刺詳細：名刺交換日を表示する
          smartViscaConfig.SDetailShowExchangeDate__c = true;
          // S名刺詳細：郵便番号を表する
          smartViscaConfig.SDetailShowZipCode__c = true;
          // S転職済みの名刺は表示しない
          smartViscaConfig.SIgnoreJobChanged__c = true;
          // S開発者モードで動く
          smartViscaConfig.SDevelopment__c = false;       // 2015.08.1X V1.11
          //// SmartViscaサーバ  proxy_flag true でリクエストする。
          //smartViscaConfig.SSmartViscaServerProxyFlag__c = false;       // 2015.08.1X V1.11
          // 取引先、取引先責任者 登録機能を使えるか
          smartViscaConfig.SUseAccountRegist__c = false;          // 2016.04.xx
          // S取引先情報を名刺情報で上書きする
          smartViscaConfig.SRegistOverwriteAccount__c = true;               // 2016.06.xx
          // S取引先責任者情報を名刺情報で上書きする
          smartViscaConfig.SRegistOverwriteContact__c = true;               // 2016.06.xx
          // S名刺一覧のみんなの名刺は最新の名刺以外も対象にする
          smartViscaConfig.SListQueryIgnoreLatestCard__c = false;            // 2016.09.xx
          // S組織情報に役職を表示する
          smartViscaConfig.SOrgTreeShowTitle__c = false;      // 2016.11.xx
          // S名刺カメラで所有者選択を有効にする
          smartViscaConfig.SCameraEnableOwnerSelect__c = true; // v2.1 2018.11.xx
        }
        smartViscaConfig.SListQueryMineLimit__c = smartViscaConfig.SListQueryMineLimit__c == null || smartViscaConfig.SListQueryMineLimit__c <=0 ?
          100 : smartViscaConfig.SListQueryMineLimit__c;
        smartViscaConfig.SListQueryVisibleLimit__c = smartViscaConfig.SListQueryVisibleLimit__c == null || smartViscaConfig.SListQueryVisibleLimit__c <=0 ?
          200 : smartViscaConfig.SListQueryVisibleLimit__c;
        smartViscaConfig.SFindNearByQueryLimit__c = smartViscaConfig.SFindNearByQueryLimit__c  == null || smartViscaConfig.SFindNearByQueryLimit__c  <=0 ?
          10 : smartViscaConfig.SFindNearByQueryLimit__c;
        smartViscaConfig.SFindNearByQueryDistance__c = smartViscaConfig.SFindNearByQueryDistance__c == null || smartViscaConfig.SFindNearByQueryDistance__c <=0 ?
          10 : smartViscaConfig.SFindNearByQueryDistance__c;
        // 地理位置情報を取得する件数
        smartViscaConfig.SGeolocationQueryLimit__c = smartViscaConfig.SGeolocationQueryLimit__c == null || smartViscaConfig.SGeolocationQueryLimit__c <=0?
          100 : smartViscaConfig.SGeolocationQueryLimit__c;
        // 地理位置情報を取得する間隔
        smartViscaConfig.SGeolocationQueryInterval__c = smartViscaConfig.SGeolocationQueryInterval__c == null || smartViscaConfig.SGeolocationQueryInterval__c <=0 ?
          1000 : smartViscaConfig.SGeolocationQueryInterval__c;
        //
        smartViscaConfig.SDatetimeFormat__c = smartViscaConfig.SDatetimeFormat__c == null ? 'yyyy/MM/dd/ HH:mm' : smartViscaConfig.SDatetimeFormat__c;
        smartViscaConfig.SEventDurationInMinutes__c = smartViscaConfig.SEventDurationInMinutes__c == null || smartViscaConfig.SEventDurationInMinutes__c <= 0 ?
          60 :smartViscaConfig.SEventDurationInMinutes__c;
        // 地図のピンをクリックしたとき表示される InfoWindow に表示するときの会社ごとの氏名の最大値
        smartViscaConfig.SMAXMapInfoWindowPersons__c = smartViscaConfig.SMAXMapInfoWindowPersons__c == null || smartViscaConfig.SMAXMapInfoWindowPersons__c <= 0?
          5 : smartViscaConfig.SMAXMapInfoWindowPersons__c;
        // 地図のピンに表示する会社数の最大値
        smartViscaConfig.SMAXMapInfoWindowCompanies__c = smartViscaConfig.SMAXMapInfoWindowCompanies__c == null || smartViscaConfig.SMAXMapInfoWindowCompanies__c <=0 ?
          4 : smartViscaConfig.SMAXMapInfoWindowCompanies__c;
        // 組織階層を作るときに取得する名刺の上限値
        smartViscaConfig.SMAXOrgTreeNameCards__c = smartViscaConfig.SMAXOrgTreeNameCards__c == null || smartViscaConfig.SMAXOrgTreeNameCards__c <=0 ?
          200 : smartViscaConfig.SMAXOrgTreeNameCards__c;
        // SmartVisca サーバの APIの ベースURL
        smartViscaConfig.SSmartViscaServer__c = String.isBlank(smartViscaConfig.SSmartViscaServer__c) ?
          SMARTVISCA_SERVER_URL : smartViscaConfig.SSmartViscaServer__c;
        // S1カメラのスキャナー名 2015.6.xx  S1カメラ対応
        smartViscaConfig.SScannerName__c = String.isBlank(smartViscaConfig.SScannerName__c) ?
          System.Label.SB_NC_S1ScannerName : smartViscaConfig.SScannerName__c;
        // SmartVisca サーバの サービスID
        smartViscaConfig.SSmartViscaServeServiceID__c = String.isBlank(smartViscaConfig.SSmartViscaServeServiceID__c) ?
          SMARTVISCA_SERVER_SERVICEID : smartViscaConfig.SSmartViscaServeServiceID__c;
        // 取引先・取引先責任者登録 の 取引先の表示項目設定
        smartViscaConfig.SRegistQueryAccountFields1__c = String.isBlank(smartViscaConfig.SRegistQueryAccountFields1__c) ?
          System.Label.SB_NC_RegistQueryAccountFields : smartViscaConfig.SRegistQueryAccountFields1__c;
        // 取引先・取引先責任者登録 の 取引先責任者の表示項目設定
        smartViscaConfig.SRegistQueryContactFields1__c = String.isBlank(smartViscaConfig.SRegistQueryContactFields1__c) ?
          System.Label.SB_NC_RegistQueryContactFields : smartViscaConfig.SRegistQueryContactFields1__c;
        // v2.1 SSmartViscaカメラで所有者選択を有効にする
        smartViscaConfig.SCameraEnableOwnerSelect__c = smartViscaConfig.SCameraEnableOwnerSelect__c == null ? true : smartViscaConfig.SCameraEnableOwnerSelect__c; // v2.1 2018.11.xx S名刺カメラで所有者選択を有効にする
        // v2.1SSmartViscaカメラの所有者選択リストの上限値
        smartViscaConfig.SCameraOwnerSelectLimit__c = smartViscaConfig.SCameraOwnerSelectLimit__c == null ? 5000 : smartViscaConfig.SCameraOwnerSelectLimit__c;
        // 取引先・取引先任者に登録(個別) 登録先候補の検索方法  0: SOQLによるカウントを行い、その後SOQLで抽出する。 その他: SOSL
        smartViscaConfig.AccountRegistSearchMethod__c = smartViscaConfig.AccountRegistSearchMethod__c == null ? 1 : smartViscaConfig.AccountRegistSearchMethod__c;   // v2.4 2019.06.xx
        // 取引先・取引先任者に登録(一括) 登録先候補の検索方法  0: SOQLによるカウントを行い、その後SOQLで抽出する。 その他: SOSL
        smartViscaConfig.AccountBulkRegistSearchMethod__c = smartViscaConfig.AccountBulkRegistSearchMethod__c == null ? 1 : smartViscaConfig.AccountBulkRegistSearchMethod__c;   // v2.4 2019.06.xx
        // SV_DEV-1938 SmartViscaカメラから固定で proxy_flag及びservice_id を名刺サーバに送る
        // カスタム表示ラベルにそれらしいのがあったときだけ、
        if (String.isBlank(smartViscaConfig.SSmartViscaServerOptions__c) && System.Label.SB_NC_SImageServerOptions.contains('proxy_flag')) {
          smartViscaConfig.SSmartViscaServerOptions__c = System.Label.SB_NC_SImageServerOptions;
        }
        // SmartViscaカメラでユーザによる設定変更を不可にする。 SV_DEV-1627 SmartViscaカメラのデフォルトの設定をシステム管理者で変更できるようにする 関連
        smartViscaConfig.SCameraDisableUserConfig__c = smartViscaConfig.SCameraDisableUserConfig__c == null ? false : smartViscaConfig.SCameraDisableUserConfig__c;
        // SSmartViscaカメラ起動ボタンを表示しない デフォルト false SV_DEV-2024 S1 新SmartVisca：カメラ起動ボタンを非表示にする設定が欲しい
        smartViscaConfig.SDisableCameraLauncher__c = smartViscaConfig.SDisableCameraLauncher__c == true;
        // タグ付き名刺の取得方法 0: v2.3までの方法。自分所有の名刺のみが対象 1: v2.4での方法。可視の名刺が対象 その他: v2.5 可視の名刺が対象で、制限を考慮
        smartViscaConfig.TaggedCardsFetchMethod__c = smartViscaConfig.TaggedCardsFetchMethod__c == null ? 2 : smartViscaConfig.TaggedCardsFetchMethod__c;
      }
      return smartViscaConfig;
    }
    private set;
  }

  // 基本パッケージの名前空間名を返します。
  // 2018.01.xx v1.22 から global にします.
  global static String getNamespacePrefix_x() { return String.isEmpty(namespacePrefix) ? '' : namespacePrefix+'__'; }
  global static String getNamespacePrefix() { return namespacePrefix; }
  private static String namespacePrefix {
    get {
      if (namespacePrefix ==null) {
        List<ApexClass> classes = [SELECT Name, NamespacePrefix FROM ApexClass WHERE Name='SB_NameCard_Util'];
        if (classes.size() == 1) { // 別のパッケージで SB_NameCard_Utilを持ってる場合に対処 2018.08.xx
          namespacePrefix = classes[0].NamespacePrefix != null ? classes[0].NamespacePrefix : '';
        }
        else if (classes.size() > 1) {
           namespacePrefix = 'SmartViscaf';
        }
        else {
          namespacePrefix = '';
        }
      }
      return namespacePrefix;
    }
    private set;
  }

  // 項目の選択リスト値のリストを取得
  public static List<String> getPickListEntry(Schema.SObjectField d) {
    try {
      Schema.DescribeFieldResult F = d.getDescribe();
      List<Schema.PicklistEntry> P = F.getPicklistValues();
      List<String> listNames = new List<String>();
      for (Schema.PicklistEntry ent : P) {
        if (ent.isActive()) {
          listNames.add(ent.getLabel());
          System.debug('active item : ' + ent.getLabel());
        }
        else {
          System.debug('inactive item : ' + ent.getLabel());
        }
        if (ent.isDefaultValue())
        System.debug('Field4__c Default : ' + ent.getLabel());
      }
      return listNames;
    } catch (Exception e) {
      System.debug(e);
      return null;
    }
  }

  // オブジェクトIDからオブジェクト名を得ます。
  public static String getObjectName(ID idObj) {
    try {
      Schema.SObjectType token = idObj.getSObjectType();
      Schema.DescribeSObjectResult dr = token.getDescribe();
      System.debug(dr.getName());
      return dr.getName();
    }
    catch (Exception e) {
      System.debug(e.getMessage());
    }
    return '';
  }

  // 活動状況の選択肢を取得, キーは 'Completed' か 'NotStarted' のみ有効
  global static Map<String, String> taskStatusValues {
    get {
      if (taskStatusValues == null) {
        taskStatusValues = new Map<String, String>();
        List<TaskStatus> taskstatuses = [SELECT IsClosed, IsDefault, MasterLabel, SortOrder FROM TaskStatus
                                        WHERE IsClosed=True OR IsDefault=True ORDER BY SortOrder ];  // v2.1.1 コードスキャン対応 WHERE句追加
        for (TaskStatus ts : taskstatuses) {
          if (ts.isClosed && ! taskStatusValues.containsKey('Completed')) {
            taskStatusValues.put('Completed', ts.MasterLabel);
          } else if (ts.isDefault && ! taskStatusValues.containsKey('NotStarted')) {
             taskStatusValues.put('NotStarted', ts.MasterLabel);
          }
        }
        if (! taskStatusValues.containsKey('Completed')) {
          taskStatusValues.put('Completed', System.Label.SB_NC_Completed);
        } else if (! taskStatusValues.containsKey('NotStarted')) {
          taskStatusValues.put('NotStarted', System.Label.SB_NC_NotStarted);
        }
      }
      return taskStatusValues;
    }
    private set;
  }

  // SOSL の予約語をエスケープする。 2016.10.xx
  private static final String SOSL_YOYAKUGO = '?&|!{}[]()^~*:"\'+-\\';
  public static String escapeSOSLYoyakugo(String text) {
    if (!text.containsAny(SOSL_YOYAKUGO)) {
      return text;
    }
    String result = text;
    result = result.replace('\\', '\\\\');
    // result = result.replace('?', '\\?'); SV_DEV-1383 S1 SmartVisca での 検索で ワイルドカードが機能していない。
    result = result.replace('&', '\\&');
    result = result.replace('|', '\\|');
    result = result.replace('!', '\\!');
    result = result.replace('{', '\\{');
    result = result.replace('}', '\\}');
    result = result.replace('[', '\\[');
    result = result.replace(']', '\\]');
    result = result.replace('(', '\\(');
    result = result.replace(')', '\\)');
    result = result.replace('^', '\\^');
    result = result.replace('~', '\\~');
    // result = result.replace('*', '\\*'); SV_DEV-1383 S1 SmartVisca での 検索で ワイルドカードが機能していない。
    result = result.replace(':', '\\:');
    result = result.replace('"', '\\"');
    result = result.replace('\'', '\\\'');
    result = result.replace('+', '\\+');
    result = result.replace('-', '\\-');
    System.debug(result);
    return result;
  }

  @TestVisible
  private static final Set<String> SV_OBJECT_NAMES = new Set<String> {
    'namecard__c',
    'namecardhistory__c',
    'namecardrenkeimapping__c',
    'jinjiido__c',
    'jinjiidoemail__c',
    'namecardhistory__c'
  };

  public static String getManagedObjectName(String oName) {
    String result = oName;
    if (SV_OBJECT_NAMES.contains(oName.toLowerCase())) {
      String ns = SB_NameCard_Util.getNamespacePrefix_x();
      result = ns + oName;
    }
    return result;
  }

  // 2017.11.xx v1.20.4 SV_DEV-673 会社名に全角バックスラッシュが含まれる名刺を自動連携すると、ORA-01424エラーが発生
  // SOQL の 条件句 用に  ／ があると ORA エラーになるので、／ があったら、_ にかえる
  // ' シングルクオートがあると、escapeSingleQuotes でエラーになるらしい。ので、あり得ない文字列 URLエンコードして BASE64エンコードした文字列に一旦置換して、あとで戻す
  // aaa\\aaa  のように \ が2つつずくと escapeSingleQuotes で \ をエスケープしとかないと、SOQLでヒットしないので、 エスケープする。
  //
  public static String getBackslashToWildcardEtc(String text) {
    String result = text;
    //result = result.replaceAll('＼', '_');
    //if (text.contains('＼') || text.contains('\\')) {
    //  // ＼  か \ があったら
    if (text.contains('＼')) {
      // ＼ があったら
      if (text.contains('\'')) {
        // ' シングルクオートがある
        String str = EncodingUtil.urlEncode(text, 'UTF-8');
        Blob b = Blob.valueOf(str);
        String b64 = EncodingUtil.base64Encode(b);
        result = result.replaceAll('\'',b64);   // ' 絶対ユニークな文字列にしておく
        //result = String.escapeSingleQuotes(result.replaceAll('＼', '_'));
        result = result.replaceAll('＼', '_');
        result = result.replaceAll(b64,'\'');
      }
      else {
        // ' シングルクオートはない
        //result = String.escapeSingleQuotes(result.replaceAll('＼', '_'));
        result = result.replaceAll('＼', '_');
      }
    }
    //else if (text.contains('\'') == false && text.contains('\\')== false)  {
    //  // ＼  がなく  ' シングルクオート、と \ 半角バックスラッシュともない。
    //  // aaa\\aaa のような バックスラッシュ2つのとき、ヒットしないので、エスケープする
    //  result = String.escapeSingleQuotes(text);
    //}
    // ＼  か \  ともなく ' シングルクオートがあったら、そのまま
    return result;
  }

  public static String getZenkakuBackslashToWildcard(String text) {
    return String.isBlank(text) ? text : text.replaceAll('＼', '_');
  }

  //public static String getZenkakuBackslashToWildcard1(String text) {
  //  String result; // = text.replaceAll('＼', '_');
  //  if (text.contains('＼')) {
  //    // ＼ があったら
  //    if (text.contains('\'')) {
  //      //// ' シングルクオートがある
  //      //String str = EncodingUtil.urlEncode(text, 'UTF-8');
  //      //Blob b = Blob.valueOf(str);
  //      //String b64 = EncodingUtil.base64Encode(b);
  //      //result = result.replaceAll('\'',b64);   // ' 絶対ユニークな文字列にしておく
  //      ////result = String.escapeSingleQuotes(result.replaceAll('＼', '_'));
  //      result = text.replaceAll('＼', '_');
  //      //result = result.replaceAll(b64,'\'');
  //    }
  //    else {
  //      // ' シングルクオートはない
  //      //result = String.escapeSingleQuotes(result.replaceAll('＼', '_'));
  //      result = String.escapeSingleQuotes(text.replaceAll('＼', '_'));
  //    }
  //  }
  //  //else if (text.contains('\'') == false && text.contains('\\')== false)  {
  //  //  // ＼  がなく  ' シングルクオート、と \ 半角バックスラッシュともない。
  //  //  // aaa\\aaa のような バックスラッシュ2つのとき、ヒットしないので、エスケープする
  //  //  result = String.escapeSingleQuotes(text);
  //  //}
  //  // ＼  か \  ともなく ' シングルクオートがあったら、そのまま
  //  return result;
  //}

  // SOQLで 部分一致検索 するときは、これを通した文字列を使う
  global static String getStringForPartialMatch(String str) {
    if (String.isBlank(str)) {
      return str;
    }
    //アポストロフィーがある場合、escapeSingleQuotesメソッドがエスケープされるはずですが、
    //なぜかうまくエスケープできてないので、エスケープする前にアポストロフィーをbase64を使って暗号化して、エスケープ後に元に戻す
    String result;
    Blob b = Blob.valueOf(EncodingUtil.urlEncode(str, 'UTF-8'));
    String b64 = EncodingUtil.base64Encode(b);
    result = str.replaceAll('\'',b64);
    result = String.escapeSingleQuotes(result.replaceAll('＼', '_'));
    result = result.replaceAll(b64,'\'');
    return result;
  }

  //  String result = text;
  //  //  ＼   があったら
  //  if (text.contains('＼')) {
  //    // ＼ があったら
  //    if (text.contains('\'')) {
  //      // ' シングルクオートがある
  //      String str = EncodingUtil.urlEncode(text, 'UTF-8');
  //      Blob b = Blob.valueOf(str);
  //      String b64 = EncodingUtil.base64Encode(b);
  //      result = result.replaceAll('\'',b64);   // ' 絶対ユニークな文字列にしておく
  //      //result = String.escapeSingleQuotes(result.replaceAll('＼', '_'));
  //      result = result.replaceAll('＼', '_');
  //      result = result.replaceAll(b64,'\'');
  //    }
  //    else {
  //      // ' シングルクオートはない
  //      //result = String.escapeSingleQuotes(result.replaceAll('＼', '_'));
  //      result = result.replaceAll('＼', '_');
  //    }
  //  }
  //  // ＼  か \  ともなく ' シングルクオートがあったら、そのまま
  //  return result;
  //}

  // v1.22 オブジェクトの項目のコレクションを取得
  public static Set<String> getValidFields(SObjectType otype) {
    Set<String> result = new Set<String>();
    Schema.DescribeSObjectResult dsr = otype.getDescribe();

    Map<String, Schema.SObjectField > fields = dsr.fields.getMap();
    for (Schema.SObjectField f : fields.values()) {
      Schema.DescribeFieldResult dfr = f.getDescribe();
      if (!dsr.isCustom() || dfr.isCustom()) {
        // 標準オブジェクトは標準項目含め全て
        // カスタムオブジェクトは カスタムオ項目のみ
        result.add(dfr.getName());
      }
    }
    result.add('Id');
    result.add('Name');
    result.add('CreatedDate');
    result.add('CreatedById');
    result.add('LastModifiedDate');
    result.add('LastModifiedById');
    result.add('OwnerId');
    return result;
  }

  // v1.22 オブジェクトを指定してクエリ文を取得
  public static String getQueryText(SObjectType otype) {
    String oname = otype.getDescribe().getName();
    String fields = String.join(new List<String>(getValidFields(otype)), ', ');
    return String.format('SELECT {0} FROM {1}', new String[] {fields, oname});
  }

  // v1.22 オブジェクトを指定してクエリ文を取得 Where句あり
  public static String getQueryText(SObjectType otype, String condition) {
    System.assert(String.isNotBlank(condition));
    String oname = otype.getDescribe().getName();
    String fields = String.join(new List<String>(getValidFields(otype)), ', ');
    return String.format('SELECT {0} FROM {1} WHERE {2}', new String[] {fields, oname, condition});
  }

  // v1.22 オブジェクトを指定してクエリ文を取得 Where句あり Order By 句あり
  public static String getQueryText(SObjectType otype, String condition, String orderby) {
    System.assert(String.isNotBlank(condition));
    System.assert(String.isNotBlank(orderby));
    String oname = otype.getDescribe().getName();
    String fields = String.join(new List<String>(getValidFields(otype)), ', ');
    return String.format('SELECT {0} FROM {1} WHERE {2} ORDER BY {3}', new String[] {fields, oname, condition, orderby});
  }

  // v.1.22 2017.07.xx Lead  拡張パッケージが入ってるかどうか
  private static Boolean enableLeadExtention = null;
  global static Boolean isEnableLeadExtention() {
    if (enableLeadExtention == null) {
      enableLeadExtention = false;
      // Lead 拡張パッケージのAPEXクラスがある か、 名前空間名が SmartViscal のクラスがある
      List<ApexClass> classes = [SELECT Name, NamespacePrefix FROM ApexClass WHERE Name IN ('SB_NameCard_LeadBulkRegistController', 'SB_NameCard_LeadNameCardListController', 'SB_NameCard_LeadRegistController') OR NamespacePrefix='SmartViscal'];
      if (!classes.isEmpty()) {
        enableLeadExtention = true;
      }
    }
    return enableLeadExtention;
  }

  // v.1.22 2017.07.xx V1.12 以降の Lead連携拡張パッケージがインストールされているか
  //    Publisher をクエリするので、 APIバージョンを 41.0
  private static Boolean enableLeadExt112 = null;
  //
  private static final Set<Id> DEV_ORG_IDS = new Set<Id> {'00D6F000001ulxy'}; // svdev01
  global static Boolean isEnableLeadExt112() {
    if (enableLeadExt112 == null) {
      enableLeadExt112 = false;
      // Lead連携拡張パッケージがインストールされているか
      List<Publisher> pubs = [SELECT Id, DurableId, Name, NamespacePrefix, MajorVersion, MinorVersion, IsSalesforce FROM Publisher WHERE NamespacePrefix = 'SmartViscal'];
      if (!pubs.isEmpty()) {
        enableLeadExt112 = pubs[0].MajorVersion > 1 || pubs[0].MinorVersion >= 12;
      }
      else {
        // 1.12 以降の Lead連携拡張パッケージ テスト環境?
        List<ApexClass> classes = [SELECT Name, NamespacePrefix FROM ApexClass WHERE Name = 'SB_NameCardL_RenkeiTriggerHandler'];
        enableLeadExt112 = !classes.isEmpty();
      }
    }
    return enableLeadExt112 || DEV_ORG_IDS.contains(UserInfo.getOrganizationId());    // 開発組織も
  }

  // v.2.4  2019.08.xx V2.1 以降の Lead連携拡張パッケージがインストールされているか
  private static Boolean enableLeadExt21 = null;
  global static Boolean isEnableLeadExt21() {
    if (enableLeadExt21 == null) {
      enableLeadExt21 = false;
      // Lead連携拡張パッケージがインストールされているか
      List<Publisher> pubs = [SELECT Id, DurableId, Name, NamespacePrefix, MajorVersion, MinorVersion, IsSalesforce FROM Publisher WHERE NamespacePrefix = 'SmartViscal'];
      if (!pubs.isEmpty()) {
        enableLeadExt21 = pubs[0].MajorVersion >= 2 && pubs[0].MinorVersion >= 1;
      }
      // SB_NameCardL_RenkeiTriggerHandlerで判定するとLX2.0.1がインストールされている環境でもTrueが返ってしまうので、
      // 次期LXパッケージで新規クラスが追加されてから実装します...
      //else {
        // 追加モジュール未定のため暫定で 1.12 以降の追加クラスが含まれるかで判定
        // List<ApexClass> classes = [SELECT Name, NamespacePrefix FROM ApexClass WHERE Name = 'SB_NameCardL_RenkeiTriggerHandler'];
        // enableLeadExt21 = !classes.isEmpty();
      //}
    }
    return enableLeadExt21 || DEV_ORG_IDS.contains(UserInfo.getOrganizationId());    // 開発組織も
  }


  // リード拡張パッケージの名前空間名を返します。 v1.22 2018.01.xx
  global static String getLeadExNamespacePrefix_x() { return String.isEmpty(leadExNamespacePrefix) ? '' : leadExNamespacePrefix+'__'; }
  global static String getLeadExNamespacePrefix() { return leadExNamespacePrefix; }
  private static String leadExNamespacePrefix {
    get {
      if (leadExNamespacePrefix ==null) {
        List<AggregateResult> ars = [SELECT Count(Id) CNT, NamespacePrefix FROM ApexClass
                WHERE Name IN ('SB_NameCard_LeadBulkRegistController', 'SB_NameCard_LeadNameCardListController', 'SB_NameCard_LeadRegistController', 'SB_NameCardL_RenkeiTriggerHandler')
                      OR NamespacePrefix='SmartViscal'
                GROUP BY NamespacePrefix];

        if (ars.size() == 1) {
          leadExNamespacePrefix = (String)ars[0].get('NamespacePrefix');
          leadExNamespacePrefix = String.isNotBlank(leadExNamespacePrefix) ? leadExNamespacePrefix : '';
        }
        else if (ars.size() > 1) {
           leadExNamespacePrefix = 'SmartViscal';
        }
        else {
          leadExNamespacePrefix = '';
        }
      }
      return leadExNamespacePrefix;
    }
    private set;
  }

  // v.1.22 2017.07.xx 個人取引先をサポートした組織か？
  private static Boolean enablePersonAccount = null;
  global static Boolean isEnablePersonAccount() {
    if (enablePersonAccount == null) {
      enablePersonAccount = Account.getSObjectType().getDescribe().fields.getMap().get('IsPersonAccount') != null;
    }
    return enablePersonAccount;
  }

  //オブジェクトデフォルトのレコードタイプIDを取得
  public static String getDefaultRecordType(SObjectType otype){
    String recordTypeId;
    List<Schema.RecordTypeInfo> rs =  otype.getDescribe().getRecordTypeInfos();
    for (RecordTypeInfo r : rs) {
        if (r.isDefaultRecordTypeMapping() && r.isAvailable() && !r.isMaster()) {
             recordTypeId = r.getRecordTypeId();
        }
    }
    return recordTypeId;
  }

  // getLabelした際に「取引先 ○○」(例：取引先 電話 英語例：Account Phone)形式で取れてしまう事象への対策、
  // 第一引数オブジェクトの第二引数項目のラベルについてオブジェクト名+半角スペースを除去した文字列を返却する
  public static String getDesirableLabel(String objName, String fieldName) {
    try{
      DescribeSObjectResult sObjectDescribe = Schema.getGlobalDescribe().get(objName).getDescribe();
      String objLabel = sObjectDescribe.getLabel();
      String fieldLabel = sObjectDescribe.fields.getMap().get(fieldName).getDescribe().getLabel();
      return fieldLabel.replace(objLabel + ' ', '');
    }  catch (Exception e) {
      return '';
    }
  }
}