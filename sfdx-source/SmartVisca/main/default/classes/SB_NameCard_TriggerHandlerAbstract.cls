/**
 *
 *  SB_NameCard_LeadRenkeiTriggerHandler
 *   リード
 *
 *  Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.22      2018.01.xx
 *
 **/
global abstract with sharing class SB_NameCard_TriggerHandlerAbstract {

  protected Boolean runInsert;
  protected Boolean runUpdate;
  protected Boolean runDelete;
  protected Boolean runUndelete;

  public Boolean didInsert() {
    return this.runInsert;
  }

  global void doneInsert() {
    this.runInsert = true;
  }

  public Boolean didUpdate() {
    return this.runUpdate;
  }

  global void doneUpdate() {
    this.runUpdate = true;
  }

  public Boolean didDelete() {
    return this.runDelete;
  }

  global void doneDelete() {
    this.runDelete = true;
  }

  public Boolean didUndelete() {
    return this.runUndelete;
  }

  global void doneUndelete() {
    this.runUndelete = true;
  }

  global SB_NameCard_TriggerHandlerAbstract() {
    this.runInsert = false;
    this.runUpdate = false;
    this.runDelete = false;
    this.runUndelete = false;
  }

  global SB_NameCard_TriggerHandlerAbstract(Object param) {
    this.runInsert = false;
    this.runUpdate = false;
    this.runDelete = false;
    this.runUndelete = false;
  }

  //
  global abstract void onBeforeInsert(List<SObject> newObjs);

  //
  global abstract void onBeforeUpdate(List<SObject>  newObjs, Map<Id, SObject> oldMap);

  //
  global abstract void onBeforeDelete(List<SObject>  oldObjs, Map<Id, SObject> oldMap);

  //
  global abstract void onAfterInsert(List<SObject> newObjs);

  //
  global abstract void onAfterUpdate(List<SObject>  newObjs, Map<Id, SObject> oldMap);

  //
  global abstract void onAfterDelete(List<SObject>  oldObjs, Map<Id, SObject> oldMap);

  //
  global abstract void onUndelete(List<SObject> newObjs);
}