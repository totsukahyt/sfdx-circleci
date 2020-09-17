/**
 *
 * SB_NameCard_UserListTest
 *
 * 名刺利用ユーザの取得 SB_NameCard_UserList のテストクラス
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1     2018.01.xx v1.22
 *
 **/
@isTest
private class SB_NameCard_UserListTest
{

  public class TestDb extends SB_NC_TestDB {

    // ユーザレコードの作成
    public User createUserInDept(String firstname, String lastname, String dept) {
      return new User(
        alias = String.format('{0}-{1}', new String[]{firstname,lastname}).subString(0, 7)
        , email= firstname+lastname+'@testorg.com'
        , emailencodingkey='UTF-8'
        , firstname = firstname
        , department = dept
        , lastname = lastname
        , languagelocalekey='ja'
        , localesidkey='ja_JP'
        , profileid = profStd.Id
        , timezonesidkey='Asia/Tokyo'
        , username=firstname+lastname+'@testorg.com');
    }

    // ユーザの初期化
    public override void initializeUser() {
      for(Integer n=1; n <= 10 ; n++) {
        listUser.add(createUserInDept(n.format(), 'Smart', null));
      }
      for(Integer n=11; n <= 20 ; n++) {
        listUser.add(createUserInDept(n.format(), 'Smart', 'テスト部'));
      }
    }

    public override void initialize() {
      initializeUser();
      if (!listUser.isEmpty()) {
        insert listUser;
      }
    }
  } // public class TestDb extends SB_NC_TestDB

  // SB_NameCard_UserList.DepartmentUsers depts = SB_NameCard_UserList.getDepartmentUsers 得る以下を確認
  //public List<String> departments { get; private set; }   // 部署の一覧  複数部署ある場合、先頭は 全部
  //public Map<String, List<UserDTO>> dept2Users { get; private set; }  // 部署とユーザのマップ
  @isTest
  static void test_getDepartmentUsers() {
    //TestDb db = new TestDb();
    //db.initialize();

    Test.startTest();
    SB_NameCard_UserList.DepartmentUsers depts = SB_NameCard_UserList.getDepartmentUsers(null, null);
    // 別のメソッドでも調べる
    Map<String, Integer> dept2num = SB_NameCard_UserList.getDept2Number();
    // 結果を突き合わせる
    // depts.departments には「全て」があるので マイナス1する。あるいは、部署が1つ（あるいはなし）ならば、全てはないので 1
    System.assert(dept2num.size() == depts.departments.size()-1 | dept2num.size()==1);

    for (String dept : dept2num.keySet()) {
      System.assert(depts.dept2Users.containsKey(dept));
      System.assertEquals(dept2num.get(dept), depts.dept2Users.get(dept).size());
    }
    Test.stopTest();
  }
  
  @isTest
  static void test_getDepartmentUsers_WithCondition() {
    //TestDb db = new TestDb();
    //db.initialize();

    Test.startTest();
    Boolean success = true;
    SB_NameCard_UserList.DepartmentUsers depts = SB_NameCard_UserList.getDepartmentUsers('テスト部', 'smart');
    // 別のメソッドでも調べる
    Map<String, Integer> dept2num = SB_NameCard_UserList.getDept2Number();
    System.debug(dept2num.get('テスト部'));
    System.debug(depts.dept2Users.get('テスト部'));
    // 結果を突き合わせる
    System.assert(dept2num.get('テスト部')==null || dept2num.get('テスト部') >= depts.dept2Users.get('テスト部').size());
    Test.stopTest();
  }
  
}