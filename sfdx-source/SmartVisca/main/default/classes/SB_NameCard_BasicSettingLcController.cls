/**
 *
 * SB_NameCard_BasicSettingLcController
 * Lightning基本設定コンポーネントクラス
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author mao
 *  @Version 1.20      2017.02.xx
 *  @Version 1.22      2018.02.XX SV_DEV-735 基本設定レコードが二つ作成される
 *  @Version 2.1       2018.08.XX SV_DEV-877 基本設定の引き継ぐ項目には拡張パッケージ
 *  @Version 2.1       2018.08.XX SV_DEV-885 基本設定、連携条件設定、連携マッピングタブ切り替えの見直し
 *  @Version 2.0.2     2018.09.XX SV_DEV-1073 SmartVisca 基本設定の「キャンペーンメンバーの状況」の「ーなしー」を選択ができる。
 *  @Version 2.4       2019.06.XX SV_DEV-XXXX SmartVisca 基本設定機能追加
 *  @Version 2.5       2019.12.XX SV_DEV-2390 Classic SV設定：リード登録時のToDo登録機能に関する設定項目の追加
 *
 **/
public  class SB_NameCard_BasicSettingLcController {
  @TestVisible
  //データ管理クラス
  private class Basicdata{
    @AuraEnabled public Map<String, String> data{get; private set;}      //基本設定
    @AuraEnabled public String state{get; private set;}                  //保存状態
    @AuraEnabled public String message{get; private set;}                //保存メッセージ
    @AuraEnabled public Map<String, String> labMap{get; private set;}    //ラベルMap
    @AuraEnabled public Map<String, String> baseMap{get; private set;}   //項目表示ラベル(現在使ってません)
   
    @AuraEnabled public List<DualListboxBean> nayoseJyokenAvailableList{get; private set;}
    @AuraEnabled public List<String> nayoseJyokenSelectedList{get; private set;}
    @AuraEnabled public List<String> nayoseJyokenRequiredList{get; private set;}  //今のところ不使用、削除不可能な必須選択項目ができた場合は値を追加してください

    @AuraEnabled public List<DualListboxBean> inheritValueAvailableList{get; private set;}
    @AuraEnabled public List<String> inheritValueSelectedList{get; private set;}
    @AuraEnabled public List<String> inheritValueRequiredList{get; private set;}  //今のところ不使用、削除不可能な必須選択項目ができた場合は値を追加してください

    @AuraEnabled public List<Map<String,String>> registAccountCompareFieldList{get; private set;} //会社名の比較対象(取引先)
    @AuraEnabled public List<Map<String,String>> registLeadCompareFieldList   {get; private set;} //会社名の比較対象(リード)

    @AuraEnabled public List<RecordTypeBean> accRegistRecordTypeList{get; private set;} //検索対象の取引先レコードタイプ
    @AuraEnabled public List<RecordTypeBean> conRegistRecordTypeList{get; private set;} //検索対象の取引先責任者レコードタイプ
    @AuraEnabled public List<RecordTypeBean> leadRegistRecordTypeList{get; private set;}//検索対象のリードレコードタイプ
    
    @AuraEnabled public List<Map<String,String>> registToDoOwnerList{get; private set;} //ToDoの任命先
    @AuraEnabled public List<Map<String,String>> registLeadToDoOwnerList{get; private set;} //ToDoの任命先(リード)


    @AuraEnabled public Boolean isEnableLeadExtention{get; private set;} //リード拡張パッケージ存在するか
    @AuraEnabled public Boolean isEnableLeadExtention21{get; private set;}  //リード拡張パッケージ v2.1以降存在するか
    @AuraEnabled public Boolean isTriggerMergeExpandCriteria{get; private set;} //トリガで実施する名寄せの条件を拡張する
    @AuraEnabled public Boolean showInheritSetting{get; private set;} //リード拡張パッケージ存在するか
    @AuraEnabled public String lastTime {get; private set;} // 最終更新日
    @AuraEnabled public String lastName {get; private set;} //最終更新者
    @AuraEnabled public String lastId {get; private set;} // 最終更新者Id
    //SV_DEV-527 リード登録時にキャンペーン内での状況を選択

