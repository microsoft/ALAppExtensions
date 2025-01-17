namespace Microsoft.EServices;

using Microsoft.Foundation.Company;
using Microsoft.Utilities;
using System.Environment.Configuration;
using System.Privacy;
using System.Environment;
using System.DataAdministration;
using System.Telemetry;
using System.Utilities;

codeunit 13628 "Nemhandel Status Mgt."
{
    Access = Public;

    var
        HttpClientGlobal: Interface "Http Client Nemhandel Status";
        HttpClientDefined: Boolean;
        NotificationMsg: Label 'Your accounting software is not registered in Nemhandelsregisteret.';
        RegisterInNemhandelTxt: Label 'Register in Nemhandelsregisteret', Comment = 'Nemhandelsregisteret word is already in Danish, no need to translate.';
        OpenRegistrationGuideTxt: Label 'Open registration guide';
        EnableNemhandelNotRegisteredNotificationTxt: Label 'Enable Nemhandel Not Registered Notification';
        EnableNemhandelNotRegisteredNotificationDescrTxt: Label 'Notify me that the company with the given CVR number is not registered in Nemhandelsregisteret. The message is shown on the Company Information page.';
        IncorrectCVRNumberFormatErr: Label 'The CVR number must be 8 digits or "A/S" followed by 3-6 digits.';
        NemhandelsregisteretCategoryTxt: Label 'Nemhandelsregisteret', Locked = true;
        CVRNumberChangedTxt: Label 'CVR number was changed from %1 to %2. Modify trigger: %3.', Locked = true;
        RegisteredStatusChangedTxt: Label 'Registered with Nemhandel was changed from %1 to %2. Modify trigger: %3.', Locked = true;
        NemhandelsregisteretUrlLbl: Label 'https://registration.nemhandel.dk/NemHandelRegisterWeb', Locked = true;
        NemhandelsregisteretGuidanceUrlLbl: Label 'https://nemhandel.dk/vejledning-nemhandelsregisteret-nhr', Locked = true;

    procedure GetHttpClient(): Interface "Http Client Nemhandel Status"
    var
        DefaultHttpClient: Codeunit "Http Client Nemhandel Status";
    begin
        if not HttpClientDefined then
            SetHttpClient(DefaultHttpClient);

        exit(HttpClientGlobal);
    end;

    procedure SetHttpClient(HttpClientNemhandel: Interface "Http Client Nemhandel Status")
    begin
        HttpClientGlobal := HttpClientNemhandel;
        HttpClientDefined := true;
    end;

    internal procedure IsNemhandelStatusCheckRequired(var CompanyInformation: Record "Company Information"): Boolean
    begin
        if CompanyInformation."Registered with Nemhandel" = Enum::"Nemhandel Company Status"::Registered then
            exit(false);

        if CompanyInformation."Last Nemhandel Status Check DT" <> 0DT then begin
            if CompanyInformation."Last Nemhandel Status Check DT" > CurrentDateTime() then
                exit(false);
            if CurrentDateTime() - CompanyInformation."Last Nemhandel Status Check DT" < GetNemhandelStatusCheckIntervalMs() then
                exit(false);
        end;

        exit(true);
    end;

    local procedure GetNemhandelStatusCheckIntervalMs(): Integer
    begin
        exit(60 * 60 * 1000); // 1 hour in milliseconds
    end;

    internal procedure IsSaaSProductionCompany(): Boolean
    var
        Company: Record Company;
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if not EnvironmentInformation.IsProduction() then
            exit(false);

        if not EnvironmentInformation.IsSaaSInfrastructure() then
            exit(false);

        if EnvironmentInformation.IsSandbox() then
            exit(false);

        if Company.Get(CompanyName()) then
            if Company."Evaluation Company" then
                exit(false);

        exit(true);
    end;

    internal procedure UpdateRegisteredWithNemhandel(NemhandelCompanyStatus: Enum "Nemhandel Company Status")
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."Registered with Nemhandel" := NemhandelCompanyStatus;
        CompanyInformation."Last Nemhandel Status Check DT" := CurrentDateTime();
        CompanyInformation.Modify();
    end;

    local procedure ResetRegisteredWithNemhandel(CompanyName: Text)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.ChangeCompany(CompanyName);
        if not CompanyInformation.Get() then
            exit;

        CompanyInformation."Registration No." := '';
        CompanyInformation."Registered with Nemhandel" := Enum::"Nemhandel Company Status"::Unknown;
        CompanyInformation."Last Nemhandel Status Check DT" := 0DT;
        CompanyInformation.Modify();
    end;

    internal procedure ValidateCVRNumberFormat(CVRNumber: Text[20])
    var
        Regex: Codeunit Regex;
    begin
        if not Regex.IsMatch(CVRNumber, '^(\d{8}|A/S\d{3,6})$') then
            Error(IncorrectCVRNumberFormatErr);
    end;

    internal procedure ManageNotRegisteredNotification(RegisteredWithNemhandel: Enum "Nemhandel Company Status")
    begin
        if not IsSaaSProductionCompany() then
            exit;

        if RegisteredWithNemhandel = Enum::"Nemhandel Company Status"::Registered then
            RecallNemhandelNotRegisteredNotification()
        else
            ShowNemhandelNotRegisteredNotification();
    end;

    internal procedure ShowNemhandelNotRegisteredNotification(): Boolean
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.Get(UserId, GetNemhandelNotRegisteredNotificationID()) then
            EnableNemhandelNotRegisteredNotification();

        if not IsNemhandelNotRegisteredNotificationEnabled() then
            exit(false);

        SendEnableNemhandelNotRegisteredNotification();
        exit(true);
    end;

    internal procedure RecallNemhandelNotRegisteredNotification()
    var
        NemhandelNotRegisteredNotification: Notification;
    begin
        NemhandelNotRegisteredNotification.Id := GetNemhandelNotRegisteredNotificationID();
        if NemhandelNotRegisteredNotification.Recall() then;
    end;

    local procedure EnableNemhandelNotRegisteredNotification()
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.SetStatus(GetNemhandelNotRegisteredNotificationID(), true) then
            MyNotifications.InsertDefault(
                GetNemhandelNotRegisteredNotificationID(), EnableNemhandelNotRegisteredNotificationTxt, EnableNemhandelNotRegisteredNotificationDescrTxt, true);
    end;

    local procedure GetNemhandelNotRegisteredNotificationID(): Guid
    begin
        exit('cd142648-4540-447f-bc5f-cfe29b12f71d');
    end;

    local procedure IsNemhandelNotRegisteredNotificationEnabled(): Boolean
    var
        InstructionMgt: Codeunit "Instruction Mgt.";
    begin
        exit(InstructionMgt.IsMyNotificationEnabled(GetNemhandelNotRegisteredNotificationID()));
    end;

    local procedure SendEnableNemhandelNotRegisteredNotification()
    var
        NemhandelNotRegisteredNotification: Notification;
    begin
        NemhandelNotRegisteredNotification.Id := GetNemhandelNotRegisteredNotificationID();
        if NemhandelNotRegisteredNotification.Recall() then;

        NemhandelNotRegisteredNotification.Message(NotificationMsg);
        NemhandelNotRegisteredNotification.Scope(NotificationScope::LocalScope);
        NemhandelNotRegisteredNotification.AddAction(RegisterInNemhandelTxt, Codeunit::"Nemhandel Status Mgt.", 'OpenNemhandelsregisteretLink');
        NemhandelNotRegisteredNotification.AddAction(OpenRegistrationGuideTxt, Codeunit::"Nemhandel Status Mgt.", 'OpenNemhandelsregisteretGuideLink');
        NemhandelNotRegisteredNotification.Send();
    end;

    internal procedure OpenNemhandelsregisteretLink(Notification: Notification)
    var
        CustomerConsentMgt: Codeunit "Customer Consent Mgt.";
    begin
        if CustomerConsentMgt.ConfirmUserConsentToOpenExternalLink() then
            Hyperlink(NemhandelsregisteretUrlLbl);
        ShowNemhandelNotRegisteredNotification();
    end;

    internal procedure OpenNemhandelsregisteretGuideLink(Notification: Notification)
    var
        CustomerConsentMgt: Codeunit "Customer Consent Mgt.";
    begin
        if CustomerConsentMgt.ConfirmUserConsentToOpenExternalLink() then
            Hyperlink(NemhandelsregisteretGuidanceUrlLbl);
        ShowNemhandelNotRegisteredNotification();
    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    local procedure NemhandelStatusOnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    begin
        ResetRegisteredWithNemhandel(NewCompanyName);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure NemhandelStatusOnClearCompanyConfig(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    begin
        ResetRegisteredWithNemhandel(CompanyName);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnAfterModifyEvent', '', false, false)]
    local procedure WriteLogOnAfterModifyEvent(var Rec: Record "Company Information"; var xRec: Record "Company Information"; RunTrigger: Boolean)
    var
        Telemetry: Codeunit "Telemetry";
        CustomDimensions: Dictionary of [Text, Text];
    begin
        if Rec.IsTemporary() then
            exit;

        CustomDimensions.Add('Category', NemhandelsregisteretCategoryTxt);

        if Rec."Registration No." <> xRec."Registration No." then
            Telemetry.LogMessage(
                '0000MAR', StrSubstNo(CVRNumberChangedTxt, xRec."Registration No.", Rec."Registration No.", RunTrigger), Verbosity::Normal,
                DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, CustomDimensions);

        if Rec."Registered with Nemhandel" <> xRec."Registered with Nemhandel" then
            Telemetry.LogMessage(
                '0000MAS', StrSubstNo(RegisteredStatusChangedTxt, xRec."Registered with Nemhandel", Rec."Registered with Nemhandel", RunTrigger), Verbosity::Normal,
                DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, CustomDimensions);
    end;
}