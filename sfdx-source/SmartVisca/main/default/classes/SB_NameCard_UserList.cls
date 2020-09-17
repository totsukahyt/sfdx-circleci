/**
 *
 * SB_NameCard_UserList
 * 名刺利用ユーザの取得
 *
 *
 *    ScanApp のユーザ選択の候補 ↓ とは 抽出の仕方が違う（権限セットも含む）
 *  https://sbproj.backlog.jp/wiki/SV_DEV/%E6%89%80%E6%9C%89%E8%80%85%E3%83%AA%E3%82%B9%E3%83%88%E3%81%AE%E5%8F%96%E5%BE%97%E5%87%A6%E7%90%86%EF%BC%88getuser.php%EF%BC%89
 *
 *  ScanAppと同じく、所有者になるには参照権だけでいいけど、作成権、編集権も持つユーザを抽出
 *
 * Copyright (C) 2017 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2017.10.xx v1.22 SV_DEV-339 SmartViscaカメラで名刺所有者を入力できるようにする
 *  @v2.0.3         2018.09.xx SV_DEV-1190 SmartViscaカメラの所有者選択で選択肢に無効ユーザーが表示される
 *
 **/
public with sharing class SB_NameCard_UserList {
  public class SB_NameCard_UserListException extends Exception {}

  private static final String QUERY_PERMISSIONSET =  'SELECT Id, ProfileId FROM PermissionSet WHERE Id IN (SELECT ParentId FROM ObjectPermissions WHERE SobjectType = \'\'{0}NameCard__c\'\' AND PermissionsCreate = true AND PermissionsRead = true AND PermissionsEdit = true)';
  //private static final String QUERY_PRFILE =  'SELECT Id, ProfileId FROM PermissionSet WHERE Id IN (SELECT ParentId FROM ObjectPermissions WHERE SobjectType = \'\'{0}NameCard__c\'\' AND PermissionsCreate = true AND PermissionsRead = true AND PermissionsEdit = true) AND ProfileId != null';
  private static final String NAME_DEPT_FORM = '{0} ({1})';

  // Salesforce ユーザ の情報を保持するクラス
  public virtual class UserDTO {
    public String id { get; private set; }
    public String userName { get; private set; }
    public String email { get; private set; }
    public String label { get; private set; }
    public String name { get; private set; }
    public String firstName { get; private set; }
    public String lastName { get; private set; }
    public String department { get; private set; }
    public String title { get; private set; }
    public UserDTO() {}
    public UserDTO(User u) {
      this.id = u.Id;
      this.userName = u.UserName;
      this.email = u.EMail;
      this.department = String.isNotBlank(u.Department) ? u.Department : System.Label.SB_NC_SETTING_LABEL_NONE;
      this.label = String.isNotBlank(u.Department) ? String.format(NAME_DEPT_FORM, new String[] { u.Name, u.Department }) : u.Name;
      this.name = u.Name;
      this.firstName = u.FirstName;
      this.lastName = u.LastName;
      this.title = u.Title;
    }
  }

  // Salesforce ユーザの情報を 部署 単位に保持するクラス
  public virtual class DepartmentUsers {
    public Boolean underLimit { get; private set; }
    public List<String> departments { get; private set; }   // 部署の一覧  複数部署ある場合、先頭は 全部
    public Map<String, List<UserDTO>> dept2Users { get; private set; }  // 部署とユーザのマップ
    public DepartmentUsers() {
      this.underLimit = false;
      this.departments = new List<String>();
      this.dept2Users = new Map<String, List<UserDTO>> ();
    }
    public void addUser(User u) {
      UserDTO dto = new UserDTO(u);
      List<UserDTO> dtos = null;
      if (dept2Users.containsKey(dto.department)) {
        dtos = dept2Users.get(dto.department);
      }
      else {
        dtos = new List<UserDTO>();
        this.dept2Users.put(dto.department, dtos);
      }
      dtos.add(dto);
    }
    // addUser が終わったら、finalize
    public void finalize() {
      this.underLimit = true;  // 該当なしでも 制限以下です。
      if (!this.dept2Users.isEmpty() && this.departments.size() > 1) {
        List<UserDTO> dtos = new List<UserDTO>();
        for (String dept : this.departments) {
          if (this.dept2Users.containsKey(dept)) {
            dtos.addAll(this.dept2Users.get(dept));
          }
        }
        this.dept2Users.put(Label.SB_Text_All, dtos);
      }
    }
    // addUser せず、部署だけ充填
    public void addUserDepts(List<AggregateResult> userDepts) {
      this.departments.add(Label.SB_Text_All);
      for (AggregateResult ar : userDepts) {
        String dept = (String)ar.get('Department');
        this.departments.add(String.isNotBlank(dept) ? dept : System.Label.SB_NC_SETTING_LABEL_NONE);
      }
    }

  }

  private static final String QUERY_FORMAT = 'SELECT {0} FROM User {1} {2}';
  private static final String QUERY_FIELDS = 'Id, Name, UserName, EMail, FirstName, LastName ,Title, Department';
  // private static final String QUERY_CONDITION = 'WHERE IsActive = true AND Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId IN :permissionSets)';
  private static final String QUERY_ORDER = 'ORDER BY Department ASC NULLS LAST, Name ASC';
  private static final String QUERY_DEPTS = 'SELECT Department FROM User {0} GROUP BY Department ORDER BY Department ASC NULLS LAST';
  // private Integer getValidNameCardUserCount(){
  // }

  // private Boolean doForceQuery() {
  // }
  private static String getQueryCondition(String dept, String word) {
    List<String> andFields = new List<String>();
    andFields.add('IsActive = true');
    andFields.add('Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId IN :permissionSets)');
    if (String.isNotBlank(dept) && dept != Label.SB_Text_All) {
      if (dept != System.Label.SB_NC_SETTING_LABEL_NONE) {
        andFields.add('Department =\'' + String.escapeSingleQuotes(dept) + '\'');
      }
      else {
        andFields.add('Department = null'); // 部署なし
      }
    }
    // 名前
    if (String.isNotBlank(word)) {
      List<String> orFields = new List<String>();
      orFields.add(String.format('Name LIKE \'\'%{0}%\'\'', new String[] { String.escapeSingleQuotes(word) }));
      orFields.add(String.format('UserName LIKE \'\'%{0}%\'\'', new String[] { String.escapeSingleQuotes(word) }));
      orFields.add(String.format('EMail LIKE \'\'%{0}%\'\'', new String[] { String.escapeSingleQuotes(word) }));
      orFields.add(String.format('Title LIKE \'\'%{0}%\'\'', new String[] { String.escapeSingleQuotes(word) }));
      orFields.add(String.format('Department LIKE \'\'%{0}%\'\'', new String[] { String.escapeSingleQuotes(word) }));
      andFields.add('(' + String.join(orFields, ' OR ') + ')');
    }
    return String.format('WHERE {0}', new String[]{ String.join(andFields, ' AND ') });
  }

  private static String getUserCountQuery(String dept, String word) {
    String condition = getQueryCondition(dept, word);
    return String.format(QUERY_FORMAT, new String[]{ 'Count(Id) CNT', condition, '' });
  }

  private static String getUserQuery(String dept, String word) {
    String condition = getQueryCondition(dept, word);
    return String.format(QUERY_FORMAT, new String[]{ QUERY_FIELDS, condition, QUERY_ORDER });
  }

  private static String getDeptsQuery() {
    String condition = getQueryCondition(null, null);
    return String.format(QUERY_DEPTS, new String[]{ condition });
  }


  /**
  *
  *  Salesforce ユーザの情報を 部署 単位に保持するクラスを返すメソッド
  *  2017.10.xx v1.22
  *     SV_DEV-339 SmartViscaカメラで名刺所有者を入力できるようにする
  *
  ***/
  public static DepartmentUsers getDepartmentUsers(String dept, String word) {
    DepartmentUsers result = new DepartmentUsers();
    try {
      // 権限セットろプロファイルのIDs
      String queryPermissionSet = String.format(QUERY_PERMISSIONSET, new String[]{ SB_NameCard_Util.getNamespacePrefix_x() });
      // 名刺アクセス権のある 権限セット（プロファイルを含む）を取得
      List<PermissionSet> permissionSets = Database.query(queryPermissionSet);
      if (permissionSets.isEmpty()) {
        throw new  SB_NameCard_UserListException('No Right PermissionSet');
      }
      // 有効な名刺ユーザのいる部署のリスト作成
      List<AggregateResult> userDepts = Database.query(getDeptsQuery());
      result.addUserDepts(userDepts);
      // 有効な名刺ユーザ数を調べる
      List<AggregateResult> ars = Database.query(getUserCountQuery(null, word));
      if (ars.isEmpty()) {
        throw new SB_NameCard_UserListException('No NameCard User');
      }
      Integer userCnt = (Integer)ars[0].get('CNT');
      if (0< userCnt && userCnt <= SB_NameCard_Util.smartViscaConfig.SCameraOwnerSelectLimit__c) {
        // 名刺アクセス権のあるユーザ取得 部署 NULL は最後
        // List<User> users = [SELECT Id, Name, UserName, EMail, FirstName, LastName ,Title, Department FROM User WHERE IsActive = true AND Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId IN :permissionSets) ORDER BY Department ASC NULLS LAST, Name ASC LIMIT 2000];
        List<User> users = Database.query(getUserQuery(null, word));
        if (users.isEmpty()) {
          throw new  SB_NameCard_UserListException('No Permission Assignment User');
        }
        for (User u : users) {
          result.addUser(u);
        }
        result.finalize();
      }
      else if (userCnt == 0) {
        result.finalize();
      }
    }
    catch(Exception e) {
      System.debug(e.getMessage());
    }
    return result;
  }

  // ユーザレコードの 部署単位の数を返す ユニットテスト用
  public static Map<String, Integer> getDept2Number() {
    Map<String, Integer> result = new Map<String, Integer>();
    String queryPermissionSet = String.format(QUERY_PERMISSIONSET, new String[]{ SB_NameCard_Util.getNamespacePrefix_x() });
    // 名刺アクセス権のある 権限セット（プロファイルを含む）を取得
    List<PermissionSet> permissionSets = Database.query(queryPermissionSet);
    if (!permissionSets.isEmpty()) {
      // 名刺アクセス権のある  ユーザ を 部署単位 に カウント
      List<AggregateResult> ars = [SELECT Count(Id) CNT, Department FROM User WHERE IsActive = true AND Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId IN :permissionSets) GROUP BY Department  LIMIT 2000];
      //List<AggregateResult> ars = [SELECT Count(Id) CNT, Department FROM User GROUP BY Department];
      for (AggregateResult ar : ars) {
        String dept = (String)ar.get('Department');
        Integer cnt = (Integer)ar.get('CNT');
        if (cnt != null && cnt >= 0) {
          if (String.isNotBlank(dept)) {
            result.put(dept, cnt);
          }
          else {
            result.put(System.Label.SB_NC_SETTING_LABEL_NONE, cnt);
          }
        }
      }
    }
    return result;
  }

  // 名刺を使える プロファイルのID を返す
  //public static Set<Id> getNameCardValidProfileId() {
  //  String query_p = String.format(QUERY_PRFILE, new String[]{ SB_NameCard_Util.getNamespacePrefix_x() });
  //  // 名刺アクセス権のある 権限セット（プロファイルを含む）を取得
  //  Map<Id, PermissionSet> permissionSets = new Map<Id, PermissionSet> (Database.query(query_p));
  //  return permissionSets.keySet();
  //}

}