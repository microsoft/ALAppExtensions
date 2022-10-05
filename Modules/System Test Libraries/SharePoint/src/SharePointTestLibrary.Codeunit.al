// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132973 "SharePoint Test Library"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SharePoint Request Helper", 'OnBeforeSendRequest', '', false, false)]
    local procedure RunOnBeforeSendRequest(HttpRequestMessage: HttpRequestMessage; var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; var IsHandled: Boolean; Method: Text)
    var
        LocalUri: Codeunit Uri;
        Uri: Text;
        BaseUrl, ParentUrl : Text;
    begin
        Uri := HttpRequestMessage.GetRequestUri();
        if Uri.IndexOf('/_api/Web') > 0 then
            BaseUrl := CopyStr(Uri, 1, Uri.IndexOf('/_api/Web'))
        else
            BaseUrl := CopyStr(Uri, 1, Uri.IndexOf('/_api/contextinfo'));

        ParentUrl := BaseUrl.Replace('https://', '').Replace('http://', '');
        ParentUrl := ParentUrl.Substring(StrPos(ParentUrl, '/')).TrimEnd('/');

        IsHandled := true;

        Uri := LocalUri.UnescapeDataString(Uri);

        if Uri.EndsWith('/_api/contextinfo/') then begin
            GetContextDigestTestResponse(SharePointOperationResponse, BaseUrl, ParentUrl);
            exit;
        end;

        if Uri.EndsWith('/_api/Web/lists/') then begin
            if Method = 'GET' then begin
                GetListsTestResponse(SharePointOperationResponse, BaseUrl, ParentUrl);
                exit;
            end;
            if Method = 'POST' then begin
                CreateListTestResponse(SharePointOperationResponse, BaseUrl, ParentUrl);
                exit;
            end
        end;

        if Uri.EndsWith('/_api/Web/Lists(guid''55CD6695-941D-49A6-801C-79CA67BD513D'')/items/') then begin
            GetTooManyRequestsResponse(SharePointOperationResponse);
            exit;
        end;

        if Uri.EndsWith('/_api/Web/Lists(guid''549F3387-C984-4969-95DE-4F405CCB4EA9'')/items/') then begin
            GetDetailedErrorResponse(SharePointOperationResponse);
            exit;
        end;

        if Uri.EndsWith('/_api/Web/Lists(guid''854D7F21-1C6A-43AB-A081-20404894B449'')/items/') or Uri.EndsWith('/_api/Web/lists/GetByTitle(''Test Documents'')/items/') then begin
            if Method = 'GET' then begin
                GetListItemsTestResponse(SharePointOperationResponse, BaseUrl, ParentUrl);
                exit;
            end;
            if Method = 'POST' then begin
                CreateListItemTestResponse(SharePointOperationResponse, BaseUrl, ParentUrl);
                exit;
            end;
        end;

        if Uri.EndsWith('_api/Web/Lists(guid''854D7F21-1C6A-43AB-A081-20404894B449'')/Items(1)/AttachmentFiles/') or Uri.EndsWith('/_api/Web/lists/GetByTitle(''Test Documents'')/Items(1)/AttachmentFiles/') then begin
            GetListItemAttachmentsTestResponse(SharePointOperationResponse, BaseUrl, ParentUrl);
            exit;
        end;

        if Uri.EndsWith('_api/Web/Lists(guid''854D7F21-1C6A-43AB-A081-20404894B449'')/Items(1)/AttachmentFiles/add(FileName=''Sample_file.txt'')/') or Uri.EndsWith('/_api/Web/lists/GetByTitle(''Test Documents'')/Items(1)/AttachmentFiles/add(FileName=''Sample_file.txt'')/') then begin
            CreateListItemAttachmentTestResponse(SharePointOperationResponse, BaseUrl, ParentUrl);
            exit;
        end;

        if Uri.EndsWith('_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/rootfolder/') then begin
            GetDocumentLibraryRootFolderTestResponse(SharePointOperationResponse, BaseUrl, ParentUrl);
            exit;
        end;

        if Uri.EndsWith('_api/Web/GetFolderByServerRelativeUrl(''' + ParentUrl + '/Lists/Test%20Documents'')/Folders/') then begin
            GetFolderBySeverRelativeUrlTestResponse(SharePointOperationResponse, BaseUrl, ParentUrl);
            exit;
        end;

        if Uri.EndsWith('_api/Web/GetFolderByServerRelativeUrl(''' + ParentUrl + '/Lists/Test%20Documents/Attachments/1'')/Files/') then begin
            GetFolderFilesByServerRelativeUrlTestResponse(SharePointOperationResponse, BaseUrl, ParentUrl);
            exit;
        end;

        if Uri.EndsWith('_api/Web/folders/') then
            if Method = 'POST' then begin
                CreateFolderTestResponse(SharePointOperationResponse, BaseUrl, ParentUrl);
                exit;
            end;

        if Uri.EndsWith('_api/Web/GetFolderByServerRelativeUrl(''' + ParentUrl + '/Lists/Test%20Documents/Attachments'')/Files/add(url=''SampleTestFile.jpg'')/') then
            if Method = 'POST' then begin
                AddFileToFolderTestResponse(SharePointOperationResponse, BaseUrl, ParentUrl);
                exit;
            end;

        Error('No matching test response for %1', Uri);
    end;

    local procedure GetContextDigestTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: TextBuilder;
    begin
        ResponseContent.Append('{');
        ResponseContent.Append('"d":{');
        ResponseContent.Append('"GetContextWebInformation":{');
        ResponseContent.Append('"__metadata":{');
        ResponseContent.Append('"type":"SP.ContextWebInformation"');
        ResponseContent.Append('},');
        ResponseContent.Append('"FormDigestTimeoutSeconds":1800,');
        ResponseContent.Append('"FormDigestValue":"0xCC9B958136D1BA6D100A038315EC4E58C093661D4D102E1EFB9D8814641E42CD4D0C12B7BCF4AC44183E2C28A67925708048F3CC900D6ACE164DD33A45A884C5,15 Jul 2022 11:00:55 -0000",');
        ResponseContent.Append('"LibraryVersion":"16.0.22629.12003",');
        ResponseContent.Append('"SiteFullUrl":"{baseUrl}",');
        ResponseContent.Append('"SupportedSchemaVersions":{');
        ResponseContent.Append('"__metadata":{');
        ResponseContent.Append('"type":"Collection(Edm.String)"');
        ResponseContent.Append('},');
        ResponseContent.Append('"results":[');
        ResponseContent.Append('"14.0.0.0",');
        ResponseContent.Append('"15.0.0.0"');
        ResponseContent.Append(']');
        ResponseContent.Append('},');
        ResponseContent.Append('"WebFullUrl":"{baseUrl}"');
        ResponseContent.Append('}');
        ResponseContent.Append('}');
        ResponseContent.Append('}');

        ResponseContent.Replace('{baseUrl}', BaseUrl);
        ResponseContent.Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent.ToText(), HttpHeaders, 200, true, 'OK');
    end;

    local procedure GetListsTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: TextBuilder;
    begin
        ResponseContent.Append('{');
        ResponseContent.Append('"odata.metadata":"{baseUrl}_api/$metadata#SP.ApiData.Lists",');
        ResponseContent.Append('"value": [');
        ResponseContent.Append('{');
        ResponseContent.Append('"odata.type":"SP.List",');
        ResponseContent.Append('"odata.id":"{baseUrl}_api/Web/Lists(guid''71b5c280-f303-46fa-b818-755bf9b91837'')",');
        ResponseContent.Append('"odata.etag":"0",');
        ResponseContent.Append('"odata.editLink":"Web/Lists(guid''71b5c280-f303-46fa-b818-755bf9b91837'')",');
        ResponseContent.Append('"AllowContentTypes":true,');
        ResponseContent.Append('"BaseTemplate":125,');
        ResponseContent.Append('"BaseType":0,');
        ResponseContent.Append('"ContentTypesEnabled":false,');
        ResponseContent.Append('"CrawlNonDefaultViews":false,');
        ResponseContent.Append('"Created":"2022-03-06T00:39:32Z",');
        ResponseContent.Append('"CurrentChangeToken":{"StringValue":"1;3;71b5c280-f303-46fa-b818-755bf9b91837;637933377461200000;290418294"},');
        ResponseContent.Append('"DefaultContentApprovalWorkflowId":"00000000-0000-0000-0000-000000000000",');
        ResponseContent.Append('"DefaultItemOpenUseListSetting":false,');
        ResponseContent.Append('"Description":"",');
        ResponseContent.Append('"Direction":"none",');
        ResponseContent.Append('"DisableCommenting":false,');
        ResponseContent.Append('"DisableGridEditing":false,');
        ResponseContent.Append('"DocumentTemplateUrl":null,');
        ResponseContent.Append('"EnableAttachments":true,');
        ResponseContent.Append('"EnableFolderCreation":true,');
        ResponseContent.Append('"EnableMinorVersions":false,');
        ResponseContent.Append('"EnableModeration":false,');
        ResponseContent.Append('"EnableRequestSignOff":true,');
        ResponseContent.Append('"EnableVersioning":false,');
        ResponseContent.Append('"EntityTypeName":"OData__x005f_catalogs_x002f_appdata",');
        ResponseContent.Append('"ExemptFromBlockDownloadOfNonViewableFiles":false,');
        ResponseContent.Append('"FileSavePostProcessingEnabled":false,');
        ResponseContent.Append('"ForceCheckout":false,');
        ResponseContent.Append('"HasExternalDataSource":false,');
        ResponseContent.Append('"Hidden":true,');
        ResponseContent.Append('"Id":"71b5c280-f303-46fa-b818-755bf9b91837",');
        ResponseContent.Append('"ImagePath":{"DecodedUrl":"/_layouts/15/images/itgen.png?rev=47"},');
        ResponseContent.Append('"ImageUrl":"/_layouts/15/images/itgen.png?rev=47",');
        ResponseContent.Append('"DefaultSensitivityLabelForLibrary":"",');
        ResponseContent.Append('"IrmEnabled":false,');
        ResponseContent.Append('"IrmExpire":false,');
        ResponseContent.Append('"IrmReject":false,');
        ResponseContent.Append('"IsApplicationList":false,');
        ResponseContent.Append('"IsCatalog":false,');
        ResponseContent.Append('"IsPrivate":false,');
        ResponseContent.Append('"ItemCount":0,');
        ResponseContent.Append('"LastItemDeletedDate":"2022-03-06T00:39:32Z",');
        ResponseContent.Append('"LastItemModifiedDate":"2022-03-06T00:39:32Z",');
        ResponseContent.Append('"LastItemUserModifiedDate":"2022-03-06T00:39:32Z",');
        ResponseContent.Append('"ListExperienceOptions":0,');
        ResponseContent.Append('"ListItemEntityTypeFullName":"SP.Data.OData__x005f_catalogs_x002f_appdataItem",');
        ResponseContent.Append('"MajorVersionLimit":0,');
        ResponseContent.Append('"MajorWithMinorVersionsLimit":0,');
        ResponseContent.Append('"MultipleDataList":false,');
        ResponseContent.Append('"NoCrawl":true,');
        ResponseContent.Append('"ParentWebPath":{"DecodedUrl":"{parentUrl}"},');
        ResponseContent.Append('"ParentWebUrl":"{parentUrl}",');
        ResponseContent.Append('"ParserDisabled":false,');
        ResponseContent.Append('"ServerTemplateCanCreateFolders":true,');
        ResponseContent.Append('"TemplateFeatureId":"00000000-0000-0000-0000-000000000000",');
        ResponseContent.Append('"Title":"appdata"');
        ResponseContent.Append('},');
        ResponseContent.Append('{');
        ResponseContent.Append('"odata.type":"SP.List",');
        ResponseContent.Append('"odata.id":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')",');
        ResponseContent.Append('"odata.etag":"5",');
        ResponseContent.Append('"odata.editLink":"Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')",');
        ResponseContent.Append('"AllowContentTypes":true,');
        ResponseContent.Append('"BaseTemplate":100,');
        ResponseContent.Append('"BaseType":0,');
        ResponseContent.Append('"ContentTypesEnabled":false,');
        ResponseContent.Append('"CrawlNonDefaultViews":false,');
        ResponseContent.Append('"Created":"2022-05-23T12:16:04Z",');
        ResponseContent.Append('"CurrentChangeToken":{"StringValue":"1;3;854d7f21-1c6a-43ab-a081-20404894b449;637933377461200000;290418294"},');
        ResponseContent.Append('"DefaultContentApprovalWorkflowId":"00000000-0000-0000-0000-000000000000",');
        ResponseContent.Append('"DefaultItemOpenUseListSetting":false,');
        ResponseContent.Append('"Description":"My Test Documents",');
        ResponseContent.Append('"Direction":"none",');
        ResponseContent.Append('"DisableCommenting":false,');
        ResponseContent.Append('"DisableGridEditing":false,');
        ResponseContent.Append('"DocumentTemplateUrl":null,');
        ResponseContent.Append('"DraftVersionVisibility":0,');
        ResponseContent.Append('"EnableAttachments":true,');
        ResponseContent.Append('"EnableFolderCreation":false,');
        ResponseContent.Append('"EnableMinorVersions":false,');
        ResponseContent.Append('"EnableModeration":false,');
        ResponseContent.Append('"EnableRequestSignOff":true,');
        ResponseContent.Append('"EnableVersioning":true,');
        ResponseContent.Append('"EntityTypeName":"My_x0020_Asset_x0020_DocumentsList",');
        ResponseContent.Append('"ExemptFromBlockDownloadOfNonViewableFiles":false,');
        ResponseContent.Append('"FileSavePostProcessingEnabled":false,');
        ResponseContent.Append('"ForceCheckout":false,');
        ResponseContent.Append('"HasExternalDataSource":false,');
        ResponseContent.Append('"Hidden":false,');
        ResponseContent.Append('"Id":"854d7f21-1c6a-43ab-a081-20404894b449",');
        ResponseContent.Append('"ImagePath":{"DecodedUrl":"/_layouts/15/images/itgen.png?rev=47"},');
        ResponseContent.Append('"ImageUrl":"/_layouts/15/images/itgen.png?rev=47",');
        ResponseContent.Append('"DefaultSensitivityLabelForLibrary":"",');
        ResponseContent.Append('"IrmEnabled":false,');
        ResponseContent.Append('"IrmExpire":false,');
        ResponseContent.Append('"IrmReject":false,');
        ResponseContent.Append('"IsApplicationList":false,');
        ResponseContent.Append('"IsCatalog":false,');
        ResponseContent.Append('"IsPrivate":false,');
        ResponseContent.Append('"ItemCount":2,');
        ResponseContent.Append('"LastItemDeletedDate":"2022-05-31T11:43:35Z",');
        ResponseContent.Append('"LastItemModifiedDate":"2022-07-08T21:11:10Z",');
        ResponseContent.Append('"LastItemUserModifiedDate":"2022-07-08T21:11:10Z",');
        ResponseContent.Append('"ListExperienceOptions":0,');
        ResponseContent.Append('"ListItemEntityTypeFullName":"SP.Data.My_x0020_Test_x0020_DocumentsListItem",');
        ResponseContent.Append('"MajorVersionLimit":50,');
        ResponseContent.Append('"MajorWithMinorVersionsLimit":0,');
        ResponseContent.Append('"MultipleDataList":false,');
        ResponseContent.Append('"NoCrawl":false,');
        ResponseContent.Append('"ParentWebPath":{"DecodedUrl":"{parentUrl}"},');
        ResponseContent.Append('"ParentWebUrl":"{parentUrl}",');
        ResponseContent.Append('"ParserDisabled":false,');
        ResponseContent.Append('"ServerTemplateCanCreateFolders":true,');
        ResponseContent.Append('"TemplateFeatureId":"00bfea71-de22-43b2-a848-c05709900100",');
        ResponseContent.Append('"Title":"Test Documents"');
        ResponseContent.Append('}');
        ResponseContent.Append(']');
        ResponseContent.Append('}');

        ResponseContent.Replace('{baseUrl}', BaseUrl);
        ResponseContent.Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent.ToText(), HttpHeaders, 200, true, 'OK');
    end;

    local procedure GetListItemsTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: TextBuilder;
    begin
        ResponseContent.Append('{');
        ResponseContent.Append('"odata.metadata":"{baseUrl}_api/$metadata#SP.ListData.Asset_x0020_DocumentsListItems",');
        ResponseContent.Append('"value": [');
        ResponseContent.Append('{');
        ResponseContent.Append('"odata.type":"SP.Data.Asset_x0020_DocumentsListItem",');
        ResponseContent.Append('"odata.id":"fbccfcf6-28bf-4f63-97bb-f1daa8955b6e",');
        ResponseContent.Append('"odata.etag":"30",');
        ResponseContent.Append('"odata.editLink":"Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)",');
        ResponseContent.Append('"FileSystemObjectType":0,');
        ResponseContent.Append('"Id":1,');
        ResponseContent.Append('"ServerRedirectedEmbedUri":null,');
        ResponseContent.Append('"ServerRedirectedEmbedUrl":"",');
        ResponseContent.Append('"ID":1,');
        ResponseContent.Append('"ContentTypeId":"0x0100386AEFB9434E704081AB02149FB55A74008FA0CDB720117949A23770C25BF4E510",');
        ResponseContent.Append('"Title":"Test List Item",');
        ResponseContent.Append('"Modified":"2022-05-31T12:31:57Z",');
        ResponseContent.Append('"Created":"2022-05-23T12:16:29Z",');
        ResponseContent.Append('"AuthorId":9,');
        ResponseContent.Append('"EditorId":9,');
        ResponseContent.Append('"OData__UIVersionString":"30.0",');
        ResponseContent.Append('"Attachments":true,');
        ResponseContent.Append('"GUID":"27c78f81-f4d9-4ee9-85bd-5d57ade1b5f4",');
        ResponseContent.Append('"ComplianceAssetId":null');
        ResponseContent.Append('},');
        ResponseContent.Append('{');
        ResponseContent.Append('"odata.type":"SP.Data.Asset_x0020_DocumentsListItem",');
        ResponseContent.Append('"odata.id":"6fdd295a-2201-4f9b-a853-d53513d4f63a",');
        ResponseContent.Append('"odata.etag":"2",');
        ResponseContent.Append('"odata.editLink":"Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(2)",');
        ResponseContent.Append('"FileSystemObjectType":0,');
        ResponseContent.Append('"Id":2,');
        ResponseContent.Append('"ServerRedirectedEmbedUri":null,');
        ResponseContent.Append('"ServerRedirectedEmbedUrl":"",');
        ResponseContent.Append('"ID":2,');
        ResponseContent.Append('"ContentTypeId":"0x0100386AEFB9434E704081AB02149FB55A74008FA0CDB720117949A23770C25BF4E510",');
        ResponseContent.Append('"Title":"Test List Item 2",');
        ResponseContent.Append('"Modified":"2022-07-08T20:37:53Z",');
        ResponseContent.Append('"Created":"2022-05-31T10:40:22Z",');
        ResponseContent.Append('"AuthorId":9,');
        ResponseContent.Append('"EditorId":9,');
        ResponseContent.Append('"OData__UIVersionString":"2.0",');
        ResponseContent.Append('"Attachments":true,');
        ResponseContent.Append('"GUID":"74c31296-cbf2-4c4a-a133-6a5bcaf39a96",');
        ResponseContent.Append('"ComplianceAssetId":null');
        ResponseContent.Append('}');
        ResponseContent.Append(']');
        ResponseContent.Append('}');

        ResponseContent.Replace('{baseUrl}', BaseUrl);
        ResponseContent.Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent.ToText(), HttpHeaders, 200, true, 'OK');
    end;

    local procedure GetListItemAttachmentsTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: TextBuilder;
    begin
        ResponseContent.Append('{');
        ResponseContent.Append('"odata.metadata":"{baseUrl}_api/$metadata#SP.ApiData.Attachments",');
        ResponseContent.Append('"value": [');
        ResponseContent.Append('{');
        ResponseContent.Append('"odata.type":"SP.Attachment",');
        ResponseContent.Append('"odata.id":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)/AttachmentFiles(''Test Picture.jpg'')",');
        ResponseContent.Append('"odata.editLink":"Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)/AttachmentFiles(''Test%20Picture.jpg'')",');
        ResponseContent.Append('"FileName":"Test Picture.jpg",');
        ResponseContent.Append('"FileNameAsPath":{');
        ResponseContent.Append('"DecodedUrl":"Test Picture.jpg"');
        ResponseContent.Append('},');
        ResponseContent.Append('"ServerRelativePath":{');
        ResponseContent.Append('"DecodedUrl":"{parentUrl}/Lists/Asset Documents/Attachments/1/Test Picture.jpg"');
        ResponseContent.Append('},');
        ResponseContent.Append('"ServerRelativeUrl":"{parentUrl}/Lists/Asset Documents/Attachments/1/Test Picture.jpg"');
        ResponseContent.Append('},');
        ResponseContent.Append('{');
        ResponseContent.Append('"odata.type":"SP.Attachment",');
        ResponseContent.Append('"odata.id":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)/AttachmentFiles(''Test_Image.jpg'')",');
        ResponseContent.Append('"odata.editLink":"Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)/AttachmentFiles(''Test_Image.jpg'')",');
        ResponseContent.Append('"FileName":"Test_Image.jpg",');
        ResponseContent.Append('"FileNameAsPath":{');
        ResponseContent.Append('"DecodedUrl":"Test_Image.jpg"');
        ResponseContent.Append('},');
        ResponseContent.Append('"ServerRelativePath":{');
        ResponseContent.Append('"DecodedUrl":"{parentUrl}/Lists/Asset Documents/Attachments/1/Test_Image.jpg"');
        ResponseContent.Append('},');
        ResponseContent.Append('"ServerRelativeUrl":"{parentUrl}/Lists/Asset Documents/Attachments/1/Test_Image.jpg"');
        ResponseContent.Append('}');
        ResponseContent.Append(']');
        ResponseContent.Append('}');

        ResponseContent.Replace('{baseUrl}', BaseUrl);
        ResponseContent.Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent.ToText(), HttpHeaders, 200, true, 'OK');
    end;

    local procedure CreateListItemAttachmentTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: TextBuilder;
    begin
        ResponseContent.Append('{');
        ResponseContent.Append('"d":{');
        ResponseContent.Append('"__metadata":{');
        ResponseContent.Append('"id":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)/AttachmentFiles(''Sample_file.txt'')",');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)/AttachmentFiles(''Sample_file.txt'')",');
        ResponseContent.Append('"type":"SP.Attachment"');
        ResponseContent.Append('},');
        ResponseContent.Append('"FileName":"Sample_file.txt",');
        ResponseContent.Append('"FileNameAsPath":{');
        ResponseContent.Append('"__metadata":{');
        ResponseContent.Append('"type":"SP.ResourcePath"');
        ResponseContent.Append('},');
        ResponseContent.Append('"DecodedUrl":"Sample_file.txt"');
        ResponseContent.Append('},');
        ResponseContent.Append('"ServerRelativePath":{');
        ResponseContent.Append('"__metadata":{');
        ResponseContent.Append('"type":"SP.ResourcePath"');
        ResponseContent.Append('},');
        ResponseContent.Append('"DecodedUrl":"{parentUrl}/Lists/Asset Documents/Attachments/1/Sample_file.txt"');
        ResponseContent.Append('},');
        ResponseContent.Append('"ServerRelativeUrl":"{parentUrl}/Lists/Asset Documents/Attachments/1/Sample_file.txt"');
        ResponseContent.Append('}');
        ResponseContent.Append('}');

        ResponseContent.Replace('{baseUrl}', BaseUrl);
        ResponseContent.Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent.ToText(), HttpHeaders, 200, true, 'OK');
    end;

    local procedure CreateListItemTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: TextBuilder;
    begin
        ResponseContent.Append('{');
        ResponseContent.Append('"d":{');
        ResponseContent.Append('"__metadata":{');
        ResponseContent.Append('"id":"02be316a-e242-44d1-8bd9-3587e1fff887",');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)",');
        ResponseContent.Append('"etag":"1",');
        ResponseContent.Append('"type":"SP.Data.My_x0020_Test_x0020_DocumentsListItem"');
        ResponseContent.Append('},');
        ResponseContent.Append('"FirstUniqueAncestorSecurableObject":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/FirstUniqueAncestorSecurableObject"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"RoleAssignments":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/RoleAssignments"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"AttachmentFiles":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/AttachmentFiles"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"ContentType":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/ContentType"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"GetDlpPolicyTip":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"https://{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/GetDlpPolicyTip"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"FieldValuesAsHtml":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"https://{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/FieldValuesAsHtml"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"FieldValuesAsText":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"https://{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/FieldValuesAsText"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"FieldValuesForEdit":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/FieldValuesForEdit"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"File":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/File"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"Folder":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/Folder"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"LikedByInformation":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/LikedByInformation"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"ParentList":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/ParentList"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"Properties":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/Properties"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"Versions":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/Versions"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"FileSystemObjectType":0,');
        ResponseContent.Append('"Id":3,');
        ResponseContent.Append('"ServerRedirectedEmbedUri":null,');
        ResponseContent.Append('"ServerRedirectedEmbedUrl":"",');
        ResponseContent.Append('"ID":3,');
        ResponseContent.Append('"ContentTypeId":"0x0100386AEFB9434E704081AB02149FB55A74008FA0CDB720117949A23770C25BF4E510",');
        ResponseContent.Append('"Title":"Test Item",');
        ResponseContent.Append('"Modified":"2022-07-15T08:31:30Z",');
        ResponseContent.Append('"Created":"2022-07-15T08:31:30Z",');
        ResponseContent.Append('"AuthorId":9,');
        ResponseContent.Append('"EditorId":9,');
        ResponseContent.Append('"OData__UIVersionString":"1.0",');
        ResponseContent.Append('"Attachments":false,');
        ResponseContent.Append('"GUID":"17bf42f2-2560-4452-b0cb-df674ac734f1",');
        ResponseContent.Append('"ComplianceAssetId":null');
        ResponseContent.Append('}');
        ResponseContent.Append('}');

        ResponseContent.Replace('{baseUrl}', BaseUrl);
        ResponseContent.Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent.ToText(), HttpHeaders, 201, true, 'CREATED');
    end;

    local procedure CreateListTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: TextBuilder;
    begin
        ResponseContent.Append('{');
        ResponseContent.Append('"d":{');
        ResponseContent.Append('"__metadata":{');
        ResponseContent.Append('"id":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')",');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')",');
        ResponseContent.Append('"etag":"1",');
        ResponseContent.Append('"type":"SP.List"');
        ResponseContent.Append('},');
        ResponseContent.Append('"FirstUniqueAncestorSecurableObject":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/FirstUniqueAncestorSecurableObject"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"RoleAssignments":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/RoleAssignments"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"Author":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/Author"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"ContentTypes":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/ContentTypes"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"CreatablesInfo":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/CreatablesInfo"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"DefaultView":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/DefaultView"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"DescriptionResource":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/DescriptionResource"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"EventReceivers":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/EventReceivers"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"Fields":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/Fields"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"Forms":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/Forms"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"InformationRightsManagementSettings":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/InformationRightsManagementSettings"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"Items":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/Items"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"ParentWeb":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/ParentWeb"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"RootFolder":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/RootFolder"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"Subscriptions":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/Subscriptions"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"TitleResource":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/TitleResource"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"UserCustomActions":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/UserCustomActions"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"Views":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/Views"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"WorkflowAssociations":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/WorkflowAssociations"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"AllowContentTypes":true,');
        ResponseContent.Append('"BaseTemplate":100,');
        ResponseContent.Append('"BaseType":0,');
        ResponseContent.Append('"ContentTypesEnabled":true,');
        ResponseContent.Append('"CrawlNonDefaultViews":false,');
        ResponseContent.Append('"Created":"2022-07-15T11:45:34Z",');
        ResponseContent.Append('"CurrentChangeToken":{');
        ResponseContent.Append('"__metadata":{');
        ResponseContent.Append('"type":"SP.ChangeToken"');
        ResponseContent.Append('},');
        ResponseContent.Append('"StringValue":"1;3;b3cf160f-d953-49d3-bf3e-5704dee4559e;637934823340800000;290869285"');
        ResponseContent.Append('},');
        ResponseContent.Append('"DefaultContentApprovalWorkflowId":"00000000-0000-0000-0000-000000000000",');
        ResponseContent.Append('"DefaultItemOpenUseListSetting":false,');
        ResponseContent.Append('"Description":"Test Sample List Description",');
        ResponseContent.Append('"Direction":"none",');
        ResponseContent.Append('"DisableCommenting":false,');
        ResponseContent.Append('"DisableGridEditing":false,');
        ResponseContent.Append('"DocumentTemplateUrl":null,');
        ResponseContent.Append('"DraftVersionVisibility":0,');
        ResponseContent.Append('"EnableAttachments":true,');
        ResponseContent.Append('"EnableFolderCreation":false,');
        ResponseContent.Append('"EnableMinorVersions":false,');
        ResponseContent.Append('"EnableModeration":false,');
        ResponseContent.Append('"EnableRequestSignOff":true,');
        ResponseContent.Append('"EnableVersioning":true,');
        ResponseContent.Append('"EntityTypeName":"Test_x0020_Sample_x0020_List_x0020_TitleList",');
        ResponseContent.Append('"ExemptFromBlockDownloadOfNonViewableFiles":false,');
        ResponseContent.Append('"FileSavePostProcessingEnabled":false,');
        ResponseContent.Append('"ForceCheckout":false,');
        ResponseContent.Append('"HasExternalDataSource":false,');
        ResponseContent.Append('"Hidden":false,');
        ResponseContent.Append('"Id":"b3cf160f-d953-49d3-bf3e-5704dee4559e",');
        ResponseContent.Append('"ImagePath":{');
        ResponseContent.Append('"__metadata":{');
        ResponseContent.Append('"type":"SP.ResourcePath"');
        ResponseContent.Append('},');
        ResponseContent.Append('"DecodedUrl":"/_layouts/15/images/itgen.png?rev=47"');
        ResponseContent.Append('},');
        ResponseContent.Append('"ImageUrl":"/_layouts/15/images/itgen.png?rev=47",');
        ResponseContent.Append('"DefaultSensitivityLabelForLibrary":"",');
        ResponseContent.Append('"IrmEnabled":false,');
        ResponseContent.Append('"IrmExpire":false,');
        ResponseContent.Append('"IrmReject":false,');
        ResponseContent.Append('"IsApplicationList":false,');
        ResponseContent.Append('"IsCatalog":false,');
        ResponseContent.Append('"IsPrivate":false,');
        ResponseContent.Append('"ItemCount":0,');
        ResponseContent.Append('"LastItemDeletedDate":"2022-07-15T11:45:34Z",');
        ResponseContent.Append('"LastItemModifiedDate":"2022-07-15T11:45:34Z",');
        ResponseContent.Append('"LastItemUserModifiedDate":"2022-07-15T11:45:34Z",');
        ResponseContent.Append('"ListExperienceOptions":0,');
        ResponseContent.Append('"ListItemEntityTypeFullName":"SP.Data.Test_x0020_Sample_x0020_List_x0020_TitleListItem",');
        ResponseContent.Append('"MajorVersionLimit":50,');
        ResponseContent.Append('"MajorWithMinorVersionsLimit":0,');
        ResponseContent.Append('"MultipleDataList":false,');
        ResponseContent.Append('"NoCrawl":false,');
        ResponseContent.Append('"ParentWebPath":{');
        ResponseContent.Append('"__metadata":{');
        ResponseContent.Append('"type":"SP.ResourcePath"');
        ResponseContent.Append('},');
        ResponseContent.Append('"DecodedUrl":"/sites/Test"');
        ResponseContent.Append('},');
        ResponseContent.Append('"ParentWebUrl":"/sites/Test",');
        ResponseContent.Append('"ParserDisabled":false,');
        ResponseContent.Append('"ServerTemplateCanCreateFolders":true,');
        ResponseContent.Append('"TemplateFeatureId":"00bfea71-de22-43b2-a848-c05709900100",');
        ResponseContent.Append('"Title":"Test Sample List Title"');
        ResponseContent.Append('}');
        ResponseContent.Append('}');

        ResponseContent.Replace('{baseUrl}', BaseUrl);
        ResponseContent.Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent.ToText(), HttpHeaders, 201, true, 'CREATED');
    end;

    local procedure GetDocumentLibraryRootFolderTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: TextBuilder;
    begin
        ResponseContent.Append('{');
        ResponseContent.Append('"odata.metadata":"{baseUrl}_api/$metadata#SP.ApiData.Folders1/@Element",');
        ResponseContent.Append('"odata.type":"SP.Folder",');
        ResponseContent.Append('"odata.id":"{baseUrl}_api/Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test Documents'')",');
        ResponseContent.Append('"odata.editLink":"Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents'')",');
        ResponseContent.Append('"Exists":true,');
        ResponseContent.Append('"IsWOPIEnabled":false,');
        ResponseContent.Append('"ItemCount":2,');
        ResponseContent.Append('"Name":"Test Documents",');
        ResponseContent.Append('"ProgID":null,');
        ResponseContent.Append('"ServerRelativeUrl":"{parentUrl}/Lists/Test Documents",');
        ResponseContent.Append('"TimeCreated":"2022-05-23T12:16:04Z",');
        ResponseContent.Append('"TimeLastModified":"2022-07-15T08:31:30Z",');
        ResponseContent.Append('"UniqueId":"05270e8a-3027-47c8-aff4-36a499486b92",');
        ResponseContent.Append('"WelcomePage":""');
        ResponseContent.Append('}');

        ResponseContent.Replace('{baseUrl}', BaseUrl);
        ResponseContent.Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent.ToText(), HttpHeaders, 200, true, 'OK');
    end;

    local procedure GetFolderBySeverRelativeUrlTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: TextBuilder;
    begin
        ResponseContent.Append('{');
        ResponseContent.Append('"odata.metadata":"{baseUrl}/_api/$metadata#SP.ApiData.Folders1",');
        ResponseContent.Append('"value":[');
        ResponseContent.Append('{');
        ResponseContent.Append('"odata.type":"SP.Folder",');
        ResponseContent.Append('"odata.id":"{baseUrl}_api/Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test Documents/Attachments'')",');
        ResponseContent.Append('"odata.editLink":"Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments'')",');
        ResponseContent.Append('"Exists":true,');
        ResponseContent.Append('"IsWOPIEnabled":false,');
        ResponseContent.Append('"ItemCount":0,');
        ResponseContent.Append('"Name":"Attachments",');
        ResponseContent.Append('"ProgID":null,');
        ResponseContent.Append('"ServerRelativeUrl":"{parentUrl}/Lists/Test Documents/Attachments",');
        ResponseContent.Append('"TimeCreated":"2022-05-23T12:16:04Z",');
        ResponseContent.Append('"TimeLastModified":"2022-05-23T12:16:04Z",');
        ResponseContent.Append('"UniqueId":"30c845cf-46b5-4edb-9c8d-018a609c2110",');
        ResponseContent.Append('"WelcomePage":""');
        ResponseContent.Append('}');
        ResponseContent.Append(']');
        ResponseContent.Append('}');

        ResponseContent.Replace('{baseUrl}', BaseUrl);
        ResponseContent.Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent.ToText(), HttpHeaders, 200, true, 'OK');
    end;

    local procedure GetFolderFilesByServerRelativeUrlTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: TextBuilder;
    begin
        ResponseContent.Append('{');
        ResponseContent.Append('"odata.metadata":"{baseUrl}/_api/$metadata#SP.ApiData.Files12",');
        ResponseContent.Append('"value":[');
        ResponseContent.Append('{');
        ResponseContent.Append('"odata.type": "SP.File",');
        ResponseContent.Append('"odata.id":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test Documents/Attachments/1/document.pdf'')",');
        ResponseContent.Append('"odata.editLink":"Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/1/document.pdf'')",');
        ResponseContent.Append('"CheckInComment":"",');
        ResponseContent.Append('"CheckOutType":2,');
        ResponseContent.Append('"ContentTag":"{FB9CD74F-610B-4AC5-99F1-3CCD5C6CE7EE},1,1",');
        ResponseContent.Append('"CustomizedPageStatus":0,');
        ResponseContent.Append('"ETag": "{FB9CD74F-610B-4AC5-99F1-3CCD5C6CE7EE}",');
        ResponseContent.Append('"Exists":true,');
        ResponseContent.Append('"IrmEnabled":false,');
        ResponseContent.Append('"Length":"25555",');
        ResponseContent.Append('"Level":1,');
        ResponseContent.Append('"LinkingUri":null,');
        ResponseContent.Append('"LinkingUrl":"",');
        ResponseContent.Append('"MajorVersion":1,');
        ResponseContent.Append('"MinorVersion":0,');
        ResponseContent.Append('"Name":"document.pdf",');
        ResponseContent.Append('"ServerRelativeUrl":"{parentUrl}/Lists/Test Documents/Attachments/1/document.pdf",');
        ResponseContent.Append('"TimeCreated":"2022-07-14T22:14:33Z",');
        ResponseContent.Append('"TimeLastModified":"2022-07-14T22:14:33Z",');
        ResponseContent.Append('"Title":null,');
        ResponseContent.Append('"UIVersion":512,');
        ResponseContent.Append('"UIVersionLabel":"1.0",');
        ResponseContent.Append('"UniqueId":"fb9cd74f-610b-4ac5-99f1-3ccd5c6ce7ee"');
        ResponseContent.Append('},');
        ResponseContent.Append('{');
        ResponseContent.Append('"odata.type":"SP.File",');
        ResponseContent.Append('"odata.id":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test Documents/Attachments/1/Test_img.jpg'')",');
        ResponseContent.Append('"odata.editLink":"Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test %20Documents/Attachments/1/Test_img.jpg'')",');
        ResponseContent.Append('"CheckInComment":"",');
        ResponseContent.Append('"CheckOutType":2,');
        ResponseContent.Append('"ContentTag":"{B490A83A-757C-4F30-85EB-8010302FF941},1,2",');
        ResponseContent.Append('"CustomizedPageStatus":0,');
        ResponseContent.Append('"ETag":"{B490A83A-757C-4F30-85EB-8010302FF941}",');
        ResponseContent.Append('"Exists":true,');
        ResponseContent.Append('"IrmEnabled":false,');
        ResponseContent.Append('"Length":"455816",');
        ResponseContent.Append('"Level":1,');
        ResponseContent.Append('"LinkingUri":null,');
        ResponseContent.Append('"LinkingUrl":"",');
        ResponseContent.Append('"MajorVersion":1,');
        ResponseContent.Append('"MinorVersion":0,');
        ResponseContent.Append('"Name":"Test_img.jpg",');
        ResponseContent.Append('"ServerRelativeUrl":"{parentUrl}/Lists/Test Documents/Attachments/1/Test_img.jpg",');
        ResponseContent.Append('"TimeCreated":"2022-05-31T11:45:25Z",');
        ResponseContent.Append('"TimeLastModified":"2022-05-31T11:45:25Z",');
        ResponseContent.Append('"Title":null,');
        ResponseContent.Append('"UIVersion":512,');
        ResponseContent.Append('"UIVersionLabel":"1.0",');
        ResponseContent.Append('"UniqueId":"b490a83a-757c-4f30-85eb-8010302ff941"');
        ResponseContent.Append('}');
        ResponseContent.Append(']');
        ResponseContent.Append('}');

        ResponseContent.Replace('{baseUrl}', BaseUrl);
        ResponseContent.Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent.ToText(), HttpHeaders, 200, true, 'OK');
    end;

    local procedure CreateFolderTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: TextBuilder;
    begin

        ResponseContent.Append('{');
        ResponseContent.Append('"d":{');
        ResponseContent.Append('"__metadata":{');
        ResponseContent.Append('"id":"{baseUrl}_api/Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test Documents/Attachments/TestSubfolder'')",');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/TestSubfolder'')",');
        ResponseContent.Append('"type":"SP.Folder"');
        ResponseContent.Append('},');
        ResponseContent.Append('"Files":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/TestSubfolder'')/Files"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"ListItemAllFields":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/TestSubfolder'')/ListItemAllFields"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"ParentFolder":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/TestSubfolder'')/ParentFolder"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"Properties":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/TestSubfolder'')/Properties"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"StorageMetrics":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/TestSubfolder'')/StorageMetrics"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"Folders":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/TestSubfolder'')/Folders"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"Exists":true,');
        ResponseContent.Append('"IsWOPIEnabled":false,');
        ResponseContent.Append('"ItemCount":0,');
        ResponseContent.Append('"Name":"TestSubfolder",');
        ResponseContent.Append('"ProgID":null,');
        ResponseContent.Append('"ServerRelativeUrl":"{parentUrl}/Lists/Test Documents/Attachments/TestSubfolder",');
        ResponseContent.Append('"TimeCreated":"2022-07-15T20:40:25Z",');
        ResponseContent.Append('"TimeLastModified":"2022-07-15T20:40:25Z",');
        ResponseContent.Append('"UniqueId":"922ba9b1-c26d-417f-8ecb-79d71ebfa22e",');
        ResponseContent.Append('"WelcomePage":""');
        ResponseContent.Append('}');
        ResponseContent.Append('}');

        ResponseContent.Replace('{baseUrl}', BaseUrl);
        ResponseContent.Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent.ToText(), HttpHeaders, 201, true, 'CREATED');
    end;

    local procedure AddFileToFolderTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: TextBuilder;
    begin
        ResponseContent.Append('{');
        ResponseContent.Append('"d":{');
        ResponseContent.Append('"__metadata":{');
        ResponseContent.Append('"id":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test Documents/Attachments/SampleTestFile.jpg'')",');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')",');
        ResponseContent.Append('"type":"SP.File"');
        ResponseContent.Append('},');
        ResponseContent.Append('"Author":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')/Author"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"CheckedOutByUser":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')/CheckedOutByUser"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"EffectiveInformationRightsManagementSettings":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')/EffectiveInformationRightsManagementSettings"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"InformationRightsManagementSettings":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')/InformationRightsManagementSettings"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"ListItemAllFields":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')/ListItemAllFields"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"LockedByUser":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')/LockedByUser"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"ModifiedBy":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')/ModifiedBy"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"Properties":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')/Properties"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"VersionEvents":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')/VersionEvents"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"Versions":{');
        ResponseContent.Append('"__deferred":{');
        ResponseContent.Append('"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')/Versions"');
        ResponseContent.Append('}');
        ResponseContent.Append('},');
        ResponseContent.Append('"CheckInComment":"",');
        ResponseContent.Append('"CheckOutType":2,');
        ResponseContent.Append('"ContentTag":"{0B217604-0507-44FD-BC88-8727C911EEE5},1,2",');
        ResponseContent.Append('"CustomizedPageStatus":0,');
        ResponseContent.Append('"ETag":"{0B217604-0507-44FD-BC88-8727C911EEE5}",');
        ResponseContent.Append('"Exists":true,');
        ResponseContent.Append('"IrmEnabled":false,');
        ResponseContent.Append('"Length":"44087",');
        ResponseContent.Append('"Level":1,');
        ResponseContent.Append('"LinkingUri":null,');
        ResponseContent.Append('"LinkingUrl":"",');
        ResponseContent.Append('"MajorVersion":1,');
        ResponseContent.Append('"MinorVersion":0,');
        ResponseContent.Append('"Name":"SampleTestFile.jpg",');
        ResponseContent.Append('"ServerRelativeUrl":"{parentUrl}/Lists/Test Documents/Attachments/SampleTestFile.jpg",');
        ResponseContent.Append('"TimeCreated":"2022-07-15T21:13:18Z",');
        ResponseContent.Append('"TimeLastModified":"2022-07-15T21:13:18Z",');
        ResponseContent.Append('"Title":null,');
        ResponseContent.Append('"UIVersion":512,');
        ResponseContent.Append('"UIVersionLabel":"1.0",');
        ResponseContent.Append('"UniqueId":"0b217604-0507-44fd-bc88-8727c911eee5"');
        ResponseContent.Append('}');
        ResponseContent.Append('}');

        ResponseContent.Replace('{baseUrl}', BaseUrl);
        ResponseContent.Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent.ToText(), HttpHeaders, 200, true, 'OK');
    end;

    local procedure GetDetailedErrorResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response")
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: TextBuilder;
    begin
        ResponseContent.Append('{');
        ResponseContent.Append('"error_description":"Invalid JWT token. The token is expired."');
        ResponseContent.Append('}');
        SharePointOperationResponse.SetHttpResponse(ResponseContent.ToText(), HttpHeaders, 401, false, 'Unauthorized');
    end;

    local procedure GetTooManyRequestsResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response")
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: Text;
    begin
        ResponseContent := '429 TOO MANY REQUESTS';
        HttpHeaders.Add('Retry-after', '5');
        SharePointOperationResponse.SetHttpResponse(ResponseContent, HttpHeaders, 429, false, 'TooManyRequests');
    end;

}