@isTest
private class SB_NameCard_SFDCSystemStatusCodeTest
{
  @isTest
  static void test_getMessageText() {
    String text;
    text = SB_NameCard_SFDCSystemStatusCode.getMessageText(System.StatusCode.INSUFFICIENT_ACCESS_OR_READONLY);
    System.assert(String.isNotBlank(text));
    text = SB_NameCard_SFDCSystemStatusCode.getMessageText(System.StatusCode.DUPLICATE_USERNAME);
    System.assert(String.isBlank(text) || SB_NameCard_SFDCSystemStatusCode.SYSTEM_STATUSCODES.containsKey(System.StatusCode.DUPLICATE_USERNAME));
  }


}