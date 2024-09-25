namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;
using System.Reflection;
using System.Environment.Configuration;

codeunit 36961 "Setup Helper"
{
    Access = Internal;

    procedure EnsureUserAcceptedPowerBITerms()
    var
        PowerBIContextSettings: Record "Power BI Context Settings";
        PowerBIEmbedSetupWizard: Page "Power BI Embed Setup Wizard";
        PowerBiNotSetupErr: Label 'Power BI is not set up. You need to set up Power BI in order to continue.';
    begin
        PowerBIContextSettings.SetRange(UserSID, UserSecurityId());
        if PowerBIContextSettings.IsEmpty() then begin
            PowerBIEmbedSetupWizard.SetContext('');
            if PowerBIEmbedSetupWizard.RunModal() <> Action::OK then;

            if PowerBIContextSettings.IsEmpty() then
                Error(PowerBiNotSetupErr);
        end;
    end;

    procedure GetReportIdAndEnsureSetup(ReportName: Text; FieldId: Integer): Guid
    var
        PowerBiReportsSetup: Record "PowerBI Reports Setup";
        AssistedSetup: Page "Assisted Setup";

        RecRef: RecordRef;
        FldRef: FieldRef;
        FinanceAppNotSetupErr: Label 'Your %1 Report has not been setup in PowerBI Reports Setup. You need to set up this reports in order to view it.', Comment = '%1 = report name';
    begin
        if PowerBiReportsSetup.Get() then begin
            RecRef.Get(PowerBiReportsSetup.RecordId());
            FldRef := RecRef.Field(FieldId);
        end;
        if IsNullGuid(FldRef.Value()) then begin
            if AssistedSetup.RunModal() = Action::OK then;
            if PowerBiReportsSetup.Get() then begin
                RecRef.Get(PowerBiReportsSetup.RecordId());
                FldRef := RecRef.Field(FieldId);
            end;
            if IsNullGuid(FldRef.Value()) then
                Error(FinanceAppNotSetupErr, ReportName);
        end;
        exit(FldRef.Value());
    end;

    procedure LookupPowerBIReport(var ReportId: Guid; var ReportName: Text[200]): Boolean
    var
        WorkspaceId: Guid;
        WorkspaceName: Text[200];
    begin
        if LookupPowerBIWorkspace(WorkspaceId, WorkspaceName) then
            if LookupPowerBIReport(WorkspaceId, WorkspaceName, ReportId, ReportName) then
                exit(true);
    end;

    procedure LookupPowerBIReport(WorkspaceId: Guid; WorkspaceName: Text[200]; var ReportId: Guid; var ReportName: Text[200]): Boolean
    var
        TempPowerBISelectionElement: Record "Power BI Selection Element" temporary;
        PowerBIWorkspaceMgt: Codeunit "Power BI Workspace Mgt.";
    begin
        PowerBIWorkspaceMgt.AddReportsForWorkspace(TempPowerBISelectionElement, WorkspaceId, WorkspaceName);
        TempPowerBISelectionElement.SetRange(Type, TempPowerBISelectionElement.Type::Report);
        if not IsNullGuid(ReportId) then begin
            TempPowerBISelectionElement.SetRange(ID, ReportId);
            if TempPowerBISelectionElement.FindFirst() then;
            TempPowerBISelectionElement.SetRange(ID);
        end;
        if Page.RunModal(Page::"Power BI Selection Lookup", TempPowerBISelectionElement) = Action::LookupOK then begin
            ReportId := TempPowerBISelectionElement.ID;
            ReportName := TempPowerBISelectionElement.Name;
            exit(true);
        end;
    end;

    procedure LookupPowerBIWorkspace(var WorkspaceId: Guid; var WorkspaceName: Text[200]): Boolean
    var
        TempPowerBISelectionElement: Record "Power BI Selection Element" temporary;
        PowerBIWorkspaceMgt: Codeunit "Power BI Workspace Mgt.";
    begin
        PowerBIWorkspaceMgt.AddSharedWorkspaces(TempPowerBISelectionElement);
        TempPowerBISelectionElement.SetRange(Type, TempPowerBISelectionElement.Type::Workspace);
        if not IsNullGuid(WorkspaceId) then begin
            TempPowerBISelectionElement.SetRange(ID, WorkspaceId);
            if TempPowerBISelectionElement.FindFirst() then;
            TempPowerBISelectionElement.SetRange(ID);
        end;
        if Page.RunModal(Page::"Power BI Selection Lookup", TempPowerBISelectionElement) = Action::LookupOK then begin
            WorkspaceId := TempPowerBISelectionElement.ID;
            WorkspaceName := TempPowerBISelectionElement.Name;
            exit(true);
        end;
    end;

    procedure InitializeEmbeddedAddin(PowerBIManagement: ControlAddIn PowerBIManagement; ReportId: Guid; ReportPageTok: Text)
    var
        PowerBIServiceMgt: Codeunit "Power BI Service Mgt.";
        TypeHelper: Codeunit "Type Helper";
        PowerBIEmbedReportUrlTemplateTxt: Label 'https://app.powerbi.com/reportEmbed?reportId=%1', Locked = true;
    begin
        PowerBiServiceMgt.InitializeAddinToken(PowerBIManagement);
        PowerBIManagement.SetLocale(TypeHelper.GetCultureName());
        PowerBIManagement.SetSettings(false, true, false, false, false, false, true);
        PowerBIManagement.EmbedPowerBIReport(
            StrSubstNo(PowerBIEmbedReportUrlTemplateTxt, ReportId),
            ReportId,
            ReportPageTok);
    end;

    procedure ShowPowerBIErrorNotification(ErrorCategory: Text; ErrorMessage: Text)
    var
        PowerBIContextSettings: Record "Power BI Context Settings";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        Notify: Notification;
        ErrorNotificationMsg: Label 'An error occurred while loading Power BI. Your Power BI embedded content might not work. Here are the error details: "%1: %2"', Comment = '%1: a short error code. %2: a verbose error message in english';
    begin
        Notify.Id := CreateGuid();
        Notify.Message(StrSubstNo(ErrorNotificationMsg, ErrorCategory, ErrorMessage));
        Notify.Scope := NotificationScope::LocalScope;
        NotificationLifecycleMgt.SendNotification(Notify, PowerBIContextSettings.RecordId());
    end;
}