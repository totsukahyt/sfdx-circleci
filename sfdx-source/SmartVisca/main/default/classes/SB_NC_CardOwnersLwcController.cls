/**
 *  SB_NC_CardOwnersLwcController
 *  同じ人の名刺を持つユーザ Lightning Web Component の　コントローラ

2019.07.xx v2.4 より
AppBuilder で コンポーネントを名刺詳細ページに配置してい使います。

以下の 設定項目 があります。
・名刺交換日を表示する 
・表示中レコードの所有者を含める
・無効なユーザも含める
・転職前後の名刺も含める
表示中の名刺と同じ名刺（最新の名刺が同じもの）を「転職後の名刺」として参照している名刺(の所有者)
あるいは、
表示中の名刺と同じ名刺（最新の名刺が同じもの）の中で「転職後の名刺」として参照している名刺(の所有者)
をリストに含めます。
・並び順(初期値)  
氏名、部署、名刺交換日から選択

名刺交換日 は同一のユーザが複数名刺ある場合は、最新の日付を採用します。

表示する項目は、名刺交換日以外は以下で固定です。
プロファイルの画像
会社名、部署、役職
メールアドレス
電話番号
携帯番号

表示されたユーザ情報は リンクになっていて、クリックすると該当ユーザのプロファイルページに遷移します。

 *
 *  @author sawano
 *  @Version1 v2.4 2019.06.xx SV_DEV-1593 LEX画面の名刺詳細から「同じ名刺を持つユーザ」を確認できるようにしてほしい
 *
 **/
public with sharing class SB_NC_CardOwnersLwcController {

  @AuraEnabled(cacheable=true)
  public static SB_NC_CardOwnersBuilder.GetCardOwnersResponse getUsersHavingCard(Id cardId,
        Boolean excludeMe,    // 自分を除外する
        Boolean includeCurrentOwner,  // このレコード所有者を含める
        Boolean includeInactiveUser,  // 無効なユーザも含める
        Boolean traceChangeJob, // 転職前後の名刺も含める
        Boolean showExchangeDate, // 名刺交換日を表示する
        String sortField, // 並び替え項目
        Boolean sortAsc,   // 昇順
        String titleFields,  // 所属役職等の表示項目
        String fields) {       // ユーザの表示項目 ToDo

    SB_NC_CardOwnersBuilder builder = new SB_NC_CardOwnersBuilder(
        cardId,
        excludeMe,    // 自分を除外する
        includeCurrentOwner,  // このレコード所有者を含める
        includeInactiveUser,  // 無効なユーザも含める
        traceChangeJob, // 転職前後の名刺も含める
        showExchangeDate, // 名刺交換日を表示する
        sortField, // 並び替え項目
        sortAsc,   // 昇順
        titleFields,  // 所属役職等の表示項目
        fields);       // ユーザの表示項目 ToDo
    return builder.create();
  }

}