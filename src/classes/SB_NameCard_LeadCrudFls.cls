/**
 *
 * AppExchange セキュリティレビュー要件 CRUD FLS チェック 付き DML を提供するクラス
 *
 * Copyright (C) 2014 − 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano, gao
 *  @Version 1      2014.07.xx
 *  @Version 2      2016.07.xx オブジェクト権限のチェックを追加   かつては ディスクドライブメソッドはガバナ制限があったけど今はなし
 *  @Version 3      2016.08.xx getPopulatedFieldsAsMap を使って入力のあった項目に絞ってすべて検査  メソッドを整理
 *  @Version 4      2016.09.xx SV_DEV-147 LeadパッケージにCURL追加
 *  @Version 5      2016.11.09 コードスキャンで global なメソッドは with sharing が必要とのことなので、 with sharing  を付けた。
 *  @Version 1.12   2018.03.XX SV_DEV-756  リードのSB_NameCard_CrudFlsを基本パッケージのCRUDを呼びして、中身を空にする
 *
 **/
 global with sharing class SB_NameCard_LeadCrudFls {
  // 基本パッケージのSB_NameCard_CrudFlsクラス使いますので中身を削除
  global static List<Database.SaveResult> screate(List<SObject> os, Database.DMLOptions dml) {
    return null;
  }

  // 基本パッケージのSB_NameCard_CrudFlsクラス使いますので中身を削除
  global static List<Database.SaveResult> supdate(List<SObject> os, Database.DMLOptions dml) {
    return null;
   }


}