    //soql文
    private final String QUERY_FORM = 'SELECT {0} FROM NameCardBasicSetting__c ORDER BY CreatedDate ASC';

    // 名刺設定値 種別
    private final String SAISHIN_INHERIT = 'SaishinInherit';

    public Basicdata() {}
    //基本設定データを収得
    public  void getBasic(){
      this.isEnableLeadExtention = SB_NameCard_Util.isEnableLeadExt112();
      this.isEnableLeadExtention21 = SB_NameCard_Util.isEnableLeadExt21();
      this.isTriggerMergeExpandCriteria = SB_NameCard_Util.isTriggerMergeExpandCriteria();  //トリガで実施する名寄せの条件を拡張する
      this.baseMap = this.getmappingsetmap();
      this.message = '';
      //画面表示の基本設定をクエリ
      this.labMap = SB_NameCard_RenkeiMapperUtil.changeLabeltoMap('basicsetting');
      //DTOに変換
      this.data = SB_NameCard_NameCardBasicSettingDTO.bindSimple(SB_NameCard_BasicSetting.getNameCardBasicSetting());
      //会社名の比較対象(取引先)
      makeRegistAccountCompareFieldList();
      //会社名の比較対象(リード)
      makeRegistLeadCompareFieldList();
      //既存のレコードタイプを取得
      this.accRegistRecordTypeList = new List<RecordTypeBean>();
      this.conRegistRecordTypeList = new List<RecordTypeBean>();
      this.leadRegistRecordTypeList = new List<RecordTypeBean>();
      this.setRecordTypeList(Account.SObjectType, 'RegistAccountQueryRecordTypeIds__c', this.accRegistRecordTypeList);
      this.setRecordTypeList(Contact.SObjectType, 'RegistContactQueryRecordTypeIds__c', this.conRegistRecordTypeList);
      this.setRecordTypeList(Lead.SObjectType, 'RegistLeadQueryRecordTypeIds__c', this.leadRegistRecordTypeList);
      //ToDoの任命先
      makeRegistToDoOwnerList();
      //名刺の同一人物の判断条件
      makeNayoseJyokenList();
      //最新の名刺が値を引継ぐ機能(新)
      makeInheritValueList();
      if (String.isBlank(this.data.get('Id'))) {
        this.message = System.Label.SB_NC_SETTING_ERROR_No_NameCardBasicSetting;
      }
    }


    //会社名の比較対象(取引先)リスト生成
    private void makeRegistAccountCompareFieldList(){
      registAccountCompareFieldList = new List<Map<String,String>>();
      //リスト先頭の未選択アイテムの追加
      Map<String,String> tmpMap = new Map<String,String>();
      tmpMap.put('label','');
      tmpMap.put('value','');
      registAccountCompareFieldList.add(tmpMap);

      Map<String,Schema.SObjectField> fieldMap = Account.SobjectType.getDescribe().fields.getMap();
      for (Schema.SObjectField sfield : fieldMap.Values()) {
        Map<String,String> m = new Map<String,String>();
        Schema.describefieldresult dfield = sfield.getDescribe();
        //テキストエリアを除外
        //参照項目・オートナンバー・暗号化テキストを除外
        //個人取引項目も除去
        //JigsawCompanyIdもとりあえずは除外
        //取引先標準項目は除く ※含む場合は→を削除 dfield.isCustom() &&
        if ( dfield.getType() == Schema.DisplayType.STRING
               && dfield.getType() != Schema.DisplayType.TextArea
               && dfield.getType() != Schema.DisplayType.REFERENCE
               && !dfield.isAutoNumber()
               && !dfield.isEncrypted()
               && dfield.name != 'JigsawCompanyId' 
               && dfield.name != 'Name'
               &&  !isPersonAccountField(dfield)
               && dfield.isCustom()) {
          String label = dfield.getLabel();
          m.put('label',label);
          m.put('value',dfield.name);
          registAccountCompareFieldList.add(m);
        }
      }
    }

