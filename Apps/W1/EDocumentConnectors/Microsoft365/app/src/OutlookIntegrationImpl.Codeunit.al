// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using System.Email;
using System.Utilities;
using Microsoft.EServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument.Integration.Receive;
using Microsoft.eServices.EDocument.Integration.Send;
using System.Environment.Configuration;
using Microsoft.eServices.EDocument.Processing.Interfaces;

codeunit 6386 "Outlook Integration Impl." implements IDocumentReceiver, IDocumentSender, IReceivedDocumentMarker
{
    Permissions = tabledata "E-Document" = r,
                  tabledata "E-Document Log" = r,
                  tabledata "E-Doc. Data Storage" = r,
                  tabledata "Email Inbox" = r,
                  tabledata "Outlook Setup" = r;
    InherentPermissions = X;
    InherentEntitlements = X;

    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext)
    begin
        Error(SendNotSupportedErr);
    end;

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; Documents: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    begin
        OutlookProcessing.ReceiveDocuments(EDocumentService, Documents, ReceiveContext);
    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadataBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    begin
        OutlookProcessing.DownloadDocument(EDocument, EDocumentService, DocumentMetadataBlob, ReceiveContext);
    end;

    procedure MarkFetched(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    begin
        OutlookProcessing.MarkMessageAsRead(EDocument, EDocumentService);
    end;

    procedure SelectEmailAccountV3(var EmailAccount: Record "Email Account"): Boolean
    var
        EmailAccounts: Page "Email Accounts";
    begin
        if not EmailAccountV3Exists() then begin
            Page.RunModal(Page::"Email Account Wizard");
            if not EmailAccountV3Exists() then
                exit(false);
        end;
        EmailAccounts.EnableLookupMode();
        EmailAccounts.FilterConnectorV3AccountsOnly(true);
        if EmailAccounts.RunModal() <> Action::LookupOK then
            exit(false);

        EmailAccounts.GetAccount(EmailAccount);
        exit(not IsNullGuid(EmailAccount."Account Id"));
    end;

    local procedure EmailAccountV3Exists(): Boolean
    var
        TempEmailAccounts: Record "Email Account" temporary;
        EmailAccount: Codeunit "Email Account";
        EmailConnector: Interface "Email Connector";
    begin
        EmailAccount.GetAllAccounts(false, TempEmailAccounts);
        if TempEmailAccounts.IsEmpty() then
            exit(false);
        TempEmailAccounts.FindSet();
        repeat
            EmailConnector := TempEmailAccounts.Connector;
            if EmailConnector is "Email Connector v3" then
                exit(true);
        until TempEmailAccounts.Next() = 0;
        exit(false);
    end;

    internal procedure SetConditionalVisibilityFlag(var VisibilityFlag: Boolean)
    var
        OutlookSetup: Record "Outlook Setup";
    begin
        if OutlookSetup.Get() then
            if OutlookSetup.Enabled then
                VisibilityFlag := true;
    end;

    internal procedure SetConditionalVisibilityFlag(var EDocument: Record "E-Document"; var VisibilityFlag: Boolean)
    var
        EDocumentService: Record "E-Document Service";
    begin
        if not EDocumentService.Get(EDocument.Service) then begin
            VisibilityFlag := false;
            exit;
        end;

        VisibilityFlag := (EDocumentService."Service Integration V2" = EDocumentService."Service Integration V2"::Outlook);
    end;

    [EventSubscriber(ObjectType::Page, Page::"E-Document Service", OnBeforeOpenServiceIntegrationSetupPage, '', false, false)]
    local procedure OnBeforeOpenServiceIntegrationSetupPage(EDocumentService: Record "E-Document Service"; var IsServiceIntegrationSetupRun: Boolean)
    var
        OutlookSetup: Page "Outlook Setup";
    begin
        if EDocumentService."Service Integration V2" = EDocumentService."Service Integration V2"::Outlook then begin
            OutlookSetup.RunModal();
            IsServiceIntegrationSetupRun := true;
        end;
    end;

    procedure WebLinkText(): Text
    begin
        exit(WebLinkTxt);
    end;

    [EventSubscriber(ObjectType::Table, Database::"E-Document Log", OnBeforeExportDataStorage, '', false, false)]
    local procedure HandleOnBeforeExportDataStorage(EDocumentLog: Record "E-Document Log"; var FileName: Text)
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocDataStorage: Record "E-Doc. Data Storage";
        IEDocFileFormat: Interface IEDocFileFormat;
    begin
        if not EDocument.Get(EDocumentLog."E-Doc. Entry No") then
            exit;

        if not EDocumentService.Get(EDocumentLog."Service Code") then
            exit;

        if EDocumentService."Service Integration V2" <> EDocumentService."Service Integration V2"::Outlook then
            exit;

        if EDocument."File Name" = '' then
            exit;

        FileName := EDocument."File Name";

        if EDocDataStorage.Get(EDocumentLog."E-Doc. Data Storage Entry No.") then begin
            IEDocFileFormat := EDocDataStorage."File Format";
            if EDocDataStorage."File Format" <> EDocDataStorage."File Format"::Unspecified then
                FileName += ('.' + IEDocFileFormat.FileExtension());
        end;

    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    local procedure HandleOnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    var
        OutlookSetup: Record "Outlook Setup";
        SharepointSetup: Record "SharePoint Setup";
        OneDriveSetup: Record "OneDrive Setup";
    begin
        OutlookSetup.ChangeCompany(NewCompanyName);
        OutlookSetup.DeleteAll();

        SharepointSetup.ChangeCompany(NewCompanyName);
        SharepointSetup.DeleteAll();

        OneDriveSetup.ChangeCompany(NewCompanyName);
        OneDriveSetup.DeleteAll();
    end;

    var
        OutlookProcessing: Codeunit "Outlook Processing";
        SendNotSupportedErr: label 'Sending document is not supported in this context.';
        WebLinkTxt: label 'https://outlook.office365.com/owa/?ItemID=%1&exvsurl=1&viewmodel=ReadMessageItem', Locked = true;
}