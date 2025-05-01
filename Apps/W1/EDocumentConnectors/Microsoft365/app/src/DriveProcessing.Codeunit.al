// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using Microsoft.EServices.EDocument;
using System.Text;
using Microsoft.eServices.EDocument.Integration;
using System.Utilities;
using System.Integration;
using Microsoft.eServices.EDocument.Integration.Receive;
using System.Telemetry;

codeunit 6381 "Drive Processing"
{
    Access = Internal;
    Permissions = tabledata "E-Document" = m,
                  tabledata "E-Document Service Status" = m,
                  tabledata "OneDrive Setup" = r,
                  tabledata "Sharepoint Setup" = r;
    InherentPermissions = X;
    InherentEntitlements = X;

    internal procedure MarkEDocumentAsDownloaded(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service")
    var
        GraphClient: Codeunit "Graph Client";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SiteId: Text;
        NewFolderId: Text;
    begin
        FeatureTelemetry.LogUptake('0000OAY', FeatureName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000OB1', FeatureName(), Format(EDocumentService."Service Integration V2"));
        if EDocument."Drive Item Id" = '' then
            Error(DocumentIdEmptyErr, EDocument."Entry No");

        SiteId := GetSiteId(EDocumentService."Service Integration V2");
        NewFolderId := GetImportedDocumentsFolderId(EDocumentService."Service Integration V2");

        GraphClient.MoveDriveItem(SiteId, EDocument."Drive Item Id", NewFolderId);
    end;

    procedure GetSiteId(FolderSharedLink: Text[2048]): Text
    var
        GraphClient: Codeunit "Graph Client";
        Base64Convert: Codeunit "Base64 Convert";
        MySiteLink, Base64SharedLink, ErrorMessageTxt : Text;
        FilesJson: JsonObject;
        SiteIdToken: JsonToken;
    begin
        Base64SharedLink := Base64Convert.ToBase64(FolderSharedLink);
        Base64SharedLink := 'u!' + Base64SharedLink.TrimEnd('=').Replace('/', '_').Replace('+', '-');
        MySiteLink := GetGraphSharesURL() + Base64SharedLink + '/driveItem/parentReference';
        if not GraphClient.GetDriveFolderInfo(MySiteLink, FilesJson) then begin
            ErrorMessageTxt := GetLastErrorText() + GetLastErrorCallStack();
            ClearLastError();
            Error(ErrorMessageTxt);
        end;

        if FilesJson.Get('siteId', SiteIdToken) then
            exit(SiteIdToken.AsValue().AsText())
    end;

    procedure GetId(FolderSharedLink: Text[2048]): Text
    var
        GraphClient: Codeunit "Graph Client";
        Base64Convert: Codeunit "Base64 Convert";
        MyFolderIdLink, Base64SharedLink, ErrorMessageTxt : Text;
        FilesJson: JsonObject;
        IdToken: JsonToken;
    begin
        Base64SharedLink := Base64Convert.ToBase64(FolderSharedLink);
        Base64SharedLink := 'u!' + Base64SharedLink.TrimEnd('=').Replace('/', '_').Replace('+', '-');
        MyFolderIdLink := GetGraphSharesURL() + Base64SharedLink + '/driveItem?$select=id';
        if not GraphClient.GetDriveFolderInfo(MyFolderIdLink, FilesJson) then begin
            ErrorMessageTxt := GetLastErrorText() + GetLastErrorCallStack();
            ClearLastError();
            Error(ErrorMessageTxt);
        end;

        if FilesJson.Get('id', IdToken) then
            exit(IdToken.AsValue().AsText())
    end;

    procedure GetName(FolderSharedLink: Text[2048]): Text
    var
        GraphClient: Codeunit "Graph Client";
        Base64Convert: Codeunit "Base64 Convert";
        MyFolderIdLink, Base64SharedLink, ErrorMessageTxt : Text;
        FilesJson: JsonObject;
        IdToken: JsonToken;
    begin
        Base64SharedLink := Base64Convert.ToBase64(FolderSharedLink);
        Base64SharedLink := 'u!' + Base64SharedLink.TrimEnd('=').Replace('/', '_').Replace('+', '-');
        MyFolderIdLink := GetGraphSharesURL() + Base64SharedLink + '/driveItem?$select=id,name';
        if not GraphClient.GetDriveFolderInfo(MyFolderIdLink, FilesJson) then begin
            ErrorMessageTxt := GetLastErrorText() + GetLastErrorCallStack();
            ClearLastError();
            Error(ErrorMessageTxt);
        end;

        if FilesJson.Get('name', IdToken) then
            exit(IdToken.AsValue().AsText())
    end;

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; Documents: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    var
        GraphClient: Codeunit "Graph Client";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        MyBCFilesLink, ErrorMessageTxt : Text;
        FilesJson: JsonObject;
    begin
        FeatureTelemetry.LogUptake('0000OAZ', FeatureName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000OB2', FeatureName(), Format(EDocumentService."Service Integration V2"));
        MyBCFilesLink := GetGraphSharesURL() + GetDocumentsSharedLink(EDocumentService."Service Integration V2") + '/driveItem/children?$top=100&$select=id,name,file,size,malware';
        if not GraphClient.GetDriveFolderInfo(MyBCFilesLink, FilesJson) then begin
            ErrorMessageTxt := GetLastErrorText() + GetLastErrorCallStack();
            ClearLastError();
            Error(ErrorMessageTxt);
        end;

        AddToDocumentsList(Documents, FilesJson);
    end;

    internal procedure FeatureName(): Text
    begin
        exit('Microsoft 365 E-Document Connector')
    end;

    internal procedure AddToReceiveContext(ReceiveContext: Codeunit ReceiveContext; var FilesJson: JSonObject)
    var
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
    begin
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        FilesJson.WriteTo(OutStream);
        ReceiveContext.SetTempBlob(TempBlob);
    end;

    internal procedure AddToDocumentsList(Documents: Codeunit "Temp Blob List"; var FilesJson: JSonObject)
    var
        TempBlob: Codeunit "Temp Blob";
        Child: JSonObject;
        Children: JSonArray;
        OutStream: OutStream;
        ChildTxt: Text;
        I: Integer;
        ChildCount: Integer;
    begin
        Children := FilesJson.GetArray('value');
        ChildCount := Children.Count();
        if ChildCount > 0 then
            for I := 0 to (ChildCount - 1) do begin
                Clear(TempBlob);
                TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
                Child := Children.GetObject(I);
                Child.WriteTo(ChildTxt);
                if not IgnoreDriveItem(Child, ChildTxt.ToLower()) then begin
                    OutStream.Write(ChildTxt);
                    Documents.Add(TempBlob);
                end;
            end;
    end;

    local procedure IgnoreDriveItem(Item: JSonObject; ItemAsTxt: Text): Boolean
    var
        SizeToken: JSonToken;
        Size: BigInteger;
    begin
        if Item.Get('size', SizeToken) then
            if SizeToken.IsValue() then
                Size := SizeToken.AsValue().AsBigInteger();

        if ItemAsTxt.Contains('"malware"') then
            exit(true);

        if not DelChr(ItemAsTxt, '=', ' ').Contains('"mimetype":"application/pdf"') then
            exit(true);

        if Size > SizeThreshold() then
            exit(true);
    end;

    internal procedure SizeThreshold(): Integer
    begin
        // 25 MB
        exit(26214400)
    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadataBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
        TempDocumentSharing: Record "Document Sharing" temporary;
        GraphClient: Codeunit "Graph Client";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        DocumentOutStream: OutStream;
        DocumentInStream: InStream;
        DocumentId, FileId, SiteId : Text;
    begin
        ExtractItemIdAndName(DocumentMetadataBlob, DocumentId, FileId);

        TempDocumentSharing.Init();
        TempDocumentSharing."Item Id" := CopyStr(DocumentId, 1, MaxStrLen(TempDocumentSharing."Item Id"));
        TempDocumentSharing.Insert();

        SiteId := GetSiteId(EDocumentService."Service Integration V2");

        FeatureTelemetry.LogUptake('0000OB0', FeatureName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000OB3', FeatureName(), Format(EDocumentService."Service Integration V2"));

        if not GraphClient.GetFileContent(SiteId, TempDocumentSharing) then begin
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());
            ClearLastError();
            exit;
        end;

        TempDocumentSharing.CalcFields(Data);
        if not TempDocumentSharing.Data.HasValue() then
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(NoContentErr, DocumentId));

        ReceiveContext.GetTempBlob().CreateOutStream(DocumentOutStream, TextEncoding::UTF8);
        TempDocumentSharing.Data.CreateInStream(DocumentInStream, TextEncoding::UTF8);
        CopyStream(DocumentOutStream, DocumentInStream);

        UpdateEDocumentAfterDocumentDownload(Edocument, DocumentId);
        UpdateReceiveContextAfterDocumentDownload(ReceiveContext, FileId, EDocumentService);
    end;

    internal procedure UpdateReceiveContextAfterDocumentDownload(ReceiveContext: Codeunit ReceiveContext; FileId: Text; var EDocumentService: Record "E-Document Service")
    begin
        ReceiveContext.SetName(CopyStr(FileId, 1, 250));
        ReceiveContext.SetType(Enum::"E-Doc. Data Storage Blob Type"::PDF);
        ReceiveContext.SetSourceDetails(GetSourceDetails(EDocumentService."Service Integration V2"));
    end;

    internal procedure UpdateEDocumentAfterDocumentDownload(var EDocument: Record "E-Document"; DocumentId: Text)
    begin
        EDocument."Drive Item Id" := CopyStr(DocumentId, 1, MaxStrLen(EDocument."Drive Item Id"));
        EDocument.Modify();
    end;

    internal procedure ExtractItemIdAndName(DocumentMetadataBlob: Codeunit "Temp Blob"; var DocumentId: Text; var FileId: Text)
    var
        Instream: InStream;
        ItemObject: JsonObject;
        ContentData: Text;
    begin
        DocumentMetadataBlob.CreateInStream(Instream);
        Instream.ReadText(ContentData);
        ItemObject.ReadFrom(ContentData);
        DocumentId := ItemObject.GetText('id');
        FileId := ItemObject.GetText('name');
    end;

    local procedure GetGraphSharesURL(): Text
    var
        URLHelper: Codeunit "Url Helper";
    begin
        exit(URLHelper.GetGraphURL() + 'v1.0/shares/')
    end;

    local procedure GetDocumentsSharedLink(var ServiceIntegration: Enum "Service Integration"): Text
    var
        SharepointSetup: Record "Sharepoint Setup";
        OneDriveSetup: Record "OneDrive Setup";
        Base64Convert: Codeunit "Base64 Convert";
        FolderSharedLink: Text;
        Base64Value: Text;
    begin
        case ServiceIntegration of
            ServiceIntegration::SharePoint:
                begin
                    if SharepointSetup.Get() then
                        if SharepointSetup.Enabled then
                            FolderSharedLink := SharepointSetup."Documents Folder";

                    CheckFolderSharedLinkNotEmpty(FolderSharedLink, SharepointSetup.TableCaption());
                end;
            ServiceIntegration::OneDrive:
                begin
                    if OneDriveSetup.Get() then
                        if OneDriveSetup.Enabled then
                            FolderSharedLink := OneDriveSetup."Documents Folder";
                    CheckFolderSharedLinkNotEmpty(FolderSharedLink, OneDriveSetup.TableCaption());
                end;
            else
                Error(UnsupportedIntegrationTypeErr);
        end;
        if FolderSharedLink <> '' then begin
            Base64Value := Base64Convert.ToBase64(FolderSharedLink);
            Base64Value := 'u!' + Base64Value.TrimEnd('=').Replace('/', '_').Replace('+', '-');
            exit(Base64Value);
        end;
    end;

    local procedure GetSiteId(var ServiceIntegration: Enum "Service Integration"): Text
    var
        SharepointSetup: Record "Sharepoint Setup";
        OneDriveSetup: Record "OneDrive Setup";
        SiteId: Text;
    begin
        case ServiceIntegration of
            ServiceIntegration::SharePoint:
                begin
                    CheckSetupEnabled(SharepointSetup);
                    CheckFolderSharedLinkNotEmpty(SharepointSetup."Documents Folder", SharepointSetup.TableCaption());
                    SiteId := SharepointSetup.SiteId;
                end;
            ServiceIntegration::OneDrive:
                begin
                    CheckSetupEnabled(OneDriveSetup);
                    CheckFolderSharedLinkNotEmpty(OneDriveSetup."Documents Folder", OneDriveSetup.TableCaption());
                    SiteId := OneDriveSetup.SiteId;
                end;
            else
                Error(UnsupportedIntegrationTypeErr);
        end;
        exit(SiteId);
    end;

    local procedure GetSourceDetails(var ServiceIntegration: Enum "Service Integration"): Text
    var
        SharepointSetup: Record "Sharepoint Setup";
        OneDriveSetup: Record "OneDrive Setup";
        DocumentsFolderName: Text;
    begin
        case ServiceIntegration of
            ServiceIntegration::SharePoint:
                begin
                    CheckSetupEnabled(SharepointSetup);
                    CheckFolderSharedLinkNotEmpty(SharepointSetup."Documents Folder", SharepointSetup.TableCaption());
                    DocumentsFolderName := SharepointSetup."Documents Folder Name";
                end;
            ServiceIntegration::OneDrive:
                begin
                    CheckSetupEnabled(OneDriveSetup);
                    CheckFolderSharedLinkNotEmpty(OneDriveSetup."Documents Folder", OneDriveSetup.TableCaption());
                    DocumentsFolderName := OneDriveSetup."Documents Folder Name";
                end;
        end;
        exit(DocumentsFolderName);
    end;

    local procedure GetImportedDocumentsFolderId(var ServiceIntegration: Enum "Service Integration"): Text
    var
        SharepointSetup: Record "Sharepoint Setup";
        OneDriveSetup: Record "OneDrive Setup";
        ImportedDocumentsFolderId: Text;
    begin
        case ServiceIntegration of
            ServiceIntegration::SharePoint:
                begin
                    CheckSetupEnabled(SharepointSetup);
                    CheckFolderSharedLinkNotEmpty(SharepointSetup."Imp. Documents Folder", SharepointSetup.TableCaption());
                    ImportedDocumentsFolderId := SharepointSetup."Imp. Documents Folder Id";
                end;
            ServiceIntegration::OneDrive:
                begin
                    CheckSetupEnabled(OneDriveSetup);
                    CheckFolderSharedLinkNotEmpty(OneDriveSetup."Imp. Documents Folder", OneDriveSetup.TableCaption());
                    ImportedDocumentsFolderId := OneDriveSetup."Imp. Documents Folder Id";
                end;
            else
                Error(UnsupportedIntegrationTypeErr);
        end;
        exit(ImportedDocumentsFolderId);
    end;

    local procedure CheckSetupEnabled(var OneDriveSetup: Record "OneDrive Setup")
    begin
        if not OneDriveSetup.Get() then
            Error(IntegrationNotEnabledErr, OneDriveSetup.TableCaption());
        if not OneDriveSetup.Enabled then
            Error(IntegrationNotEnabledErr, OneDriveSetup.TableCaption());
    end;

    local procedure CheckSetupEnabled(var SharepointSetup: Record "Sharepoint Setup")
    begin
        if not SharepointSetup.Get() then
            Error(IntegrationNotEnabledErr, SharepointSetup.TableCaption());
        if not SharepointSetup.Enabled then
            Error(IntegrationNotEnabledErr, SharepointSetup.TableCaption());
    end;

    local procedure CheckFolderSharedLinkNotEmpty(FolderSharedLink: Text; SetupTableCaption: Text)
    begin
        if FolderSharedLink = '' then
            Error(IntegrationNotEnabledErr, SetupTableCaption);
    end;

    var
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        NoContentErr: Label 'Empty content retrieved from the service for document id: %1.', Comment = '%1 - Document ID';
        IntegrationNotEnabledErr: Label '%1 must be enabled.', Comment = '%1 - a table caption, Sharepoint Document Import Setup';
        UnsupportedIntegrationTypeErr: Label 'You must choose a upported integration type.';
        DocumentIdEmptyErr: Label 'Drive Item Id is empty on e-document %1.', Comment = '%1 - an integer';
}