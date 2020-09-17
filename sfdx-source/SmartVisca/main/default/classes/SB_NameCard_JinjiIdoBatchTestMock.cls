/*
 * Copyright (c) 2014 SunBridge Inc.
 *
 * 日経テレコン人事異動情報 WSI API バッチ スケジューラ テストクラス
 * HTTPサービス用Mock
 *
 * @author fukui@sunbridge.com
 * @since 2014-12-02
 * @Version 1 kou 2017.10.xx No Assert v1.21 for code scan
 */


global class SB_NameCard_JinjiIdoBatchTestMock {
    /** バッチ処理用Mock */
    global class batch implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            return new HTTPResponse();
        }
    }
}