/**
 *
 *  SB_NameCard_RenkeiMapper
 *  名刺連携項目マッピング NameCardRenkeiMapping__c の対象のオブジェクト用の該当のレコードレコードタイプのレコードを読んで
 *  名刺から 取引先、取引先責任者、リード等を作るときの項目のマッピング情報を取得して、マッピング情報をもとに項目ごとの変換者を生成し保持する。
 *
 *
 *  Copyright (C) 2016 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2016.xx.xx
 *  @Version 2      2017.03.xx  マッピングレコードは 利用中の名刺基本設定を参照してるものを使う。住所関連のマッピングのバリエーションを追加
 *  @Version 3      2017.12.xx    V1.22  Lead Extention で使うためGlobalへ
 *                  2018.03.xx    V1.22  SV_DEV-809 名刺の選択リスト（カスタム項目）のマッピングが選択リストに設定した値のAPI名でマッピングされる。
 *  @Version 4      v2.0.3      2018.09.xx  自動連携のとき用で OWNERID 以外で更新してはいけない 項目リスト RENKEI_DONOT_UPDATE_FIELDS に Lead 用追加
 *  @Version 5      2019.07.xx v2.4 複数名刺項目から 連携先項目合成対応 SV_DEV-395 医療法人のデータ納品について
 *
 **/
