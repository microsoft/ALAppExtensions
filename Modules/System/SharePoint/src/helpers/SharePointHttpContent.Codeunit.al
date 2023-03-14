// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9107 "SharePoint Http Content"
{
    Access = Internal;

    var
        HttpContent: HttpContent;
        ContentLength: Integer;
        ContentType: Text;
        RequestDigest: Text;
        XHTTPMethod: Text;

    procedure FromFileInStream(var FileInStream: InStream)
    begin
        HttpContent.WriteFrom(FileInStream);
        ContentLength := GetContentLength(FileInStream);
    end;

    procedure FromJson(Object: JsonObject)
    var
        RequestText: Text;
    begin
        Object.WriteTo(RequestText);
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

    procedure SetRequestDigest(RequestDigestValue: Text)
    begin
        RequestDigest := RequestDigestValue;
    end;

    procedure GetRequestDigest(): Text;
    begin
        exit(RequestDigest);
    end;

    procedure SetXHTTPMethod(XHTTPMethodValue: Text)
    begin
        XHTTPMethod := XHTTPMethodValue;
    end;

    procedure GetXHTTPMethod(): Text;
    begin
        exit(XHTTPMethod);
    end;

    local procedure GetContentLength(var SourceInStream: InStream) Length: Integer
    var
        MemoryStream: DotNet MemoryStream;
    begin
        MemoryStream := MemoryStream.MemoryStream();
        CopyStream(MemoryStream, SourceInStream);
        Length := MemoryStream.Length;
        Clear(SourceInStream);
    end;

}