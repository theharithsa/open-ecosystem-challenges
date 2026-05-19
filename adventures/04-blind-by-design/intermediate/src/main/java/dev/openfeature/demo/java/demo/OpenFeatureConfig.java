package dev.openfeature.demo.java.demo;

import dev.openfeature.contrib.providers.flagd.Config;
import dev.openfeature.contrib.providers.flagd.FlagdOptions;
import dev.openfeature.contrib.providers.flagd.FlagdProvider;
import dev.openfeature.sdk.ImmutableContext;
import dev.openfeature.sdk.OpenFeatureAPI;
import dev.openfeature.sdk.Value;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.HashMap;
import java.util.Map;

@Configuration
public class OpenFeatureConfig implements WebMvcConfigurer {

    @Autowired
    private SpeciesInterceptor speciesInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(speciesInterceptor);
    }

    @PostConstruct
    public void initProvider() {
        OpenFeatureAPI api = OpenFeatureAPI.getInstance();

        FlagdOptions flagdOptions = FlagdOptions.builder()
                .resolverType(Config.Resolver.RPC)
                .build();
        api.setProviderAndWait(new FlagdProvider(flagdOptions));

        String country = System.getenv("COUNTRY");
        Map<String, Value> globalAttrs = new HashMap<>();
        if (country != null && !country.isBlank()) {
            globalAttrs.put("country", new Value(country));
        }
        api.setEvaluationContext(new ImmutableContext(globalAttrs));

        api.addHooks(new AuditHook());
    }
}
