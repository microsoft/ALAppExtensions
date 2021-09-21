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

    /// <summary>
    /// Gets the result of a ABS client operation as text, 
    /// </summary>
    /// <returns>The content of the response.</returns>
    [NonDebuggable]
    [TryFunction]
    internal procedure GetResultAsText(var Result: Text);
    begin
        Response.Content.ReadAs(Result);
    end;

    /// <summary>
    /// Gets the result of a ABS client operation as stream, 
    /// </summary>
    /// <returns>The content of the response.</returns>
    [NonDebuggable]
    [TryFunction]
    internal procedure GetResultAsStream(var Result: InStream)
    begin
        Response.Content.ReadAs(Result);
    end;

    [NonDebuggable]
    internal procedure SetHttpResponse(NewResponse: HttpResponseMessage)
    begin
        Response := NewResponse;
    end;

    var
        [NonDebuggable]
        Response: HttpResponseMessage;
        ResponseError: Text;
}