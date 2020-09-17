/**
 *
 * SB_NameCard_SFDCSystemStatusCode
 *   System.StatusCode を エラーについての文字列にして返す。
 *
 * Copyright (C) 2018 SunBridge Inc. All Rights Reserved.
 * 
 *  @author sawano
 *  @Version 1      2018.01.xx v1.22
 *
 **/
global class SB_NameCard_SFDCSystemStatusCode {

  // https://developer.salesforce.com/docs/atlas.ja-jp.api.meta/api/sforce_api_calls_concepts_core_data_objects.htm 日本語
  // https://developer.salesforce.com/docs/atlas.en-us.210.0.api.meta/api/sforce_api_calls_concepts_core_data_objects.htm 英語
  // StatusCode より

  @TestVisible
  private static final Map<System.StatusCode, String> SYSTEM_STATUSCODES = new Map<System.StatusCode, String> {
    //下記のLOGIN_CHALLENGE_ISSUED,LOGIN_CHALLENGE_PENDING,MAX_TASK_DESCRIPTION_EXCEEDED,LOGIN_MUST_USE_SECURITY_TOKEN,BCC_SELF_NOT_ALLOWED_IF_BCC_COMPLIANCE_ENABLED,UNSUPPORTED_APEX_TRIGGER_OPERATION,CANNOT_RESOLVE_NAMEはシステムから呼べればいので、コメントアウトする
    // StatusCode.LOGIN_CHALLENGE_ISSUED                             => System.Label.SFDC_SC_LOGIN_CHALLENGE_ISSUED,        //ユーザが信頼できない IP アドレスからログインしたため、セキュリティトークンを含むメールがユーザのメールアドレスに送信されました。ユーザは、セキュリティトークンをパスワードの末尾に追加しないとログインできません。
    // StatusCode.LOGIN_CHALLENGE_PENDING                            => System.Label.SFDC_SC_LOGIN_CHALLENGE_PENDING,       //ユーザが信頼できない IP アドレスからログインしましたが、セキュリティトークンがまだ発行されていません。
    // StatusCode.MAX_TASK_DESCRIPTION_EXCEEDED                      => System.Label.SFDC_SC_MAX_TASK_DESCRIPTION_EXCEEDED, //ToDo の説明が長すぎます。
    // StatusCode.LOGIN_MUST_USE_SECURITY_TOKEN                      => System.Label.SFDC_SC_LOGIN_MUST_USE_SECURITY_TOKEN, //ユーザは、セキュリティトークンをパスワードの末尾に追加してログインする必要があります。
    // StatusCode.BCC_SELF_NOT_ALLOWED_IF_BCC_COMPLIANCE_ENABLED     => System.Label.SFDC_SC_BCC_SELF_NAIBC,                //コンプライアンス BCC メールオプションが組織で有効になっているにも関わらず、クライアントアプリケーションがログインユーザのメールアドレスへ、BCC でメールを送信しようとしました。このオプションは送信されるメールの写しを自動的に受信する特定のメールアドレスを指定します。このオプションが有効な場合、他のメールアドレスに BCC 送信できません。オプションを無効にするには、ユーザインターフェースにログインし、[設定] から、[クイック検索] ボックスに「コンプライアンス BCC メール」と入力し、[コンプライアンス BCC メール] を選択します。
    // StatusCode.UNSUPPORTED_APEX_TRIGGER_OPERATION                 => System.Label.SFDC_SC_UNST_ATO,                      //Apex トリガでは定期的な行動を保存できません。
    // StatusCode.CANNOT_RESOLVE_NAME                                => System.Label.SFDC_SC_CANNOT_RESOLVE_NAME,           //sendEmail() コールがオブジェクト名を解決できませんでした。
    StatusCode.TOO_MANY_APEX_REQUESTS                              => System.Label.SFDC_SC_TOO_MANY_APEX_REQUESTS,             //送信された Apex 要求の数が多すぎます。これは一時的なエラーです。少ししてから要求を再送信してください。
    StatusCode.INVALID_MESSAGE_ID_REFERENCE                        => System.Label.SFDC_SC_INVALID_MESSAGE_ID_REFERENCE,       //送信メールの References または In-Reply-To 項目が無効です。これらの項目には、有効なメッセージ ID が必要です。「RFC2822 - Internet Message Format」を参照してください。
    StatusCode.PACKAGE_LICENSE_REQUIRED                            => System.Label.SFDC_SC_PACKAGE_LICENSE_REQUIRED,           //パッケージのライセンスがない場合、ログインユーザはライセンスパッケージに含まれているオブジェクトにアクセスできません。
    StatusCode.INVALID_CROSS_REFERENCE_TYPE_FOR_FIELD              => System.Label.SFDC_SC_INVALID_CROSS_RTYPEFF,              //指定された相互参照タイプが、指定された項目で有効な型ではありません。
    StatusCode.WEBLINK_URL_INVALID                                 => System.Label.SFDC_SC_WEBLINK_URL_INVALID,                //WebLink URL で URL 文字列の入力規則チェックに失敗しました。
    StatusCode.INVALID_READ_ONLY_USER_DML                          => System.Label.SFDC_SC_INVALID_READ_ONLY_USER_DML,         //バージョン 31.0 以前: 組織が含まれるインスタンスを最新リリースにアップグレードしている間は、データを作成、更新、削除できません。リリースが完了してから再度実行してください。リリーススケジュールについての詳細は、trust.salesforce.com を参照してください。バージョン 31.0 より後の場合、コードは INSERT_UPDATE_DELETE_NOT_ALLOWED_DURING_MAINTENANCE になります。
    StatusCode.INVALID_EMAIL_ADDRESS                               => System.Label.SFDC_SC_INVALID_EMAIL_ADDRESS,              //指定されたメールアドレスが無効です。
    StatusCode.INVALID_ASSIGNEE_TYPE                               => System.Label.SFDC_SC_INVALID_ASSIGNEE_TYPE,              //1 から 6 の間の有効な整数でない値を任命先種別として指定しました。
    StatusCode.MERGE_FAILED                                        => System.Label.SFDC_SC_MERGE_FAILED,                       //マージ操作が失敗しました。
    StatusCode.MISSING_ARGUMENT                                    => System.Label.SFDC_SC_MISSING_ARGUMENT,                   //必要な引数が指定されていません。
    StatusCode.INVALID_INET_ADDRESS                                => System.Label.SFDC_SC_INVALID_INET_ADDRESS,               //指定された Inet アドレスが無効です。
    StatusCode.INVALID_CURRENCY_ISO                                => System.Label.SFDC_SC_INVALID_CURRENCY_ISO,               //指定された通貨 ISO コードが有効ではありません。
    StatusCode.INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST             => System.Label.SFDC_SC_INVALID_OR_NULL_FRP,                //制限つき選択リストに無効な値または null 値を指定しました。
    StatusCode.INVALID_ID_FIELD                                    => System.Label.SFDC_SC_INVALID_ID_FIELD,                   //指定された ID 項目 (ID、ownerId) または相互参照項目が無効です。
    StatusCode.CUSTOM_METADATA_LIMIT_EXCEEDED                      => System.Label.SFDC_SC_CUSTOM_METADATA_LIMIT_EXCEEDED,     //組織のカスタムメタデータの最大制限に達しました。
    StatusCode.EMAIL_TEMPLATE_MERGEFIELD_VALUE_ERROR               => System.Label.SFDC_SC_EMAIL_TMP_MER_VE,                   //1 つ以上の差し込み項目に値がありません。値を指定するには、メールを送信する前にレコードを更新します。
    StatusCode.CANT_UNSET_CORP_CURRENCY                            => System.Label.SFDC_SC_CANT_UNSET_CORP_CURRENCY,           //組織のマスタ通貨は API から変更できません。マスタ通貨はユーザインターフェースを使用して変更します。
    StatusCode.CANNOT_CASCADE_PRODUCT_ACTIVE                       => System.Label.SFDC_SC_CANT_CASCADE_PA,                    //カスケードによる商品への更新は、関連付けられた商品がアクティブであるため実行できません。
    StatusCode.ALREADY_IN_PROCESS                                  => System.Label.SFDC_SC_ALREADY_IN_PROCESS,                 //すでに承認プロセスが開始しているレコードは送信できません。前の承認プロセスが完了するまで待機してからこのレコードの要求を再送信します。
    StatusCode.INVALID_TYPE_FOR_OPERATION                          => System.Label.SFDC_SC_INVALID_TYPE_FOR_OPERATION,         //指定された型が、指定された操作で有効ではありません。
    StatusCode.INVALID_CROSS_REFERENCE_KEY                         => System.Label.SFDC_SC_INVALID_CROSS_REFERENCE_KEY,        //参照項目に指定した値が有効でないか、データが予期した型ではありません。
    StatusCode.NO_APPLICABLE_PROCESS                               => System.Label.SFDC_SC_NO_APPLICABLE_PROCESS,              //送信されたレコードが、ユーザが権限のあるどの有効承認プロセスのエントリ条件も満たさないため、process() 要求が失敗しました。
    StatusCode.MAXIMUM_SIZE_OF_DOCUMENT                            => System.Label.SFDC_SC_MAXIMUM_SIZE_OF_DOCUMENT,           //ドキュメントサイズの上限を超えました。
    StatusCode.CANNOT_CHANGE_FIELD_TYPE_OF_APEX_REFERENCED_FIELD   => System.Label.SFDC_SC_CANT_CFTOAR,                        //Apex スクリプトで参照されている項目のデータ型は変更できません。
    StatusCode.CANNOT_REPARENT_RECORD                              => System.Label.SFDC_SC_CANNOT_REPARENT_RECORD,             //指定したレコードに新しい親レコードを定義できません。
    StatusCode.EMAIL_TEMPLATE_PROCESSING_ERROR                     => System.Label.SFDC_SC_EMAIL_TEMPLATE_PROCESSING_ERROR,    //このメールテンプレートの差し込み項目は処理できません。テンプレートの本文が有効であることを確認してください。
    StatusCode.JIGSAW_IMPORT_LIMIT_EXCEEDED                        => System.Label.SFDC_SC_JIGSAW_IMPORT_LIMIT_EXCEEDED,       //Data.com から購入を試みたレコードの数が、使用可能なレコード追加制限を上回っています。
    StatusCode.NUM_HISTORY_FIELDS_BY_SOBJECT_EXCEEDED              => System.Label.SFDC_SC_NUM_HISTORY,                        //sObject に指定された履歴項目数が制限を超えています。
    StatusCode.INVALID_OPERATOR                                    => System.Label.SFDC_SC_INVALID_OPERATOR,                   //ワークフロー条件として使用する場合、このデータ型に指定した演算子は使用できません。
    StatusCode.EMAIL_OPTED_OUT                                     => System.Label.SFDC_SC_EMAIL_OPTED_OUT,                    //単一のメールメッセージが optOutPolicy 項目の REJECT 設定を使用して、受信メールの送信除外を設定している受信者に送信されました。このエラーを回避するには、optOutPolicy 項目を別の値に設定します。
    StatusCode.PRIVATE_CONTACT_ON_ASSET                            => System.Label.SFDC_SC_PRIVATE_CONTACT_ON_ASSET,           //納入商品に非公開の取引先責任者は設定できません。
    StatusCode.INVALID_OPERATION                                   => System.Label.SFDC_SC_INVALID_OPERATION,                  //指定されたオブジェクトに適用可能な承認プロセスはありません。
    StatusCode.CANT_DISABLE_CORP_CURRENCY                          => System.Label.SFDC_SC_CANT_DISABLE_CORP_CURRENCY,         //組織のマスタ通貨は無効にできません。マスタ通貨として設定されている通貨を無効にするには、ユーザインターフェースを使用してマスタ通貨を別の通貨に変更してから、その通貨を無効にします。
    StatusCode.ENTITY_IS_ARCHIVED                                  => System.Label.SFDC_SC_ENTITY_IS_ARCHIVED,                 //アーカイブされたレコードにはアクセスできません。
    StatusCode.UNDELETE_FAILED                                     => System.Label.SFDC_SC_UNDELETE_FAILED,                    //オブジェクトが存在しないか、削除されていないため、このオブジェクトを復元できません。
    StatusCode.MALFORMED_ID                                        => System.Label.SFDC_SC_MALFORMED_ID,                       //ID は 15 文字、または大文字と小文字を識別するための有効な拡張を含めて 18 文字でなければなりません。同じ名前の例外コードが存在します。
    StatusCode.MAX_FORMULAS_PER_RULE_EXCEEDED                      => System.Label.SFDC_SC_MAX_FORMULAS_PER_RULE_EXCEEDED,     //ルールあたりの数式数の上限を超えました。
    StatusCode.MANAGER_NOT_DEFINED                                 => System.Label.SFDC_SC_MANAGER_NOT_DEFINED,                //指定された承認プロセスにはマネージャが定義されていません。
    StatusCode.DELETE_FAILED                                       => System.Label.SFDC_SC_DELETE_FAILED,                      //他のオブジェクトが使用中のため、レコードを削除できません。
    StatusCode.STANDARD_PRICE_NOT_DEFINED                          => System.Label.SFDC_SC_STANDARD_PRICE_NOT_DEFINED,         //対応する標準価格がなければ、カスタム価格を定義することはできません。
    StatusCode.IP_RANGE_LIMIT_EXCEEDED                             => System.Label.SFDC_SC_IP_RANGE_LIMIT_EXCEEDED,            //指定された IP アドレスが、組織に指定された IP 範囲外です。
    StatusCode.LIGHT_PORTAL_USER_EXCEPTION                         => System.Label.SFDC_SC_LIGHT_PORTAL_USER_EXCEPTION,        //許可されていない大規模ポータルユーザでアクションを実行しようとしました。たとえば、ケースチームへのユーザの追加などです。
    StatusCode.DUPLICATE_CUSTOM_ENTITY_DEFINITION                  => System.Label.SFDC_SC_DUP_CT_ED,                          //カスタムオブジェクトまたはカスタム項目の ID は一意でなければなりません。
    StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION                   => System.Label.SFDC_SC_FIELD_CT_VE,                        //項目の整合性規則に違反するカスタム入力規則数式は定義できません。
    StatusCode.DUPLICATE_DEVELOPER_NAME                            => System.Label.SFDC_SC_DUPLICATE_DEVELOPER_NAME,           //開発者名が重複するカスタムオブジェクトやカスタム項目は作成できません。
    StatusCode.INVALID_BATCH_OPERATION                             => System.Label.SFDC_SC_INVALID_BATCH_OPERATION,            //指定されたバッチ操作が無効です。
    StatusCode.ALL_OR_NONE_OPERATION_ROLLED_BACK                   => System.Label.SFDC_SC_ALL_OR_NONE_OPERATION_ROLLED_BACK,  //いずれかのレコードが正常に処理されなかったため、一括操作はロールバックされました。「AllOrNoneHeader」を参照してください。
    StatusCode.CIRCULAR_DEPENDENCY                                 => System.Label.SFDC_SC_CIRCULAR_DEPENDENCY,                //組織内のメタデータオブジェクト間では循環参照は作成できません。たとえば、公開グループ A が公開グループ B に含まれている場合、公開グループ B を公開グループ A に含めることはできません。
    StatusCode.ENTITY_FAILED_IFLASTMODIFIED_ON_UPDATE              => System.Label.SFDC_SC_ENTITY_FAILED_IOU,                  //レコードの LastModifiedDate 項目の値が現在の日付より後に設定されている場合、レコードを更新できません。
    StatusCode.CANNOT_RENAME_APEX_REFERENCED_OBJECT                => System.Label.SFDC_SC_CANT_RENAME_ARO,                    //Apex スクリプトで参照されているオブジェクトの名前は変更できません。
    StatusCode.MASSMAIL_RETRY_LIMIT_EXCEEDED                       => System.Label.SFDC_SC_MASSMAIL_RETRY_LIMIT_EXCEEDED,      //組織の一括メール送信再実行の上限を超えたため、一括メール送信再実行が失敗しました。
    StatusCode.MAX_TM_RULE_ITEMS_EXCEEDED                          => System.Label.SFDC_SC_MAX_TM_RULE_ITEMS_EXCEEDED,         //Territory のルールあたりのルール条件の数の上限を超えました。
    StatusCode.OPTED_OUT_OF_MASS_MAIL                              => System.Label.SFDC_SC_OPTED_OUT_OF_MASS_MAIL,             //指定された User が一括メール送信を除外したため、メールを送信できません。
    StatusCode.WRONG_CONTROLLER_TYPE                               => System.Label.SFDC_SC_WRONG_CONTROLLER_TYPE,              //Visualforce メールテンプレートのコントローラタイプが、使用されているオブジェクト種別と一致しません。
    StatusCode.MAX_APPROVAL_STEPS_EXCEEDED                         => System.Label.SFDC_SC_MAX_APPROVAL_STEPS_EXCEEDED,        //承認プロセスの承認ステップ数の上限を超えました。
    StatusCode.TABSET_LIMIT_EXCEEDED                               => System.Label.SFDC_SC_TABSET_LIMIT_EXCEEDED,              //タブセットに許可されたタブ数を超えています。
    StatusCode.DUPLICATE_VALUE                                     => System.Label.SFDC_SC_DUPLICATE_VALUE,                    //一意でなければならない項目に重複する値は指定できません。たとえば、invalidateSessions() コールで同じセッション ID の複製を 2 つ送信できません。
    StatusCode.MAXIMUM_CCEMAILS_EXCEEDED                           => System.Label.SFDC_SC_MAXIMUM_CCEMAILS_EXCEEDED,          //ワークフローメールアラートで指定された CC アドレスが上限数を超えました。
    StatusCode.OP_WITH_INVALID_USER_TYPE_EXCEPTION                 => System.Label.SFDC_SC_OP_WITH_INVALID_USER_TYPE_EXCEPTION,//1 人以上のユーザについて、試行した操作を実行できません。たとえば、大規模ポータルユーザをグループに追加することはできません。
    StatusCode.CANNOT_CREATE_ANOTHER_MANAGED_PACKAGE               => System.Label.SFDC_SC_CANT_CREATE_AMP,                    //組織では管理パッケージは 1 つしか作成できません。
    StatusCode.DUPLICATE_SENDER_DISPLAY_NAME                       => System.Label.SFDC_SC_DUPLICATE_SENDER_DISPLAY_NAME,      //sendEmail() コール OrgWideEmailAddress.DisplayName または senderDisplayName から選択できませんでした。2 つの項目のいずれかのみ定義できます。
    StatusCode.INSUFFICIENT_ACCESS_OR_READONLY                     => System.Label.SFDC_SC_INSUFFICIENT_ACCESS_OR_READONLY,    //指定したアクションを実行する十分な権限がないため、実行できません。
    StatusCode.RECORD_IN_USE_BY_WORKFLOW                           => System.Label.SFDC_SC_RECORD_IN_USE_BY_WORKFLOW,          //ワークフロープロセスまたは承認プロセスによって使用されているレコードにはアクセスできません。
    StatusCode.PORTAL_USER_ALREADY_EXISTS_FOR_CONTACT              => System.Label.SFDC_SC_PORTAL_USER_AEFC,                   //Contact の下に 2 つ目のポータルユーザは作成できないため、User 作成操作が失敗しました。
    StatusCode.BCC_NOT_ALLOWED_IF_BCC_COMPLIANCE_ENABLED           => System.Label.SFDC_SC_BCC_NOT_AIBCE,                      //コンプライアンス BCC メールオプションが組織で有効になっているにも関わらず、クライアントアプリケーションがメールアドレスへ BCC でメールを送信しようとしました。このオプションは送信されるメールの写しを自動的に受信する特定のメールアドレスを指定します。このオプションが有効な場合、他のメールアドレスに BCC 送信できません。オプションを無効にするには、ユーザインターフェースにログインし、[設定] から、[クイック検索] ボックスに「コンプライアンス BCC メール」と入力し、[コンプライアンス BCC メール] を選択します。
    StatusCode.EMAIL_TEMPLATE_MERGEFIELD_ACCESS_ERROR              => System.Label.SFDC_SC_EMAIL_TMP_MAE,                      //このテンプレートの 1 つ以上の差し込み項目に対するアクセス権がありません。アクセス権を要求するには、Salesforce システム管理者に連絡してください。
    StatusCode.INVALID_EMPTY_KEY_OWNER                             => System.Label.SFDC_SC_INVALID_EMPTY_KEY_OWNER,            //owner に null 値は設定できません。
    StatusCode.NUMBER_OUTSIDE_VALID_RANGE                          => System.Label.SFDC_SC_NUMBER_OUTSIDE_VALID_RANGE,         //指定された数値が、値の有効な範囲外です。
    StatusCode.HTML_FILE_UPLOAD_NOT_ALLOWED                        => System.Label.SFDC_SC_HTML_FILE_UPLOAD_NOT_ALLOWED,       //HTML ファイルのアップロードが失敗しました。Solution への HTML 添付ファイルなど、HTML 添付ファイルおよびドキュメントは、[HTML ドキュメントと添付ファイルの設定] ページで [HTML ドキュメントと添付ファイルを許可しない] チェックボックスがオンになっているとアップロードできません。
    StatusCode.INVALID_MASTER_OR_TRANSLATED_SOLUTION               => System.Label.SFDC_SC_IVD_MASTER_ORS,                     //ソリューションが無効です。たとえば、翻訳ソリューションと、別の翻訳ソリューションが関連付けられているマスタソリューションとを関連付けようとした場合にこの例外が発生します。
    StatusCode.CUSTOM_FIELD_INDEX_LIMIT_EXCEEDED                   => System.Label.SFDC_SC_CT_FIELD_ILE,                       //組織の項目へのインデックスの最大数に達しました。
    StatusCode.CUSTOM_INDEX_EXISTS                                 => System.Label.SFDC_SC_CUSTOM_INDEX_EXISTS,                //項目に対して作成できるカスタムインデックスは 1 つだけです。
    StatusCode.MAX_RULE_ENTRIES_EXCEEDED                           => System.Label.SFDC_SC_MAX_RULE_ENTRIES_EXCEEDED,          //ルールのエントリ数の上限を超えました。
    StatusCode.CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY                => System.Label.SFDC_SC_CANT_INSERT_UAC,                    //指定されたレコードの作成、更新、有効化の権限がありません。
    StatusCode.LIMIT_EXCEEDED                                      => System.Label.SFDC_SC_LIMIT_EXCEEDED,                     //項目のサイズまたは値、ライセンスまたはその他のコンポーネントの制限を超えました。
    StatusCode.NO_ATTACHMENT_PERMISSION                            => System.Label.SFDC_SC_NO_ATTACHMENT_PERMISSION,           //組織ではメールへの添付ファイルが許可されていません。
    StatusCode.MAX_RULES_EXCEEDED                                  => System.Label.SFDC_SC_MAX_RULES_EXCEEDED,                 //オブジェクトのルール数の上限を超えました。
    StatusCode.CANNOT_DISABLE_LAST_ADMIN                           => System.Label.SFDC_SC_CANNOT_DISABLE_LAST_ADMIN,          //少なくとも 1 人の有効な管理者ユーザが必要です。
    StatusCode.INVALID_PARTNER_NETWORK_STATUS                      => System.Label.SFDC_SC_INVALID_PARTNER_NETWORK_STATUS,     //指定されたテンプレート項目の、指定されたパートナーネットワーク状況が無効です。
    StatusCode.INVALID_FILTER_ACTION                               => System.Label.SFDC_SC_INVALID_FILTER_ACTION,              //指定した検索条件アクションは、指定したオブジェクトでは使用できません。たとえば、アラートは Task の有効な条件アクションではありません。
    StatusCode.MAXIMUM_HIERARCHY_LEVELS_REACHED                    => System.Label.SFDC_SC_MAX_HLR,                            //階層の最大レベル数に達しました。
    StatusCode.INVALID_CURRENCY_CORP_RATE                          => System.Label.SFDC_SC_INVALID_CURRENCY_CORP_RATE,         //マスタ通貨の換算レートは変更できません。
    StatusCode.MASS_MAIL_LIMIT_EXCEEDED                            => System.Label.SFDC_SC_MASS_MAIL_LIMIT_EXCEEDED,           //組織の一括メール送信の 1 日の上限を超えました。翌日になるまで一括メールメッセージは再送信できません。
    StatusCode.NO_MASS_MAIL_PERMISSION                             => System.Label.SFDC_SC_NO_MASS_MAIL_PERMISSION,            //メールを送信する権限が付与されていません。一括メール送信には「一括メール送信」権限、個別メール送信には「メールの送信」権限が必要です。
    StatusCode.DUPLICATE_USERNAME                                  => System.Label.SFDC_SC_DUPLICATE_USERNAME,                 //ユーザ名が重複しているため、作成、更新、または更新/挿入に失敗しました。
    StatusCode.ASSIGNEE_TYPE_REQUIRED                              => System.Label.SFDC_SC_ASSIGNEE_TYPE_REQUIRED,             //承認申請 (ProcessInstanceStep または ProcessInstanceWorkitem) の任命先を指定します。
    StatusCode.INVALID_EVENT_SUBSCRIPTION                          => System.Label.SFDC_SC_INVALID_EVENT_SUBSCRIPTION,         //イベントの登録時に無効なパラメータが指定されました。
    StatusCode.INVALID_SAVE_AS_ACTIVITY_FLAG                       => System.Label.SFDC_SC_INVALID_SAVE_AS_ACTIVITY_FLAG,      //saveAsActivity フラグには true または false を指定します。
    StatusCode.WEBLINK_SIZE_LIMIT_EXCEEDED                         => System.Label.SFDC_SC_WEBLINK_SIZE_LIMIT_EXCEEDED,        //WebLink URL または JavaScript コードのサイズが制限を超えています。
    StatusCode.MAX_ACTIONS_PER_RULE_EXCEEDED                       => System.Label.SFDC_SC_MAX_APRE,                           //ルールあたりのアクション数の上限を超えました。
    StatusCode.TOO_MANY_ENUM_VALUE                                 => System.Label.SFDC_SC_TOO_MANY_ENUM_VALUE,                //複数選択リストに渡された値が多すぎるため、要求が失敗しました。複数選択リストでは 100 個の値まで選択できます。
    StatusCode.CUSTOM_ENTITY_OR_FIELD_LIMIT                        => System.Label.SFDC_SC_CUSTOM_ENTITY_OR_FIELD_LIMIT,       //組織のカスタムオブジェクトまたはカスタム項目の最大数に達しました。
    StatusCode.TEMPLATE_NOT_ACTIVE                                 => System.Label.SFDC_SC_TEMPLATE_NOT_ACTIVE,                //指定されたテンプレートが利用できません。別のテンプレートを指定するか、指定したテンプレートが利用できるようにします。
    StatusCode.INVALID_LINEITEM_CLONE_STATE                        => System.Label.SFDC_SC_INVALID_LINEITEM_CLONE_STATE,       //有効でない Pricebook2 または PricebookEntry レコードをコピーすることはできません。
    StatusCode.REQUIRED_FIELD_MISSING                              => System.Label.SFDC_SC_REQUIRED_FIELD_MISSING,             //このコールには項目が必要ですが指定されていません。
    StatusCode.INVALID_ARGUMENT_TYPE                               => System.Label.SFDC_SC_INVALID_ARGUMENT_TYPE,              //実行しようとする操作に対して不正な型の引数を指定しました。
    StatusCode.MAXIMUM_SIZE_OF_ATTACHMENT                          => System.Label.SFDC_SC_MAXIMUM_SIZE_OF_ATTACHMENT,         //添付ファイルのサイズの上限を超えました。
    StatusCode.CUSTOM_LINK_LIMIT_EXCEEDED                          => System.Label.SFDC_SC_CUSTOM_LINK_LIMIT_EXCEEDED,         //組織のカスタムリンクの最大数に達しました。
    StatusCode.REQUEST_RUNNING_TOO_LONG                            => System.Label.SFDC_SC_REQUEST_RUNNING_TOO_LONG,           //処理時間が長すぎる要求はキャンセルされます。
    StatusCode.CUSTOM_TAB_LIMIT_EXCEEDED                           => System.Label.SFDC_SC_CUSTOM_TAB_LIMIT_EXCEEDED,          //組織のカスタムタブの最大数に達しました。
    StatusCode.EMAIL_ADDRESS_BOUNCED                               => System.Label.SFDC_SC_EMAIL_ADDRESS_BOUNCED,              //メールが不達になった受信者が 1 人以上います。メールアドレスが有効であることを確認してくだい。
    StatusCode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY       => System.Label.SFDC_SC_IN_ACCESS_OCRE,                     //この操作は指定されたオブジェクトが相互参照しているオブジェクトに影響を与えますが、ログインユーザは相互参照しているオブジェクトに対する十分な権限がありません。たとえば、ログインユーザが取引先レコードを変更しようとして、その更新により ProcessInstanceWorkitem が作成されます。ユーザに ProcessInstanceWorkitem の承認、却下、再割り当て権限がない場合、この例外が発生します。
    StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION                   => System.Label.SFDC_SC_FIELD_FVE,                          //項目の整合性規則に違反することはできません。
    StatusCode.INVALID_ACCESS_LEVEL                                => System.Label.SFDC_SC_INVALID_ACCESS_LEVEL,               //指定された組織の共有設定よりアクセス権限の小さい共有ルールを新たに定義することはできません。
    StatusCode.NONUNIQUE_SHIPPING_ADDRESS                          => System.Label.SFDC_SC_NONUNIQUE_SHIPPING_ADDRESS,         //減額注文品目の納入先住所が元の注文の納入先住所と異なる場合、その減額注文品目は挿入できません。
    StatusCode.NO_INACTIVE_DIVISION_MEMBERS                        => System.Label.SFDC_SC_NO_INACTIVE_DIVISION_MEMBERS,       //無効なディビジョンにメンバーを追加することはできません。
    StatusCode.DUPLICATE_CASE_SOLUTION                             => System.Label.SFDC_SC_DUPLICATE_CASE_SOLUTION,            //指定されたケースとソリューションの関係がすでに存在するため、新たに作成することはできません。
    StatusCode.UNVERIFIED_SENDER_ADDRESS                           => System.Label.SFDC_SC_UNVERIFIED_SENDER_ADDRESS,          //sendEmail() コールが、OrgWideEmailAddress オブジェクトで定義された未検証のメールアドレスを使用しようとしました。
    StatusCode.ENVIRONMENT_HUB_MEMBERSHIP_CONFLICT                 => System.Label.SFDC_SC_ENV_HUB_MC,                         //複数の環境ハブに組織を追加することはできません。
    StatusCode.ENTITY_IS_DELETED                                   => System.Label.SFDC_SC_ENTITY_IS_DELETED,                  //削除されたオブジェクトは参照できません。この状況コードは、API バージョン 10.0 以降でのみ発生します。API の以前のリリースでは、このエラーに INVALID_ID_FIELD を使用しています。
    StatusCode.CANNOT_DEACTIVATE_DIVISION                          => System.Label.SFDC_SC_CANNOT_DEACTIVATE_DIVISION,         //割り当てルールがディビジョンを参照している場合、またはユーザレコードの DefaultDivision 項目が null 値に設定されていない場合は、ディビジョンを無効にできません。
    StatusCode.CUSTOM_SETTINGS_LIMIT_EXCEEDED                      => System.Label.SFDC_SC_CUSTOM_SETTINGS_LIMIT_EXCEEDED,     //組織のカスタム設定の最大制限に達しました。
    StatusCode.DEPENDENCY_EXISTS                                   => System.Label.SFDC_SC_DEPENDENCY_EXISTS,                  //指定されたオブジェクトまたは項目に連動関係が存在するため、要求された操作を実行できません。
    StatusCode.EMAIL_TEMPLATE_MERGEFIELD_ERROR                     => System.Label.SFDC_SC_EMAIL_TEMPLATE_MERGEFIELD_ERROR,    //1 つ以上の差し込み項目が存在しません。項目名のスペルをチェックしてください。
    StatusCode.INSERT_UPDATE_DELETE_NOT_ALLOWED_DURING_MAINTENANCE => System.Label.SFDC_SC_IUD_NOT_ADM,                        //バージョン 32.0 以降では、組織が含まれるインスタンスを最新リリースにアップグレードしている間は、データを作成、更新、削除できません。リリースが完了してから再度実行してください。リリーススケジュールについての詳細は、trust.salesforce.com を参照してください。バージョン 32.0 より前の場合、コードは INVALID_READ_ONLY_USER_DML になります。
    StatusCode.MAXIMUM_DASHBOARD_COMPONENTS_EXCEEDED               => System.Label.SFDC_SC_MAX_DASHBOARD_CE,                   //ダッシュボードのドキュメントサイズの制限を超えました。
    StatusCode.INVALID_CONTENT_TYPE                                => System.Label.SFDC_SC_INVALID_CONTENT_TYPE,               //送信メールの EmailFileAttachment の contentType プロパティが無効です。「RFC2045 - Internet Message Format」を参照してください。
    StatusCode.TEXT_DATA_OUTSIDE_SUPPORTED_CHARSET                 => System.Label.SFDC_SC_TEXT_DATA_OSC,                      //指定されたテキストがサポートされていない文字コードを使用しています。
    StatusCode.STRING_TOO_LONG                                     => System.Label.SFDC_SC_STRING_TOO_LONG,                    //指定された文字列は文字列長の上限を超えています。
    StatusCode.TRANSFER_REQUIRES_READ                              => System.Label.SFDC_SC_TRANSFER_REQUIRES_READ,             //ユーザに参照権限がないため、指定された User にレコードを割り当てることができません。
    StatusCode.DUPLICATE_MASTER_LABEL                              => System.Label.SFDC_SC_DUPLICATE_MASTER_LABEL,             //マスタ名が重複するカスタムオブジェクトやカスタム項目は作成できません。
    StatusCode.UNKNOWN_EXCEPTION                                   => System.Label.SFDC_SC_UNKNOWN_EXCEPTION,                  //システムで内部エラーが発生しました。この問題を Salesforce に報告してください。
    StatusCode.UNSPECIFIED_EMAIL_ADDRESS                           => System.Label.SFDC_SC_UNSPECIFIED_EMAIL_ADDRESS,          //指定されたユーザにはメールアドレスがありません。
    StatusCode.CANNOT_DELETE_MANAGED_OBJECT                        => System.Label.SFDC_SC_CANNOT_DELETE_MANAGED_OBJECT,       //管理パッケージに含まれているコンポーネントは変更できません。
    StatusCode.CANNOT_ENABLE_IP_RESTRICT_REQUESTS                  => System.Label.SFDC_SC_CANT_ENABLE_IP_RR,                  //プロファイルに指定されている 5 つの IP 範囲を超えている場合、IP アドレスによるログイン制限を有効にできません。プロファイルの指定範囲を減らして再度要求を実行してください。
    StatusCode.INVALID_FIELD                                       => System.Label.SFDC_SC_INVALID_FIELD,                      //レコードを更新または更新/挿入しようとしたときに無効な項目名を指定しました。
    StatusCode.INVALID_PERSON_ACCOUNT_OPERATION                    => System.Label.SFDC_SC_INVAILD_PAO,                        //個人取引先は削除できません。
    StatusCode.ENTITY_IS_LOCKED                                    => System.Label.SFDC_SC_ENTITY_IS_LOCKED,                   //承認プロセスでロックされているレコードは編集できません。
    StatusCode.CHILD_SHARE_FAILS_PARENT                            => System.Label.SFDC_SC_CHILD_SHARE_FAILS_PARENT,           //親レコードに対する適切な権限が付与されていない場合、子レコードの所有者の変更または子レコードの共有ルールの定義を行うことはできません。たとえば、取引先責任者レコードの所有者を変更するには、親の取引先レコードを編集する権限が必要です。
    StatusCode.ERROR_IN_MAILER                                     => System.Label.SFDC_SC_ERROR_IN_MAILER,                    //メールアドレスが無効であるか、メール関連のトランザクション中に別のエラーが発生しました。
    StatusCode.INVALID_TYPE_ON_FIELD_IN_RECORD                     => System.Label.SFDC_SC_INVALID_TYPE_ON_FIELD_IN_RECORD,    //指定された値が、指定された項目の型で有効ではありません。
    StatusCode.STORAGE_LIMIT_EXCEEDED                              => System.Label.SFDC_SC_STORAGE_LIMIT_EXCEEDED,             //組織のストレージ容量の制限を超えています。
    StatusCode.FAILED_ACTIVATION                                   => System.Label.SFDC_SC_FAILED_ACTIVATION,                  //Contract の有効化が失敗しました。
    StatusCode.BAD_CUSTOM_ENTITY_PARENT_DOMAIN                     => System.Label.SFDC_SC_BAD_CUSTOM_ENTITY_PARENT_DOMAIN,    //関連する主従関係への変更を適用できないため、この変更を完了できません。
    StatusCode.MAX_TM_RULES_EXCEEDED                               => System.Label.SFDC_SC_MAX_TM_RULES_EXCEEDED,              //Territory あたりのルール数の上限を超えました。
    StatusCode.LICENSE_LIMIT_EXCEEDED                              => System.Label.SFDC_SC_LICENSE_LIMIT_EXCEEDED,             //組織に割り当てられたライセンス数の上限を超えています。
    StatusCode.DUPLICATE_EXTERNAL_ID                               => System.Label.SFDC_SC_DUPLICATE_EXTERNAL_ID,              //ユーザが指定した外部 ID が更新/挿入で複数のレコードに一致しています。
    StatusCode.CANNOT_MODIFY_MANAGED_OBJECT                        => System.Label.SFDC_SC_CANNOT_MODIFY_MANAGED_OBJECT,       //管理パッケージに含まれているコンポーネントは変更できません。
    StatusCode.CANNOT_DELETE_LAST_DATED_CONVERSION_RATE            => System.Label.SFDC_SC_CANT_DELETE_LDC,                    //日付の入った換算が有効な場合、少なくとも 1 つの DatedConversionRate レコードが必要です。
    StatusCode.INVALID_CREDIT_CARD_INFO                            => System.Label.SFDC_SC_INVALID_CREDIT_CARD_INFO,           //指定されたクレジットカード情報が有効ではありません。
    StatusCode.INVALID_ASSIGNMENT_RULE                             => System.Label.SFDC_SC_INVALID_ASSIGNMENT_RULE,            //無効な割り当てルールまたは組織で定義されていない割り当てルールを指定しました。
    StatusCode.INACTIVE_OWNER_OR_USER                              => System.Label.SFDC_SC_INACTIVE_OWNER_OR_USER,             //指定されたデータの所有者が無効なユーザです。このデータを参照するには、所有者を再度有効化するか、別の有効なユーザに所有権を再度割り当てます。
    StatusCode.INVALID_TYPE                                        => System.Label.SFDC_SC_INVALID_TYPE,                       //指定された型が、指定されたオブジェクトで有効ではありません。
    StatusCode.DUPLICATE_CUSTOM_TAB_MOTIF                          => System.Label.SFDC_SC_DUPLICATE_CUSTOM_TAB_MOTIF,         //マスタ名が重複するカスタムオブジェクトやカスタム項目は作成できません。
    StatusCode.EMPTY_SCONTROL_FILE_NAME                            => System.Label.SFDC_SC_EMPTY_SCONTROL_FILE_NAME,           //Scontrol のファイル名が空ですが、バイナリが空ではありません。
    StatusCode.MAX_ACTIVE_RULES_EXCEEDED                           => System.Label.SFDC_SC_MAX_ACTIVE_RULES_EXCEEDED,          //有効なルール数の上限を超えました。
    StatusCode.INVALID_FIELD_WHEN_USING_TEMPLATE                   => System.Label.SFDC_SC_INVALID_FIELD_WHEN_USING_TEMPLATE,  //無効な項目名でメールテンプレートを使用することはできません。
    StatusCode.INVALID_STATUS                                      => System.Label.SFDC_SC_INVALID_STATUS,                     //指定された組織の状況変更が有効ではありません。
    StatusCode.CANNOT_RENAME_APEX_REFERENCED_FIELD                 => System.Label.SFDC_SC_CANT_RENAME_ARF,                    //Apex スクリプトで参照されている項目の名前は変更できません。
    StatusCode.DUPLICATES_DETECTED                                 => System.Label.SFDC_SC_DUPLICATES_DETECTED,                //重複レコードが検出されました。データ型が DuplicateError の Error オブジェクトに使用されます。
    StatusCode.EMAIL_NOT_PROCESSED_DUE_TO_PRIOR_ERROR              => System.Label.SFDC_SC_EMAIL_NOT_PDTPE,                    //これより以前にコールで発生したエラーにより、このメールは処理されませんでした。
    StatusCode.INVALID_CURRENCY_CONV_RATE                          => System.Label.SFDC_SC_INVALID_CURRENCY_CONV_RATE,         //通貨換算レートには、0 でない正の値を指定します。
    StatusCode.SINGLE_EMAIL_LIMIT_EXCEEDED                         => System.Label.SFDC_SC_SINGLE_EMAIL_LIMIT_EXCEEDED,        //(API バージョン 18.0 以降) 組織の個別メール送信の 1 日の上限を超えました。翌日になるまで個別メールメッセージは送信できません。
    StatusCode.CUSTOM_CLOB_FIELD_LIMIT_EXCEEDED                    => System.Label.SFDC_SC_CUSTOM_CFLE,                        //CLOB 項目の最大サイズを超えることはできません。
    StatusCode.INVALID_FIELD_FOR_INSERT_UPDATE                     => System.Label.SFDC_SC_INVALID_FIELD_FOR_INSERT_UPDATE,    //個人取引先レコードタイプの変更を、他の項目の更新と組み合わせることはできません。
    StatusCode.EMAIL_TEMPLATE_FORMULA_ERROR                        => System.Label.SFDC_SC_EMAIL_TEMPLATE_FORMULA_ERROR,       //メールテンプレートが無効か、表示不能です。テンプレートに不適切に指定された差し込み項目がないか確認してください。
    StatusCode.INVALID_SESSION_ID                                  => System.Label.SFDC_SC_INVALID_SESSION_ID,                 //指定された sessionId の形式が正しくないか (長さまたは形式が不正)、期限が切れています。再度ログインして新しいセッションを起動してください。
    StatusCode.SHARE_NEEDED_FOR_CHILD_OWNER                        => System.Label.SFDC_SC_SHARE_NEEDED_FOR_CHILD_OWNER,       //親レコードに共有ルールを必要とする子レコードがある場合、親レコードの共有ルールを削除できません。
    StatusCode.TERRITORY_REALIGN_IN_PROGRESS                       => System.Label.SFDC_SC_TERRITORY_REALIGN_IN_PROGRESS,      //テリトリーの再配置が進行中のため、この処理を実行できません。
    StatusCode.FILTERED_LOOKUP_LIMIT_EXCEEDED                      => System.Label.SFDC_SC_FILTERED_LOOKUP_LIMIT_EXCEEDED,     //オブジェクトごとに使用できるルックアップ検索条件の最大数を超えているため、ルックアップ検索条件の作成に失敗しました。
    StatusCode.IMAGE_TOO_LARGE                                     => System.Label.SFDC_SC_IMAGE_TOO_LARGE,                    //画像が幅、高さ、ファイルサイズの最大値を超えています。
    StatusCode.CANNOT_UPDATE_CONVERTED_LEAD                        => System.Label.SFDC_SC_CANNOT_UPDATE_CONVERTED_LEAD,       //取引開始済みのリードを更新できませんでした。
    StatusCode.COMMUNITY_NOT_ACCESSIBLE                            => System.Label.SFDC_SC_COMMUNITY_NOT_ACCESSIBLE,           //このエンティティが含まれるコミュニティへのアクセス権限がありません。このエンティティにアクセスする前に、コミュニティへのアクセス権限が必要です。
    StatusCode.UNAVAILABLE_RECORDTYPE_EXCEPTION                    => System.Label.SFDC_SC_UNA_RTPE,                           //適切なデフォルトのレコードタイプが見つかりませんでした。
    StatusCode.UNABLE_TO_LOCK_ROW                                  => System.Label.SFDC_SC_UNABLE_TO_LOCK_ROW,
    /*  デッドロックまたはタイムアウト条件が検出されました。
        デッドロックには、重なり合うオブジェクトセットを更新しようとする最低 2 つのトランザクションが関係しています。トランザクションに集計項目が含まれている場合、親オブジェクトがロックされるため、このようなトランザクションでは特にデッドロックが発生しやすくなります。デバッグするには、コード内のデッドロックを確認し修正してください。通常デッドロックは Salesforce 操作の問題から引き起こされる結果ではありません。
        タイムアウトは、選択リストの値の置き換えや、カスタム項目定義の変更など、完了までに時間がかかりすぎるトランザクションで発生します。タイムアウト状態は一時的です。修正アクションは不要です。
        バッチに含まれるオブジェクトをロックできない場合、バッチ全体でこのエラーが発生し失敗します。この状況コードのエラーでは、エラーメッセージにロックできないレコードの ID が含まれます (使用可能な場合)。
    */
   StatusCode.SELF_REFERENCE_FROM_TRIGGER                          => System.Label.SFDC_SC_SELF_REFERENCE_FROM_TRIGGER
   /*
        同じオブジェクトを Apex トリガで繰り返し更新または削除できません。このエラーは、次のような場合に多く発生します。
        オブジェクトを before トリガで更新または削除しようとした場合。
        オブジェクトを after トリガで削除しようとした場合。
        このエラーは直接操作または間接操作のいずれでも発生します。次に、間接操作の例を示します。

        オブジェクト A を更新する要求が送信されました。
        オブジェクト A の before update トリガがオブジェクト B を作成します。
        オブジェクト A が更新されます。
        オブジェクト B の after insert トリガがオブジェクト A にクエリを実行し、更新します。これはオブジェクト A の before トリガとなり、オブジェクト A の間接更新となるためエラーが生成されます。
    */
  };

  global static String getMessageText(System.StatusCode code) {
    if (SYSTEM_STATUSCODES.containsKey(code)) {
      return SYSTEM_STATUSCODES.get(code);
    }
    else {
      return '';
    }
  }

}