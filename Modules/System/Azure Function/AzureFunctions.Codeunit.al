// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality for connecting to Azure functions.
/// </summary>
codeunit 7804 "Azure Functions"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        AzureFunctionSet: Boolean;
        IAzureFunctions: Interface IAzureFunctions;

    local procedure GetAzureFunctionInterface(): Interface IAzureFunctions
    var
        AzureFunctionsImpl: Codeunit "Azure Functions Impl";
    begin
        if not AzureFunctionSet then
            IAzureFunctions := AzureFunctionsImpl;

        exit(IAzureFunctions);
    end;

    /// <summary>
    /// Sends a get request to Azure function.
    /// </summary>
    /// <param name="AzureFunctionAuthentication">Authentication interface.</param>
    /// <param name="QueryDict">Dictionary of query parameters for the request.</param>
    /// <returns>Instance of Azure function response object.</returns>
    [NonDebuggable]
    procedure SendGetRequest(AzureFunctionsAuthentication: Interface "Azure Functions Authentication"; QueryDict: Dictionary of [Text, Text]): Codeunit "Azure Functions Response"
    begin
        exit(GetAzureFunctionInterface().SendGetRequest(AzureFunctionsAuthentication, QueryDict));
    end;

    /// <summary>
    /// Sends a post request to Azure function.
    /// </summary>
    /// <param name="AzureFunctionAuthentication">Authentication interface</param>
    /// <param name="Body">Body of the request message.</param>
    /// <param name="ContentTypeHeader">Content type of the body to add to the request header.</param>
    /// <returns>Instance of Azure function response object.</returns>
    [NonDebuggable]
    procedure SendPostRequest(AzureFunctionsAuthentication: Interface "Azure Functions Authentication"; Body: Text; ContentTypeHeader: text): Codeunit "Azure Functions Response"
    begin
        exit(GetAzureFunctionInterface.SendPostRequest(AzureFunctionsAuthentication, Body, ContentTypeHeader));
    end;

    /// <summary>
    /// Sends a request to Azure function.
    /// </summary>
    /// <param name="AzureFunctionAuthentication">Authentication interface</param>
    /// <param name="RequestType">HTTP request method.</param>
    /// <param name="QueryDict">Dictionary of query parameters for the request.</param>
    /// <param name="Body">Body of the request message.</param>
    /// <param name="ContentTypeHeader">Content type of the body to add to the request header.</param>
    /// <returns>Instance of Azure function response object.</returns>
    [NonDebuggable]
    procedure Send(AzureFunctionsAuthentication: Interface "Azure Functions Authentication"; RequestType: enum "Http Request Type"; QueryDict: Dictionary of [Text, Text]; Body: Text; ContentTypeHeader: text): Codeunit "Azure Functions Response"
    begin
        exit(GetAzureFunctionInterface.Send(AzureFunctionsAuthentication, RequestType, QueryDict, Body, ContentTypeHeader));
    end;

    /// <summary>
    /// Set a custom implementation of the azure function to mock the azure function communication in a test.
    /// </summary>
    /// <remarks>This method is only used for testing purpose.</remarks>
    /// <param name="NewIAzureFunctions"></param>
    procedure SetIAzureFunctions(NewIAzureFunctions: Interface IAzureFunctions)
    begin
        IAzureFunctions := NewIAzureFunctions;
        AzureFunctionSet := true;
    end;
}