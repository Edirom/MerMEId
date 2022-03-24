package mermeid;


import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;

import java.time.Duration;
import java.util.ArrayList;
import java.util.Random;
import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.assertTrue;


@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class MermeidTest extends WebDriverSettings {
    public void enterLogin(){
        driver.get("http://localhost:8080/modules/list_files.xq");

        driver.findElement(By.id("login-info")).click();
        driver.findElement(By.id("login-modal")).click();

        driver.findElement(By.name("user")).sendKeys("mermeid");
        driver.findElement(By.name("password")).sendKeys("mermeid");

        driver.findElement(By.name("remember")).click();
        driver.findElement(By.cssSelector(".submit")).click();

        //get login name
        String loginUser = driver.findElement(By.id("login-info")).getText();
        assertTrue(loginUser.equals("mermeid"));
    }
    @Test
    @Order(1)
    public void OpenEditPage(){

        String title = driver.getTitle();
        System.out.println("Title: " + title);
        assertTrue(title.equals("MerMEId – Metadata Editor and Repository for MEI Data"));

        WebElement button = driver.findElement(By.cssSelector("button"));
        String buttonText = button.getText();
        System.out.print("Test log: ");
        System.out.println(buttonText);


        assertTrue(buttonText.equals("Try MerMEId"));


        enterLogin();
        WebElement edit = driver.findElement(By.cssSelector("[href=\"../forms/edit-work-case.xml?doc=incipit_demo.xml\"]"));
        edit.click();

    }

    public void setText(ArrayList<String> ids, String text ){

        for (String id: ids) {
            try {
                Thread.sleep(3000);
                WebElement inputTextElement = driver.findElement(By.id(id));
                inputTextElement.clear();
                inputTextElement.sendKeys(text);
                inputTextElement.sendKeys(Keys.RETURN);
            } catch(InterruptedException e) {
                System.out.print("Test log: ");
                System.out.println("got interrupted!");
            }
        }
    }

    public void clickButton(ArrayList<String> ids){
        for (String id: ids) {
            try {
                //WebElement element = driver.findElement(By.cssSelector("#xf-293 > a > img"));
                WebElement element = driver.findElement(By.xpath("//*[@id=\"xf-293\"]/a/img"));
                Actions builder = new Actions(driver);
                builder.moveToElement(element).pause(500);
                builder.moveToElement(element).perform();

                Thread.sleep(3000);
                driver.findElement(By.cssSelector(id)).click();

            } catch(InterruptedException e) {
                System.out.print("Test log: ");
                System.out.println("got interrupted!");
            }
            catch(NoSuchElementException e){
                System.out.print("Test log: ");
                System.out.println("No Element with id: " +id);
                assertTrue(false);
            }

        }
    }

    public void checkText(ArrayList<String> ids, String expected_text ){
        for (String id: ids) {

            try{
                //checkTitle
                WebElement input_title = driver.findElement(By.id(id));
                String text =input_title.getAttribute("value");
                System.out.print("Test log: ");
                System.out.println("Expected Text: " + expected_text);
                System.out.print("Test log: ");
                System.out.println("Current Text: " + text);
                assertTrue(text.equals(expected_text));
            }
            catch(NoSuchElementException e){
                System.out.print("Test log: ");
                System.out.println("No Element with id: " +id);
                assertTrue(false);
            }


        }

    }

    @Test
    @Order(2)
    public void checkWorkTabInputText(){
        enterLogin();
        WebElement edit = driver.findElement(By.cssSelector("[href=\"../forms/edit-work-case.xml?doc=incipit_demo.xml\"]"));
        edit.click();

        // driver.findElement(By.id("work-tab")).click();


        String randomString = generatingRandomAlphabeticString();

        //ids for input text
        ArrayList<String> ids = new ArrayList<String>();
        //main title
        ids.add("xf-216≡xforms-input-1⊙1");
        //list name
        ids.add("xf-301≡xforms-input-1⊙1");
        //name
        ids.add("xf-309≡xf-2011≡xforms-input-1⊙1");
        //work notes label
        ids.add("xf-370≡xforms-input-1⊙1");



        setText(ids, randomString );

        try {
            Thread.sleep(3000);
            driver.findElement(By.id("save-button-image")).click();
            Thread.sleep(3000);
            driver.findElement(By.id("home-button-image")).click();


        } catch(InterruptedException e) {
            System.out.print("Test log: ");
            System.out.println("got interrupted!");
        }


        //open edit view
        driver.get("http://localhost:8080/modules/list_files.xq");
        edit = driver.findElement(By.cssSelector("[href=\"../forms/edit-work-case.xml?doc=incipit_demo.xml\"]"));
        edit.click();

        //check changes
        checkText(ids, randomString);


    }

    @Test
    @Order(3)
    public void checkWorkTabPopupInputText(){
        String randomString = generatingRandomAlphabeticString();

        enterLogin();
        WebElement edit = driver.findElement(By.cssSelector("[href=\"../forms/edit-work-case.xml?doc=incipit_demo.xml\"]"));
        edit.click();

        //ids for input text
        ArrayList<String> button_ids = new ArrayList<String>();
        //alternative title
        button_ids.add("#xf-294≡xf-1468≡≡c");
        //subtitle
        button_ids.add("#xf-295≡xf-1519≡≡c");
        //uniform title
        button_ids.add("#xf-296≡xf-1570≡≡c");
        //origanal title
        button_ids.add("#xf-297≡xf-1621≡≡c");
        //title of sourcecode
        button_ids.add("#xf-298≡xf-1672≡≡c");

        clickButton(button_ids);


        //ids for input text
        ArrayList<String> ids = new ArrayList<String>();
        //alternative title
        ids.add("xf-229≡xforms-input-1⊙1");
        //subtitle
        ids.add("xf-242≡xforms-input-1⊙1");
        //uniform title
        ids.add("xf-255≡xforms-input-1⊙1");
        //origanal title
        ids.add("xf-268≡xforms-input-1⊙1");
        //title of sourcecode
        ids.add("xf-281≡xforms-input-1⊙1");

        setText(ids, randomString );



        //save changes
        driver.findElement(By.id("save-button-image")).click();
        driver.findElement(By.id("home-button-image")).click();


        //open edit view
        driver.get("http://localhost:8080/modules/list_files.xq");
        edit = driver.findElement(By.cssSelector("[href=\"../forms/edit-work-case.xml?doc=incipit_demo.xml\"]"));
        edit.click();

        //check changes
        checkText(ids, randomString);

    }

    public String generatingRandomAlphabeticString() {
        int leftLimit = 97; // letter 'a'
        int rightLimit = 122; // letter 'z'
        int targetStringLength = 10;
        Random random = new Random();

        String generatedString = random.ints(leftLimit, rightLimit + 1)
                .limit(targetStringLength)
                .collect(StringBuilder::new, StringBuilder::appendCodePoint, StringBuilder::append)
                .toString();

        return generatedString;
    }

   /* @Test
    public void firstTest(){
        driver.get("http://localhost:8080/index.html");
        String title = driver.getTitle();
        Assert.assertTrue(title.equals("MerMEId – Metadata Editor and Repository for MEI Data"));
    }
    @Test
    public void clickTryMermeid(){
        driver.get("http://localhost:8080/index.html");
        WebElement button = driver.findElement(By.cssSelector("button"));
        String buttonText = button.getText();
        System.out.println(buttonText);
        Assert.assertTrue(buttonText.equals("Try MerMEId"));
        button.click();

    }
    @Test
    public void enterLogin(){
        driver.get("http://localhost:8080/index.html");
        WebElement button = driver.findElement(By.cssSelector("button"));
        button.click();

        driver.findElement(By.id("user")).sendKeys("mermeid");
        driver.findElement(By.id("password")).sendKeys("mermeid");

        WebElement submit = driver.findElement(By.cssSelector("button"));
        submit.click();


    }*/
  /*  public static void main(String[] args) {
        System.setProperty("webdriver.chrome.driver", "/Users/olina/Downloads/chromedriver");
        WebDriver driver = new ChromeDriver();
        driver.manage().window().maximize();
        driver.get("http://localhost:8080/index.html");
        System.out.println(driver.getTitle());

        driver.quit();
    }*/
}
