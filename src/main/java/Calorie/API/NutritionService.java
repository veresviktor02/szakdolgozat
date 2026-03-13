package Calorie.API;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;

@Service
public class NutritionService {
    private static final String API_URL = "https://api.calorieninjas.com/v1/nutrition";

    private final String apiKey;

    private final RestTemplate restTemplate;

    public NutritionService(RestTemplate restTemplate, @Value("${api.key}") String apiKey) {
        this.restTemplate = restTemplate;
        this.apiKey = apiKey;
        ;
    }

    public NutritionResponse getNutrition(String query) {
        String url = UriComponentsBuilder
                .fromUri(URI.create(API_URL))
                .queryParam("query", query)
                .toUriString();

        HttpHeaders headers = new HttpHeaders();
        headers.set("X-Api-Key", apiKey);

        return restTemplate.exchange(
                url,
                HttpMethod.GET,
                new HttpEntity<>(headers),
                NutritionResponse.class
        ).getBody();
    }
}
