// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Holder object for holding for Azure Function request result.
/// </summary>
codeunit 7805 "Azure Functions Response"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Checks whether the request was successful.
    /// </summary>    
    /// <returns>True if the request was successful; otherwise - false.</returns>
    [NonDebuggable]
    procedure IsSuccessful(): Boolean
    begin
        if ResponseError <> '' then
            exit(false);

        exit(ResponseMessage.IsSuccessStatusCode);
    end;

    /// <summary>
    /// Gets the error (if any) of the response.
    /// </summary>
    /// <returns>Text representation of the error that occurred during the request.</returns>
    procedure GetError(): Text
    begin
        if ResponseError <> '' then
            exit(ResponseError)
        else
            exit(ResponseMessage.ReasonPhrase);
    end;

    /// <summary>
    /// Gets the error content
    /// </summary>
    /// <returns>Text representation of the detailed error message.</returns>
    procedure GetError(var ErrorContent: Text)
    begin
        ResponseMessage.Content.ReadAs(ErrorContent);
    end;

    internal procedure SetError(Error: Text)
    begin
        ResponseError := Error;
    end;

    /// <summary>
    /// Gets the result of Azure function request as text.
    /// </summary>
    /// <returns>The content of the response.</returns>
    [NonDebuggable]
    [TryFunction]
    procedure GetResultAsText(var Result: Text);
    begin
        if IsSuccessful() then
            ResponseMessage.Content.ReadAs(Result);
    end;

    /// <summary>
    /// Gets the result of Azure function request as stream.
    /// </summary>
    /// <returns>The content of the response.</returns>
    [NonDebuggable]
    [TryFunction]
    procedure GetResultAsStream(var ResultInStream: InStream)
    begin
        if IsSuccessful() then
            ResponseMessage.Content.ReadAs(ResultInStream);
    end;

    /// <summary>
    /// Gets the result of Azure function request as HTTPResponseMessage.
    /// </summary>
    /// <returns>The HTTP response object.</returns>
    [NonDebuggable]
    procedure GetHttpResponse(var ResultResponseMessage: HttpResponseMessage)
    begin
        ResultResponseMessage := ResponseMessage;
    end;

    [NonDebuggable]
    internal procedure SetHttpResponse(NewHttpResponseMessage: HttpResponseMessage)
    begin
        ResponseMessage := NewHttpResponseMessage;
    end;

    var
        [NonDebuggable]
        ResponseMessage: HttpResponseMessage;
        ResponseError: Text;
}