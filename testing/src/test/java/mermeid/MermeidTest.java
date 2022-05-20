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
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.support.ui.ExpectedConditions;

import java.time.Duration;
import java.util.ArrayList;
import java.util.Random;


import static org.junit.jupiter.api.Assertions.assertTrue;


@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class MermeidTest extends WebDriverSettings {


    public void enterLogin(){
        String loginText = "";
        String loginUser = "mermeid";
        String loginPass = "mermeid";
        driver.get("http://localhost:8080/modules/list_files.xq");

        try {
            loginText = driver.findElement(By.id("login-info")).getText();
            System.out.println("Test log: login name -" +loginText);

            driver.findElement(By.id("login-info")).click();
            driver.findElement(By.id("login-modal")).click();

            driver.findElement(By.name("user")).sendKeys(loginUser);
            driver.findElement(By.name("password")).sendKeys(loginPass);

            //driver.findElement(By.name("remember")).click();
            driver.findElement(By.cssSelector(".submit")).click();

            // check login name
            new WebDriverWait(driver, Duration.ofSeconds(3)).until(ExpectedConditions.textToBe(By.id("login-info"), loginUser));
        } catch(org.openqa.selenium.TimeoutException e) {
            System.out.print("Test log: ");
            System.out.println("Timed out waiting for element 'login-info'!");
        }
        catch(NoSuchElementException e){
            assertTrue(false);
        }
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
        WebElement editButton = driver.findElement(By.xpath("//form[@action='http://localhost:8080/forms/edit-work-case.xml'][input/@value='incipit_demo.xml']/button"));
        editButton.click();
    }

    public void setText(ArrayList<String> ids, String text ){
        for (String id: ids) {
            try {
                WebElement inputTextElement = new WebDriverWait(driver, Duration.ofSeconds(3)).until(ExpectedConditions.visibilityOfElementLocated(By.id(id)));
                inputTextElement.clear();
                inputTextElement.sendKeys(text);
                inputTextElement.sendKeys(Keys.RETURN);
            } catch(org.openqa.selenium.TimeoutException e) {
                System.out.print("Test log: ");
                System.out.println("Timed out waiting for element '" + id + "'!");
            }
        }
    }
    
    public void saveChangesAndReturnToMainPage() {
        // save changes
        driver.findElement(By.id("save-button-image")).click();
        // wait for the asterisk to be removed from the page title 
        new WebDriverWait(driver, Duration.ofSeconds(5)).until(ExpectedConditions.not(ExpectedConditions.titleContains("*")));

        // return to main list view
        driver.findElement(By.id("home-button-image")).click();
        // wait until the page title is "All documents"
        new WebDriverWait(driver, Duration.ofSeconds(5)).until(ExpectedConditions.titleIs("All documents"));
    }

    public void clickButton(ArrayList<String> ids){
        for (String id: ids) {
            try {
                WebElement addTitlesButton = new WebDriverWait(driver, Duration.ofSeconds(5)).until(ExpectedConditions.visibilityOfElementLocated(By.xpath("//*[@id=\"xf-293\"]/a/img")));
                //WebElement element = driver.findElement(By.xpath("//*[@id=\"xf-293\"]/a/img"));
                Actions builder = new Actions(driver);
                builder.moveToElement(addTitlesButton).perform();

                WebElement addRow = new WebDriverWait(driver, Duration.ofSeconds(3)).until(ExpectedConditions.visibilityOfElementLocated(By.cssSelector(id)));
                addRow.click();

            } catch(org.openqa.selenium.TimeoutException e) {
                System.out.print("Test log: ");
                System.out.println("Timed out waiting for element '" + id + "'!");
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
                WebElement input_title = new WebDriverWait(driver, Duration.ofSeconds(5)).until(ExpectedConditions.visibilityOfElementLocated(By.id(id)));
                //WebElement input_title = driver.findElement(By.id(id));
                String text =input_title.getAttribute("value");
                System.out.print("Test log: ");
                System.out.println("Expected Text: " + expected_text);
                System.out.print("Test log: ");
                System.out.println("Current Text: " + text);
                assertTrue(text.equals(expected_text));
            }
            catch(org.openqa.selenium.TimeoutException e){
                System.out.print("Test log: ");
                System.out.println("Timed out waiting for element '" + id + "'!");
            }
        }
    }

    @Test
    @Order(2)
    public void checkWorkTabInputText(){
        enterLogin();
        WebElement editButton = driver.findElement(By.xpath("//form[@action='http://localhost:8080/forms/edit-work-case.xml'][input/@value='incipit_demo.xml']/button"));
        editButton.click();

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

        saveChangesAndReturnToMainPage();

        //open edit view
        driver.get("http://localhost:8080/modules/list_files.xq");
        editButton = driver.findElement(By.xpath("//form[@action='http://localhost:8080/forms/edit-work-case.xml'][input/@value='incipit_demo.xml']/button"));
        editButton.click();

        //check changes
        checkText(ids, randomString);
    }

    @Test
    @Order(3)
    public void checkWorkTabPopupInputText(){
        String randomString = generatingRandomAlphabeticString();

        enterLogin();
        WebElement editButton = driver.findElement(By.xpath("//form[@action='http://localhost:8080/forms/edit-work-case.xml'][input/@value='incipit_demo.xml']/button"));
        editButton.click();

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
        saveChangesAndReturnToMainPage();

        //open edit view
        editButton = driver.findElement(By.xpath("//form[@action='http://localhost:8080/forms/edit-work-case.xml'][input/@value='incipit_demo.xml']/button"));
        editButton.click();

        //check changes
        checkText(ids, randomString);

        //ids to remove input text
        ArrayList<String> removeIds = new ArrayList<String>();
        //alternative title
        removeIds.add("xf-239≡xf-910≡≡c⊙1");
        //subtitle
        removeIds.add("xf-252≡xf-1029≡≡c⊙1");
        //uniform title
        removeIds.add("xf-265≡xf-1148≡≡c⊙1");
        //origanal title
        removeIds.add("xf-278≡xf-1267≡≡c⊙1");
        //title of sourcecode
        removeIds.add("xf-291≡xf-1386≡≡c⊙1");

        removeInputText(removeIds);

        /*driver.findElement(By.cssSelector("#xf-239\\2261xf-910\\2261\\2261 c\\2299 1 > img")).click();
        driver.findElement(By.cssSelector("#xf-252\\2261xf-1029\\2261\\2261 c\\2299 1 > img")).click();
        driver.findElement(By.cssSelector("#xf-265\\2261xf-1148\\2261\\2261 c\\2299 1 > img")).click();
        driver.findElement(By.cssSelector("#xf-278\\2261xf-1267\\2261\\2261 c\\2299 1 > img")).click();
        driver.findElement(By.cssSelector("#xf-291\\2261xf-1386\\2261\\2261 c\\2299 1 > img")).click();*/

       /* //cssSelector to remove input text
        ArrayList<String> removeIds = new ArrayList<String>();
        //alternative title
        removeIds.add("#xf-239\\2261xf-910\\2261\\2261 c\\2299 1 > img");
        //subtitle
        removeIds.add("#xf-252\\2261xf-1029\\2261\\2261 c\\2299 1 > img");
        //uniform title
        removeIds.add("#xf-265\\2261xf-1148\\2261\\2261 c\\2299 1 > img");
        //origanal title
        removeIds.add("#xf-278\\2261xf-1267\\2261\\2261 c\\2299 1 > img");
        //title of sourcecode
        removeIds.add("#xf-291\\2261xf-1386\\2261\\2261 c\\2299 1 > img");

        removeInputText(removeIds);*/

        saveChangesAndReturnToMainPage();
    }
    
    // This function is not called anywhere, hence commenting out (PS)
    /*private void checkAfterRemove(ArrayList<String> removeIds) {
        for (String id: removeIds) {
            try {
                Thread.sleep(3000);
                if(driver.findElements(By.id(id)).size() != 0){
                    System.out.println("Test log: " + "Item with id: " +id + " was not deleted");
                    assertTrue(false);
                }

            } catch(InterruptedException e) {
                System.out.print("Test log: ");
                System.out.println("got interrupted!");
            }
        }
    }*/

    //
    public void removeInputText(ArrayList<String> ids){
        for (String id: ids) {
            try {
                //Thread.sleep(3000);
                WebElement elem = new WebDriverWait(driver, Duration.ofSeconds(3)).until(ExpectedConditions.presenceOfElementLocated(By.id(id)));
                elem.click();
                //driver.findElement(By.id(id)).click();

            } catch(org.openqa.selenium.TimeoutException e) {
                System.out.print("Test log: ");
                System.out.println("Timed out waiting for element '" + id + "'!");
            }
            catch(NoSuchElementException e){
                System.out.print("Test log: ");
                System.out.println("No Element with id: " +id);
                assertTrue(false);
            }
        }
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
