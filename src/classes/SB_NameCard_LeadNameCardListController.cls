/*
 * (c) 2015 SunBridge Inc.
 *
 * リードを更新
 */

public with sharing class SB_NameCard_LeadNameCardListController
{

  public class NameCardRecord
  {
    public Integer index { get; set; }
    public SmartViscaf__NameCard__c nameCard { get; set; }

    public NameCardRecord(Integer index, SmartViscaf__NameCard__c nc)
    {
      this.index = index;
      this.nameCard = nc;
    }
  }

  public Boolean leadOverwrite { get; set; }
  public Integer nameCardRecordListIndex { get; set; }
  public List<NameCardRecord> nameCardRecordList { get; set; }
  public String overwriteLeadInfoLabel{get;set;}
  public String updateLeadLabel{get;set;}

  private Lead lead;

  public SB_NameCard_LeadNameCardListController(ApexPages.StandardController sc)
  {
    try {
      this.updateLeadLabel = System.Label.SB_NCLD_Text_UpdateLeadDEV;
      this.updateLeadLabel = this.updateLeadLabel.replace('&*Lead*&',System.Label.SB_NCLD_Text_Lead);
      this.updateLeadLabel = this.updateLeadLabel.replace('&*smallLead*&',System.Label.SB_NCLD_Text_SmallLead);
      this.overwriteLeadInfoLabel = System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV;
      this.overwriteLeadInfoLabel = this.overwriteLeadInfoLabel.replace('&*Lead*&',System.Label.SB_NCLD_Text_Lead);
      this.overwriteLeadInfoLabel = this.overwriteLeadInfoLabel.replace('&*smallLead*&',System.Label.SB_NCLD_Text_SmallLead);
      this.leadOverwrite = SB_NameCard_LeadRegist.svConfig.overwrite();
      this.nameCardRecordListIndex = -1;
      this.nameCardRecordList = new List<NameCardRecord>();

      this.lead = getLead(sc.getId());
      List<SmartViscaf__NameCard__c> nameCardList = getNameCardList(this.lead, false);
      if (nameCardList != null && nameCardList.size() > 1000) {
          nameCardList = getNameCardList(this.lead, true);
      }

      if (nameCardList != null && nameCardList.size() <= 1000) {
        for (SmartViscaf__NameCard__c nc : nameCardList) {
          this.nameCardRecordList.add(new NameCardRecord(this.nameCardRecordList.size(), nc));
        }
      }
    } catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }

  // リード
  private static Lead getLead(Id leadId)
  {
    if (leadId == null) return null;

    for (Lead lead : [SELECT Id, Name, Email, LastName, FirstName FROM Lead WHERE Id = :leadId]) {
      return lead;
    }
    return null;
  }

  // 名刺リスト
  private static List<SmartViscaf__NameCard__c> getNameCardList(Lead lead, Boolean latestonly)
  {
    if (lead == null) return null;

    List<String> whereList = new List<String>();
    String leadId, email, lastName, firstName;

    leadId = lead.Id;
    whereList.add('SmartViscaf__lead__c = :leadId');

    if (String.isNotBlank(lead.Email)) {
      email = lead.Email;
      whereList.add('SmartViscaf__email__c = :email');
    }
    if (String.isNotBlank(lead.LastName) && String.isNotBlank(lead.FirstName)) {
      lastName = lead.LastName;
      firstName = lead.FirstName;
      whereList.add('((SmartViscaf__person_name_last__c = :lastName OR SmartViscaf__last_name__c = :lastName)'
        + ' AND (SmartViscaf__person_name_first__c = :firstName OR SmartViscaf__first_name__c = :firstName))');
    }
    if (whereList.size() <= 0) return null;

    String whereStr = '';
    for (String s : whereList) whereStr += ' OR ' + s;
    whereStr = whereStr.removeStart(' OR ');
        if (latestonly) {
            whereStr = '(' + whereStr + ') AND SmartViscaf__delivery_type__c != \'1\' AND SmartViscaf__Parent__c = null';
        }


    String soql = 'SELECT Id, Name, OwnerId, Owner.Name, LastModifiedDate,'
      + ' SmartViscaf__zip_code__c, SmartViscaf__address_pref__c, SmartViscaf__address__c,'
      + ' SmartViscaf__address_bld__c, SmartViscaf__address_eng__c,'
      + ' SmartViscaf__company_name__c, SmartViscaf__web_url1__c, SmartViscaf__tel1__c, SmartViscaf__fax1__c, SmartViscaf__title_name__c,'
      + ' SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c, SmartViscaf__last_name__c, SmartViscaf__first_name__c,'
      + ' SmartViscaf__email__c, SmartViscaf__mobile__c, SmartViscaf__lead__c, campaign__c,'
      + ' SmartViscaf__list_name__c, SmartViscaf__memo__c, SmartViscaf__freehandmemo__c, SmartViscaf__card_exchange_date__c'
      + ' FROM SmartViscaf__NameCard__c'
      + ' WHERE ' + whereStr
      + ' ORDER BY SmartViscaf__card_exchange_date__c DESC NULLS LAST, SmartViscaf__company_name__c ASC NULLS LAST,'
      + ' SmartViscaf__address_pref__c ASC NULLS LAST, SmartViscaf__title_name__c ASC NULLS LAST, LastModifiedDate DESC LIMIT 1001';

    return Database.query(soql);
  }

  // 更新
  public PageReference save()
  {
    if (this.lead == null) return null;
    PageReference pageRef;
    Savepoint sp;

    try {
      if (this.nameCardRecordListIndex < 0 || this.nameCardRecordListIndex >= this.nameCardRecordList.size()) return null;
      NameCardRecord ncRec = this.nameCardRecordList.get(this.nameCardRecordListIndex);
      if (ncRec == null) return null;

      Lead updLead;
      if (this.leadOverwrite) {
        updLead = SB_NameCard_LeadRegist.getLead(this.lead.Id, ncRec.nameCard, null);
      } else {
        updLead = new Lead(Id=this.lead.Id, NameCard__c=ncRec.nameCard.Id);
      }

      sp = Database.setSavepoint();

      Database.DMLOptions leaddml = new Database.DMLOptions();

      leaddml.OptAllOrNone = false;

      SB_NameCard_LeadCrudFls.supdate(new List<Lead>{updLead}, leaddml);

      if (ncRec.nameCard.SmartViscaf__lead__c != updLead.Id) {


        Database.DMLOptions dml = new Database.DMLOptions();

        dml.OptAllOrNone = false;

        SB_NameCard_LeadCrudFls.supdate(new List<SmartViscaf__NameCard__c>{new SmartViscaf__NameCard__c(Id=ncRec.nameCard.Id, SmartViscaf__lead__c=updLead.Id)},dml);
      }
      pageRef = (new ApexPages.StandardController(updLead)).view();
    } catch (Exception e) {
      if (sp != null) Database.rollback(sp);
      ApexPages.addMessages(e);
    }
    return pageRef;
  }

  // キャンセル
  public PageReference cancel()
  {
    if (this.lead == null) return null;
    return (new ApexPages.StandardController(this.lead)).view();
  }
}