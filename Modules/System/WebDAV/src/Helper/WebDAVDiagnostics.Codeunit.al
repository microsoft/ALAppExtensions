// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Stores detailed information about failed api call
/// </summary>
codeunit 5685 "WebDAV Diagnostics" implements "HTTP Diagnostics"
{
    Access = Internal;

    var
        ErrorMessage, ResponseReasonPhrase : Text;
        HttpStatusCode, RetryAfter : Integer;
        SuccessStatusCode: Boolean;

    /// <summary>
    /// Gets reponse details.
    /// </summary>
    /// <returns>HttpResponseMessage.IsSuccessStatusCode</returns>
    procedure IsSuccessStatusCode(): Boolean
    begin
        exit(SuccessStatusCode);
    end;

    /// <summary>
    /// Gets response details.
    /// </summary>
    /// <returns>HttpResponseMessage.StatusCode</returns>
    procedure GetHttpStatusCode(): Integer
    begin
        exit(HttpStatusCode);
    end;

    /// <summary>
    /// Gets response details.
    /// </summary>
    /// <returns>Retry-after header value</returns>
    procedure GetHttpRetryAfter(): Integer
    begin
        exit(RetryAfter);
    end;

    /// <summary>
    /// Gets reponse details
    /// </summary>
    /// <returns>Error message</returns>
    procedure GetErrorMessage(): Text
    begin
        exit(ErrorMessage);
    end;

    /// <summary>
    /// Gets response details.
    /// </summary>
    /// <returns>HttpResponseMessage.ResponseReasonPhrase</returns>
    procedure GetResponseReasonPhrase(): Text
    begin
        exit(ResponseReasonPhrase);
    end;

    internal procedure SetParameters(NewIsSuccesss: Boolean; NewHttpStatusCode: Integer; NewResponseReasonPhrase: Text; NewRetryAfter: Integer; NewErrorMessage: Text)
    begin
        SuccessStatusCode := NewIsSuccesss;
        HttpStatusCode := NewHttpStatusCode;
        ResponseReasonPhrase := NewResponseReasonPhrase;
        RetryAfter := NewRetryAfter;
        ErrorMessage := NewErrorMessage;
    end;
}