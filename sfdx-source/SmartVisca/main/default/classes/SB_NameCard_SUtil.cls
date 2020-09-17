/**
 *
 * SB_NameCard_SUtil
 * Salesforce1、LEX での JavaScript Remoting で使われる共通ルーチン
 *    v1.21 から
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.10.xx
 *
 **/
public with sharing class SB_NameCard_SUtil {
  /**
  *
  * 補助的なメソッド
  *
  **/
  @TestVisible
  private static List<String> getNamesWithRecordTypes(Set<Id>ids, String obj_name, List<String> recTypes) {
    List<String> result = new List<String>();
    Set<Id> targetIds = new Set<Id>(ids);
    String query = 'SELECT Id, Name FROM ' + obj_name + ' WHERE Id IN :targetIds';
    Set<String> targetRecTypeIds = null;
    if (recTypes !=null && !recTypes.isEmpty()) {   // テストコードように、recTypes の指定がなくてもとおるようにする
      targetRecTypeIds = new Set<String>(recTypes);
      query += ' AND RecordTypeId IN :targetRecTypeIds';
    }
    List<SObject> objs  = Database.query(query);
    for (SObject obj : objs) {
      result.add((String)obj.get('Name'));
    }
    return result;
  }

  // 指定のオブジェクトで最近参照したレコードのNameを返す 最大 100件
  public static List<String> getRecentlyViewed(String obj_name, List<String> recTypes) {
    List<String> result = new List<String>();
    List<AggregateResult> ars = [SELECT Id, Name, Type FROM RecentlyViewed WHERE Type = :obj_name Group by Id, Type, Name Order by Type, Name LIMIT 100];
    if (ars.isEmpty()) {
      return result;
    }
    if (recTypes == null || recTypes.isEmpty()) {
      for (AggregateResult ar : ars) {
        result.add((String)ar.get('Name'));
      }
    }
    else {
      Set<Id> ids = new Set<Id>();
      for (AggregateResult ar : ars) {
        ids.add((Id)ar.get('Id'));
      }
      result.addAll(getNamesWithRecordTypes(ids, obj_name, recTypes));
    }
    return result;
  }


}