namespace Microsoft.EServices;

using Microsoft.CRM.RoleCenters;
using Microsoft.Foundation.Company;
using Microsoft.Utilities;
using System.Telemetry;

pageextension 13630 "Sales Mgr. Activit. Nemhandel" extends "Sales & Relationship Mgr. Act."
{
    // this page is a part of page 9026 Sales & Relationship Mgr. RC

    var
        NemhandelStatusPageBckgrnd: Codeunit "Nemhandel Status Page Bckgrnd";
        NemhandelStatusMgt: Codeunit "Nemhandel Status Mgt.";
        BackgroundTaskId: Integer;
        PageBckGrndTaskCompletedTxt: Label 'Sales and Relationship Mgr. Activities Page Background Task to check Nemhandel registration status completed. Status: %1; status text: %2', Comment = '%1, %2 - Registered/NotRegisted/Unknown', Locked = true;
        NemhandelsregisteretCategoryTxt: Label 'Nemhandelsregisteret', Locked = true;
        NemhandelPageBackgroundTaskTxt: Label 'Nemhandel Page Background Task';
        NemhandelCheckCompanyStatusTxt: Label 'Nemhandel Check Company Status';

    trigger OnAfterGetCurrRecord()
    var
        CompanyInformation: Record "Company Information";
        InputParams: Dictionary of [Text, Text];
    begin
        CompanyInformation.Get();
        if NemhandelStatusMgt.IsNemhandelStatusCheckRequired(CompanyInformation) then begin
            InputParams.Add(NemhandelStatusPageBckgrnd.GetCVRNumberKey(), CompanyInformation."Registration No.");
            RunGetCompanyStatusBackgroundTask(InputParams);
        end;

        // even if background task was not run, show notification if company is not registered
        if BackgroundTaskId = 0 then
            NemhandelStatusMgt.ManageNotRegisteredNotification(CompanyInformation."Registered with Nemhandel");
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        ActivityLog: Record "Activity Log";
        Telemetry: Codeunit Telemetry;
        CustomDimensions: Dictionary of [Text, Text];
        CompanyStatusTextValue: Text;
        CompanyStatus: Enum "Nemhandel Company Status";
    begin
        if TaskId <> BackgroundTaskId then
            exit;
        if Results.Count() = 0 then
            exit;

        if Results.Get(NemhandelStatusPageBckgrnd.GetStatusKey(), CompanyStatusTextValue) then
            if Evaluate(CompanyStatus, CompanyStatusTextValue) then begin
                OnAfterGetCompanyStatusSalesMgrActivitBckgrndTask(CompanyStatus);
                NemhandelStatusMgt.UpdateRegisteredWithNemhandel(CompanyStatus);
            end;

        NemhandelStatusMgt.ManageNotRegisteredNotification(CompanyStatus);

        CustomDimensions.Add('Category', NemhandelsregisteretCategoryTxt);
        Telemetry.LogMessage(
            '0000LB9', StrSubstNo(PageBckGrndTaskCompletedTxt, CompanyStatus, CompanyStatusTextValue), Verbosity::Normal,
            DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
        ActivityLog.LogActivity(
            Rec.RecordId(), ActivityLog.Status::Success, NemhandelPageBackgroundTaskTxt, NemhandelCheckCompanyStatusTxt,
            StrSubstNo(PageBckGrndTaskCompletedTxt, CompanyStatus, CompanyStatusTextValue));
    end;

    local procedure RunGetCompanyStatusBackgroundTask(InputParams: Dictionary of [Text, Text])
    begin
        if BackgroundTaskId <> 0 then
            CurrPage.CancelBackgroundTask(BackgroundTaskId);

        CurrPage.EnqueueBackgroundTask(BackgroundTaskId, Codeunit::"Nemhandel Status Page Bckgrnd", InputParams);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetCompanyStatusSalesMgrActivitBckgrndTask(var CompanyStatus: Enum "Nemhandel Company Status")
    begin
    end;
}