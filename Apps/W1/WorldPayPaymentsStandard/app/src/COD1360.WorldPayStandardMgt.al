codeunit 1360 "MS - WorldPay Standard Mgt."
{
    TableNo = 1062;

    trigger OnRun()
    begin
        if not GenerateHyperlink(Rec) then begin
            Session.LogMessage('0000802', WorldPayNoLinkTelemetryTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WorldPayTelemetryCategoryTok);
            if not GuiAllowed() then
                Error(WorldPayNoLinkErr);
            if Confirm(WorldPayNoLinkQst) then
                exit;
            Error('');
        end;
        SetCaptionBasedOnLanguage(Rec);
        Session.LogMessage('00001TJ', WorldPayHyperlinkIncludedTxt, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', WorldPayTelemetryCategoryTok);
    end;

    var
        InvoiceTxt: Label 'Invoice %1', Comment = '%1 Invoice No.';
        NotSupportedTypeErr: Label 'This function is not supported for the %1 table.', Comment = '%1 Caption of the table';
        WorldPayCaptionURLTxt: Label 'Pay with WorldPay';
        DemoLinkCaptionTxt: Label 'Note: You''re in an evaluation company, and this isn''t a real invoice. You can''t actually pay it.', Comment = 'Will be shown next to the Pay with WorldPay link.';
        WorldPayStandardNameTxt: Label 'WorldPay Payments Standard';
        WorldPayStandardDescriptionTxt: Label 'Use the WorldPay Payments Standard service';
        WorldPayStandardBusinessSetupDescriptionTxt: Label 'Set up and enable the WorldPay Payments Standard service.';
        YourReferenceTxt: Label 'Your Ref.', Comment = 'Ref. is short for reference from Your Reference field. After Ref there will be a number';
        TermsOfServiceURLTxt: Label 'https://go.microsoft.com/fwlink/?linkid=844662', Locked = true;
        LogoURLTxt: Label 'https://cdn-bc.dynamics.com/common/images/extensionslogos/worldpay_colour_v1.png', Locked = true;
        WorldPayBaseURLTok: Label 'https://secure-test.worldpay.com/wcc/purchase?testMode=100', Locked = true;
        WorldPayMandatoryParametersTok: Label 'instId=%1&cartId=%2&amount=%3&currency=%4&desc=%5', Locked = true;
        TargetURLCannotBeChangedInDemoCompanyErr: Label 'You cannot change the target URL in the demonstration company.';
        SandboxWorldPayBaseURLTok: Label 'https://secure-test.worldpay.com/wcc/purchase?testMode=100', Locked = true;
        WorldPayMenuDescriptionTxt: Label 'Add WorldPay link to your invoices.';
        WorldPayHomepageLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=844661', Locked = true;
        WorldPayBusinessSetupKeywordsTxt: Label 'Finance,WorldPay,Payment';
        WorldPayPaymentMethodCodeTok: Label 'WorldPay', Locked = true;
        WorldPayPaymentMethodDescTok: Label 'WorldPay payment';
        WorldPayTelemetryCategoryTok: Label 'AL WorldPay', Locked = true;
        WorldPayHyperlinkIncludedTxt: Label 'WorldPay hyperlink included on sales document.', Locked = true;
        WorldPayHyperlinkGeneratedTxt: Label 'WorldPay hyperlink generated for sales document.', Locked = true;
        WorldPayNoLinkTelemetryTxt: Label 'An error occured while creating the WorldPay payment link.', Locked = true;
        WorldPayNoLinkErr: Label 'An error occured while creating the WorldPay payment link.';
        WorldPayNoLinkQst: Label 'An error occured while creating the WorldPay payment link.\\Do you want to continue to create the document without the link?';
        WorldPayTargetURLIsEmptyTxt: Label 'WorldPay target URL is empty.', Locked = true;
        WorldPayTargetURLIsInvalidTxt: Label 'WorldPay target URL is invalid.', Locked = true;

    local procedure GenerateHyperlink(var PaymentReportingArgument: Record 1062): Boolean;
    var
        SalesInvoiceHeader: Record 112;
        MsWorldPayStandardAccount: Record 1360;
        MSWorldPayStdTemplate: Record 1361;
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
                    GetTemplate(MSWorldPayStdTemplate);
                    MSWorldPayStdTemplate.RefreshLogoIfNeeded();
                    MsWorldPayStandardAccount.SETAUTOCALCFIELDS("Target URL");
                    MsWorldPayStandardAccount.GET(PaymentReportingArgument."Setup Record ID");
                    DocumentRecordRef.SETTABLE(SalesInvoiceHeader);
                    SalesInvoiceHeader.CALCFIELDS("Amount Including VAT");

                    InvoiceNo := SalesInvoiceHeader."No.";
                    IF SalesInvoiceHeader."Your Reference" <> '' THEN
                        InvoiceNo := STRSUBSTNO('%1 (%2 %3)', InvoiceNo, YourReferenceTxt, SalesInvoiceHeader."Your Reference");

                    QueryString := STRSUBSTNO(WorldPayMandatoryParametersTok,
                        UriEscapeDataString(MsWorldPayStandardAccount."Account ID"),
                        UriEscapeDataString(SalesInvoiceHeader."No."),
                        UriEscapeDataString(FORMAT(SalesInvoiceHeader."Amount Including VAT", 0, 9)),
                        UriEscapeDataString(PaymentReportingArgument.GetCurrencyCode(SalesInvoiceHeader."Currency Code")),
                        UriEscapeDataString(STRSUBSTNO(InvoiceTxt, InvoiceNo)));
                    BaseURL := MsWorldPayStandardAccount.GetTargetURL();
                    if BaseURL = '' then begin
                        Session.LogMessage('0000803', WorldPayTargetURLIsEmptyTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WorldPayTelemetryCategoryTok);
                        exit(false);
                    end;

                    TargetURL := STRSUBSTNO('%1&%2', BaseURL, QueryString);
                    if not PaymentReportingArgument.TrySetTargetURL(TargetURL) then begin
                        Session.LogMessage('0000804', WorldPayTargetURLIsInvalidTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WorldPayTelemetryCategoryTok);
                        exit(false);
                    end;

                    PaymentReportingArgument.Logo := MSWorldPayStdTemplate.Logo;
                    PaymentReportingArgument."Payment Service ID" := PaymentReportingArgument.GetWorldPayServiceID();
                    PaymentReportingArgument.MODIFY(TRUE);

                    IF SalesInvoiceHeader."No. Printed" = 1 then
                        Session.LogMessage('00001ZT', WorldPayHyperlinkGeneratedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', WorldPayTelemetryCategoryTok);

                    exit(true);
                END;
            DATABASE::"Sales Header":
                BEGIN
                    GetTemplate(MSWorldPayStdTemplate);
                    MSWorldPayStdTemplate.RefreshLogoIfNeeded();

                    PaymentReportingArgument.SetTargetURL(WorldPayHomepageLinkTxt);
                    PaymentReportingArgument.Logo := MSWorldPayStdTemplate.Logo;
                    PaymentReportingArgument."Payment Service ID" := PaymentReportingArgument.GetWorldPayServiceID();
                    PaymentReportingArgument.MODIFY(TRUE);
                    exit(true);
                END;
            ELSE
                ERROR(STRSUBSTNO(NotSupportedTypeErr, DocumentRecordRef.CAPTION()));
        END;
    end;

    local procedure UriEscapeDataString(Uri: Text): Text;
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.UriEscapeDataString(Uri));
    end;

    local procedure SetCaptionBasedOnLanguage(var PaymentReportingArgument: Record 1062)
    var
        Language: Record 8;
        CurrentLanguage: Integer;
    begin
        CurrentLanguage := GLOBALLANGUAGE();
        IF Language.GET(PaymentReportingArgument."Language Code") THEN
            GLOBALLANGUAGE(Language."Windows Language ID");

        PaymentReportingArgument.VALIDATE("URL Caption", WorldPayCaptionURLTxt);
        IF STRPOS(PaymentReportingArgument.GetTargetURL(), GetSandboxURL()) > 0 THEN
            PaymentReportingArgument.VALIDATE("URL Caption", STRSUBSTNO('%1 (%2)', WorldPayCaptionURLTxt, DemoLinkCaptionTxt));
        PaymentReportingArgument.MODIFY(TRUE);

        IF GLOBALLANGUAGE() <> CurrentLanguage THEN
            GLOBALLANGUAGE(CurrentLanguage);
    end;

    procedure GetTemplate(var TempMSWorldPayStdTemplate: Record 1361 temporary)
    var
        MSWorldPayStdTemplate: Record 1361;
    begin
        IF MSWorldPayStdTemplate.GET() THEN BEGIN
            MSWorldPayStdTemplate.CALCFIELDS(Logo, "Target URL");
            TempMSWorldPayStdTemplate.TRANSFERFIELDS(MSWorldPayStdTemplate, TRUE);
            EXIT;
        END;

        TempMSWorldPayStdTemplate.INIT();
        TempMSWorldPayStdTemplate.INSERT();
        TemplateAssignDefaultValues(TempMSWorldPayStdTemplate);
    end;

    procedure TemplateAssignDefaultValues(var MSWorldPayStdTemplate: Record 1361)
    begin
        MSWorldPayStdTemplate.VALIDATE(Name, WorldPayStandardNameTxt);
        MSWorldPayStdTemplate.VALIDATE(Description, WorldPayStandardDescriptionTxt);
        MSWorldPayStdTemplate.VALIDATE("Terms of Service", TermsOfServiceURLTxt);
        MSWorldPayStdTemplate.VALIDATE("Logo Update Frequency", 7 * 24 * 3600 * 1000);
        MSWorldPayStdTemplate.MODIFY(TRUE);
        MSWorldPayStdTemplate.SetTargetURL(GetTargetURL());
        MSWorldPayStdTemplate.SetLogoURL(LogoURLTxt);
    end;

    procedure GetWorldPayPaymentMethod(var PaymentMethod: Record 289)
    begin
        RegisterWorldPayPaymentMethod(PaymentMethod);
    end;

    local procedure RegisterWorldPayPaymentMethod(var PaymentMethod: Record 289)
    begin
        IF PaymentMethod.GET(WorldPayPaymentMethodCodeTok) THEN
            EXIT;
        PaymentMethod.INIT();
        PaymentMethod.Code := WorldPayPaymentMethodCodeTok;
        PaymentMethod.Description := WorldPayPaymentMethodDescTok;
        PaymentMethod."Bal. Account Type" := PaymentMethod."Bal. Account Type"::"G/L Account";
        PaymentMethod."Use for Invoicing" := TRUE;
        IF PaymentMethod.INSERT() THEN;
    end;

    [EventSubscriber(ObjectType::Table, 1360, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertWorldPayStandardAccount(var Rec: Record 1360; RunTrigger: Boolean)
    var
        PaymentMethod: Record 289;
    begin
        RegisterWorldPayPaymentMethod(PaymentMethod);
    end;

    [EventSubscriber(ObjectType::Table, 1060, 'OnRegisterPaymentServices', '', false, false)]
    local procedure RegisterWorldPayStandardAccounts(var PaymentServiceSetup: Record 1060)
    var
        MSWorldPayStandardAccount: Record 1360;
    begin
        IF NOT MSWorldPayStandardAccount.FINDSET() THEN
            EXIT;

        REPEAT
            CLEAR(PaymentServiceSetup);
            PaymentServiceSetup.TRANSFERFIELDS(MSWorldPayStandardAccount, FALSE);
            PaymentServiceSetup."Setup Record ID" := MSWorldPayStandardAccount.RECORDID();
            PaymentServiceSetup.AssignPrimaryKey(PaymentServiceSetup);
            PaymentServiceSetup."Management Codeunit ID" := CODEUNIT::"MS - WorldPay Standard Mgt.";
            PaymentServiceSetup.INSERT(TRUE);
        UNTIL MSWorldPayStandardAccount.NEXT() = 0;
    end;

    [EventSubscriber(ObjectType::Table, 1060, 'OnRegisterPaymentServiceProviders', '', false, false)]
    procedure RegisterWorldPayStandardTemplate(var PaymentServiceSetup: Record 1060)
    var
        TempMSWorldPayStdTemplate: Record 1361 temporary;
    begin
        GetTemplate(TempMSWorldPayStdTemplate);

        CLEAR(PaymentServiceSetup);

        PaymentServiceSetup.Name := TempMSWorldPayStdTemplate.Name;
        PaymentServiceSetup.Description := TempMSWorldPayStdTemplate.Description;
        PaymentServiceSetup."Setup Record ID" := TempMSWorldPayStdTemplate.RECORDID();
        PaymentServiceSetup."Management Codeunit ID" := CODEUNIT::"MS - WorldPay Standard Mgt.";
        PaymentServiceSetup.AssignPrimaryKey(PaymentServiceSetup);
        PaymentServiceSetup.INSERT(TRUE);
    end;

    [EventSubscriber(ObjectType::Table, 1060, 'OnCreatePaymentService', '', false, false)]
    local procedure NewPaymentAccount(var PaymentServiceSetup: Record 1060)
    var
        MSWorldPayStdTemplate: Record 1361;
        MSWorldPayStandardAccount: Record 1360;
    begin
        IF PaymentServiceSetup."Management Codeunit ID" <> CODEUNIT::"MS - WorldPay Standard Mgt." THEN
            EXIT;

        GetTemplate(MSWorldPayStdTemplate);
        MSWorldPayStandardAccount.TRANSFERFIELDS(MSWorldPayStdTemplate, FALSE);
        MSWorldPayStandardAccount.INSERT(TRUE);
        COMMIT();
        PAGE.RUNMODAL(PAGE::"MS - WorldPay Standard Setup", MSWorldPayStandardAccount);
    end;

    [EventSubscriber(ObjectType::Table, 1400, 'OnRegisterServiceConnection', '', false, false)]
    local procedure RegisterServiceConnection(var ServiceConnection: Record 1400)
    var
        MSWorldPayStandardAccount: Record 1360;
        MSWorldPayStdTemplate: Record 1361;
        RecRef: RecordRef;
        TargetURL: Text;
    begin
        IF NOT MSWorldPayStandardAccount.FINDSET() THEN BEGIN
            GetTemplate(MSWorldPayStdTemplate);
            MSWorldPayStandardAccount.TRANSFERFIELDS(MSWorldPayStdTemplate, FALSE);
            MSWorldPayStandardAccount.INSERT(TRUE);
        END;

        REPEAT
            RecRef.GETTABLE(MSWorldPayStandardAccount);

            IF MSWorldPayStandardAccount.Enabled THEN
                ServiceConnection.Status := ServiceConnection.Status::Enabled
            ELSE
                ServiceConnection.Status := ServiceConnection.Status::Disabled;

            TargetURL := MSWorldPayStandardAccount.GetTargetURL();
            ServiceConnection.InsertServiceConnection(
              ServiceConnection, RecRef.RECORDID(), MSWorldPayStandardAccount.Description,
              COPYSTR(TargetURL, 1, MAXSTRLEN(ServiceConnection."Host Name")), PAGE::"MS - WorldPay Standard Setup");
        UNTIL MSWorldPayStandardAccount.NEXT() = 0
    end;

    [EventSubscriber(ObjectType::Codeunit, 1875, 'OnRegisterManualSetup', '', false, false)]
    local procedure RegisterBusinessSetup(var Sender: Codeunit 1875)
    var
        MSWorldPayStandardAccount: Record 1360;
        MSWorldPayStdTemplate: Record 1361;
        ManualSetupCategory: Enum "Manual Setup Category";
    begin
        IF NOT MSWorldPayStandardAccount.FINDFIRST() THEN BEGIN
            GetTemplate(MSWorldPayStdTemplate);
            MSWorldPayStandardAccount.TRANSFERFIELDS(MSWorldPayStdTemplate, FALSE);
            MSWorldPayStandardAccount.INSERT(TRUE);
        END;

        Sender.Insert(
          WorldPayStandardNameTxt, WorldPayStandardBusinessSetupDescriptionTxt, WorldPayBusinessSetupKeywordsTxt,
          PAGE::"MS - WorldPay Standard Setup", 'bae453ed-0fd8-4416-afdc-4b09db6c12c3', ManualSetupCategory::Service);
    end;

    procedure ValidateChangeTargetURL()
    var
        CompanyInformationMgt: Codeunit 1306;
        EnvironmentInfo: Codeunit 457;
    begin
        IF CompanyInformationMgt.IsDemoCompany() AND EnvironmentInfo.IsSaaS() THEN
            ERROR(TargetURLCannotBeChangedInDemoCompanyErr);
    end;

    [EventSubscriber(ObjectType::Page, 2133, 'OnOpenPageEvent', '', false, false)]
    local procedure AddWorldPayMenuItemOnOpenTaxPaymentsSettingsPageEvent(var Rec: Record 2132)
    var
        MSWorldPayStdSettings: Page 1364;
    begin
        Rec.InsertPageMenuItem(PAGE::"MS - WorldPay Std. Settings", CopyStr(MSWorldPayStdSettings.CAPTION(), 1, 30), WorldPayMenuDescriptionTxt);
    end;

    procedure GetTargetURL(): Text
    var
        CompanyInformationMgt: Codeunit 1306;
    begin
        IF CompanyInformationMgt.IsDemoCompany() THEN
            EXIT(GetSandboxURL());

        EXIT(WorldPayBaseURLTok);
    end;

    procedure GetSandboxURL(): Text
    begin
        EXIT(SandboxWorldPayBaseURLTok);
    end;

}

