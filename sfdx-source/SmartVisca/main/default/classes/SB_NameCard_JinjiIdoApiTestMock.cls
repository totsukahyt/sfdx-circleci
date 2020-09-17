/*
 * Copyright (c) 2014 SunBridge Inc.
 *
 * 日経テレコン人事異動情報 WSI API テストクラス
 * HTTPサービス用Mock
 *
 * 注意
 * http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_gov_limits.htm
 * Total number of callouts (HTTP requests or Web services calls) in a transaction         10
 * Maximum timeout for all callouts (HTTP requests or Web services calls) in a transaction 120 seconds
 * Default timeout of callouts (HTTP requests or Web services calls) in a transaction      10 seconds
 * Maximum size of callout request or response (HTTP request or Web services call)         3 MB
 *
 * @author fukui@sunbridge.com
 * @since 2014-11-28
 *
 * History:
 *      2018.07.xx v.2.0.2 sawano 同一複数名刺レコードで人事異動情報フラグがONのときの対応で、テストケース追加
 *
 */
global with sharing class SB_NameCard_JinjiIdoApiTestMock {
  /** ログイン・ログアウト用Mock */
  global class JinjiLogin implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
      return new HttpResponse();
    }
  }

  /** ログイン用Mock(Cookieなし) */
  global class JinjiLoginNonCookie implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
      return new HttpResponse();
    }
  }

  /** ログイン用Mock(メッセージ) */
  global class JinjiLoginMsg implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
      return new HttpResponse();
    }
  }

  /** 件数取得用Mock */
  global class JinjiGetCount implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
      return new HttpResponse();
    }
  }

  /** 一覧取得用Mock */
  global class JinjiGetList implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
      return new HttpResponse();
    }
  }

  /** 本文取得用Mock */
  global class JinjiGetBody implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
      return new HttpResponse();
    }
  }
}