package Calorie.User;

import Calorie.Exceptions.UserException;

import jakarta.annotation.PostConstruct;

import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;

import java.util.ArrayList;
import java.util.List;

@Service
public class UserNameCheckerService {
    private final List<String> bannedWords = new ArrayList<>();

    @PostConstruct
    public void loadBannedWords() {
        try {
            InputStream inputStream = getClass()
                    .getClassLoader()
                    .getResourceAsStream("banned_words.txt");

            if(inputStream == null) {
                throw new UserException("banned_words.txt nem található!");
            }

            BufferedReader reader = new BufferedReader(
                    new InputStreamReader(inputStream)
            );

            reader.lines().forEach(line -> {
                if(!line.isBlank()) {
                    bannedWords.add(normalize(line));
                }
            });

            reader.close();

        } catch (Exception e) {
            throw new UserException(
                    "Tiltott szavak listájának betöltése sikertelen.", e
            );
        }
    }

    public void validate(String text) {
        String normalizedText = normalize(text);

        for(String bannedWord : bannedWords) {
            if(normalizedText.contains(bannedWord)) {
                throw new UserException(
                        "A megadott felhasználónév tiltott szót tartalmaz!"
                );
            }
        }
    }

    private String normalize(String text) {
        return text.trim().toLowerCase().replaceAll("[^\\p{L}0-9]", "");
    }
}