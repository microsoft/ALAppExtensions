#if not CLEAN20
codeunit 1080 "MS - Wallet Mgt."
{
    ObsoleteState = Pending;
    ObsoleteReason = 'MS Wallet have been deprecated';
    ObsoleteTag = '20.0';
    TableNo = "Payment Reporting Argument";

    trigger OnRun();
    var
        TestMode: Boolean;
    begin
        if not GenerateHyperlink(Rec, TestMode) then begin
            Session.LogMessage('00001YA', MSWalletPayLinkErrTelemetryTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            if not GuiAllowed() then
                Error(MSWalletRequestErr);
            if Confirm(MSWalletNoLinkQst) then
                exit;
            Error('');
        end;

        SetCaptionBasedOnLanguage(Rec, TestMode);
        Session.LogMessage('00001SV', MSWalletHyperlinkIncludedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
    end;

    var
        NotSupportedTypeErr: Label 'This function is not supported for the %1 table.', Comment = '%1 Caption of the table';
        MSWalletCaptionURLTxt: Label 'Pay this invoice now.';
        DemoLinkCaptionTxt: Label 'NOTE: This is a test invoice. Therefore, no actual money transfer will be made.', Comment = 'Will be shown next to Pay with Microsoft Pay Payments link';
        MSWalletNameTxt: Label 'Microsoft Pay Payments';
        MSWalletDescriptionTxt: Label 'Microsoft Pay Payments - Enables credit cards and PayPal payments';
        MSWalletBusinessSetupDescriptionTxt: Label 'Set up and enable the Microsoft Pay Payments service.';
        TermsOfServiceURLTxt: Label 'https://www.microsoft.com/en-us/microsoft-pay/merchant', Locked = true;
        TargetURLCannotBeChangedInDemoCompanyErr: Label 'You cannot change the target URL in the demonstration company.';
        MSWalletHomepageLinkTxt: Label 'https://www.microsoft.com/en-us/payments', Locked = true;
        MSWalletBusinessSetupKeywordsTxt: Label 'Finance,Microsoft Pay Payments,MS Pay,Payment';
        MSWalletPaymentMethodCodeTok: Label 'MSPAY', Locked = true;
        MSWalletPaymentMethodDescTok: Label 'Microsoft Pay Payments';
        CompleteWebhookTok: Label '%1?target=MSWallet&event=complete&company=%2', Locked = true;
        MSWalletRequestErr: Label 'An error occured while creating the Microsoft Pay Payments payment link.';
        MSWalletNoLinkQst: Label 'An error occured while creating the Microsoft Pay Payments payment link.\\Do you want to continue to create the document without the link?';
        MSWalletPayLinkErrTelemetryTxt: Label 'An error occured while creating the Microsoft Pay Payments payment link.', Locked = true;
        MSWalletPaymentRequestUrlTxt: Label 'walletpaymentrequesturl', Locked = true;
        PaymentRequestAzureKeyVaultErr: Label 'An error occured while getting the URL of the Microsoft Pay Payments payment request. Could not retreive azure key vault secrets.';
        MSWalletAADAppIDTxt: Label 'MSWalletAADAppID', Locked = true;
        MSWalletAADAppKeyTxt: Label 'MSWalletAADAppKey', Locked = true;
        MSWalletAADIdentityServiceTxt: Label 'MSWalletAADIdentityService', Locked = true;
        MSWalletTelemetryCategoryTok: Label 'AL MSPAY', Locked = true;
        MSWalletHyperlinkIncludedTxt: Label 'Microsoft Pay Payments hyperlink included on sales document.', Locked = true;
        MSWalletHyperlinkGeneratedTxt: Label 'Microsoft Pay Payments hyperlink generated for sales document.', Locked = true;
        ResetCachedPaymentRequestUrlTxt: Label 'Reset the cached Microsoft Pay Payments payment request URL.', Locked = true;
        CachedPaymentRequestUrlHasExpiredTxt: Label 'The cached Microsoft Pay Payments payment request URL has expired.', Locked = true;
        MSWalletPaymentRequestURLIsEmptyTxt: Label 'Microsoft Pay Payments payment request URL is empty.', Locked = true;
        MSWalletPaymentRequestURLIsInvalidTxt: Label 'Microsoft Pay Payments payment request URL is invalid.', Locked = true;
        CannotSetPaymentRequestURLTxt: Label 'Cannot set Microsoft Pay Payments payment request URL: %1', Locked = true;
        MSWalletDeprecationMsgTok: Label 'Effective the 8th of February 2020, changes in the Microsoft Pay service will affect the Microsoft Pay extension in Microsoft Dynamics 365 Business Central.', Comment = 'Microsoft Pay and Microsoft Dynamics 365 Business Central must not be tranlated';
        MSWalletDeprecationActionTok: Label 'See more info here';
        MSWalletDeprecationErr: Label 'Effective the 8th of February 2020, changes in the Microsoft Pay service will affect the Microsoft Pay extension in Microsoft Dynamics 365 Business Central. Due to the changes, after February 8th, the Pay now payment links that the Microsoft Pay extension generates for invoices in Business Central will not open Microsoft Pay', Comment = 'Microsoft Pay and Microsoft Dynamics 365 Business Central must not be tranlated';
        MSWalledDeprecationHelpTopicLinkTok: Label 'https://go.microsoft.com/fwlink/?linkid=2114066', Locked = true;

    local procedure GenerateHyperlink(var PaymentReportingArgument: Record "Payment Reporting Argument"; var TestMode: Boolean): Boolean;
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        MSWalletMerchantAccount: Record "MS - Wallet Merchant Account";
        MSWalletMerchantTemplate: Record "MS - Wallet Merchant Template";
        MSWalletWebhookManagement: Codeunit "MS - Wallet Webhook Management";
        DataTypeManagement: Codeunit "Data Type Management";
        DocumentRecordRef: RecordRef;
        TargetURL: Text;
    begin
        DataTypeManagement.GetRecordRef(PaymentReportingArgument."Document Record ID", DocumentRecordRef);

        CASE DocumentRecordRef.NUMBER() OF
            DATABASE::"Sales Invoice Header":
                BEGIN
                    if not GetTemplate(MSWalletMerchantTemplate) then
                        exit(false);
                    MSWalletMerchantTemplate.RefreshLogoIfNeeded();
                    MSWalletMerchantAccount.SETAUTOCALCFIELDS("Payment Request URL");
                    MSWalletMerchantAccount.GET(PaymentReportingArgument."Setup Record ID");
                    DocumentRecordRef.SETTABLE(SalesInvoiceHeader);
                    SalesInvoiceHeader.CALCFIELDS("Amount Including VAT");

                    TestMode := MSWalletMerchantAccount."Test Mode";

                    TargetURL := GetTargetURL(SalesInvoiceHeader);
                    if TargetURL = '' then begin
                        Session.LogMessage('00007ZZ', MSWalletPaymentRequestURLIsEmptyTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
                        exit(false);
                    end;

                    if not PaymentReportingArgument.TrySetTargetURL(TargetURL) then begin
                        Session.LogMessage('0000800', MSWalletPaymentRequestURLIsInvalidTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
                        Session.LogMessage('00008HH', StrSubstNo(CannotSetPaymentRequestURLTxt, TargetURL), Verbosity::Warning, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
                        exit(false);
                    end;

                    PaymentReportingArgument.Logo := MSWalletMerchantTemplate.Logo;
                    PaymentReportingArgument."Payment Service ID" := PaymentReportingArgument.GetMSWalletServiceID();
                    PaymentReportingArgument.MODIFY(TRUE);

                    IF SalesInvoiceHeader."No. Printed" = 1 then
                        Session.LogMessage('00001ZS', MSWalletHyperlinkGeneratedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);

                    MSWalletWebhookManagement.ShowWarningIfCannotMakePayment(MSWalletMerchantAccount);
                    exit(true);
                END;
            DATABASE::"Sales Header":
                BEGIN
                    if not GetTemplate(MSWalletMerchantTemplate) then
                        Error(PaymentRequestAzureKeyVaultErr);
                    MSWalletMerchantTemplate.RefreshLogoIfNeeded();

                    PaymentReportingArgument.SetTargetURL(MSWalletHomepageLinkTxt);
                    PaymentReportingArgument.Logo := MSWalletMerchantTemplate.Logo;
                    PaymentReportingArgument."Payment Service ID" := PaymentReportingArgument.GetMSWalletServiceID();
                    PaymentReportingArgument.MODIFY(TRUE);
                    exit(true);
                END;
            ELSE
                ERROR(STRSUBSTNO(NotSupportedTypeErr, DocumentRecordRef.CAPTION()));
        END;
    end;

    procedure ErrorOnNewUsage()
    begin
        error(MSWalletDeprecationErr);
    end;

    procedure GetDeprecationMessageNotification(): Text
    begin
#pragma warning disable AA0217
        exit(StrSubstNo('%1\\%2:\%3', MSWalletDeprecationMsgTok, MSWalletDeprecationActionTok, MSWalledDeprecationHelpTopicLinkTok));
#pragma warning restore
    end;

    local procedure GetDeprecationMessageError(): Text
    begin
#pragma warning disable AA0217        
        exit(StrSubstNo('%1\\%2:\%3', MSWalletDeprecationErr, MSWalletDeprecationActionTok, MSWalledDeprecationHelpTopicLinkTok));
#pragma warning restore
    end;

    procedure SendDeprecationNotification(ParentRecordId: RecordId);
    var
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        DeprecationNotification: Notification;
    begin
        DeprecationNotification.Id := GetDeprecationNotificationId();
        DeprecationNotification.Message := MSWalletDeprecationMsgTok;
        DeprecationNotification.Scope := NotificationScope::LocalScope;
        DeprecationNotification.AddAction(MSWalletDeprecationActionTok, Codeunit::"MS - Wallet Mgt.", 'ShowDeprecationHelpTopic');
        NotificationLifecycleMgt.SendNotification(DeprecationNotification, ParentRecordId);
    end;

    local procedure GetDeprecationNotificationId(): Guid;
    begin
        EXIT('a64e785d-7a46-479d-8b39-4d978e0cd8ea');
    end;

    procedure ShowDeprecationHelpTopic(DeprecationNotification: Notification)
    begin
        Hyperlink(MSWalledDeprecationHelpTopicLinkTok);
    end;

    local procedure SetCaptionBasedOnLanguage(var PaymentReportingArgument: Record "Payment Reporting Argument"; TestMode: Boolean);
    var
        Language: Record "Language";
        CurrentLanguage: Integer;
        MSWalletBaseCaptionURL: Text;
    begin
        CurrentLanguage := GLOBALLANGUAGE();
        IF Language.GET(PaymentReportingArgument."Language Code") THEN
            GLOBALLANGUAGE(Language."Windows Language ID");

        MSWalletBaseCaptionURL := MSWalletCaptionURLTxt;

        PaymentReportingArgument.VALIDATE("URL Caption", MSWalletBaseCaptionURL);

        IF TestMode THEN
#pragma warning disable AA0217        
            PaymentReportingArgument.VALIDATE("URL Caption", STRSUBSTNO('%1 (%2)', MSWalletBaseCaptionURL, DemoLinkCaptionTxt));
#pragma warning restore
        PaymentReportingArgument.MODIFY(TRUE);

        IF GLOBALLANGUAGE() <> CurrentLanguage THEN
            GLOBALLANGUAGE(CurrentLanguage);
    end;

    procedure GetTemplate(var TempMSWalletMerchantTemplate: Record "MS - Wallet Merchant Template" temporary): Boolean;
    begin
        exit(GetTemplateExtended(TempMSWalletMerchantTemplate, false));
    end;

    local procedure GetTemplateExtended(var TempMSWalletMerchantTemplate: Record "MS - Wallet Merchant Template" temporary; ResetCachedPaymentRequestUrl: Boolean): Boolean;
    var
        MSWalletMerchantTemplate: Record "MS - Wallet Merchant Template";
        RenewCachedPaymentRequestUrl: Boolean;
    begin
        MSWalletMerchantTemplate.LockTable();
        IF MSWalletMerchantTemplate.GET() THEN BEGIN
            if ResetCachedPaymentRequestUrl then begin
                RenewCachedPaymentRequestUrl := true;
                Session.LogMessage('00007KE', ResetCachedPaymentRequestUrlTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            end;
            if MSWalletMerchantTemplate."Payment Request URL Modified" < CurrentDateTime() - ServiceUrlValidityTime() then begin
                RenewCachedPaymentRequestUrl := true;
                Session.LogMessage('00007KF', CachedPaymentRequestUrlHasExpiredTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            end;
            if RenewCachedPaymentRequestUrl then
                if not SetTemplatePaymentRequestFromAzureKeyVault(MSWalletMerchantTemplate) then
                    exit(false);

            MSWalletMerchantTemplate.CALCFIELDS(Logo, "Payment Request URL");
            TempMSWalletMerchantTemplate.TRANSFERFIELDS(MSWalletMerchantTemplate, TRUE);
            EXIT(true);
        END;

        TempMSWalletMerchantTemplate.INIT();
        TempMSWalletMerchantTemplate.INSERT();
        exit(TemplateAssignDefaultValues(TempMSWalletMerchantTemplate));
    end;

    procedure TemplateAssignDefaultValues(var MSWalletMerchantTemplate: Record "MS - Wallet Merchant Template"): Boolean;
    begin
        MSWalletMerchantTemplate.VALIDATE(Name, MSWalletNameTxt);
        MSWalletMerchantTemplate.VALIDATE(Description, MSWalletDescriptionTxt);
        MSWalletMerchantTemplate.VALIDATE("Terms of Service", TermsOfServiceURLTxt);
        MSWalletMerchantTemplate.MODIFY(TRUE);
        if not SetTemplatePaymentRequestFromAzureKeyVault(MSWalletMerchantTemplate) then
            exit(false);
        MSWalletMerchantTemplate.UpdateLogo();
        exit(true);
    end;

    procedure GetWalletPaymentMethod(var PaymentMethod: Record "Payment Method");
    begin
        RegisterWalletPaymentMethod(PaymentMethod);
    end;

    local procedure RegisterWalletPaymentMethod(var PaymentMethod: Record "Payment Method");
    begin
        IF PaymentMethod.GET(MSWalletPaymentMethodCodeTok) THEN
            EXIT;
        PaymentMethod.INIT();
        PaymentMethod.Code := MSWalletPaymentMethodCodeTok;
        PaymentMethod.Description := MSWalletPaymentMethodDescTok;
        PaymentMethod."Bal. Account Type" := PaymentMethod."Bal. Account Type"::"G/L Account";
        PaymentMethod."Use for Invoicing" := TRUE;
        IF PaymentMethod.INSERT() THEN;
    end;


    [EventSubscriber(ObjectType::Page, Page::"Select Payment Service", 'OnAfterValidateEvent', 'Available', true, true)]
    local procedure ShowDeprecationNotificationOnPage(var Rec: Record "Payment Service Setup")
    begin
        if Rec."Management Codeunit ID" = Codeunit::"MS - Wallet Mgt." then
            SendDeprecationNotification(Rec.RecordId());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Role Center Notification Mgt.", 'OnBeforeShowNotifications', '', true, true)]
    local procedure OnBeforeShowRoleCenterNotifications()
    var
        MSWalletMerchantAccount: Record "MS - Wallet Merchant Account";
    begin
        if not MSWalletMerchantAccount.ReadPermission() then
            exit;

        MSWalletMerchantAccount.SetRange(Enabled, true);
        if not MSWalletMerchantAccount.FindFirst() then
            exit;

        SendDeprecationNotification(MSWalletMerchantAccount.RecordId());
    end;

    [EventSubscriber(ObjectType::Table, Database::"MS - Wallet Merchant Account", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertMSWalletAccount(var Rec: Record "MS - Wallet Merchant Account"; RunTrigger: Boolean);
    var
        PaymentMethod: Record "Payment Method";
    begin
        if Rec.IsTemporary() then
            exit;

        RegisterWalletPaymentMethod(PaymentMethod);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Service Setup", 'OnRegisterPaymentServices', '', false, false)]
    local procedure RegisterMSWalletAccounts(var PaymentServiceSetup: Record 1060);
    var
        MSWalletMerchantAccount: Record "MS - Wallet Merchant Account";
    begin
        if not PaymentServiceSetup.WritePermission() then
            exit;

        IF NOT MSWalletMerchantAccount.FINDSET() THEN
            EXIT;

        REPEAT
            CLEAR(PaymentServiceSetup);
            PaymentServiceSetup.TRANSFERFIELDS(MSWalletMerchantAccount, FALSE);
            if PaymentServiceSetup."Always Include on Documents" then
                SendDeprecationNotification(PaymentServiceSetup.RecordId());

            PaymentServiceSetup."Always Include on Documents" := false;
            PaymentServiceSetup."Setup Record ID" := MSWalletMerchantAccount.RECORDID();
            PaymentServiceSetup.AssignPrimaryKey(PaymentServiceSetup);
            PaymentServiceSetup."Management Codeunit ID" := CODEUNIT::"MS - Wallet Mgt.";
            if PaymentServiceSetup.INSERT(TRUE) then;
        UNTIL MSWalletMerchantAccount.NEXT() = 0;
    end;

    procedure RegisterMSWalletTemplate(var PaymentServiceSetup: Record 1060);
    var
        TempMSWalletMerchantTemplate: Record "MS - Wallet Merchant Template" temporary;
        DummyMSWalletMerchantTemplate: Record "MS - Wallet Merchant Template";
    begin
        if not DummyMSWalletMerchantTemplate.WritePermission() then
            exit;

        if not PaymentServiceSetup.WritePermission() then
            exit;

        CLEAR(PaymentServiceSetup);
        if not GetTemplate(TempMSWalletMerchantTemplate) then
            exit;

        PaymentServiceSetup.Name := TempMSWalletMerchantTemplate.Name;
        PaymentServiceSetup.Description := TempMSWalletMerchantTemplate.Description;
        PaymentServiceSetup."Setup Record ID" := TempMSWalletMerchantTemplate.RECORDID();
        PaymentServiceSetup."Management Codeunit ID" := CODEUNIT::"MS - Wallet Mgt.";
        PaymentServiceSetup.AssignPrimaryKey(PaymentServiceSetup);
        if PaymentServiceSetup.INSERT(TRUE) then;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Service Setup", 'OnRegisterPaymentServiceProviders', '', false, false)]
    local procedure RegisterMSWalletTemplateOnRegisterPaymentServiceProviders(var PaymentServiceSetup: Record 1060);
    begin
        RegisterMSWalletTemplate(PaymentServiceSetup);
    end;

    procedure NewPaymentAccount(var MSWalletMerchantAccount: Record "MS - Wallet Merchant Account"): Boolean;
    var
        MSWalletMerchantTemplate: Record "MS - Wallet Merchant Template";
    begin
        if not GetTemplate(MSWalletMerchantTemplate) then
            exit(false);

        MSWalletMerchantAccount.TRANSFERFIELDS(MSWalletMerchantTemplate, FALSE);
        MSWalletMerchantAccount.INSERT(TRUE);
        exit(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Service Setup", 'OnCreatePaymentService', '', false, false)]
    local procedure NewPaymentAccountOnCreatePaymentService(var PaymentServiceSetup: Record 1060);
    var
        MSWalletMerchantAccount: Record "MS - Wallet Merchant Account";
    begin
        if not MSWalletMerchantAccount.WritePermission() then
            exit;

        IF PaymentServiceSetup."Management Codeunit ID" <> CODEUNIT::"MS - Wallet Mgt." THEN
            EXIT;

        if not NewPaymentAccount(MSWalletMerchantAccount) then
            Error(PaymentRequestAzureKeyVaultErr);

        COMMIT();
        PAGE.RUNMODAL(PAGE::"MS - Wallet Merchant Setup", MSWalletMerchantAccount);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', false, false)]
    local procedure RegisterServiceConnection(var ServiceConnection: Record 1400);
    var
        MSWalletMerchantAccount: Record "MS - Wallet Merchant Account";
        RecRef: RecordRef;
        PaymentRequestURL: Text;
    begin
        if not MSWalletMerchantAccount.WritePermission() then
            exit;

        if not ServiceConnection.WritePermission() then
            exit;

        IF NOT MSWalletMerchantAccount.FINDSET() THEN
            if not NewPaymentAccount(MSWalletMerchantAccount) then
                exit;

        REPEAT
            RecRef.GETTABLE(MSWalletMerchantAccount);

            IF MSWalletMerchantAccount.Enabled THEN
                ServiceConnection.Status := ServiceConnection.Status::Enabled
            ELSE
                ServiceConnection.Status := ServiceConnection.Status::Disabled;

            PaymentRequestURL := MSWalletMerchantAccount.GetPaymentRequestURL();
            ServiceConnection.InsertServiceConnection(
              ServiceConnection, RecRef.RECORDID(), MSWalletMerchantAccount.Description,
              COPYSTR(PaymentRequestURL, 1, MAXSTRLEN(ServiceConnection."Host Name")), PAGE::"MS - Wallet Merchant Setup");
        UNTIL MSWalletMerchantAccount.NEXT() = 0
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterManualSetup', '', false, false)]
    local procedure RegisterBusinessSetup(sender: Codeunit "Guided Experience");
    var
        MSWalletMerchantAccount: Record "MS - Wallet Merchant Account";
    begin
        if not MSWalletMerchantAccount.WritePermission() then
            exit;

        IF NOT MSWalletMerchantAccount.FINDFIRST() THEN
            if not NewPaymentAccount(MSWalletMerchantAccount) then
                exit;

        Sender.InsertManualSetup(
          MSWalletNameTxt, MSWalletNameTxt, MSWalletBusinessSetupDescriptionTxt, 0, ObjectType::Page,
          Page::"MS - Wallet Merchant Setup", "Manual Setup Category"::Service, MSWalletBusinessSetupKeywordsTxt);
    end;

    procedure ValidateChangePaymentRequestURL();
    var
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        IF CompanyInformationMgt.IsDemoCompany() AND EnvironmentInformation.IsSaaS() THEN
            ERROR(TargetURLCannotBeChangedInDemoCompanyErr);
    end;

    local procedure SetTemplatePaymentRequestFromAzureKeyVault(var MSWalletMerchantTemplate: Record "MS - Wallet Merchant Template"): Boolean;
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        PaymentRequestUrl: Text;
    begin
        IF AzureKeyVault.GetAzureKeyVaultSecret(MSWalletPaymentRequestUrlTxt, PaymentRequestUrl) THEN
            if PaymentRequestUrl <> '' then begin
                MSWalletMerchantTemplate.SetPaymentRequestURL(PaymentRequestUrl);
                exit(true);
            end;

        Session.LogMessage('00001YB', PaymentRequestAzureKeyVaultErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
        exit(false);
    end;

    procedure GetTargetURL(var SalesInvoiceHeader: Record "Sales Invoice Header"): Text;
    var
        MSWalletPayment: Record "MS - Wallet Payment";
    begin
        if MSWalletPayment.Get(SalesInvoiceHeader."No.") then
            exit(MSWalletPayment.GetPaymentURL())
        else
            Error(GetDeprecationMessageError());
    end;

    [Scope('OnPrem')]
    procedure GetAADAuthHeader(PaymentRequesBaseURL: Text): Text;
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        AADAppID: Text;
        AADAppKey: Text;
        AADIdentityService: Text;
        AcquiredAuthToken: Text;
    begin
        IF NOT AzureKeyVault.GetAzureKeyVaultSecret(MSWalletAADAppIDTxt, AADAppID) THEN
            ERROR(PaymentRequestAzureKeyVaultErr);
        IF NOT AzureKeyVault.GetAzureKeyVaultSecret(MSWalletAADAppKeyTxt, AADAppKey) THEN
            ERROR(PaymentRequestAzureKeyVaultErr);
        IF NOT AzureKeyVault.GetAzureKeyVaultSecret(MSWalletAADIdentityServiceTxt, AADIdentityService) THEN
            ERROR(PaymentRequestAzureKeyVaultErr);

        AcquiredAuthToken := AcquireApplicationToken(AADAppID, AADAppKey, AADIdentityService, PaymentRequesBaseURL);
#pragma warning disable AA0217
        EXIT(STRSUBSTNO('Bearer %1', AcquiredAuthToken));
#pragma warning restore
    end;

    local procedure GetNotifyURL(): Text;
    var
        WebhookManagement: Codeunit "Webhook Management";
    begin
        EXIT(WebhookManagement.GetNotificationUrl());
    end;

    procedure GetWebhookCompleteURL(): Text;
    begin
        exit(STRSUBSTNO(CompleteWebhookTok, GetNotifyURL(), LOWERCASE(CompanyProperty.UrlName())));
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

    procedure GetBaseURL(URL: Text): Text;
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        EXIT(TypeHelper.UriGetAuthority(URL));
    end;

    procedure GetPropertyValueFromJObject(JObject: JsonObject; PropertyKey: Text; var PropertyValue: Text);
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        PropertyValue := '';
        if not JObject.Get(PropertyKey, JToken) then
            exit;
        if not JToken.IsValue() then
            exit;
        JValue := JToken.AsValue();
        if JValue.IsNull() then
            exit;
        PropertyValue := JValue.AsText();
    end;

    local procedure ServiceUrlValidityTime(): Integer;
    begin
        exit(3600000); // 1 hour
    end;

    local procedure AcquireApplicationToken(ClientID: Text; ClientSecret: Text; Authority: Text; ResourceUri: Text) AccessToken: text;
    Var
        AuthFlow: DotNet ALAzureAdCodeGrantFlow;
        Uri: DotNet Uri;
    begin
        AuthFlow := AuthFlow.ALAzureAdCodeGrantFlow(Uri.Uri(ResourceUri));
        AccessToken := AuthFlow.ALAcquireApplicationToken(ClientID, ClientSecret, Authority, ResourceUri);
    end;
}
#endif