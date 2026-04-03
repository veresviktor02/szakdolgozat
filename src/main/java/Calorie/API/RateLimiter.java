package Calorie.API;

import org.springframework.stereotype.Component;

import java.time.Instant;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class RateLimiter {
    private static final int MAX_REQUESTS = 5;
    private static final long WINDOW_SECONDS = 60;

    private final Map<Integer, UserRequestInfo> users = new ConcurrentHashMap<>();

    public boolean isAllowed(Integer userId) {
        UserRequestInfo info = users.computeIfAbsent(userId, k -> new UserRequestInfo());

        long now = Instant.now().getEpochSecond();

        if(now - info.windowStart >= WINDOW_SECONDS) {
            info.windowStart = now;
            info.requestCount = 0;
        }

        if(info.requestCount >= MAX_REQUESTS) {
            return false;
        }

        info.requestCount++;

        return true;
    }

    private static class UserRequestInfo {
        long windowStart = Instant.now().getEpochSecond();

        int requestCount = 0;
    }
}
