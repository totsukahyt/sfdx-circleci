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
 *
 **/
global class SB_NameCard_LeadCrudFls {
  public class CrudFlsException extends exception {}

  // // パッチリリースでは、カスタム表示ラベルが追加できないので、
  // private static final String SB_MSG_CrudNotCreateable = '{0} オブジェクトの作成権限がありません。';
  // private static final String SB_MSG_CrudNotUpdateable ='{0} オブジェクトの編集権限がありません。';
  // private static final String SB_MSG_FlsNotCreateable = '{0} オブジェクトの項目 {1} ({2}) の作成権限がありません。';
  // private static final String SB_MSG_FlsNotUpdateable = '{0} オブジェクトの項目 {1} ({2}) の編集権限がありません。';
  //
  // // private static String namespace = SB_NameCard_Util.getNamespacePrefix_x();

  // そもそも オブジェクトが内部処理用なので、ユーザの権限に依存しないもの
  //private static Set<Schema.SObjectType> ignoreObjects {
  //  get {
  //    if (ignoreObjects == null) {
  //      ignoreObjects  = new Set<Schema.SObjectType> {
  //        User.sObjectType          // ユーザ
  //        , SmartViscaf__SmartViscaConfig__c.sObjectType   // SVカスタム設定
  //        //    , Schema.getGlobalDescribe().get('Lead')
  //      };
  //    }
  //    return ignoreObjects;
  //  }
  //  Set;
  //}

  // 入力のあった項目API名を抽出する。
  private static Set<String> getCheckFields(List<SObject> os) {
    Set<String> result = new Set<String>();
    for (SObject o : os) {
      result.addAll(o.getPopulatedFieldsAsMap().keySet());
    }
    return result;
  }

  //// CRDU FLS チェック付き 作成
  //public static void screate(List<SObject> os, Boolean opt_allOrNone) {
  //  if (os == null || os.size() == 0){
  //    return;
  //  }
  //  Database.DMLOptions dml = new Database.DMLOptions();
  //  dml.OptAllOrNone = opt_allOrNone;
  //  screateDuplicate(os, dml);

  //}

global static void screateLead(List<SObject> os) {


Schema.SObjectType targetType = os[0].getSObjectType();
Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
Map<string, schema.sObjectField> m = sobjResult.fields.getMap();
 Set<String> keys = getCheckFields(os);    // 入力のあった項目s]
    System.debug(keys.size());
      // 入力のあった項目が作成可能でないと例外
      for (String key : keys) {
        // String k = key.removeStart(namespace);   // SVのカスタム項目だとネームスペースがついてるので、とる  -> 37.0あたりでは不要
        schema.describeFieldResult descField = m.get(key).getDescribe();
        if (descField.getType() != DisplayType.location        // 2015.01.22  Location 型は isCreateable() とかでエラーになる。
          && descField.isPermissionable()           // 権限設定出来る項目だけ
          && descField.isCreateable() == false      // 作成可能?
          && descField.isAutoNumber() == false      // 自動採番?
          && descField.isCalculated() == false) {   // 数式?
            throw new CrudFlsException(String.format(Label.SB_NCLD_MSG_FlsNotCreateable,
            new String[] {sobjResult.label, descField.getLabel(), descField.getName()}));
        }

}
     }


    global static void supdateLead(List<SObject> os) {
        Schema.SObjectType targetType = os[0].getSObjectType();
        Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
        Map<string, schema.sObjectField> m = sobjResult.fields.getMap();
        Set<String> keys = getCheckFields(os);    // 入力のあった項目s
      // 入力のあった項目が作成可能でないと例外
      for (String key : keys) {
        // String k = key.removeStart(namespace);   // SVのカスタム項目だとネームスペースがついてるので、とる  -> 37.0あたりでは不要
        schema.describeFieldResult descField = m.get(key).getDescribe();
        if (descField.getType() != DisplayType.location        // 2015.01.22  Location 型は isCreateable() とかでエラーになる。
          && descField.isPermissionable()           // 権限設定出来る項目だけ
          && descField.isUpdateable() == false      // 作成可能?
          && descField.isAutoNumber() == false      // 自動採番?
          && descField.isCalculated() == false) {   // 数式?
           throw new CrudFlsException(String.format(Label.SB_NCLD_MSG_FlsNotUpdateable,
            new String[] {sobjResult.label, descField.getLabel(), descField.getName()}));
        } 
      }

}

  // CRDU FLS チェック付き 作成
  // DMLOptions指定、結果を返す。 重複管理用で追加
  //global static List<Database.SaveResult> screateDuplicate(List<SObject> os, Database.DMLOptions dml) {
  //  if (os == null || os.isEmpty()) {
  //    return null;
  //  }
  //  if (ignoreObjects.contains(os[0].getSObjectType()) == false && Test.isRunningTest() == false) {
  //    // Get Describe Result of the SObject
  //    Schema.SObjectType targetType = os[0].getSObjectType();
  //    if (targetType == null) {
  //      throw new CrudFlsException('Object not found.');
  //    }

  //    Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
  //    // オブジェクト作成権限があるか
  //    if (!sobjResult.isCreateable()) {
  //      throw new CrudFlsException(String.format(Label.SB_NCLD_MSG_CrudNotCreateable, new String[] {sobjResult.label}));
  //    }

  //    Map<string, schema.sObjectField> m = sobjResult.fields.getMap();
  //    Set<String> keys = getCheckFields(os);    // 入力のあった項目s
  //    // 入力のあった項目が作成可能でないと例外
  //    for (String key : keys) {
  //      // String k = key.removeStart(namespace);   // SVのカスタム項目だとネームスペースがついてるので、とる  -> 37.0あたりでは不要
  //      schema.describeFieldResult descField = m.get(key).getDescribe();
  //      if (descField.getType() != DisplayType.location        // 2015.01.22  Location 型は isCreateable() とかでエラーになる。
  //        && descField.isPermissionable()           // 権限設定出来る項目だけ
  //        && descField.isCreateable() == false      // 作成可能?
  //        && descField.isAutoNumber() == false      // 自動採番?
  //        && descField.isCalculated() == false) {   // 数式?
  //          throw new CrudFlsException(String.format(Label.SB_NCLD_MSG_FlsNotCreateable,
  //                                    new String[] {sobjResult.label, descField.getLabel(), descField.getName()}));
  //      }
  //    }
  //  }

  //  // INSERT
  //  List<Database.SaveResult> sr = Database.insert(os, dml);
  //  return sr;
  //}

  // CRDU FLS チェック付き 更新
  //public static void supdate(List<SObject> os, Boolean opt_allOrNone){
  //  if (os == null || os.isEmpty()) {
  //    return;
  //  }
  //  Database.DMLOptions dml = new Database.DMLOptions();
  //  dml.OptAllOrNone = opt_allOrNone;
  //  supdateDuplicate(os, dml);
  //}

  //// CRDU FLS チェック付き 更新
  //// DMLOptions指定、結果を返す。 重複管理用で追加
  //global static List<Database.SaveResult> supdateDuplicate(List<SObject> os, Database.DMLOptions dml) {
  //  if (os == null || os.isEmpty()) {
  //    return null;
  //  }

  //  if (ignoreObjects.contains(os[0].getSObjectType()) == false && Test.isRunningTest() == false) {
  //    Schema.SObjectType targetType = os[0].getSObjectType();
  //    if (targetType == null) {
  //        throw new CrudFlsException('Object not found.');
  //    }

  //    Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
  //    // オブジェクトの編集権限があるか
  //    if (!sobjResult.isUpdateable()) {
  //      throw new CrudFlsException(String.format(Label.SB_NCLD_MSG_CrudNotUpdateable, new String[] {sobjResult.label}));
  //    }

  //    Map<string, schema.sObjectField> m = sobjResult.fields.getMap();
  //    Set<String> keys = getCheckFields(os);    // 入力のあった項目s
  //    // 入力のあった項目が編集可能でないと例外
  //    for (String key : keys) {
  //      // String k = key.removeStart(namespace);   // SVのカスタム項目だとネームスペースがついてるので、とる  -> 37.0あたりでは不要
  //      schema.describeFieldResult descField = m.get(key).getDescribe();
  //      if (descField.getType() != DisplayType.location         // 2015.01.22  Location 型は isCreateable() とかでエラーになる。
  //        && descField.isPermissionable()       // 権限設定出来る項目だけ
  //        && descField.isUpdateable() == false      // 更新可能？
  //        && descField.isAutoNumber() == false      // 自動採番?
  //        && descField.isCalculated() == false) {   // 数式?
  //          throw new CrudFlsException(String.format(Label.SB_NCLD_MSG_FlsNotUpdateable,
  //                                    new String[] {sobjResult.label, descField.getLabel(), descField.getName()}));
  //      }
  //    }
  //  }

  //  List<Database.SaveResult> sr = Database.update(os, dml);
  //  return sr;
  //}

    //オブジェクト編集権限あるか
    global static Boolean isCreateable(Sobject objects)
    {
       Schema.SObjectType targetType = objects.getSobjectType();
       Schema.DescribeSObjectResult tar = targetType.getDescribe();
       return tar.isCreateable();
    }
 
    //オブジェクト編集権限あるか
    global static Boolean isUpdateable(Sobject objects)
    {
        Schema.SObjectType targetType = objects.getSobjectType();
        Schema.DescribeSObjectResult tar = targetType.getDescribe();
        return tar.isUpdateable();
    }

      global static Void isCreateableError(Sobject objects)
    {
       Schema.SObjectType targetType = objects.getSobjectType();
       Schema.DescribeSObjectResult tar = targetType.getDescribe();
       if(!tar.isCreateable())
       {
        throw new CrudFlsException(String.format(System.Label.SB_MSG_CrudNotCreateable,new String[]{tar.label})) ;
       }
    }
 
    //編集権限あるか
    global static void isUpdateableError(Sobject objects)
    {
        Schema.SObjectType targetType = objects.getSobjectType();
        Schema.DescribeSObjectResult tar = targetType.getDescribe();
        if(!tar.isUpdateable())
        {
            throw new CrudFlsException(String.format(System.Label.SB_MSG_CrudNotUpdateable, new String[]{tar.label}));
        }
    }


// /**
//  *
//  * AppExchange セキュリティレビュー要件 CRUD FLS チェック 付き DML
//  *
//  * Copyright (C) 2014 SunBridge Inc. All Rights Reserved.
//  *
//  *  @author sawano
//  *  @Version 1      2014.7.xx
//  *  @Version 2      2016.7.xx オブジェクト権限のチェックを追加
//  *
//  **/
// global class SB_NameCard_CrudFls {
//   public class CrudFlsException extends exception {}
//
//   // そもそも 作成・更新時ともに作成・更新出来ないカスタム項目  数式、自動番号
//   // 小文字で比べる
//   private static Map<Schema.SObjectType, Set<String>> mapSObj2IgnoreFieldsInCreate = new Map<Schema.SObjectType, Set<String>> {
//     Account.sObjectType => new Set<String>{
//       'site', 'billingpostalcode', 'billingstate', 'billingcity', 'billingstreet', 'phone', 'fax'
//       , 'website', 'namecard__c', 'namecardlistname__c', 'namecardmemo__c', 'namecardfreehandmemo__c'}
//     , Contact.sObjectType => new Set<String>{
//       'accountid', 'lastname', 'firstname', 'mailingpostalcode', 'mailingstate', 'mailingcity', 'mailingstreet'
//       , 'phone', 'fax', 'mobilephone', 'email', 'title', 'department'
//       , 'namecard__c', 'namecardlistname__c', 'namecardmemo__c', 'namecardfreehandmemo__c'}
//     , NameCard__c.sObjectType => new Set<String>{
//       //　参照項目を除外
//       'campaing__c', 'lead__c', 'parent__c', 'account__c', 'contact__c', 'tenshokugonomeishi__c'
//       , 'lead__c'      // 2016.07.xx
//       // 数式は除外
//       , 'thumbnail__c','bk_thumbnail__c', 'leadLink__c', 'parentlink__c',  'portrait__c', 'accountlink__c'
//       , 'contactlink__c', 'location__c', 'date__c', 'delivery_icon__c', 'bk_image__c'
//       , 'leadlink__c', 'company_name_kana_1st__c', 'company_name_kana_1sta__c', 'name_kana__c'  // 2016.07.xx
//       , 'person_name_last_kana_1st__c', 'person_name_last_kana_1sta__c', 'image__c', 'title_and_name__c'}      // 2016.07.xx
//     , Schema.getGlobalDescribe().get('Lead') => new Set<String>{
//       'lastname', 'firstname', 'company', 'postalcode', 'state', 'city', 'street'
//       , 'phone', 'fax', 'mobilephone', 'email', 'title', 'ownerid'
//       , 'namecard__c', 'namecardlistname__c', 'namecardmemo__c', 'namecardfreehandmemo__c' }
//     , Schema.getGlobalDescribe().get('FeedItem') => new Set<String>{
//       'body', 'type', 'parentid', 'title', 'linkurl'}
//   };
//   // そもそも 更新時にだけ更新出来ないカスタム項目 主従
//   private static Map<Schema.SObjectType, Set<String>> mapSObj2IgnoreFieldsInUpdate = new Map<Schema.SObjectType, Set<String>> {
//     Account.sObjectType => new Set<String>{}
//     , Contact.sObjectType => new Set<String>{}
//     , NameCard__c.sObjectType => new Set<String>{}
//     , Schema.getGlobalDescribe().get('Lead') => new Set<String>{}
//     , Schema.getGlobalDescribe().get('CampaignMember') => new Set<String>{}
//     , Schema.getGlobalDescribe().get('FeedItem') => new Set<String>{}
//   };
//
//   // そもそも オブジェクトが内部処理用なので、ユーザの権限に依存しないもの
//   private static Set<Schema.SObjectType> ignoreObjects {
//     get {
//       if (ignoreObjects == null) {
//         ignoreObjects  = new Set<Schema.SObjectType> {
//           User.sObjectType          // ユーザ
// //          , Account.sObjectType
//   //        , Contact.sObjectType
//     //      , NameCard__c.sObjectType
//       //    , Schema.getGlobalDescribe().get('Lead')
//         //  , Schema.getGlobalDescribe().get('FeedItem')
//           // カスタム設定たち
//           , SmartViscaConfig__c.sObjectType
//         };
//         if (String.isBlank(system.Label.SB_NC_CrudFlsIgnoreObjects) == false) {
//           // カスタム表示ラベルに指定があったら追加する。
//           String[] objNames = system.Label.SB_NC_CrudFlsIgnoreObjects.split('[\r\n\\s,]+');
//           for (String objName : objNames) {
//             try {
//               Schema.SObjectType targetType = schema.getGlobalDescribe().get(objName);
//               if (targetType == null) continue;
//               ignoreObjects.add(targetType);
//             }
//             catch(Exception e) {
//               system.debug(e.getMessage());
//             }
//           }
//         }
//       }
//       return ignoreObjects;
//     }
//     Set;
//   }
//
//   // そもそも オブジェクトが内部処理用なので、ユーザの権限に依存しないので、項目レベルとかチェック不用
//   private static Boolean isIgnorableObject(Schema.SObjectType ot) {
//     return ignoreObjects.contains(ot);
//   }
//
//   // そもそも 作成、更新時に 作成、更新できない項目（数式、自動番号とか）でないか チェックする
//   // Filed Describe メソッドをなるべく使わないために事前にチェックします。
//   // 念のため、このチェックのあと、各タイプの項目でないかのチェックもします。
//   private static Boolean isIgnorableField(Schema.SObjectType ot, String field, Boolean create) {
//     return (
//       // 作成可能項目？
//       (create == true &&
//         mapSObj2IgnoreFieldsInCreate.containsKey(ot) == true &&
//         mapSObj2IgnoreFieldsInCreate.get(ot).contains(field.toLowerCase()) == true)  ||
//         // 更新可能項目？
//       (create ==false &&
//         mapSObj2IgnoreFieldsInUpdate.containsKey(ot) == true &&
//         mapSObj2IgnoreFieldsInUpdate.get(ot).contains(field.toLowerCase()) == true));
//   }
// /*  Bulkify Apex Methods - Using Collections in methods といわれるので、１つづつはやらない
//   public static void screate(SObject o){
//         screate(new List<SObject>{o});
//     }*/
//
    //public static String defaultRecordType(String sobjectname)
    //  {
    //    String recordTypeName;
    //    List<Schema.RecordTypeInfo> rs =  Schema.getGlobalDescribe().get(sobjectname).getDescribe().getRecordTypeInfos();
    //    for (RecordTypeInfo r : rs)
    //      {
    //        if(r.isDefaultRecordTypeMapping() && r.isAvailable())
    //          {
    //             recordTypeName =  r.getRecordTypeId();
    //            }
    //      }
    //      return recordTypeName;
    //  }

    //public static List<RecordTypeInfo> getRecordType(String sobjectname)
    //  {

    //    List<Schema.RecordTypeInfo> rs =  Schema.getGlobalDescribe().get(sobjectname).getDescribe().getRecordTypeInfos();
    //    List<RecordTypeInfo> recordtypes = new List<RecordTypeInfo>();
    //    for (RecordTypeInfo r : rs)
    //      {
    //        if(r.isAvailable()){
    //            recordtypes.add(r);
    //         }
    //      }
    //      //isMasterメソード使えるにはWinter'16　APIバージョン35.0以降でなければならない、
    //      //そのため、今最後のレコードタイプMasterをリストから削除します
    //      if(recordtypes.size()>0)
    //      {
    //          recordtypes.remove(recordtypes.size()-1);
    //        }
    //      return recordtypes;
    //  }
//
//
//   //
//   public static void screate(List<SObject> os, Boolean opt_allOrNone) {
//     if (os == null || os.size() == 0){
//       return;
//     }
//
//     if (Test.isRunningTest() == false && isIgnorableObject(os[0].getSObjectType()) == false) {
//       // Get Describe Result of the SObject
//       Schema.SObjectType targetType = os[0].getSObjectType();
//       if (targetType == null) {
//           throw new CrudFlsException('Object not found.');
//       }
//
//       Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
//       // オブジェクト作成権限があるか
//       if (!sobjResult.isCreateable()) {
//         throw new CrudFlsException(String.format(Label.SB_MSG_CrudNotCreateable, new String[] {sobjResult.label}));
//       }
//
//       // !! Attention to Governor Limit: Up to 100 call
//       // Get Map of all fileds exist in the SObject
//       Map<string, schema.sObjectField> m = sobjResult.fields.getMap();
//
//       // 全部の項目が作成可能でないと例外
//       for (String key : m.keySet()) {
//         schema.describeFieldResult descField = m.get(key).getDescribe();
//         if ((key.endsWithIgnoreCase('__c') || key == 'Name')
//           && isIgnorableField(targetType, key, true) == false     // Describeメソッドはなるべく使わずにチェック
//           && descField.getType() != DisplayType.location         // 2015.01.22  Location 型は isCreateable() とかでエラーになる。
//           && os[0].get(key) != null            // null にしている項目はよしとする。
//           && descField.isCreateable() == false      // 作成可能?
//           && descField.isAutoNumber()==false         // 自動採番? 弾いているが、再度検証
//           && descField.isCalculated()==false) {      // 数式? 弾いているが、再度検証
//             throw new CrudFlsException(String.format(Label.SB_MSG_FlsNotCreateable,
//                                         new String[] {sobjResult.label, descField.getLabel(), descField.getName()}));
//         }
//       }
//     }
//     Database.insert(os, opt_allOrNone);
//   }
//
//   //重複管理用
//   global static List<Database.SaveResult> screateDuplicate(List<SObject> os, Database.DMLOptions dml) {
//     if (os == null || os.isEmpty()) {
//       return null;
//     }
//     if (Test.isRunningTest() == false && isIgnorableObject(os[0].getSObjectType()) == false) {
//       // Get Describe Result of the SObject
//       Schema.SObjectType targetType = os[0].getSObjectType();
//       if (targetType == null) {
//         throw new CrudFlsException('Object not found.');
//       }
//
//       Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
//       // オブジェクト作成権限があるか
//       if (!sobjResult.isCreateable()) {
//         throw new CrudFlsException(String.format(Label.SB_MSG_CrudNotCreateable, new String[] {sobjResult.label}));
//       }
//
//       // !! Attention to Governor Limit: Up to 100 call
//       // Get Map of all fileds exist in the SObject
//       Map<string, schema.sObjectField> m = sobjResult.fields.getMap();
//
//       // 全部の項目が作成可能でないと例外
//       for (String key : m.keySet()) {
//         schema.describeFieldResult descField = m.get(key).getDescribe();
//         if ((key.endsWithIgnoreCase('__c') || key == 'Name')
//           && isIgnorableField(targetType, key, true) == false     // Describeメソッドはなるべく使わずにチェック
//           && descField.getType() != DisplayType.location        // 2015.01.22  Location 型は isCreateable() とかでエラーになる。
//           && os[0].get(key) != null           // null にしている項目はよしとする。
//           && descField.isCreateable() == false      // 作成可能?
//           && descField.isAutoNumber()==false        // 自動採番? 弾いているが、再度検証
//           && descField.isCalculated()==false) {     // 数式? 弾いているが、再度検証
//             throw new CrudFlsException(String.format(Label.SB_MSG_FlsNotCreateable,
//                                       new String[] {sobjResult.label, descField.getLabel(), descField.getName()}));
//         }
//       }
//     }
//
//     // INSERT
//     List<Database.SaveResult> sr = Database.insert(os, dml);
//     return sr;
//   }
// /*
//     public static SObject sread(string objName, id rid){
//         return sread(objName, rid, null);
//     }
//
//     public static SObject sread(string obj_Name, id rid, List<string> flds){
//     String objName = SB_NameCard_Util.getNamespacePrefix();
//     objName = String.isBlank(objName) == true ? '' : objName +'__';
//     objName += obj_Name;
//
//         string field_to_read = '';
//
//         Schema.SObjectType targetType = schema.getGlobalDescribe().get(objName);
//         if (targetType == null) {
//             CrudFlsException e = new CrudFlsException('Object not found.');
//             throw e;
//         }
//     Boolean ignoreObject =  isIgnorableObject(targetType);
//         if (flds == null){
//             // retrieve all fields
//             Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
//
//             // !! Attention to Governor Limit: Up to 100 call
//             Map<string, schema.sObjectField> m = sobjResult.fields.getMap();
//
//             for (String key : m.keySet()) {
//                 if (ignoreObject==false && !m.get(key).getDescribe().isAccessible()){
//                     continue;
//                 }
//                 schema.describeFieldResult descField = m.get(key).getDescribe();
//                 field_to_read += descField.getName() + ',';
//             }
//         } else {
//             // retrieve specified fields
//             // !! Attention to Governor Limit: Up to 100 call
//             Map<string, schema.sObjectField> m = targetType.getDescribe().fields.getMap();
//
//             for (string f : flds){
//                 if (ignoreObject==false && !m.get(f).getDescribe().isAccessible()){
//                     continue;
//                 }
//                 field_to_read += f + ',';
//             }
//         }
//         system.debug('++field_to_read : ' + field_to_read );
//         if (field_to_read == ''){
//             CrudFlsException e = new CrudFlsException('No field can be retrieved.');
//             throw e;
//         }
//         field_to_read = field_to_read.removeEnd(',');
//
//         string soql = 'select ' + field_to_read + ' from ' + objName + ' where id = :rid';
//         List<sObject> records;
//         try {
//             records = Database.query(soql);
//         } catch (QueryException e){
//             system.debug('Error ocurred on executing SOQL: ' + soql);
//             throw e;
//         }
//
//         if (records.size() == 0){
//             return null;
//         }
//         return records[0];
//     }
// */
//   /*  Bulkify Apex Methods - Using Collections in methods といわれるので、１つづつはやらない
//     public static void supdate(SObject o){
//         supdate(new List<SObject>{o}, false);
//     }*/
//
    //ラベル記号の引き換え
  //  public static String changeLabel(String str)
  //  {
    //    str = str.replace('&*RecType*&',System.Label.SB_NC_RecType);
   //     str = str.replace('&*smallRecType*&', System.Label.SB_NC_SmallRecordType);
  //      str = str.replace('&*account*&',System.Label.SB_NC_Account);
 //       str = str.replace('&*contact*&',System.Label.SB_NC_Contact);
 //      return str;
//
 // }
//     public static void supdate(List<SObject> os, Boolean opt_allOrNone){
//         supdate(os, true, opt_allOrNone);
//     }
//
// /*    public static void supdate(SObject o, Boolean strict){
//         supdate(new List<SObject>{o}, strict);
//     }*/
//
//   public static void supdate(List<SObject> os, Boolean strict, Boolean opt_allOrNone) {
//     if (os == null || os.isEmpty()) {
//       return;
//     }
//
//     if (Test.isRunningTest() == false && isIgnorableObject(os[0].getSObjectType()) == false) {
//       Schema.SObjectType targetType = os[0].getSObjectType();
//       if (targetType == null) {
//           throw new CrudFlsException('Object not found.');
//       }
//
//       Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
//       // オブジェクトの編集権限があるか
//       if (!sobjResult.isUpdateable()) {
//         throw new CrudFlsException(String.format(Label.SB_MSG_CrudNotUpdateable, new String[] {sobjResult.label}));
//       }
//
//       // !! Attention to Governor Limit: Up to 100 call
//       Map<string, schema.sObjectField> m = sobjResult.fields.getMap();
//
//       // 全部の項目が更新可能でないと例外
//       for (String key : m.keySet()) {
//           schema.describeFieldResult descField = m.get(key).getDescribe();
//         if (strict == true &&
//           (key.endsWithIgnoreCase('__c') || key == 'Name')
//           && isIgnorableField(targetType, key, false) == false     // Describeメソッドはなるべく使わずにチェック
//           && descField.getType() != DisplayType.location         // 2015.01.22  Location 型は isCreateable() とかでエラーになる。
//           && os[0].get(key) != null            // null にしている項目はよしとする。
//           && descField.isUpdateable() == false      // 更新可能？
//           && descField.isAutoNumber()==false         // 自動採番？ 弾いているが、再度検証
//           && descField.isCalculated()==false) {      // 数式？ 弾いているが、再度検証
//             throw new CrudFlsException(String.format(Label.SB_MSG_FlsNotUpdateable,
//                                       new String[] {sobjResult.label, descField.getLabel(), descField.getName()}));
//         }
//       }
//     }
//
//     Database.update(os, opt_allOrNone);
//   }
//
//   global static List<Database.SaveResult> supdateDuplicate(List<SObject> os, Database.DMLOptions dml) {
//     if (os == null || os.isEmpty()) {
//       return null;
//     }
//
//     if (Test.isRunningTest() == false && isIgnorableObject(os[0].getSObjectType()) == false) {
//       Schema.SObjectType targetType = os[0].getSObjectType();
//       if (targetType == null) {
//         throw new CrudFlsException('Object not found.');
//       }
//       Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
//       // オブジェクトの編集権限があるか
//       if (!sobjResult.isUpdateable()) {
//         throw new CrudFlsException(String.format(Label.SB_MSG_CrudNotUpdateable, new String[] {sobjResult.label}));
//       }
//     }
//
//     List<Database.SaveResult> sr = Database.update(os, dml);
//     return sr;
//   }
//
// /*    public static void supsert(SObject o){
//         supsert(o, false);
//     }
//
//     public static void supsert(SObject o, Boolean strict){
//     if (Test.isRunningTest() == false && isIgnorableObject(o.getSObjectType()) == false) {
//           Schema.SObjectType targetType = o.getSObjectType();
//           if (targetType == null) {
//               CrudFlsException e = new CrudFlsException('Object not found.');
//               throw e;
//           }
//
//           Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
//
//           // !! Attention to Governor Limit: Up to 100 call
//           Map<string, schema.sObjectField> m = sobjResult.fields.getMap();
//
//       // 全部の項目が更新可能でないと例外
//           for (String key : m.keySet()) {
//               schema.describeFieldResult descField = m.get(key).getDescribe();
//               if (strict == true
//           && (key.endsWithIgnoreCase('__c') || key == 'Name')
//           && isIgnorableField(targetType, key, false) == false     // Describeメソッドはなるべく使わずにチェック
//           && o.get(key) != null            // null にしている項目はよしとする。
//                 && descField.isCreateable() == false      // 作成可能
//                 && descField.isUpdateable() == false      // 更新可能？
//                 && descField.isAutoNumber()==false         // 自動採番？ 弾いているが、再度検証
//                 && descField.isCalculated()==false) {      // 数式？ 弾いているが、再度検証
//
// //        if (key != 'orderid__c' && key != 'orderref__c' && key.endsWithIgnoreCase('__c') || (key == 'Name')){    // Describeメソッドはなるべく使わずにチェック
//                       CrudFlsException e = new CrudFlsException('Object: ' + sobjResult.label +' Field: ' + key + ' is not updateable.');
//                       throw e;
//         }
//           }
//     }
//
//     upsert o;
//
//     }*/
//
//    // UPSERT
//    // sObject の List の upsert はできない。
// /*    public static void supsert(List<SObject> os, Boolean strict){
//         if (os == null || os.size() == 0){
//             return;
//         }
//
//     if (Test.isRunningTest() == false && isIgnorableObject(os[0].getSObjectType()) == false) {
//           Schema.SObjectType targetType = os[0].getSObjectType();
//           if (targetType == null) {
//               CrudFlsException e = new CrudFlsException('Object not found.');
//               throw e;
//           }
//
//           Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
//
//           // !! Attention to Governor Limit: Up to 100 call
//           Map<string, schema.sObjectField> m = sobjResult.fields.getMap();
//
//       // 全部の項目が更新可能でないと例外
//           for (String key : m.keySet()) {
//               schema.describeFieldResult descField = m.get(key).getDescribe();
//
//               if (strict == true
//           && (key.endsWithIgnoreCase('__c') || key == 'Name')
//           && isIgnorableField(targetType, key, true) == false     // Describeメソッドはなるべく使わずにチェック
//           && os[0].get(key) != null            // null にしている項目はよしとする。
//                 && descField.isCreateable() == false      // 作成可能
//                 && descField.isUpdateable() == false      // 更新可能？
//                 && descField.isAutoNumber()==false         // 自動採番？ 弾いているが、再度検証
//                 && descField.isCalculated()==false) {      // 数式？ 弾いているが、再度検証
//                       CrudFlsException e = new CrudFlsException('Object: ' + sobjResult.label +' Field: ' + key + ' is not upsertable.');
//                       throw e;
//         }
//           }
//     }
//
//     upsert os;
//
//     }*/
//
// }

}