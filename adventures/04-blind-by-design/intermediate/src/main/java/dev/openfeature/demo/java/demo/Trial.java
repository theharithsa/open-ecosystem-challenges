package dev.openfeature.demo.java.demo;

import dev.openfeature.sdk.Client;
import dev.openfeature.sdk.FlagEvaluationDetails;
import dev.openfeature.sdk.ImmutableContext;
import dev.openfeature.sdk.OpenFeatureAPI;
import dev.openfeature.sdk.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;
import java.util.Random;

@RestController
public class Trial {

    private static final String[] DOSES = {"standard", "standard", "standard", "underdose", "overdose"};
    private static final Random RANDOM = new Random();

    @GetMapping("/")
    public FlagEvaluationDetails<String> observeSubject(
            @RequestParam(required = false) String dose) {

        String effectiveDose = (dose != null && !dose.isBlank())
                ? dose
                : DOSES[RANDOM.nextInt(DOSES.length)];

        ImmutableContext invocationCtx = new ImmutableContext(
                Map.of("dose", new Value(effectiveDose))
        );

        Client client = OpenFeatureAPI.getInstance().getClient();
        return client.getStringDetails("vision_state", "untreated", invocationCtx);
    }
}
