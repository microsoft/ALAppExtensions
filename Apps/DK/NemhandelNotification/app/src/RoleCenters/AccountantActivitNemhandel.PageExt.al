namespace Microsoft.EServices;

using Microsoft.Finance.RoleCenters;
using Microsoft.Foundation.Company;
using Microsoft.Utilities;

pageextension 13628 "Accountant Activit. Nemhandel" extends "Accountant Activities"
{
    // this page is a part of page 9027 Accountant Role Center

    trigger OnAfterGetCurrRecord()
    var
        CompanyInformation: Record "Company Information";
        InputParams: Dictionary of [Text, Text];
    begin
#if not CLEAN24
        if not NemhandelStatusMgt.IsFeatureEnableDatePassed() then
            exit;
#endif
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
        CompanyStatusTextValue: Text;
        CompanyStatus: Enum "Nemhandel Company Status";
    begin
        if TaskId <> BackgroundTaskId then
            exit;
        if Results.Count() = 0 then
            exit;

        if Results.Get(NemhandelStatusPageBckgrnd.GetStatusKey(), CompanyStatusTextValue) then
            if Evaluate(CompanyStatus, CompanyStatusTextValue) then begin
                OnAfterGetCompanyStatusAccountantActivitBckgrndTask(CompanyStatus);
                NemhandelStatusMgt.UpdateRegisteredWithNemhandel(CompanyStatus);
            end;

        NemhandelStatusMgt.ManageNotRegisteredNotification(CompanyStatus);

        Session.LogMessage(
            '0000LB6', StrSubstNo(PageBckGrndTaskCompletedTxt, CompanyStatus, CompanyStatusTextValue), Verbosity::Normal,
            DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', NemhandelsregisteretCategoryTxt);
        ActivityLog.LogActivity(
            Rec.RecordId(), ActivityLog.Status::Success, NemhandelPageBackgroundTaskTxt, NemhandelCheckCompanyStatusTxt,
            StrSubstNo(PageBckGrndTaskCompletedTxt, CompanyStatus, CompanyStatusTextValue));
    end;

    var
        NemhandelStatusPageBckgrnd: Codeunit "Nemhandel Status Page Bckgrnd";
        NemhandelStatusMgt: Codeunit "Nemhandel Status Mgt.";
        BackgroundTaskId: Integer;
        PageBckGrndTaskCompletedTxt: Label 'Accountant Activities Page Background Task to check Nemhandel registration status completed. Status: %1; status text: %2', Comment = '%1, %2 - Registered/NotRegisted/Unknown', Locked = true;
        NemhandelsregisteretCategoryTxt: Label 'Nemhandelsregisteret', Locked = true;
        NemhandelPageBackgroundTaskTxt: Label 'Nemhandel Page Background Task';
        NemhandelCheckCompanyStatusTxt: Label 'Nemhandel Check Company Status';

    local procedure RunGetCompanyStatusBackgroundTask(InputParams: Dictionary of [Text, Text])
    begin
        if BackgroundTaskId <> 0 then
            CurrPage.CancelBackgroundTask(BackgroundTaskId);

        CurrPage.EnqueueBackgroundTask(BackgroundTaskId, Codeunit::"Nemhandel Status Page Bckgrnd", InputParams);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetCompanyStatusAccountantActivitBckgrndTask(var CompanyStatus: Enum "Nemhandel Company Status")
    begin
    end;
}