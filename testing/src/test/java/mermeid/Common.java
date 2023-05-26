package mermeid;

import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;
import java.util.ArrayList;
import java.util.Random;

import static org.junit.jupiter.api.Assertions.assertTrue;

public class Common extends WebDriverSettings{
    public static String generatingRandomAlphabeticString() {
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

    public static void enterLogin(){
        String loginText = "";
        String loginUser = "mermeid";
        String loginPass = "mermeid";
        driver.get("http://localhost:8080/index.html");
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



    public static void setText(WebElement inputTextElement, String text ){
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

    public static void saveChangesAndReturnToMainPage() {
        // save changes
        driver.findElement(By.id("save-button-image")).click();
        // wait for the asterisk to be removed from the page title
        new WebDriverWait(driver, Duration.ofSeconds(10)).until(ExpectedConditions.not(ExpectedConditions.titleContains("*")));

        // return to main list view
        driver.findElement(By.id("home-button-image")).click();
        // wait until the page title is "All documents"
        new WebDriverWait(driver, Duration.ofSeconds(10)).until(ExpectedConditions.titleIs("All documents"));
    }

    public static void checkText(WebElement inputTextElement, String expected_text ){
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

    public static void removeInputText(ArrayList<String> ids){
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

}
