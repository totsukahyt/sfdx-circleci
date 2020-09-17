/**
 *
 * SB_NameCard_ShowSameNameCardController
 * SB_NameCard_ShowSameNameCardControllerクラス
 *  Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author K.Yoshida
 *  @Version 2.2  2019.02.XX SV_DEV-1558 LEX 取引先登録 一括画面をLXパッケージ同様のLC化で追加
 *
 **/
public with sharing class SB_NameCard_ShowSameNameCardController{
    public PageReference showReport(){
        PageReference pageRef = null;
        List<Report> reportList = [select Id from Report where DeveloperName='SB_haveSameNameCard'];
        if ( reportList  != null && reportList.size()>0 ){
            pageRef = new PageReference('/' + reportList[0].Id + '?pv0=' + ApexPages.currentPage().getParameters().get('pv0') );
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.SB_MSG_HaveSameNameCardReportNotFound, ''));
        }
        return pageRef ;
    }
}