    //個人取引先項目判定
    private boolean isPersonAccountField(Schema.describefieldresult field){
      String label = field.getLabel();
      String fieldName = field.Name.toLowerCase();
      if (fieldName.endsWith('__pc')
                || (fieldName.startsWith('person')
                      && !field.isCustom())
                || SB_NameCard_RenkeiMapperUtil.PERSONALACCOUNT.contains(fieldName)) {
        return true;
      }
      return false;
    }

    //会社名の比較対象(リード)リスト生成
    private void makeRegistLeadCompareFieldList(){
      registLeadCompareFieldList = new List<Map<String,String>>();
      //リスト先頭の未選択アイテムの追加
      Map<String,String> tmpMap = new Map<String,String>();
      tmpMap.put('label','');
      tmpMap.put('value','');
      registLeadCompareFieldList.add(tmpMap);

      Map<String,Schema.SObjectField> fieldMap = Lead.SobjectType.getDescribe().fields.getMap();
      for (Schema.SObjectField sfield : fieldMap.Values()) {
        Map<String,String> m = new Map<String,String>();
        Schema.describefieldresult dfield = sfield.getDescribe();
        //テキストエリアを除外
        //参照項目・オートナンバー・暗号化テキストを除外
        //リード標準項目は除く ※含む場合は→を削除 dfield.isCustom() &&
        if ( dfield.getType() == Schema.DisplayType.STRING
               && dfield.getType() != Schema.DisplayType.TextArea
               && dfield.getType() != Schema.DisplayType.REFERENCE
               && !dfield.isAutoNumber()
               && !dfield.isEncrypted()
               && dfield.name != 'Company'
               && dfield.isCustom()) {
          m.put('label',dfield.getLabel());
          m.put('value',dfield.name);
          registLeadCompareFieldList.add(m);
        }
      }

    }


    //ToDoの任命先リスト生成
    private void makeRegistToDoOwnerList(){
      registToDoOwnerList = new List<Map<String,String>>();
      registLeadToDoOwnerList = new List<Map<String,String>>();

      makeRegistToDoOwnerList(registToDoOwnerList    ,NameCardBasicSetting__c.RegistToDoOwner__c.getDescribe().getPicklistValues());
      makeRegistToDoOwnerList(registLeadToDoOwnerList,NameCardBasicSetting__c.RegistLeadToDoOwner__c.getDescribe().getPicklistValues());
    }

    private void makeRegistToDoOwnerList(List<Map<String,String>> ownerList ,List<Schema.PicklistEntry> ple){
      for ( Schema.PicklistEntry f : ple) {
        Map<String,String> m = new Map<String,String>();
        m.put('label',f.getLabel());
        m.put('value',f.getValue());
        ownerList.add(m);
      }
    }

