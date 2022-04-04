codeunit 1151 "COHUB Core"
{
    TableNo = "COHUB Enviroment";
    Access = Internal;

    trigger OnRun()
    begin
    end;

    var
        ActivityDescriptionEnviromentFailTxt: Label 'Could not get fresh key performance data for enviroment %1.', Comment = '%1 = Enviroment Name';
        ActivityDescriptionCompanyFailTxt: Label 'Updating key performance indicator data failed for the company %1.', Comment = '%1 = Company name.';
        ActivityContextTxt: Label 'Company Hub';
        EnviromentLinkValidMsg: Label 'The link was successfully validated.';
        CRONUSCompanyNameTxt: Label 'CRONUS - SAMPLE', Comment = 'This is a mock sample company and should be translated.';
        UserTxt: Label '"USER ID:  %1.  "', Locked = true;
        ErrorTxt: Label '"ERROR:  %1.  "', Locked = true;
        COHUBTelemetryCategoryTxt: Label 'Company Hub', Locked = true;
        COHUBTelemetryGoToCompanyTxt: Label '"EVENT:  Company Hub user logged into company.  "', Locked = true;
        COHUBTelemetryReloadCompaniesTxt: Label '"EVENT:  Company Hub user user reloaded all companies. Current number of enviroments:  "', Locked = true;
        CannotConnectToEnviromentErr: Label 'Failed to fetch the companies. Please verify if you can log in manually by using the following link: %1', Comment = '%1 will be replaced with a url.';

        ClienkLinkFormatErr: Label 'The specified link is not valid. The link to the company must have the following format: https://businesscentral.dynamics.com/tenant[/enviroment]?redirectedfromsignup=1';
        RedirectedFromSignupTxt: Label '?redirectedfromsignup=1', Locked = true;
        ExportEnviromentsDialogLbl: Label 'Export';
        EnviromentsJsonFileNameTxt: Label 'EnviromentsList.json';
        ImportEnviromentsDialogLbl: Label 'Please specify the location of the file that contains the data that you want to import.';
        UnsupportedFieldValueTypeErr: Label 'Unsupported field found in the imported data. Field name: %1', Comment = '%1 is the name of the field', Locked = true;
        LoginToTargetCompanyToVerifyMsg: Label 'We recommend that you verify that you can access the target company so that we can verify your permissions, and you can provide consent if needed.\\Would you like us to open the company in a new window to verify your access?';
        LoginSuccessfulMsg: Label 'Was the login successful?';
        ProductionEnviromentTxt: Label 'Production', Locked = true;
        COHUBEnviromentExistsErr: Label 'An environment with the specified link already exists. Enviroment number %1, name %2.', Comment = '%1 No. field, %2 Name of enviroment';
        CompanyHubNotSupportedOnPremMsg: Label 'Company Hub extension is not supported in the On-Prem enviroment.';
        NoEnviromentsMsg: Label 'The company hub is empty. Go ahead and add the first environment.';
        EnterEnviromentsTxt: Label 'Setup';
        DontShowAgainTok: Label 'Don''t show again';
        DontShowAgainSetupCompanyHubNotificationTxt: Label 'Company Hub Setup Notification', MaxLength = 128;
        DontShowAgainSetupCompanyHubNotificationDescriptionTxt: Label 'This notification is raised to help set up the company hub if no enviroments have been added.';

    procedure GoToCompany(COHUBEnviroment: Record "COHUB Enviroment"; Company: Text)
    var
    begin
        if COHUBEnviroment.Link <> '' then begin
            HyperLink(COHUBEnviroment.Link + '&company=' + Company);
            Session.LogMessage('0000163', COHUBTelemetryGoToCompanyTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', COHUBTelemetryCategoryTxt);
        end;
    end;

    procedure UpdateEnviromentCompany(EnviromentNumber: Code[20]; CompanyName: Text[50]; AssignedTo: Guid)
    var
        COHUBCompanyEndpoint: Record "COHUB Company Endpoint";
        COHUBCompUrlTaskManager: Codeunit "COHUB Comp. Url Task Manager";
        SourceRecordRef: RecordRef;
    begin
        if COHUBCompanyEndpoint.Get(EnviromentNumber, CompanyName, AssignedTo) then begin
            SourceRecordRef.GetTable(COHUBCompanyEndpoint);
            COHUBCompUrlTaskManager.GatherKPIData(COHUBCompanyEndpoint);
        end;
    end;

    procedure SetUserTaskComplete(EnviromentNumber: Code[20]; CompanyName: Text[50]; AssignedTo: Guid; TaskId: Integer)
    var
        COHUBCompanyEndpoint: Record "COHUB Company Endpoint";
        COHUBCompUrlTaskManager: Codeunit "COHUB Comp. Url Task Manager";
        SourceRecordRef: RecordRef;
    begin
        if COHUBCompanyEndpoint.Get(EnviromentNumber, CompanyName, AssignedTo) then begin
            SourceRecordRef.GetTable(COHUBCompanyEndpoint);

            COHUBCompUrlTaskManager.SetTaskComplete(COHUBCompanyEndpoint, TaskId);
        end;
    end;

    procedure ShowSetupCompanyHubNotification()
    var
        MyNotifications: Record "My Notifications";
        NoEnviromentsEnteredNotification: Notification;
    begin
        if MyNotifications.Get(UserId, GetShowSetupCompanyHubNotificationId()) then
            if not MyNotifications.Enabled then
                exit;

        NoEnviromentsEnteredNotification.Message(NoEnviromentsMsg);
        NoEnviromentsEnteredNotification.Id := GetShowSetupCompanyHubNotificationId();
        if NoEnviromentsEnteredNotification.Recall() then;
        NoEnviromentsEnteredNotification.Scope := NotificationScope::LocalScope;
        NoEnviromentsEnteredNotification.AddAction(EnterEnviromentsTxt, Codeunit::"COHUB Core", 'OpenEnviroment');
        NoEnviromentsEnteredNotification.AddAction(DontShowAgainTok, Codeunit::"COHUB Core", 'DontShowAgainSetupCompanyHubNotification');
        NoEnviromentsEnteredNotification.Send();
    end;

    local procedure GetShowSetupCompanyHubNotificationId(): Guid
    begin
        exit('896f743d-d47e-4193-a651-178209df33e3');
    end;

    procedure UpdateAllCompanies(UpdatateAsync: Boolean)
    var
        COHUBEnviroment: Record "COHUB Enviroment";
    begin
        COHUBEnviroment.SetFilter(Link, '<> %1', '');
        COHUBEnviroment.SetFilter(Name, '<> %1', GetCRONUSEnviromentName());
        if COHUBEnviroment.FindSet() then
            repeat
                if UpdatateAsync then
                    TaskScheduler.CreateTask(
                    Codeunit::"COHUB Url Task Manager", Codeunit::"COHUB Url Error Handler", true, CompanyName(), 0DT, COHUBEnviroment.RecordId())
                else
                    if not Codeunit.Run(Codeunit::"COHUB Url Task Manager", COHUBEnviroment) then
                        Codeunit.Run(Codeunit::"COHUB Url Error Handler", COHUBEnviroment);
            until COHUBEnviroment.Next() = 0;

        Session.LogMessage('0000164', COHUBTelemetryReloadCompaniesTxt + Format(COHUBEnviroment.Count()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', COHUBTelemetryCategoryTxt);
    end;

    procedure OpenEnviroment(NoClientsEnteredNotification: Notification)
    begin
        Page.Run(Page::"COHUB Enviroment List");
    end;

    procedure DontShowAgainSetupCompanyHubNotification(SetupCompanyHubNotification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefault(SetupCompanyHubNotification.Id, DontShowAgainSetupCompanyHubNotificationTxt,
                          DontShowAgainSetupCompanyHubNotificationDescriptionTxt, false);
    end;

    procedure ValidateEnviromentUrl(COHUBEnviroment: Record "COHUB Enviroment"): Boolean;
    var
        COHUBUrlTaskManager: Codeunit "COHUB Url Task Manager";
        SourceRecordRef: RecordRef;
        EnviromentNameAndEnviroment: Text;
        EnviromentLink: Text;
        EnviromentName: Text;
    begin
        SourceRecordRef.GetTable(COHUBEnviroment);
        EnviromentLink := COHUBEnviroment.Link;

        if not EnviromentLink.ToLower().TrimStart().StartsWith(GetFixedClientUrl()) then
            Error(ClienkLinkFormatErr);

        if not EnviromentLink.ToLower().TrimEnd().EndsWith(RedirectedFromSignupTxt) then
            Error(ClienkLinkFormatErr);

        GetEnviromentNameAndEnviroment(COHUBEnviroment, EnviromentName, EnviromentNameAndEnviroment);

        if not (StrLen(EnviromentNameAndEnviroment) > 0) then
            Error(ClienkLinkFormatErr);

        if GuiAllowed() then
            if Confirm(LoginToTargetCompanyToVerifyMsg) then begin
                Hyperlink(EnviromentLink);
                if not Confirm(LoginSuccessfulMsg) then
                    exit(false);
            end;

        if not (COHUBUrlTaskManager.FetchCompanies(COHUBEnviroment)) then
            Error(CannotConnectToEnviromentErr, EnviromentLink);

        Commit();
        if Codeunit.Run(Codeunit::"COHUB Group Summary Sync") then;

        if GuiAllowed then
            Message(EnviromentLinkValidMsg);

        exit(true);
    end;

    procedure AppendRedirectedFromSignupUrl(var EnviromentLink: Text[2048])
    begin
        if not EnviromentLink.ToLower().TrimEnd().EndsWith(RedirectedFromSignupTxt) then
            EnviromentLink := CopyStr(EnviromentLink.TrimEnd().TrimEnd('/') + RedirectedFromSignupTxt, 1, MaxStrLen(EnviromentLink));

        if EnviromentLink.Contains('/?') then
            EnviromentLink := CopyStr(EnviromentLink.Replace('/?', '?'), 1, MaxStrLen(EnviromentLink));
    end;

#pragma warning disable AA0150
    procedure VerifyForDuplicates(CurrentCOHUBEnviroment: Record "COHUB Enviroment"; var EnviromentLink: Text[2048])
    var
        COHUBEnviroment: Record "COHUB Enviroment";
    begin
        COHUBEnviroment.SetRange(Link, EnviromentLink);
        COHUBEnviroment.SetFilter("No.", '<>%1', CurrentCOHUBEnviroment."No.");
        if COHUBEnviroment.FindFirst() then
            Error(COHUBEnviromentExistsErr, COHUBEnviroment."No.", COHUBEnviroment.Name)
    end;
#pragma warning restore AA0150

    procedure GetCRONUSEnviromentName(): Text[50];
    begin
        exit(CopyStr(CRONUSCompanyNameTxt, 1, 50));
    end;

    procedure LogFailure(ErrorText: Text; SourceRecordRef: RecordRef)
    var
        ActivityLog: Record "Activity Log";
        COHUBEnviroment: Record "COHUB Enviroment";
        COHUBCompanyEndpoint: Record "COHUB Company Endpoint";
        ActivityDescription: Text;
        LogInformation: Text;
        UserInformation: Text;
    begin
        case SourceRecordRef.Number() of
            Database::"COHUB Enviroment":
                begin
                    SourceRecordRef.SetTable(COHUBEnviroment);
                    ActivityDescription := StrSubstNo(ActivityDescriptionEnviromentFailTxt, COHUBEnviroment.Name);
                end;
            Database::"COHUB Company Endpoint":
                begin
                    SourceRecordRef.SetTable(COHUBCompanyEndpoint);
                    ActivityDescription := StrSubstNo(ActivityDescriptionCompanyFailTxt, COHUBCompanyEndpoint."Company Name");
                end;
        end;

        UserInformation := StrSubstNo(UserTxt, UserId());
        LogInformation := StrSubstNo(ErrorTxt, ErrorText);
        ActivityLog.LogActivity(SourceRecordRef.RecordId(), ActivityLog.Status::Failed, CopyStr(ActivityContextTxt, 1, 30), ActivityDescription, UserInformation + LogInformation);
        Session.LogMessage('0000CPW', LogInformation, Verbosity::Error, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', COHUBTelemetryCategoryTxt);
    end;

    procedure IsPPE(): Boolean;
    var
        Url: Text;
    begin
        Url := LowerCase(GetUrl(ClientType::Web));
        exit((StrPos(Url, 'businesscentral.dynamics-tie.com') <> 0) OR (StrPos(Url, 'localhost.businesscentral.dynamics-ppe.com') <> 0));
    end;

    procedure GetFixedWebServicesUrl(): Text;
    var
        Url: Text;
    begin
        if IsPPE() then
            exit('https://api.businesscentral.dynamics-tie.com/');


        Url := GetUrl(ClientType::ODataV4);

        // Should return something like https://api.businesscentral.dynamics.com
        // We supprot partner URL structure as well https://[application family].bc.dynamics.com[/environment]
        Url := Url.Remove(Url.IndexOf('.com/') + StrLen('.com/'));
        exit(Url);
    end;

    procedure GetFixedClientUrl(): Text;
    var
        URLHelper: Codeunit "Url Helper";
    begin
        if IsPPE() then
            exit('https://businesscentral.dynamics-tie.com/');

        exit(URLHelper.GetFixedClientEndpointBaseUrl());
    end;

    [Obsolete('Replaced with GetResourceURL', '19.0')]
    procedure GetResoureUrl(): Text[100];
    var
    begin
        if IsPPE() then
            exit('https://api.businesscentral.dynamics-tie.com')
        else
            exit('https://api.businesscentral.dynamics.com');
    end;

    procedure GetResourceUrl(): Text;
    var
        ResourceURL: Text;
        Handled: Boolean;
    begin
        if IsPPE() then
            exit('https://api.businesscentral.dynamics-tie.com');

        OnGetResourceURL(ResourceURL, Handled);
        if Handled then
            exit(ResourceURL);

        exit('https://api.businesscentral.dynamics.com');
    end;

    procedure ExportEnviroments()
    var
        COHUBEnviroment: Record "COHUB Enviroment";
        TempBlob: Codeunit "Temp Blob";
        AllEnviromentsJsonObject: JsonObject;
        EnviromentsJsonArray: JsonArray;
        EnviromentJsonObject: JsonObject;
        JsonInStream: InStream;
        JsonOutStream: OutStream;
        EnviromentsJsonTxt: Text;
        FileName: Text;
    begin
        if not COHUBEnviroment.FindSet() then
            exit;

        repeat
            EnviromentJsonObject := EnviromentToJson(COHUBEnviroment);
            EnviromentsJsonArray.Add(EnviromentJsonObject);
        until COHUBEnviroment.Next() = 0;

        AllEnviromentsJsonObject.Add('values', EnviromentsJsonArray);
        AllEnviromentsJsonObject.WriteTo(EnviromentsJsonTxt);
        TempBlob.CreateOutStream(JsonOutStream);
        JsonOutStream.WriteText(EnviromentsJsonTxt);
        TempBlob.CreateInStream(JsonInStream);

        FileName := EnviromentsJsonFileNameTxt;
        DownloadFromStream(JsonInStream, ExportEnviromentsDialogLbl, '', '*.json', FileName);
    end;

    procedure ImportEnviroments()
    var
        COHUBEnviroment: Record "COHUB Enviroment";
        EnviromentsJsonObject: JsonObject;
        CurrentEnviromentJsonToken: JsonToken;
        EnviromentsJToken: JsonToken;
        EnviromentsJsonArray: JsonArray;
        JsonInStream: InStream;
        EnviromentsJsonTxt: Text;
        FileName: Text;
        I: Integer;
    begin
        FileName := EnviromentsJsonFileNameTxt;

        if not UploadIntoStream(ImportEnviromentsDialogLbl, '', 'All Files (*.*)|*.*', FileName, JsonInStream) then
            exit;

        JsonInStream.ReadText(EnviromentsJsonTxt);
        EnviromentsJsonObject.ReadFrom(EnviromentsJsonTxt);
        EnviromentsJsonObject.Get('values', EnviromentsJToken);
        EnviromentsJsonArray := EnviromentsJToken.AsArray();
        for I := 0 to EnviromentsJsonArray.Count() - 1 do begin
            EnviromentsJsonArray.Get(I, CurrentEnviromentJsonToken);
            EnviromentFromJson(CurrentEnviromentJsonToken, COHUBEnviroment);
            COHUBEnviroment.Insert();
        end;
    end;

    procedure ShowNotSupportedOnPremNotification(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
        NotSupportedOnPremNotification: Notification;
    begin
        if not EnvironmentInformation.IsOnPrem() then
            exit(false);

        NotSupportedOnPremNotification.Id := 'fcb734e8-9f28-438b-ae85-164a40ff4bf1';
        NotSupportedOnPremNotification.Scope := NotSupportedOnPremNotification.Scope::LocalScope;
        NotSupportedOnPremNotification.Message := CompanyHubNotSupportedOnPremMsg;
        NotSupportedOnPremNotification.Send();

        exit(true);
    end;

    procedure GetEnviromentManagementUrl(): Text;
    var
    begin
        if IsPPE() then
            exit('https://tenantmanagement.smb.dynamics-tie.com/v3.0/tenant/')
        else
            exit('https://tenantmanagement.smb.dynamics.com/v3.0/tenant/');
    end;

    procedure GetEnviromentNameAndEnviroment(COHUBEnviromentRecord: Record "COHUB Enviroment"; var EnviromentName: Text; var EnviromentNameAndEnviroment: Text)
    var
        EnviromentLinkLower: Text;
    begin
        EnviromentLinkLower := COHUBEnviromentRecord.Link.ToLower();

        //Remove beginning portion
        EnviromentNameAndEnviroment := CopyStr(EnviromentLinkLower.Replace(GetFixedClientUrl(), ''), 1);

        //Remove ending portion
        EnviromentNameAndEnviroment := CopyStr(EnviromentNameAndEnviroment.Replace(RedirectedFromSignupTxt, ''), 1);

        // Only if they have used tenant name as a guid we can use V2.0 version of API
        if StrLen(EnviromentNameAndEnviroment) = 0 then
            Error(ClienkLinkFormatErr);

        if EnviromentNameAndEnviroment.Contains('/') then
            EnviromentName := CopyStr(EnviromentNameAndEnviroment, 1, StrPos(EnviromentNameAndEnviroment, '/') - 1)
        else begin
            EnviromentName := EnviromentNameAndEnviroment;
            EnviromentNameAndEnviroment += '/' + ProductionEnviromentTxt;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"COHUB Enviroment", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterEnviromentDelete(var Rec: Record "COHUB Enviroment"; RunTrigger: Boolean)
    var
        COHUBCompanyKPI: Record "COHUB Company KPI";
        EnviromentCompanyEndpoint: Record "COHUB Company Endpoint";
        COHUBUserTask: Record "COHUB User Task";
    begin
        if Rec.IsTemporary() then
            exit;

        COHUBCompanyKPI.SetRange("Enviroment No.", Rec."No.");
        COHUBCompanyKPI.DeleteAll();

        EnviromentCompanyEndpoint.SetRange("Enviroment No.", Rec."No.");
        EnviromentCompanyEndpoint.DeleteAll();

        COHUBUserTask.SetRange("Enviroment No.", Rec."No.");
        COHUBUserTask.DeleteAll();
    end;

    local procedure EnviromentToJson(var COHUBEnviroment: Record "COHUB Enviroment"): JsonObject
    var
        COHUBEnviromentRecordRef: RecordRef;
        COHUBEnviromentFieldRef: FieldRef;
        EnviromentJsonObject: JsonObject;
        I: Integer;
    begin
        COHUBEnviromentRecordRef.GetTable(COHUBEnviroment);

        for I := 1 to COHUBEnviromentRecordRef.FieldCount() do begin
            COHUBEnviromentFieldRef := COHUBEnviromentRecordRef.FieldIndex(I);
            EnviromentJsonObject.Add(COHUBEnviromentFieldRef.Name, Format(COHUBEnviromentFieldRef.Value, 0, 9));
        end;

        exit(EnviromentJsonObject);
    end;

    local procedure EnviromentFromJson(EnviromentToken: JsonToken; var COHUBEnviroment: Record "COHUB Enviroment")
    var
        COHUBEnviromentRecordRef: RecordRef;
        COHUBEnviromentFieldRef: FieldRef;
        EnviromentJsonObject: JsonObject;
        FieldJsonToken: JsonToken;
        FieldTextValue: Text;
        I: Integer;
        BooleanValue: Boolean;
        UnsupportedValueErrorInfo: ErrorInfo;
    begin
        Clear(COHUBEnviroment);
        COHUBEnviromentRecordRef.GetTable(COHUBEnviroment);
        EnviromentJsonObject := EnviromentToken.AsObject();

        for I := 1 to COHUBEnviromentRecordRef.FieldCount() do begin
            COHUBEnviromentFieldRef := COHUBEnviromentRecordRef.FieldIndex(I);
            if EnviromentJsonObject.Get(COHUBEnviromentFieldRef.Name, FieldJsonToken) then
                case COHUBEnviromentFieldRef.Type of
                    COHUBEnviromentFieldRef.Type::Boolean:
                        begin
                            FieldJsonToken.WriteTo(FieldTextValue);
                            Evaluate(BooleanValue, FieldTextValue.Replace('"', ''), 9);
                            COHUBEnviromentFieldRef.Value := BooleanValue;
                        end;
                    COHUBEnviromentFieldRef.Type::Text, COHUBEnviromentFieldRef.Type::Code:
                        begin
                            FieldTextValue := FieldJsonToken.AsValue().AsText();
                            COHUBEnviromentFieldRef.Value := FieldTextValue;
                        end
                    else begin
                            UnsupportedValueErrorInfo.ErrorType := UnsupportedValueErrorInfo.ErrorType::Internal;
                            UnsupportedValueErrorInfo.Message := UnsupportedFieldValueTypeErr;
                            UnsupportedValueErrorInfo.Verbosity := UnsupportedValueErrorInfo.Verbosity::Error;
                            UnsupportedValueErrorInfo.DataClassification := UnsupportedValueErrorInfo.DataClassification::SystemMetadata;
                            Error(UnsupportedValueErrorInfo);
                        end;
                end;
        end;

        COHUBEnviromentRecordRef.SetTable(COHUBEnviroment);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetResourceURL(var ResourceURL: Text; var Handled: Boolean)
    begin
    end;
}