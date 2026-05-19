package dev.openfeature.demo.java.demo;

import dev.openfeature.sdk.ImmutableContext;
import dev.openfeature.sdk.OpenFeatureAPI;
import dev.openfeature.sdk.ThreadLocalTransactionContextPropagator;
import dev.openfeature.sdk.Value;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.util.Map;

@Component
public class SpeciesInterceptor implements HandlerInterceptor {

    static {
        OpenFeatureAPI.getInstance().setTransactionContextPropagator(
                new ThreadLocalTransactionContextPropagator()
        );
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        String species = request.getParameter("species");
        ImmutableContext ctx;
        if (species != null && !species.isBlank()) {
            ctx = new ImmutableContext(Map.of("species", new Value(species)));
        } else {
            ctx = new ImmutableContext();
        }
        OpenFeatureAPI.getInstance().setTransactionContext(ctx);
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response,
                                Object handler, Exception ex) {
        OpenFeatureAPI.getInstance().setTransactionContext(new ImmutableContext());
    }
}
