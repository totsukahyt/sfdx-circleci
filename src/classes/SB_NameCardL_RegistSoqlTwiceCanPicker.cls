/**
 *
 * SB_NameCardL_RegistSoqlTwiceCanPicker
 *
 *      登録先候補の 取引先、取引先責任者を 収集するクラスの1つ
 *
 *      '従来仕様 (取引先責任者SOQL+取引先SOQL)☓2'
 *
 *
 *
 **/
public with sharing class SB_NameCardL_RegistSoqlTwiceCanPicker extends SB_NameCardL_RegistCanPickerAbstract {
  @TestVisible
  private static final String LABEL = '従来仕様 取引先責任者SOQL + 取引先部分一致SOQL ☓ 2';

  public SB_NameCardL_RegistSoqlTwiceCanPicker() {
    super();
    //this.methodLabel = Label.SB_;
    this.methodLabel = LABEL;
  }

  public SB_NameCardL_RegistSoqlTwiceCanPicker(String label) {
    super();
    this.methodLabel = label;
  }

  public override Map<SObjectType, List<SObject>> create() {

     return this.otype2Objs;
  }

  public override Map<SObjectType, List<SObject>> create(Id cardId) {

     return this.otype2Objs;
  }

  //public override Map<Id, List<SObject>> create(Set<Id> cardIds) {
  //  Map<Id, List<SObject>> result = new Map<Id, List<SObject>>();
  public override Map<Id, Map<SObjectType, List<SObject>>> create(Set<Id> cardIds) {
    Map<Id, Map<SObjectType, List<SObject>>> result = new Map<Id, Map<SObjectType, List<SObject>>>();


    return result;
  }


}