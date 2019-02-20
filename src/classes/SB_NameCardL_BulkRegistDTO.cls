/*
 * (c) 2016 Sunbridge Inc.
 *
 * 統合一括DTOクラス
 * @Version 1 201８/08/XX
*  @Version 拡張パッケージ：Lead Ex. 1.12 SV_DEV-1161 統合版の一括登録ではtodo登録の一括選択がない
 *
 */

public with sharing class SB_NameCardL_BulkRegistDTO {

  @AuraEnabled public InputValue inputV {get; set;} // 入力内容
  @AuraEnabled public TitleValue titleV {get; set;} // タイトル表示内容
  @AuraEnabled public List<CustomObject> dataList {get; set;} // 画面表示レコード
  @AuraEnabled public List<DataTableColumnField> fieldList {get; set;} // 画面表示項目

  /**
    * @description SB_NameCardL_BulkRegistDTOクラスのコンストラクタ
  **/
  public SB_NameCardL_BulkRegistDTO() {
    this.inputV = new InputValue();
    this.titleV = new TitleValue();
    this.dataList = new List<CustomObject>();
    this.fieldList = new List<DataTableColumnField>();
  }

  /**
    * @description DataListを設定メソッド
    * @param dataListValue DataListを設定したいSobjectリスト
  **/
  public void setDataList(List<Sobject> dataListValue) {
    this.dataList = new List<CustomObject>();
    for (Sobject sobj : dataListValue) {
      CustomObject co = new CustomObject();
      for (DataTableColumnField field : fieldList) {
        CustomField cf = new CustomField();
        if (String.isNotBlank(field.fieldName)) {
          cf.label = (String)sobj.get(field.fieldName);
          cf.value = (String)sobj.get(field.fieldName);
        }
        cf.type = field.type;
        cf.input = field.input;
        cf.fieldName = field.fieldName;
        co.cObjectMap.put(field.fieldName, cf);
      }
      co.id = (Id)sobj.get('Id');
      SB_NameCardL_BulkRegistDTO.CustomField cfOwner = new SB_NameCardL_BulkRegistDTO.CustomField();
      cfOwner.label = (String)sobj.get('OwnerId');
      cfOwner.value = (String)sobj.get('OwnerId');
      co.cObjectMap.put('OwnerId', cfOwner);
      SB_NameCardL_BulkRegistDTO.CustomField cfId = new SB_NameCardL_BulkRegistDTO.CustomField();
      cfId.label = (String)sobj.get('Id');
      cfId.value = (String)sobj.get('Id');
      co.cObjectMap.put('Id', cfId);
      this.dataList.add(co);
    }
  }

  /**
    * @description DataTable用行クラス
  **/
  public class CustomObject {
    // -------------------- Lightning 用 start -------------------- //
    @AuraEnabled public Map<String, CustomField> cObjectMap {get; set;}
    @AuraEnabled public Id id {get; set;}
    @AuraEnabled public Boolean haveError {get; set;}
    @AuraEnabled public Map<String, SB_NameCardL_BulkRegistDTO.InputPlickListValue> combobox {get; set;}
    // -------------------- Lightning 用 end -------------------- //

    // -------------------- Classic 用 start -------------------- //
    public SmartViscaf__NameCard__c nameCard {get; set;}
    public Boolean registTodo {get; set;}
    public Integer index {get; set;}
    public String message {get; set;}
    public Boolean hasError {get; set;}
    public String leadId {get; set;}
    public Integer accAndCon {get; set;}
    public List<AccAndCon> accAndConList {get; set;}
    // -------------------- Classic 用 end -------------------- //

    /**
    * @description DataTableクラスのコンストラクタ
    **/
    public CustomObject() {
      this.cObjectMap = new Map<String, CustomField>();
      this.accAndCon = -1;
    }

    /**
    * @description DataTableクラスのコンストラクタ
    * @param nameCard 名刺オブジェクト
    * @param rToDo ToDoに登録用フラグ
    **/
    public CustomObject(SmartViscaf__NameCard__c nameCard, Boolean rToDo) {
      this.nameCard = nameCard;
      this.registTodo = rToDo;
      this.index = -1;
      this.hasError = false;
      this.message = '';
      this.accAndConList = new List<AccAndCon>();
      this.leadId = '';
      this.haveError = false;
    }
  }

  public class AccAndCon{
    public Boolean regist { get; set; }
    public Id accountId { get; set; }
    public Id contactId { get; set; }

    public AccAndCon(){
      this.regist = false;
    }

    public AccAndCon(Id accountId, Id contactId){
      this.regist = true;
      this.accountId = accountId;
      this.contactId = contactId;
    }
  }


  /**
    * @description DataTable用Data項目クラス
  **/
  public class CustomField {
    @AuraEnabled public String fieldName {get; set;} // 項目API
    @AuraEnabled public String label {get; set;} // 表示値
    @AuraEnabled public String value {get; set;} // 実際値
    @AuraEnabled public String link {get; set;} // URL場合のLINK
    @AuraEnabled public Boolean checked {get; set;} // CheckBox場合の値
    @AuraEnabled public String selectValue {get; set;} // 選択リスト場合の選択された値
    @AuraEnabled public List<LabelValue> plickList {get; set;} // 選択リストの選択肢
    @AuraEnabled public String type {get; set;} // 項目タイプ
    @AuraEnabled public Boolean input {get; set;} // 入力フラグ

    /**
    * @description CustomFieldクラスのコンストラクタ
    **/
    public CustomField() {
      this.label = '';
      this.value = '';
      this.link = '';
      this.checked = false;
      this.selectValue = '';
      this.plicklist = new List<LabelValue>();
      this.input = false;
    }
  }

  /**
    * @description LightningDataTableタイトルとタイプ使用するBeanクラス
  **/
  public class DataTableColumnField {
    @AuraEnabled public String label {get; set;}
    @AuraEnabled public String fieldName {get; set;}
    @AuraEnabled public String type {get; set;}
    @AuraEnabled public Object typeAttributes {get; set;}
    @AuraEnabled public Boolean input {get; set;}
    @AuraEnabled public Boolean show {get; set;}
    @AuraEnabled public String eventName {get; set;}
    @AuraEnabled public String width {get; set;}
    @AuraEnabled public Boolean checkAll {get; set;}
    @AuraEnabled public Boolean checkAllCheck {get; set;}

    /**
     * @description DataTableColumnFieldBeanコンストラクタメソッド
     * @param labelValue タイトル表示ラベル
     * @param fieldNameValue タイトル表示ラベル
     * @param typeValue 表示タイプ名
     * @param typeValue 入力フラグ
    **/
    public DataTableColumnField(String labelValue, String fieldNameValue, String typeValue, Boolean inputValue) {
      this.label = labelValue;
      this.fieldName = fieldNameValue;
      this.type = typeValue;
      this.input = inputValue;
      this.show = true;
      this.eventName = '';
      this.width = '';
      this.checkAll = false;
      this.checkAllCheck = false;
    }

    /**
     * @description URLタイプの場合表示する項目を設定
     * @param urlLabelFieldAPIValue URLタイプの場合表示する項目名
    **/
    public void settypeAttributes(Map<String, object> typeAttributesValue) {
      this.typeAttributes = typeAttributesValue;
    }
  }

  /**
     * @description 画面表示用ラベル用クラス
  **/
  public class TitleValue {
    @AuraEnabled public String title {get; set;} // 一括登録タイトル
    @AuraEnabled public Integer cardCount {get; set;} // 名刺件数
    @AuraEnabled public String titleName {get; set;} // タイトル表示内容
    @AuraEnabled public String iconName {get; set;} // アイコン名
    @AuraEnabled public String iconSize {get; set;} // アイコンサイズ
    @AuraEnabled public String closeValue {get; set;} // 閉じるボタン表示内容
    @AuraEnabled public String saveValue {get; set;} // 保存ボタン表示内容

    /**
      * @description TitleValueクラスのコンストラクタ
    **/
    public TitleValue() {
      this.title = '';
      this.cardCount = 0;
      this.titleName = '';
      this.iconName = '';
      this.iconSize = '';
      this.closeValue = '';
      this.saveValue = '';
    }
  }

  /**
    * @description 入力用Class
  **/
  public class InputValue {
    @AuraEnabled public List<SearchCondition> searchConditions {get; set;} // クエリ条件
    @AuraEnabled public String searchConditionValue {get; set;} // 選択されたクエリ条件
    @AuraEnabled public List<SearchCondition> searchConditionsContact {get; set;} // クエリ条件
    @AuraEnabled public String searchConditionValueContact {get; set;} // 選択されたクエリ条件
    @AuraEnabled public SearchConditionRecordType searchConditionRct {get; set;} // レコードタイプ条件エリア情報
    @AuraEnabled public String searchRecordTypes {get; set;} // 選択されたレコードタイプ
    @AuraEnabled public Map<String, List<String>> searchRecordTypesMap {get; set;} // 選択されたレコードタイプマップ
    @AuraEnabled public List<InputPlickListValue> InputPlickListValues {get; set;} // レコードタイプ登録に関する入力
    @AuraEnabled public Boolean showRecordType {get; set;} // レコードタイプ登録に関する入力
    @AuraEnabled public List<InputRegistOverWritValue> inputRegistOverWritValues {get; set;} // 上書き登録に関する入力
    @AuraEnabled public Boolean showOverWrite {get; set;} // 上書き登録に関する入力
    @AuraEnabled public String campaignId {get; set;} // 選択されたキャンペーンID
    @AuraEnabled public String campaignLabel {get; set;} // キャンペーンラベル
    @AuraEnabled public InputPlickListValue campaignStatusPlick {get; set;} // キャンペーンメンバーStatusの選択リスト
    @AuraEnabled public String ownerId {get; set;} // 選択された所有者ID
    @AuraEnabled public String accountOwnerId {get; set;} // 選択された所有者ID
    @AuraEnabled public String ownerLabel {get; set;} // 所有者表示ラベル
    @AuraEnabled public String accountOwnerLabel {get; set;} // 所有者表示ラベル
    @AuraEnabled public Boolean useNameCardOwner {get; set;} // 名刺所有者使用
    @AuraEnabled public Boolean useNameCardAccountOwner {get; set;} // 名刺所有者使用
    @AuraEnabled public String useNameCardOwnerLabel {get; set;} // 名刺所有者使用表示ラベル
    @AuraEnabled public String useNameCardAccountOwnerLabel {get; set;} // 名刺所有者使用表示ラベル
    @AuraEnabled public Boolean haveQueue {get; set;} // キューが存在
    @AuraEnabled public String queueLabel {get; set;} // キューの表示ラベル
    @AuraEnabled public String userLabel {get; set;} // ユーザの表示ラベル
    @AuraEnabled public Map<String, String> labelMap {get; set;} // 画面表示したい動的ラベル
    @AuraEnabled public Authority accountAuthority {get; set;} // 取引先権限
    @AuraEnabled public Authority contactAuthority {get; set;} // 取引先責任者権限
    @AuraEnabled public Authority leadAuthority {get; set;} // リード権限
    @AuraEnabled public Authority campaignAuthority {get; set;} // リード権限
    @AuraEnabled public Boolean nameCardCampaignisAccessible {get; set;} // リード権限
    @AuraEnabled public Boolean campaignStatusisAccessible {get; set;} // リード権限
    @AuraEnabled public String accountLabel {get; set;} // 取引先オブジェクト表示ラベル権限
    @AuraEnabled public String contactLabel {get; set;} // 取引先責任者オブジェクト表示ラベル権限
    @AuraEnabled public String leadLabel {get; set;} // リードオブジェクト表示ラベル権限
    @AuraEnabled public String newSectionLabel {get; set;} // 新規セクショ表示ラベル
    @AuraEnabled public String overWriteLabel {get; set;} // リードオブジェクト表示ラベル権限
    // ----------------------------  Lead  ----------------------------//
    //@AuraEnabled public List<InputRegistValue> campaign {get; set;} // 登録に関する入力

    /**
      * @description InputValueクラスのコンストラクタ
    **/
    public InputValue() {
      this.searchConditions = new List<SearchCondition>();
      this.searchConditionValue = '';
      this.searchConditionsContact = new List<SearchCondition>();
      this.searchConditionValueContact = '';
      this.searchConditionRct = new SearchConditionRecordType();
      this.searchRecordTypes = '';
      this.searchRecordTypesMap = new Map<String, List<String>>();
      this.InputPlickListValues = new List<InputPlickListValue>();
      this.inputRegistOverWritValues = new List<InputRegistOverWritValue>();
      this.campaignId = '';
      this.ownerId = '';
      this.accountOwnerId = '';
      this.campaignLabel = '';
      this.useNameCardOwnerLabel = '';
      this.useNameCardAccountOwnerLabel = '';
      this.haveQueue = false;
      this.ownerLabel = '';
      this.accountOwnerLabel = '';
      this.useNameCardOwner = false;
      this.useNameCardAccountOwner = false;
      this.campaignStatusPlick = new InputPlickListValue();
      this.queueLabel = System.Label.SB_NCLD_Label_Queue;
      this.userLabel = User.getSObjectType().getDescribe().getLabel();
      this.labelMap = new Map<String, String>();
      this.accountLabel = Account.sObjectType.getDescribe().getLabel();
      this.contactLabel = Contact.sObjectType.getDescribe().getLabel();
      this.leadLabel = Lead.sObjectType.getDescribe().getLabel();
      this.accountAuthority = new Authority(Account.sObjectType);
      this.contactAuthority = new Authority(Contact.sObjectType);
      this.leadAuthority = new Authority(Lead.sObjectType);
      this.campaignAuthority = new Authority(Campaign.sObjectType);
      this.showRecordType = true;
      this.nameCardCampaignisAccessible = SmartViscaf__NameCard__c.campaign__c.getDescribe().isAccessible();
      this.campaignStatusisAccessible = CampaignMember.Status.getDescribe().isAccessible();
      this.newSectionLabel = '';
      this.overWriteLabel = '';
      this.showOverWrite = true;
    }
  }

  public class Authority {
    @AuraEnabled public Boolean isCreateable;
    @AuraEnabled public Boolean isUpdateable;
    @AuraEnabled public Boolean isDeletable;
    @AuraEnabled public Boolean isSearchable;
    @AuraEnabled public Boolean isAccessible;

    public Authority(sObjectType sObj) {
      Schema.DescribeSObjectResult ds = sObj.getDescribe();
      isCreateable = ds.isCreateable();
      isUpdateable = ds.isUndeletable();
      isDeletable = ds.isDeletable();
      isSearchable = ds.isSearchable();
      isAccessible = ds.isAccessible();
    }

  }

  /**
    * @description 上書き用クラス
  **/
  public class InputRegistOverWritValue {
    @AuraEnabled public LabelValueCheck overWriteCheck {get; set;} // 上書きチェック
    @AuraEnabled public Boolean show {get; set;} // 表示フラグ
    @AuraEnabled public Boolean canShow {get; set;} // 表示フラグ
    @AuraEnabled public String overId {get; set;} // 非表示フラグ

    /**
      * @description InputRegistOverWritValueクラスのコンストラクタ
    **/
    public InputRegistOverWritValue() {
      this.overWriteCheck = new LabelValueCheck();
      this.show = false;
      this.overId = '';
      this.canShow = true;
    }
  }

  /**
    * @description 選択リスト用クラス
  **/
  public class InputPlickListValue {
    @AuraEnabled public String plickListTitle {get; set;} // レコードタイプタイトル（オブジェクト表示ラベル）
    @AuraEnabled public String selectValue {get; set;} // 選択したレコードタイプ
    @AuraEnabled public String plickListId {get; set;} // 選択したレコードタイプ
    @AuraEnabled public List<LabelValue> plickListOptions {get; set;} // 新規作成の場合、レコードタイプの選択リスト
    @AuraEnabled public Boolean show {get; set;} // 新規作成の場合、レコードタイプの選択リスト
    @AuraEnabled public Boolean canShow {get; set;} // 新規作成の場合、レコードタイプの選択リスト
    @AuraEnabled public Map<String, String> plickListValueMap {get; set;} // 新規作成の場合、レコードタイプの選択リスト

    public InputPlickListValue() {
      this.plickListTitle = '';
      this.selectValue = '';
      this.plickListId = '';
      this.plickListOptions = new List<LabelValue>();
      this.plickListValueMap = new Map<String, String>();
      this.show = true;
      this.canShow = true;
    }
  }

  /**
    * @description Label,Value クラス
  **/
  public class LabelValue {
    @AuraEnabled public String label {get; set;}
    @AuraEnabled public String value {get; set;}
    public LabelValue() {
      this.label = '';
      this.value = '';
    }

    /**
      * @description LabelValueBeanコンストラクタ
    **/
    public LabelValue(String labelValue, String valueValue) {
      this.label = labelValue;
      this.value = valueValue;
    }
  }

  /**
   * @description 検索条件クラス
  **/
  public class SearchCondition {
    @AuraEnabled public String label {get; set;}
    @AuraEnabled public String value {get; set;}
    @AuraEnabled public String iconName {get; set;}
    @AuraEnabled public String iconSize {get; set;}
    @AuraEnabled public Boolean disabled {get; set;}
    @AuraEnabled public String groupName {get; set;}
    @AuraEnabled public String className {get; set;}

    public SearchCondition() {
      this.label = '';
      this.value = '';
      this.iconName = '';
      this.iconSize = '';
      this.disabled = false;
      this.groupName = '';
      this.className = '';
    }

    public SearchCondition(String labelValue, String valueValue, String iconNameValue, String iconSizeValue) {
      this.label = labelValue;
      this.value = valueValue;
      this.iconName = iconNameValue;
      this.iconSize = iconSizeValue;
    }
  }

  /**
   * @description 検索条件レコードタイプクラス
  **/
  public class SearchConditionRecordType {
    @AuraEnabled public String title {get; set;}
    @AuraEnabled public String description {get; set;}
    @AuraEnabled public List<SearchConditionRecordTypeOptionGroup> searchConditionRecordTypeOptionGroups {get; set;}


    public SearchConditionRecordType() {
      this.title = '';
      this.description = '';
      this.searchConditionRecordTypeOptionGroups = new List<SearchConditionRecordTypeOptionGroup>();
    }
  }

  /**
   * @description 検索条件レコードタイプグルプクラス
  **/
  public class SearchConditionRecordTypeOptionGroup {
    @AuraEnabled public String title {get; set;}
    @AuraEnabled public String titleId {get; set;}
    @AuraEnabled public Boolean show {get; set;}
    @AuraEnabled public List<LabelValueCheck> searchConditionplickListOptions {get; set;}

    public SearchConditionRecordTypeOptionGroup() {
      this.title = '';
      this.titleId = '';
      this.show = true;
      this.searchConditionplickListOptions = new List<LabelValueCheck>();
    }
  }

  /**
   * @description 検索条件レコードタイプOptionクラス
  **/
  public class LabelValueCheck {
    @AuraEnabled public String label {get; set;}
    @AuraEnabled public String value {get; set;}
    @AuraEnabled public Boolean checked {get; set;}
    @AuraEnabled public Boolean disabled {get; set;}
    @AuraEnabled public Boolean hidden {get; set;}

    public LabelValueCheck() {
      this.label = '';
      this.value = '';
      this.checked = true;
      this.disabled = false;
      this.hidden = false;
    }
  }


  /**
   * @description 検索条件レコードタイプOptionクラス
  **/
  public class SaveResult {
    @AuraEnabled public Boolean success {get; set;}
    @AuraEnabled public String errorMessage {get; set;}
    @AuraEnabled public String message {get; set;}
    @AuraEnabled public String testClassMessage {get; set;}
    @AuraEnabled public Boolean dataError {get; set;}
    @AuraEnabled public Object data {get; set;}
    @AuraEnabled public Map<String, String> otherMessage {get; set;}

    public SaveResult() {
      this.success = true;
      this.errorMessage = '';
      this.message = '';
      // this.data = new Object();
      this.dataError = false;
      this.otherMessage = new Map<String, String>();
      this.testClassMessage = '';

    }
  }
}