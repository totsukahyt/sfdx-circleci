/**
 *
 * SB_NameCard_SettingsLcController
 * 権限判断
 *  Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.20      2017.02.XX
 *  @Version 2.4       2019.06.XX SV_DEV-1634 SmartVisca設定タブの自動連携に関する設定の表示/非表示を切り替えるカスタム設定を作る
 *  @Version 2.4       2019.06.XX SV_DEV-XXXX SmartVisca 基本設定機能追加
 *  @Version 2.4       2019.09.XX SV_DEV-1933 適切なオブジェクトアクセス権限が付与されていない場合はエラー
 *
 **/

public with sharing class SB_NameCard_SettingsLcController {

  @TestVisible
  public class CheckAccesable{
    @AuraEnabled public Boolean isa{get;set;}
    @AuraEnabled public String message{get;set;}
    @AuraEnabled public Boolean isDispRenkeiSetting{get;set;}

    private String SOQL_CHECK_ACCESABLE_SETTING = 'SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId in (SELECT ParentId FROM ObjectPermissions WHERE SobjectType =: nobj AND PermissionsRead = true AND PermissionsCreate = true AND PermissionsEdit = true And PermissionsDelete = true AND PermissionsViewAllRecords = true AND PermissionsModifyAllRecords = true) AND AssigneeId =: uid';

    public CheckAccesable(){
    }
    public void init(){
      this.isa = true;
      this.message = '';

      String setting = getAccessError('NameCardBasicSetting__c');
      if(String.isNotBlank(setting)){
        this.isa = false;
        this.message += setting;
      }

      String inherit = getAccessError('NameCardSettingValues__c');
      if(String.isNotBlank(inherit)){
        this.isa = false;
        this.message += inherit;
      }

      String mapping = getAccessError('NameCardRenkeiMapping__c');
      if(String.isNotBlank(mapping)){
        this.isa = false;
        this.message += mapping;
      }

      String jyouken = getAccessError('NameCardRenkeiJyoken__c');
      if(String.isNotBlank(jyouken)){
        this.isa = false;
        this.message += jyouken;
      }

      //自動連携表示/非表示に関するカスタム設定取得
      this.isDispRenkeiSetting = SB_NameCard_Util.isDispRenkeiSetting();
    }

    //アクセス権をチェック
    public String getAccessError(String os) {
      Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
      String nobj = SB_NameCard_RenkeiMapperUtil.getManagedObjectName(os);
      Map<String,Schema.SObjectField> fieldMap = schemaMap.get(nobj).getDescribe().fields.getMap();

      String message = '';
      Schema.SObjectType targetType = schemaMap.get(nobj);
      Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
      // SV_DEV-1933 ObjectPermissionsを見て適切な権限がなければエラーを返すよう仕様変更
/*
      // オブジェクトの編集権限があるか
      if (!sobjResult.isAccessible()) {
        return String.format(Label.SB_MSG_CrudNotAccessible,
          new String[] {sobjResult.label}) + '\n';
      }
*/
      Id uid = UserInfo.getUserId();
      String soql = SOQL_CHECK_ACCESABLE_SETTING;
      List<PermissionSetAssignment> psaList = Database.query(soql);
      if (psaList.size() == 0){
        return String.format(Label.SB_MSG_CrudNotAccessible,new String[] {sobjResult.label}) + '\n';
      }


      Map<string, schema.sObjectField> m = sobjResult.fields.getMap();
      Set<String> keys = fieldMap.keySet();    // 入力のあった項目s
      // 入力のあった項目が作成可能でないと例外
      for (String key : keys) {
        if(nobj == SB_NameCard_RenkeiMapperUtil.getManagedObjectName('NameCardRenkeiMapping__c') && (key == SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCardRenkeiMapping__c','NameCardLabel__c') || key == SB_NameCard_RenkeiMapperUtil.getManagedfileName('NameCardRenkeiMapping__c','TagetLabel__c'))){
          continue;
        }
        // String k = key.removeStart(namespace);   // SVのカスタム項目だとネームスペースがついてるので、とる  -> 37.0あたりでは不要
        schema.describeFieldResult descField = m.get(key).getDescribe();
        if (descField.getType() != DisplayType.location        // 2015.01.22  Location 型は isCreateable() とかでエラーになる。
          && descField.isPermissionable()           // 権限設定出来る項目だけ
          && descField.isAccessible() == false      // アクセス可能?
          && descField.isAutoNumber() == false      // 自動採番?
          && descField.isCalculated() == false) {   // 数式?
          message += String.format(Label.SB_MSG_FlsNotAccessible,
          new String[] {sobjResult.label, descField.getLabel(), descField.getName()}) + '\n';
        }
      }
      return message;
    }
  }

  @RemoteAction
  @AuraEnabled
  //権限のチェック
  public static String check(){
    CheckAccesable c = new CheckAccesable();
    try{
      c.init();
    }
    catch(Exception e){
      return 'error:  ' + e.getMessage();
    }
    //return c.message;
    return JSON.serialize(c);
  }

}