/**
 *
 * SB_NameCard_RenkeiMapperUtil
 * 名刺、オブジェクトのAPI項目の区間スペース追加及消すの処理
 * オブジェクトの項目Mapを作成(連携マッピング機能に合わせて,追加及表示しないの項目処理を行っています)
 * SV_DEV-556 名刺：住所を取引先/取引先責任者のカスタム項目にマッピングするとエラーが発生する
 *
 *  Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.20      2017.02.XX
 *  @Version 1.20.2    2017.09.XX  SV_DEV-556  名刺：住所を取引先/取引先責任者のカスタム項目にマッピングするとエラーが発生する
 *  @Version 1.22      2017.10.XX  SV_DEV-630  マッピング編集画面に「ficuspop__Title_and_Name__c」が表示されてしまっている
 *  @Version 1.22      2017.10.xx  SV_DEV-640   個人取引先を有効化している場合、マッピングで取引差責任者のカスタム項目を区別するか表示しない
 *  @Version 1.22      2017.11.XX  SV_DEV-690  連携マッピング項目設定する際に、IDの項目設定する際に、URL、Emailが候補一覧に出てしまいました
 *  @Version 2.1       2018.04.XX  SV_DEV-876  連携設定条件に名刺項目に参照項目が選択できないことを変更
 *  @Version 2.4       2019.06.XX  SV_DEV-XXXX SmartVisca 基本設定機能追加
 *  @Version 2.5       2020.01.XX  SV_DEV-2437 SV設定：名刺 日付型項目→取引先責任者 誕生日 のマッピングが行えない
 *
 **/

