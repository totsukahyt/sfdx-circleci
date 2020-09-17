List<smvTest__NameCard__c> nameCardList;
List<Attachment> attList;
MAP<id,smvTest__NameCard__c> idNmeCardMap = new MAP<id,smvTest__NameCard__c>();
String BACK_IMAGE_NAME = '名刺裏';
String FRONT_IMAGE_NAME = '名刺表';
//名刺と添付ファイルのリスト取得
nameCardList = [SELECT id, smvTest__image_id__c, smvTest__bk_image_id__c, smvTest__contact__r.AccountId, smvTest__account__c  FROM smvTest__NameCard__c];
AttList = [SELECT id, parentId, name FROM Attachment WHERE parentId IN :nameCardList];
for(smvTest__NameCard__c nc: nameCardList){
    idNmeCardMap.put(nc.id, nc);
}

for(Attachment att : attList){
    if (att.name == BACK_IMAGE_NAME){
        idNmeCardMap.get(att.parentId).smvTest__image_id__c = att.id;
    }else if (att.name == FRONT_IMAGE_NAME){
        idNmeCardMap.get(att.parentId).smvTest__bk_image_id__c = att.id;
    }   
}
List<smvTest__NameCard__c> updNameCardList = new List<smvTest__NameCard__c>();
updNameCardList = idNmeCardMap.values();
for(Integer i=0 ; i < updNameCardList.size() ; i++){
    updNameCardList[i].smvTest__account__c = updNameCardList[i].smvTest__contact__r.AccountId;
}
update updNameCardList;