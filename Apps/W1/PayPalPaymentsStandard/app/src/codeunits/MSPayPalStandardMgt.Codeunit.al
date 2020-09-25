codeunit 1070 "MS - PayPal Standard Mgt."
{
    Permissions = TableData 289 = rimd, TableData 1062 = rimd;
    TableNo = 1062;

    trigger OnRun();
    begin
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
        LogoURLTxt: Label 'https://cdn-bc.dynamics.com/common/images/extensionslogos/paypal_colour_v1.png', Locked = true;
        PayPalBaseURLTok: Label 'https://www.paypal.com/us/cgi-bin/webscr?cmd=_xclick&charset=UTF-8&page_style=primary', Locked = true;
        PayPalMandatoryParametersTok: Label 'business=%1&amount=%2&item_name=%3&invoice=%4&currency_code=%5&notify_url=%6', Locked = true;
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

    local procedure GenerateHyperlink(var PaymentReportingArgument: Record 1062): Boolean;
    var
        SalesInvoiceHeader: Record 112;
        MsPayPalStandardAccount: Record 1070;
        MSPayPalStandardTemplate: Record 1071;
        DataTypeManagement: Codeunit 701;
        DocumentRecordRef: RecordRef;
        BaseURL: Text;
        TargetURL: Text;
        QueryString: Text;
        InvoiceNo: Text;
    begin
        DataTypeManagement.GetRecordRef(PaymentReportingArgument."Document Record ID", DocumentRecordRef);


        CASE DocumentRecordRef.NUMBER() OF
            DATABASE::"Sales Invoice Header":
                BEGIN
                    GetTemplate(MSPayPalStandardTemplate);
                    MSPayPalStandardTemplate.RefreshLogoIfNeeded();
                    MsPayPalStandardAccount.SETAUTOCALCFIELDS("Target URL");
                    MsPayPalStandardAccount.GET(PaymentReportingArgument."Setup Record ID");
                    DocumentRecordRef.SETTABLE(SalesInvoiceHeader);
                    SalesInvoiceHeader.CALCFIELDS("Amount Including VAT");

                    InvoiceNo := SalesInvoiceHeader."No.";
                    IF SalesInvoiceHeader."Your Reference" <> '' THEN
                        InvoiceNo := STRSUBSTNO(InvoiceNoFormatTxt, InvoiceNo, YourReferenceTxt, SalesInvoiceHeader."Your Reference");
                    QueryString := STRSUBSTNO(PayPalMandatoryParametersTok,
                        UriEscapeDataString(MsPayPalStandardAccount."Account ID"),
                        UriEscapeDataString(FORMAT(SalesInvoiceHeader."Amount Including VAT", 0, 9)),
                        UriEscapeDataString(STRSUBSTNO(InvoiceTxt, InvoiceNo)),
                        UriEscapeDataString(SalesInvoiceHeader."No."),
                        UriEscapeDataString(PaymentReportingArgument.GetCurrencyCode(SalesInvoiceHeader."Currency Code")),
                        UriEscapeDataString(GetNotifyURL()));
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
                    PaymentReportingArgument.MODIFY(TRUE);

                    IF SalesInvoiceHeader."No. Printed" = 1 then
                        Session.LogMessage('00001ZR', PayPalHyperlinkGeneratedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);

                    exit(true);
                END;
            DATABASE::"Sales Header":
                BEGIN
                    GetTemplate(MSPayPalStandardTemplate);
                    MSPayPalStandardTemplate.RefreshLogoIfNeeded();

                    PaymentReportingArgument.SetTargetURL(PayPalHomepageLinkTxt);
                    PaymentReportingArgument.Logo := MSPayPalStandardTemplate.Logo;
                    PaymentReportingArgument."Payment Service ID" := PaymentReportingArgument.GetPayPalServiceID();
                    PaymentReportingArgument.MODIFY(TRUE);

                    exit(true);
                END;
            ELSE
                ERROR(NotSupportedTypeErr, DocumentRecordRef.CAPTION());
        END;
    end;

    local procedure UriEscapeDataString(Uri: Text): Text;
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.UriEscapeDataString(Uri));
    end;

    local procedure SetCaptionBasedOnLanguage(var PaymentReportingArgument: Record 1062);
    var
        Language: Record 8;
        CurrentLanguage: Integer;
    begin
        CurrentLanguage := GLOBALLANGUAGE();
        IF Language.GET(PaymentReportingArgument."Language Code") THEN
            GLOBALLANGUAGE(Language."Windows Language ID");

        PaymentReportingArgument.VALIDATE("URL Caption", PayPalCaptionURLTxt);
        IF STRPOS(PaymentReportingArgument.GetTargetURL(), GetSandboxURL()) > 0 THEN
            PaymentReportingArgument.VALIDATE("URL Caption", STRSUBSTNO(PaymentReportingArgumentFormatTxt, PayPalCaptionURLTxt, DemoLinkCaptionTxt));
        PaymentReportingArgument.MODIFY(TRUE);

        IF GLOBALLANGUAGE() <> CurrentLanguage THEN
            GLOBALLANGUAGE(CurrentLanguage);
    end;

    procedure GetTemplate(var TempMsPayPalStandardTemplate: Record 1071 temporary);
    var
        MsPayPalStandardTemplate: Record 1071;
    begin
        IF MsPayPalStandardTemplate.GET() THEN BEGIN
            MsPayPalStandardTemplate.CALCFIELDS(Logo, "Target URL");
            TempMsPayPalStandardTemplate.TRANSFERFIELDS(MsPayPalStandardTemplate, TRUE);
            EXIT;
        END;

        TempMsPayPalStandardTemplate.INIT();
        TempMsPayPalStandardTemplate.INSERT();
        TemplateAssignDefaultValues(TempMsPayPalStandardTemplate);
    end;

    procedure TemplateAssignDefaultValues(var MsPayPalStandardTemplate: Record 1071);
    begin
        MsPayPalStandardTemplate.VALIDATE(Name, PayPalStandardNameTxt);
        MsPayPalStandardTemplate.VALIDATE(Description, PayPalStandardDescriptionTxt);
        MsPayPalStandardTemplate.VALIDATE("Terms of Service", STRSUBSTNO(TermsOfServiceURLTxt, GetCountryCode()));
        MsPayPalStandardTemplate.VALIDATE("Logo Update Frequency", 7 * 24 * 3600 * 1000);
        MsPayPalStandardTemplate.MODIFY(TRUE);
        MsPayPalStandardTemplate.SetTargetURLNoVerification(GetTargetURL());
        MsPayPalStandardTemplate.SetLogoURLNoVerification(LogoURLTxt);
    end;

    procedure GetPayPalPaymentMethod(var PaymentMethod: Record 289);
    begin
        RegisterPayPalPaymentMethod(PaymentMethod);
    end;

    local procedure RegisterPayPalPaymentMethod(var PaymentMethod: Record 289);
    begin
        IF PaymentMethod.GET(PayPalPaymentMethodCodeTok) THEN begin
            InsertCanadaFrenchTranslation(); // we can remove this line after a while, as this is to batch existing tenants (lazy upgrade)
            EXIT;
        end;

        PaymentMethod.INIT();
        PaymentMethod.Code := PayPalPaymentMethodCodeTok;
        PaymentMethod.Description := PayPalPaymentMethodDescTok;
        PaymentMethod."Bal. Account Type" := PaymentMethod."Bal. Account Type"::"G/L Account";
        PaymentMethod."Use for Invoicing" := TRUE;
        IF PaymentMethod.INSERT() THEN;

        InsertCanadaFrenchTranslation();
    end;

    local PROCEDURE IsCanada(): Boolean;
    var
        CompanyInformation: Record 79;
    BEGIN
        IF CompanyInformation.GET() THEN
            EXIT(CompanyInformation."Country/Region Code" = 'CA');
        exit(false);
    END;

    local PROCEDURE InsertCanadaFrenchTranslation();
    VAR
        PaymentmethodTranslation: Record 466;
    BEGIN
        if not IsCanada() then
            exit;
        PaymentmethodTranslation."Payment Method Code" := PayPalPaymentMethodCodeTok;
        PaymentmethodTranslation."Language Code" := 'FRC';
        PaymentmethodTranslation.Description := PayPalPaymentMethodDescFRCTok;
        IF PaymentmethodTranslation.INSERT() THEN;
    END;

    [EventSubscriber(ObjectType::Table, 1070, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertPayPalStandardAccount(var Rec: Record 1070; RunTrigger: Boolean);
    var
        PaymentMethod: Record 289;
    begin
        RegisterPayPalPaymentMethod(PaymentMethod);
    end;

    [EventSubscriber(ObjectType::Table, 1060, 'OnRegisterPaymentServices', '', false, false)]
    local procedure RegisterPayPalStandardAccounts(var PaymentServiceSetup: Record 1060);
    var
        MSPayPalStandardAccount: Record 1070;
    begin
        IF NOT MSPayPalStandardAccount.FINDSET() THEN
            EXIT;

        REPEAT
            CLEAR(PaymentServiceSetup);
            PaymentServiceSetup.TRANSFERFIELDS(MSPayPalStandardAccount, FALSE);
            PaymentServiceSetup."Setup Record ID" := MSPayPalStandardAccount.RECORDID();
            PaymentServiceSetup.AssignPrimaryKey(PaymentServiceSetup);
            PaymentServiceSetup."Management Codeunit ID" := CODEUNIT::"MS - PayPal Standard Mgt.";
            PaymentServiceSetup.INSERT(TRUE);
        UNTIL MSPayPalStandardAccount.NEXT() = 0;
    end;

    [EventSubscriber(ObjectType::Table, 1060, 'OnRegisterPaymentServiceProviders', '', false, false)]
    procedure RegisterPayPalStandardTemplate(var PaymentServiceSetup: Record 1060);
    var
        TempMSPayPalStandardTemplate: Record 1071 temporary;
    begin
        CLEAR(PaymentServiceSetup);
        GetTemplate(TempMSPayPalStandardTemplate);

        PaymentServiceSetup.Name := TempMSPayPalStandardTemplate.Name;
        PaymentServiceSetup.Description := TempMSPayPalStandardTemplate.Description;
        PaymentServiceSetup."Setup Record ID" := TempMSPayPalStandardTemplate.RECORDID();
        PaymentServiceSetup."Management Codeunit ID" := CODEUNIT::"MS - PayPal Standard Mgt.";
        PaymentServiceSetup.AssignPrimaryKey(PaymentServiceSetup);
        PaymentServiceSetup.INSERT(TRUE);
    end;

    [EventSubscriber(ObjectType::Table, 1060, 'OnCreatePaymentService', '', false, false)]
    local procedure NewPaymentAccount(var PaymentServiceSetup: Record 1060);
    var
        MSPayPalStandardTemplate: Record 1071;
        MSPayPalStandardAccount: Record 1070;
    begin
        IF PaymentServiceSetup."Management Codeunit ID" <> CODEUNIT::"MS - PayPal Standard Mgt." THEN
            EXIT;

        GetTemplate(MSPayPalStandardTemplate);
        MSPayPalStandardAccount.TRANSFERFIELDS(MSPayPalStandardTemplate, FALSE);
        MSPayPalStandardAccount.INSERT(TRUE);
        COMMIT();
        PAGE.RUNMODAL(PAGE::"MS - PayPal Standard Setup", MSPayPalStandardAccount);
    end;

    [EventSubscriber(ObjectType::Table, 1400, 'OnRegisterServiceConnection', '', false, false)]
    local procedure RegisterServiceConnection(var ServiceConnection: Record 1400);
    var
        MSPayPalStandardAccount: Record 1070;
        MSPayPalStandardTemplate: Record 1071;
        RecRef: RecordRef;
        TargetURL: Text;
    begin
        IF NOT MSPayPalStandardAccount.FINDSET() THEN BEGIN
            GetTemplate(MSPayPalStandardTemplate);
            MSPayPalStandardAccount.TRANSFERFIELDS(MSPayPalStandardTemplate, FALSE);
            MSPayPalStandardAccount.INSERT(TRUE);
        END;

        REPEAT
            RecRef.GETTABLE(MSPayPalStandardAccount);

            IF MSPayPalStandardAccount.Enabled THEN
                ServiceConnection.Status := ServiceConnection.Status::Enabled
            ELSE
                ServiceConnection.Status := ServiceConnection.Status::Disabled;

            TargetURL := MSPayPalStandardAccount.GetTargetURL();
            ServiceConnection.InsertServiceConnection(
              ServiceConnection, RecRef.RECORDID(), MSPayPalStandardAccount.Description,
              COPYSTR(TargetURL, 1, MAXSTRLEN(ServiceConnection."Host Name")), PAGE::"MS - PayPal Standard Setup");
        UNTIL MSPayPalStandardAccount.NEXT() = 0
    end;

    [EventSubscriber(ObjectType::Codeunit, 1875, 'OnRegisterManualSetup', '', false, false)]
    local procedure RegisterBusinessSetup(var Sender: Codeunit 1875);
    var
        MSPayPalStandardAccount: Record 1070;
        MSPayPalStandardTemplate: Record 1071;
        ManualSetupCategory: Enum "Manual Setup Category";
    begin
        IF NOT MSPayPalStandardAccount.FINDFIRST() THEN BEGIN
            GetTemplate(MSPayPalStandardTemplate);
            MSPayPalStandardAccount.TRANSFERFIELDS(MSPayPalStandardTemplate, FALSE);
            MSPayPalStandardAccount.INSERT(TRUE);
        END;

        Sender.Insert(
          PayPalStandardNameTxt, PayPalStandardBusinessSetupDescriptionTxt, PayPalBusinessSetupKeywordsTxt,
          PAGE::"MS - PayPal Standard Setup", 'd09fa965-9a2a-424d-b704-69f3b54ed0ce', ManualSetupCategory::Service);
    end;

    procedure ValidateChangeTargetURL();
    var
        CompanyInformationMgt: Codeunit 1306;
        EnvironmentInfo: Codeunit 457;
    begin
        IF CompanyInformationMgt.IsDemoCompany() AND EnvironmentInfo.IsSaaS() THEN
            ERROR(TargetURLCannotBeChangedInDemoCompanyErr);
    end;

    procedure IsValidAndSecureURL(URL: Text): Boolean;
    var
        WebRequestHelper: Codeunit 1299;
    begin
        if WebRequestHelper.IsValidUri(URL) then
            if WebRequestHelper.IsHttpUrl(URL) then
                if WebRequestHelper.IsSecureHttpUrl(URL) then
                    exit(true);
        exit(false);
    end;

    procedure GetTargetURL(): Text;
    var
        CompanyInformationMgt: Codeunit 1306;
    begin
        IF CompanyInformationMgt.IsDemoCompany() THEN
            EXIT(GetSandboxURL());

        EXIT(PayPalBaseURLTok);
    end;

    procedure GetSandboxURL(): Text;
    begin
        EXIT(SandboxPayPalBaseURLTok);
    end;

    local procedure GetNotifyURL(): Text;
    var
        WebhookManagement: Codeunit 5377;
        NotifyURL: Text;
    begin
        NotifyURL := WebhookManagement.GetNotificationUrl();
        EXIT(NotifyURL);
    end;

    [EventSubscriber(ObjectType::Codeunit, 1060, 'GetPaypalAccount', '', false, false)]
    local procedure GetPaypalAccount(var Account: Text[250]);
    var
        MSPayPalStandardAccount: Record 1070;
    begin
        IF MSPayPalStandardAccount.FINDFIRST() THEN
            Account := MSPayPalStandardAccount."Account ID";
    end;

    [EventSubscriber(ObjectType::Codeunit, 1060, 'SetAlwaysIncludePaypalOnDocuments', '', false, false)]
    local procedure HandleSetAlwaysIncludePaypalOnDocuments(NewAlwaysIncludeOnDocuments: Boolean; HideDialogs: Boolean);
    begin
        SetAlwaysIncludeOnDocuments(NewAlwaysIncludeOnDocuments, HideDialogs);
    end;

    [EventSubscriber(ObjectType::Table, 1060, 'OnDoNotIncludeAnyPaymentServicesOnAllDocuments', '', false, false)]
    local procedure HandleOnDoNotIncludeAnyPaymentServicesOnAllDocuments();
    begin
        SetAlwaysIncludeOnDocuments(false, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 1060, 'GetPaypalSetupOptions', '', false, false)]
    local procedure HandleGetPaypalSetupOptions(var Enabled: Boolean; var IncludeInAllDocuments: Boolean);
    var
        MSPayPalStandardAccount: Record 1070;
    begin
        if not MSPayPalStandardAccount.FindFirst() then
            exit;

        Enabled := MSPayPalStandardAccount.Enabled;
        IncludeInAllDocuments := MSPayPalStandardAccount."Always Include on Documents";
    end;

    local procedure SetAlwaysIncludeOnDocuments(NewAlwaysIncludeOnDocuments: Boolean; HideDialogs: Boolean);
    var
        MSPayPalStandardAccount: Record 1070;
    begin
        if HideDialogs then
            MSPayPalStandardAccount.HideAllDialogs();

        if not MSPayPalStandardAccount.FINDFIRST() then
            exit;

        MSPayPalStandardAccount.Validate("Always Include on Documents", NewAlwaysIncludeOnDocuments);
        MSPayPalStandardAccount.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 1060, 'SetPaypalAccount', '', false, false)]
    procedure SetPaypalAccount(Account: Text[250]; Silent: Boolean);
    var
        MSPayPalStandardAccount: Record 1070;
        TempPaymentServiceSetup: Record 1060 temporary;
        MSPayPalStandardTemplate: Record 1071;
        O365SalesInvoicePayment: Codeunit 2105;
        TargetURL: Text;
    begin
        MSPayPalStandardAccount.HideAllDialogs();

        Account := LowerCase(Account);

        if NOT MSPayPalStandardAccount.FindFirst() then begin
            RegisterPayPalStandardTemplate(TempPaymentServiceSetup);
            GetTemplate(MSPayPalStandardTemplate);
            MSPayPalStandardTemplate.RefreshLogoIfNeeded();
            MSPayPalStandardAccount.TransferFields(MSPayPalStandardTemplate, false);
            MSPayPalStandardAccount.Insert(true);
        END;

        TargetURL := GetTargetURL();
        if StrPos(Account, SandboxPrefixTok) = 1 THEN
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
        CompanyInformation: Record 79;
    begin
        IF CompanyInformation.GET() THEN
            EXIT(CompanyInformation."Country/Region Code");
        EXIT('');
    end;
}

