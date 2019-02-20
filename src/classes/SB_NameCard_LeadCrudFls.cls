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


  // 入力のあった項目API名を抽出する。
  private static Set<String> getCheckFields(List<SObject> os) {
    Set<String> result = new Set<String>();
    for (SObject o : os) {
      result.addAll(o.getPopulatedFieldsAsMap().keySet());
    }
    return result;
  }


  global static List<Database.SaveResult> screate(List<SObject> os, Database.DMLOptions dml) {
    Schema.SObjectType targetType = os[0].getSObjectType();
    Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
    // オブジェクト作成権限があるか
    if (!sobjResult.isCreateable()) {
        throw new CrudFlsException(String.format(Label.SB_NCLD_MSG_CrudNotCreateable, new String[] {sobjResult.label}));
    }
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
    List<Database.SaveResult> sr = Database.insert(os, dml);
    return sr;
  }


  global static List<Database.SaveResult> supdate(List<SObject> os, Database.DMLOptions dml) {
    Schema.SObjectType targetType = os[0].getSObjectType();
    Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
    // オブジェクトの編集権限があるか
    if (!sobjResult.isUpdateable()) {
        throw new CrudFlsException(String.format(Label.SB_NCLD_MSG_CrudNotUpdateable, new String[] {sobjResult.label}));
    }

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
     List<Database.SaveResult> sr = Database.update(os, dml);
     return sr;
   }


}