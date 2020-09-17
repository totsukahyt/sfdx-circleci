/**
 * SB_NC_LookupModalLcController
 *  SmartVisca LEX対応
 *   Lightning Component 用 APEXコントローラ
 *
 *
 * Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.11.xx
 *  @Version 2.5    2020.01.xx SV_DEV-2100 LEX 転職先設定：半角スペース＋1文字検索した場合に「search term must be longer than one character:」エラーになる
 *
 **/
public with sharing class SB_NC_LookupModalLcController {
  public class SB_NC_LookupModalLcControllerException extends Exception {}

  public static String namespace {
    get {
      if (namespace == null) {
        namespace = SB_NameCard_Util.getNamespacePrefix();
      }
      return namespace;
    }
    private set;
  }


  public class LookupModalLabels {
    @AuraEnabled public Boolean success { get; private set; }
    @AuraEnabled public String error { get; private set; }
    @AuraEnabled public String sobjLabel { get; private set; }
    @AuraEnabled public String sobjName { get; private set; }
    @AuraEnabled public String someone { get; private set; }
    public LookupModalLabels(String sobjName) {
      this.sobjName = SB_NameCard_Util.getManagedObjectName(sobjName);
      try {
        DescribeSObjectResult dsr = Schema.getGlobalDescribe().get(this.sobjName).getDescribe();
        this.sobjLabel = dsr.getLabel();
        this.success = true;
      }
      catch(Exception e) {
        this.success = false;
        this.error = e.getMessage();
      }
    }
  }

  //@RemoteAction
  //@AuraEnabled
  //public static LookupModalLabels getLookupModalLabels(String sobjName) {
  //  LookupModalLabels result = new LookupModalLabels(sobjName);
  //  return result;
  //}
  @RemoteAction
  @AuraEnabled
  public static String getLookupModalLabels(String sobjName) {
    LookupModalLabels result = new LookupModalLabels(sobjName);
    return JSON.serialize(result);
  }


  //////// SOSL検索 ////////
  public class SearchRequest {
    @TestVisible public String searchString { get; private set; }
    @TestVisible public String sobjName { get; private set; }
    @TestVisible public String[] fields { get; private set; }
    @TestVisible public String condition { get; private set; }
    @TestVisible public String orderby { get; private set; }
    @TestVisible public Boolean ascend { get; private set; }
  }

  public class SearchResponse {
    @AuraEnabled public Boolean success { get; private set; }
    @AuraEnabled public String error { get; private set; }
    @AuraEnabled public List<SB_NC_DTO> objs {get; private set;}

    public SearchResponse(SearchRequest req) {
      try {
        //SV_DEV-2100 検索条件が2文字以下なら日本語でエラーメッセージが出るよう修正
        if (req.searchString.replaceAll('"','').trim().length() < 2){
          throw new SB_NC_LookupModalLcControllerException(System.Label.SB_MSG_MoreThanOneLetter);
        }

        // Sanitze the input
        String sanitizedSearchWord = SB_NameCard_Util.escapeSOSLYoyakugo(String.escapeSingleQuotes(req.searchString));
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(req.sobjName);

        Set<String> fs = new Set<String>(req.fields);
        fs.add('Id');
        fs.add('Name');
        String prefix = sanitizedSObjectAPIName != 'NameCard__c' || String.isBlank(namespace) ? '' : namespace + '__';

        String orderby = String.isNotBlank(req.orderby) ?
                  ' ORDER BY ' + req.orderby + ((req.ascend != null && !req.ascend) ? ' DESC' : '')
                  : '';        // オーダー;

        String query = 'FIND {' + sanitizedSearchWord + '} IN ALL FIELDS RETURNING ' + prefix + sanitizedSObjectAPIName +' (';
        for (String f : fs) {
          query += f + ', ';
        }
        query = query.removeEnd(', ');
        query += String.isNotBlank(req.condition) ? ' WHERE ' + req.condition : '';
        query += orderby;
        query += ') LIMIT 50';

        List<List<SObject>> searchList = Search.query(query);

        this.objs = SB_NC_DTO.getInstance(searchList[0]);
        this.success = true;
      }
      catch(Exception e) {
        this.success = false;
        this.error = e.getMessage();
      }
    }
  }

  //特定のオブジェクトに対してSOSLする
  //　AuraEnabled だと RemoteActionみたいに 引数をAPEXのクラスにできないみたいなので、JSONシリアライズした引数をわたしてデシリアライズする。
  //@RemoteAction
  //@AuraEnabled
  //public static SearchResponse searchSObject(String req) {
  //  SearchRequest request = (SearchRequest)JSON.deserialize(req, SearchRequest.class);
  //  System.debug(request);
  //  SearchResponse result = new SearchResponse(request);

  //  return result;
  //}
  @RemoteAction
  @AuraEnabled
  public static String searchSObject(String req) {
    SearchRequest request = (SearchRequest)JSON.deserialize(req, SearchRequest.class);
    System.debug(request);
    SearchResponse result = new SearchResponse(request);

    return JSON.serialize(result);
  }

}