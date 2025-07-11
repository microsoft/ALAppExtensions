// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN25
namespace Microsoft.Finance.VAT.Reporting;

using System.Environment;
using System.Environment.Configuration;
using System.Media;

codeunit 10038 "IRS Forms Feature"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        FeatureKeyIdTok: Label 'IRSForm', Locked = true;
        InstallFeatureNotificationMsg: Label 'The IRS Forms feature is not enabled. You can enable it in the Feature Management window.';
        DataTransferInProgressNotificationMsg: Label 'The IRS Forms feature is enabled, but the data transfer is in progress. Refresh the page (F5), or come back later.';
        AssistedSetupTxt: Label 'Set up a IRS Forms feature';
        AssistedSetupDescriptionTxt: Label 'Setup 1099 forms to transmit the tax data to the IRS in the United States';
        AssistedSetupHelpTxt: Label 'https://learn.microsoft.com/en-us/dynamics365/business-central/localfunctionality/unitedstates/set-up-use-irs1099-form', Locked = true;

    procedure IsEnabled() Result: Boolean
    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
    begin
        Result := FeatureManagementFacade.IsEnabled(FeatureKeyIdTok);
        OnAfterCheckFeatureEnabled(Result);
    end;

    procedure GetFeatureKeyId(): Text
    begin
        exit(FeatureKeyIdTok);
    end;

    procedure FeatureCanBeUsed(): Boolean
    var
        IRSFormsSetup: Record "IRS Forms Setup";
        FeatureNotification: Notification;
    begin
        IRSFormsSetup.InitSetup();
        if IsEnabled() and not IRSFormsSetup.DataTransferInProgress() then
            exit(true);
        FeatureNotification.Id := GetFeatureNotificationId();
        FeatureNotification.Recall();
        if IsEnabled() then
            FeatureNotification.Message := DataTransferInProgressNotificationMsg
        else
            FeatureNotification.Message := InstallFeatureNotificationMsg;
        FeatureNotification.Send();
        exit(false);
    end;

    procedure UpgradeFromBaseApplication()
    var
        IRSFormsSetup: Record "IRS Forms Setup";
    begin
        IRSFormsSetup.InitSetup();
        IRSFormsSetup.CheckIfDataTransferIsPossible();
        if IRSFormsSetup."Background Task" then begin
            ScheduleTask();
            exit;
        end;
        Codeunit.Run(Codeunit::"IRS 1099 Transfer From BaseApp");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Feature Management Facade", 'OnAfterFeatureEnableConfirmed', '', true, true)]
    local procedure OnAfterFeatureEnableConfirmed(var FeatureKey: Record "Feature Key")
    var
        IRSFormsGuide: Page "IRS Forms Guide";
    begin
        if FeatureKey.ID = GetFeatureKeyId() then begin
            Commit();
            if IRSFormsGuide.RunModal() = Action::OK then
                if not IRSFormsGuide.IsSetupCompleted() then
                    Error('');
        end;
    end;

    local procedure GetFeatureNotificationId(): Guid
    begin
        exit('0200065a-8efe-4c00-a68f-ea20fe41e4e3');
    end;

    local procedure ScheduleTask(): Boolean;
    var
        IRSFormsSetup: Record "IRS Forms Setup";
        DoNotScheduleTask: Boolean;
        TaskID: Guid;
    begin
        if not TaskScheduler.CanCreateTask() then
            exit(false);

        IRSFormsSetup.Get();
        if DoNotScheduleTask then
            IRSFormsSetup."Data Transfer Task ID" := TaskID
        else
            IRSFormsSetup."Data Transfer Task ID" :=
                CreateTask(IRSFormsSetup);
        IRSFormsSetup.Modify();
        exit(true);
    end;

    local procedure CreateTask(var IRSFormsSetup: Record "IRS Forms Setup") TaskId: Guid
    begin
        CancelTask(IRSFormsSetup);
        AdjustStartDateTime(IRSFormsSetup);
        TaskId :=
            TaskScheduler.CreateTask(
                Codeunit::"IRS 1099 Transfer From BaseApp", Codeunit::"IRS 1099 Trans. Error Handler",
                true, CompanyName(), IRSFormsSetup."Task Start Date/Time");
    end;

    procedure CancelTask(var IRSFormsSetup: Record "IRS Forms Setup")
    var
        ScheduledTask: Record "Scheduled Task";
    begin
        IRSFormsSetup.Get();
        if not IsNullGuid(IRSFormsSetup."Data Transfer Task ID") then begin
            if ScheduledTask.Get(IRSFormsSetup."Data Transfer Task ID") then
                TaskScheduler.CancelTask(IRSFormsSetup."Data Transfer Task ID");
            Clear(IRSFormsSetup."Data Transfer Task ID");
        end;
    end;

    procedure InsertAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
    begin
        GuidedExperience.InsertAssistedSetup(AssistedSetupTxt, CopyStr(AssistedSetupTxt, 1, 50), AssistedSetupDescriptionTxt, 5, ObjectType::Page, Page::"IRS Forms Guide", AssistedSetupGroup::FinancialReporting,
                                            '', VideoCategory::FinancialReporting, AssistedSetupHelpTxt);
    end;

    local procedure AdjustStartDateTime(var IRSFormsSetup: Record "IRS Forms Setup")
    var
        Delta: Duration;
    begin
        Delta := 500; // Time to update the status record before the task is started.
        if IRSFormsSetup."Task Start Date/Time" = 0DT then
            IRSFormsSetup."Task Start Date/Time" := CurrentDateTime() + Delta
        else
            if IRSFormsSetup."Task Start Date/Time" - CurrentDateTime() < Delta then
                IRSFormsSetup."Task Start Date/Time" := CurrentDateTime() + Delta;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', true, true)]
    local procedure InsertIntoAssistedSetup()
    begin
        if not IsEnabled() then
            exit;
        InsertAssistedSetup();
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
    end;

}
#endif
