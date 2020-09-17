/**
 * @File Name          : SB_Connect_Utils.cls
 * @Description        :
 * @Author             : 西根哲史
 * @Group              :
 * @Last Modified By   : 西根哲史
 * @Last Modified On   : 2020/2/25 11:52:06
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    2020/1/28   西根哲史     Initial Version
 * 2.0    2020/5/13   sawano      2.5.1 SOQLの使用回数を消費されてるとこまるので、使う人に明示的に先に読んでもらうようにします。
**/
public with sharing class SB_Connect_Utils {

  /** デフォルトの国番号取得用 */
  private static final String DEFAULT_COUNTRY_NAME = 'default';
  public static final String DEFAULT_COUNTRY_CODE = '81';
  /** 国際電話番号データマップ */
  private Map<String, String> name2Code { get; private set; }
  private String defaultCode;


  public SB_Connect_Utils() {
    this.name2Code = new Map<String, String>();
    Integer limits = Limits.getLimitQueryRows() - Limits.getQueryRows();
    System.debug('Limits.getLimitQueryRows(): ' + limits);
    List<InternationalCallingCodes__mdt> codes = [SELECT CountryCode__c, CountryName__c FROM InternationalCallingCodes__mdt WHERE CountryCode__c!=null AND CountryName__c!=null LIMIT :limits];
    for (InternationalCallingCodes__mdt c : codes ) {
      this.name2Code.put(c.CountryName__c, c.CountryCode__c);
    }
    if (this.name2Code.containsKey(DEFAULT_COUNTRY_NAME)) {
      this.defaultCode = this.name2Code.get(DEFAULT_COUNTRY_NAME);
    }
    else {
      this.defaultCode = DEFAULT_COUNTRY_CODE;
    }

  }
  public String getDefaultContryCode() {
    return this.defaultCode;
  }

  public String getCallingCode(String countryName) {
    if (this.name2Code.containsKey(countryName)) {
      return this.name2Code.get(countryName);
    }
    else {
      return this.defaultCode;
    }
  }
}