public with sharing class SB_NameCard_RenkeiMapperUtil{

  //名刺住処を分けで処理
  public static final Set<String> ADDRESS_FIELDS = new Set<String> {'city', 'street','address__c','pref_address_bld','address_bld','street_nobld'};
  //個人取引先項目
  public static final Set<String> PERSONALACCOUNT = new Set<String> {'firstname', 'lastname','middlename','suffix', 'salutation', 'informalname'};
  public static String getNamespacePrefix_x() { return String.isEmpty(namespacePrefix) ? '' : namespacePrefix+'__'; }
  public static String getNamespacePrefix() { return namespacePrefix; }
  private static String namespacePrefix {
    get {
      if (namespacePrefix ==null) {
        list<ApexClass> classes = [select Name, NamespacePrefix from ApexClass where Name='SB_NameCard_Util' limit 1];
        if (classes.isEmpty() == false)
        namespacePrefix = classes[0].NamespacePrefix != null ? classes[0].NamespacePrefix : '';
      }
      return namespacePrefix;
    }
    private set;
  }

  public static Map<String,Schema.SObjectType> schemaMap{
    get{
      if (schemaMap == null) {
        schemaMap = Schema.getGlobalDescribe();
      }
      return schemaMap;
    }
    private set;
  }

  //今回ネームスペース付けられるのオブジェクト
  private static final Set<String> SV_OBJECT_NAMES = new Set<String> {
      'namecard__c',
      'namecardhistory__c',
      'namecardrenkeimapping__c',
      'jinjiido__c',
      'jinjiidoemail__c',
      'namecardhistory__c',
      'namecardbasicsetting__c',
      'namecardrenkeijyoken__c',
      'namecardsettingvalues__c',
      'all',
      'lead'
 };

  public static final Set<String> DONT_USE_MAPPING = new Set<String>{'Company_Name_Kana_1stA__c',     // 会社（カナ）の最初の1文字のア段 数式 (テキスト)
                                                                     'Company_Name_Kana_1st__c',      // 会社（カナ）の最初の1文字      数式 (テキスト)
                                                                     'GeoLocation__Latitude__s',      // 緯度経度(Latitude)          地理位置情報 (数値)
                                                                     'GeoLocation__Longitude__s',     // 緯度経度(Longitude)         地理位置情報 (数値)
                                                                     'GeoLocation__c',                // 緯度経度                    地理位置情報
                                                                     'GetJinjiIdoDate__c',            // 人事異動情報取得日            日付
                                                                     'GetJinjiIdoExec__c',            // 人事異動情報取得中            チェックボックス
                                                                     'GetJinjiIdo__c',                // 人事異動情報取得              チェックボックス
                                                                     'ParentLink__c',                 // 最新名刺                    数式 (テキスト)
                                                                     'Parent__c',                     // 最新名刺                    参照関係(名刺)
                                                                     'Person_Name_Last_Kana_1stA__c', // 姓カナの1文字目ア段           数式 (テキスト)
                                                                     'Person_Name_Last_Kana_1st__c',  // 姓カナの1文字目              数式 (テキスト)
                                                                     'Saishin__c',                    // この名刺が最新               チェックボックス
                                                                     'Title_and_Name__c',             // 役職                       数式 (テキスト)
                                                                     'accountLink__c',                // 取引先                      数式 (テキスト)
                                                                     'accountRegDateTime__c',         // 取引先取込日時               日付/時間
                                                                     // 'account__c' 連携先から名刺に設定   SB_NameCard_RenkeiMappingLcController で選択肢から外してます
                                                                     // 'address__c' cityなどに変更
                                                                     'bk_direction__c',               // 裏画像縦横フラグ             テキスト(1)
                                                                     'bk_height__c',                  // 裏画像縦サイズ               数値(4、0)
                                                                     'bk_image__c',                   // 裏面                       数式 (テキスト)
                                                                     'bk_image_id__c',                // 裏画像ID                   テキスト(18)
                                                                     'bk_thumbnail__c',               // サムネイル（裏面）           数式 (テキスト)
                                                                     'bk_thumbnail_id__c',            // 裏サムネイルID              テキスト(18)
                                                                     'bk_width__c',                   // 裏画像横サイズ               数値(4、0)
                                                                     'branch_name__c',                // 支社支店                    テキスト(255)
                                                                     'contactLink__c',                // 取引先責任者                 数式 (テキスト)
                                                                     'contact__c',                    // 取引先責任者                 参照関係(取引先責任者)
                                                                     'delivery_icon__c',              // 納品状態                    数式 (テキスト)
                                                                     'delivery_type__c',              // 納品タイプ                  テキスト(10)
                                                                     'direction__c',                  // 表画像縦横フラグ             テキスト(1)
                                                                     'env_machine_name__c',           // コンピュータ名               テキスト(255)
                                                                     'error__c',                      // エラー情報                  テキストエリア(255)
                                                                     'fax2__c',                       // FAX番号2                   電話
                                                                     'freehandmemo_flag__c',          // 手書きメモも入力する          チェックボックス
                                                                     'height__c',                     // 表画像縦サイズ               数値(4、0)
                                                                     'image__c',                      // 表面                       数式 (テキスト)
                                                                     'image_id__c',                   // 表画像ID                   テキスト(18)
                                                                     'isNotOverContactwrite__c',      // 既存取引先責任者上書き不可    チェックボックス
                                                                     'isNotOverwrite__c',             // 既存取引先上書き不可         チェックボックス
                                                                     'key__c',                        // キー                      テキスト(255) (外部 ID)
                                                                     'latitude__c',                   // 緯度                      数値(2、10)
                                                                     'leadLink__c',                   // リード                    数式 (テキスト)
                                                                     'leadRegDateTime__c',            // リード取込日時              日付/時間
                                                                     'lead__c',                       // リード                     参照関係(リード)
                                                                     'location__c',                   // 登録場所                   数式 (テキスト)
                                                                     'longitude__c',                  // 経度                      数値(3、10)
                                                                     'portrait__c',                   // 写真                      数式 (テキスト)
                                                                     'portrait_id__c',                // 写真ID                    テキスト(18)
                                                                     'tenshokugonomeishi__c',         // 転職後の名刺                参照関係(名刺)
                                                                     'tenshokuzumi__c',               // 転職済み                   チェックボックス
                                                                     'thumbnail__c',                    // サムネイル               数式 (テキスト)
                                                                     'thumbnail_base64__c',           // base64サムネイル            ロングテキストエリア(10000)
                                                                     'thumbnail_id__c',               // 表サムネイルID              テキスト(18)
                                                                     'web_url2__c',                   // URL2                      URL(255)
                                                                     'width__c',                      // 表画像横サイズ               数値(4、0)
                                                                     'SystemModstamp',                // SystemModstamp            日付/時間
                                                                     'LastModifiedById',              // 最終更新者  ID              ID
                                                                     'LastActivityDate',              // 最終活動日                  日付
                                                                     'LastViewedDate',                // 最終参照日                  日付/時間
                                                                     'LastReferencedDate',            // 最終参照日                  日付/時間
                                                                     'IsDeleted',                     // 削除　                     チェックボックス
                                                                     'leadLink_del__c',               // 
                                                                     'google_map__c'                  //

                                                };

  public static final Set<String> DONT_USE_SETTING = new Set<String>{'Company_Name_Kana_1stA__c',     // 会社（カナ）の最初の1文字のア段 数式 (テキスト)
                                                                     'Company_Name_Kana_1st__c',      // 会社（カナ）の最初の1文字      数式 (テキスト)
                                                                     'GeoLocation__Latitude__s',      // 緯度経度(Latitude)          地理位置情報 (数値)
                                                                     'GeoLocation__Longitude__s',     // 緯度経度(Longitude)         地理位置情報 (数値)
                                                                     'GeoLocation__c',                // 緯度経度                    地理位置情報
                                                                     'GetJinjiIdoDate__c',            // 人事異動情報取得日            日付
                                                                     'GetJinjiIdoExec__c',            // 人事異動情報取得中            チェックボックス
                                                                     'GetJinjiIdo__c',                // 人事異動情報取得              チェックボックス
                                                                     'ParentLink__c',                 // 最新名刺                    数式 (テキスト)
                                                                     // 'Parent__c',                     // 最新名刺                    参照関係(名刺)
                                                                     'Person_Name_Last_Kana_1stA__c', // 姓カナの1文字目ア段           数式 (テキスト)
                                                                     'Person_Name_Last_Kana_1st__c',  // 姓カナの1文字目              数式 (テキスト)
                                                                     'Saishin__c',                    // この名刺が最新               チェックボックス
                                                                     'Title_and_Name__c',             // 役職                       数式 (テキスト)
                                                                     'accountLink__c',                // 取引先                      数式 (テキスト)
                                                                     'accountRegDateTime__c',         // 取引先取込日時               日付/時間
                                                                     'bk_direction__c',               // 裏画像縦横フラグ             テキスト(1)
                                                                     'bk_height__c',                  // 裏画像縦サイズ               数値(4、0)
                                                                     'bk_image__c',                   // 裏面                       数式 (テキスト)
                                                                     'bk_image_id__c',                // 裏画像ID                   テキスト(18)
                                                                     'bk_thumbnail__c',               // サムネイル（裏面）           数式 (テキスト)
                                                                     'bk_thumbnail_id__c',            // 裏サムネイルID              テキスト(18)
                                                                     'bk_width__c',                   // 裏画像横サイズ              数値(4、0)
                                                                     'branch_name__c',                // 支社支店                   テキスト(255)
                                                                     'contactLink__c',                // 取引先責任者                数式 (テキスト)
                                                                     // 'contact__c',                    // 取引先責任者                参照関係(取引先責任者)
                                                                     'delivery_icon__c',              // 納品状態                   数式 (テキスト)
                                                                     'delivery_type__c',              // 納品タイプ                 テキスト(10)
                                                                     'direction__c',                  // 表画像縦横フラグ            テキスト(1)
                                                                     'env_machine_name__c',           // コンピュータ名              テキスト(255)
                                                                     'error__c',                      // エラー情報                 テキストエリア(255)
                                                                     'fax2__c',                       // FAX番号2                  電話
                                                                     'freehandmemo_flag__c',          // 手書きメモも入力する        チェックボックス
                                                                     'height__c',                     // 表画像縦サイズ             数値(4、0)
                                                                     'image__c',                      // 表面                      数式 (テキスト)
                                                                     'image_id__c',                   // 表画像ID                  テキスト(18)
                                                                     'isNotOverContactwrite__c',      // 既存取引先責任者上書き不可   チェックボックス
                                                                     'isNotOverwrite__c',             // 既存取引先上書き不可        チェックボックス
                                                                     'key__c',                        // キー                     テキスト(255) (外部 ID)
                                                                     'latitude__c',                   // 緯度                      数値(2、10)
                                                                     'leadLink__c',                   // リード                     数式 (テキスト)
                                                                     'leadRegDateTime__c',            // リード取込日時              日付/時間
                                                                     // 'lead__c',                       // リード                     参照関係(リード)
                                                                     'location__c',                   // 登録場所                   数式 (テキスト)
                                                                     'longitude__c',                  // 経度                      数値(3、10)
                                                                     'portrait__c',                   // 写真                      数式 (テキスト)
                                                                     'portrait_id__c',                // 写真ID                    テキスト(18)
                                                                     // 'tenshokugonomeishi__c',         // 転職後の名刺                参照関係(名刺)
                                                                     'thumbnail__c',                  // サムネイル                  数式 (テキスト)
                                                                     'thumbnail_base64__c',           // base64サムネイル            ロングテキストエリア(10000)
                                                                     'thumbnail_id__c',               // 表サムネイルID              テキスト(18)
                                                                     'web_url2__c',                   // URL2                      URL(255)
                                                                     'width__c',                      // 表画像横サイズ               数値(4、0)
                                                                     'SystemModstamp',                // SystemModstamp            日付/時間
                                                                     'LastModifiedById',              // 最終更新者  ID             ID
                                                                     'LastActivityDate',              // 最終活動日                 日付
                                                                     'LastViewedDate',                // 最終参照日                  日付/時間
                                                                     'LastReferencedDate',            // 最終参照日                  日付/時間
                                                                     'IsDeleted',                     // 削除　                     チェックボックス
                                                                     'leadLink_del__c',               // 
                                                                     'google_map__c'                  //
                                                                      };
  //マッピングしないの
  //SV_DEV-2437 取引先/取引先責任者(/リード)の日付(/時刻)型 標準項目はマッピングできるよう修正するにあたって、除外するシステム項目を追加(SystemModstamp以降)
  public static final Set<String> DONT_MAPPING = new Set<String>{'IsDeleted',           // 削除           チェックボックス
                                                                 'Id',                  // Id            ID
                                                                 'ParentId',            // 親Id           REFERENCE
                                                                 'LastModifiedById',    // 最終更新者Id     REFERENCE
                                                                 'LastModifiedDate',    // 最終更新日       日付/時間
                                                                 'CreatedDate',         // 作成者日         日付/時間
                                                                 'CreatedById',         // 作成者Id        REFERENCE
                                                                 'SystemModstamp',      // SystemModstamp  日付/時間
                                                                 'LastActivityDate',    // 最終活動日       日付
                                                                 'LastViewedDate',      // 最終閲覧日       日付/時間
                                                                 'LastReferencedDate',  // 最終参照日       日付/時間
                                                                 'LastCURequestDate',   // 登録情報照会 最終依頼日 日付/時間
                                                                 'LastCUUpdateDate'     // 登録情報照会 最終更新日 日付/時間
                                                                };
  public static final Set<String> DONT_ACCOUNT = new Set<String>{'MasterRecordId',                // マスタレコード ID             REFERENCE
                                                                 'RecordTypeId',                  // レコードタイプ ID             REFERENCE
                                                                 'JigsawCompanyId',               // Jigsaw Company              STRING
                                                                 'PhotoUrl',                      // 写真の URL                   URL
                                                                 'BillingGeocodeAccuracy',        // Billing Geocode Accuracy    PICKLIST
                                                                 'ShippingGeocodeAccuracy',       // Shipping Geocode Accuracy   PICKLIST
                                                                 'PersonOtherGeocodeAccuracy',    // Other Geocode Accuracy      PICKLIST
                                                                 'PersonMailingGeocodeAccuracy',  // Mailing Geocode Accuracy    PICKLIST
                                                                 'IsPersonAccount',               // 個人取引先                    BOOLEAN
                                                                 'PersonEmailBouncedReason',      // メール不達の理由               STRING
                                                                 'PersonEmailBouncedDate'        // メール不達発生日               DATETIME
                                                               };
  public static final Set<String> DONT_CONTACT = new Set<String>{'Name',                     // 氏名                       STRING
                                                                 'IsEmailBounced',           // メール不達                  BOOLEAN
                                                                 'MasterRecordId',           // マスタレコード ID            REFERENCE
                                                                 'AccountId',                // 取引先 ID                   REFERENCE
                                                                 'RecordTypeId',             // レコードタイプ ID            REFERENCE
                                                                 'ReportsToId',              // 上司 ID                    REFERENCE
                                                                 'JigsawContactId',          // Jigsaw Contact ID         STRING
                                                                 'PhotoUrl',                 // 写真の URL                 URL
                                                                 'OtherGeocodeAccuracy',     // Other Geocode Accuracy    PICKLIST
                                                                 'MailingGeocodeAccuracy',   // Mailing Geocode Accuracy  PICKLIST
                                                                 'EmailBouncedReason',       // メール不達の理由                 STRING
                                                                 'EmailBouncedDate'         // メール不達発生日                 DATETIME
                                                               };
  public static final Set<String> DONT_LEAD = new Set<String>{'IsConverted',                // 取引先開始済み                   BOOLEAN
                                                              'IsUnreadByOwner',            // 所有者 未読フラグ                BOOLEAN
                                                              'Name',                       // 氏名                           TEXT
                                                              'Latitude',                   // 緯度                           DOUBLE
                                                              'Longitude',                  // 緯度                           DOUBLE
                                                              'GeocodeAccuracy',            // Geocode Accuracy              PICKLIST
                                                              'PhotoUrl',                   // 写真の URL                     URL
                                                              'ConvertedDate',              // 取引開始日                      DATE
                                                              'ConvertedAccountId',         // 取引開始済みの取引先 ID          REFERENCE
                                                              'ConvertedContactId',         // 取引開始済みの取引先責任者 ID     REFERENCE
                                                              'ConvertedOpportunityId',     // 取引開始済みの商談 ID            REFERENCE
                                                              'SystemModstamp',             // SystemModstamp                DATETIME
                                                              'LastActivityDate',           // 最終活動日                      DATE
                                                              'LastViewedDate',             // 最終参照日                      DATETIME
                                                              'LastReferencedDate',         // 最終参照日                      DATETIME
                                                              'EmailBouncedReason',         // メール不達の理由                 STRING
                                                              'EmailBouncedDate',           // メール不達発生日                 DATETIME
                                                              'JigsawContactId',            // Contact ID                    STRING
                                                              'LastTransferDate'            //  最終移行日                     Date
                                                            };
  // パッケージ内項目と同じAPI名のカスタム項目があればパッケージの項目を優先
  public static final Set<String> US_NC_PACKGE = new Set<String>{'company_name_kana_1sta__c',      // 会社（カナ）の最初の1文字のア段 数式 (テキスト)
                                                                'company_name_kana_1st__c',        // 会社（カナ）の最初の1文字      数式 (テキスト)
                                                                'geolocation__latitude__s',        // 緯度経度(Latitude)          地理位置情報 (数値)
                                                                'geolocation__longitude__s',       // 緯度経度(Longitude)         地理位置情報 (数値)
                                                                'geolocation__c',                  // 緯度経度                    地理位置情報
                                                                'getjinjiidodate__c',              // 人事異動情報取得日            日付
                                                                'getjinjiidoexec__c',              // 人事異動情報取得中            チェックボックス
                                                                'getjinjiido__c',                  // 人事異動情報取得              チェックボックス
                                                                'parentlink__c',                   // 最新名刺                    数式 (テキスト)
                                                                'parent__c',                       // 最新名刺                    参照関係(名刺)
                                                                'person_name_last_kana_1sta__c',   // 姓カナの1文字目ア段           数式 (テキスト)
                                                                'person_name_last_kana_1st__c',    // 姓カナの1文字目              数式 (テキスト)
                                                                'saishin__c',                      // この名刺が最新               チェックボックス
                                                                'title_and_name__c',               // 役職                       数式 (テキスト)
                                                                'accountlink__c',                  // 取引先                      数式 (テキスト)
                                                                'accountregdatetime__c',           // 取引先取込日時               日付/時間
                                                                'account__c',                      // 取引先                      参照関係(取引先)
                                                                'address__c',                      // 住所                        テキスト(255)
                                                                'address_bld__c',                  // 建物名                      テキスト(255)
                                                                'address_eng__c',                  // 英語住所                     テキストエリア(255)
                                                                'address_pref__c',                 // 都道府県                     テキスト(10)
                                                                'bk_direction__c',                 // 裏画像縦横フラグ              テキスト(1)
                                                                'bk_height__c',                    // 裏画像縦サイズ               数値(4、0)
                                                                'bk_image__c',                     // 裏面                       数式 (テキスト)
                                                                'bk_image_id__c',                  // 裏画像ID                   テキスト(18)
                                                                'bk_thumbnail__c',                 // サムネイル（裏面）           数式 (テキスト)
                                                                'bk_thumbnail_id__c',              // 裏サムネイルID              テキスト(18)
                                                                'bk_width__c',                     // 裏画像横サイズ               数値(4、0)
                                                                'branch_name__c',                  // 支社支店                    テキスト(255)
                                                                'campaing__c',                     // キャンペーン                 参照関係(キャンペーン)
                                                                'card_exchange_date__c',           // 名刺交換日                   日付
                                                                'card_id__c',                      // 名刺ID                      テキスト(18)
                                                                'company_name__c',                 // 会社名                      テキスト(255)
                                                                'company_name_kana__c',            // 会社名カナ                   テキスト(255)
                                                                'contactlink__c',                  // 取引先責任者                 数式 (テキスト) 
                                                                'contact__c',                      // 取引先責任者                 参照関係(取引先責任者)
                                                                'date__c',                         // 日付                        数式 (日付)
                                                                'delivery_icon__c',                // 納品状態                     数式 (テキスト)
                                                                'delivery_type__c',                // 納品タイプ                   テキスト(10)
                                                                'direction__c',                    // 表画像縦横フラグ              テキスト(1)
                                                                'division__c',                     // 所属                        テキスト(255)
                                                                'division_name__c',                // 所属役職                     テキストエリア(255)
                                                                'email__c',                        // メールアドレス                メール
                                                                'env_machine_name__c',             // コンピュータ名               テキスト(255)
                                                                'error__c',                        // エラー情報                  テキストエリア(255)
                                                                'fax1__c',                         // FAX番号                    電話
                                                                'fax2__c',                         // FAX番号2                   電話
                                                                'first_name__c',                   // ファーストネーム             テキスト(80)
                                                                'freehandmemo__c',                 // 手書きメモ                  テキストエリア(255)
                                                                'freehandmemo_flag__c',            // 手書きメモも入力する          チェックボックス
                                                                'height__c',                       // 表画像縦サイズ               数値(4、0)
                                                                'image__c',                        // 表面                       数式 (テキスト)
                                                                'image_id__c',                     // 表画像ID                   テキスト(18)
                                                                'isnotovercontactwrite__c',        // 既存取引先責任者上書き不可    チェックボックス
                                                                'isnotoverwrite__c',               // 既存取引先上書き不可         チェックボックス
                                                                'key__c',                          // キー                      テキスト(255) (外部 ID)
                                                                'last_name__c',                    // ラストネーム                テキスト(80)
                                                                'latitude__c',                     // 緯度                      数値(2、10)
                                                                ' leadlink__c',                    // リード                    数式 (テキスト)
                                                                'leadregdatetime__c',              // リード取込日時             日付/時間
                                                                'lead__c',                         // リード                    参照関係(リード)
                                                                'list_name__c',                    // リスト名                  テキスト(255)
                                                                'location__c',                     // 登録場所                  数式 (テキスト)
                                                                'longitude__c',                    // 経度                      数値(3、10)
                                                                'memo__c',                         // メモ                     テキスト(255)
                                                                'middle_name__c',                  // ミドルネーム              テキスト(80)
                                                                'mobile__c',                       // 携帯電話番号              電話
                                                                'name_kana__c',                    // 氏名カナ                 数式 (テキスト)
                                                                'person_name_first__c',            // 名                      テキスト(127)
                                                                'person_name_first_kana__c',       // 名カナ                   テキスト(255)
                                                                'person_name_last__c',             // 姓                      テキスト(127)
                                                                'person_name_last_kana__c',        // 姓カナ                   テキスト(255)
                                                                'portrait__c',                     // 写真                    数式 (テキスト)
                                                                'portrait_id__c',                  // 写真ID                  テキスト(18)
                                                                'tel1__c',                         // 電話番号                 電話
                                                                'tel2__c',                         // 電話番号2                電話
                                                                'tenshokugonomeishi__c',           // 転職後の名刺              参照関係(名刺)
                                                                'tenshokuzumi__c',                 // 転職済み                 チェックボックス
                                                                'thumbnail__c',                    // サムネイル               数式 (テキスト)
                                                                'thumbnail_base64__c',             // base64サムネイル         ロングテキストエリア(10000)
                                                                'thumbnail_id__c',                 // 表サムネイルID           テキスト(18)
                                                                'title_name__c',                   // 役職                    テキスト(255)
                                                                'web_url1__c',                     // URL                    URL(255)
                                                                'web_url2__c',                     // URL2                   URL(255)
                                                                'width__c',                        // 表画像横サイズ           数値(4、0)
                                                                'zip_code__c'                      // 郵便番号                テキスト(10)
                                                              };
 
  public static Map<String,List<String>> createApiNameKeyDataTypeMap(String objName,Map<String,String> apiNameKeyDataTypeMap,Map<String,String> apiNameKeyLabelNameMap,String objectName,Boolean isSetting){

    Map<String,List<String>>   typeMap = new Map<String,List<String>>  ();
    Map<String,Set<Schema.SObjectType>> typMap = getTypeMap(getManagedobjectName(objName));

    String remostr = '';
    for(Schema.SObjectField sField : SB_NameCard_RenkeiMapperUtil.getobjmap(objName).Values()) {
      Schema.describefieldresult dField = sField.getDescribe();
      //SV_DEV-2437 取引先/取引先責任者(/リード)の日付(/時刻)型 標準項目はマッピングできるよう修正
      //if ((DONT_MAPPING.contains(dField.name) && objName != 'NameCard__c') || ((objName == 'Account' || objName == 'Contact') && !dField.isCustom() && (dField.getType() == Schema.DisplayType.DATETIME || dField.getType() == Schema.DisplayType.DATE))) {
      if (DONT_MAPPING.contains(dField.name) && objName != 'NameCard__c'){
        continue;
      }
      // パッケージ内項目と同じAPI名のカスタム項目があればパッケージの項目を優先
      if (objName == 'NameCard__c' && US_NC_PACKGE.contains(dField.name.toLowerCase()) && dField.isCustom() && String.isNotBlank(SB_NameCard_Util.getNamespacePrefix_x())) {
        continue;
      }

      if ((objName == 'Account' && DONT_ACCOUNT.contains(dField.name))
          || (objName == 'Contact' && DONT_CONTACT.contains(dField.name))
          || (objName == 'Lead' && DONT_LEAD.contains(dField.name))
          //マッピングの場合，数式と自動採番項目は値を設定できないため，名刺以外のオブジェクトには数式と自動採番項目を選択させません
          || ((dField.isAutoNumber() || dField.isCalculated()) && objName != 'NameCard__c')) {
        continue;
      }

      if (!isSetting) {
        System.debug(SB_NameCard_RenkeiMapperUtil.getdeManagedfileName(objName,dField.name));
        System.debug(objName);

        if (dField.name == SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCard__c','address__c') && objName == 'NameCard__c') {
          for(String  str : ADDRESS_FIELDS) {
            //SV_DEV-556
            apiNameKeyDataTypeMap.put(str == 'address__c' ? dField.name : str,'STRING');
            String label = ''; 
            System.debug(str);
            if (str == 'city') {
              label = System.Label.SB_NC_City;
            } else if (str == 'street_nobld') {
              label = System.Label.SB_NC_Street;
            } else if (str == 'address__c') {
              label = System.Label.SB_NC_Address;
              str = dField.name;
            } else if (str == 'pref_address_bld') {
              label = System.Label.SB_NC_Pref_Address_Bld;
            } else if (str == 'address_bld') {
              label = System.Label.SB_NC_Address_Bld;
            } else if (str == 'street') {
              label = System.Label.SB_NC_Street_Bld;
            }
            System.debug('address__c:' + str + objectName + label);
            apiNameKeyLabelNameMap.put(str,objectName + label);
          }
          continue;
        }

        if ((DONT_USE_MAPPING.contains(SB_NameCard_RenkeiMapperUtil.getdeManagedfileName(objName,dField.name)) && objName == 'NameCard__c' ) || dField.getType() == Schema.DisplayType.LOCATION) {
          continue;
        }
        String tyObj = '';
        if (typMap.containsKey(dField.name)){
          Set<Schema.SObjectType> s1 = typMap.get(dField.name);
          for (Schema.SObjectType s2 : s1) {
            tyObj = s2.getDescribe().getName();
          }
        }

        if (!typeMap.containsKey(String.valueOf(dField.getType() + tyObj))) {
          List<String> l = new  List<String>();
          l.add(dField.name);
          typeMap.put(String.valueOf(dField.getType() + tyObj),l);
          System.debug(typeMap);
        } else {
          typeMap.get(String.valueOf(dField.getType() + tyObj)).add(dField.name);

        }

        if (dField.getType() != Schema.DisplayType.ID) {
          apiNameKeyDataTypeMap.put(dField.name,String.valueOf(dField.getType() + tyObj));
        } else {
          apiNameKeyDataTypeMap.put(dField.name,String.valueOf(dField.getType()));
        }
        String forldlabel = dField.getLabel();
        //SV_DEV-640   個人取引先を有効化している場合、マッピングで取引差責任者のカスタム項目を区別するか表示しない
        if (objName == 'Account' && SB_NameCard_Util.isEnablePersonAccount()) {
          forldlabel = SB_NameCard_RenkeiMapperUtil.changePersonAccountLabel(dField);
        }
        System.debug('isSetting true:' + dField.name + objectName + forldlabel);
        apiNameKeyLabelNameMap.put(dField.name, objectName + forldlabel); 
      } else {
        if ((DONT_USE_SETTING.contains(SB_NameCard_RenkeiMapperUtil.getdeManagedfileName(objName,dField.name)) && objName == 'NameCard__c')) {
            continue;
        }

        String tyObj = '';
        // 連携設定なので参照先の判断は必要ないです
        // if (typMap.containsKey(dField.name)){
        //   Set<Schema.SObjectType> s1 = typMap.get(dField.name);
        //   for (Schema.SObjectType s2 : s1) {
        //     tyObj = s2.getDescribe().getName();
        //   }
        // }
        //
        // タイプIDとREFERENCE文字列として判断
        String fieldType = (dField.getType() == Schema.DisplayType.ID || dField.getType() == Schema.DisplayType.REFERENCE) ? 'STRING' : String.valueOf(dField.getType());
        // 連携設定なので参照先の判断は必要ないです
        if (!typeMap.containsKey(fieldType)) {
          List<String> l = new  List<String>();
          l.add(dField.name);
          // 連携設定なので参照先の判断は必要ないです
          typeMap.put(fieldType,l);
          System.debug(typeMap);
        } else {
          // 連携設定なので参照先の判断は必要ないです
          typeMap.get(fieldType).add(dField.name);
        }

        apiNameKeyDataTypeMap.put(dField.name,fieldType);

        String forldlabel = dField.getLabel();
        //SV_DEV-640   個人取引先を有効化している場合、マッピングで取引差責任者のカスタム項目を区別するか表示しない
        if (objName == 'Account' && SB_NameCard_Util.isEnablePersonAccount()) {
          forldlabel = SB_NameCard_RenkeiMapperUtil.changePersonAccountLabel(dField);
        }
        System.debug('isSetting Flase:' + dField.name + objectName + forldlabel);
        apiNameKeyLabelNameMap.put(dField.name, objectName + forldlabel);
      }
      // else {
        // remostr += dField.name + ':' +  dField.getLabel()+'\n';
      // }
    }

    return typeMap;
  }

  //項目マップを取得
  public static Map<String,Schema.SObjectField> getobjmap(String objName){
    String nObj = SB_NameCard_RenkeiMapperUtil.getManagedobjectName(objName);
    return schemaMap.get(nObj).getDescribe().fields.getMap();
  }

  //ネームスペースを着けられるのオブジェクトをネームスペースを付ける
  public static String getManagedobjectName(String oName){
    if (String.isBlank(oName)) {
      return '';
    }
    String result = oName;
    if (SV_OBJECT_NAMES.contains(oName.toLowerCase())) {
      String ns = SB_NameCard_Util.getNamespacePrefix_x();
      result = ns + oName;
    }
    return result;
  }

  //項目にネームスペースを付きます
  public static String getManagedfileName(String oName,String fname){
    if (String.isBlank(fname)) {
      return '';
    }
    String result = fname;
    if (SV_OBJECT_NAMES.contains(oName.toLowerCase())) {
      String ns;
      if (oName == 'lead') {
        ns = SB_NameCard_Util.getLeadExNamespacePrefix_x();
      } else {
        ns = SB_NameCard_Util.getNamespacePrefix_x();
      }
      if (fname.startsWith(ns)) {
          result = fname;
    } else {
          result = ns + fname;
      }
    }
    return result;
  }

  //項目にネームスペースを削除します
  public static String getdeManagedfileName(String oName,String fname){
    if (String.isBlank(fname)) {
        return '';
    }
    String result = fname;
    if (SV_OBJECT_NAMES.contains(oName.toLowerCase())) {
      String ns1;
      if (oName == 'lead') {
        ns1 = SB_NameCard_Util.getLeadExNamespacePrefix_x();
      } else {
        ns1 = SB_NameCard_Util.getNamespacePrefix_x();
      }

      String ns = ns1.toLowerCase();

      if (fname.startsWith(ns)) {
        result = result.removeStart(ns);
      }
      else if (fname.startsWith(ns1)) {
        result = result.removeStart(ns1);
      }
      else{
        result = fname;
      }
    }
    return result;
  }

  //連携画面に使うのラベル
  public static Map<String,String> changeLabeltoMap(String str){
    Map<String,String> lab = new Map<String,String>();
    if (str == 'basicsetting') {
      lab.put('SB_NC_MAPPING_MSG_CLEAN', System.Label.SB_NC_MAPPING_MSG_CLEAN);
      lab.put('SB_NC_MAPPING_NOUPDATE', System.Label.SB_NC_MAPPING_NOUPDATE);
      lab.put('SB_NC_TITLE_SaishinInherit', System.Label.SB_NC_TITLE_SaishinInherit);
      lab.put('SB_NC_CANSELECTFIELD', System.Label.SB_NC_CANSELECTFIELD);
      lab.put('SB_NC_SELECTEdField', System.Label.SB_NC_SELECTEdField);
      lab.put('SB_NC_MAPPING_LABEL_RegistNoToDo', System.Label.SB_NC_MAPPING_LABEL_RegistNoToDo);
      lab.put('SB_NC_MAPPING_LABEL_RegsitToDoSubject', System.Label.SB_NC_MAPPING_LABEL_RegsitToDoSubject);
      lab.put('SB_NC_MAPPING_LABEL_RegistAccountNotOverWrite', System.Label.SB_NC_MAPPING_LABEL_RegistAccountNotOverWrite);
      lab.put('SB_NC_MAPPING_LABEL_RegistContactNotOverWrite', System.Label.SB_NC_MAPPING_LABEL_RegistContactNotOverWrite);
      lab.put('SB_NC_MAPPING_Mapping_inherit_ErrorMessage', System.Label.SB_NC_MAPPING_Mapping_inherit_ErrorMessage);
      lab.put('SB_NC_MAPPING_LABEL_RegistLeadNotOverWrite', System.Label.SB_NC_MAPPING_LABEL_RegistLeadNotOverWrite);
      lab.put('SB_NC_MAPPING_LABEL_RenkeiActiveCampaignMember', System.Label.SB_NC_MAPPING_LABEL_RenkeiActiveCampaignMember);
      lab.put('SB_NC_MAPPING_LABEL_RenkeiCampaignStatus', System.Label.SB_NC_MAPPING_LABEL_RenkeiCampaignStatus);
      lab.put('SB_NC_MAPPING_Label_RegistDispLeadRectype', System.Label.SB_NC_MAPPING_Label_RegistDispLeadRectype);
      lab.put('SB_NC_SETTING_ERROR_OtherSection_Saved', System.Label.SB_NC_SETTING_ERROR_OtherSection_Saved);
      lab.put('SB_NC_MAPPING_LABEL_REGISTAANDCANDL', System.Label.SB_NC_MAPPING_LABEL_REGISTAANDCANDL);
      lab.put('SB_NC_SETTING_ERROR_Required_RegistAccountCompareField', System.Label.SB_NC_SETTING_ERROR_Required_RegistAccountCompareField);
      lab.put('SB_NC_SETTING_ERROR_Required_RegistLeadCompareField', System.Label.SB_NC_SETTING_ERROR_Required_RegistLeadCompareField);
    } else if (str == 'renkeisetting') {
      lab.put('SB_NC_MAPPING_MSG_CLEAN', System.Label.SB_NC_MAPPING_MSG_CLEAN);
      lab.put('SB_NC_MAPPING_MSG_LINEERROR', System.Label.SB_NC_MAPPING_MSG_LINEERROR);
      lab.put('SB_NC_MAPPING_MSG_TYPEBOOLEANERROR', System.Label.SB_NC_MAPPING_MSG_TYPEBOOLEANERROR);
      lab.put('SB_NC_MAPPING_MSG_TYPEDATEERROR', System.Label.SB_NC_MAPPING_MSG_TYPEDATEERROR);
      lab.put('SB_NC_MAPPING_MSG_TYPEURLERROR', System.Label.SB_NC_MAPPING_MSG_TYPEURLERROR);
      lab.put('SB_NC_MAPPING_MSG_TYPEEMAILERROR', System.Label.SB_NC_MAPPING_MSG_TYPEEMAILERROR);
      lab.put('SB_NC_MAPPING_MSG_REGEXERROR', System.Label.SB_NC_MAPPING_MSG_REGEXERROR);
      lab.put('SB_NC_MAPPING_NOUPDATE', System.Label.SB_NC_MAPPING_NOUPDATE);
      lab.put('SB_NC_MAPPING_MSG_CANNOTBLANK', System.Label.SB_NC_MAPPING_MSG_CANNOTBLANK);
      lab.put('SB_NC_MAPPING_MSG_SAMEERROR', System.Label.SB_NC_MAPPING_MSG_SAMEERROR);
      lab.put('SB_NC_MAPPING_MSG_SAMEERRORSET', System.Label.SB_NC_MAPPING_MSG_SAMEERRORSET);
      lab.put('SB_NC_MAPPING_LABEL_RenkeiLeadNOExistCreateNew', System.Label.SB_NC_MAPPING_LABEL_RenkeiLeadNOExistCreateNew);
      lab.put('SB_NC_MAPPING_LABEL_RenkeiLeadOverwrite', System.Label.SB_NC_MAPPING_LABEL_RenkeiLeadOverwrite);
      lab.put('SB_NC_SETTING_ERROR_OtherSection_Saved', System.Label.SB_NC_SETTING_ERROR_OtherSection_Saved);
      lab.put('SB_NC_MAPPING_MSG_TYPENUMBERERROR', System.Label.SB_NC_MAPPING_MSG_TYPENUMBERERROR);
      lab.put('SB_NC_MAPPING_MSG_LastModifiedDate', System.Label.SB_NC_MAPPING_MSG_LastModifiedDate);
      lab.put('SB_NC_MAPPING_MSG_CreateDate', System.Label.SB_NC_MAPPING_MSG_CreateDate);
    } else if (str == 'mapping') {
      lab.put('SB_NC_MAPPING_MSG_SELECTMAPPINGERROR', System.Label.SB_NC_MAPPING_MSG_SELECTMAPPINGERROR);
      lab.put('SB_NC_SETTING_LABEL_NONE', System.Label.SB_NC_SETTING_LABEL_NONE);
      lab.put('SB_NC_MAPPING_LABEL_AUSAVE', System.Label.SB_NC_MAPPING_LABEL_AUSAVE);
      lab.put('SB_NC_MAPPING_MSG_DEFAULT', System.Label.SB_NC_MAPPING_MSG_DEFAULT);
      lab.put('SB_NC_MAPPING_MSG_CLEAN', System.Label.SB_NC_MAPPING_MSG_CLEAN);
      lab.put('SB_NC_MAPPING_MSG_SAMEERROR', System.Label.SB_NC_MAPPING_MSG_SAMEERROR);
      lab.put('SB_NC_MAPPING_MSG_LINEERROR', System.Label.SB_NC_MAPPING_MSG_LINEERROR);
      lab.put('SB_NC_MAPPING_NOUPDATE', System.Label.SB_NC_MAPPING_NOUPDATE);
      lab.put('SB_NC_MAPPING_ChangeRecordTypeError', System.Label.SB_NC_MAPPING_ChangeRecordTypeError);
      lab.put('SB_NC_MAPPING_NO_SELECT_RENKEIOBJECT_ERRORMESSAGE', System.Label.SB_NC_MAPPING_NO_SELECT_RENKEIOBJECT_ERRORMESSAGE);
    }

    return lab;
  }

  //オブジェクトの項目Mapを作成(参照先チェック用)
  public static Map<String,Set<Schema.SObjectType>> getTypeMap(String obType){
    // 名刺の項目リストを作成
    String nObj = SB_NameCard_RenkeiMapperUtil.getManagedobjectName(obType);
    Map<String,Schema.SObjectField> fieldMap = schemaMap.get(nObj).getDescribe().fields.getMap();
    Map<String,Set<Schema.SObjectType>> types = new Map<String,Set<Schema.SObjectType>>();
    for(Schema.SObjectField sField : fieldMap.Values()) {
      Schema.describefieldresult dField = sField.getDescribe();
      if (dField.getType() == Schema.DisplayType.REFERENCE
          || dField.getType() == Schema.DisplayType.ID) {
        Set<Schema.SObjectType> se = new Set<Schema.SObjectType>();
        if (dField.getType() == Schema.DisplayType.ID) {
          se.add(schemaMap.get(nObj));
          types.put(dField.name,se);
          continue;
        }
        for(Schema.SObjectType ty : dField.getReferenceTo()) {
          se.add(ty);
        }
        types.put(dField.name,se);
      }
    }
    return types;
  }

  // 個人取引先項目変更
  // SV_DEV-640   個人取引先を有効化している場合、マッピングで取引差責任者のカスタム項目を区別するか表示しない
  public static String changePersonAccountLabel(Schema.describefieldresult field) {
    String label = field.getLabel();
    String fieldName = field.Name.toLowerCase();
    if (fieldName.endsWith('__pc')
              || (fieldName.startsWith('person')
                    && !field.isCustom())
              || PERSONALACCOUNT.contains(fieldName)) {
      label += System.Label.SB_NC_Person;
    }
    return label;
  }
}