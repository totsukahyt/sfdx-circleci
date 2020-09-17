'use strict'

// 提供済みのものをそのまま利用しています。
// SEE: https://github.com/sunbridge-code/smartvisca-camera-http-sample/blob/master/force-app/main/default/components/SB_NC_Service.component
//
// NcService  HTTP通信するAPIごとの関数
window.NcService = (function () {

  // サーバの処理でのエラー情報を取得する
  var getErrorMessage = function (data) {
    if (!data) return [{ error_code: '-1', description: '通信エラー' }]    // "通信エラー"
    var result = []
    $(data.getElementsByTagName('errors')).each(function () {
      var error = {}
      error['error_code'] = $(this).find('error_code').text()
      error['description'] = $(this).find('description').text()
      result.push(error)
    })
    return result
  }

  return {
    sendScanLotData: sendScanLotData,    // 所有者利用可判定
    sendCardData: sendCardData,          // 名刺データ受信＆転送 表面送信
    sendBackCardData: sendBackCardData,  // 名刺データ受信＆転送 裏面送信
    sendEnd: sendEnd                     // 名刺データ受信＆転送 送信終了
  }

  // 基本情報送信 名刺送信開始
  // セッションID をもとに認証して、クッキー、送信IDを取得する。
  function sendScanLotData (inputs, options, callbackSuccess, callbackFailure) {
    var deferred = $.Deferred() // deferオブジェクト生成
    var values = {
      'service_id': options.sSmartViscaServeServiceID,     // サービスID Sunbridge用
      'service_client_id': (options.devMode ? 'DEV_' : 'PAID_') + options.sOrgId,   // お客様システムの利用企業ID SFDC葬式IDを送って識別
      'service_division_id': '0_' + options.sSessionId,   // お客様システムの利用企業の部署ID S1では、セッションIDを送る
      'service_user_id': inputs.ownerId ? inputs.ownerId : options.sUserId,                 // 名刺の所有者するユーザID 2017.10.xx v1.21
      'list_name': inputs.list_name,    //リスト名
      'scanner_name': options.sScannerName,   // スキャナー名(空文字不可 100文字以内)
      'card_count': inputs.card_count,        //これからスキャン送信する枚数
      'open_flag': 0,         // 公開フラグ                          0：未設定、1：公開、2：非公開
      'freehandmemo_flag': inputs.freehandmemo_flag, // 手書きメモをデジタル化するか指示       0：しない 1：する
      'digitalize_mode': 9,   // デジタル化モード                         0：OCRのみ、1：基本項目、9：全項目
      'past_card_flag': 0,    // 過去名刺フラグ                          0：通常、1：過去名刺、NULL：通常
      'env_machine_name': options.sSfdcEndPoint,  // Salesforce SOAPのエンドポイントURL 本来はスキャンを実行したPCのコンピューター名
      'env_user_name': options.userName,          // スキャンを実行した人のログイン名
      'env_local_ip_address': options.sClinetIPAddress,     // スキャンを実行したPCのローカルIP ないとエラーになる
      'env_scan_user_id': options.sUserId,        // スキャン送信者ID スキャンしたユーザID 必須。
      'scan_app_option': 'app=SmartViscaCamera' + (inputs.svcFrontOnly ? ',English' : '')     // undocumented
    }
    // 追加のパラメータ セッションCookieが無効な環境用 のパラメータ proxy_flag = 1 とか
    if (options.sSmartViscaServerOptions) {
      $.each(options.sSmartViscaServerOptions, function (key, value) {
        values[key] = value
      })
    }

    var serverApi = options.sSmartViscaServer + '/' + (options.devMode ? 'rego_dev/' : 'rego_paid/')
      + 'scan/SUNBRIDGE/sendscanlotdata/'
    $.ajax({
      type: 'POST',
      url: serverApi,
      data: $.param(values),
      traditional: true,
      xhrFields: {
        withCredentials: true
      },
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    })
      .done(function (data, textStatus, jqXHR) {
        var send = $(data.getElementsByTagName('send'))
        var session = $(data.getElementsByTagName('session'))
        if (send && session && send.length > 0 && session.length > 0) {
          inputs['regoSessionId'] = session.attr('value')
          inputs['send_id'] = send.attr('id')
          deferred.resolve()
        } else {
          // 401: 組織IDが登録されていません とかのエラー
          var errors = getErrorMessage(data)
          deferred.reject(errors[0])
        }
      })
      .fail(function (jqXHR, textStatus, errorThrown) {
        deferred.reject({ error_code: jqXHR.status, description: jqXHR.statusText })
      })

    return deferred
  }

  // 表面送信  表面画像を送信して、名刺IDを受ける。
  function sendCardData (inputs, card, options, callbackSuccess, callbackFailure) {
    var deferred = $.Deferred() // deferオブジェクト生成
    var fd = new FormData()
    fd.append('service_id', options.sSmartViscaServeServiceID)
    fd.append('send_id', inputs.send_id) //送信ID 基本情報送信時に返されたID
    fd.append('memo', card.memo)                //スキャン送信されたメモ内容
    fd.append('card_exchange_date', card.date)   //スキャン送信された名刺交換日
    // 追加のパラメータ セッションCookieが無効な環境用 のパラメータ proxy_flag = 1 とか service_id　= SFDCAPEXとか
    if (options.sSmartViscaServerOptions) {
      $.each(options.sSmartViscaServerOptions, function (key, value) {
        fd.append(key, value)
      })
    }
    // 表面画像データ
    // 縮小した画像を送る ↓
    fd.append('card_file1', card.front.blob, card.front.name)
    console.log(card.front.name)
    var serverApi = options.sSmartViscaServer + '/' + (options.devMode ? 'rego_dev/' : 'rego_paid/')
      + 'scan/SUNBRIDGE/sendcarddata/'
    $.ajax({
      type: 'POST',
      url: serverApi,
      processData: false,
      contentType: false,
      data: fd,
      traditional: true,
      xhrFields: {
        withCredentials: true,
      },
      headers: {
        'Content-Type': undefined,      // Content-Type:multipart/form-data; になる
        'Cookie': 'REGOSESSID=' + inputs.regoSessionId // Cookie をセットします。
      }
    })
      .done(function (data, textStatus, jqXHR) {
        var res = $(data.getElementsByTagName('card'))
        if (res && res.length > 0) {
          console.log(res.attr('id'))
          card['card_id'] = res.attr('id')
          card['result'] = card['result'] + 1
          deferred.resolve()
        } else {
          var errors = getErrorMessage(data)
          deferred.reject(errors[0])
        }
      })
      .fail(function (jqXHR, textStatus, errorThrown) {
        // サーバでCookieのREGOSESSID を受け取れないと、500 Internal Server Error になります。
        deferred.reject({ error_code: jqXHR.status, description: jqXHR.statusText })
      })
    return deferred
  }

  // 裏面送信
  function sendBackCardData (inputs, card, options, callbackSuccess, callbackFailure) {
    var deferred = $.Deferred() // deferオブジェクト生成
    var fd = new FormData()
    fd.append('send_id', inputs.send_id) //送信ID
    fd.append('card_id', card.card_id) // 名刺ID 名刺表面送信で取得した名刺ＩＤ
    // 追加のパラメータ セッションCookieが無効な環境用 のパラメータ proxy_flag = 1 とか
    if (options.sSmartViscaServerOptions) {
      $.each(options.sSmartViscaServerOptions, function (key, value) {
        fd.append(key, value)
      })
    }
    if (card.back) {
      fd.append('card_file2', card.back.blob, card.back.name)
    }

    console.log(card.back ? card.back.name : 'none')
    var serverApi = options.sSmartViscaServer + '/' + (options.devMode ? 'rego_dev/' : 'rego_paid/')
      + 'scan/SUNBRIDGE/sendbackcarddata/'
    $.ajax({
      type: 'POST',
      url: serverApi,
      processData: false,
      contentType: false,
      data: fd,
      traditional: true,
      xhrFields: {
        withCredentials: true
      },
      headers: {
        'Content-Type': undefined,      // Content-Type:multipart/form-data; になる
        'Cookie': 'REGOSESSID=' + inputs.regoSessionId
      }
    })
      .done(function (data, textStatus, jqXHR) {
        var res = $(data.getElementsByTagName('card'))
        if (res && res.length > 0) {
          console.log(res.attr('id'))
          card['card_id'] = res.attr('id')
          card['result'] = card['result'] + 2
          deferred.resolve()
        } else {
          var errors = getErrorMessage(data)
          deferred.reject(errors[0])
        }
      })
      .fail(function (jqXHR, textStatus, errorThrown) {
        deferred.reject({ error_code: jqXHR.status, description: jqXHR.statusText })
      })

    return deferred
  }

  // 送信終了
  function sendEnd (inputs, options, callbackSuccess, callbackFailure) {
    var deferred = $.Deferred() // deferオブジェクト生成
    var values = {
      'card_count': inputs.card_count,        // 送信した枚数（エラー終了の場合は0）
      'send_id': inputs.send_id
    }
    // 追加のパラメータ セッションCookieが無効な環境用 のパラメータ proxy_flag = 1 とか
    if (options.sSmartViscaServerOptions) {
      $.each(options.sSmartViscaServerOptions, function (key, value) {
        values[key] = value
      })
    }

    var serverApi = options.sSmartViscaServer + '/' + (options.devMode ? 'rego_dev/' : 'rego_paid/')
      + 'scan/SUNBRIDGE/sendend/'
    $.ajax({
      type: 'POST',
      url: serverApi,
      data: $.param(values),
      traditional: true,
      xhrFields: {
        withCredentials: true
      },
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    })
      .done(function (data, textStatus, jqXHR) {
        var send = $(data.getElementsByTagName('send'))
        var finish_code = $(data.getElementsByTagName('finish_code'))
        if (send && finish_code && send.length > 0) {
          console.log(finish_code.text())
          console.log(send.attr('id'))
          console.log(send.attr('count'))
          deferred.resolve({
            finish_code: finish_code.text(),
            send_id: send.attr('id'),
            send_count: send.attr('count')
          })
        } else {
          var errors = getErrorMessage(data)
          deferred.reject(errors[0])
        }
      })
      .fail(function (jqXHR, textStatus, errorThrown) {
        deferred.reject({ error_code: jqXHR.status, description: jqXHR.statusText })
      })
    return deferred
  }

})()
