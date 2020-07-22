/*
 * (c) 2016 Sunbridge Inc.
 *
 * リードに登録
 * 共通クラス
 *
 *  2016.11.09  コードスキャンで global なメソッドは with sharing が必要とのことなので、 with sharing  を付けた。
 *  @Version 1 2017/11/XX  SV_DEV-681 Lead一括登録での候補検索時の姓、名の文字列のエスケープは完全一致なので、不要では。
 *                         SV_DEV-747 リード拡張パッケージのカスタム設定：リードに登録 リードレコードタイプ表示の初期値がOFF
 * lx2.1 2020.01.xx SV_DEV-1092 2.0.2アップデート後にカスタム設定のリード関連デフォルト値が変更され、リードのTodo件名のデフォルト「名刺交換」が空白値になる。
 */

global with sharing class SB_NameCard_LeadRegist
{
    global static final Integer SEARCHTYPE_EMAIL = 1;
    global static final Integer SEARCHTYPE_NAME  = 2;

    global class LeadRegistException extends Exception {}


    // SmartVisca設定
    global class SvConfig
    {
        global Map<String, Boolean> disp { get; private set; }
        private Map<String, Boolean> confMap = new Map<String, Boolean>();
        //private String todoSubject = '名刺交換';
        private String todoSubject = System.Label.SB_NCLD_Text_BusinessCardExchange;
        private String todoSubjectL = System.Label.SB_NCLD_Text_BusinessCardExchange;
        private Boolean registTodo;
        private Boolean registTodoL;

        private SmartViscaf__NameCardBasicSetting__c baseSetting;

        global SmartViscaf__SmartViscaConfig__c config { get; private set; }

        global SvConfig()
        {
            SmartViscaf__SmartViscaConfig__c conf = SmartViscaf__SmartViscaConfig__c.getInstance(UserInfo.getUserId());
            if (conf.Id == null) conf = SmartViscaf__SmartViscaConfig__c.getInstance(UserInfo.getProfileId());
            if (conf.Id == null) conf = SmartViscaf__SmartViscaConfig__c.getOrgDefaults();
            baseSetting = SmartViscaf.SB_NameCard_BasicSetting.getNameCardBasicSetting();

            config = conf;

            // SV_DEV-747 リード拡張パッケージのカスタム設定：リードに登録 リードレコードタイプ表示の初期値がOFF
            List<String> keyList = new List<String> {'Company', 'State', 'Title', 'Email', 'LastModifiedDate', 'Owner', 'LeadRectype'};
            this.disp = new Map<String, Boolean>();
            this.setBoolMap(keyList, this.disp, conf, 'Disp');

            keyList = new List<String> {'Overwrite', 'RegistTodo', 'DefaultShowLeadListNoExsiting'};
            this.setBoolMap(keyList, this.confMap, conf, null);

            // SV_DEV-1092 SmartVisca基本設定から読み込むよう修正
            //if (conf.Id != null && conf.get('LeadRegist_DispCompany__c') != null) {
            //    this.todoSubject = conf.LeadRegist_TodoSubject__c; // defined in Lead Package
            //}
            if (baseSetting.SmartViscaf__RegistToDoSubject__c != null) {
              this.todoSubject = baseSetting.SmartViscaf__RegistToDoSubject__c;
            }
            if (baseSetting.SmartViscaf__RegistLeadToDoSubject__c != null) {
              this.todoSubjectL = baseSetting.SmartViscaf__RegistLeadToDoSubject__c;
            }
            registTodo = !baseSetting.SmartViscaf__RegistNoToDo__c;       //登録"しない"フラグなので読み替え
            registTodoL = !baseSetting.SmartViscaf__RegistLeadNoToDo__c;  //登録"しない"フラグなので読み替え
        }

        private void setBoolMap(List<String> keyList, Map<String, Boolean> bMap, SmartViscaf__SmartViscaConfig__c conf, String keyPrefix)
        {
            if (conf.Id == null) {
                for (String key : keyList) {
                    bMap.put(key, true);
                }
            } else {
                if (String.isBlank(keyPrefix)) keyPrefix = '';
                Boolean b;
                for (String key : keyList) {
                    b = (Boolean)conf.get('LeadRegist_'+keyPrefix+key+'__c');
                    if (b == null) b = true;
                    bMap.put(key, b);
                }
            }
        }

        // SV_DEV-747 リード拡張パッケージのカスタム設定：リードに登録 リードレコードタイプ表示の初期値がOFF
        global Boolean leadRectype()
        {
            System.debug(this.confMap);
            return this.disp.get('LeadRectype');
        }

        global Boolean overwrite()
        {
            return this.confMap.get('Overwrite');
        }

        global String todoSubject()
        {
            return this.todoSubject;
        }

        global String todoSubjectL()
        {
            return this.todoSubjectL;
        }

        global Boolean registTodo()
        {
            // SV_DEV-1092 SmartVisca基本設定から読み込むよう修正
            //return this.confMap.get('RegistTodo');
            return this.registTodo;
        }

        global Boolean registTodoL()
        {
            return this.registTodoL;
        }

        global Boolean defaultDisplayExistingLead()
        {
            return this.confMap.get('DefaultShowLeadListNoExsiting');
        }
    }

    // インスタンス化させない
    private SB_NameCard_LeadRegist() {}

    //ラベル変更
    global static String changeleadlabel(String str)
    {
        return '';
    }

    // SmartVisca設定
    global static SvConfig svConfig
    {
        get {
            return (svConfig == null) ? new SvConfig() : svConfig;
        }
    }

    // ToDoの状況値
    global static Map<String, String> todoStatusMap
    {
        get {
            if (todoStatusMap != null) return todoStatusMap;

            todoStatusMap = new Map<String, String>();

            for (TaskStatus ts : [SELECT MasterLabel, IsDefault, IsClosed FROM TaskStatus WHERE IsDefault = true OR IsClosed = true]) {
                if (ts.IsDefault) todoStatusMap.put('IsDefault', ts.MasterLabel);
                if (ts.IsClosed) todoStatusMap.put('IsClosed', ts.MasterLabel);
            }
            return todoStatusMap;
        }
    }

    // 検索条件
    global static List<SelectOption> getSearchTypeList()
    {
        List<SelectOption> opts = new List<SelectOption>();

        //opts.add(new SelectOption(String.valueOf(SEARCHTYPE_EMAIL), 'メールアドレス'));
        //opts.add(new SelectOption(String.valueOf(SEARCHTYPE_NAME),  '氏名'));
        opts.add(new SelectOption(String.valueOf(SEARCHTYPE_EMAIL), System.Label.SB_NCLD_Label_Email));
        opts.add(new SelectOption(String.valueOf(SEARCHTYPE_NAME),  System.Label.SB_NCLD_Label_Name));

        return opts;
    }

    // 名刺
    global static SmartViscaf__NameCard__c getNameCard(Id ncId)
    {
        List<SmartViscaf__NameCard__c> selectedNcList = new List<SmartViscaf__NameCard__c> { new SmartViscaf__NameCard__c(Id=ncId) };
        List<SmartViscaf__NameCard__c> ncList = getNameCardList(selectedNcList);
        if (ncList.size() <= 0) return null;
        return ncList[0];
    }

    // 名刺リスト
    global static List<SmartViscaf__NameCard__c> getNameCardList(List<SmartViscaf__NameCard__c> selectedNcList)
    {
        List<SmartViscaf__NameCard__c> ncList = new List<SmartViscaf__NameCard__c>();
        //SV_DEV-175 リード登録時にキャンペーン内での状況を選択 キャンペーンのStatusクエリ
        for (SmartViscaf__NameCard__c nc : [SELECT Id, Name, OwnerId, Owner.IsActive,SmartViscaf__account__c,
                SmartViscaf__zip_code__c, SmartViscaf__address_pref__c, SmartViscaf__address__c,
                SmartViscaf__address_bld__c, SmartViscaf__address_eng__c,
                SmartViscaf__company_name__c, SmartViscaf__web_url1__c, SmartViscaf__tel1__c, SmartViscaf__fax1__c,
                SmartViscaf__division__c, SmartViscaf__title_name__c,
                SmartViscaf__person_name_last__c, SmartViscaf__person_name_first__c, SmartViscaf__last_name__c, SmartViscaf__first_name__c,
                SmartViscaf__email__c, SmartViscaf__mobile__c, SmartViscaf__lead__c, campaign__c, SmartViscaf__contact__c,campaign__r.Status,
                SmartViscaf__list_name__c, SmartViscaf__memo__c, SmartViscaf__freehandmemo__c, SmartViscaf__card_exchange_date__c
                FROM SmartViscaf__NameCard__c WHERE Id IN :selectedNcList]) {
            ncList.add(nc);
        }
        return ncList;
    }

    // リードSOQL文 (SEARCHTYPE_EMAIL)
    global static void setEmailSoql(Map<Integer, String> soqlMap, List<Id> emailIdList, List<String> emailList, List<SmartViscaf__NameCard__c> ncList)
    {
        for (SmartViscaf__NameCard__c nc : ncList) {
            if (nc.SmartViscaf__lead__c != null)             emailIdList.add(nc.SmartViscaf__lead__c);
            if (String.isNotBlank(nc.SmartViscaf__email__c)) emailList.add(nc.SmartViscaf__email__c);
        }

        List<String> whereList = new List<String>();
        if (emailIdList.size() > 0) whereList.add('Id IN :emailIdList');
        if (emailList.size() > 0)   whereList.add('Email IN :emailList');

        soqlMap.put(SEARCHTYPE_EMAIL, getSoql(whereList));
    }

    //************************************************************************************************************
    //未使用。global なので消せないので定義だけ残す。
    // リードSOQL文 (SEARCHTYPE_NAME)
    global static void setNameSoql(Map<Integer, String> soqlMap, List<Id> nameIdList, Set<String> nameSet, List<SmartViscaf__NameCard__c> ncList)
    {
        /************************************************************************************************************/
        //String name;

        //for (SmartViscaf__NameCard__c nc : ncList) {
        //    if (nc.SmartViscaf__lead__c != null) nameIdList.add(nc.SmartViscaf__lead__c);

        //    if ((name = getPersonName(nc)) != null) {
        //        String str = EncodingUtil.urlEncode(name,'UTF-8');
        //        Blob b = Blob.valueOf(str);
        //        String b64 = EncodingUtil.base64Encode(b);
        //        name = name.replaceAll('\'', b64);
        //        name = String.escapeSingleQuotes(name.replaceAll('＼','_'));
        //        name = name.replaceAll(b64, '\'');
        //        nameSet.add(name);

        //        //if (name.startsWith(' '))    nameSet.add('%'+name); // 名のみ
        //        //else if (name.endsWith(' ')) nameSet.add(name+'%'); // 姓のみ
        //    }
        //}
        //List<String> whereList = new List<String>();
        //if (nameIdList.size() > 0)  whereList.add('Id IN :nameIdList');
        //if (nameSet.size() > 0) whereList.add('Name LIKE :nameSet');

        //soqlMap.put(SEARCHTYPE_NAME, getSoql(whereList));
    }

    global static void setLastFirstNameSoql(Map<Integer, String> soqlMap, List<Id> nameIdList, Set<String> nameSet,Set<String> lastnameSet,Set<String> firstnameSet, List<SmartViscaf__NameCard__c> ncList)
    {
        String lastName;
        String firstName;

        for (SmartViscaf__NameCard__c nc : ncList) {
            if (nc.SmartViscaf__lead__c != null) {
                nameIdList.add(nc.SmartViscaf__lead__c);
            }
            //SV_DEV-681
            //Lead一括登録での候補検索時の姓、名の文字列のエスケープは完全一致なので、不要では。
            if ((lastName = getPersonLastName(nc)) != null) {
                // String str = EncodingUtil.urlEncode(lastName,'UTF-8');
                // Blob b = Blob.valueOf(str);
                // String b64 = EncodingUtil.base64Encode(b);
                // lastName = lastName.replaceAll('\'', b64);
                // lastName = String.escapeSingleQuotes(lastName.replaceAll('＼','_'));
                // lastName = lastName.replaceAll(b64, '\'');
                lastnameSet.add(lastName);
                //if (name.startsWith(' '))    nameSet.add('%'+name); // 名のみ
                //else if (name.endsWith(' ')) nameSet.add(name+'%'); // 姓のみ
            }
            if ((firstName = getPersonFirstName(nc)) != null) {
                // String str = EncodingUtil.urlEncode(firstName,'UTF-8');
                // Blob b = Blob.valueOf(str);
                // String b64 = EncodingUtil.base64Encode(b);
                // firstName = firstName.replaceAll('\'', b64);
                // firstName = String.escapeSingleQuotes(firstName.replaceAll('＼','_'));
                // firstName = firstName.replaceAll(b64, '\'');
                firstnameSet.add(firstName);
                //if (name.startsWith(' '))    nameSet.add('%'+name); // 名のみ
                //else if (name.endsWith(' ')) nameSet.add(name+'%'); // 姓のみ
            }
        }

        List<String> whereList = new List<String>();
        if (nameIdList.size() > 0)  {
            whereList.add('Id IN :nameIdList');
        }
        String str = '';
        if (lastnameSet.size() > 0) {
            str += ' LastName = :lastnameSet ';
            if (firstnameSet.size() > 0){
                str = '(' + str + ' AND FirstName = :firstnameSet' + ')';
            }
        } else if (firstnameSet.size() > 0){
                str = 'FirstName = :firstnameSet';
        }
        if (String.isNotBlank(str)) {
            whereList.add(str);
        }
        System.debug(firstnameSet);
        System.debug(lastnameSet);
        System.debug(whereList.size());
        System.debug(getSoql(whereList));
        soqlMap.put(SEARCHTYPE_NAME, getSoql(whereList));
    }

    // リードSOQL文
    global static String getSoql(List<String> whereList)
    {
        if (whereList == null || whereList.size() <= 0) return null;

        String soqlWhere = '';
        for (String s : whereList) soqlWhere += ' OR ' + s;
        soqlWhere = ' WHERE isConverted = FALSE AND (' + soqlWhere.removeStart(' OR ') + ')';

        return 'SELECT Id, Company, State,LastName,FirstName, Title, Name, Email, LastModifiedDate, OwnerId, Owner.Name FROM Lead'
            + soqlWhere
            + ' ORDER BY Company ASC NULLS LAST, State ASC NULLS LAST, Title ASC NULLS LAST, Name ASC NULLS LAST, Email ASC NULLS LAST';
    }

        // 名刺の姓
    global static String getPersonLastName(SmartViscaf__NameCard__c nc)
    {
        Map<String, String> pnMap = SmartViscaf.SB_NameCard_Util.getPersonName(nc);

        if (String.isBlank(pnMap.get('last_name'))) {
           return null;
        }
        return pnMap.get('last_name');
    }

       // 名刺の名
    global static String getPersonFirstName(SmartViscaf__NameCard__c nc)
    {
        Map<String, String> pnMap = SmartViscaf.SB_NameCard_Util.getPersonName(nc);

        if (String.isBlank(pnMap.get('first_name'))) {
            return null;
        }
        return pnMap.get('first_name'); // 姓名
    }

    // 名刺の姓名
    global static String getPersonName(SmartViscaf__NameCard__c nc)
    {
        Map<String, String> pnMap = SmartViscaf.SB_NameCard_Util.getPersonName(nc);

        if (String.isBlank(pnMap.get('last_name'))) {
            if (String.isBlank(pnMap.get('first_name'))) return null;
            return pnMap.get('first_name'); // 名のみ
        }
        if (String.isBlank(pnMap.get('first_name'))) {
            return pnMap.get('last_name'); // 姓のみ
        }

        return pnMap.get('last_name')+' '+pnMap.get('first_name'); // 姓名

    }

    // リード recordtype設定追加
    global static Lead getLead(Id leadId, SmartViscaf__NameCard__c nc, Id ownerId, Id recordtype)
    {
        Lead lead1;
        if (String.isNotBlank(recordtype)) {
            lead1 = (Lead)Lead.sObjectType.newSObject(recordtype, false);
            lead1.put('RecordTypeId',recordtype);
        }
        else {
            lead1 = (Lead)Lead.sObjectType.newSObject(null, false);
        }
        lead1.id = leadId;

        lead1.PostalCode = nc.SmartViscaf__zip_code__c;
        lead1.State = nc.SmartViscaf__address_pref__c;

        Map<String, String> adMap = SmartViscaf.SB_NameCard_Util.getAddress(nc);
        lead1.City = adMap.get('city');
        lead1.Street = adMap.get('street');

        lead1.Company = nc.SmartViscaf__company_name__c;
        lead1.Website = nc.SmartViscaf__web_url1__c;
        lead1.Phone = nc.SmartViscaf__tel1__c;
        lead1.Fax = nc.SmartViscaf__fax1__c;
        lead1.Title = nc.SmartViscaf__title_name__c;

        Map<String, String> pnMap = SmartViscaf.SB_NameCard_Util.getPersonName(nc);
        lead1.LastName = pnMap.get('last_name');
        lead1.FirstName = pnMap.get('first_name');

        lead1.Email = nc.SmartViscaf__email__c;
        lead1.MobilePhone = nc.SmartViscaf__mobile__c;

        lead1.NameCard__c = nc.Id;
        lead1.NameCardListName__c = nc.SmartViscaf__list_name__c;
        lead1.NameCardMemo__c = nc.SmartViscaf__memo__c;
        lead1.NameCardFreehandmemo__c = nc.SmartViscaf__freehandmemo__c;
        if (ownerId != null) lead1.OwnerId = ownerId;

        return lead1;
    }

    // SV_DEV-568 リード拡張パッケージ v1.11 追加、更新 package.xml
    //GlobalクラスのGlobalメソッドが削除されていたため、古いglobalメッソドを残します
    global static Lead getLead(Id leadId, SmartViscaf__NameCard__c nc, Id ownerId)
    {
        //レコードタイプを対応したため、パラメータを追加する必要です
        //global static Lead getLead(Id leadId, SmartViscaf__NameCard__c nc, Id ownerId, Id recordtype) 
        //↑メソッドを追加このメソッドを廃棄します、globalのため削除できません
        return null;
        //Lead lead = new Lead(Id=leadId);

        //lead.PostalCode = nc.SmartViscaf__zip_code__c;
        //lead.State = nc.SmartViscaf__address_pref__c;

        //Map<String, String> adMap = SmartViscaf.SB_NameCard_Util.getAddress(nc);
        //lead.City = adMap.get('city');
        //lead.Street = adMap.get('street');

        //lead.Company = nc.SmartViscaf__company_name__c;
        //lead.Website = nc.SmartViscaf__web_url1__c;
        //lead.Phone = nc.SmartViscaf__tel1__c;
        //lead.Fax = nc.SmartViscaf__fax1__c;
        //lead.Title = nc.SmartViscaf__title_name__c;

        //Map<String, String> pnMap = SmartViscaf.SB_NameCard_Util.getPersonName(nc);
        //lead.LastName = pnMap.get('last_name');
        //lead.FirstName = pnMap.get('first_name');

        //lead.Email = nc.SmartViscaf__email__c;
        //lead.MobilePhone = nc.SmartViscaf__mobile__c;

        //lead.NameCard__c = nc.Id;
        //lead.NameCardListName__c = nc.SmartViscaf__list_name__c;
        //lead.NameCardMemo__c = nc.SmartViscaf__memo__c;
        //lead.NameCardFreehandmemo__c = nc.SmartViscaf__freehandmemo__c;
        //if (ownerId != null) lead.OwnerId = ownerId;

        //return lead;
    }

    // ToDo
    global static Task getTodo(Id leadId, Id ownerId, String subject, Date cardExchangeDate)
    {
        Task todo = new Task(WhoId=leadId, Subject=subject, ActivityDate=cardExchangeDate, OwnerId=ownerId);

        if (todo.ActivityDate == null || todo.ActivityDate <= Date.today()) {
            todo.Status = todoStatusMap.get('IsClosed'); // 完了
        } else {
            todo.Status = todoStatusMap.get('IsDefault'); // 未着手
        }
        return todo;
    }
     // ToDoコメント付き
    global static Task getTodo(Id leadId, Id ownerId, String subject, Date cardExchangeDate,String description)
    {
        Task todo = new Task(WhoId=leadId, Subject=subject, ActivityDate=cardExchangeDate, OwnerId=ownerId,Description = description);

        if (todo.ActivityDate == null || todo.ActivityDate <= Date.today()) {
            todo.Status = todoStatusMap.get('IsClosed'); // 完了
        } else {
            todo.Status = todoStatusMap.get('IsDefault'); // 未着手
        }
        return todo;
    }
}