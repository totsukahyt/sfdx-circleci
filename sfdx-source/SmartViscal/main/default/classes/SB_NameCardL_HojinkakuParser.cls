/**
 *
 * SB_NameCardL_HojinkakuParser
 *  法人格をパースするクラス
 *  
 **/
public with sharing class SB_NameCardL_HojinkakuParser {

    //  略のある法人格 System.Label.SB_NCL_HojinKakuPairs
    // 1つの正式名称が1つ以上の略称になる もののうち、複数の正式名称が1つの略称を共有するものを除く
    // 株式会社, 株, ㈱
    // 有限会社, 有, ㈲
    // 合名会社, 名, ㈴
    // 合資会社, 資, ㈾
    // 合同会社, 同, 合同
    // 学校法人, 学, ㈻
    // 社団法人, 社, ㈳
    // 特殊法人, 特, ㈵
    // 財団法人, 財, ㈶
    // 監査法人, 監, 監法, ㈼
    // 企業組合, 企, ㈽
    // 協同組合, 協, ㈿
    // 労働組合, 労, ㈸
    // 一般社団法人, 一社
    // 一般財団法人, 一財
    // 公益社団法人, 公社
    // 公益財団法人, 公財
    // 独立行政法人, 独
    // 地方独立行政法人, 地独
    // 特定非営利活動法人, 特非, 特定
    // 宗教法人, 宗
    // 相互会社, 相
    // 社会福祉法人, 福
    // 弁護士法人, 弁, 弁法
    // 行政書士法人, 行
    // 司法書士法人, 司
    // 税理士法人, 税, 税法
    
    //System.Label.SB_NCL_HojinkakuDuplicate
    // 複数の正式名称が1つの略称を共有するもの
    // 医療法人, 医療法人社団, 医療法人財団, 社会医療法人  のそれぞれを (医)と同一視
    // 複数の正式名称が１つの略称になるもの
    // private static final String DUPLICTE_RYAKUSHO = '医:医療法人, 医療法人社団, 医療法人財団, 社会医療法人
    // 大:国立大学法人, 公立大学法人
    // 国法:国立大学法人
    // 中:有限責任中間法人, 無限責任中間法人';
    
      @TestVisible
      private static Map<String, Integer> hojinkaku2id {  // 法人格文字列 - 識別子
        get {
          if (hojinkaku2id == null) {
            // 法人格文字列 - 識別子
            hojinkaku2id = new Map<String, Integer>();
            String[] lines = System.Label.SB_NCL_HojinKakuPairs.split('\\r\\n|\\n|\\r');
            for (Integer n=0; n < lines.size(); n++) {
              String[] mojis = lines.get(n).split(',\\s*');
              for (String moji : mojis) {
                hojinkaku2id.put(moji, n);   // 法人格文字列 - 識別子
                System.debug(LoggingLevel.DEBUG, moji + n);
              }
            }
          }
          return hojinkaku2id;
        }
        private set;
      }
    
      public static Integer getHojinkakuId(String kaku) {
        if (String.isBlank(kaku)) {
          return -1;
        }
        if (!hojinkaku2id.containsKey(kaku)) {
          return -1;
        }
        return hojinkaku2id.get(kaku);
      }
    
      // private static final String HOJIN_REGEX0 =
      // (?:株式会社|有限会社|合名会社|合資会社|合同会社|学校法人|特殊法人|監査法人|企業組合|協同組合|労働組合|医療法人社団|医療法人財団|社会医療法人|特定医療法人|医療法人|一般社団法人|公益社団法人|社団法人|一般財団法人|公益財団法人|財団法人|社会福祉法人|更生保護法人|独立行政法人|地方独立行政法人|特定非営利活動法人|宗教法人|相互会社|社会福祉法人|弁護士法人|行政書士法人|司法書士法人|税理士法人|国立大学法人|公立大学法人|有限責任中間法人|無限責任中間法人|(?:[(（](?:[株有名資同学社特財監企協労医独宗相福弁行司税大中]|一社|一財|公社|公財|地独|特非|弁法|税法|国法)[）)])|[㈱㈲㈴㈾㈻㈳㈵㈶㈼㈽㈿㈸]);
      // private static final String HOJIN_REGEX = '(^' + HOJIN_REGEX0 + '[\\s　]*)(.+$)' + '|' + '(^.+)(' + HOJIN_REGEX0 + '$)';
      // SB_NC_HojinKakuRegexFormat → (^{0}[\\\s　]*)(.+$)|(^.+?)({0}$)  カスタム表示ラベルにして \\s だと s を拾ってしまうので \\\s にしてます。  後格のとき、余計にとらないように(^.+?) で ? つき
    
      private static Pattern hojinPattern  {
        get {
          if (hojinPattern == null) {
            hojinPattern = Pattern.compile(String.format(System.Label.SB_NCL_HojinKakuRegexFormat, new String[] { System.Label.SB_NCL_HojinKakuRegex }));
          }
          return hojinPattern;
        }
        private set;
      }
    
      // 会社名を法人格と社名にパース
      //   確認用に public で
      //  4つの要素のリストでかえす。
      // 前格の場合、法人格(空白),社名,null,null
      // 後格の場合、null,null,社名(空白),法人格
      public static List<String> regexKaishamei(String kaishamei) {
        List<String> result;
        Matcher m = hojinPattern.matcher(kaishamei.trim());
        if (m.find()) { 
          result = new List<String>();
          for (Integer j = 1; j <= m.groupCount(); j++) {
            if (String.isNotBlank(m.group(j))) {
              result.add(m.group(j).trim().replaceAll('[\\s　]*$', '')); // 前格の後の半角空白、全角空白、後格の場合の社名のあとの半角空白、全角空白は１つになってるので除去、念の為trim
            }
            else {
              result.add(m.group(j));
            }
          }
        }
        return result;
      }
    
      private String fullname;
      private String kaku;
      private String shamei;
      private Integer kakuIchi; // -1: 格なし、0:前格 1:後格
      private Integer kakuId;  // 法人格の識別子 略がないか、格ナシは -1
      public SB_NameCardL_HojinkakuParser(String kaishamei) {
        this.fullname = kaishamei;
        this.kakuId = -1;
        List<String> texts = regexKaishamei(kaishamei);
        if (texts == null || texts.size() != 4) {
          // 格なし
          this.kakuId = -1;
          this.shamei = kaishamei;
        } 
        else {
          this.kakuIchi = texts[0]!=null ? 0 : 1;
          if (this.kakuIchi == 0) { // 前格
            // this.kaku = texts[0].replaceAll('^[(（]', '').replaceAll('[)）]$', '')  // 前後の丸括弧1文字は除去
            this.kaku = texts[0].replaceAll('[()（）]', ''); // 格についてる丸括弧はとっておく 取り出した法人格ではあっても前後に1文字づつ getHojinkakuId の中は （）　なしでみる
            this.shamei = texts[1]; // 社名
          }
          else {  // 後格
            this.shamei = texts[2]; // 社名
            this.kaku = texts[3].replaceAll('[()（）]', '');
          }
          this.kakuId = getHojinkakuId(this.kaku);
        } 
      }
    
      public Boolean isEqual(String kaishamei) {
        return this.fullname == kaishamei || isEqual(new SB_NameCardL_HojinkakuParser(kaishamei));
      }
    
      public Boolean isEqual(SB_NameCardL_HojinkakuParser sha) {
        System.debug(this.kakuIchi == sha.kakuIchi);
        System.debug(this.kakuId == sha.kakuId);
        System.debug(this.shamei == sha.shamei);
        System.debug(this.kakuId != -1);
        return this.kakuIchi == sha.kakuIchi && this.kakuId == sha.kakuId && this.shamei == sha.shamei &&
          (this.kakuId != -1 || this.kaku == sha.kaku || isEqualDuplicateRyakusho(sha.kaku));  // どれでもなかったら、最後、医療法人等の略称共有型について調べる
      }
     
      // 複数の正式名称が1つの略称を共有するもの   そのタイプの正式名称は 1つの正式名称が1つ以上の略称になる こともこちらで対応（例：国立大学法人）
      // SB_NC_HojinkakuDuplicate
      // 大:国立大学法人, 公立大学法人
      // 国法:国立大学法人
      // 中:有限責任中間法人, 無限責任中間法人  
      // 医:医療法人, 医療法人社団, 医療法人財団, 社会医療法人
      // 特定医療法人 の略は (医) でない。らしい。
      private static Map<String, Set<String>> ryaku2longs {  // 略称 - 正式名称s
        get {
          if (ryaku2longs == null) {
            ryaku2longs = new Map<String, Set<String>>();
            // String[] lines = DUPLICTE_RYAKUSHO.split('\\r\\n|\\n|\\r');
            String[] lines = System.Label.SB_NCL_HojinkakuDuplicate.split('\\r\\n|\\n|\\r');
            for (String line : lines) {
              String[] pair = line.trim().split(':\\s*');
              if (pair.size() == 2) { // 一応、調べる。
                Set<String> longs = new Set<String>();
                String[] ll = pair[1].trim().split(',\\s*');
                for (String l : ll) {
                  longs.add(l);
                }
                ryaku2longs.put(pair[0].trim(), longs);
              }
            }
          }
          return ryaku2longs;
        }
        private set;
      }
      
      // 複数の正式名称が１つの略称になるタイプのを調べる
      private Boolean isEqualDuplicateRyakusho(String kaku) {
        if (ryaku2longs.containsKey(this.kaku)) {
          // こっちのが略称であった
          return ryaku2longs.get(this.kaku).contains(kaku);
        }
        else if (ryaku2longs.containsKey(kaku)) {
          // そっちのが略称であった
          return ryaku2longs.get(kaku).contains(this.kaku);
        }
        // その略称はなかった
        return false;
      }
    
    
      public static Boolean isEqualeKaishamei(String a, String b) {
        if (a==b) {
          return true;
        }
        SB_NameCardL_HojinkakuParser k_a = new SB_NameCardL_HojinkakuParser(a);
        SB_NameCardL_HojinkakuParser k_b = new SB_NameCardL_HojinkakuParser(b);
        return k_a.isEqual(k_b);
      }
    
    }