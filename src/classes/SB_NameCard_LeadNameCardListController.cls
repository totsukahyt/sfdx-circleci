/*
 * (c) 2015 SunBridge Inc.
 *
 *  @Version 1    2017/11/XX SV_DEV-762 名刺オブジェクトの編集権限がない場合にリードに登録の処理が終了しない。
 *  @Version 1.12 2018/03/XX SV_DEV-523  Classic版 リード拡張パッケージでも「名刺で更新」ボタンのマッピング対応
 *
 *
 * リードを更新
 */

public with sharing class SB_NameCard_LeadNameCardListController{
  public class SB_NameCard_LeadNameCardListControllerException extends exception {}
  public class NameCardRecord{
    public Integer index { get; set; }
    public SmartViscaf__NameCard__c nameCard { get; set; }

    public NameCardRecord(Integer index, SmartViscaf__NameCard__c nc) {
      this.index = index;
      this.nameCard = nc;
    }
  }

  public SmartViscaf__NameCardBasicSetting__c  baseSetting{
    get{
      if (baseSetting == null) {
        baseSetting = SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting();
      }
      return baseSetting;
    }
    set;
  }

  public Boolean leadOverwrite { get; set; }
  public Integer nameCardRecordListIndex { get; set; }
  public List<NameCardRecord> nameCardRecordList { get; set; }
  public String overwriteLeadInfoLabel{get;set;}
  public String updateLeadLabel{get;set;}
  private final static String NAMECARD_QUERY_FROM = 'SELECT {0} FROM SmartViscaf__NameCard__c WHERE Id = :id';

  private Lead pageLead;

  public SB_NameCard_LeadNameCardListController(ApexPages.StandardController sc) {
    try {
      // this.updateLeadLabel = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Text_UpdateLeadDEV);
      this.updateLeadLabel = String.format(System.Label.SB_NCLD_Text_UpdateLeadDEV, new String[]{Lead.sObjectType.getDescribe().getLabel()});
      // this.overwriteLeadInfoLabel = SB_NameCard_LeadRegist.changeleadlabel(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV);
      this.overwriteLeadInfoLabel = String.format(System.Label.SB_NCLD_Label_OverwriteLeadInfoDEV, new String[]{Lead.sObjectType.getDescribe().getLabel()});
      this.leadOverwrite = !baseSetting.SmartViscaf__RegistLeadNotOverWrite__c && Lead.SObjectType.getDescribe().isUpdateable();
      this.nameCardRecordListIndex = -1;
      this.nameCardRecordList = new List<NameCardRecord>();

      this.pageLead = getLead(sc.getId());
      List<SmartViscaf__NameCard__c> nameCardList = getNameCardList(this.pageLead, false);
      if (nameCardList != null && nameCardList.size() > 1000) {
          nameCardList = getNameCardList(this.pageLead, true);
      }

      if (nameCardList != null && nameCardList.size() <= 1000) {
        for (SmartViscaf__NameCard__c nc : nameCardList) {
          this.nameCardRecordList.add(new NameCardRecord(this.nameCardRecordList.size(), nc));
        }
      }
    }
    catch (Exception e) {
      ApexPages.addMessages(e);
    }
  }

  // リード
  private static Lead getLead(Id leadId) {
    if (leadId == null) return null;

    for (Lead lead : [SELECT Id, Name, Email, LastName, FirstName FROM Lead WHERE Id = :leadId]) {
      return lead;
    }
    return null;
  }

  // 名刺リスト
  private static List<SmartViscaf__NameCard__c> getNameCardList(Lead lead, Boolean latestonly) {
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

    String soql = 'SELECT Id, Name, OwnerId, Owner.Name, LastModifiedDate,SmartViscaf__division__c,'
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
  // SV_DEV-762 名刺オブジェクトの編集権限がない場合にリードに登録の処理が終了しない。
  public PageReference saveLead() {
    if (this.pageLead == null) return null;
    PageReference pageRef;
    Savepoint sp;

    try {
      if (this.nameCardRecordListIndex < 0 || this.nameCardRecordListIndex >= this.nameCardRecordList.size()) return null;
      NameCardRecord ncRec = this.nameCardRecordList.get(this.nameCardRecordListIndex);
      if (ncRec == null) return null;

      SmartViscaf__NameCard__c nameCard = getNameCard(ncRec.nameCard.Id);
      Lead updLead;
      if (this.leadOverwrite) {
        SmartViscaf.SB_NameCard_RenkeiMapper mapper = SmartViscaf.SB_NameCard_RenkeiMapper.getInstance('Lead', true);
        updLead = (Lead)mapper.updateRecord(nameCard, this.pageLead.Id);
        //updLead = SB_NameCard_LeadRegist.getLead(this.pageLead.Id, ncRec.nameCard, null,null);
      } else {
        updLead = new Lead(Id=this.pageLead.Id, NameCard__c=ncRec.nameCard.Id);
      }

      sp = Database.setSavepoint();

      Database.DMLOptions leaddml = new Database.DMLOptions();

      leaddml.OptAllOrNone = true;

      SmartViscaf.SB_NameCard_CrudFls.supdate(new List<Lead>{updLead}, leaddml);

      if (ncRec.nameCard.SmartViscaf__lead__c != updLead.Id) {


        Database.DMLOptions dml = new Database.DMLOptions();

        dml.OptAllOrNone = false;

        SmartViscaf.SB_NameCard_CrudFls.supdate(new List<SmartViscaf__NameCard__c>{new SmartViscaf__NameCard__c(Id=ncRec.nameCard.Id, SmartViscaf__lead__c=updLead.Id)},dml);
      }
      pageRef = (new ApexPages.StandardController(updLead)).view();
    }
    catch (Exception e) {
      if (sp != null) Database.rollback(sp);
      SB_NameCard_LeadNameCardListControllerException aa = new SB_NameCard_LeadNameCardListControllerException();
      aa.setMessage(e.getMessage());
      ApexPages.addMessages(aa);
    }
    return pageRef;
  }

  // 名刺
  private SmartViscaf__NameCard__c getNameCard(String id) {
    Set<String> fields = SmartViscaf.SB_NameCard_RenkeiMapper.getInstance(Lead.sObjectType.getDescribe().getName(), false).getNameCardQueryFields();
    String ns = SmartViscaf.SB_NameCard_Util.getNamespacePrefix_x();
    // Name
    fields.add('Name');
    // 所有者
    fields.add('OwnerId');
    // 名刺交換日  2017.04.25
    fields.add(ns + 'card_exchange_date__c');
    // 会社名
    fields.add(ns + 'company_name__c');
    // 住所用の項目
    fields.add(ns + 'address_pref__c');
    fields.add(ns + 'address__c');
    fields.add(ns + 'address_eng__c');
    fields.add(ns + 'address_bld__c');
    // 姓名用の項目
    fields.add(ns + 'person_name_last__c');
    fields.add(ns + 'person_name_first__c');
    fields.add(ns + 'last_name__c');
    fields.add(ns + 'first_name__c');
    // 上書きしない
    fields.add(ns + 'isNotOverwrite__c');
    fields.add(ns + 'isNotOverContactwrite__c');
    // 参照項目
    fields.add(ns + 'account__c');
    fields.add(ns + 'contact__c');
    fields.add(ns + 'lead__c');
    //  CardHolder で 識別用に使っている項目
    fields.add(ns + 'division__c');
    fields.add(ns + 'zip_code__c');
    fields.add(ns + 'tel1__c');
    fields.add(ns + 'tel2__c');
    fields.add(ns + 'web_url1__c');
    fields.add(ns + 'web_url2__c');
    fields.add(ns + 'memo__c');
    fields.add(ns + 'email__c');

    //removeAddressLabel(fields);
    fields.remove('city');
    fields.remove('street');
    fields.remove('pref_address_bld');
    fields.remove('address_bld');
    fields.remove('street_nobld');
    fields.remove('last_name');
    fields.remove('first_name');
    // クエリ文字列
    String query = String.format(NAMECARD_QUERY_FROM, new String[] { String.join(new List<String>(fields), ', ') });
    System.debug('+++createNameCardMap: ' + query);
    return Database.query(query);
  }

  public void search() {
    this.nameCardRecordList = new List<NameCardRecord>();
     List<SmartViscaf__NameCard__c> nameCardList = getNameCardList(this.pageLead, false);
      if (nameCardList != null && nameCardList.size() > 1000) {
          nameCardList = getNameCardList(this.pageLead, true);
      }

      if (nameCardList != null && nameCardList.size() <= 1000) {
        for (SmartViscaf__NameCard__c nc : nameCardList) {
          this.nameCardRecordList.add(new NameCardRecord(this.nameCardRecordList.size(), nc));
        }
      }
  }

  // キャンセル
  public PageReference cancel() {
    if (this.pageLead == null) return null;
    return (new ApexPages.StandardController(this.pageLead)).view();
  }
}