package dev.openfeature.demo.java.demo;

import dev.openfeature.sdk.EvaluationContext;
import dev.openfeature.sdk.Hook;
import dev.openfeature.sdk.HookContext;
import dev.openfeature.sdk.Value;
import io.opentelemetry.api.trace.Span;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Copies a fixed allowlist of evaluation-context attributes onto the currently
 * active OpenTelemetry span as {@code feature_flag.context.<key>}.
 *
 * <p>This lets on-call engineers search Tempo for, e.g.,
 * {@code feature_flag.context.dose=underdose} and immediately see — on the
 * same span — which {@code feature_flag.variant} the lab recorded, closing
 * the loop between why an outcome happened and what the chart knew.</p>
 *
 * <p>⚠️ The allowlist is intentionally fixed. The merged evaluation context
 * can carry a {@code targetingKey} (often a stable user id that joins to
 * email / account data in real apps). Span attributes are retained for days
 * in Tempo and are hard to redact after the fact — see
 * https://opentelemetry.io/docs/security/ for the broader guidance.</p>
 */
public class ContextSpanHook implements Hook {

    private static final List<String> ALLOWLIST = List.of("species", "country", "dose");

    @Override
    public Optional<EvaluationContext> before(HookContext ctx, Map hints) {
        Span span = Span.current();
        EvaluationContext ec = ctx.getCtx();
        if (ec != null) {
            for (String key : ALLOWLIST) {
                Value v = ec.getValue(key);
                if (v != null && !v.isNull()) {
                    span.setAttribute("feature_flag.context." + key, v.asString());
                }
            }
        }
        return Optional.empty();
    }
}
