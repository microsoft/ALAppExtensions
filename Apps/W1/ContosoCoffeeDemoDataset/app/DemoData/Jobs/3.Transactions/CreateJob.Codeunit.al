codeunit 5190 "Create Job"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        FixedRateJobTok: Label 'Fix Rate Job', MaxLength = 20;
        FixRateJobNameLbl: Label 'Installation of S-100 Semi-Automatic', MaxLength = 100;
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
        RecurringJobTok: Label 'Recurring Job', MaxLength = 20;
        RecurringJobNameLbl: Label 'Supplies and maintenance of S-100 Semi-Automatic', MaxLength = 100;
        RecurringTaskMonthlyDescriptionLbl: Label 'Phase 1 - Planning and specs', MaxLength = 100;
        RecurringTaskAnnuallyDescriptionLbl: Label 'Pre-installation requirements', MaxLength = 100;
        WIPJobTok: Label 'WIP Job', MaxLength = 20;
        WIPJobNameLbl: Label 'Software update', MaxLength = 100;

    trigger OnRun()
    begin
        CreateFixRateJob();
        CreateRecurringJob();
        CreateWIPJob();
    end;

    procedure CreateFixRateJob()
    var
        JobsModuleSetup: Record "Jobs Module Setup";
        ContosoJob: Codeunit "Contoso Job";
        JobTaskIndent: Codeunit "Job Task-Indent";
    begin
        JobsModuleSetup.Get();

        ContosoJob.InsertJob(FixRateJob(), FixRateJobNameLbl, JobsModuleSetup."Customer No.", 'F-1');

        ContosoJob.InsertJobTask(FixRateJob(), '100', FixRateJobPhase1DescriptionLbl, Enum::"Job Task Type"::"Begin-Total");
        ContosoJob.InsertJobTask(FixRateJob(), FixRateJobPreInstallTask(), PreInstallationTaskDescriptionLbl, Enum::"Job Task Type"::"Posting");
        ContosoJob.InsertJobPlanningLine(FixRateJob(), FixRateJobPreInstallTask(), Enum::"Job Planning Line Line Type"::Budget, Enum::"Job Planning Line Type"::Resource, JobsModuleSetup."Resource Installer No.", 3, '', JobsModuleSetup."Job Location");
        ContosoJob.InsertJobPlanningLine(FixRateJob(), FixRateJobPreInstallTask(), Enum::"Job Planning Line Line Type"::Billable, Enum::"Job Planning Line Type"::Item, JobsModuleSetup."Item Service No.", 3, PreInstallationTaskDescriptionLbl, JobsModuleSetup."Job Location");
        ContosoJob.InsertJobPlanningLine(FixRateJob(), FixRateJobPreInstallTask(), Enum::"Job Planning Line Line Type"::Billable, FixRateJobChecklistDescriptionLbl);
        ContosoJob.InsertJobPlanningLine(FixRateJob(), FixRateJobPreInstallTask(), Enum::"Job Planning Line Line Type"::Billable, FixRateJobSpaceRequirementDescriptionLbl);
        ContosoJob.InsertJobPlanningLine(FixRateJob(), FixRateJobPreInstallTask(), Enum::"Job Planning Line Line Type"::Billable, FixRateJobWaterRequirementDescriptionLbl);
        ContosoJob.InsertJobPlanningLine(FixRateJob(), FixRateJobPreInstallTask(), Enum::"Job Planning Line Line Type"::Billable, FixRateJobElectricalRequirementDescriptionLbl);
        ContosoJob.InsertJobTask(FixRateJob(), '199', FixRateJobPhase1TotalDescriptionLbl, Enum::"Job Task Type"::"End-Total");

        ContosoJob.InsertJobTask(FixRateJob(), '200', FixRateJobPhase2DescriptionLbl, Enum::"Job Task Type"::"Begin-Total");
        ContosoJob.InsertJobTask(FixRateJob(), FixRateJobDeliveryTask(), FixRateJobDeliveryTaskDescriptionLbl, Enum::"Job Task Type"::"Posting");
        ContosoJob.InsertJobPlanningLine(FixRateJob(), FixRateJobDeliveryTask(), Enum::"Job Planning Line Line Type"::"Both Budget and Billable", Enum::"Job Planning Line Type"::Item, JobsModuleSetup."Item Machine No.", 1, '', JobsModuleSetup."Job Location");

        ContosoJob.InsertJobTask(FixRateJob(), FixRateJobInstallationTask(), FixRateJobInstallationTaskLbl, Enum::"Job Task Type"::"Posting");
        ContosoJob.InsertJobPlanningLine(FixRateJob(), FixRateJobInstallationTask(), Enum::"Job Planning Line Line Type"::Budget, Enum::"Job Planning Line Type"::Resource, JobsModuleSetup."Resource Installer No.", 3, '', JobsModuleSetup."Job Location");
        ContosoJob.InsertJobPlanningLine(FixRateJob(), FixRateJobInstallationTask(), Enum::"Job Planning Line Line Type"::Billable, Enum::"Job Planning Line Type"::Item, JobsModuleSetup."Item Service No.", 2, FixRateJobInstallationTaskLbl, JobsModuleSetup."Job Location");
        ContosoJob.InsertJobPlanningLine(FixRateJob(), FixRateJobInstallationTask(), Enum::"Job Planning Line Line Type"::Budget, Enum::"Job Planning Line Type"::Item, JobsModuleSetup."Item Consumable No.", 1, '', JobsModuleSetup."Job Location");

        ContosoJob.InsertJobTask(FixRateJob(), FixRateJobConfigurationTask(), FixRateJobConfigurationTaskTok, Enum::"Job Task Type"::"Posting");
        ContosoJob.InsertJobPlanningLine(FixRateJob(), FixRateJobConfigurationTask(), Enum::"Job Planning Line Line Type"::Budget, Enum::"Job Planning Line Type"::Resource, JobsModuleSetup."Resource Installer No.", 1, '', JobsModuleSetup."Job Location");
        ContosoJob.InsertJobPlanningLine(FixRateJob(), FixRateJobConfigurationTask(), Enum::"Job Planning Line Line Type"::Billable, Enum::"Job Planning Line Type"::Item, JobsModuleSetup."Item Service No.", 2, FixRateJobConfigurationTaskTok, JobsModuleSetup."Job Location");

        ContosoJob.InsertJobTask(FixRateJob(), '299', FixRateJobPhase2TotalDescriptionLbl, Enum::"Job Task Type"::"End-Total");

        JobTaskIndent.Indent(FixRateJob());
    end;

    procedure CreateWIPJob()
    var
        JobsModuleSetup: Record "Jobs Module Setup";
        ContosoJob: Codeunit "Contoso Job";
    begin
        JobsModuleSetup.Get();

        ContosoJob.InsertJob(WIPJob(), WIPJobNameLbl, JobsModuleSetup."Customer No.", 'W-2');
        ContosoJob.InsertJobTask(WIPJob(), WIPJobSoftUpdateTask(), WIPJobNameLbl, Enum::"Job Task Type"::"Posting");
        ContosoJob.InsertJobPlanningLine(WIPJob(), WIPJobSoftUpdateTask(), Enum::"Job Planning Line Line Type"::Budget, Enum::"Job Planning Line Type"::Resource, JobsModuleSetup."Resource Installer No.", 12, '', JobsModuleSetup."Job Location");
        ContosoJob.InsertJobPlanningLine(WIPJob(), WIPJobSoftUpdateTask(), Enum::"Job Planning Line Line Type"::Billable, Enum::"Job Planning Line Type"::Item, JobsModuleSetup."Item Service No.", 12, WIPJobNameLbl, JobsModuleSetup."Job Location");
    end;

    procedure CreateRecurringJob()
    var
        JobsModuleSetup: Record "Jobs Module Setup";
        ContosoJob: Codeunit "Contoso Job";
    begin
        JobsModuleSetup.Get();

        ContosoJob.InsertJob(RecurringJob(), RecurringJobNameLbl, JobsModuleSetup."Customer No.", 'R-3');
        ContosoJob.InsertJobTask(RecurringJob(), '1000', RecurringTaskMonthlyDescriptionLbl, Enum::"Job Task Type"::"Posting");
        ContosoJob.InsertJobTask(RecurringJob(), '3000', RecurringTaskAnnuallyDescriptionLbl, Enum::"Job Task Type"::"Posting");
    end;

    procedure FixRateJob(): Code[20]
    begin
        exit(FixedRateJobTok);
    end;

    procedure WIPJob(): Code[20]
    begin
        exit(WIPJobTok);
    end;

    procedure RecurringJob(): Code[20]
    begin
        exit(RecurringJobTok);
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