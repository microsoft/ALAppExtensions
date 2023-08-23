interface "Azure Functions Impl"
{
    procedure SendGetRequest(AzureFunctionAuthentication: Interface "Azure Functions Authentication"; QueryDict: Dictionary of [Text, Text]): Codeunit "Azure Functions Response";

    procedure SendPostRequest(AzureFunctionAuthentication: Interface "Azure Functions Authentication"; Body: Text; ContentTypeHeader: text): Codeunit "Azure Functions Response";

    procedure Send(AzureFunctionAuthentication: Interface "Azure Functions Authentication"; RequestType: enum "Http Request Type"; QueryDict: Dictionary of [Text, Text]; Body: Text; ContentTypeHeader: text): Codeunit "Azure Functions Response";
}