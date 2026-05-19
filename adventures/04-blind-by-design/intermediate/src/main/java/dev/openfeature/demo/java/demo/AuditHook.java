package dev.openfeature.demo.java.demo;

import dev.openfeature.sdk.EvaluationContext;
import dev.openfeature.sdk.FlagEvaluationDetails;
import dev.openfeature.sdk.Hook;
import dev.openfeature.sdk.HookContext;
import dev.openfeature.sdk.Value;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.Map;

public class AuditHook implements Hook<String> {

    private static final Logger log = LoggerFactory.getLogger(AuditHook.class);
    private static final List<String> AUDIT_KEYS = List.of("species", "country", "dose");

    @Override
    public void after(HookContext<String> ctx, FlagEvaluationDetails<String> details,
                      Map<String, Object> hints) {
        EvaluationContext evalCtx = ctx.getCtx();
        String flag = ctx.getFlagKey();
        String variant = details.getVariant();
        String reason = details.getReason();

        StringBuilder sb = new StringBuilder("[AUDIT]")
                .append(" flag=").append(flag)
                .append(" variant=").append(variant)
                .append(" reason=").append(reason);

        for (String key : AUDIT_KEYS) {
            Value val = evalCtx != null ? evalCtx.getValue(key) : null;
            sb.append(" ").append(key).append("=").append(val != null ? val.asString() : "null");
        }

        if ("clouded".equals(variant)) {
            log.warn("{} — improper dosing or off-protocol cohort, follow-up required", sb);
        } else {
            log.info("{}", sb);
        }
    }

    @Override
    public void error(HookContext<String> ctx, Exception error, Map<String, Object> hints) {
        log.error("[AUDIT] flag={} ERROR: {}", ctx.getFlagKey(), error.getMessage());
    }
}
