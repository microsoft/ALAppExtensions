Codeunit 132971 "SharePoint Test Library"
{

    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SharePoint Request Manager", 'OnBeforeSendRequest', '', false, false)]
    local procedure RunOnBeforeSendRequest(HttpRequestMessage: HttpRequestMessage; var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; var IsHandled: Boolean; Method: Text)
    var
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
            GetTooManyRequestsResponse(SharePointOperationResponse, BaseUrl, ParentUrl);
            exit;
        end;

        if Uri.EndsWith('/_api/Web/Lists(guid''549F3387-C984-4969-95DE-4F405CCB4EA9'')/items/') then begin
            GetDetailedErrorResponse(SharePointOperationResponse, BaseUrl, ParentUrl);
            exit;
        end;

        if Uri.EndsWith('/_api/Web/Lists(guid''854D7F21-1C6A-43AB-A081-20404894B449'')/items/') or Uri.EndsWith('/_api/Web/lists/GetByTitle(''Test%20Documents'')/items/') then begin
            if Method = 'GET' then begin
                GetListItemsTestResponse(SharePointOperationResponse, BaseUrl, ParentUrl);
                exit;
            end;
            if Method = 'POST' then begin
                CreateListItemTestResponse(SharePointOperationResponse, BaseUrl, ParentUrl);
                exit;
            end;
        end;

        if Uri.EndsWith('_api/Web/Lists(guid''854D7F21-1C6A-43AB-A081-20404894B449'')/Items(1)/AttachmentFiles/') or Uri.EndsWith('/_api/Web/lists/GetByTitle(''Test%20Documents'')/Items(1)/AttachmentFiles/') then begin
            GetListItemAttachmentsTestResponse(SharePointOperationResponse, BaseUrl, ParentUrl);
            exit;
        end;

        if Uri.EndsWith('_api/Web/Lists(guid''854D7F21-1C6A-43AB-A081-20404894B449'')/Items(1)/AttachmentFiles/add(FileName=''Sample_file.txt'')/') or Uri.EndsWith('/_api/Web/lists/GetByTitle(''Test%20Documents'')/Items(1)/AttachmentFiles/add(FileName=''Sample_file.txt'')/') then begin
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
        ResponseContent: Text;
    begin
        ResponseContent := '{';
        ResponseContent += '"d":{';
        ResponseContent += '"GetContextWebInformation":{';
        ResponseContent += '"__metadata":{';
        ResponseContent += '"type":"SP.ContextWebInformation"';
        ResponseContent += '},';
        ResponseContent += '"FormDigestTimeoutSeconds":1800,';
        ResponseContent += '"FormDigestValue":"0xCC9B958136D1BA6D100A038315EC4E58C093661D4D102E1EFB9D8814641E42CD4D0C12B7BCF4AC44183E2C28A67925708048F3CC900D6ACE164DD33A45A884C5,15 Jul 2022 11:00:55 -0000",';
        ResponseContent += '"LibraryVersion":"16.0.22629.12003",';
        ResponseContent += '"SiteFullUrl":"{baseUrl}",';
        ResponseContent += '"SupportedSchemaVersions":{';
        ResponseContent += '"__metadata":{';
        ResponseContent += '"type":"Collection(Edm.String)"';
        ResponseContent += '},';
        ResponseContent += '"results":[';
        ResponseContent += '"14.0.0.0",';
        ResponseContent += '"15.0.0.0"';
        ResponseContent += ']';
        ResponseContent += '},';
        ResponseContent += '"WebFullUrl":"{baseUrl}"';
        ResponseContent += '}';
        ResponseContent += '}';
        ResponseContent += '}';

        ResponseContent := ResponseContent.Replace('{baseUrl}', BaseUrl).Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent, HttpHeaders, 200, true, 'OK');
    end;

    local procedure GetListsTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: Text;
    begin
        ResponseContent := '{';
        ResponseContent += '"odata.metadata":"{baseUrl}_api/$metadata#SP.ApiData.Lists",';
        ResponseContent += '"value": [';
        ResponseContent += '{';
        ResponseContent += '"odata.type":"SP.List",';
        ResponseContent += '"odata.id":"{baseUrl}_api/Web/Lists(guid''71b5c280-f303-46fa-b818-755bf9b91837'')",';
        ResponseContent += '"odata.etag":"0",';
        ResponseContent += '"odata.editLink":"Web/Lists(guid''71b5c280-f303-46fa-b818-755bf9b91837'')",';
        ResponseContent += '"AllowContentTypes":true,';
        ResponseContent += '"BaseTemplate":125,';
        ResponseContent += '"BaseType":0,';
        ResponseContent += '"ContentTypesEnabled":false,';
        ResponseContent += '"CrawlNonDefaultViews":false,';
        ResponseContent += '"Created":"2022-03-06T00:39:32Z",';
        ResponseContent += '"CurrentChangeToken":{"StringValue":"1;3;71b5c280-f303-46fa-b818-755bf9b91837;637933377461200000;290418294"},';
        ResponseContent += '"DefaultContentApprovalWorkflowId":"00000000-0000-0000-0000-000000000000",';
        ResponseContent += '"DefaultItemOpenUseListSetting":false,';
        ResponseContent += '"Description":"",';
        ResponseContent += '"Direction":"none",';
        ResponseContent += '"DisableCommenting":false,';
        ResponseContent += '"DisableGridEditing":false,';
        ResponseContent += '"DocumentTemplateUrl":null,';
        ResponseContent += '"EnableAttachments":true,';
        ResponseContent += '"EnableFolderCreation":true,';
        ResponseContent += '"EnableMinorVersions":false,';
        ResponseContent += '"EnableModeration":false,';
        ResponseContent += '"EnableRequestSignOff":true,';
        ResponseContent += '"EnableVersioning":false,';
        ResponseContent += '"EntityTypeName":"OData__x005f_catalogs_x002f_appdata",';
        ResponseContent += '"ExemptFromBlockDownloadOfNonViewableFiles":false,';
        ResponseContent += '"FileSavePostProcessingEnabled":false,';
        ResponseContent += '"ForceCheckout":false,';
        ResponseContent += '"HasExternalDataSource":false,';
        ResponseContent += '"Hidden":true,';
        ResponseContent += '"Id":"71b5c280-f303-46fa-b818-755bf9b91837",';
        ResponseContent += '"ImagePath":{"DecodedUrl":"/_layouts/15/images/itgen.png?rev=47"},';
        ResponseContent += '"ImageUrl":"/_layouts/15/images/itgen.png?rev=47",';
        ResponseContent += '"DefaultSensitivityLabelForLibrary":"",';
        ResponseContent += '"IrmEnabled":false,';
        ResponseContent += '"IrmExpire":false,';
        ResponseContent += '"IrmReject":false,';
        ResponseContent += '"IsApplicationList":false,';
        ResponseContent += '"IsCatalog":false,';
        ResponseContent += '"IsPrivate":false,';
        ResponseContent += '"ItemCount":0,';
        ResponseContent += '"LastItemDeletedDate":"2022-03-06T00:39:32Z",';
        ResponseContent += '"LastItemModifiedDate":"2022-03-06T00:39:32Z",';
        ResponseContent += '"LastItemUserModifiedDate":"2022-03-06T00:39:32Z",';
        ResponseContent += '"ListExperienceOptions":0,';
        ResponseContent += '"ListItemEntityTypeFullName":"SP.Data.OData__x005f_catalogs_x002f_appdataItem",';
        ResponseContent += '"MajorVersionLimit":0,';
        ResponseContent += '"MajorWithMinorVersionsLimit":0,';
        ResponseContent += '"MultipleDataList":false,';
        ResponseContent += '"NoCrawl":true,';
        ResponseContent += '"ParentWebPath":{"DecodedUrl":"{parentUrl}"},';
        ResponseContent += '"ParentWebUrl":"{parentUrl}",';
        ResponseContent += '"ParserDisabled":false,';
        ResponseContent += '"ServerTemplateCanCreateFolders":true,';
        ResponseContent += '"TemplateFeatureId":"00000000-0000-0000-0000-000000000000",';
        ResponseContent += '"Title":"appdata"';
        ResponseContent += '},';
        ResponseContent += '{';
        ResponseContent += '"odata.type":"SP.List",';
        ResponseContent += '"odata.id":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')",';
        ResponseContent += '"odata.etag":"5",';
        ResponseContent += '"odata.editLink":"Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')",';
        ResponseContent += '"AllowContentTypes":true,';
        ResponseContent += '"BaseTemplate":100,';
        ResponseContent += '"BaseType":0,';
        ResponseContent += '"ContentTypesEnabled":false,';
        ResponseContent += '"CrawlNonDefaultViews":false,';
        ResponseContent += '"Created":"2022-05-23T12:16:04Z",';
        ResponseContent += '"CurrentChangeToken":{"StringValue":"1;3;854d7f21-1c6a-43ab-a081-20404894b449;637933377461200000;290418294"},';
        ResponseContent += '"DefaultContentApprovalWorkflowId":"00000000-0000-0000-0000-000000000000",';
        ResponseContent += '"DefaultItemOpenUseListSetting":false,';
        ResponseContent += '"Description":"My Test Documents",';
        ResponseContent += '"Direction":"none",';
        ResponseContent += '"DisableCommenting":false,';
        ResponseContent += '"DisableGridEditing":false,';
        ResponseContent += '"DocumentTemplateUrl":null,';
        ResponseContent += '"DraftVersionVisibility":0,';
        ResponseContent += '"EnableAttachments":true,';
        ResponseContent += '"EnableFolderCreation":false,';
        ResponseContent += '"EnableMinorVersions":false,';
        ResponseContent += '"EnableModeration":false,';
        ResponseContent += '"EnableRequestSignOff":true,';
        ResponseContent += '"EnableVersioning":true,';
        ResponseContent += '"EntityTypeName":"My_x0020_Asset_x0020_DocumentsList",';
        ResponseContent += '"ExemptFromBlockDownloadOfNonViewableFiles":false,';
        ResponseContent += '"FileSavePostProcessingEnabled":false,';
        ResponseContent += '"ForceCheckout":false,';
        ResponseContent += '"HasExternalDataSource":false,';
        ResponseContent += '"Hidden":false,';
        ResponseContent += '"Id":"854d7f21-1c6a-43ab-a081-20404894b449",';
        ResponseContent += '"ImagePath":{"DecodedUrl":"/_layouts/15/images/itgen.png?rev=47"},';
        ResponseContent += '"ImageUrl":"/_layouts/15/images/itgen.png?rev=47",';
        ResponseContent += '"DefaultSensitivityLabelForLibrary":"",';
        ResponseContent += '"IrmEnabled":false,';
        ResponseContent += '"IrmExpire":false,';
        ResponseContent += '"IrmReject":false,';
        ResponseContent += '"IsApplicationList":false,';
        ResponseContent += '"IsCatalog":false,';
        ResponseContent += '"IsPrivate":false,';
        ResponseContent += '"ItemCount":2,';
        ResponseContent += '"LastItemDeletedDate":"2022-05-31T11:43:35Z",';
        ResponseContent += '"LastItemModifiedDate":"2022-07-08T21:11:10Z",';
        ResponseContent += '"LastItemUserModifiedDate":"2022-07-08T21:11:10Z",';
        ResponseContent += '"ListExperienceOptions":0,';
        ResponseContent += '"ListItemEntityTypeFullName":"SP.Data.My_x0020_Test_x0020_DocumentsListItem",';
        ResponseContent += '"MajorVersionLimit":50,';
        ResponseContent += '"MajorWithMinorVersionsLimit":0,';
        ResponseContent += '"MultipleDataList":false,';
        ResponseContent += '"NoCrawl":false,';
        ResponseContent += '"ParentWebPath":{"DecodedUrl":"{parentUrl}"},';
        ResponseContent += '"ParentWebUrl":"{parentUrl}",';
        ResponseContent += '"ParserDisabled":false,';
        ResponseContent += '"ServerTemplateCanCreateFolders":true,';
        ResponseContent += '"TemplateFeatureId":"00bfea71-de22-43b2-a848-c05709900100",';
        ResponseContent += '"Title":"Test Documents"';
        ResponseContent += '}';
        ResponseContent += ']';
        ResponseContent += '}';

        ResponseContent := ResponseContent.Replace('{baseUrl}', BaseUrl).Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent, HttpHeaders, 200, true, 'OK');
    end;

    local procedure GetListItemsTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: Text;
    begin
        ResponseContent := '{';
        ResponseContent += '"odata.metadata":"{baseUrl}_api/$metadata#SP.ListData.Asset_x0020_DocumentsListItems",';
        ResponseContent += '"value": [';
        ResponseContent += '{';
        ResponseContent += '"odata.type":"SP.Data.Asset_x0020_DocumentsListItem",';
        ResponseContent += '"odata.id":"fbccfcf6-28bf-4f63-97bb-f1daa8955b6e",';
        ResponseContent += '"odata.etag":"30",';
        ResponseContent += '"odata.editLink":"Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)",';
        ResponseContent += '"FileSystemObjectType":0,';
        ResponseContent += '"Id":1,';
        ResponseContent += '"ServerRedirectedEmbedUri":null,';
        ResponseContent += '"ServerRedirectedEmbedUrl":"",';
        ResponseContent += '"ID":1,';
        ResponseContent += '"ContentTypeId":"0x0100386AEFB9434E704081AB02149FB55A74008FA0CDB720117949A23770C25BF4E510",';
        ResponseContent += '"Title":"Test List Item",';
        ResponseContent += '"Modified":"2022-05-31T12:31:57Z",';
        ResponseContent += '"Created":"2022-05-23T12:16:29Z",';
        ResponseContent += '"AuthorId":9,';
        ResponseContent += '"EditorId":9,';
        ResponseContent += '"OData__UIVersionString":"30.0",';
        ResponseContent += '"Attachments":true,';
        ResponseContent += '"GUID":"27c78f81-f4d9-4ee9-85bd-5d57ade1b5f4",';
        ResponseContent += '"ComplianceAssetId":null';
        ResponseContent += '},';
        ResponseContent += '{';
        ResponseContent += '"odata.type":"SP.Data.Asset_x0020_DocumentsListItem",';
        ResponseContent += '"odata.id":"6fdd295a-2201-4f9b-a853-d53513d4f63a",';
        ResponseContent += '"odata.etag":"2",';
        ResponseContent += '"odata.editLink":"Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(2)",';
        ResponseContent += '"FileSystemObjectType":0,';
        ResponseContent += '"Id":2,';
        ResponseContent += '"ServerRedirectedEmbedUri":null,';
        ResponseContent += '"ServerRedirectedEmbedUrl":"",';
        ResponseContent += '"ID":2,';
        ResponseContent += '"ContentTypeId":"0x0100386AEFB9434E704081AB02149FB55A74008FA0CDB720117949A23770C25BF4E510",';
        ResponseContent += '"Title":"Test List Item 2",';
        ResponseContent += '"Modified":"2022-07-08T20:37:53Z",';
        ResponseContent += '"Created":"2022-05-31T10:40:22Z",';
        ResponseContent += '"AuthorId":9,';
        ResponseContent += '"EditorId":9,';
        ResponseContent += '"OData__UIVersionString":"2.0",';
        ResponseContent += '"Attachments":true,';
        ResponseContent += '"GUID":"74c31296-cbf2-4c4a-a133-6a5bcaf39a96",';
        ResponseContent += '"ComplianceAssetId":null';
        ResponseContent += '}';
        ResponseContent += ']';
        ResponseContent += '}';

        ResponseContent := ResponseContent.Replace('{baseUrl}', BaseUrl).Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent, HttpHeaders, 200, true, 'OK');
    end;

    local procedure GetListItemAttachmentsTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: Text;
    begin
        ResponseContent := '{';
        ResponseContent += '"odata.metadata":"{baseUrl}_api/$metadata#SP.ApiData.Attachments",';
        ResponseContent += '"value": [';
        ResponseContent += '{';
        ResponseContent += '"odata.type":"SP.Attachment",';
        ResponseContent += '"odata.id":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)/AttachmentFiles(''Test Picture.jpg'')",';
        ResponseContent += '"odata.editLink":"Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)/AttachmentFiles(''Test%20Picture.jpg'')",';
        ResponseContent += '"FileName":"Test Picture.jpg",';
        ResponseContent += '"FileNameAsPath":{';
        ResponseContent += '"DecodedUrl":"Test Picture.jpg"';
        ResponseContent += '},';
        ResponseContent += '"ServerRelativePath":{';
        ResponseContent += '"DecodedUrl":"{parentUrl}/Lists/Asset Documents/Attachments/1/Test Picture.jpg"';
        ResponseContent += '},';
        ResponseContent += '"ServerRelativeUrl":"{parentUrl}/Lists/Asset Documents/Attachments/1/Test Picture.jpg"';
        ResponseContent += '},';
        ResponseContent += '{';
        ResponseContent += '"odata.type":"SP.Attachment",';
        ResponseContent += '"odata.id":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)/AttachmentFiles(''Test_Image.jpg'')",';
        ResponseContent += '"odata.editLink":"Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)/AttachmentFiles(''Test_Image.jpg'')",';
        ResponseContent += '"FileName":"Test_Image.jpg",';
        ResponseContent += '"FileNameAsPath":{';
        ResponseContent += '"DecodedUrl":"Test_Image.jpg"';
        ResponseContent += '},';
        ResponseContent += '"ServerRelativePath":{';
        ResponseContent += '"DecodedUrl":"{parentUrl}/Lists/Asset Documents/Attachments/1/Test_Image.jpg"';
        ResponseContent += '},';
        ResponseContent += '"ServerRelativeUrl":"{parentUrl}/Lists/Asset Documents/Attachments/1/Test_Image.jpg"';
        ResponseContent += '}';
        ResponseContent += ']';
        ResponseContent += '}';

        ResponseContent := ResponseContent.Replace('{baseUrl}', BaseUrl).Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent, HttpHeaders, 200, true, 'OK');
    end;

    local procedure CreateListItemAttachmentTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: Text;
    begin
        ResponseContent := '{';
        ResponseContent += '"d":{';
        ResponseContent += '"__metadata":{';
        ResponseContent += '"id":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)/AttachmentFiles(''Sample_file.txt'')",';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(1)/AttachmentFiles(''Sample_file.txt'')",';
        ResponseContent += '"type":"SP.Attachment"';
        ResponseContent += '},';
        ResponseContent += '"FileName":"Sample_file.txt",';
        ResponseContent += '"FileNameAsPath":{';
        ResponseContent += '"__metadata":{';
        ResponseContent += '"type":"SP.ResourcePath"';
        ResponseContent += '},';
        ResponseContent += '"DecodedUrl":"Sample_file.txt"';
        ResponseContent += '},';
        ResponseContent += '"ServerRelativePath":{';
        ResponseContent += '"__metadata":{';
        ResponseContent += '"type":"SP.ResourcePath"';
        ResponseContent += '},';
        ResponseContent += '"DecodedUrl":"{parentUrl}/Lists/Asset Documents/Attachments/1/Sample_file.txt"';
        ResponseContent += '},';
        ResponseContent += '"ServerRelativeUrl":"{parentUrl}/Lists/Asset Documents/Attachments/1/Sample_file.txt"';
        ResponseContent += '}';
        ResponseContent += '}';

        ResponseContent := ResponseContent.Replace('{baseUrl}', BaseUrl).Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent, HttpHeaders, 200, true, 'OK');
    end;

    local procedure CreateListItemTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: Text;
    begin
        ResponseContent := '{';
        ResponseContent += '"d":{';
        ResponseContent += '"__metadata":{';
        ResponseContent += '"id":"02be316a-e242-44d1-8bd9-3587e1fff887",';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)",';
        ResponseContent += '"etag":"1",';
        ResponseContent += '"type":"SP.Data.My_x0020_Test_x0020_DocumentsListItem"';
        ResponseContent += '},';
        ResponseContent += '"FirstUniqueAncestorSecurableObject":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/FirstUniqueAncestorSecurableObject"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"RoleAssignments":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/RoleAssignments"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"AttachmentFiles":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/AttachmentFiles"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"ContentType":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/ContentType"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"GetDlpPolicyTip":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"https://{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/GetDlpPolicyTip"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"FieldValuesAsHtml":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"https://{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/FieldValuesAsHtml"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"FieldValuesAsText":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"https://{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/FieldValuesAsText"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"FieldValuesForEdit":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/FieldValuesForEdit"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"File":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/File"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"Folder":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/Folder"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"LikedByInformation":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/LikedByInformation"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"ParentList":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/ParentList"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"Properties":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/Properties"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"Versions":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''854d7f21-1c6a-43ab-a081-20404894b449'')/Items(3)/Versions"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"FileSystemObjectType":0,';
        ResponseContent += '"Id":3,';
        ResponseContent += '"ServerRedirectedEmbedUri":null,';
        ResponseContent += '"ServerRedirectedEmbedUrl":"",';
        ResponseContent += '"ID":3,';
        ResponseContent += '"ContentTypeId":"0x0100386AEFB9434E704081AB02149FB55A74008FA0CDB720117949A23770C25BF4E510",';
        ResponseContent += '"Title":"Test Item",';
        ResponseContent += '"Modified":"2022-07-15T08:31:30Z",';
        ResponseContent += '"Created":"2022-07-15T08:31:30Z",';
        ResponseContent += '"AuthorId":9,';
        ResponseContent += '"EditorId":9,';
        ResponseContent += '"OData__UIVersionString":"1.0",';
        ResponseContent += '"Attachments":false,';
        ResponseContent += '"GUID":"17bf42f2-2560-4452-b0cb-df674ac734f1",';
        ResponseContent += '"ComplianceAssetId":null';
        ResponseContent += '}';
        ResponseContent += '}';

        ResponseContent := ResponseContent.Replace('{baseUrl}', BaseUrl).Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent, HttpHeaders, 201, true, 'CREATED');
    end;

    local procedure CreateListTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: Text;
    begin

        ResponseContent := '{';
        ResponseContent += '"d":{';
        ResponseContent += '"__metadata":{';
        ResponseContent += '"id":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')",';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')",';
        ResponseContent += '"etag":"1",';
        ResponseContent += '"type":"SP.List"';
        ResponseContent += '},';
        ResponseContent += '"FirstUniqueAncestorSecurableObject":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/FirstUniqueAncestorSecurableObject"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"RoleAssignments":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/RoleAssignments"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"Author":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/Author"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"ContentTypes":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/ContentTypes"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"CreatablesInfo":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/CreatablesInfo"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"DefaultView":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/DefaultView"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"DescriptionResource":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/DescriptionResource"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"EventReceivers":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/EventReceivers"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"Fields":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/Fields"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"Forms":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/Forms"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"InformationRightsManagementSettings":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/InformationRightsManagementSettings"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"Items":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/Items"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"ParentWeb":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/ParentWeb"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"RootFolder":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/RootFolder"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"Subscriptions":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/Subscriptions"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"TitleResource":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/TitleResource"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"UserCustomActions":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/UserCustomActions"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"Views":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/Views"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"WorkflowAssociations":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/Lists(guid''b3cf160f-d953-49d3-bf3e-5704dee4559e'')/WorkflowAssociations"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"AllowContentTypes":true,';
        ResponseContent += '"BaseTemplate":100,';
        ResponseContent += '"BaseType":0,';
        ResponseContent += '"ContentTypesEnabled":true,';
        ResponseContent += '"CrawlNonDefaultViews":false,';
        ResponseContent += '"Created":"2022-07-15T11:45:34Z",';
        ResponseContent += '"CurrentChangeToken":{';
        ResponseContent += '"__metadata":{';
        ResponseContent += '"type":"SP.ChangeToken"';
        ResponseContent += '},';
        ResponseContent += '"StringValue":"1;3;b3cf160f-d953-49d3-bf3e-5704dee4559e;637934823340800000;290869285"';
        ResponseContent += '},';
        ResponseContent += '"DefaultContentApprovalWorkflowId":"00000000-0000-0000-0000-000000000000",';
        ResponseContent += '"DefaultItemOpenUseListSetting":false,';
        ResponseContent += '"Description":"Test Sample List Description",';
        ResponseContent += '"Direction":"none",';
        ResponseContent += '"DisableCommenting":false,';
        ResponseContent += '"DisableGridEditing":false,';
        ResponseContent += '"DocumentTemplateUrl":null,';
        ResponseContent += '"DraftVersionVisibility":0,';
        ResponseContent += '"EnableAttachments":true,';
        ResponseContent += '"EnableFolderCreation":false,';
        ResponseContent += '"EnableMinorVersions":false,';
        ResponseContent += '"EnableModeration":false,';
        ResponseContent += '"EnableRequestSignOff":true,';
        ResponseContent += '"EnableVersioning":true,';
        ResponseContent += '"EntityTypeName":"Test_x0020_Sample_x0020_List_x0020_TitleList",';
        ResponseContent += '"ExemptFromBlockDownloadOfNonViewableFiles":false,';
        ResponseContent += '"FileSavePostProcessingEnabled":false,';
        ResponseContent += '"ForceCheckout":false,';
        ResponseContent += '"HasExternalDataSource":false,';
        ResponseContent += '"Hidden":false,';
        ResponseContent += '"Id":"b3cf160f-d953-49d3-bf3e-5704dee4559e",';
        ResponseContent += '"ImagePath":{';
        ResponseContent += '"__metadata":{';
        ResponseContent += '"type":"SP.ResourcePath"';
        ResponseContent += '},';
        ResponseContent += '"DecodedUrl":"/_layouts/15/images/itgen.png?rev=47"';
        ResponseContent += '},';
        ResponseContent += '"ImageUrl":"/_layouts/15/images/itgen.png?rev=47",';
        ResponseContent += '"DefaultSensitivityLabelForLibrary":"",';
        ResponseContent += '"IrmEnabled":false,';
        ResponseContent += '"IrmExpire":false,';
        ResponseContent += '"IrmReject":false,';
        ResponseContent += '"IsApplicationList":false,';
        ResponseContent += '"IsCatalog":false,';
        ResponseContent += '"IsPrivate":false,';
        ResponseContent += '"ItemCount":0,';
        ResponseContent += '"LastItemDeletedDate":"2022-07-15T11:45:34Z",';
        ResponseContent += '"LastItemModifiedDate":"2022-07-15T11:45:34Z",';
        ResponseContent += '"LastItemUserModifiedDate":"2022-07-15T11:45:34Z",';
        ResponseContent += '"ListExperienceOptions":0,';
        ResponseContent += '"ListItemEntityTypeFullName":"SP.Data.Test_x0020_Sample_x0020_List_x0020_TitleListItem",';
        ResponseContent += '"MajorVersionLimit":50,';
        ResponseContent += '"MajorWithMinorVersionsLimit":0,';
        ResponseContent += '"MultipleDataList":false,';
        ResponseContent += '"NoCrawl":false,';
        ResponseContent += '"ParentWebPath":{';
        ResponseContent += '"__metadata":{';
        ResponseContent += '"type":"SP.ResourcePath"';
        ResponseContent += '},';
        ResponseContent += '"DecodedUrl":"/sites/Test"';
        ResponseContent += '},';
        ResponseContent += '"ParentWebUrl":"/sites/Test",';
        ResponseContent += '"ParserDisabled":false,';
        ResponseContent += '"ServerTemplateCanCreateFolders":true,';
        ResponseContent += '"TemplateFeatureId":"00bfea71-de22-43b2-a848-c05709900100",';
        ResponseContent += '"Title":"Test Sample List Title"';
        ResponseContent += '}';
        ResponseContent += '}';

        ResponseContent := ResponseContent.Replace('{baseUrl}', BaseUrl).Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent, HttpHeaders, 201, true, 'CREATED');
    end;

    local procedure GetDocumentLibraryRootFolderTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: Text;
    begin
        ResponseContent := '{';
        ResponseContent += '"odata.metadata":"{baseUrl}_api/$metadata#SP.ApiData.Folders1/@Element",';
        ResponseContent += '"odata.type":"SP.Folder",';
        ResponseContent += '"odata.id":"{baseUrl}_api/Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test Documents'')",';
        ResponseContent += '"odata.editLink":"Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents'')",';
        ResponseContent += '"Exists":true,';
        ResponseContent += '"IsWOPIEnabled":false,';
        ResponseContent += '"ItemCount":2,';
        ResponseContent += '"Name":"Test Documents",';
        ResponseContent += '"ProgID":null,';
        ResponseContent += '"ServerRelativeUrl":"{parentUrl}/Lists/Test Documents",';
        ResponseContent += '"TimeCreated":"2022-05-23T12:16:04Z",';
        ResponseContent += '"TimeLastModified":"2022-07-15T08:31:30Z",';
        ResponseContent += '"UniqueId":"05270e8a-3027-47c8-aff4-36a499486b92",';
        ResponseContent += '"WelcomePage":""';
        ResponseContent += '}';

        ResponseContent := ResponseContent.Replace('{baseUrl}', BaseUrl).Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent, HttpHeaders, 200, true, 'OK');
    end;

    local procedure GetFolderBySeverRelativeUrlTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: Text;
    begin
        ResponseContent := '{';
        ResponseContent += '"odata.metadata":"{baseUrl}/_api/$metadata#SP.ApiData.Folders1",';
        ResponseContent += '"value":[';
        ResponseContent += '{';
        ResponseContent += '"odata.type":"SP.Folder",';
        ResponseContent += '"odata.id":"{baseUrl}_api/Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test Documents/Attachments'')",';
        ResponseContent += '"odata.editLink":"Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments'')",';
        ResponseContent += '"Exists":true,';
        ResponseContent += '"IsWOPIEnabled":false,';
        ResponseContent += '"ItemCount":0,';
        ResponseContent += '"Name":"Attachments",';
        ResponseContent += '"ProgID":null,';
        ResponseContent += '"ServerRelativeUrl":"{parentUrl}/Lists/Test Documents/Attachments",';
        ResponseContent += '"TimeCreated":"2022-05-23T12:16:04Z",';
        ResponseContent += '"TimeLastModified":"2022-05-23T12:16:04Z",';
        ResponseContent += '"UniqueId":"30c845cf-46b5-4edb-9c8d-018a609c2110",';
        ResponseContent += '"WelcomePage":""';
        ResponseContent += '}';
        ResponseContent += ']';
        ResponseContent += '}';

        ResponseContent := ResponseContent.Replace('{baseUrl}', BaseUrl).Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent, HttpHeaders, 200, true, 'OK');
    end;

    local procedure GetFolderFilesByServerRelativeUrlTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: Text;
    begin
        ResponseContent := '{';
        ResponseContent += '"odata.metadata":"{baseUrl}/_api/$metadata#SP.ApiData.Files12",';
        ResponseContent += '"value":[';
        ResponseContent += '{';
        ResponseContent += '"odata.type": "SP.File",';
        ResponseContent += '"odata.id":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test Documents/Attachments/1/document.pdf'')",';
        ResponseContent += '"odata.editLink":"Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/1/document.pdf'')",';
        ResponseContent += '"CheckInComment":"",';
        ResponseContent += '"CheckOutType":2,';
        ResponseContent += '"ContentTag":"{FB9CD74F-610B-4AC5-99F1-3CCD5C6CE7EE},1,1",';
        ResponseContent += '"CustomizedPageStatus":0,';
        ResponseContent += '"ETag": "{FB9CD74F-610B-4AC5-99F1-3CCD5C6CE7EE}",';
        ResponseContent += '"Exists":true,';
        ResponseContent += '"IrmEnabled":false,';
        ResponseContent += '"Length":"25555",';
        ResponseContent += '"Level":1,';
        ResponseContent += '"LinkingUri":null,';
        ResponseContent += '"LinkingUrl":"",';
        ResponseContent += '"MajorVersion":1,';
        ResponseContent += '"MinorVersion":0,';
        ResponseContent += '"Name":"document.pdf",';
        ResponseContent += '"ServerRelativeUrl":"{parentUrl}/Lists/Test Documents/Attachments/1/document.pdf",';
        ResponseContent += '"TimeCreated":"2022-07-14T22:14:33Z",';
        ResponseContent += '"TimeLastModified":"2022-07-14T22:14:33Z",';
        ResponseContent += '"Title":null,';
        ResponseContent += '"UIVersion":512,';
        ResponseContent += '"UIVersionLabel":"1.0",';
        ResponseContent += '"UniqueId":"fb9cd74f-610b-4ac5-99f1-3ccd5c6ce7ee"';
        ResponseContent += '},';
        ResponseContent += '{';
        ResponseContent += '"odata.type":"SP.File",';
        ResponseContent += '"odata.id":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test Documents/Attachments/1/Test_img.jpg'')",';
        ResponseContent += '"odata.editLink":"Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test %20Documents/Attachments/1/Test_img.jpg'')",';
        ResponseContent += '"CheckInComment":"",';
        ResponseContent += '"CheckOutType":2,';
        ResponseContent += '"ContentTag":"{B490A83A-757C-4F30-85EB-8010302FF941},1,2",';
        ResponseContent += '"CustomizedPageStatus":0,';
        ResponseContent += '"ETag":"{B490A83A-757C-4F30-85EB-8010302FF941}",';
        ResponseContent += '"Exists":true,';
        ResponseContent += '"IrmEnabled":false,';
        ResponseContent += '"Length":"455816",';
        ResponseContent += '"Level":1,';
        ResponseContent += '"LinkingUri":null,';
        ResponseContent += '"LinkingUrl":"",';
        ResponseContent += '"MajorVersion":1,';
        ResponseContent += '"MinorVersion":0,';
        ResponseContent += '"Name":"Test_img.jpg",';
        ResponseContent += '"ServerRelativeUrl":"{parentUrl}/Lists/Test Documents/Attachments/1/Test_img.jpg",';
        ResponseContent += '"TimeCreated":"2022-05-31T11:45:25Z",';
        ResponseContent += '"TimeLastModified":"2022-05-31T11:45:25Z",';
        ResponseContent += '"Title":null,';
        ResponseContent += '"UIVersion":512,';
        ResponseContent += '"UIVersionLabel":"1.0",';
        ResponseContent += '"UniqueId":"b490a83a-757c-4f30-85eb-8010302ff941"';
        ResponseContent += '}';
        ResponseContent += ']';
        ResponseContent += '}';

        ResponseContent := ResponseContent.Replace('{baseUrl}', BaseUrl).Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent, HttpHeaders, 200, true, 'OK');
    end;

    local procedure CreateFolderTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: Text;
    begin

        ResponseContent := '{';
        ResponseContent += '"d":{';
        ResponseContent += '"__metadata":{';
        ResponseContent += '"id":"{baseUrl}_api/Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test Documents/Attachments/TestSubfolder'')",';
        ResponseContent += '"uri":"{baseUrl}_api/Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/TestSubfolder'')",';
        ResponseContent += '"type":"SP.Folder"';
        ResponseContent += '},';
        ResponseContent += '"Files":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/TestSubfolder'')/Files"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"ListItemAllFields":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/TestSubfolder'')/ListItemAllFields"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"ParentFolder":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/TestSubfolder'')/ParentFolder"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"Properties":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/TestSubfolder'')/Properties"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"StorageMetrics":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/TestSubfolder'')/StorageMetrics"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"Folders":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/GetFolderByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/TestSubfolder'')/Folders"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"Exists":true,';
        ResponseContent += '"IsWOPIEnabled":false,';
        ResponseContent += '"ItemCount":0,';
        ResponseContent += '"Name":"TestSubfolder",';
        ResponseContent += '"ProgID":null,';
        ResponseContent += '"ServerRelativeUrl":"{parentUrl}/Lists/Test Documents/Attachments/TestSubfolder",';
        ResponseContent += '"TimeCreated":"2022-07-15T20:40:25Z",';
        ResponseContent += '"TimeLastModified":"2022-07-15T20:40:25Z",';
        ResponseContent += '"UniqueId":"922ba9b1-c26d-417f-8ecb-79d71ebfa22e",';
        ResponseContent += '"WelcomePage":""';
        ResponseContent += '}';
        ResponseContent += '}';

        ResponseContent := ResponseContent.Replace('{baseUrl}', BaseUrl).Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent, HttpHeaders, 201, true, 'CREATED');
    end;

    local procedure AddFileToFolderTestResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: Text;
    begin

        ResponseContent := '{';
        ResponseContent += '"d":{';
        ResponseContent += '"__metadata":{';
        ResponseContent += '"id":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test Documents/Attachments/SampleTestFile.jpg'')",';
        ResponseContent += '"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')",';
        ResponseContent += '"type":"SP.File"';
        ResponseContent += '},';
        ResponseContent += '"Author":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')/Author"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"CheckedOutByUser":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')/CheckedOutByUser"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"EffectiveInformationRightsManagementSettings":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')/EffectiveInformationRightsManagementSettings"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"InformationRightsManagementSettings":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')/InformationRightsManagementSettings"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"ListItemAllFields":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')/ListItemAllFields"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"LockedByUser":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')/LockedByUser"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"ModifiedBy":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')/ModifiedBy"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"Properties":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')/Properties"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"VersionEvents":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')/VersionEvents"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"Versions":{';
        ResponseContent += '"__deferred":{';
        ResponseContent += '"uri":"{baseUrl}_api/Web/GetFileByServerRelativePath(decodedurl=''{parentUrl}/Lists/Test%20Documents/Attachments/SampleTestFile.jpg'')/Versions"';
        ResponseContent += '}';
        ResponseContent += '},';
        ResponseContent += '"CheckInComment":"",';
        ResponseContent += '"CheckOutType":2,';
        ResponseContent += '"ContentTag":"{0B217604-0507-44FD-BC88-8727C911EEE5},1,2",';
        ResponseContent += '"CustomizedPageStatus":0,';
        ResponseContent += '"ETag":"{0B217604-0507-44FD-BC88-8727C911EEE5}",';
        ResponseContent += '"Exists":true,';
        ResponseContent += '"IrmEnabled":false,';
        ResponseContent += '"Length":"44087",';
        ResponseContent += '"Level":1,';
        ResponseContent += '"LinkingUri":null,';
        ResponseContent += '"LinkingUrl":"",';
        ResponseContent += '"MajorVersion":1,';
        ResponseContent += '"MinorVersion":0,';
        ResponseContent += '"Name":"SampleTestFile.jpg",';
        ResponseContent += '"ServerRelativeUrl":"{parentUrl}/Lists/Test Documents/Attachments/SampleTestFile.jpg",';
        ResponseContent += '"TimeCreated":"2022-07-15T21:13:18Z",';
        ResponseContent += '"TimeLastModified":"2022-07-15T21:13:18Z",';
        ResponseContent += '"Title":null,';
        ResponseContent += '"UIVersion":512,';
        ResponseContent += '"UIVersionLabel":"1.0",';
        ResponseContent += '"UniqueId":"0b217604-0507-44fd-bc88-8727c911eee5"';
        ResponseContent += '}';
        ResponseContent += '}';

        ResponseContent := ResponseContent.Replace('{baseUrl}', BaseUrl).Replace('{parentUrl}', ParentUrl);
        SharePointOperationResponse.SetHttpResponse(ResponseContent, HttpHeaders, 200, true, 'OK');
    end;


    local procedure GetDetailedErrorResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: Text;
    begin
        ResponseContent := '{';
        ResponseContent += '"error_description":"Invalid JWT token. The token is expired."';
        ResponseContent += '}';
        SharePointOperationResponse.SetHttpResponse(ResponseContent, HttpHeaders, 401, false, 'Unauthorized');
    end;

    local procedure GetTooManyRequestsResponse(var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; BaseUrl: Text; ParentUrl: Text)
    var
        HttpHeaders: HttpHeaders;
        ResponseContent: Text;
    begin
        ResponseContent := '429 TOO MANY REQUESTS';
        HttpHeaders.Add('Retry-after', '5');
        SharePointOperationResponse.SetHttpResponse(ResponseContent, HttpHeaders, 429, false, 'TooManyRequests');
    end;

}