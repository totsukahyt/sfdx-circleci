/*  $Id: SB_NameCard_NameCardListController.cls 1 2011-10-16 11:51:01Z ume $    */

/*
 * Copyright (c) 2011-2015 SunBridge
 *  
 * 名刺リスト
 *  @author gao
 *  @Version 1.20      2017.02.XX
 *  @Version 1.21      2018.02.XX   SV_DEV-428  「名刺で更新」ボタンの検索条件
 *  @Version 2.0.4     2019.02.XX   SV_DEV-1514 英訳ミス 残課題対応
 */
public with sharing class SB_NameCard_NameCardListController {
  public class SB_NameCard_NameCardListControllerException extends Exception {}

  private PageReference retUrl;
  public String title{get; private set;} // 取引先 or 取引先責任者
  public String aId{get; private set;} // 取引先
  public String cId{get; private set;} // 取引先責任者
  public List<NameCard__c> nameCards{get; private set;} // 名刺リスト
  public String accountLabel{get; private set;}
  public String contactLabel{get; private set;}
  public String searchType { get; set; } // 検索条件
  public String windowTitle { get; private set; }  // v2.0.4 Windowタイトル

  public SB_NameCard_NameCardListController() {
    try {
      this.aId = System.currentPageReference().getParameters().get('aid');
      this.cId = System.currentPageReference().getParameters().get('cid');

      this.accountLabel = Account.SobjectType.getDescribe().getLabel();

      this.contactLabel = Contact.SobjectType.getDescribe().getLabel();

      System.debug(Logginglevel.DEBUG, '################################################################################');
      System.debug(Logginglevel.DEBUG, 'parameter aid: ' + this.aId);
      System.debug(Logginglevel.DEBUG, 'parameter cid: ' + this.cId);
      System.debug(Logginglevel.DEBUG, '################################################################################');

      this.searchType = '0';

      if (this.cId != null) {
        this.retUrl = new PageReference('/' + this.cId);
        this.title = Contact.SobjectType.getDescribe().getLabel();
        this.search();
      } else if (this.aId != null) {
        this.retUrl = new PageReference('/' + this.aId);
        this.title = Account.SobjectType.getDescribe().getLabel();
        this.nameCards = this.getNameCardsByAccount(this.aId);
      } else {
        this.retUrl = new PageReference('/home/home.jsp');
        this.title = '';
      }

      System.debug(Logginglevel.DEBUG, '################################################################################');

      if (this.nameCards != null) {
          System.debug(Logginglevel.DEBUG, 'nameCards.size: ' + this.nameCards.size());
      } else {
        System.debug(Logginglevel.DEBUG, 'nameCards: null');
      }

      // Windowタイトル v2.0.4
      String titleForm = '{2}: '+ Label.SB_NC_CardList;
      this.windowTitle = String.format(titleForm,
            new String[] { Account.getSobjectType().getDescribe().getLabel(),
                            Contact.getSobjectType().getDescribe().getLabel(),
                            NameCard__c.getSobjectType().getDescribe().getLabel() });

      System.debug(Logginglevel.DEBUG, '################################################################################');
    } catch (Exception e) {
        ApexPages.addMessages(e);
    }
  }

  // 名刺リスト 取引先責任者
  private List<NameCard__c> getNameCardsByContact(String cId) {
    List<NameCard__c> sobjs;
    System.debug('CID IS  :' + cId);
    if (cId != null && cId.length() > 0) {
      // 2012.02.21 - 姓、名、メールアドレスが合致する名刺を表示

      Contact cobj = [SELECT
                      firstName, lastName, Email 
                      FROM Contact WHERE Id =:cId AND IsDeleted <> true];

      String wher = '';
      String lastName = cobj.LastName;
      String firstName = cobj.FirstName;
      String email = cobj.Email;
      // SV_DEV-428  「名刺で更新」ボタンの検索条件
      if (searchType == '0' && String.isNotBlank(lastName) && String.isNotBlank(firstName) && String.isNotBlank(email)) {
        wher = '(first_name__c=:firstName OR person_name_first__c=:firstName) '
                + 'AND (last_name__c=:lastName OR person_name_last__c=:lastName) '
                + 'AND email__c=:email';
      } else if (searchType == '1' && String.isNotBlank(email)) {
        wher = ' email__c=:email';
      } else if (searchType == '2' && String.isNotBlank(lastName) && String.isNotBlank(firstName)) {
        wher = '(first_name__c=:firstName OR person_name_first__c=:firstName) '
                + 'AND (last_name__c=:lastName OR person_name_last__c=:lastName) ';
      }

      if (String.isNotBlank(wher)) {
        String soql = 'SELECT'
                + ' Account__r.Name, Contact__r.Name,'
                + ' Id, company_name__c, Name, division__c,'
                + ' title_name__c, person_name_last__c, person_name_first__c, last_name__c, first_name__c,'
                + ' zip_code__c, address_pref__c, address__c, address_bld__c,'
                + ' tel1__c, fax1__c, mobile__c, email__c, web_url1__c,'
                + ' LastModifiedDate, Owner.Name, card_exchange_date__c '
              + ' FROM NameCard__c WHERE ' + wher + ' AND IsDeleted <> true'
            + ' ORDER BY card_exchange_date__c desc NULLS LAST limit 1001';

        sobjs = Database.query(soql);

        if (sobjs.size() > 1000) {
          soql = ' SELECT'
                + ' Account__r.Name, Contact__r.Name,'
                + ' Id, company_name__c, Name, division__c,'
                + ' title_name__c, person_name_last__c, person_name_first__c, last_name__c, first_name__c,'
                + ' zip_code__c, address_pref__c, address__c, address_bld__c,'
                + ' tel1__c, fax1__c, mobile__c, email__c, web_url1__c,'
                + ' LastModifiedDate, Owner.Name, card_exchange_date__c '
              + ' FROM NameCard__c WHERE ' + wher + ' IsDeleted <> true'
                                + ' AND Parent__c = null AND delivery_type__c != \'1\''
              + ' ORDER BY card_exchange_date__c desc NULLS LAST limit 1001';
          sobjs = Database.query(soql);

        }
      }
    }

    if (sobjs == null)
        sobjs = new List<NameCard__c>();

    return sobjs;
  }

  public void search() {
    this.nameCards = this.getNameCardsByContact(this.cId);
  }

  // selectOptions 取引先検索条件
  public List<SelectOption> getSearchTypeSelectOpts(){
    List<SelectOption> opts = new List<SelectOption>();
    //ラベル:メールアドレス
    String str = NameCard__c.email__c.getDescribe().getLabel();
    //ラベル:姓名
    String str1 = NameCard__c.person_name_last__c.getDescribe().getLabel()
            + '、' + NameCard__c.person_name_first__c.getDescribe().getLabel();
    opts.add(new SelectOption('0', str + System.Label.SB_NC_AND + str1));
    opts.add(new SelectOption('1', str));
    opts.add(new SelectOption('2', str1));

    return opts;
  }


  // 名刺リスト 取引先
  private List<NameCard__c> getNameCardsByAccount(String aId){
    List<NameCard__c> sobjs;
    System.debug('AID IS  :' + aId);
    if (aId != null && aId.length() > 0) {
      // 2012.02.21 - 会社名が合致する名刺を表示
      Account aobj = [SELECT Name
                      FROM Account WHERE Id =:aId AND IsDeleted <> true];
      
      if (aobj.Name != null) {
          sobjs = [SELECT
              Account__r.Name, Contact__r.Name,
              Id, company_name__c, Name, division__c,
              title_name__c, person_name_last__c, person_name_first__c, last_name__c, first_name__c,
              zip_code__c, address_pref__c, address__c, address_bld__c,
              tel1__c, fax1__c, mobile__c, email__c, web_url1__c,
              LastModifiedDate, Owner.Name, card_exchange_date__c 
          FROM NameCard__c WHERE company_name__c=:aobj.Name AND IsDeleted <> true
          ORDER BY card_exchange_date__c desc NULLS LAST limit 1001];

        if (sobjs.size() > 1000) {
          sobjs = [SELECT
              Account__r.Name, Contact__r.Name,
              Id, company_name__c, Name, division__c,
              title_name__c, person_name_last__c, person_name_first__c, last_name__c, first_name__c,
              zip_code__c, address_pref__c, address__c, address_bld__c,
              tel1__c, fax1__c, mobile__c, email__c, web_url1__c,
              LastModifiedDate, Owner.Name, card_exchange_date__c 
          FROM NameCard__c WHERE company_name__c=:aobj.Name AND Parent__c = null AND delivery_type__c != '1' 
                              AND IsDeleted <> true
          ORDER BY card_exchange_date__c desc NULLS LAST limit 1001];

          if (sobjs.size() > 1000) {
            throw new SB_NameCard_NameCardListControllerException('検索件数が制限値（1000件）を超えました');
          }
        }
      }
    }

    if (sobjs == null) {
      sobjs = new List<NameCard__c>();
    }

    return sobjs;
  }

  // キャンセル
  public PageReference cancel(){
    return this.retUrl;
  }
}