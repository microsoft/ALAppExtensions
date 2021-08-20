// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Holder object for holding for ABS client operations result.
/// </summary>
codeunit 9050 "ABS Operation Response"
{
    Access = Public;

    /// <summary>
    /// Gets the result of a ABS client operation as text, 
    /// </summary>
    /// <returns>The content of the response.</returns>
    [TryFunction]
    procedure GetResultAsText(var Result: Text);
    begin
        Response.Content.ReadAs(Result);
    end;

    /// <summary>
    /// Gets the result of a ABS client operation as stream, 
    /// </summary>
    /// <returns>The content of the response.</returns>
    [TryFunction]
    procedure GetResultAsStream(var Result: InStream)
    begin
        Response.Content.ReadAs(Result);
    end;

    /// <summary>
    /// Checks whether the operation was successful.
    /// </summary>    
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure IsSuccessful(): Boolean
    begin
        exit(Response.IsSuccessStatusCode);
    end;

    /// <summary>
    /// Gets the error (if any) of the response.
    /// </summary>
    /// <returns>Text representation of the error that occurred during the operation.</returns>
    procedure GetError(): Text
    begin
        exit(ResponseError);
    end;

    internal procedure SetError(Error: Text)
    begin
        ResponseError := Error;
    end;

    internal procedure SetHttpResponse(NewResponse: HttpResponseMessage)
    begin
        Response := NewResponse;
    end;

    internal procedure GetHttpResponseHeaders(): HttpHeaders
    begin
        exit(Response.Headers);
    end;

    internal procedure GetHttpResponse(): HttpResponseMessage
    begin
        exit(Response);
    end;

    internal procedure GetHeaderValueFromResponseHeaders(HeaderName: Text): Text
    var
        Headers: HttpHeaders;
        Values: array[100] of Text;
    begin
        Headers := GetHttpResponseHeaders();
        if not Headers.GetValues(HeaderName, Values) then
            exit('');

        exit(Values[1]);
    end;

    var
        Response: HttpResponseMessage;
        ResponseError: Text;
}