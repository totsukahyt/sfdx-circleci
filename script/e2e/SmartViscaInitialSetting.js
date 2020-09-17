require("chromedriver");
require("date-utils");
const path = require("path")
const webdriver =  require("selenium-webdriver");
const { Builder, By, until } = webdriver;
var chrome = require('selenium-webdriver/chrome');
const fs = require('fs');
var LOGIN_INFO
var options   = new chrome.Options().addArguments('--headless').addArguments('--disable-gpu').addArguments('--no-sandbox').addArguments('--window-size=1024x768');


let driver;
let iframe;
const npw = "sohoTest1"

describe("SeleniumChromeTest", () => {
  before(() => {
    driver = new Builder().forBrowser('chrome').withCapabilities(options).build();
    LOGIN_INFO = fs.readFileSync(path.join(process.cwd(), "qa_UserPassword.json"))
    LOGIN_INFO = JSON.parse(LOGIN_INFO).result
  });

  after(() => {
    return driver.quit();
  });

  it("フィード追跡", async () => {
    let url = LOGIN_INFO.instanceUrl+"/secur/frontdoor.jsp?sid="+LOGIN_INFO.accessToken
    await driver.get(url);
    let shareUrl = LOGIN_INFO.instanceUrl + "/lightning/setup/FeedTracking/home";
    await driver.get(shareUrl)

    await driver.wait(until.elementLocated(By.xpath('//*[@id="setupComponent"]/div[2]/div/force-aloha-page/div/iframe')),10000)
    iframe = await driver.findElement(By.xpath('//*[@id="setupComponent"]/div[2]/div/force-aloha-page/div/iframe'))
    await driver.switchTo().frame(iframe);

    await driver.wait(until.elementsLocated(By.xpath('//a[@title="NameCard"]')),10000)
    await driver.findElement(By.xpath('//a[@title="NameCard"]')).click()
    await driver.wait(until.elementsLocated(By.xpath('//input[@id="j_id0:j_id7:toolbarTop:j_id32:enableTracking"]')),5000)
    const checkbox = await driver.findElement(By.xpath('//input[@id="j_id0:j_id7:toolbarTop:j_id32:enableTracking"]'))
    const isCheck = await checkbox.getAttribute("checked")
    if(!isCheck ||isCheck === null){
      await checkbox.click()
      console.log("有効化")
      await driver.findElement(By.xpath('//input[@value="保存"]')).click()
    }
  })

  it("ページレイアウト", async () => {
    let layoutUrl = LOGIN_INFO.instanceUrl + "/lightning/setup/ObjectManager/home";
    await driver.get(layoutUrl)
    await driver.sleep(3000)
    await driver.wait(until.elementLocated(By.xpath('//a[text()="名刺"]')),10000)
    await driver.findElement(By.xpath('//a[text()="名刺"]')).click()
    await driver.wait(until.elementLocated(By.xpath('//a[text()="ページレイアウト"]')),10000)
    await driver.findElement(By.xpath('//a[text()="ページレイアウト"]')).click()
    await driver.sleep(1000)
    await driver.wait(until.elementLocated(By.xpath('//button[text()="ページレイアウトの割り当て"]')),10000)
    await driver.findElement(By.xpath('//button[text()="ページレイアウトの割り当て"]')).click()

    await driver.wait(until.elementLocated(By.xpath('//*[@id="setupComponent"]/div/div/force-aloha-page/div/iframe')),10000)
    iframe = await driver.findElement(By.xpath('//*[@id="setupComponent"]/div/div/force-aloha-page/div/iframe'))

    await driver.switchTo().frame(iframe)

    await driver.wait(until.elementLocated(By.xpath('//input[@value="割り当ての編集"]')),10000)
    await driver.findElement(By.xpath('//input[@value="割り当ての編集"]')).click()
    await driver.sleep(5000)

    

    await driver.wait(until.elementLocated(By.xpath('//td[text()="標準ユーザ"]')),10000)
    await driver.findElement(By.xpath('//td[text()="標準ユーザ"]')).click()

    await driver.wait(until.elementLocated(By.xpath('//select[@id="pageLayoutSelector"]')),10000)
    driver.executeScript("document.getElementById('pageLayoutSelector').options[1].selected=true;");
    await driver.findElement(By.xpath('//input[@value=" 保存 "]')).click()
    

  })
});
