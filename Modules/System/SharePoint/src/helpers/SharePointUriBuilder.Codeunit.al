// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Sharepoint;

using System.Utilities;

codeunit 9110 "SharePoint Uri Builder"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        ServerName, Namespace : Text;
        Uri: Text;
        UriLbl: Label 'https://{server_name}/_api/{namespace}', Locked = true;
        UriAppendTxt: Label '/%1', Comment = '%1 - URI part to append', Locked = true;
        SetMethodTxt: Label '/%1(''%2'')', Comment = '%1 - method name, %2 - method parameter', Locked = true;
        SetMethodRawTxt: Label '/%1(%2)', Comment = '%1 - method name, %2 - method parameter', Locked = true;
        SetMethodGuidTxt: Label '/%1(guid''%2'')', Comment = '%1 - method name, %2 - method parameter', Locked = true;
        QueryParameters: Dictionary of [Text, Text];

    procedure GetHost(): Text
    var
        NewUri: Codeunit Uri;
    begin
        NewUri.Init(GetUri());
        exit(NewUri.GetHost());
    end;

    procedure AddQueryParameter(ParameterName: Text; ParameterValue: Text)
    begin
        QueryParameters.Add(ParameterName, ParameterValue);
    end;

    procedure Initialize(NewServerName: Text; NewNamespace: Text)
    begin
        ServerName := NewServerName;
        Namespace := NewNamespace;

        if ServerName.StartsWith('https://') then
            ServerName := ServerName.Substring(9);
        if ServerName.StartsWith('http://') then
            ServerName := ServerName.Substring(8);
    end;

    procedure SetObject(Object: Text)
    begin
        Uri += StrSubstNo(UriAppendTxt, EscapeDataString(Object));
    end;

    procedure SetMethod(Method: Text; ParameterValue: Text)
    begin
        Uri += StrSubstNo(SetMethodTxt, EscapeDataString(Method), EscapeDataString(ParameterValue));
    end;

    procedure SetMethod(Method: Text; ParameterValue: Integer)
    begin
        Uri += StrSubstNo(SetMethodRawTxt, EscapeDataString(Method), ParameterValue);
    end;

    procedure SetMethod(Method: Text; ParameterValue: Boolean)
    begin
        Uri += StrSubstNo(SetMethodRawTxt, EscapeDataString(Method), ParameterValue);
    end;

    procedure SetMethod(Method: Text; ParameterValue: Guid)
    begin
        Uri += StrSubstNo(SetMethodGuidTxt, EscapeDataString(Method), EscapeDataString(Format(ParameterValue).TrimStart('{').TrimEnd('}')));
    end;

    procedure SetMethod(Method: Text; ParameterName: Text; ParameterValue: Text)
    var
        Parameters: Dictionary of [Text, Text];
    begin
        Parameters.Add(ParameterName, ParameterValue);
        SetMethod(Method, Parameters);
    end;

    procedure SetMethod(Method: Text; Parameters: Dictionary of [Text, Text])
    var
        i: Integer;
        ParameterName, ParameterValue : Text;
    begin
        Uri += StrSubstNo(UriAppendTxt, Method);
        if Parameters.Count() > 0 then begin
            Uri += '(';
            foreach ParameterName in Parameters.Keys() do begin
                i += 1;
                Parameters.Get(ParameterName, ParameterValue);
                Uri += EscapeDataString(ParameterName) + '=' + EscapeDataString(ParameterValue);

                if i < Parameters.Count() then
                    Uri += ','
            end;

            Uri += ')';
        end;
    end;

    procedure GetMethodParameter(Method: Text): Text
    var
        str1, str2 : Text;
        start, len : Integer;
    begin
        start := Uri.IndexOf(Method) + StrLen(Method);
        str1 := Uri.Substring(start);
        len := str1.IndexOf(')');
        str2 := str1.Substring(1, len);
        exit(str2.TrimStart('(').TrimStart('''').TrimEnd(')').TrimEnd(''''));
    end;

    procedure GetUri(): Text
    var
        FullUri: Text;
        ParameterName, ParameterValue : Text;
    begin
        FullUri := UriLbl + Uri + '/';
        FullUri := FullUri.Replace('{server_name}', ServerName.TrimStart('/').TrimEnd('/')).Replace('{namespace}', Namespace.TrimStart('/').TrimEnd('/'));
        if QueryParameters.Count() > 0 then begin
            FullUri += '?';
            foreach ParameterName in QueryParameters.Keys() do begin
                QueryParameters.Get(ParameterName, ParameterValue);
                FullUri += EscapeDataString(ParameterName) + '=' + EscapeDataString(ParameterValue) + '&';
            end;
            FullUri := FullUri.TrimEnd('&');
        end;
        exit(FullUri);
    end;

    procedure ResetPath()
    begin
        Uri := '';
        Clear(QueryParameters);
    end;

    procedure SetPath(NewPath: Text)
    begin
        Uri := NewPath;
        Clear(QueryParameters);
    end;

    procedure ResetPath(Id: Text)
    begin
        Uri := UriLbl;
        Clear(QueryParameters);
        Uri := Uri.Replace('{server_name}', ServerName.TrimStart('/').TrimEnd('/')).Replace('{namespace}', Namespace.TrimStart('/').TrimEnd('/'));
        Uri := Id.Replace(Uri, '');
    end;

    local procedure EscapeDataString(TextToEscape: Text): Text
    var
        LocalUri: Codeunit Uri;
    begin
        exit(LocalUri.EscapeDataString(TextToEscape));
    end;

}