    // 名刺の同一人物の判断条件
    private void makeNayoseJyokenList() {
      this.nayoseJyokenAvailableList = new List<DualListboxBean>();
      this.nayoseJyokenSelectedList = new List<String>();
      //this.nayoseJyokenRequiredList = new List<String>();
      List<String> errorfield = new List<String>();

      // 選択可能値リスト：メールアドレス以外の文字列・電話番号・URLに限定して表示させる
      // 設定しても意味のない名刺オブジェクト パッケージ内項目は非表示にしておく
      // ■画像納品に関連する項目
      // 表・裏画像縦横フラグ、表・裏画像ID、表・裏サムネイルID、写真ID
      // ■スキャン/納品に関わるシステム項目
      // 名刺ID、自動連携処理情報、納品タイプ、コンピュータ名
      // ■姓名に関連する項目
      // キー、姓、名、ファーストネーム、ミドルネーム、ラストネーム
      // ■カナ項目
      // 会社名カナ、姓カナ、名カナ
      // ■そもそもが納品されない項目
      // FAX番号2、URL2
      // ※DisplayTypeの仕様は下記URLを参照
      // https://developer.salesforce.com/docs/atlas.ja-jp.apexcode.meta/apexcode/apex_enum_Schema_DisplayType.htm
      Map<String,Schema.SObjectField> ncFieldMap = SB_NameCard_RenkeiMapperUtil.getObjMap('NameCard__c'); // 名刺オブジェクト 全カスタム項目情報Map
      for (Schema.SObjectField field : ncFieldMap.values()) {
        Schema.describefieldresult dfield = field.getDescribe();
        if ( ( dfield.getType() == Schema.DisplayType.STRING || 
               dfield.getType() == Schema.DisplayType.Phone || 
               dfield.getType() == Schema.DisplayType.URL )
            && dfield.isCustom()
            && dfield.getType() != Schema.DisplayType.REFERENCE
            && dfield.getLength() <= 255
            && !dfield.isAutoNumber()
            && !dfield.isCalculated()
            && !dfield.isEncrypted()
            //■画像納品に関連する項目
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'email__c'
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'direction__c'
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'bk_direction__c'
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'image_id__c'
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'bk_image_id__c'
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'thumbnail_id__c'
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'bk_thumbnail_id__c'
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'portrait_id__c'
            // ■スキャン/納品に関わるシステム項目
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'card_id__c'
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'RenkeiMessage__c'
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'delivery_type__c'
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'env_machine_name__c'
            // ■姓名に関連する項目
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'key__c'
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'person_name_last__c'
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'person_name_first__c'
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'first_name__c'
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'middle_name__c'
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'last_name__c'
            // ■カナ項目
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'company_name_kana__c'
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'person_name_last_kana__c'
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'person_name_first_kana__c'
            // ■そもそもが納品されない項目
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'fax2__c'
            && dfield.name != SB_NameCard_Util.getNamespacePrefix_x() + 'web_url2__c'
           ){
          this.nayoseJyokenAvailableList.add(new DualListboxBean(dfield));
        }
      }
      /*
      for (Schema.SObjectField field : ncFieldMap.values()) {
        Schema.describefieldresult dfield = field.getDescribe();
        if ( !dfield.isCustom() || dfield.name.endswith('email__c') || dfield.name.endswith('Latitude__s') || dfield.name.endswith('Longitude__s') ) {
          continue;
        }
        this.nayoseJyokenAvailableList.add(new DualListboxBean(dfield));
      }
      */
      
      // 選択済みリスト：名刺オブジェクトにない項目はエラーにする
      String jyoken = this.data.get('NayoseJyoken__c');
      if (String.isNotBlank(jyoken)){
        for (String value : jyoken.split(';')) {
          String lowerCaseValue = value.toLowerCase();
          if (!ncFieldMap.containsKey(lowerCaseValue)) {
            errorfield.add(value);
            continue;
          } else {
            this.nayoseJyokenSelectedList.add(value);
          }
        }
      }

      // 選択不可リスト(ここで定義すると選択済みリスト値として扱われてしまう)
      //this.nayoseJyokenRequiredList.add(SB_NameCard_Util.getNamespacePrefix_x() + 'email__c');

      if (!errorfield.isEmpty()) {
        String str = '';
        for (String s : errorfield) {
          str += s + ',';
        }
        str = str.removeEnd(',');
        message += String.format(System.Label.SB_NC_MAPPING_NayoseJyoken_ErrorMessage,new String[]{str});
      }
    }

