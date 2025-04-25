// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.DemoTool.Helpers;
using System.Environment;
using System.Utilities;
using Microsoft.Sales.Document;
using System.Globalization;

codeunit 5685 "Create Media Repository"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Description = 'This codeunit should only be called in codeunit 5691 "Create Contoso Tenant Data"';

    trigger OnRun()
    begin
        InsertMediaResources();
        InsertExcelTemplates();
        InsertSalesStatusIcons();
        InsertWalkMeTour();
        ImportInvoicingEmailMedia();
        CreateO3565Template();
        CreateLatePaymentModel();
    end;

    local procedure InsertMediaResources()
    begin
        InsertMediaResource('CopilotNotAvailable.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));
        InsertMediaResource('ImageAnalysis-Setup-NoText.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));
        InsertMediaResource('OutlookAddinIllustration.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));
        InsertMediaResource('TeamsAppIllustration.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));
        InsertMediaResource('PowerBi-OptIn-480px.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));

        InsertMediaResource('AssistedSetup-NoText-400px.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));
        InsertMediaResource('AssistedSetupDone-NoText-400px.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));
        InsertMediaResource('AssistedSetupInfo-NoText.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));
        InsertMediaResource('ExternalSync-NoText.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));
        InsertMediaResource('FirstInvoice1.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Phone));
        InsertMediaResource('FirstInvoice2.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Phone));
        InsertMediaResource('FirstInvoice3.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Phone));
        InsertMediaResource('FirstInvoiceSplash.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Phone));
        InsertMediaResource('PowerBi-OptIn-480px.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Tablet));
        InsertMediaResource('PowerBi-OptIn-480px.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Phone));
        InsertMediaResource('WhatsNewWizard-Banner-First.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));
        InsertMediaResource('WhatsNewWizard-Banner-Second.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));
    end;

    local procedure InsertExcelTemplates()
    begin
        InsertExcelTemplate(ExcelTemplateBalanceSheet() + '.xltm', ExcelTemplatesFolderLbl);
        InsertExcelTemplate(ExcelTemplateIncomeStatement() + '.xltm', ExcelTemplatesFolderLbl);
        InsertExcelTemplate(ExcelTemplateAgedAccountsPayable() + '.xltm', ExcelTemplatesFolderLbl);
        InsertExcelTemplate(ExcelTemplateAgedAccountsReceivable() + '.xltm', ExcelTemplatesFolderLbl);
        InsertExcelTemplate(ExcelTemplateCashFlowStatement() + '.xltm', ExcelTemplatesFolderLbl);
        InsertExcelTemplate(ExcelTemplateRetainedEarnings() + '.xltm', ExcelTemplatesFolderLbl);
        InsertExcelTemplate(ExcelTemplateTrialBalance() + '.xltm', ExcelTemplatesFolderLbl);
    end;

    local procedure InsertSalesStatusIcons()
    var
        IconType: Integer;
    begin
        for IconType := 0 to 5 do
            InsertSalesDocumentIcon(IconType);
    end;

    local procedure InsertWalkMeTour()
    var
        O365DeviceSetupInstructions: Record "O365 Device Setup Instructions";
        O365GettingStartedPageData: Record "O365 Getting Started Page Data";
        InStream: InStream;
        OutStream: OutStream;
    begin
        O365DeviceSetupInstructions.DeleteAll();
        O365DeviceSetupInstructions.Init();

        NavApp.GetResource(WalkMeTourFolderLbl + 'QRCode.png', InStream);
        O365DeviceSetupInstructions."QR Code".CreateOutStream(OutStream);
        CopyStream(OutStream, InStream);

        O365DeviceSetupInstructions.Insert();


        O365GettingStartedPageData.DeleteAll();
        InsertO365GettingStartedPageData(Page::"O365 Developer Welcome", 1, Format(CLIENTTYPE::Default), '1305-1-DEFAULT.png');
        InsertO365GettingStartedPageData(Page::"O365 Tour Complete", 1, Format(CLIENTTYPE::Default), '1306-1-DEFAULT.png');
        InsertO365GettingStartedPageData(Page::"O365 Getting Started Device", 1, Format(CLIENTTYPE::Default), '1307-1-DEFAULT.png');
        InsertO365GettingStartedPageData(Page::"O365 Getting Started Device", 1, Format(CLIENTTYPE::Phone), '1307-1-PHONE.png');
        InsertO365GettingStartedPageData(Page::"O365 Getting Started", 1, Format(CLIENTTYPE::Default), '1309-1-DEFAULT.png');
    end;

    local procedure ImportInvoicingEmailMedia()
    var
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        ContosoUtilities.InsertBLOBFromFile(PaymentServiceFolderLbl, 'Payment service - PayPal-logo.png');
        ContosoUtilities.InsertBLOBFromFile(PaymentServiceFolderLbl, 'Payment service - Microsoft-logo.png');
        ContosoUtilities.InsertBLOBFromFile(PaymentServiceFolderLbl, 'Payment service - WorldPay-logo.png');

        ContosoUtilities.InsertBLOBFromFile(SocialFolderLbl, 'Social - FACEBOOK.png');
        ContosoUtilities.InsertBLOBFromFile(SocialFolderLbl, 'Social - TWITTER.png');
        ContosoUtilities.InsertBLOBFromFile(SocialFolderLbl, 'Social - YOUTUBE.png');
        ContosoUtilities.InsertBLOBFromFile(SocialFolderLbl, 'Social - LINKEDIN.png');
        ContosoUtilities.InsertBLOBFromFile(SocialFolderLbl, 'Social - PINTEREST.png');
        ContosoUtilities.InsertBLOBFromFile(SocialFolderLbl, 'Social - YELP.png');
        ContosoUtilities.InsertBLOBFromFile(SocialFolderLbl, 'Social - INSTAGRAM.png');
    end;

    local procedure CreateO3565Template()
    var
        O365HTMLTemplate: Record "O365 HTML Template";
        ContosoUtilities: Codeunit "Contoso Utilities";
        MediaResourcesCode: Code[50];
    begin
        if O365HTMLTemplate.Get(SalesMailTok) then
            exit;

        MediaResourcesCode := ContosoUtilities.InsertBLOBFromFile(HTMLTemplatesFolderLbl, 'Invoicing - SalesMail.html');

        O365HTMLTemplate.Validate(Code, SalesMailTok);
        O365HTMLTemplate.Validate(Description, SalesMailDescLbl);
        O365HTMLTemplate.Validate("Media Resources Ref", MediaResourcesCode);
        O365HTMLTemplate.Insert(true);
    end;

    local procedure CreateLatePaymentModel()
    var
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        ContosoUtilities.InsertBLOBFromFile(MachineLearningFolderLbl, 'LatePaymentStandardModel.txt');
    end;

    procedure InsertExcelTemplate(FileName: Text; PathToFile: Text)
    var
        MediaResources: Record "Media Resources";
        InStream: InStream;
        OutStream: OutStream;
    begin
        if MediaResources.Get(FileName) then
            exit;

        NavApp.GetResource(PathToFile + FileName, InStream);
        MediaResources.Blob.CreateOutStream(OutStream);
        CopyStream(OutStream, InStream);
        MediaResources.Code := CopyStr(FileName, 1, MaxStrLen(MediaResources.Code));
#pragma warning disable AS0059
        MediaResources.Insert(true);
#pragma warning restore AS0059
    end;

    procedure InsertMediaResource(MediaFile: Text[50]; Path: Text[200]; DisplayTarget: Code[50])
    var
        MediaRepository: Record "Media Repository";
        MediaResourcesCode: Code[50];
    begin
        if MediaRepository.Get(MediaFile, DisplayTarget) then
            exit;

        MediaRepository.Validate("File Name", MediaFile);
        MediaRepository.Validate("Display Target", DisplayTarget);

        MediaResourcesCode := InsertMediaFromInstream(Path, MediaFile);

        MediaRepository.Validate("Media Resources Ref", MediaResourcesCode);
        MediaRepository.Insert(true);
    end;

    local procedure InsertSalesDocumentIcon(IconType: Option)
    var
        SalesDocumentIcon: Record "Sales Document Icon";
        MediaResources: Record "Media Resources";
        Language: Codeunit Language;
        MediaResourcesCode: Code[50];
        InStream: InStream;
        OldLanguageId: Integer;
    begin
        if SalesDocumentIcon.Get(IconType) then
            exit;

        SalesDocumentIcon.Type := IconType;
        MediaResourcesCode := Format(SalesDocumentIcon.Type);

        OldLanguageId := GlobalLanguage();
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());

        if not MediaResources.Get(MediaResourcesCode) then begin
            NavApp.GetResource(SalesDocumentIconFolderLbl + Format(SalesDocumentIcon.Type) + '.png', InStream);

            MediaResources.Init();
            MediaResources."MediaSet Reference".ImportStream(InStream, MediaResourcesCode);
            MediaResources.Validate(Code, MediaResourcesCode);
#pragma warning disable AS0059
            MediaResources.Insert(true);
#pragma warning restore AS0059
        end;
        GlobalLanguage(OldLanguageId);

        SalesDocumentIcon.Validate("Media Resources Ref", MediaResourcesCode);
        SalesDocumentIcon.Insert();
    end;

    local procedure InsertO365GettingStartedPageData(WizardID: Integer; No: Integer; DisplayTarget: Code[20]; FileName: Text)
    var
        O365GettingStartedPageData: Record "O365 Getting Started Page Data";
        MediaResourcesCode: Code[50];
    begin
        O365GettingStartedPageData."Wizard ID" := WizardID;
        O365GettingStartedPageData."No." := No;
        O365GettingStartedPageData."Display Target" := DisplayTarget;
        O365GettingStartedPageData.Type := O365GettingStartedPageData.Type::Image;

        MediaResourcesCode := InsertMediaFromInstream(WalkMeTourFolderLbl, FileName);

        O365GettingStartedPageData.Validate("Media Resources Ref", MediaResourcesCode);
        O365GettingStartedPageData.Insert();
    end;

    local procedure InsertMediaFromInstream(FilePath: Text; FileName: Text): Code[50]
    var
        MediaResourcesMgt: Codeunit "Media Resources Mgt.";
        MediaResourcesCode: Code[50];
        InStream: InStream;
    begin
        MediaResourcesCode := CopyStr(FileName, 1, MaxStrLen(MediaResourcesCode));

        NavApp.GetResource(FilePath + FileName, InStream);
        MediaResourcesMgt.InsertMediaFromInstream(MediaResourcesCode, InStream);
        exit(MediaResourcesCode);
    end;

    procedure ExcelTemplateBalanceSheet(): Text[50]
    begin
        exit('ExcelTemplateBalanceSheet');
    end;

    procedure ExcelTemplateIncomeStatement(): Text[50]
    begin
        exit('ExcelTemplateIncomeStatement');
    end;

    procedure ExcelTemplateAgedAccountsPayable(): Text[50]
    begin
        exit('ExcelTemplateAgedAccountsPayable');
    end;

    procedure ExcelTemplateAgedAccountsReceivable(): Text[50]
    begin
        exit('ExcelTemplateAgedAccountsReceivable');
    end;

    procedure ExcelTemplateCashFlowStatement(): Text[50]
    begin
        exit('ExcelTemplateCashFlowStatement');
    end;

    procedure ExcelTemplateRetainedEarnings(): Text[50]
    begin
        exit('ExcelTemplateRetainedEarnings');
    end;

    procedure ExcelTemplateTrialBalance(): Text[50]
    begin
        exit('ExcelTemplateTrialBalance');
    end;

    var
        ImagesSystemFolderLbl: Label 'Images/System/', Locked = true;
        ExcelTemplatesFolderLbl: Label 'ExcelTemplates/', Locked = true;
        SalesDocumentIconFolderLbl: Label 'SalesStatusIcons/', Locked = true;
        WalkMeTourFolderLbl: Label 'WalkMeTour/', Locked = true;
        PaymentServiceFolderLbl: Label 'PaymentService/', Locked = true;
        SocialFolderLbl: Label 'Social/', Locked = true;
        MachineLearningFolderLbl: Label 'MachineLearning/', Locked = true;
        HTMLTemplatesFolderLbl: Label 'HTMLTemplates/', Locked = true;
        SalesMailTok: Label 'SALESEMAIL', Locked = true;
        SalesMailDescLbl: Label 'Invoicing sales mail', MaxLength = 100;
}
