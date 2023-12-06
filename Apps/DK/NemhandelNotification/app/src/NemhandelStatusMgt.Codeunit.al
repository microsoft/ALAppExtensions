namespace Microsoft.EServices;

using Microsoft.Foundation.Company;
using Microsoft.Utilities;
using System.Environment.Configuration;
using System.Privacy;

codeunit 13628 "Nemhandel Status Mgt."
{
    Access = Public;

    var
        HttpClientGlobal: Interface "Http Client Nemhandel Status";
        HttpClientDefined: Boolean;
        NotificationMsg: Label 'Your accounting software is not registered in Nemhandelsregisteret.';
        EnableNemhandelNotRegisteredNotificationTxt: Label 'Enable Nemhandel Not Registered Notification';
        EnableNemhandelNotRegisteredNotificationDescrTxt: Label 'Notify me that the company with the given CVR number is not registered in Nemhandelsregisteret. The message is shown on the Company Information page.';
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

#if not CLEAN24
    internal procedure IsFeatureEnableDatePassed(): Boolean
    var
        FeatureEnableDatePassed: Boolean;
        IsHandled: Boolean;
    begin
        OnBeforeCheckFeatureEnableDate(FeatureEnableDatePassed, IsHandled);
        if IsHandled then
            exit(FeatureEnableDatePassed);
        exit(CurrentDateTime() > GetFeatureEnableDateTime());
    end;

    local procedure GetFeatureEnableDateTime(): DateTime
    begin
        exit(CreateDateTime(20240101D, 0T));    // 1 January 2024
    end;
#endif
    local procedure GetNemhandelStatusCheckIntervalMs(): Integer
    begin
        exit(60 * 60 * 1000); // 1 hour in milliseconds
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

    internal procedure ManageNotRegisteredNotification(RegisteredWithNemhandel: Enum "Nemhandel Company Status")
    begin
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
        NemhandelNotRegisteredNotification.AddAction('Register in Nemhandelsregisteret', Codeunit::"Nemhandel Status Mgt.", 'OpenNemhandelsregisteretLink');
        NemhandelNotRegisteredNotification.AddAction('Open registration guide', Codeunit::"Nemhandel Status Mgt.", 'OpenNemhandelsregisteretGuideLink');
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

    [InternalEvent(false)]
    internal procedure OnBeforeCheckFeatureEnableDate(var FeatureEnableDatePassed: Boolean; var IsHandled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    local procedure NemhandelStatusOnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.ChangeCompany(NewCompanyName);
        if not CompanyInformation.Get() then
            exit;

        CompanyInformation."Registration No." := '';
        CompanyInformation."Registered with Nemhandel" := Enum::"Nemhandel Company Status"::Unknown;
        CompanyInformation."Last Nemhandel Status Check DT" := 0DT;
        CompanyInformation.Modify();
    end;
}