    //値を引継ぐ機能リスト生成
    private void makeInheritValueList() {
      this.inheritValueAvailableList = new List<DualListboxBean>();
      this.inheritValueSelectedList = new List<String>();
      //this.inheritValueRequiredList = new List<String>();
      List<String> errorfield = new List<String>();

      Map<String,Schema.SObjectField> ncFieldMap = SB_NameCard_RenkeiMapperUtil.getObjMap('NameCard__c'); // 名刺オブジェクト 全カスタム項目情報Map
      String nameSpace = SB_NameCard_Util.getNamespacePrefix_x();
      String nameSpaceLead = SB_NameCard_Util.getLeadExNamespacePrefix();
      Boolean isInstalledPKG = String.isNotBlank(nameSpace);
      Boolean isInstalledLead = String.isNotBlank(nameSpaceLead);

      // 選択可能値リスト：管理パッケージに含まれない項目を追加
      for (Schema.SObjectField field : ncFieldMap.values()) {
        Schema.describefieldresult dfield = field.getDescribe();
        if ( dfield.isDependentPicklist()
                || !dfield.isCustom()
                || dfield.name.endswith('Latitude__s')
                || dfield.name.endswith('Longitude__s')
                || dfield.isAutoNumber() == true
                || dfield.isCalculated() == true
                || (dfield.name.indexof(nameSpace)>=0 && isInstalledPKG == true)
                || (dfield.name.indexof(nameSpaceLead)>=0 && isInstalledLead == true)
            ) {
          continue;
        }
        this.inheritValueAvailableList.add(new DualListboxBean(dfield));
      }
      // 選択可能値リストが空なら
      if (this.inheritValueAvailableList.isEmpty()) {
        showInheritSetting = false;
      }else{
        showInheritSetting = true;
      }

      // 選択済みリスト：名刺オブジェクトにない項目はエラーにする
      for (NameCardSettingValues__c settingValue : SB_NameCard_BasicSettingUtil.getSettingValues(SAISHIN_INHERIT)) {
        // ncFieldMapのkeyは小文字なので小文字に変更してチェック
        String lowerCaseValue = settingValue.TextValue01__c.toLowerCase();
        // 選択可能値リストは大文字小文字を区別
        String loadedValue = settingValue.TextValue01__c;

        // 緯度経度読み替え
        if(loadedValue.endswith('Latitude__s') || loadedValue.endswith('Longitude__s')){
          loadedValue = loadedValue.split('__')[0] + '__c';
          lowerCaseValue = lowerCaseValue.split('__')[0] + '__c';
          if(this.inheritValueSelectedList.contains(loadedValue)){
            continue;
          }
        }

        // 名刺項目に存在しなかったらエラー項目リストに入れます
        if (!ncFieldMap.containsKey(lowerCaseValue)) {
          errorfield.add(settingValue.TextValue01__c);
          continue;
        }
        this.inheritValueSelectedList.add(loadedValue);
      }

      // 選択不可リスト(ここで定義すると選択済みリスト値として扱われてしまう)
      //this.inheritValueRequiredList.add('');

      if (!errorfield.isEmpty()) {
        String str = '';
        for (String s : errorfield) {
          str += s + ',';
        }
        str = str.removeEnd(',');
        message += String.format(System.Label.SB_NC_MAPPING_Ingert_ErrorMessage,new String[]{str});
      }
    }

