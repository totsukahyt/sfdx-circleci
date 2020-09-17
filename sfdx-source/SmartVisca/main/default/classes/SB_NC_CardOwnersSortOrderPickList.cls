/**
 *  SB_NC_CardOwnersSortOrderPickList
 *    「同じ名刺を持つユーザ」LWCの並び順の選択肢
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1    2019.10.xx 
 *  
 **/
public class SB_NC_CardOwnersSortOrderPickList extends VisualEditor.DynamicPickList {

  public override VisualEditor.DataRow getDefaultValue(){
    VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(System.Label.SB_NC_SORT_ASCENDING, 'asc');
    return defaultValue;
  }

  public override VisualEditor.DynamicPickListRows getValues() {
    VisualEditor.DynamicPickListRows  result = new VisualEditor.DynamicPickListRows();
    result.addRow(new VisualEditor.DataRow(System.Label.SB_NC_SORT_ASCENDING, 'asc'));
    result.addRow(new VisualEditor.DataRow(System.Label.SB_NC_SORT_DESCENDING, 'desc'));
    return result;
  }
}