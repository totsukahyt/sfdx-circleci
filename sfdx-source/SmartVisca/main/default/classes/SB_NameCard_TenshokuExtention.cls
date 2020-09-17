public with sharing class SB_NameCard_TenshokuExtention {

    public class SB_NameCard_TenshokuExtentionException extends Exception {}

    public NameCard__c nameCard = null;

    public SB_NameCard_TenshokuExtention ( ApexPages.StandardController controller) {
        this.nameCard = (NameCard__c)controller.getRecord();
        //LightningStyleSheetを対応するため、Lightningにはjsボタン画面に表示できないため、チェックはControllerに移動
        if (this.nameCard.Saishin__c == false) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.SB_NC_CareerErrorNotLatest, ''));
        }
    }

    private static Integer callNumber = 0;

    private NameCard__c getSaishinReccursive( Id input) {
        Integer localCallNumber = callNumber++;
System.debug( '----- (' + localCallNumber + ') getSaishinReccursive start');

        NameCard__c ret = null;

        List<NameCard__c> nameCard = [SELECT Id, Name, Parent__c, Saishin__c FROM NameCard__c WHERE Id = :input AND delivery_type__c = '2' Limit 1];
System.debug( '----- (' + localCallNumber + ')');

        if ( nameCard.size() == 0) {
            return null;
        }
        else {
System.debug( '----- (' + localCallNumber + ') saishin__c=' + nameCard[0].Saishin__c);
            if ( nameCard[0].Saishin__c == true) {
System.debug( '----- (' + localCallNumber + ') 決定：' + nameCard[0].Name);
                ret = NameCard[0];
            }
            else {
System.debug( '----- (' + localCallNumber + ') 再帰へ');
                ret = getSaishinReccursive( nameCard[0].Parent__c);
            }
        }

System.debug( '----- (' + localCallNumber + ') getSaishinReccursive end');
        return ret;
    }

    public PageReference doSave() {

        //SB_FirstRunKeeper.SB_AftInsUpdOnNameCard = false;

        System.debug( '----- ' + nameCard.Name);
        System.debug( '----- ' + nameCard.tenshokugonomeishi__c);

        if ( nameCard.tenshokugonomeishi__c == null) {
            // 関連付けがとれた場合
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.SB_MSG_SelectNewCareer, ''));
            return null;
        }
        else if ( nameCard.tenshokugonomeishi__c == nameCard.Id) {
            // 自分自身と同じIDがセットされている
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.SB_MSG_NewCareerMustBeAnother, ''));
            return null;
        }
        else {
            // 関連付けが定義された場合

            // 自分自身を参照する名刺データを、転職後の名刺グループの最新のものに関連付ける

            // 自分自身を参照する名刺データを select
            List<NameCard__c> refferring = [SELECT Id, Name, Parent__c FROM NameCard__c WHERE Parent__c = :nameCard.Id AND delivery_type__c = '2'];

            // 転職後の名刺グループの最新名刺を取得
            NameCard__c newSaishin = getSaishinReccursive( nameCard.tenshokugonomeishi__c);

            if ( newSaishin == null) {
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.SB_MSG_NoLatestCardSelected, ''));
                return null;
            }
            // 2014.08.20 最新の名刺を転職後の名刺にするので、循環参照しないようにチェックします。
            if ( newSaishin.Id == nameCard.Id) {
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.SB_MSG_NewCareerCantBeOldOfSelf, ''));
                return null;
            }

System.debug( '----- 最新の名刺決定：' + newSaishin.Name);


            for ( NameCard__c local : refferring) {
System.debug( '----- local.Name=' + local.Name);
                local.Parent__c = newSaishin.id;
                local.tenshokuzumi__c = true;
            }

 //           update refferring;
            // 2014.4.2x CRUD/FLS 対応
            SB_NameCard_CrudFls.supdate(refferring, true);

            nameCard.Parent__c = newSaishin.id;
            nameCard.saishin__c = false;
            nameCard.tenshokuzumi__c = true;
//            update nameCard;
            // 2014.4.2x CRUD/FLS 対応
            list<NameCard__c> cards = new list<NameCard__c>();
            cards.add(nameCard);
            SB_NameCard_CrudFls.supdate(cards, true);

            return new ApexPages.StandardController(nameCard).view();
        }

    }

}