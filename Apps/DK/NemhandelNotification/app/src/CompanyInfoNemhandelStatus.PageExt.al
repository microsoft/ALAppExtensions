namespace Microsoft.EServices;

using Microsoft.Foundation.Company;
using Microsoft.Utilities;

pageextension 13608 "Company Info. Nemhandel Status" extends "Company Information"
{
    layout
    {
        modify("Registration No.")
        {
            Editable = Rec."Registered with Nemhandel" <> "Nemhandel Company Status"::Registered;
            ToolTip = 'Specifies the company''s CVR number. Once the CVR number that is registered in Nemhandelsregisteret is set, it cannot changed.';

            trigger OnAfterValidate()
            var
                InputParams: Dictionary of [Text, Text];
            begin
#if not CLEAN24
                if not NemhandelStatusMgt.IsFeatureEnableDatePassed() then
                    exit;
#endif
                if Rec."Registered with Nemhandel" = "Nemhandel Company Status"::Registered then
                    exit;

                InputParams.Add(NemhandelStatusPageBckgrnd.GetCVRNumberKey(), Rec."Registration No.");
                RunGetCompanyStatusBackgroundTask(InputParams);
            end;
        }
    }

    var
        NemhandelStatusPageBckgrnd: Codeunit "Nemhandel Status Page Bckgrnd";
        NemhandelStatusMgt: Codeunit "Nemhandel Status Mgt.";
        BackgroundTaskId: Integer;
        PageBckGrndTaskCompletedTxt: Label 'Company Information Page Background Task to check Nemhandel registration status completed. Status: %1; status text: %2', Comment = '%1, %2 - Registered/NotRegisted/Unknown', Locked = true;
        NemhandelsregisteretCategoryTxt: Label 'Nemhandelsregisteret', Locked = true;
        NemhandelPageBackgroundTaskTxt: Label 'Nemhandel Page Background Task';
        NemhandelCheckCompanyStatusTxt: Label 'Nemhandel Check Company Status';

    trigger OnAfterGetCurrRecord()
    var
        InputParams: Dictionary of [Text, Text];
    begin
#if not CLEAN24
        if not NemhandelStatusMgt.IsFeatureEnableDatePassed() then
            exit;
#endif
        if NemhandelStatusMgt.IsNemhandelStatusCheckRequired(Rec) then begin
            InputParams.Add(NemhandelStatusPageBckgrnd.GetCVRNumberKey(), Rec."Registration No.");
            RunGetCompanyStatusBackgroundTask(InputParams);
        end;

        // even if background task was not run, show notification if company is not registered
        if BackgroundTaskId = 0 then
            NemhandelStatusMgt.ManageNotRegisteredNotification(Rec."Registered with Nemhandel");
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
                OnAfterGetCompanyStatusCompanyInfoBckgrndTask(CompanyStatus);

                Rec."Registered with Nemhandel" := CompanyStatus;
                Rec."Last Nemhandel Status Check DT" := CurrentDateTime();
                Rec.Modify();
            end;

        NemhandelStatusMgt.ManageNotRegisteredNotification(Rec."Registered with Nemhandel");

        Session.LogMessage(
            '0000KXY', StrSubstNo(PageBckGrndTaskCompletedTxt, CompanyStatus, CompanyStatusTextValue), Verbosity::Normal,
            DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', NemhandelsregisteretCategoryTxt);
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
    local procedure OnAfterGetCompanyStatusCompanyInfoBckgrndTask(var CompanyStatus: Enum "Nemhandel Company Status")
    begin
    end;
}