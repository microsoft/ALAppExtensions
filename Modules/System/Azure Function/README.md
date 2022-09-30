This module provides functionality for connecting to [Azure Functions](https://docs.microsoft.com/en-us/azure/azure-functions/).

> This module does not store credentials for Azure Functions.  
> Use caution when you store and pass credentials. 
> We recommend that you use OAuth 2.0 authorization. [Secure an HTTP endpoint in production] (https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-http-webhook-trigger?tabs=in-process%2Cfunctionsv2&pivots=programming-language-csharp#secure-an-http-endpoint-in-production)
> **NOTE:** Azure Function Integration telemetry gathers data about the success or failure of calls from Business Central to Azure Functions. For more information, see [Analyzing Azure Function Integration Telemetry](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/telemetry-azure-function-integration-trace?branch=kepontop-azure-function-telemetry).

#### Examle: send a POST request

```
    procedure SendPostRequest_Example()
    var
        AzureFunctionAuthentication: Codeunit "Azure Functions Authentication";
        AzureFunction: Codeunit "Azure Functions";
        AzureFunctionResponse: Codeunit "Azure Functions Response";
        IAzurefunctionAuthentication: Interface "Azure Functions Authentication";
        ResponseTxt: text;
    begin
        // Code authentication example
        // Uncomment to use it
        // Do not hardcode secrets
        // IAzurefunctionAuthentication := AzureFunctionAuthentication.CreateCodeAuth('<Function URL>', '<Function Code>');


        // OAuth authentication example
        // Uncomment to use it
        // Do not hardcode secrets
        // IAzurefunctionAuthentication := AzureFunctionAuthentication.CreateOAuth2('<Function URL>', '<Function Code>', '<Client ID>', 'Client Secret', '<OAuthAuthorityUrl>', '<ReturnURL>', 'ResourceURL');


        // Set the value of the body and the body type header
        AzureFunctionResponse := AzureFunction.SendPostRequest(IAzurefunctionAuthentication, '<Body>', 'application/json');

        if AzureFunctionResponse.IsSuccessful() then begin
            AzureFunctionResponse.GetResultAsText(ResponseTxt);

            // Display the response
            Message(ResponseTxt);
        end
        else
            // Display the error message
            Message(AzureFunctionResponse.GetError());
    end;
```

#### Examle 2: send a GET request

```
    procedure SendGetRequest_Example()
    var
        AzureFunctionAuthentication: Codeunit "Azure Functions Authentication";
        AzureFunction: Codeunit "Azure Functions";
        AzureFunctionResponse: Codeunit "Azure Functions Response";
        IAzurefunctionAuthentication: Interface "Azure Functions Authentication";
        QueryDictionary: Dictionary of [Text, Text];
        ResponseTxt: text;
    begin
        // Code authentication example
        // Uncomment to use it
        // Do not hardcode secrets
        // IAzurefunctionAuthentication := AzureFunctionAuthentication.CreateCodeAuth('<Function URL>', '<Function Code>');


        // OAuth authentication example
        // Uncomment to use it
        // Do not hardcode secrets
        // IAzurefunctionAuthentication := AzureFunctionAuthentication.CreateOAuth2('<Function URL>', '<Function Code>', '<Client ID>', 'Client Secret', '<OAuthAuthorityUrl>', '<ReturnURL>', 'ResourceURL');

        QueryDictionary.Add('name', 'value');
        AzureFunctionResponse := AzureFunction.SendGetRequest(IAzurefunctionAuthentication, QueryDictionary);

        if AzureFunctionResponse.IsSuccessful() then begin
            AzureFunctionResponse.GetResultAsText(ResponseTxt);

            // Display the response
            Message(ResponseTxt);
        end
        else
            // Display the error message
            Message(AzureFunctionResponse.GetError());
    end;
```