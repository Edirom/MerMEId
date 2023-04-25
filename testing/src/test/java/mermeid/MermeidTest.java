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
import java.util.List;
import java.util.Random;


import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertEquals;


@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class MermeidTest extends WebDriverSettings {


    public void enterLogin(){
        String loginText = "";
        String loginUser = "mermeid";
        String loginPass = "mermeid";
        driver.get("http://localhost:8080/modules/list_files.xq");
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));

        try {
            WebElement loginTextElement = wait.until(ExpectedConditions.elementToBeClickable(By.id("login-info")));
            System.out.print("Function `enterLogin` log: current login name - ");
            System.out.println(loginTextElement.getText());
            loginTextElement.click();

            WebElement modal = wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("login-modal")));
            //driver.findElement(By.id("login-modal")).click();
            System.out.println("Function `enterLogin` log: login modal available");

            WebElement userInput = modal.findElement(By.name("user"));
            userInput.clear();
            userInput.sendKeys(loginUser);
            WebElement passwordInput = modal.findElement(By.name("password"));
            passwordInput.clear();
            passwordInput.sendKeys(loginPass);

            //driver.findElement(By.name("remember")).click();
            modal.findElement(By.xpath(".//button[@type='submit']")).click();

            // check login name
            WebElement loginTextElementOnNewPage = wait.until(ExpectedConditions.elementToBeClickable(By.id("login-info")));
            wait.until(ExpectedConditions.textToBePresentInElement(loginTextElementOnNewPage, loginUser));
            System.out.print("Function `enterLogin` log: new login name - ");
            System.out.println(loginTextElementOnNewPage.getText());
        } catch(org.openqa.selenium.TimeoutException e) {
            System.out.print("Function `enterLogin` log: ");
            System.out.println("Timed out waiting for element 'login-info'!");
            System.out.print("Function `enterLogin` log: login name - ");
            System.out.println(driver.findElement(By.id("login-info")).getText());
            assertTrue(false);
        }
        catch(NoSuchElementException e){
            assertTrue(false);
        }
    }

    @Test
    @Order(1)
    public void OpenEditPage(){
        System.out.println("**************************");
        System.out.println("* Test 1: `OpenEditPage` *");
        System.out.println("**************************");

        String title = driver.getTitle();
        System.out.println("Title: " + title);
        assertTrue(title.equals("MerMEId – Metadata Editor and Repository for MEI Data"));

        WebElement button = driver.findElement(By.cssSelector("button"));
        String buttonText = button.getText();
        System.out.print("Function `OpenEditPage` log: ");
        System.out.println(buttonText);

        assertTrue(buttonText.equals("Try MerMEId"));

        enterLogin();
        WebElement editButton = driver.findElement(By.xpath("//form[@action='http://localhost:8080/forms/edit-work-case.xml'][input/@value='incipit_demo.xml']/button"));
        editButton.click();

        try {
            new WebDriverWait(driver, Duration.ofSeconds(10)).until(ExpectedConditions.titleContains("MerMEId "));
        }
        catch(org.openqa.selenium.TimeoutException e) {
            System.out.print("Test `OpenEditPage` log: ");
            System.out.println("Timed out waiting for edit page to load!");
            assertTrue(false);
        }
    }

    public void setText(WebElement inputTextElement, String text ){
        try {
            inputTextElement.clear();
            inputTextElement.sendKeys(text);
            inputTextElement.sendKeys(Keys.RETURN);
        } catch(org.openqa.selenium.TimeoutException e) {
            System.out.print("Function `setText` log: ");
            System.out.println("Timed out waiting for element '" + inputTextElement.getAttribute("id") + "'!");
            assertTrue(false);
        }
    }
    
    public void saveChangesAndReturnToMainPage() {
        // save changes
        driver.findElement(By.id("save-button-image")).click();
        // wait for the asterisk to be removed from the page title 
        new WebDriverWait(driver, Duration.ofSeconds(10)).until(ExpectedConditions.not(ExpectedConditions.titleContains("*")));

        // return to main list view
        driver.findElement(By.id("home-button-image")).click();
        // wait until the page title is "All documents"
        new WebDriverWait(driver, Duration.ofSeconds(10)).until(ExpectedConditions.titleIs("All documents"));
    }

    public void checkText(WebElement inputTextElement, String expected_text ){
        try{
            String text = inputTextElement.getAttribute("value");
            System.out.print("Function `checkText` log: ");
            System.out.println("Expected Text: " + expected_text);
            System.out.print("Function `checkText` log: ");
            System.out.println("Current Text: " + text);
            assertTrue(text.equals(expected_text));
        }
        catch(org.openqa.selenium.TimeoutException e){
            System.out.print("Function `checkText` log: ");
            System.out.println("Timed out waiting for element '" + inputTextElement.getAttribute("id") + "'!");
            assertTrue(false);
        }
    }

    @Test
    @Order(2)
    public void checkWorkTabInputText(){
        System.out.println("***********************************");
        System.out.println("* Test 2: `checkWorkTabInputText` *");
        System.out.println("***********************************");

        String randomString = generatingRandomAlphabeticString();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));
        Actions builder = new Actions(driver);

        enterLogin();
        WebElement editButton = driver.findElement(By.xpath("//form[@action='http://localhost:8080/forms/edit-work-case.xml'][input/@value='incipit_demo.xml']/button"));
        editButton.click();

        // wait for page to have loaded
        wait.until(ExpectedConditions.elementToBeClickable(By.xpath("//span[@id='xf-293']/a")));

        // set text inputs with randomString
        List<WebElement> inputs = driver.findElements(By.xpath("//input[@type='text']"));
        ArrayList<String> changedIds = new ArrayList<String>();
        for (WebElement input: inputs) {
            if (input.isDisplayed()) {
                System.out.print("Setting input text for id: ");
                System.out.println(input.getAttribute("id"));
                setText(input, randomString);
                changedIds.add(input.getAttribute("id"));
            }
        }
        // assert that there are 5 changed text inputs
        assertEquals(6, changedIds.size());

        // Save changes and return to main menu
        saveChangesAndReturnToMainPage();

        // Reopen edit pane
        editButton = driver.findElement(By.xpath("//form[@action='http://localhost:8080/forms/edit-work-case.xml'][input/@value='incipit_demo.xml']/button"));
        editButton.click();
        // wait for page to have loaded
        wait.until(ExpectedConditions.elementToBeClickable(By.xpath("//span[@id='xf-293']/a")));

        // check changes
        for (String id: changedIds) {
            System.out.print("Checking input text for id: ");
            System.out.println(id);
            checkText(driver.findElement(By.id(id)), randomString);
        }
    }

    @Test
    @Order(3)
    public void checkWorkTabPopupInputText(){
        System.out.println("****************************************");
        System.out.println("* Test 3: `checkWorkTabPopupInputText` *");
        System.out.println("****************************************");

        String randomString = generatingRandomAlphabeticString();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));
        Actions builder = new Actions(driver);

        enterLogin();
        WebElement editButton = driver.findElement(By.xpath("//form[@action='http://localhost:8080/forms/edit-work-case.xml'][input/@value='incipit_demo.xml']/button"));
        editButton.click();

        // hover over "add more titles"
        WebElement addTitlesButton =
            wait.until(ExpectedConditions.elementToBeClickable(By.xpath("//span[@id='xf-293']/a")));
        builder.moveToElement(addTitlesButton).perform();

        // Add rows for additional titles
        List<WebElement> buttons = addTitlesButton.findElements(By.xpath(".//button"));
        // assert that there are 5 buttons
        assertEquals(5, buttons.size());
        // iterate over buttons and add rows for additional titles
        for (WebElement button: buttons) {
            System.out.println(button.getText());
            builder.moveToElement(button).perform();
            button.click();
        }

        // set text inputs to $randomString$
        // and assert that there are 48 text inputs on the page (most of them invisible)
        List<WebElement> inputs =
            wait.until(ExpectedConditions.numberOfElementsToBe(By.xpath("//input[@type='text']"), 51));

        // array to be filled with changed ids
        ArrayList<String> changedIds = new ArrayList<String>();
        // iterate over text inputs and set to $randomString$
        for (WebElement input: inputs) {
            if (input.isDisplayed()) {
                System.out.print("Setting input text for id: ");
                System.out.println(input.getAttribute("id"));
                setText(input, randomString);
                changedIds.add(input.getAttribute("id"));
            }
        }
        // assert that there are 10 changed text inputs
        assertEquals(11, changedIds.size());

        // Save changes and return to main menu
        saveChangesAndReturnToMainPage();

        // Reopen edit pane
        editButton = driver.findElement(By.xpath("//form[@action='http://localhost:8080/forms/edit-work-case.xml'][input/@value='incipit_demo.xml']/button"));
        editButton.click();


        // check changes
        for (String id: changedIds) {
            System.out.print("Checking input text for id: ");
            System.out.println(id);
            checkText(driver.findElement(By.id(id)), randomString);
        }

        // cleanup: remove additional title rows again
        WebElement titlesFieldset =
            wait.until(ExpectedConditions.elementToBeClickable(By.xpath("//fieldset[legend='Titles']")));
        List<WebElement> removeButtons = titlesFieldset.findElements(By.xpath(".//a[img/@title='Delete row']"));
        for (WebElement removeButton: removeButtons) {
            System.out.print("Removing row for id: ");
            System.out.println(removeButton.getAttribute("id"));
            removeButton.click();
        }

        // Save changes and return to main menu
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
                System.out.print("Function `removeInputText` log: ");
                System.out.println("Timed out waiting for element '" + id + "'!");
                assertTrue(false);
            }
            catch(NoSuchElementException e){
                System.out.print("Function `removeInputText` log: ");
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
