package dev.openfeature.demo.java.demo;

import dev.openfeature.contrib.providers.flagd.FlagdOptions;
import dev.openfeature.contrib.providers.flagd.FlagdProvider;
import dev.openfeature.contrib.providers.flagd.Config;
import dev.openfeature.sdk.OpenFeatureAPI;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenFeatureConfig {

    @Bean
    public ApplicationRunner openFeatureSetup() {
        return args -> {
            FlagdProvider provider = new FlagdProvider(
                FlagdOptions.builder()
                    .resolverType(Config.Resolver.RPC)
                    .build()
            );
            OpenFeatureAPI.getInstance().setProviderAndWait(provider);
        };
    }
}
