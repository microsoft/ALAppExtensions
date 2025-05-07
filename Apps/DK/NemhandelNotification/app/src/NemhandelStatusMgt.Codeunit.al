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
        NotRegisteredNotificationMsg: Label 'Your accounting software is not registered in Nemhandelsregisteret.';
        IncorrectCVRNumberFormatMsg: Label 'The Registration No. must be 8 digits or "A/S" followed by 3-6 digits.';
        RegisterInNemhandelTxt: Label 'Register in Nemhandelsregisteret', Comment = 'Nemhandelsregisteret word is already in Danish, no need to translate.';
        OpenRegistrationGuideTxt: Label 'Open registration guide';
        EnableNemhandelNotRegisteredNotificationTxt: Label 'Enable Nemhandel Not Registered Notification';
        EnableNemhandelNotRegisteredNotificationDescrTxt: Label 'Notify me that the company with the given CVR number is not registered in Nemhandelsregisteret. The message is shown on the Company Information page.';
        EnableIncorrectCVRFormatNotificationTxt: Label 'Enable Incorrect CVR Format Notification';
        EnableIncorrectCVRFormatNotificationDescrTxt: Label 'Notify me that the CVR number is not in the correct format. The message is shown on the Company Information page.';
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

    local procedure IsCVRNumberFormatValid(CVRNumber: Text[20]): Boolean
    var
        Regex: Codeunit Regex;
    begin
        exit(Regex.IsMatch(CVRNumber, '^(\d{8}|A/S\d{3,6})$'));
    end;

    internal procedure ValidateCVRNumberFormat(CVRNumber: Text[20])
    var
        Regex: Codeunit Regex;
    begin
        if not Regex.IsMatch(CVRNumber, '^(\d{8}|A/S\d{3,6})$') then
            Error(IncorrectCVRNumberFormatErr);
    end;

    internal procedure ManageNotRegisteredNotification(RegisteredWithNemhandel: Enum "Nemhandel Company Status")
    var
        NotificationID: Guid;
    begin
        if not IsSaaSProductionCompany() then
            exit;

        NotificationID := GetNemhandelNotRegisteredNotificationID();
        if RegisteredWithNemhandel = Enum::"Nemhandel Company Status"::Registered then
            RecallNotification(NotificationID)
        else
            ShowNotification(NotificationID);
    end;

    internal procedure ManageIncorrectCVRFormatNotification(CVRNumber: Text[20])
    var
        NotificationID: Guid;
    begin
        if not IsSaaSProductionCompany() then
            exit;

        NotificationID := GetIncorrectCVRFormatNotificationID();
        if IsCVRNumberFormatValid(CVRNumber) then
            RecallNotification(NotificationID)
        else
            ShowNotification(NotificationID);
    end;

    internal procedure ShowNotification(NotificationID: Guid): Boolean
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.Get(UserId, NotificationID) then
            EnableNotification(NotificationID);

        if not IsNotificationEnabled(NotificationID) then
            exit(false);

        SendEnableNotification(NotificationID);
        exit(true);
    end;

    internal procedure RecallNotification(NotificationID: Guid)
    var
        Notification: Notification;
    begin
        Notification.Id := NotificationID;
        if Notification.Recall() then;
    end;

    local procedure EnableNotification(NotificationID: Guid)
    var
        MyNotifications: Record "My Notifications";
        NotificationName: Text[128];
        DescriptionText: Text;
    begin
        case NotificationID of
            GetNemhandelNotRegisteredNotificationID():
                begin
                    NotificationName := EnableNemhandelNotRegisteredNotificationTxt;
                    DescriptionText := EnableNemhandelNotRegisteredNotificationDescrTxt;
                end;
            GetIncorrectCVRFormatNotificationID():
                begin
                    NotificationName := EnableIncorrectCVRFormatNotificationTxt;
                    DescriptionText := EnableIncorrectCVRFormatNotificationDescrTxt;
                end;
        end;

        if not MyNotifications.SetStatus(NotificationID, true) then
            MyNotifications.InsertDefault(NotificationID, NotificationName, DescriptionText, true);
    end;

    local procedure GetNemhandelNotRegisteredNotificationID(): Guid
    begin
        exit('cd142648-4540-447f-bc5f-cfe29b12f71d');
    end;

    local procedure GetIncorrectCVRFormatNotificationID(): Guid
    begin
        exit('1ff2c627-7c7d-4a79-8729-a081ffb08f62');
    end;

    local procedure IsNotificationEnabled(NotificationID: Guid): Boolean
    var
        InstructionMgt: Codeunit "Instruction Mgt.";
    begin
        exit(InstructionMgt.IsMyNotificationEnabled(NotificationID));
    end;

    local procedure SendEnableNotification(NotificationID: Guid)
    var
        Notification: Notification;
        NotificationMessage: Text;
        NotificationActions: Dictionary of [Text, Text];
        ActionMethodName: Text;
        ActionCaption: Text;
    begin
        case NotificationID of
            GetNemhandelNotRegisteredNotificationID():
                begin
                    NotificationMessage := NotRegisteredNotificationMsg;
                    NotificationActions.Add('OpenNemhandelsregisteretLink', RegisterInNemhandelTxt);
                    NotificationActions.Add('OpenNemhandelsregisteretGuideLink', OpenRegistrationGuideTxt);
                end;
            GetIncorrectCVRFormatNotificationID():
                NotificationMessage := IncorrectCVRNumberFormatMsg;
        end;

        Notification.Id := NotificationID;
        if Notification.Recall() then;

        Notification.Message(NotificationMessage);
        Notification.Scope(NotificationScope::LocalScope);
        foreach ActionMethodName in NotificationActions.Keys do begin
            ActionCaption := NotificationActions.Get(ActionMethodName);
            Notification.AddAction(ActionCaption, Codeunit::"Nemhandel Status Mgt.", ActionMethodName);
        end;
        Notification.Send();
    end;

    internal procedure OpenNemhandelsregisteretLink(Notification: Notification)
    var
        CustomerConsentMgt: Codeunit "Customer Consent Mgt.";
    begin
        if CustomerConsentMgt.ConfirmUserConsentToOpenExternalLink() then
            Hyperlink(NemhandelsregisteretUrlLbl);
        ShowNotification(GetNemhandelNotRegisteredNotificationID());
    end;

    internal procedure OpenNemhandelsregisteretGuideLink(Notification: Notification)
    var
        CustomerConsentMgt: Codeunit "Customer Consent Mgt.";
    begin
        if CustomerConsentMgt.ConfirmUserConsentToOpenExternalLink() then
            Hyperlink(NemhandelsregisteretGuidanceUrlLbl);
        ShowNotification(GetNemhandelNotRegisteredNotificationID());
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