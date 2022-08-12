package helpers;

import com.github.javafaker.Faker;

import java.util.Date;


public class DataGenerator {

    public static String getRandomEmail(){
        Faker faker = new Faker();
        String email = faker.name().firstName().toLowerCase() + faker.random().nextInt(0, 100) + "@test.com";
        return email;
    }

    public static String getRandomUsername(){
        Faker faker = new Faker();
        String username = faker.name().username();
        return username;
    }
    public static String getRandomArticleName(){
        return "Article-" + Math.round(Math.random()*1000);
    }

    public static String getRandomComment(){
        return "Comment is created at -" + new Date().toString();
    }
}
