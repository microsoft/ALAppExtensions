// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Integration.Microsoft.Graph;

/// <summary>
/// Holder for the optional Microsoft Graph HTTP headers and URL parameters.
/// </summary>
codeunit 9353 "Mg Optional Parameters"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    #region Headers

    /// <summary>
    /// Sets the value for 'IF-Match' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Text value specifying the HttpHeader value</param>
    procedure SetIfMatch("Value": Text)
    begin
        SetRequestHeader('IF-Match', "Value");
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
    /// <param name="MgConflictBehavior">Enum "Mg ConflictBehavior" value specifying the HttpHeader value</param>
    procedure SetMicrosftGraphConflictBehavior(MgConflictBehavior: Enum "Mg ConflictBehavior")
    begin
        SetQueryParameter('@microsoft.graph.conflictBehavior', Format(MgConflictBehavior));
    end;


    local procedure SetQueryParameter(Header: Text; HeaderValue: Text)
    begin
        QueryParameters.Remove(Header);
        QueryParameters.Add(Header, HeaderValue);
    end;

    internal procedure GetQueryParameters(): Dictionary of [Text, Text]
    begin
        exit(QueryParameters);
    end;
    #endregion

    var
        QueryParameters: Dictionary of [Text, Text];
        RequestHeaders: Dictionary of [Text, Text];
}