/**
 *
 * AppExchange セキュリティレビュー要件 CRUD FLS チェック 付き DML を提供するクラス
 *
 * Copyright (C) 2014 − 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2014.7.xx
 *  @Version 2      2016.7.xx オブジェクト権限のチェックを追加   かつては ディスクドライブメソッドはガバナ制限があったけど今はなし
 *  @Version 3      2016.8.xx getPopulatedFieldsAsMap を使って入力のあった項目に絞ってすべて検査  メソッドを整理
 *  @Version 4      2017.10.xx  with sharing  v1.21 for code scan
 *  @Version 2.4    2019.05.XX  SV_DEV-958 入力規則エラーメッセージを加工せずそのまま表示させる対応
 *
 **/
global with sharing class SB_NameCard_CrudFls {
  global class CrudFlsException extends exception {}

  // // パッチリリースでは、カスタム表示ラベルが追加できないので、
  // private static final String SB_MSG_CrudNotCreateable = '{0} オブジェクトの作成権限がありません。';
  // private static final String SB_MSG_CrudNotUpdateable ='{0} オブジェクトの編集権限がありません。';
  // private static final String SB_MSG_FlsNotCreateable = '{0} オブジェクトの項目 {1} ({2}) の作成権限がありません。';
  // private static final String SB_MSG_FlsNotUpdateable = '{0} オブジェクトの項目 {1} ({2}) の編集権限がありません。';
  // SB_MSG_DmlInsertFailed = '{0} オブジェクト 作成エラー : {1}'
  // SB_MSG_DmlUpdateFailed = '{0} オブジェクト 更新エラー : {1}'
  //
  // // private static String namespace = SB_NameCard_Util.getNamespacePrefix_x();

  // そもそも オブジェクトが内部処理用なので、ユーザの権限に依存しないもの
  private static Set<Schema.SObjectType> ignoreObjects {
    get {
      if (ignoreObjects == null) {
        ignoreObjects  = new Set<Schema.SObjectType> {
          User.sObjectType          // ユーザ
          , SmartViscaConfig__c.sObjectType   // SVカスタム設定
          //    , Schema.getGlobalDescribe().get('Lead')
        };
      }
      return ignoreObjects;
    }
    Set;
  }

  // SV_DEV-164 リードの「名刺で更新」時にリードの住所項目の編集権限がない場合のエラーメッセージが「リード オブジェクトの項目 郵便番号 (PostalCode) の編集権限がありません。」
  //
  // 住所複合項目は個々の項目でなく 住所でアクセス権を設定するので、 住所項目として 例外を表示しようとしたけど 実行中のコードでは 住所複合項目 の DescribeFieldResult はとれない！
  // 項目をアクセス権の設定単位に読み替えるためのマッピング
  //private static final Map<String, String> NMAE2SWITCHEDNAME = new Map<String, String> {
  //  // リードの住所用
  //  'country' => 'Address',
  //  'postalcode' => 'Address',
  //  'state' => 'Address',
  //  'city' => 'Address',
  //  'street' => 'Address',
  //  // 取引先の住所用 請求先
  //  'billingcountry' => 'BillingAddress',
  //  'billingpostalcode' => 'BillingAddress',
  //  'billingstate' => 'BillingAddress',
  //  'billingcity' => 'BillingAddress',
  //  'billingstreet' => 'BillingAddress',
  //  // 取引先の住所用 納入先
  //  'shippingcountry' => 'ShippingAddress',
  //  'shippingpostalcode' => 'ShippingAddress',
  //  'shippingstate' => 'ShippingAddress',
  //  'shippingcity' => 'ShippingAddress',
  //  'shippingstreet' => 'ShippingAddress',
  //  // 取引先の責任者の住所用 郵送先
  //  'mailingcountry' => 'MailingAddress',
  //  'mailingpostalcode' => 'MailingAddress',
  //  'mailingstate' => 'MailingAddress',
  //  'mailingcity' => 'MailingAddress',
  //  'mailingstreet' => 'MailingAddress',
  //  // 取引先の責任者の住所用 その他の
  //  'othercountry' => 'OtherAddress',
  //  'otherpostalcode' => 'OtherAddress',
  //  'otherstate' => 'OtherAddress',
  //  'othercity' => 'OtherAddress',
  //  'otherstreet' => 'OtherAddress'
  //};

  // 入力のあった項目API名を抽出する。
  @TestVisible
  private static Set<String> getCheckFields(List<SObject> os) {
    Set<String> result = new Set<String>();
    for (SObject o : os) {
      result.addAll(o.getPopulatedFieldsAsMap().keySet());
    }
    return result;
  }

  //
  // DmlException のエラーとなった各レコードのメッセージを取得する。
  //  v1.22 2018.01.xx
  @TestVisible
  private static String getMessageEachRow(System.DmlException e) {
    List<String> texts = new List<String>();
    for (Integer n = 0; n < e.getNumDml(); n++) {
      String statusCodeMsg = SB_NameCard_SFDCSystemStatusCode.getMessageText(e.getDmlType(n));
      String id = e.getDmlId(n);
      if (String.isNotBlank(statusCodeMsg)) {
        texts.add(statusCodeMsg);
      } else if (String.isNotBlank(id)) {
        texts.add(String.format('[{0} {1}]', new String[] {e.getDmlMessage(n), id}));
      }
      else if (e.getNumDml() > 1) {
        texts.add(String.format('[{0}: {1}]', new String[] {String.valueOf(n), e.getDmlMessage(n)}));
      }
      else {
        texts.add(String.format('[{0}]', new String[] {e.getDmlMessage(n)}));
      }

    }
    return String.join(texts, ', ');
  }

  // CRDU FLS チェック付き 作成
  global static void screate(List<SObject> os, Boolean opt_allOrNone) {
    if (os == null || os.size() == 0){
      return;
    }
    Database.DMLOptions dml = new Database.DMLOptions();
    dml.OptAllOrNone = opt_allOrNone;
    screate(os, dml);

  }

  // CRDU FLS チェック付き 作成
  // DMLOptions指定、結果を返す。 重複管理用で追加
  global static List<Database.SaveResult> screate(List<SObject> os, Database.DMLOptions dml) {
    if (os == null || os.isEmpty()) {
      return null;
    }
    Schema.SObjectType targetType = os[0].getSObjectType();
    Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
    if (ignoreObjects.contains(targetType) == false) {
      // Get Describe Result of the SObject
      // オブジェクト作成権限があるか
      if (!sobjResult.isCreateable()) {
        throw new CrudFlsException(String.format(Label.SB_MSG_CrudNotCreateable, new String[] {sobjResult.label}));
      }

      Map<string, Schema.SObjectField> m = sobjResult.fields.getMap();
      Set<String> keys = getCheckFields(os);    // 入力のあった項目s
      // 入力のあった項目が作成可能でないと例外
      for (String key : keys) {
        // String k = key.removeStart(namespace);   // SVのカスタム項目だとネームスペースがついてるので、とる  -> 37.0あたりでは不要        Schema.` descField = m.get(key).getDescribe();
        Schema.DescribeFieldResult descField = m.get(key).getDescribe();
        if (descField.getType() != DisplayType.location        // 2015.01.22  Location 型は isCreateable() とかでエラーになる。
          && descField.isPermissionable()           // 権限設定出来る項目だけ
          && descField.isCreateable() == false      // 作成可能?
          && descField.isAutoNumber() == false      // 自動採番?
          && descField.isCalculated() == false) {   // 数式?
            throw new CrudFlsException(String.format(Label.SB_MSG_FlsNotCreateable,
                                      new String[] {sobjResult.label, descField.getLabel(), descField.getName()}));
        }
      }
    }

    // INSERT
    List<Database.SaveResult> sr;
    try {
      sr = Database.insert(os, dml);
    }
    catch(System.DmlException e) {
      throw new CrudFlsException(String.format(Label.SB_MSG_DmlInsertFailed,
                                new String[]{ sobjResult.label, e.getMessage() }));
                                //new String[]{ sobjResult.label, getMessageEachRow(e) }));
    }
    catch(Exception e) {
      throw new CrudFlsException(String.format(Label.SB_MSG_DmlInsertFailed,
                                //new String[]{ sobjResult.label, e.getMessage() }));
                                new String[]{ sobjResult.label, e.getMessage() }));
    }
    return sr;
  }

  // CRDU FLS チェック付き 更新
  global static void supdate(List<SObject> os, Boolean opt_allOrNone){
    if (os == null || os.isEmpty()) {
      return;
    }
    Database.DMLOptions dml = new Database.DMLOptions();
    dml.OptAllOrNone = opt_allOrNone;
    supdate(os, dml);
  }

  // CRDU FLS チェック付き 更新
  // DMLOptions指定、結果を返す。 重複管理用で追加
  global static List<Database.SaveResult> supdate(List<SObject> os, Database.DMLOptions dml) {
    if (os == null || os.isEmpty()) {
      return null;
    }

    Schema.SObjectType targetType = os[0].getSObjectType();
    Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
    if (ignoreObjects.contains(targetType) == false) {
      // オブジェクトの編集権限があるか
      if (!sobjResult.isUpdateable()) {
        throw new CrudFlsException(String.format(Label.SB_MSG_CrudNotUpdateable, new String[] {sobjResult.label}));
      }

      Map<string, Schema.SObjectField> m = sobjResult.fields.getMap();
      // Anonymous Executeなら できるが、ここでは 複合項目の Address についてはとれない！
      //for (String key : m.keySet()) {
      //  Schema.DescribeFieldResult descField = m.get(key).getDescribe();
      //  System.debug('111 '  + descField.getLabel() + ' : ' + descField.getName() + ' : ' + descField.isPermissionable() + ' : ' + descField.isCreateable() + ' : ' + descField.isUpdateable());
      //}

      Set<String> keys = getCheckFields(os);    // 入力のあった項目s
      // 入力のあった項目が編集可能でないと例外
      for (String key : keys) {
        // String k = key.removeStart(namespace);   // SVのカスタム項目だとネームスペースがついてるので、とる  -> 37.0あたりでは不要
        Schema.DescribeFieldResult descField = m.get(key).getDescribe();
        if (descField.getType() != DisplayType.location         // 2015.01.22  Location 型は isCreateable() とかでエラーになる。
          && descField.isPermissionable()       // 権限設定出来る項目だけ
          && descField.isUpdateable() == false      // 更新可能？
          && descField.isAutoNumber() == false      // 自動採番?
          && descField.isCalculated() == false) {   // 数式?
            throw new CrudFlsException(String.format(Label.SB_MSG_FlsNotUpdateable,
                                      new String[] {sobjResult.label, descField.getLabel(), descField.getName()}));
        }
      }
    }
    List<Database.SaveResult> sr;
    try {
      sr = Database.update(os, dml);
    }
    catch(System.DmlException e) {
      //SV_DEV-958 ユーザが独自に定義した入力規則に伴うエラーの場合にはメッセージを加工せず返却します
      if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
        throw e;
      } else {
        throw new CrudFlsException(String.format(Label.SB_MSG_DmlUpdateFailed,
                                //new String[]{ sobjResult.label, e.getMessage() }));
                                new String[]{ sobjResult.label, getMessageEachRow(e) }));
      }
    }
    catch(Exception e) {
      throw new CrudFlsException(String.format(Label.SB_MSG_DmlUpdateFailed,
                                //new String[]{ sobjResult.label, e.getMessage() }));
                                new String[]{ sobjResult.label, e.getMessage() }));
    }
    return sr;
  }

  //オブジェクトを削除
  global static List<Database.DeleteResult> sdelete(List<SObject> os) {
    if (os == null || os.isEmpty()) {
      return null;
    }

    Schema.SObjectType targetType = os[0].getSObjectType();
    Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
    // オブジェクトの編集権限があるか
    if (!sobjResult.isDeletable()) {
        throw new CrudFlsException(String.format(Label.SB_MSG_CrudNotDeleteable, new String[] {sobjResult.label}));
    }
    List<Database.DeleteResult> sr;
    try {
      sr = Database.delete(os);
    }
    catch(System.DmlException e) {
      throw new CrudFlsException(String.format(Label.SB_MSG_DmlDeleteFailed,
                                //new String[]{ sobjResult.label, e.getMessage() }));
                                new String[]{ sobjResult.label, getMessageEachRow(e) }));
    }
    catch(Exception e) {
      throw new CrudFlsException(String.format(Label.SB_MSG_DmlDeleteFailed,
                                //new String[]{ sobjResult.label, e.getMessage() }));
                                new String[]{ sobjResult.label, e.getMessage() }));
    }
    return sr;
  }

  // 管理パッケージの場合 globalメソッドを削除できないので、以前のバージョンのダミーで残しておきます。
  global static List<Database.SaveResult> screateDuplicate(List<SObject> os, Database.DMLOptions dml) {
    return null;
  }
  // 管理パッケージの場合 globalメソッドを削除できないので、以前のバージョンのダミーで残しておきます。
  global static List<Database.SaveResult> supdateDuplicate(List<SObject> os, Database.DMLOptions dml) {
    return null;
  }

}