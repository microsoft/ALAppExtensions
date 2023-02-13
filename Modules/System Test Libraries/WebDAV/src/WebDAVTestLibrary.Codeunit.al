codeunit 136789 "WebDAV Test Library"
{
    EventSubscriberInstance = Manual;

    var
        RequestMessage: HttpRequestMessage;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"WebDAV Request Helper", 'OnBeforeSendRequest', '', false, false)]
    local procedure RunOnBeforeSendRequest(HttpRequestMessage: HttpRequestMessage; var WebDAVOperationResponse: Codeunit "WebDAV Operation Response"; var IsHandled: Boolean; Method: Text)
    var
        HttpHeaders: HttpHeaders;
        Uri: Text;
    begin
        IsHandled := true;
        RequestMessage := HttpRequestMessage;
        HttpRequestMessage.GetHeaders(HttpHeaders);
        Uri := HttpRequestMessage.GetRequestUri;

        case HttpRequestMessage.Method of
            'PROPFIND':
                begin
                    if HttpHeaders.Contains('Depth') then
                        if GetDepth(HttpHeaders) then
                            GetPropfindRecursiveResponse(Uri, WebDAVOperationResponse)
                        else
                            GetPropfindResponse(Uri, WebDAVOperationResponse);
                end;
            'MKCOL':
                GetCreatedResponse(Uri, WebDAVOperationResponse);
            'GET':
                GetResponseText(Uri, WebDAVOperationResponse);
            'COPY':
                GetSuccessfullResponse(Uri, WebDAVOperationResponse);
            'MOVE':
                GetSuccessfullResponse(Uri, WebDAVOperationResponse);
            'DELETE':
                GetSuccessfullResponse(Uri, WebDAVOperationResponse);
            'PUT':
                GetSuccessfullResponse(Uri, WebDAVOperationResponse);
            else
                Error('No matching test response for %1', Uri);
        end;
    end;

    procedure GetRequestMessage(): HttpRequestMessage
    begin
        exit(RequestMessage);
    end;

    local procedure GetCreatedResponse(Uri: Text; var WebDAVOperationResponse: Codeunit "WebDAV Operation Response")
    var
        HttpHeaders: HttpHeaders;
    begin
        WebDAVOperationResponse.SetHttpResponse('', HttpHeaders, 201, true, 'Created');
    end;

    local procedure GetResponseText(Uri: Text; var WebDAVOperationResponse: Codeunit "WebDAV Operation Response")
    var
        HttpHeaders: HttpHeaders;
    begin
        WebDAVOperationResponse.SetHttpResponse('This is a test string.', HttpHeaders, 400, true, '');
    end;

    local procedure GetSuccessfullResponse(Uri: Text; var WebDAVOperationResponse: Codeunit "WebDAV Operation Response")
    var
        HttpHeaders: HttpHeaders;
    begin
        WebDAVOperationResponse.SetHttpResponse('', HttpHeaders, 400, true, '');
    end;

    local procedure GetPropfindResponse(Uri: Text; var WebDAVOperationResponse: Codeunit "WebDAV Operation Response")
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: TextBuilder;
    begin
        ResponseContent.AppendLine('<?xml version="1.0" encoding="utf-8"?>');
        ResponseContent.AppendLine('<D:multistatus xmlns:D="DAV:">');

        // Folders = 4; Files = 33
        // Uri Folder
        AddPropfindFolder(ResponseContent, Uri, GetLastUrlItemName(Uri), 'Sun, 01 Jan 2023 12:00:00 GMT', 'Sun, 01 Jan 2023 12:00:00 GMT');
        AddPropFindFile(ResponseContent, Uri, 'index.html', 'text/html', 123, 'Sun, 01 Jan 2023 12:01:01 GMT', 'Sun, 01 Jan 2023 12:01:01 GMT');
        AddPropFindFile(ResponseContent, Uri, 'logo.png', 'image/png', 4567, 'Sun, 01 Jan 2023 12:02:02 GMT', 'Sun, 01 Jan 2023 12:02:02 GMT');
        AddPropFindFile(ResponseContent, Uri, 'response.xml', 'text/xml', 890, 'Sun, 01 Jan 2023 12:03:03 GMT', 'Sun, 01 Jan 2023 12:03:03 GMT');

        // Folder1
        AddPropfindFolder(ResponseContent, Uri, '/Folder1', 'Mon, 02 Jan 2023 12:00:00 GMT', 'Mon, 02 Jan 2023 12:00:00 GMT');
        // Folder2
        AddPropfindFolder(ResponseContent, Uri, 'Folder2', 'Fri, 06 Jan 2023 12:00:00 GMT', 'Fri, 06 Jan 2023 12:00:00 GMT');
        // Folder3
        AddPropfindFolder(ResponseContent, Uri, 'Folder3', 'Mon, 09 Jan 2023 12:00:00 GMT', 'Mon, 09 Jan 2023 12:00:00 GMT');

        ResponseContent.AppendLine('</D:multistatus>');
        WebDAVOperationResponse.SetHttpResponse(ResponseContent.ToText(), HttpHeaders, 400, true, '');
    end;

    local procedure GetPropfindRecursiveResponse(Uri: Text; var WebDAVOperationResponse: Codeunit "WebDAV Operation Response")
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: TextBuilder;
    begin
        ResponseContent.AppendLine('<?xml version="1.0" encoding="utf-8"?>');
        ResponseContent.AppendLine('<D:multistatus xmlns:D="DAV:">');

        // Folders = 10; Files = 13
        // Uri Folder
        AddPropfindFolder(ResponseContent, Uri, GetLastUrlItemName(Uri), 'Sun, 01 Jan 2023 12:00:00 GMT', 'Sun, 01 Jan 2023 12:00:00 GMT');
        AddPropFindFile(ResponseContent, Uri, 'index.html', 'text/html', 123, 'Sun, 01 Jan 2023 12:01:01 GMT', 'Sun, 01 Jan 2023 12:01:01 GMT');
        AddPropFindFile(ResponseContent, Uri, 'logo.png', 'image/png', 4567, 'Sun, 01 Jan 2023 12:02:02 GMT', 'Sun, 01 Jan 2023 12:02:02 GMT');
        AddPropFindFile(ResponseContent, Uri, 'response.xml', 'text/xml', 890, 'Sun, 01 Jan 2023 12:03:03 GMT', 'Sun, 01 Jan 2023 12:03:03 GMT');

        // Folder1
        AddPropfindFolder(ResponseContent, Uri, '/Folder1', 'Mon, 02 Jan 2023 12:00:00 GMT', 'Mon, 02 Jan 2023 12:00:00 GMT');
        AddPropFindFile(ResponseContent, Uri + '/Folder1', 'pic.jpg', 'image/jpeg', 4666, 'Mon, 02 Jan 2023 13:13:13 GMT', 'Mon, 02 Jan 2023 13:13:13 GMT');
        AddPropFindFile(ResponseContent, Uri + '/Folder1', 'pic.gif', 'image/gif', 466, 'Mon, 02 Jan 2023 14:14:14 GMT', 'Mon, 02 Jan 2023 14:14:14 GMT');
        // Folder1/Subfolder1
        AddPropfindFolder(ResponseContent, Uri + '/Folder1', 'SubFolder1', 'Tue, 03 Jan 2023 12:00:00 GMT', 'Tue, 03 Jan 2023 12:00:00 GMT');
        AddPropFindFile(ResponseContent, Uri + '/Folder1/Subfolder1', 'file1.txt', 'text/plain', 21, 'Tue, 03 Jan 2023 13:13:13 GMT', 'Tue, 03 Jan 2023 13:13:13 GMT');
        AddPropFindFile(ResponseContent, Uri + '/Folder1/Subfolder1', 'file2.txt', 'text/plain', 500, 'Tue, 03 Jan 2023 15:06:59 GMT', 'Tue, 03 Jan 2023 15:06:59 GMT');
        AddPropFindFile(ResponseContent, Uri + '/Folder1/Subfolder1', 'file3.txt', 'text/plain', 33, 'Tue, 03 Jan 2023 00:00:00 GMT', 'Tue, 03 Jan 2023 00:00:00 GMT');
        // Folder1/Subfolder2
        AddPropfindFolder(ResponseContent, Uri + '/Folder1', 'SubFolder2', 'Wed, 04 Jan 2023 12:00:00 GMT', 'Wed, 04 Jan 2023 12:00:00 GMT');
        AddPropFindFile(ResponseContent, Uri + '/Folder1/Subfolder2', 'file1.pdf', 'application/pdf', 53950, 'Wed, 04 Jan 2023 23:59:59 GMT', 'Wed, 04 Jan 2023 23:59:59 GMT');
        AddPropFindFile(ResponseContent, Uri + '/Folder1/Subfolder2', 'file2.fob', 'application/octet-stream', 373137165, 'Wed, 04 Jan 2023 11:59:59 GMT', 'Wed, 04 Jan 2023 11:59:59 GMT');
        // Folder1/Subfolder3
        AddPropfindFolder(ResponseContent, Uri + '/Folder1', 'SubFolder3', 'Thu, 05 Jan 2023 12:00:00 GMT', 'Thu, 05 Jan 2023 12:00:00 GMT');
        // Folder2
        AddPropfindFolder(ResponseContent, Uri, 'Folder2', 'Fri, 06 Jan 2023 12:00:00 GMT', 'Fri, 06 Jan 2023 12:00:00 GMT');
        AddPropfindFolder(ResponseContent, Uri + '/Folder2', 'SubFolder1', 'Sat, 07 Jan 2023 12:00:00 GMT', 'Sat, 07 Jan 2023 12:00:00 GMT');
        AddPropfindFolder(ResponseContent, Uri + '/Folder2/SubFolder1', 'SubSubFolder1', 'Sat, 07 Jan 2023 20:00:00 GMT', 'Sat, 07 Jan 2023 20:00:00 GMT');
        AddPropfindFolder(ResponseContent, Uri + '/Folder2', 'SubFolder2', 'Sun, 08 Jan 2023 12:00:00 GMT', 'Sun, 08 Jan 2023 12:00:00 GMT');
        // Folder3
        AddPropfindFolder(ResponseContent, Uri, 'Folder3', 'Mon, 09 Jan 2023 12:00:00 GMT', 'Mon, 09 Jan 2023 12:00:00 GMT');
        AddPropFindFile(ResponseContent, Uri + '/Folder3', 'file1.txt', 'text/plain', 21, 'Mon, 09 Jan 2023 13:13:13 GMT', 'Sun, 31 Dec 2023 23:59:59 GMT');
        AddPropFindFile(ResponseContent, Uri + '/Folder3', 'file2.txt', 'text/plain', 500, 'Mon, 09 Jan 2023 15:06:59 GMT', 'Mon, 09 Jan 2023 15:06:59 GMT');
        AddPropFindFile(ResponseContent, Uri + '/Folder3', 'file3.txt', 'text/plain', 33, 'Mon, 09 Jan 2023 00:00:00 GMT', 'Mon, 09 Jan 2023 00:00:00 GMT');

        ResponseContent.AppendLine('</D:multistatus>');
        WebDAVOperationResponse.SetHttpResponse(ResponseContent.ToText(), HttpHeaders, 400, true, '');
    end;


    local procedure AddPropfindFolder(var ResponseContent: TextBuilder; Uri: Text; FolderName: Text; CreationDate: Text; LastModifiedDate: Text)
    begin
        ResponseContent.AppendLine('<D:response>');
        ResponseContent.AppendLine(StrSubstNo('<D:href>%1</D:href>', Uri + '/' + FolderName));
        ResponseContent.AppendLine('<D:propstat>');
        ResponseContent.AppendLine('<D:status>HTTP/1.1 200 OK</D:status>');
        ResponseContent.AppendLine('<D:prop>');
        ResponseContent.AppendLine('<D:getcontenttype/>');
        ResponseContent.AppendLine(StrSubstNo('<D:getlastmodified>%1</D:getlastmodified>', LastModifiedDate));
        ResponseContent.AppendLine(StrSubstNo('<D:displayname>%1</D:displayname>', FolderName));
        ResponseContent.AppendLine('<D:getcontentlength>0</D:getcontentlength>');
        ResponseContent.AppendLine(StrSubstNo('<D:creationdate>%1</D:creationdate>', CreationDate));
        ResponseContent.AppendLine('<D:resourcetype>');
        ResponseContent.AppendLine('<D:collection/>');
        ResponseContent.AppendLine('</D:resourcetype>');
        ResponseContent.AppendLine('</D:prop>');
        ResponseContent.AppendLine('</D:propstat>');
        ResponseContent.AppendLine('</D:response>');
    end;

    local procedure AddPropfindFile(var ResponseContent: TextBuilder; Uri: Text; FileName: Text; ContentType: Text; ContentLength: Integer; CreationDate: Text; LastModifiedDate: Text)
    begin
        ResponseContent.AppendLine('<D:response>');
        ResponseContent.AppendLine(StrSubstNo('<D:href>%1</D:href>', Uri + '/' + Filename));
        ResponseContent.AppendLine('<D:propstat>');
        ResponseContent.AppendLine('<D:status>HTTP/1.1 200 OK</D:status>');
        ResponseContent.AppendLine('<D:prop>');
        ResponseContent.AppendLine(StrSubstNo('<D:getcontenttype>%1</D:getcontenttype>', ContentType));
        ResponseContent.AppendLine(StrSubstNo('<D:getlastmodified>%1</D:getlastmodified>', LastModifiedDate));
        ResponseContent.AppendLine(StrSubstNo('<D:displayname>%1</D:displayname>', Filename));
        ResponseContent.AppendLine(StrSubstNo('<D:getcontentlength>%1</D:getcontentlength>', ContentLength));
        ResponseContent.AppendLine(StrSubstNo('<D:creationdate>%1</D:creationdate>', CreationDate));
        ResponseContent.AppendLine('<D:resourcetype/>');
        ResponseContent.AppendLine('</D:prop>');
        ResponseContent.AppendLine('</D:propstat>');
        ResponseContent.AppendLine('</D:response>');
    end;

    local procedure GetLastUrlItemName(Uri: Text) LastUriItemName: Text;
    var
        UriParts: List of [Text];
    begin
        UriParts := Uri.Split('/');
        UriParts.Get(UriParts.Count, LastUriItemName);
    end;

    local procedure GetDepth(HttpHeaders: HttpHeaders) IsRecursive: Boolean;
    var
        Values: List of [Text];
    begin
        HttpHeaders.GetValues('Depth', Values);
        case Values.Get(1) of
            'infinity':
                exit(true);
            '1':
                exit(false);
            // TODO
            '0':
                Error('Not yet implemented');
        end;
    end;
}