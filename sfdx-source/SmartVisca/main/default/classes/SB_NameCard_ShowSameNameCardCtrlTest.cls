/**
 *
 * SB_NameCard_ShowSameNameCardCtrlTest 
 * SB_NameCard_ShowSameNameCardControllerクラス
 *  Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author K.Yoshida
 *  @Version 2.2    2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 *  @Version 2.2    sawano   2019.03.XX 2.1.1 パッチで で2019.02 コードスキャンをパス → セキュリティレビュー更新 2.2へ反映
 *
 **/
@isTest
private class SB_NameCard_ShowSameNameCardCtrlTest {
    // エンドユーザの環境で「同じ名刺を持っている社員」レポートが削除されてしまった場合に備え、(SeeAllData='true')を使用した正常系のテストは控えておきます
    @isTest static void testShowReport() {
        PageReference pageRef;
        SB_NameCard_ShowSameNameCardController con = new SB_NameCard_ShowSameNameCardController();
        pageRef = con.showReport();
        System.assert(pageRef == null);
    }

}