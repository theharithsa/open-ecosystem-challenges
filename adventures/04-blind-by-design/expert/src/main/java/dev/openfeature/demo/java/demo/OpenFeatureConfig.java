package dev.openfeature.demo.java.demo;

import dev.openfeature.contrib.hooks.otel.MetricsHook;
import dev.openfeature.contrib.hooks.otel.TracesHook;
import dev.openfeature.contrib.providers.flagd.Config;
import io.opentelemetry.api.GlobalOpenTelemetry;
import dev.openfeature.contrib.providers.flagd.FlagdOptions;
import dev.openfeature.contrib.providers.flagd.FlagdProvider;
import dev.openfeature.sdk.ImmutableContext;
import dev.openfeature.sdk.OpenFeatureAPI;
import dev.openfeature.sdk.Value;
import jakarta.annotation.PostConstruct;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.HashMap;
import java.util.Optional;

/**
 * Wires the OpenFeature client to a remote flagd container ({@code Resolver.RPC})
 * and registers the cross-cutting hooks.
 *
 * <p>OpenTelemetry SDK setup is provided by the OpenTelemetry Java Agent
 * (attached via {@code -javaagent} — see {@code pom.xml} and {@code otel.properties}).
 * The agent installs the global {@link io.opentelemetry.api.OpenTelemetry} instance
 * before {@code main()} runs, so {@link io.opentelemetry.api.GlobalOpenTelemetry#get()}
 * returns a working SDK throughout this class.</p>
 *
 * <p>Half-wired on purpose: the {@link TracesHook} is registered, so flag
 * evaluations show up as span events in Tempo. The matching
 * {@code MetricsHook} is NOT registered — until it is, the "Fun With Flags"
 * dashboard panels in Grafana stay dark.</p>
 */
@Configuration
public class OpenFeatureConfig implements WebMvcConfigurer {

    @PostConstruct
    public void initProvider() {
        OpenFeatureAPI api = OpenFeatureAPI.getInstance();
        FlagdOptions flagdOptions = FlagdOptions.builder()
                .resolverType(Config.Resolver.RPC)
                .build();

        api.setProviderAndWait(new FlagdProvider(flagdOptions));

        String country = Optional.ofNullable(System.getenv("COUNTRY")).orElse("");
        HashMap<String, Value> attributes = new HashMap<>();
        attributes.put("country", new Value(country));
        ImmutableContext evaluationContext = new ImmutableContext(attributes);
        api.setEvaluationContext(evaluationContext);

        api.addHooks(new AuditHook());
        api.addHooks(new TracesHook());
        api.addHooks(new MetricsHook(GlobalOpenTelemetry.get()));
        api.addHooks(new ContextSpanHook());
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new SpeciesInterceptor());
    }
}
