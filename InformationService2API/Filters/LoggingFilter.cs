using Microsoft.AspNetCore.Mvc.Filters;

namespace InformationService2API.Filters
{
    public class LoggingFilter : IActionFilter
    {
        private readonly ILogger<LoggingFilter> _logger;

        public LoggingFilter(ILogger<LoggingFilter> logger)
        {
            _logger = logger;
        }

        public void OnActionExecuting(ActionExecutingContext context)
        {
            var method = context.HttpContext.Request.Method;
            var path = context.HttpContext.Request.Path;
            _logger.LogInformation($"[REQUEST] {method} {path}");
        }

        public void OnActionExecuted(ActionExecutedContext context)
        {
            var statusCode = context.HttpContext.Response.StatusCode;
            _logger.LogInformation($"[RESPONSE] Status Code: {statusCode}");
        }
    }
}
