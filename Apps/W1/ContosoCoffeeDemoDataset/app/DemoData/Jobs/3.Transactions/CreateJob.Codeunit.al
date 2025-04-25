// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Jobs;

using Microsoft.Projects.Project.Job;
using Microsoft.DemoTool.Helpers;
using Microsoft.Projects.Project.Planning;

codeunit 5190 "Create Job"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        FixRateJobNameLbl: Label 'Installation of S-200 Semi-Automatic', MaxLength = 100;
        FixRateJobPhase1DescriptionLbl: Label 'Phase 1 - Planning and specs', MaxLength = 100;
        PreInstallationTaskDescriptionLbl: Label 'Pre-installation requirements', MaxLength = 100;
        FixRateJobChecklistDescriptionLbl: Label 'Check-list:', MaxLength = 100;
        FixRateJobSpaceRequirementDescriptionLbl: Label '* Space constraints', MaxLength = 100;
        FixRateJobWaterRequirementDescriptionLbl: Label '* Water quality, inlet, drain out', MaxLength = 100;
        FixRateJobElectricalRequirementDescriptionLbl: Label '* Electrical requirements', MaxLength = 100;
        FixRateJobPhase1TotalDescriptionLbl: Label 'Phase 1 - Total', MaxLength = 100;
        FixRateJobPhase2DescriptionLbl: Label 'Phase 2 - Installation', MaxLength = 100;
        FixRateJobDeliveryTaskDescriptionLbl: Label 'Delivery', MaxLength = 100;
        FixRateJobInstallationTaskLbl: Label 'Installation', MaxLength = 100;
        FixRateJobConfigurationTaskTok: Label 'Configuration', MaxLength = 100;
        FixRateJobPhase2TotalDescriptionLbl: Label 'Phase 2 - Total', MaxLength = 100;
        RecurringJobNameLbl: Label 'Supplies and maintenance of S-200 Semi-Automatic', MaxLength = 100;
        RecurringTaskMonthlyDescriptionLbl: Label 'Monthly maintenance', MaxLength = 100;
        RecurringTaskAnnuallyDescriptionLbl: Label 'Annual maintenance', MaxLength = 100;
        WIPJobNameLbl: Label 'Software update', MaxLength = 100;

    trigger OnRun()
    begin
        CreateFixRateJob();
        CreateRecurringJob();
        CreateWIPJob();
    end;

    local procedure CreateFixRateJob()
    var
        JobsModuleSetup: Record "Jobs Module Setup";
        FixedRateJob: Record Job;
        ContosoJob: Codeunit "Contoso Job";
        JobTaskIndent: Codeunit "Job Task-Indent";
    begin
        JobsModuleSetup.Get();

        FixedRateJob := ContosoJob.InsertJob(FixRateJobNameLbl, JobsModuleSetup."Customer No.", FixRateJobExternalDocumentNo());

        ContosoJob.InsertJobTask(FixedRateJob."No.", '100', FixRateJobPhase1DescriptionLbl, Enum::"Job Task Type"::"Begin-Total");
        ContosoJob.InsertJobTask(FixedRateJob."No.", FixRateJobPreInstallTask(), PreInstallationTaskDescriptionLbl, Enum::"Job Task Type"::"Posting");
        ContosoJob.InsertJobPlanningLine(FixedRateJob."No.", FixRateJobPreInstallTask(), Enum::"Job Planning Line Line Type"::Budget, Enum::"Job Planning Line Type"::Resource, JobsModuleSetup."Resource Installer No.", 3, '', JobsModuleSetup."Job Location");
        ContosoJob.InsertJobPlanningLine(FixedRateJob."No.", FixRateJobPreInstallTask(), Enum::"Job Planning Line Line Type"::Billable, Enum::"Job Planning Line Type"::Item, JobsModuleSetup."Item Service No.", 3, PreInstallationTaskDescriptionLbl, JobsModuleSetup."Job Location");
        ContosoJob.InsertJobPlanningLine(FixedRateJob."No.", FixRateJobPreInstallTask(), Enum::"Job Planning Line Line Type"::Billable, FixRateJobChecklistDescriptionLbl);
        ContosoJob.InsertJobPlanningLine(FixedRateJob."No.", FixRateJobPreInstallTask(), Enum::"Job Planning Line Line Type"::Billable, FixRateJobSpaceRequirementDescriptionLbl);
        ContosoJob.InsertJobPlanningLine(FixedRateJob."No.", FixRateJobPreInstallTask(), Enum::"Job Planning Line Line Type"::Billable, FixRateJobWaterRequirementDescriptionLbl);
        ContosoJob.InsertJobPlanningLine(FixedRateJob."No.", FixRateJobPreInstallTask(), Enum::"Job Planning Line Line Type"::Billable, FixRateJobElectricalRequirementDescriptionLbl);
        ContosoJob.InsertJobTask(FixedRateJob."No.", '199', FixRateJobPhase1TotalDescriptionLbl, Enum::"Job Task Type"::"End-Total");

        ContosoJob.InsertJobTask(FixedRateJob."No.", '200', FixRateJobPhase2DescriptionLbl, Enum::"Job Task Type"::"Begin-Total");
        ContosoJob.InsertJobTask(FixedRateJob."No.", FixRateJobDeliveryTask(), FixRateJobDeliveryTaskDescriptionLbl, Enum::"Job Task Type"::"Posting");
        ContosoJob.InsertJobPlanningLine(FixedRateJob."No.", FixRateJobDeliveryTask(), Enum::"Job Planning Line Line Type"::"Both Budget and Billable", Enum::"Job Planning Line Type"::Item, JobsModuleSetup."Item Machine No.", 1, '', JobsModuleSetup."Job Location");

        ContosoJob.InsertJobTask(FixedRateJob."No.", FixRateJobInstallationTask(), FixRateJobInstallationTaskLbl, Enum::"Job Task Type"::"Posting");
        ContosoJob.InsertJobPlanningLine(FixedRateJob."No.", FixRateJobInstallationTask(), Enum::"Job Planning Line Line Type"::Budget, Enum::"Job Planning Line Type"::Resource, JobsModuleSetup."Resource Installer No.", 3, '', JobsModuleSetup."Job Location");
        ContosoJob.InsertJobPlanningLine(FixedRateJob."No.", FixRateJobInstallationTask(), Enum::"Job Planning Line Line Type"::Billable, Enum::"Job Planning Line Type"::Item, JobsModuleSetup."Item Service No.", 2, FixRateJobInstallationTaskLbl, JobsModuleSetup."Job Location");
        ContosoJob.InsertJobPlanningLine(FixedRateJob."No.", FixRateJobInstallationTask(), Enum::"Job Planning Line Line Type"::Budget, Enum::"Job Planning Line Type"::Item, JobsModuleSetup."Item Consumable No.", 1, '', JobsModuleSetup."Job Location");

        ContosoJob.InsertJobTask(FixedRateJob."No.", FixRateJobConfigurationTask(), FixRateJobConfigurationTaskTok, Enum::"Job Task Type"::"Posting");
        ContosoJob.InsertJobPlanningLine(FixedRateJob."No.", FixRateJobConfigurationTask(), Enum::"Job Planning Line Line Type"::Budget, Enum::"Job Planning Line Type"::Resource, JobsModuleSetup."Resource Installer No.", 1, '', JobsModuleSetup."Job Location");
        ContosoJob.InsertJobPlanningLine(FixedRateJob."No.", FixRateJobConfigurationTask(), Enum::"Job Planning Line Line Type"::Billable, Enum::"Job Planning Line Type"::Item, JobsModuleSetup."Item Service No.", 2, FixRateJobConfigurationTaskTok, JobsModuleSetup."Job Location");

        ContosoJob.InsertJobTask(FixedRateJob."No.", '299', FixRateJobPhase2TotalDescriptionLbl, Enum::"Job Task Type"::"End-Total");

        JobTaskIndent.Indent(FixedRateJob."No.");
    end;

    local procedure CreateWIPJob()
    var
        JobsModuleSetup: Record "Jobs Module Setup";
        WIPJob: Record Job;
        ContosoJob: Codeunit "Contoso Job";
    begin
        JobsModuleSetup.Get();

        WIPJob := ContosoJob.InsertJob(WIPJobNameLbl, JobsModuleSetup."Customer No.", WIPJobExternalDocumentNo());
        ContosoJob.InsertJobTask(WIPJob."No.", WIPJobSoftUpdateTask(), WIPJobNameLbl, Enum::"Job Task Type"::"Posting");
        ContosoJob.InsertJobPlanningLine(WIPJob."No.", WIPJobSoftUpdateTask(), Enum::"Job Planning Line Line Type"::Budget, Enum::"Job Planning Line Type"::Resource, JobsModuleSetup."Resource Installer No.", 12, '', JobsModuleSetup."Job Location");
        ContosoJob.InsertJobPlanningLine(WIPJob."No.", WIPJobSoftUpdateTask(), Enum::"Job Planning Line Line Type"::Billable, Enum::"Job Planning Line Type"::Item, JobsModuleSetup."Item Service No.", 12, WIPJobNameLbl, JobsModuleSetup."Job Location");
    end;

    local procedure CreateRecurringJob()
    var
        JobsModuleSetup: Record "Jobs Module Setup";
        RecurringJob: Record Job;
        ContosoJob: Codeunit "Contoso Job";
    begin
        JobsModuleSetup.Get();

        RecurringJob := ContosoJob.InsertJob(RecurringJobNameLbl, JobsModuleSetup."Customer No.", RecurringJobExternalDocumentNo());
        ContosoJob.InsertJobTask(RecurringJob."No.", '1000', RecurringTaskMonthlyDescriptionLbl, Enum::"Job Task Type"::"Posting");
        ContosoJob.InsertJobTask(RecurringJob."No.", '3000', RecurringTaskAnnuallyDescriptionLbl, Enum::"Job Task Type"::"Posting");
    end;

    procedure FixRateJobExternalDocumentNo(): Code[20]
    begin
        exit('F-1');
    end;

    procedure WIPJobExternalDocumentNo(): Code[20]
    begin
        exit('W-2');
    end;

    procedure RecurringJobExternalDocumentNo(): Code[20]
    begin
        exit('R-3');
    end;

    procedure FixRateJobPreInstallTask(): Code[20]
    begin
        exit('110');
    end;

    procedure FixRateJobDeliveryTask(): Code[20]
    begin
        exit('220');
    end;

    procedure FixRateJobInstallationTask(): Code[20]
    begin
        exit('240');
    end;

    procedure FixRateJobConfigurationTask(): Code[20]
    begin
        exit('260');
    end;

    procedure WIPJobSoftUpdateTask(): Code[20]
    begin
        exit('110');
    end;
}
