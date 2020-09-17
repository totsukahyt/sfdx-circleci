/**
 *
 * SB_NC_DTO
 *   各オブジェクトのレコードを 名前空間プレフィクスなしで扱えるようのクラス の既定
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.03.xx
 *
 **/
public abstract class SB_NC_DTO {
  public SB_NC_DTO() {}
  public SB_NC_DTO(SObject obj) {}
  //public abstract void bind(SObject obj);

  //public static SB_NC_DTO getInstance(SObjectType otype) {
  //  SB_NC_DTO result = null;
  //  if (otype == NameCard__c.sObjectType) {
  //    result = new SB_NC_NameCardDTO();
  //  }
  //  return result;
  //}

  public static SB_NC_DTO getInstance(SObject obj) {
    SB_NC_DTO result = null;
    if (obj.getSObjectType() == NameCard__c.sObjectType) {
      result = new SB_NC_NameCardDTO(obj);
    }
    return result;
  }

  public static List<SB_NC_DTO> getInstance(List<SObject> objs) {
    List<SB_NC_DTO> result = new List<SB_NC_DTO>();
    for (SObject obj : objs) {
      if (obj.getSObjectType() == NameCard__c.sObjectType) {
        result.add(new SB_NC_NameCardDTO(obj));
      }
    }
    return result;
  }

}