    //基本設定及び引き継ぐの保存
    public void saveBasic(Map<String,String> basesetMap,List<String> inheritSelectedList) {

      NameCardBasicSetting__c baseset = SB_NameCard_NameCardBasicSettingDTO.DebindSimple(basesetMap);
      String error = '';
      String isok = '';
      String fields = SB_NameCard_NameCardBasicSettingDTO.NC_QUERY_SIMPLE_FIELDS;
      fields += fields.contains('LastModifiedDate') ? '' : ',LastModifiedDate ';
      String QUERY = String.format(QUERY_FORM,new String[]{fields});
      List<NameCardBasicSetting__c> settings = Database.query(QUERY);
      NameCardBasicSetting__c setting = settings.size() > 0 ? settings[0] : SB_NameCard_BasicSetting.getNameCardBasicSetting();
      if (basesetMap.get('LastModifiedByDate') != String.valueOf(Datetime.valueOf(setting.LastModifiedDate))) {
        this.message = System.Label.SB_NC_SETTING_ERROR_OtherSection_Saved;
        // this.message = baseMap.get('LastModifiedByDate') + '    ' + LastModifiedDate;
        this.state = 'warning';
        return;
      }
      List<Schema.PicklistEntry> ple = NameCardSettingValues__c.Type__c.getDescribe().getPicklistValues();
      String first = ple[0].getValue();
      // 制御によって選択できないで場合デフォルト値を設定
      if (String.isBlank(first)) {
        first = 'SaishinInherit';
      }
      Map<Id,NameCardSettingValues__c> settingva = new Map<Id,NameCardSettingValues__c>(SB_NameCard_BasicSettingUtil.getSettingValues(first));
      for (String f : SB_NameCard_NameCardBasicSettingDTO.NC_QUERY_SIMPLE_FIELDS.split(',')) {
        if (f == 'Name' || f =='Id' || f =='LastModifiedById') {
          continue;
        }
        setting.put(f , baseset.get(f));
      }
      baseset = setting;
      Savepoint sp;
      sp = Database.setSavepoint();
      try{
        //基本設定がなければ新規作成
        if (String.isBlank(baseset.Id)) {
            SB_NameCard_CrudFls.screate(new NameCardBasicSetting__c[]{baseset},true);
        } else {
          System.debug('basesetis' + baseset.Id);
          SB_NameCard_CrudFls.supdate(new NameCardBasicSetting__c[]{baseset},true);
          System.debug('basesetis');
        }
        //削除リスト
        Map<String,NameCardSettingValues__c> sm = new Map<String,NameCardSettingValues__c>();
        for (NameCardSettingValues__c s : settingva.values()) {
          sm.put(s.TextValue01__c,s);
        }
        //新規リスト
        List<NameCardSettingValues__c> inl = new List<NameCardSettingValues__c>();
        //更新リスト
        List<NameCardSettingValues__c> up = new List<NameCardSettingValues__c>();

        Map<String,Schema.SObjectField> ncFieldMap = SB_NameCard_RenkeiMapperUtil.getObjMap('NameCard__c');
        Map<String,Schema.DisplayType> nametype = new Map<String,Schema.DisplayType>();
        for (Schema.SObjectField str : ncFieldMap.Values()) {
          Schema.describefieldresult dfield = str.getDescribe();
          nametype.put(dfield.name,dfield.gettype());
        }
        for (Integer i = 0 ; i<inheritSelectedList.size();i++) {
          String str = inheritSelectedList[i];
          if (String.isBlank(str)) {
            continue;
          }
          if (sm.containsKey(str)) {
            NameCardSettingValues__c upsv = sm.get(str);
            upsv.index__c = i;
            up.add(upsv);
            sm.remove(str);
          } else {
            if (nametype.get(str) == Schema.DisplayType.LOCATION) {
              NameCardSettingValues__c nsv = new NameCardSettingValues__c(TextValue01__c = str.split('__')[0] + '__Latitude__s' , Type__c = SAISHIN_INHERIT,index__c = i);
              NameCardSettingValues__c nsv1 = new NameCardSettingValues__c(TextValue01__c = str.split('__')[0] + '__Longitude__s', Type__c = SAISHIN_INHERIT,index__c = i);
              inl.add(nsv);
              inl.add(nsv1);
            } else {
              NameCardSettingValues__c nsv = new NameCardSettingValues__c(TextValue01__c = str , Type__c = SAISHIN_INHERIT,index__c = i);
              inl.add(nsv);
            }
          }
        }
        SB_NameCard_CrudFls.screate(inl,true);
        SB_NameCard_CrudFls.supdate(up,true);
        SB_NameCard_CrudFls.sdelete(sm.values());

      }
      catch(Exception e) {
        Database.rollback(sp);
        error = e.getMessage();
        this.state = 'ng';
        this.message = error;
        System.debug(e.getStackTraceString());
        return;
      }

      if (String.isBlank(error)) {
        error = System.Label.SB_NC_MAPPING_MSG_SAVEOK;
        isok = 'ok';
      }
      //エラーメッセージ
      this.message=error;
      this.state = String.isBlank(isok)?'ng':isok;

      QUERY = String.format(QUERY_FORM,new String[]{SB_NameCard_NameCardBasicSettingDTO.NC_QUERY_SIMPLE_FIELDS + ',LastModifiedDate,LastModifiedBy.Name'});
      List<NameCardBasicSetting__c> datas = Database.query(QUERY);
      if (datas.size()>0) {
        this.data = SB_NameCard_NameCardBasicSettingDTO.bindSimple(datas[0]);
        this.lastTime = String.valueOf(datas[0].LastModifiedDate);
        this.lastName = datas[0].LastModifiedBy.Name;
        this.lastId = datas[0].LastModifiedById;
      }
    }

