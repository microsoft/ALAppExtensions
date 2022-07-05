codeunit 9110 "SharePoint Uri Builder"
{

    Access = Internal;

    var
        ServerName, Namespace : Text;
        Uri: Text;
        UriLbl: Label 'https://{server_name}/_api/{namespace}', Locked = true;
        UriAppendTxt: Label '/%1', Comment = '%1 - URI part to append', Locked = true;
        SetMethodTxt: Label '/%1(''%2'')', Comment = '%1 - method name, %2 - method parameter', Locked = true;
        SetMethodRawTxt: Label '/%1(%2)', Comment = '%1 - method name, %2 - method parameter', Locked = true;



    procedure GetHost(): Text
    var
        _Uri: Codeunit Uri;
    begin
        _Uri.Init(ServerName);
        exit(_Uri.GetHost());
    end;

    procedure Initialize(_ServerName: Text; _Namespace: Text)
    begin
        ServerName := _ServerName;
        Namespace := _Namespace;

        if ServerName.StartsWith('https://') then
            ServerName := ServerName.Substring(9);
        if ServerName.StartsWith('http://') then
            ServerName := ServerName.Substring(8);
    end;

    procedure SetObject(Object: Text)
    begin
        Uri += StrSubstNo(UriAppendTxt, Object);
    end;

    procedure SetMethod(Method: Text; ParameterValue: Text)
    begin
        Uri += StrSubstNo(SetMethodTxt, Method, ParameterValue);
    end;

    procedure SetMethod(Method: Text; ParameterValue: Integer)
    begin
        Uri += StrSubstNo(SetMethodRawTxt, Method, ParameterValue);
    end;

    procedure SetMethod(Method: Text; ParameterValue: Boolean)
    begin
        Uri += StrSubstNo(SetMethodRawTxt, Method, ParameterValue);
    end;

    procedure SetMethod(Method: Text; ParameterValue: Guid)
    begin
        Uri += StrSubstNo(SetMethodRawTxt, Method, ParameterValue);
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
                Uri += ParameterName + '=' + ParameterValue;

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
    begin
        Uri := UriLbl + Uri + '/';
        exit(uri.Replace('{server_name}', ServerName.TrimStart('/').TrimEnd('/')).Replace('{namespace}', Namespace.TrimStart('/').TrimEnd('/')));
    end;

    procedure ResetPath()
    begin
        Uri := '';
    end;

    procedure ResetPath(Id: Text)
    begin
        Uri := UriLbl;
        Uri := Uri.Replace('{server_name}', ServerName.TrimStart('/').TrimEnd('/')).Replace('{namespace}', Namespace.TrimStart('/').TrimEnd('/'));
        Uri := Id.Replace(Uri, '');
    end;


}