using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace CalculatorFunctionAPI
{
    public static class Multiply
    {
        [FunctionName("Multiply")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a Multiply request.");

            string requestBody = String.Empty;

            using (StreamReader streamReader = new StreamReader(req.Body))
            {
                requestBody = await streamReader.ReadToEndAsync();
            }

            dynamic data = JsonConvert.DeserializeObject(requestBody);
            int valueA = data?._valueA;
            int valueB = data?._valueB;
            int result = 0;
            string message = "";

            try
            {
                result = valueA * valueB;
            }
            catch (Exception ex)
            {
                result = 0;
                message = ex.Message;

                var errorResponse = new response
                {
                    result = result,
                    message = message
                };

                return new BadRequestObjectResult(errorResponse);
            }

            var response = new response
            {
                result = result,
                message = message
            };

            return new OkObjectResult(response);
        }        
    }
}
