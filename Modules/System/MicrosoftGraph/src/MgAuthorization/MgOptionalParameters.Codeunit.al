// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Holder for the optional Microsoft Graph HTTP headers and URL parameters.
/// </summary>
codeunit 9157 "Mg Optional Parameters"
{
    Access = Public;

    #region Headers

    /// <summary>
    /// Sets the value for 'IF-Match' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Text value specifying the HttpHeader value</param>
    procedure SetIfMatch("Value": Text)
    begin
        SetRequestHeader('IF-Match', "Value");
    end;

    /// <summary>
    /// Sets the value for 'Content-Range' HttpHeader for a request.
    /// </summary>
    /// <param name="BytesStartValue">Integer value specifying the Bytes start range value</param>
    /// <param name="BytesEndValue">Integer value specifying the Bytes end range value</param>
    procedure SetContentRange(BytesStartValue: Integer; BytesEndValue: Integer)
    var
        RangeBytesLbl: Label 'bytes=%1-%2', Comment = '%1 = Start Range; %2 = End Range', Locked = true;
    begin
        SetRequestHeader('Content-Range', StrSubstNo(RangeBytesLbl, BytesStartValue, BytesEndValue));
    end;

    /// <summary>
    /// Sets the value for 'Content-Range' HttpHeader for a request.
    /// </summary>
    /// <param name="ContentLength">Integer value specifying the length value</param>
    procedure SetContentLength(ContentLength: Integer)
    begin
        SetRequestHeader('Content-Length', Format(ContentLength));
    end;

    local procedure SetRequestHeader(Header: Text; HeaderValue: Text)
    begin
        RequestHeaders.Remove(Header);
        RequestHeaders.Add(Header, HeaderValue);
    end;

    internal procedure GetRequestHeaders(): Dictionary of [Text, Text]
    begin
        exit(RequestHeaders);
    end;

    #endregion

    #region Parameters

    /// <summary>
    /// Sets the value for '@microsoft.graph.conflictBehavior' HttpHeader for a request.
    /// </summary>
    /// <param name="MicrosftGraphConflictBehavior">Enum "MicrosftGraph ConflictBehavior" value specifying the HttpHeader value</param>
    procedure SetMicrosftGraphConflictBehavior(MicrosftGraphConflictBehavior: Enum "MicrosftGraph ConflictBehavior")
    begin
        SetParameter('@microsoft.graph.conflictBehavior', Format(MicrosftGraphConflictBehavior));
    end;


    local procedure SetParameter(Header: Text; HeaderValue: Text)
    begin
        QueryParameters.Remove(Header);
        QueryParameters.Add(Header, HeaderValue);
    end;

    internal procedure GetParameters(): Dictionary of [Text, Text]
    begin
        exit(QueryParameters);
    end;
    #endregion

    var
        QueryParameters: Dictionary of [Text, Text];
        RequestHeaders: Dictionary of [Text, Text];
}