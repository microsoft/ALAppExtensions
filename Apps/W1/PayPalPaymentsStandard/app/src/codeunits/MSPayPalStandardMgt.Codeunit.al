namespace Microsoft.Bank.PayPal;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Payment;
using Microsoft.Bank.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Utilities;
using System.Integration;
using System.Environment;
using System.Environment.Configuration;
using System.Globalization;
using System.Reflection;
using System.Telemetry;

codeunit 1070 "MS - PayPal Standard Mgt."
{
    Permissions = TableData "Payment Method" = rimd, TableData "Payment Reporting Argument" = rimd;
    TableNo = "Payment Reporting Argument";
    trigger OnRun();
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000LHT', PaypalTelemetryTok, Enum::"Feature Uptake Status"::Used);
        if not GenerateHyperlink(Rec) then begin
            Session.LogMessage('0000801', PayPalNoLinkTelemetryTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
            if not GuiAllowed() then
                Error(PayPalNoLinkErr);
            if Confirm(PayPalNoLinkQst) then
                exit;
            Error('');
        end;
        SetCaptionBasedOnLanguage(Rec);
        Session.LogMessage('00001SY', PayPalHyperlinkIncludedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
    end;

    var
        InvoiceTxt: Label 'Invoice %1', Comment = '%1 Invoice No.';
        NotSupportedTypeErr: Label 'This function is not supported for the %1 table.', Comment = '%1 Caption of the table';
        PayPalCaptionURLTxt: Label 'Pay with PayPal';
        DemoLinkCaptionTxt: Label 'NOTE: This Is a test invoice. Therefore, no actual money transfer will be made.', Comment = 'Will be shown next to Pay with PayPal link';
        PayPalStandardNameTxt: Label 'PayPal Payments Standard';
        PayPalStandardDescriptionTxt: Label 'PayPal Payments Standard - Fee % of Amount';
        PayPalStandardBusinessSetupDescriptionTxt: Label 'Set up and enable the PayPal Payments Standard service.';
        YourReferenceTxt: Label 'Your Ref.', Comment = 'Ref. is short for reference from Your Reference field. After Ref there will be a number';
        TermsOfServiceURLTxt: Label 'https://www.paypal.com/%1/webapps/mpp/ua/useragreement-full', Locked = true;
        LogoURLTxt: Label 'https://bc-cdn.dynamics.com/common/images/extensionslogos/paypal_colour_v1.png', Locked = true;
        PayPalBaseURLTok: Label 'https://www.paypal.com/us/cgi-bin/webscr?cmd=_xclick&charset=UTF-8&page_style=primary', Locked = true;
        PayPalMandatoryParametersTok: Label 'business=%1&amount=%2&item_name=%3&invoice=%4&currency_code=%5', Locked = true;
        PayPalNotifyURLTok: Label '&notify_url=%1', Locked = true;
        TargetURLCannotBeChangedInDemoCompanyErr: Label 'You cannot change the target URL in the demonstration company.';
        SandboxPayPalBaseURLTok: Label 'https://www.sandbox.paypal.com/us/cgi-bin/webscr?cmd=_xclick&charset=UTF-8&page_style=primary', Locked = true;
        PayPalHomepageLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=836564', Locked = true;
        PayPalBusinessSetupKeywordsTxt: Label 'Finance,PayPal,Payment';
        PayPalPaymentMethodCodeTok: Label 'PAYPAL', Locked = true;
        PayPalPaymentMethodDescTok: Label 'PayPal payment';
        PayPalPaymentMethodDescFRCTok: Label 'Paiement PayPal', Locked = true;
        SandboxPrefixTok: Label 'sandbox.', Locked = true;
        PayPalSandBoxModeQst: Label 'Do you want to enable PayPal Sandbox setup?';
        PayPalTelemetryCategoryTok: Label 'AL Paypal', Locked = true;
        PayPalHyperlinkIncludedTxt: Label 'PayPal hyperlink included on sales document.', Locked = true;
        PayPalHyperlinkGeneratedTxt: Label 'PayPal hyperlink generated for sales document.', Locked = true;
        PayPalNoLinkTelemetryTxt: Label 'An error occured while creating the PayPal payment link.', Locked = true;
        PayPalNoLinkErr: Label 'An error occured while creating the PayPal payment link.';
        PayPalNoLinkQst: Label 'An error occured while creating the PayPal payment link.\\Do you want to continue to create the document without the link?';
        PayPalTargetURLIsEmptyTxt: Label 'PayPal target URL is empty.', Locked = true;
        PayPalTargetURLIsInvalidTxt: Label 'PayPal target URL is invalid.', Locked = true;
        CannotSetTargetURLTxt: Label 'Cannot set PayPal target URL: %1', Locked = true;
        InvoiceNoFormatTxt: Label '%1 (%2 %3)', Locked = true;
        PaymentReportingArgumentFormatTxt: Label '%1 (%2)', Locked = true;
        UrlJoinPlaceholderLbl: Label '%1&%2', Comment = '%1 - First part of the URL, %2 additional query', Locked = true;
        PayPalDocumentationHyperlinkLbl: Label 'https://go.microsoft.com/fwlink/?linkid=2248494', Locked = true;
        PayPalWebhookNotificationsTxt: Label 'PayPal Webhooks';
        PayPalWebhookNotificationsDescriptionTxt: Label 'Notify about setting up automatic payment registration when document is paid by PayPal.';
        SetupWebhooksNotificationMsg: Label 'If you have a Business PayPal account you can automatically register payments and close open documents. Would you like to learn more?';
        LearnMoreMsg: Label 'Learn more';
        DontShowAgainMsg: Label 'Don''t show again';
        PayPalTelemetryTok: Label 'PayPal', Locked = true;
        HyperlinkGeneratedTok: Label 'Hyperlink generated', Locked = true;

    internal procedure GetFeatureTelemetryName(): Text;
    begin
        exit(PayPalTelemetryTok);
    end;

    local procedure GenerateHyperlink(var PaymentReportingArgument: Record "Payment Reporting Argument"): Boolean;
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        MsPayPalStandardAccount: Record "MS - PayPal Standard Account";
        MSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
        DataTypeManagement: Codeunit "Data Type Management";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        DocumentRecordRef: RecordRef;
        BaseURL: Text;
        TargetURL: Text;
        QueryString: Text;
        InvoiceNo: Text;
    begin
        DataTypeManagement.GetRecordRef(PaymentReportingArgument."Document Record ID", DocumentRecordRef);


        case DocumentRecordRef.NUMBER() of
            DATABASE::"Sales Invoice Header":
                begin
                    GetTemplate(MSPayPalStandardTemplate);
                    MSPayPalStandardTemplate.RefreshLogoIfNeeded();
                    MsPayPalStandardAccount.SETAUTOCALCFIELDS("Target URL");
                    MsPayPalStandardAccount.GET(PaymentReportingArgument."Setup Record ID");
                    DocumentRecordRef.SETTABLE(SalesInvoiceHeader);
                    SalesInvoiceHeader.CALCFIELDS("Amount Including VAT");

                    InvoiceNo := SalesInvoiceHeader."No.";
                    if SalesInvoiceHeader."Your Reference" <> '' then
                        InvoiceNo := STRSUBSTNO(InvoiceNoFormatTxt, InvoiceNo, YourReferenceTxt, SalesInvoiceHeader."Your Reference");
                    QueryString := STRSUBSTNO(PayPalMandatoryParametersTok,
                        UriEscapeDataString(MsPayPalStandardAccount."Account ID"),
                        UriEscapeDataString(FORMAT(SalesInvoiceHeader."Amount Including VAT", 0, 9)),
                        UriEscapeDataString(STRSUBSTNO(InvoiceTxt, InvoiceNo)),
                        UriEscapeDataString(SalesInvoiceHeader."No."),
                        UriEscapeDataString(PaymentReportingArgument.GetCurrencyCode(SalesInvoiceHeader."Currency Code"))
                        );

                    if (not MsPayPalStandardAccount."Disable Webhook Notifications") then
                        QueryString += StrSubstNo(PayPalNotifyURLTok, UriEscapeDataString(GetNotifyURL()));

                    BaseURL := MsPayPalStandardAccount.GetTargetURL();
                    if BaseURL = '' then begin
                        Session.LogMessage('00007ZW', PayPalTargetURLIsEmptyTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
                        exit(false);
                    end;
                    TargetURL := StrSubstNo(UrlJoinPlaceholderLbl, BaseURL, QueryString);
                    if not PaymentReportingArgument.TrySetTargetURL(TargetURL) then begin
                        Session.LogMessage('00007ZX', PayPalTargetURLIsInvalidTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
                        Session.LogMessage('00008GJ', StrSubstNo(CannotSetTargetURLTxt, TargetURL), Verbosity::Warning, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
                        exit(false);
                    end;
                    PaymentReportingArgument.Logo := MSPayPalStandardTemplate.Logo;
                    PaymentReportingArgument."Payment Service ID" := PaymentReportingArgument.GetPayPalServiceID();
                    PaymentReportingArgument.MODIFY(true);

                    if SalesInvoiceHeader."No. Printed" = 1 then
                        Session.LogMessage('00001ZR', PayPalHyperlinkGeneratedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
                    FeatureTelemetry.LogUsage('0000LHU', PayPalTelemetryTok, HyperlinkGeneratedTok);

                    exit(true);
                end;
            DATABASE::"Sales Header":
                begin
                    GetTemplate(MSPayPalStandardTemplate);
                    MSPayPalStandardTemplate.RefreshLogoIfNeeded();

                    PaymentReportingArgument.SetTargetURL(PayPalHomepageLinkTxt);
                    PaymentReportingArgument.Logo := MSPayPalStandardTemplate.Logo;
                    PaymentReportingArgument."Payment Service ID" := PaymentReportingArgument.GetPayPalServiceID();
                    PaymentReportingArgument.MODIFY(true);
                    FeatureTelemetry.LogUsage('0000LHV', PayPalTelemetryTok, HyperlinkGeneratedTok);

                    exit(true);
                end;
            else
                ERROR(NotSupportedTypeErr, DocumentRecordRef.CAPTION());
        end;
    end;

    local procedure GetSetupWebhooksNotificationID(): Guid
    begin
        exit('be1a2bc8-8c31-1eda-23ab-b153cd645355');
    end;

    local procedure UriEscapeDataString(Uri: Text): Text;
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.UriEscapeDataString(Uri));
    end;

    local procedure SetCaptionBasedOnLanguage(var PaymentReportingArgument: Record "Payment Reporting Argument");
    var
        Language: Record "Language";
        CurrentLanguage: Integer;
    begin
        CurrentLanguage := GLOBALLANGUAGE();
        if Language.GET(PaymentReportingArgument."Language Code") then
            GLOBALLANGUAGE(Language."Windows Language ID");

        PaymentReportingArgument.VALIDATE("URL Caption", PayPalCaptionURLTxt);
        if STRPOS(PaymentReportingArgument.GetTargetURL(), GetSandboxURL()) > 0 then
            PaymentReportingArgument.VALIDATE("URL Caption", STRSUBSTNO(PaymentReportingArgumentFormatTxt, PayPalCaptionURLTxt, DemoLinkCaptionTxt));
        PaymentReportingArgument.MODIFY(true);

        if GLOBALLANGUAGE() <> CurrentLanguage then
            GLOBALLANGUAGE(CurrentLanguage);
    end;

    procedure GetTemplate(var TempMsPayPalStandardTemplate: Record "MS - PayPal Standard Template" temporary);
    var
        MsPayPalStandardTemplate: Record "MS - PayPal Standard Template";
    begin
        if MsPayPalStandardTemplate.GET() then begin
            MsPayPalStandardTemplate.CALCFIELDS(Logo, "Target URL");
            TempMsPayPalStandardTemplate.TRANSFERFIELDS(MsPayPalStandardTemplate, true);
            exit;
        end;

        TempMsPayPalStandardTemplate.INIT();
        TempMsPayPalStandardTemplate.INSERT();
        TemplateAssignDefaultValues(TempMsPayPalStandardTemplate);
    end;

    procedure TemplateAssignDefaultValues(var MsPayPalStandardTemplate: Record "MS - PayPal Standard Template");
    begin
        MsPayPalStandardTemplate.VALIDATE(Name, PayPalStandardNameTxt);
        MsPayPalStandardTemplate.VALIDATE(Description, PayPalStandardDescriptionTxt);
        MsPayPalStandardTemplate.VALIDATE("Terms of Service", STRSUBSTNO(TermsOfServiceURLTxt, GetCountryCode()));
        MsPayPalStandardTemplate.VALIDATE("Logo Update Frequency", 7 * 24 * 3600 * 1000);
        MsPayPalStandardTemplate.MODIFY(true);
        MsPayPalStandardTemplate.SetTargetURLNoVerification(GetTargetURL());
        MsPayPalStandardTemplate.SetLogoURLNoVerification(LogoURLTxt);
    end;

    procedure GetPayPalPaymentMethod(var PaymentMethod: Record "Payment Method");
    begin
        RegisterPayPalPaymentMethod(PaymentMethod);
    end;

    internal procedure RunPaymentRegistrationSetupForce()
    var
        PaymentRegistrationMgt: Codeunit "Payment Registration Mgt.";
        SetupOK: Boolean;
    begin
        SetupOK := PAGE.RunModal(PAGE::"Payment Registration Setup") = ACTION::LookupOK;
        if not SetupOK then
            exit;

        PaymentRegistrationMgt.RunSetup();
    end;

    local procedure RegisterPayPalPaymentMethod(var PaymentMethod: Record "Payment Method");
    begin
        if PaymentMethod.GET(PayPalPaymentMethodCodeTok) then begin
            InsertCanadaFrenchTranslation(); // we can remove this line after a while, as this is to batch existing tenants (lazy upgrade)
            exit;
        end;

        PaymentMethod.Init();
        PaymentMethod.Code := PayPalPaymentMethodCodeTok;
        PaymentMethod.Description := PayPalPaymentMethodDescTok;
        PaymentMethod."Bal. Account Type" := PaymentMethod."Bal. Account Type"::"G/L Account";
        if PaymentMethod.INSERT() then;
        InsertCanadaFrenchTranslation();
    end;

    local procedure IsCanada(): Boolean;
    var
        CompanyInformation: Record "Company Information";
    begin
        if CompanyInformation.GET() then
            exit(CompanyInformation."Country/Region Code" = 'CA');
        exit(false);
    end;

    local procedure InsertCanadaFrenchTranslation();
    var
        PaymentmethodTranslation: Record "Payment Method Translation";
    begin
        if not IsCanada() then
            exit;
        PaymentmethodTranslation."Payment Method Code" := PayPalPaymentMethodCodeTok;
        PaymentmethodTranslation."Language Code" := 'FRC';
        PaymentmethodTranslation.Description := PayPalPaymentMethodDescFRCTok;
        if PaymentmethodTranslation.INSERT() then;
    end;

    [EventSubscriber(ObjectType::Table, Database::"MS - PayPal Standard Account", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertPayPalStandardAccount(var Rec: Record "MS - PayPal Standard Account"; RunTrigger: Boolean);
    var
        PaymentMethod: Record "Payment Method";
    begin
        if Rec.IsTemporary() then
            exit;

        RegisterPayPalPaymentMethod(PaymentMethod);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Service Setup", 'OnRegisterPaymentServices', '', false, false)]
    local procedure RegisterPayPalStandardAccounts(var PaymentServiceSetup: Record 1060);
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
    begin
        if not MSPayPalStandardAccount.FINDSET() then
            exit;

        repeat
            CLEAR(PaymentServiceSetup);
            PaymentServiceSetup.TRANSFERFIELDS(MSPayPalStandardAccount, false);
            PaymentServiceSetup."Setup Record ID" := MSPayPalStandardAccount.RECORDID();
            PaymentServiceSetup.AssignPrimaryKey(PaymentServiceSetup);
            PaymentServiceSetup."Management Codeunit ID" := CODEUNIT::"MS - PayPal Standard Mgt.";
            PaymentServiceSetup.INSERT(true);
        until MSPayPalStandardAccount.NEXT() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Service Setup", 'OnRegisterPaymentServiceProviders', '', false, false)]
    local procedure RegisterPayPalStandardTemplateOnRegisterPaymentServiceProviders(var PaymentServiceSetup: Record 1060);
    begin
        RegisterPayPalStandardTemplate(PaymentServiceSetup)
    end;

    procedure RegisterPayPalStandardTemplate(var PaymentServiceSetup: Record 1060);
    var
        TempMSPayPalStandardTemplate: Record "MS - PayPal Standard Template" temporary;
    begin
        CLEAR(PaymentServiceSetup);
        GetTemplate(TempMSPayPalStandardTemplate);

        PaymentServiceSetup.Name := TempMSPayPalStandardTemplate.Name;
        PaymentServiceSetup.Description := TempMSPayPalStandardTemplate.Description;
        PaymentServiceSetup."Setup Record ID" := TempMSPayPalStandardTemplate.RECORDID();
        PaymentServiceSetup."Management Codeunit ID" := CODEUNIT::"MS - PayPal Standard Mgt.";
        PaymentServiceSetup.AssignPrimaryKey(PaymentServiceSetup);
        PaymentServiceSetup.INSERT(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Service Setup", 'OnCreatePaymentService', '', false, false)]
    local procedure NewPaymentAccount(var PaymentServiceSetup: Record 1060);
    var
        MSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
    begin
        if PaymentServiceSetup."Management Codeunit ID" <> CODEUNIT::"MS - PayPal Standard Mgt." then
            exit;

        GetTemplate(MSPayPalStandardTemplate);
        MSPayPalStandardAccount.TRANSFERFIELDS(MSPayPalStandardTemplate, false);
        MSPayPalStandardAccount.INSERT(true);
        COMMIT();
        PAGE.RUNMODAL(PAGE::"MS - PayPal Standard Setup", MSPayPalStandardAccount);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', false, false)]
    local procedure RegisterServiceConnection(var ServiceConnection: Record "Service Connection");
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        MSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
        RecRef: RecordRef;
        TargetURL: Text;
    begin
        if not MSPayPalStandardAccount.FINDSET() then begin
            GetTemplate(MSPayPalStandardTemplate);
            MSPayPalStandardAccount.TRANSFERFIELDS(MSPayPalStandardTemplate, false);
            MSPayPalStandardAccount.INSERT(true);
        end;

        repeat
            RecRef.GETTABLE(MSPayPalStandardAccount);

            if MSPayPalStandardAccount.Enabled then
                ServiceConnection.Status := ServiceConnection.Status::Enabled
            else
                ServiceConnection.Status := ServiceConnection.Status::Disabled;

            TargetURL := MSPayPalStandardAccount.GetTargetURL();
            ServiceConnection.InsertServiceConnection(
              ServiceConnection, RecRef.RECORDID(), MSPayPalStandardAccount.Description,
              COPYSTR(TargetURL, 1, MAXSTRLEN(ServiceConnection."Host Name")), PAGE::"MS - PayPal Standard Setup");
        until MSPayPalStandardAccount.NEXT() = 0
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterManualSetup', '', false, false)]
    local procedure RegisterBusinessSetup(var Sender: Codeunit "Guided Experience");
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        MSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
    begin
        if not MSPayPalStandardAccount.FindFirst() then begin
            GetTemplate(MSPayPalStandardTemplate);
            MSPayPalStandardAccount.TransferFields(MSPayPalStandardTemplate, false);
            MSPayPalStandardAccount.Insert(true);
        end;

        Sender.InsertManualSetup(
          PayPalStandardNameTxt, PayPalStandardNameTxt, PayPalStandardBusinessSetupDescriptionTxt, 0, ObjectType::Page,
          Page::"MS - PayPal Standard Setup", "Manual Setup Category"::Service, PayPalBusinessSetupKeywordsTxt);
    end;

    procedure ValidateChangeTargetURL();
    var
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if CompanyInformationMgt.IsDemoCompany() and EnvironmentInformation.IsSaaS() then
            ERROR(TargetURLCannotBeChangedInDemoCompanyErr);
    end;

    procedure IsValidAndSecureURL(URL: Text): Boolean;
    var
        WebRequestHelper: Codeunit "Web Request Helper";
    begin
        if WebRequestHelper.IsValidUri(URL) then
            if WebRequestHelper.IsHttpUrl(URL) then
                if WebRequestHelper.IsSecureHttpUrl(URL) then
                    exit(true);
        exit(false);
    end;

    procedure GetTargetURL(): Text;
    var
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        if CompanyInformationMgt.IsDemoCompany() then
            exit(GetSandboxURL());

        exit(PayPalBaseURLTok);
    end;

    internal procedure SendSendSetupWebhooksNotification()
    var
        MyNotifications: Record "My Notifications";
        SendSetupWebhooksNotification: Notification;
    begin
        if MyNotifications.Get(UserId(), GetSetupWebhooksNotificationID()) then
            if MyNotifications.Enabled = false then
                exit;

        SendSetupWebhooksNotification.Id := GetSetupWebhooksNotificationID();
        if SendSetupWebhooksNotification.Recall() then;

        SendSetupWebhooksNotification.Message(SetupWebhooksNotificationMsg);
        SendSetupWebhooksNotification.Scope(NotificationScope::LocalScope);
        SendSetupWebhooksNotification.AddAction(LearnMoreMsg, Codeunit::"MS - PayPal Standard Mgt.", 'WebhooksLearnMore');
        SendSetupWebhooksNotification.AddAction(DontShowAgainMsg, Codeunit::"MS - PayPal Standard Mgt.", 'DontShowAgainWebhooks');
        SendSetupWebhooksNotification.Send();
    end;

    procedure GetSandboxURL(): Text;
    begin
        exit(SandboxPayPalBaseURLTok);
    end;

    procedure WebhooksLearnMore(Notification: Notification)
    begin
        Hyperlink(PayPalDocumentationHyperlinkLbl);
    end;

    procedure DontShowAgainWebhooks(Notification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.SetStatus(GetSetupWebhooksNotificationID(), false) then
            MyNotifications.InsertDefault(
              GetSetupWebhooksNotificationID(), PayPalWebhookNotificationsTxt, PayPalWebhookNotificationsDescriptionTxt, false);
    end;

    local procedure GetNotifyURL(): Text;
    var
        WebhookManagement: Codeunit "Webhook Management";
        NotifyURL: Text;
    begin
        NotifyURL := WebhookManagement.GetNotificationUrl();
        exit(NotifyURL);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Paypal Account Proxy", 'GetPaypalAccount', '', false, false)]
    local procedure GetPaypalAccount(var Account: Text[250]);
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
    begin
        if MSPayPalStandardAccount.FINDFIRST() then
            Account := MSPayPalStandardAccount."Account ID";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Paypal Account Proxy", 'SetAlwaysIncludePaypalOnDocuments', '', false, false)]
    local procedure HandleSetAlwaysIncludePaypalOnDocuments(NewAlwaysIncludeOnDocuments: Boolean; HideDialogs: Boolean);
    begin
        SetAlwaysIncludeOnDocuments(NewAlwaysIncludeOnDocuments, HideDialogs);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Service Setup", 'OnDoNotIncludeAnyPaymentServicesOnAllDocuments', '', false, false)]
    local procedure HandleOnDoNotIncludeAnyPaymentServicesOnAllDocuments();
    begin
        SetAlwaysIncludeOnDocuments(false, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Paypal Account Proxy", 'GetPaypalSetupOptions', '', false, false)]
    local procedure HandleGetPaypalSetupOptions(var Enabled: Boolean; var IncludeInAllDocuments: Boolean);
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
    begin
        if not MSPayPalStandardAccount.FindFirst() then
            exit;

        Enabled := MSPayPalStandardAccount.Enabled;
        IncludeInAllDocuments := MSPayPalStandardAccount."Always Include on Documents";
    end;

    local procedure SetAlwaysIncludeOnDocuments(NewAlwaysIncludeOnDocuments: Boolean; HideDialogs: Boolean);
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
    begin
        if HideDialogs then
            MSPayPalStandardAccount.HideAllDialogs();

        if not MSPayPalStandardAccount.FINDFIRST() then
            exit;

        MSPayPalStandardAccount.Validate("Always Include on Documents", NewAlwaysIncludeOnDocuments);
        MSPayPalStandardAccount.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Paypal Account Proxy", 'SetPaypalAccount', '', false, false)]
    local procedure SetPaypalAccountOnSetPaypalAccount(Account: Text[250]; Silent: Boolean);
    begin
        SetPaypalAccount(Account, Silent)
    end;

    procedure SetPaypalAccount(Account: Text[250]; Silent: Boolean);
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        TempPaymentServiceSetup: Record 1060 temporary;
        MSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
        O365SalesInvoicePayment: Codeunit "O365 Sales Invoice Payment";
        TargetURL: Text;
    begin
        MSPayPalStandardAccount.HideAllDialogs();

        Account := LowerCase(Account);

        if not MSPayPalStandardAccount.FindFirst() then begin
            RegisterPayPalStandardTemplate(TempPaymentServiceSetup);
            GetTemplate(MSPayPalStandardTemplate);
            MSPayPalStandardTemplate.RefreshLogoIfNeeded();
            MSPayPalStandardAccount.TransferFields(MSPayPalStandardTemplate, false);
            MSPayPalStandardAccount.Insert(true);
        end;

        TargetURL := GetTargetURL();
        if StrPos(Account, SandboxPrefixTok) = 1 then
            if Silent or not GuiAllowed() then
                TargetURL := GetSandboxURL()
            else
                if Confirm(PayPalSandBoxModeQst) then
                    TargetURL := GetSandboxURL();

        // Keep SetTargetURL before VALIDATE, since it calls Modify without trigger
        MSPayPalStandardAccount.SetTargetURL(TargetURL);
        MSPayPalStandardAccount.Validate("Account ID", Account);

        if Account <> '' then begin
            MSPayPalStandardAccount.Validate(Enabled, true);
            MSPayPalStandardAccount.Validate("Always Include on Documents", true);
        end else begin
            MSPayPalStandardAccount.Validate(Enabled, false);
            MSPayPalStandardAccount.Validate("Always Include on Documents", false);
        end;
        MSPayPalStandardAccount.Modify(true);

        O365SalesInvoicePayment.UpdatePaymentServicesForInvoicesQuotesAndOrders();
    end;

    local procedure GetCountryCode(): Code[10];
    var
        CompanyInformation: Record "Company Information";
    begin
        if CompanyInformation.GET() then
            exit(CompanyInformation."Country/Region Code");
        exit('');
    end;
}

