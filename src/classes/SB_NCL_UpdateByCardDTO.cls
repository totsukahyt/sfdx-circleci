/**
 *
 * SB_NameCard_UpdateByCardBean 名刺で更新コンポネート使用するためのBeanクラス
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author gao
 *  @Version 1.12      2018.5.xx SV_DEV-910 [LEX]リードの名刺で更新のLightning版対応
 *
 **/

public with sharing class SB_NCL_UpdateByCardDTO {
  @AuraEnabled public TitleValue titleV {get; set;} // タイトル表示内容
  @AuraEnabled public InputValue inputV {get; set;} // 入力内容
  @AuraEnabled public List<Sobject> dataList {get; set;} // 画面表示レコード
  @AuraEnabled public List<DataTableColumnField> fieldList {get; set;} // 画面表示項目

  public SB_NCL_UpdateByCardDTO() {
    this.titleV = new TitleValue();
    this.inputV = new InputValue();
    this.dataList = new List<SObject>();
    this.fieldList = new List<DataTableColumnField>();
  }

  /**
    * @description Titleを表示する為のClass
  **/
  public class TitleValue {
    @AuraEnabled public String titleName {get; set;} // タイトル表示内容
    @AuraEnabled public String iconName {get; set;} // アイコン名
    @AuraEnabled public String iconSize {get; set;} // アイコンサイズ
    @AuraEnabled public String linkName {get; set;} // タイトルリンク表示ラベル
    @AuraEnabled public String linkTo {get; set;} // タイトルリンクの遷移先
    @AuraEnabled public String closeValue {get; set;} // タイトルリンクの遷移先

    public TitleValue() {
      this.titleName = '';
      this.iconName = '';
      this.iconSize = '';
      this.linkName = '';
      this.linkTo = '';
      this.closeValue = '';
    }
  }

  /**
    * @description 入力用Class
  **/
  public Class InputValue {
    @AuraEnabled public String radioValue {get; set;} // 選択したラジオボタンラジオ値を保存されます
    @AuraEnabled public String radioTitle {get; set;} // ラジオボタン表示タイトル  例(検索条件)
    @AuraEnabled public String checkboxLabel {get; set;} // checkbox表示ラベル  例(既存取引先を上書きする)
    @AuraEnabled public Boolean checkboxValue {get; set;} // チェックボックスの値をここで保存されっます
    @AuraEnabled public List<LabelValue> searchTypeSelectOpts {get; set;} // ラジオボタンの選択肢 Max3

    public InputValue() {
      this.radioValue = '';
      this.radioTitle = '';
      this.checkboxLabel = '';
      this.checkboxValue = false;
      this.searchTypeSelectOpts = new List<LabelValue>();
    }
  }

  /**
    * @description 現在はラジオボタン選択肢しか使わないlabelとvalueのBean
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
    * @description LightningDataTableタイトルとタイプ使用するBeanクラス
  **/
  public class DataTableColumnField {
    @AuraEnabled public String label {get; set;}
    @AuraEnabled public String fieldName {get; set;}
    @AuraEnabled public String type {get; set;}
    @AuraEnabled public Object typeAttributes {get; set;}

    /**
     * @description DataTableColumnFieldBeanコンストラクタメソッド
     * @param labelValue タイトル表示ラベル
     * @param fieldNameValue タイトル表示ラベル
     * @param typeValue 表示タイプ名
    **/
    public DataTableColumnField(String labelValue, String fieldNameValue, String typeValue) {
      this.label = labelValue;
      this.fieldName = fieldNameValue;
      this.type = typeValue;
    }

    /**
     * @description rowActionsセットするメソッド
     * @param rowActions タイトル表示ラベル
    **/
    public void setActon(List<Action> rowActionsValue) {
      this.typeAttributes = new Map<String, List<Action>>{'rowActions' => rowActionsValue};
    }

    /**
     * @description URLタイプの場合表示する項目を設定
     * @param urlLabelFieldAPIValue URLタイプの場合表示する項目名
    **/
    public void setURLLabel(String urlLabelFieldAPIValue) {
      this.typeAttributes = new Map<String, Map<String, String>>{'label' => new Map<String, String>{'fieldName' => urlLabelFieldAPIValue}};
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
    * @description LightningDataTableAction使用するBeanクラス
  **/
  public class Action {
    @AuraEnabled public String label {get; set;}
    @AuraEnabled public String name {get; set;}

    /**
      * @description ActionBeanコンストラクタメソッド
    **/
    public Action() {
      this.label = '';
      this.name = '';
    }

    /**
      * @description ActionBeanコンストラクタメソッド
      * @param labelValue action表示するラベル
      * @param nameValue action名
    **/
    public Action(String labelValue, String nameValue) {
      this.label = labelValue;
      this.name = nameValue;
    }
  }

  /**
    * @description LightningDataTableButton使用するBeanクラス
  **/
  public class Button {
    @AuraEnabled public String label {get; set;}
    @AuraEnabled public Object value {get; set;}
    @AuraEnabled public String title {get; set;}
    @AuraEnabled public String name {get; set;}
    @AuraEnabled public String iconName {get; set;}
    @AuraEnabled public String iconPosition {get; set;}
    @AuraEnabled public String variant {get; set;}
    @AuraEnabled public Boolean disabled {get; set;}

    /**
      * @description Buttonコンストラクタメソッド
    **/
    public Button() {
      this.label = '';
      this.value = '';
      this.title = '';
      this.name = '';
      this.iconName = '';
      this.iconPosition = '';
      this.variant = '';
      this.disabled = false;
    }

    /**
      * @description Buttonコンストラクタメソッド
      * @param labelValue Button表示するラベル
      * @param valueValue Button表示名
      * @param titleValue Buttonタイトル名
      * @param nameValue Button名
      * @param iconNameValue Buttonアイコン名
      * @param disabledValue disabledフラグ
    **/
    public Button(String labelValue, Object valueValue, String titleValue,
                  String nameValue, String iconNameValue, String iconPositionValue, String variantValue, Boolean disabledValue) {
      this.label = labelValue;
      this.value = valueValue;
      this.title = titleValue;
      this.name = nameValue;
      this.iconName = iconNameValue;
      this.iconPosition = iconPositionValue;
      this.variant = variantValue;
      this.disabled = disabledValue;
    }
  }
}