/**
 *  SB_NC_CardOwnersSortPickList
 *    「同じ名刺を持つユーザ」LWCの並び変え項目の選択肢
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1    2019.05.xx 
 *  
 **/
public class SB_NC_CardOwnersSortPickList extends VisualEditor.DynamicPickList {

  public override VisualEditor.DataRow getDefaultValue(){
    Map<String, Schema.SObjectField> uFields = User.getSObjectType().getDescribe().fields.getMap();
    VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(uFields.get('Name').getDescribe().getLabel(), 'name');
    return defaultValue;
  }

  public override VisualEditor.DynamicPickListRows getValues() {
    String nsx = SB_NameCard_Util.getNamespacePrefix_x();
    VisualEditor.DynamicPickListRows  result = new VisualEditor.DynamicPickListRows();
    Map<String, Schema.SObjectField> svFields = NameCard__c.getSObjectType().getDescribe().fields.getMap();
    Map<String, Schema.SObjectField> uFields = User.getSObjectType().getDescribe().fields.getMap();
    result.addRow(new VisualEditor.DataRow(uFields.get('Name').getDescribe().getLabel(), 'name'));
    result.addRow(new VisualEditor.DataRow(uFields.get('Department').getDescribe().getLabel(), 'department'));
    result.addRow(new VisualEditor.DataRow(svFields.get(nsx + 'card_exchange_date__c').getDescribe().getLabel(), 'exchangeDate'));
    return result;
  }
}