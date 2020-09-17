/**
 *
 *  SB_NameCard_TriggerHandlerDummy
 *   SB_NameCard_TriggerHandlerAbstract のテスト用
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.22      2018.02.xx
 *
 **/
public with sharing class SB_NameCard_TriggerHandlerDummy extends SB_NameCard_TriggerHandlerAbstract {
  Integer cnt;

  public SB_NameCard_TriggerHandlerDummy() {
    cnt = 0;
  }

  public SB_NameCard_TriggerHandlerDummy(Object o) {
    super(o);
    cnt = 0;
  }

  public override void onBeforeInsert(List<SObject> newObjs) {
    doneInsert();
    cnt++;
    System.debug('onBeforeInsert: ' + cnt);
  }

  //
  public override void onBeforeUpdate(List<SObject>  newObjs, Map<Id, SObject> oldMap) {
    doneUpdate();
    cnt++;
    System.debug('onBeforeUpdate: ' + cnt);
  }

  public override void onBeforeDelete(List<SObject>  oldObjs, Map<Id, SObject> oldMap) {
    doneDelete();
    cnt++;
    System.debug('onBeforeDelete: ' + cnt);
  }

  public override void onAfterInsert(List<SObject> newObjs) {
    doneInsert();
    cnt++;
    System.debug('onAfterInsert: ' + cnt);
  }

  public override void onAfterUpdate(List<SObject>  newObjs, Map<Id, SObject> oldMap) {
    doneUpdate();
    cnt++;
    System.debug('onAfterUpdate: ' + cnt);
  }

  public override void onAfterDelete(List<SObject>  oldObjs, Map<Id, SObject> oldMap) {
    doneDelete();
    cnt++;
    System.debug('onAfterDelete: ' + cnt);
  }

  public override void onUndelete(List<SObject> newObjs) {
    doneUndelete();
    cnt++;
    System.debug('onUndelete: ' + cnt);
  }

}