    //基本設定項目APILabelMap
    public  Map<String,String> getMappingSetMap(){
      Map<String,Schema.SObjectField> fieldMap = NameCardBasicSetting__c.SobjectType.getDescribe().fields.getMap();
      Map<String,String> mappingmap = new Map<String,String>();
      for (Schema.SObjectField sfield : fieldMap.Values()) {
        Schema.describefieldresult dfield = sfield.getDescribe();
        String lab = '';
        if (dfield.getLabel().split(':').size()>1) {
          lab = dfield.getLabel().split(':')[1];
          if (lab.startsWith('自動連携で')) {
            lab = lab.removeStart('自動連携で');
          }
        } else {
          lab = dfield.getLabel();
        }
        mappingmap.put(SB_NameCard_RenkeiMapperUtil.getdeManagedfileName('NameCardBasicSetting__c',dfield.name),lab);
      }
      return mappingmap;
    }

    //レコードタイプ取得
    private void setRecordTypeList(Schema.SObjectType sobjType, String targetType,List<RecordTypeBean> recTypeList){
      String currentID = data.get(targetType);

      //定義されたレコードタイプリスト
      List<Schema.RecordTypeInfo> recordTypeInfos = sobjType.getDescribe().getRecordTypeInfos();

      //DB保存されていたレコードタイプリスト
      Set<String> currentIDSet = new Set<String>();
      if (String.isNotBlank(currentID)) {
        for (String str : currentID.split(';')) {
          currentIDSet.add(str);
        }
      }
      
      Set<String> availableIDSet = new Set<String>();  //現時点で有効性が確認できたレコードタイプのセット

      for (Schema.RecordTypeInfo info : recordTypeInfos) {
        //レコードタイプ有効性チェック
        if (!info.isAvailable() || info.isMaster()) {
          if (!info.isMaster() && (currentIDSet.contains(info.getRecordTypeId()))) {
            currentIDSet.remove(info.getRecordTypeId());
            this.message += String.format(System.Label.SB_NC_MAPPING_NoAvailableR_ErrorMessage,new String[]{sobjType.getDescribe().getLabel(),info.Name});
          }
          continue;
        }
        RecordTypeBean bean = new RecordTypeBean(info,currentIDSet.contains(info.getRecordTypeId()));
        if (bean.check == 'true') {
          currentIDSet.remove(info.getRecordTypeId());
          availableIDSet.add(info.getRecordTypeId());
        }
        recTypeList.add(bean);
      }

      currentID = '';
      for (Id str : availableIDSet) {
        if (String.isNotBlank(currentID)) {
          currentID += ';';
        }
         currentID += str;
      }
      data.put(targetType, currentID);

      //DBからロードしたレコードタイプに現時点で存在しない不正なレコードタイプが紛れていないかチェック
      if (!currentIDSet.isEmpty()) {
        for (String str : currentIDSet) {
          if (currentID.contains(str)) {
            continue;
          }
          this.message += String.format(System.Label.SB_NC_MAPPING_NoObject_ErrorMessage,new String[]{sobjType.getDescribe().getLabel(),str});
        }
      }
    }
  }

  @TestVisible
  //レコードタイプ選択リストバインド用bean
  public class RecordTypeBean{
      @AuraEnabled public String label{get;private set;}
      @AuraEnabled public String value{get;private set;}
      @AuraEnabled public String check{get;private set;}
      public RecordTypeBean(Schema.RecordTypeInfo info,Boolean check) {
        this.label = info.Name;
        this.value = info.getRecordTypeId();
        this.check = String.valueof(check);
      }

      public RecordTypeBean() {}
  }

  @TestVisible
  //DualListboxバインド用bean
  public class DualListboxBean {
    @AuraEnabled public String label{get;private set;}
    @AuraEnabled public String value{get;private set;}
    public DualListboxBean(Schema.describefieldresult dfield) {
      this.label = dfield.getLabel();
      this.value = dfield.getName();
    }
  }

  @RemoteAction
  @AuraEnabled
  //SB基本設定データを取得
  public static String getSetting() {
    Basicdata ba = new Basicdata();
    ba.getBasic();
    return JSON.serialize(ba);
  }

  @RemoteAction
  @AuraEnabled
  //基本設定及び引き継ぐの保存
  public static String saveSettingcu(Map<String,String> baseSet,List<String> inheritSelectedList) {
    system.debug(inheritSelectedList.size());
    Basicdata ba = new Basicdata();
    ba.saveBasic(baseset, inheritSelectedList);
    return JSON.serialize(ba);
  }
}