global with sharing class SB_NameCard_RenkeiMapper {
  global class SB_NameCard_RenkeiMapperException extends Exception {}

  private static Map<String, SB_NameCard_RenkeiMapper> obj2Instance;
  private static Map<String, Id> objName2RectypeId;
  private static Map<String, Schema.SObjectField> namecardFields;     //  名刺の項目情報
  // マッピング対象のオブジェクトたち
  public static Set<String> getTargetObjects() {  // v1.21 追加
    return objName2RectypeId.keySet();
  }

  static {
    if (obj2Instance == null) {
      obj2Instance = new Map<String, SB_NameCard_RenkeiMapper>();
    }
    if (objName2RectypeId == null) {
      objName2RectypeId = new Map<String, Id>();
      List<Schema.RecordTypeInfo> rectypeInfos = NameCardRenkeiMapping__c.getSObjectType().getDescribe().getRecordTypeInfos();
      for (Schema.RecordTypeInfo rectypeInfo : rectypeInfos) {
        //if (rectypeInfo.isAvailable()) {    // 現在のユーザのアクセス権にかかわらず、存在するレコードタイプについて保持する。
        if (rectypeInfo.isMaster()) {   // v1.21 追加
          continue;
        }
        objName2RectypeId.put(rectypeInfo.getName(), rectypeInfo.getRecordTypeId());
        //}
      }
    }
    //  名刺の項目情報
    namecardFields = NameCard__c.getSObjectType().getDescribe().fields.getMap();
  }

  //////////////
  // 名刺の住所から アカウント用の住所を作るクラス 住所のパーツの組み合わせのパターンごとにクラス
  //////////////
  @TestVisible
  private abstract class AddressBuilder {
    public abstract String create(NameCard__c card, Map<String, String> srcMap);
  }

  // 市区郡
  @TestVisible
  private class CityBuilder extends AddressBuilder {
    public override String create(NameCard__c card, Map<String, String> srcMap) {
      return srcMap.get('city');
    }
  }

  // 町名・番地＋建物名
  @TestVisible
  private class StreetBuilder extends AddressBuilder {
    public override String create(NameCard__c card, Map<String, String> srcMap) {
      return srcMap.get('street');
    }
  }

  //'street_nobld' 町名・番地  建物名なし  2017.03.xx
  @TestVisible
  private class StreetNoBldBuilder extends AddressBuilder {
    public override String create(NameCard__c card, Map<String, String> srcMap) {
      return srcMap.get('street_nobld');
    }
  }

  private static final String THREE_FORM = '{0}{1}{2}';
  private static final String TWO_FORM = '{0}{1}';

  //'pref_address_bld'  都道府県 + 住所 + 建物名  2017.03.xx
  @TestVisible
  private class PrefAddressBldBuilder extends AddressBuilder {
    public override String create(NameCard__c card, Map<String, String> srcMap) {
      String pref = String.isNotBlank(card.address_pref__c) ? card.address_pref__c : '';
      String address = String.isNotBlank(card.address__c) ? card.address__c : '';
      String bld = String.isNotBlank(card.address_bld__c) ? card.address_bld__c : '';
      return String.format(THREE_FORM, new String[] {pref, address, bld});
    }
  }

  //'address_bld' => new Set<String> {'address__c', 'address_eng__c', 'address_bld__c'},    // 住所 + 建物名  2017.03.xx
  @TestVisible
  private class AddressBldBuilder extends AddressBuilder {
    public override String create(NameCard__c card, Map<String, String> srcMap) {
      String address = String.isNotBlank(card.address__c) ? card.address__c : '';
      String bld = String.isNotBlank(card.address_bld__c) ? card.address_bld__c : '';
      return String.format(TWO_FORM, new String[] {address, bld});
    }
  }

  // 住所のパターンを作るクラスのインスタンスを保持するマップ
  private static Map<String, AddressBuilder> addressBuilders = new Map<String, AddressBuilder>();

  // 住所のパターンを作るクラスをインスタンス化を得るメソッド
  private static AddressBuilder getAddressBuilder(String key) {
    if (addressBuilders.containsKey(key)) {
      return addressBuilders.get(key);
    }
    AddressBuilder builder = null;
    if (key == 'city') {
      builder = new CityBuilder();
    }
    else if (key == 'street') {
      builder = new StreetBuilder();
    }
    else if (key == 'street_nobld') {
      builder = new StreetNoBldBuilder();
    }
    else if (key == 'pref_address_bld') {
      builder = new PrefAddressBldBuilder();
    }
    else if (key == 'address_bld') {
      builder = new AddressBldBuilder();
    }
    System.assert(builder != null);
    addressBuilders.put(key, builder);
    return builder;
  }

  //////////////
  // 対象の値の作成クラスの基底
  //////////////
  public virtual class FieldBuilder {
    private String srcField;    // 目的の項目API名
    private Schema.DescribeFieldResult destFR;      // 目的のSchema.DescribeFieldResult
    private Boolean dontUpdate;     // 更新時、上書きしない項目 OwnerID とか
    public Boolean isDontUpdate() { return dontUpdate; }

    public FieldBuilder(String srcField, Schema.DescribeFieldResult destFR) {
      this.srcField = srcField;
      this.destFR = destFR;
      this.dontUpdate = this.destFR.getName().equalsIgnoreCase('ownerid');
    }
    public virtual Object create(SObject srcObj, SObject destObj) {
      //System.debug('srcField: ' + srcField);
      //System.debug('destField: ' + destFR.getName());
      Object src = getValue(srcObj, srcField);
      if (src != null && !destFR.isAutoNumber() && !destFR.isCalculated()) {
        // NULL でないか Name 項目でないとき、値を複写して項目を作る。
        if (src instanceof String) {
          Integer len = destFR.getLength();
          destObj.put(destFR.getName(), ((String)src).left(len));
        }
        else {
          destObj.put(destFR.getName(), src);
        }
      }
      return src;
    }

    //'last_name' => new Set<String> {'person_name_last__c', 'last_name__c'},
    //'first_name' => new Set<String> {'person_name_first__c', 'first_name__c'},
    public virtual Object create(Map<String, String> srcMap, SObject destObj) {
      String src = srcMap.get(srcField);
      if (String.isNotBlank(src)) {
        destObj.put(destFR.getName(), src);
      }
      return src;
    }
    //'city' => new Set<String> {'address__c', 'address_eng__c'},   // 市区郡
    //'street' => new Set<String> {'address__c', 'address_eng__c', 'address_bld__c'},     // 町名・番地 建物名つき
    //'pref_address_bld' => new Set<String> {'address_pref__c', 'address__c', 'address_eng__c', 'address_bld__c'},   // 都道府県 + 住所 + 建物名  2017.03.xx
    //'address_bld' => new Set<String> {'address__c', 'address_eng__c', 'address_bld__c'},    // 住所 + 建物名  2017.03.xx
    //'street_nobld' => new Set<String> {'address__c', 'address_eng__c'}          // 町名・番地  建物名なし  2017.03.xx
    public virtual Object create(SObject srcObj, Map<String, String> srcMap, SObject destObj) {
      //String src = srcMap.get(srcField);
      AddressBuilder builder = getAddressBuilder(srcField);
      String src = builder.create((NameCard__c)srcObj, srcMap);
      if (String.isNotBlank(src)) {
        destObj.put(destFR.getName(), src);
      }
      return src;
    }
    // 自動連携 で 更新のときは上書きしない項目はこれで オフにする
    public void setDontUpdate(Boolean b) {
      this.dontUpdate = b;
    }
  } // public virtual class FieldBuilder

  // 選択リスト型の 項目作成
  // 2018.03.xx v1.22
  // SV_DEV-809 名刺の選択リスト（カスタム項目）のマッピングが選択リストに設定した値のAPI名でマッピングされる。
  public class FieldBuilderFromPickList extends FieldBuilder {
    private List<Schema.PicklistEntry> pes;
    public FieldBuilderFromPickList(String srcField, Schema.DescribeFieldResult destFR, List<Schema.PicklistEntry> pes) {
      super(srcField, destFR);
      this.pes = pes;
    }

    public override Object create(SObject srcObj, SObject destObj) {
      String src = (String)getValue(srcObj, srcField);
      if (String.isNotBlank(src)) {
        for (Schema.PicklistEntry pe : this.pes) {
          System.debug(pe.getLabel() + ' = ' + pe.getValue() );
          if (pe.getValue().equalsIgnoreCase(src)) {
            destObj.put(destFR.getName(), pe.getLabel());
            return pe.getValue();
          }
        }
      }
      return null;
    }
  }  // public class FieldBuilderFromPickList extends FieldBuilder {

  // 2019.07.xx v2.4 複数名刺項目から 連携先項目合成対応 SV_DEV-395 医療法人のデータ納品について
  public class MultiSourceFieldBuilder extends FieldBuilder {
    private List<String> srcFields; 
    public MultiSourceFieldBuilder(List<String> srcFields, Schema.DescribeFieldResult destFR) {
      super(null, destFR);
      this.srcFields = new List<String> (srcFields);
    }
    public override Object create(SObject srcObj, SObject destObj) {
      List<String> srcValues = new List<String>();
      for (String srcField : srcFields) {
        Object srcVal = getValue(srcObj, srcField);
        if (srcVal != null) {
          srcValues.add((String)srcVal);
        }
      }
      String value = String.join(srcValues, ' ');  // 半角スペースで連携
      destObj.put(destFR.getName(), value);
      return value;
    }

  } // public class MultiSourceFieldBuilder extends FieldBuilder {


  // リレーションクエリした結果のSObject から 参照先の値を取得する。
  private static Object getValue(SObject srcObj, String field) {
    String[] ff = field.split('\\.');
    if (ff.size() > 1) {
      Sobject obj = srcObj;
      for(Integer n =0; n < ff.size()-1; n++) {
        obj = obj.getSObject(ff[n]);
        if (obj == null) {
          return null;
        }
      }
      return obj.get(ff[ff.size()-1]);
    }
    return srcObj.get(field);
  }

  // 宛先オブジェクトの API名
  private String destObjectName;
  // 宛先オブジェクトの SObjectType
  private SObjectType destSObjectType;
  // 名刺項目と宛先オブジェクトの項目への変換クラスのマッピング
  private Map<String, List<FieldBuilder>> sourceField2Creaters;
  // 対象のオブジェクトの項目情報
  private Map<String, Schema.SObjectField > destFields;
  // Name 項目にする 名刺項目
  private Set<String> nameSources;
  // 名刺基本設定
  private NameCardBasicSetting__c setting;    // 2017.03.xx
  // 2019.07.xx v2.4 複数名刺項目から 連携先項目合成対応 SV_DEV-395 医療法人のデータ納品について
  private Map<String, List<String>> dest2Sources; 
  // 2019.07.xx v2.4 マッピング不要になる項目s ↑の関係
  private Set<String> ignoreFields;

  // マッピング定義に応じた 対象の値の作成クラスを作成
  // ToDO 今 FieldBuilder しかないけど、この派生クラスができるはずなので、それらもここで振り分けてインスタンス化する。
  private FieldBuilder createFieldBuilder(NameCardRenkeiMapping__c mapping) {
    System.debug(mapping.NameCardName__c + ' => ' + mapping.TargetName__c);
    if (namecardFields.get(mapping.NameCardName__c) == null &&
        !ADDRESS_FIELDS.contains(mapping.NameCardName__c) &&
        !NAME_FIELDS.contains(mapping.NameCardName__c)) {
      throw new SB_NameCard_RenkeiMapperException(String.format(Label.SB_NC_MAPPING_InalidField, new String[] { mapping.NameCardName__c }));
    }
    //String dest = mapping.TargetName__c.endsWithIgnoreCase('__c') ? ns + mapping.TargetName__c : mapping.TargetName__c;
    //Schema.SObjectField sf = this.destFields.get(dest.toLowerCase());
    Schema.SObjectField sf = this.destFields.get(mapping.TargetName__c.toLowerCase());
    if (sf == null) {
      throw new SB_NameCard_RenkeiMapperException(String.format(Label.SB_NC_MAPPING_InalidField, new String[] { mapping.TargetName__c }));
    }
    DescribeFieldResult dfr = sf.getDescribe();
    Schema.DescribeFieldResult dfrNc = null;
    if (namecardFields.containsKey(mapping.NameCardName__c)) {
      dfrNc = namecardFields.get(mapping.NameCardName__c).getDescribe();
    }
    if (dfrNc!= null && dfrNc.getType() == Schema.DisplayType.Picklist) {
      // 2018.03.xx v1.22
      // 選択リスト型のとき
      return new FieldBuilderFromPickList(mapping.NameCardName__c, dfr, dfrNc.getPicklistValues());
    }
    else if (this.dest2Sources.containsKey(dfr.getName().toLowerCase())) {
      // 2019.07.xx v2.4 複数名刺項目から 連携先項目合成対応 SV_DEV-395 医療法人のデータ納品について
      return new MultiSourceFieldBuilder(this.dest2Sources.get(dfr.getName().toLowerCase()), dfr);
    }
    else {
      return new FieldBuilder(mapping.NameCardName__c, dfr);
    }
  }

  private SB_NameCard_RenkeiMapper(String obj_name) {
    this.destObjectName = obj_name;
    this.destSObjectType = Schema.getGlobalDescribe().get(obj_name);
    // 名刺項目と宛先オブジェクトの項目への変換クラスのマッピング
    this.sourceField2Creaters = new Map<String, List<FieldBuilder>>();
    // 対象のオブジェクトの項目情報
    this.destFields = this.destSObjectType.getDescribe().fields.getMap();
    // Name 項目にする 名刺項目
    this.nameSources = new Set<String>();
    // 名刺基本設定
    this.setting = SB_NameCard_BasicSetting.getNameCardBasicSetting();
    // 2019.07.xx v2.4 複数名刺項目から 連携先項目合成対応 SV_DEV-395 医療法人のデータ納品について
    this.dest2Sources = new Map<String, List<String>>();
    // 2019.07.xx v2.4 マッピング不要になる項目s ↑の関係
    this.ignoreFields = new Set<String>();
  }

  // 2019.07.xx v2.4 複数名刺項目から 連携先項目合成対応 SV_DEV-395 医療法人のデータ納品について
  private void prepareMultiSource(Map<String, List<String>> dest2Sources) {
    for (String dest : dest2Sources.keySet()) {
      // 追加しなかないので、
      this.dest2Sources.put(dest.toLowerCase(), new List<String>(dest2Sources.get(dest)));
    } 
  }
  // 2019.07.xx v2.4 マッピング不要になる項目s
  private void prepareIgnoreFields(Set<String> ignoreFields) {
    this.ignoreFields.addAll(ignoreFields);
  }
  // 連携先レコードの項目を作るクラスのインスタンス FieldBuilder を作る。
  // jidoRenkei  TRUE なら、更新のときに特定の項目は上書きしないようにする。
  private void setup(Boolean jidoRenkei) {
    // 対象の名刺連携項目マッピング のレコードタイプ
    Id recTypeId = objName2RectypeId.get(this.destObjectName);
    Id settingId = this.setting.Id;     // 基本設定 の レコードID  2017.03.xx
    // 基本設定に対応したマッピング
    List<NameCardRenkeiMapping__c> mappinngs = [SELECT Id, Name, NameCardName__c, TargetName__c FROM NameCardRenkeiMapping__c
                          WHERE BasicSetting__c = :settingId AND RecordTypeId = :recTypeId AND IsActive__c = true];
    for (NameCardRenkeiMapping__c mapping : mappinngs) {
      // Name 用の項目か？
      checkNameSource(mapping);
      // 項目ごとの作る用クラスをインスタンス化
      List<FieldBuilder> builders = null;
      if (this.sourceField2Creaters.containsKey(mapping.NameCardName__c)) {
        builders = this.sourceField2Creaters.get(mapping.NameCardName__c);
      }
      else {
        builders = new List<FieldBuilder>();
        this.sourceField2Creaters.put(mapping.NameCardName__c, builders);
      }
      try {
        if (this.ignoreFields.contains(mapping.TargetName__c.toLowerCase())) {
          // 2019.07.xx v2.4 マッピング不要になる項目s ?
          continue;
        }
        FieldBuilder builder = createFieldBuilder(mapping);
        if (jidoRenkei && RENKEI_DONOT_UPDATE_FIELDS.get(destSObjectType).contains(mapping.TargetName__c.toLowerCase())) {
          // 自動連携で更新時ｍうわがきしては いけない 項目
          builder.setDontUpdate(true);
        }
        builders.add(builder);
      }
      catch(Exception e) {
        //  項目が削除されてた場合とか スルーする
        System.debug(e.getMessage());
        // またスローする。SV_DEV-850 ベータ58にてマッピングにマッピングされている名刺カスタム項目削除すると、名刺に登録する際にエラー発生
        throw new SB_NameCard_RenkeiMapperException(e.getMessage());
      }
    }
  }

  // 新規作成に備え、Name項目にする 名刺項目を保持する。
  private void checkNameSource(NameCardRenkeiMapping__c mapping) {
    if (TARGET_NAMES.contains(mapping.TargetName__c.toLowerCase())) {
      if (COMPLEX_FIELDS.containsKey(mapping.NameCardName__c.toLowerCase())) {
        this.nameSources.addAll(COMPLEX_FIELDS.get(mapping.NameCardName__c.toLowerCase()));
      }
      else {
        this.nameSources.add(mapping.NameCardName__c);
      }
    }
  }

  // 対象のオブジェクトのName項目になる値を持った名刺か？  新規作成のとき、createRecord の前とかで チェックする
  public Boolean haveNameSource(NameCard__c card) {
    Boolean result = false;
    for (String f : this.nameSources) {
      // どれか1項目でもあればいい
      if (card.get(f) != null) {
        result = true;
        break;
      }
    }
    return result;
  }

  // Name 項目 のAPI名  Name だけではないかた
  private static final Set<String> TARGET_NAMES = new Set<String> {
    'name', 'firstname', 'lastname'
  };
  // 姓 名 は特別な項目
  private static final Set<String> NAME_FIELDS = new Set<String> {'last_name', 'first_name'};
  // 住所は特別な項目
  private static final Set<String> ADDRESS_FIELDS = new Set<String> {'city', 'street', 'pref_address_bld', 'address_bld', 'street_nobld'};
  // マッピングの値として保持する名称に対して、対応する名刺の項目API名
  global static final Map<String, Set<String>> COMPLEX_FIELDS = new Map<String, Set<String>> {
    'last_name' => new Set<String> {'person_name_last__c', 'last_name__c'},
    'first_name' => new Set<String> {'person_name_first__c', 'first_name__c'},
    'city' => new Set<String> {'address__c', 'address_eng__c'},   // 市区郡
    'street' => new Set<String> {'address__c', 'address_eng__c', 'address_bld__c'},     // 町名・番地 建物名つき
    'pref_address_bld' => new Set<String> {'address_pref__c', 'address__c', 'address_eng__c', 'address_bld__c'},   // 都道府県 + 住所 + 建物名  2017.03.xx
    'address_bld' => new Set<String> {'address__c', 'address_eng__c', 'address_bld__c'},    // 住所 + 建物名  2017.03.xx
    'street_nobld' => new Set<String> {'address__c', 'address_eng__c'}          // 町名・番地  建物名なし  2017.03.xx
  };


  // 自動連携のとき用で OWNERID 以外で更新してはいけない 項目
  private static final Map<SObjectType, Set<String>> RENKEI_DONOT_UPDATE_FIELDS = new Map<SObjectType, Set<String>> {
    Account.SObjectType => new Set<String> { 'name'},
    Contact.SObjectType => new Set<String> { 'lastname'},
    Lead.SObjectType => new Set<String>() // v2.0.3 2018.09.xx
  };

  // 名刺レコードから、対象のオブジェクトのレコードへ値をセットする人
  private void setupRecord(NameCard__c card, SObject target) {
    Map<String, String> address = SB_NameCard_Util.getAddress(card);
    Map<String, String> names = SB_NameCard_Util.getPersonName(card);
    for (String srcField : this.sourceField2Creaters.keySet()) {
      List<FieldBuilder> builders = this.sourceField2Creaters.get(srcField);
      for (FieldBuilder builder : builders) {
        if (ADDRESS_FIELDS.contains(srcField.toLowerCase())) {
          builder.create(card, address, target);
        }
        else if (NAME_FIELDS.contains(srcField.toLowerCase())) {
          builder.create(names, target);
        }
        else if (builder.isDontUpdate() && target.Id != null) {
          continue;       //  更新時は上書きしない項目（OwnerId）の場合、スキップ
        }
        else {
          builder.create(card, target);
        }
      }
    }
  }

  global SObject createRecord(NameCard__c card, Id recorTypeId) {
    SObject result = this.destSObjectType.newSObject(recorTypeId, false);   //
    if (recorTypeId != null) {
      result.put('RecordTypeId', recorTypeId);      // newSObject で false だと 指定したレコードタイプが無効になるので。 2016.10.11
    }
    setupRecord(card, result);
    return result;
  }

  global SObject updateRecord(NameCard__c card, Id destId) {
    SObject result = this.destSObjectType.newSObject(destId);   //
    setupRecord(card, result);
    return result;
  }

  // 対象のオブジェクトのAPIを私で このクラスのインスタンスを貰う
  global static SB_NameCard_RenkeiMapper getInstance(String obj_name, Boolean jidoRenkei) {
    if (objName2RectypeId.containsKey(obj_name) == false) {
      throw new SB_NameCard_RenkeiMapperException('Invalid Object : ' + obj_name);
    }
    SB_NameCard_RenkeiMapper instance = null;
    if (obj2Instance.containsKey(obj_name)) {
      instance = obj2Instance.get(obj_name);
    }
    else {
      instance = new SB_NameCard_RenkeiMapper(obj_name);
      instance.setup(jidoRenkei);
      obj2Instance.put(obj_name, instance);
    }
    return instance;
  }

  // 2019.07.xx v2.4 対象のオブジェクトのAPIを私で このクラスのインスタンスを貰う 複数名刺項目から 連携先項目合成対応
  global static SB_NameCard_RenkeiMapper getInstance(String obj_name, Boolean jidoRenkei, 
                                                    Map<String, List<String>> dest2Sources, Set<String> ignoreFields) {
    if (objName2RectypeId.containsKey(obj_name) == false) {
      throw new SB_NameCard_RenkeiMapperException('Invalid Object : ' + obj_name);
    }
    SB_NameCard_RenkeiMapper instance = null;
    if (obj2Instance.containsKey(obj_name)) {
      instance = obj2Instance.get(obj_name);
    }
    else {
      instance = new SB_NameCard_RenkeiMapper(obj_name);  
      if (dest2Sources != null && !dest2Sources.isEmpty()) {
        instance.prepareMultiSource(dest2Sources);
      }
      // 2019.07.xx v2.4 マッピング不要になる項目s
      if (ignoreFields != null && !ignoreFields.isEmpty()) {
        instance.prepareIgnoreFields(ignoreFields);
      }
      instance.setup(jidoRenkei);
      obj2Instance.put(obj_name, instance);
    }
    return instance;
  }

  //
  // マッピングに必要な 名刺の項目を取得する
  global Set<String> getNameCardQueryFields() {
    Set<String> results = new Set<String>(this.sourceField2Creaters.keySet());
    String ns = SB_NameCard_Util.getNamespacePrefix_x();
    // 会社名
    results.add(ns + 'company_name__c');
    // 住所用の項目
    results.add(ns + 'address_pref__c');   // 2017.03.xx
    results.add(ns + 'address__c');
    results.add(ns + 'address_eng__c');
    results.add(ns + 'address_bld__c');
    // 姓名用の項目
    results.add(ns + 'person_name_last__c');
    results.add(ns + 'person_name_first__c');
    results.add(ns + 'last_name__c');
    results.add(ns + 'first_name__c');
    //removeAddressLabel(results);
    results.removeAll(ADDRESS_FIELDS);
    results.removeAll(NAME_FIELDS);
    return results;
  }


}