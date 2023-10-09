// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9153 "Microsoft Graph Http Content"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        HttpContent: HttpContent;
        ContentLength: Integer;
        ContentType: Text;

    procedure FromFileInStream(var FileInStream: Instream)
    begin
        HttpContent.WriteFrom(FileInStream);
        ContentLength := FileInStream.Length();
    end;

    procedure FromJson(NewJsonObject: JsonObject)
    var
        RequestText: Text;
    begin
        NewJsonObject.WriteTo(RequestText);
        HttpContent.WriteFrom(RequestText);

        ContentLength := StrLen(RequestText);
        ContentType := 'application/json;odata=verbose';
    end;

    procedure GetContent(): HttpContent
    begin
        exit(HttpContent);
    end;

    procedure GetContentLength(): Integer
    begin
        exit(ContentLength);
    end;

    procedure GetContentType(): Text
    begin
        exit(ContentType);
    end;

}