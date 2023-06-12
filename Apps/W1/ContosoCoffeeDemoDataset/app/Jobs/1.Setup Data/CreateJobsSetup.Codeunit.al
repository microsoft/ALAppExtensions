codeunit 5113 "Create Jobs Setup"
{
    Permissions = tabledata "Jobs Setup" = rim,
        tabledata "No. Series" = rim,
        tabledata "No. Series Line" = rim;

    var
        JobsDemoAccount: Record "Jobs Demo Account";
        JobsDemoDataSetup: Record "Jobs Demo Data Setup";
        JobsDemoAccounts: Codeunit "Jobs Demo Accounts";
        JobsNosTok: Label 'JOBS', MaxLength = 20;
        JobNosDescTok: Label 'Jobs', MaxLength = 100;
        JobNosStartTok: Label 'J00020', MaxLength = 20;
        JobNosEndTok: Label 'J99999', MaxLength = 20;
        JobPostingGroupTok: Label 'Setting up', MaxLength = 50;

    trigger OnRun()
    begin
        JobsDemoDataSetup.Get();

        CreateJobsSetup(JobsNosTok);
        CreateJobsGLAccounts();

        CreateJobPostingGroup();
    end;

    local procedure CreateJobsSetup(JobNos: Code[20])
    var
        JobsSetup: Record "Jobs Setup";
        IsHandled: Boolean;
    begin
        if not JobsSetup.Get() then begin
            JobsSetup.Init();
            JobsSetup.Insert(true);
        end;
        OnBeforePopulateJobsSetupFields(JobsSetup, IsHandled);
        if IsHandled then
            exit;
        JobsSetup."Job Nos." := CheckNoSeriesSetup(JobsSetup."Job Nos.", JobNos, JobNosDescTok, JobNosStartTok, JobNosEndTok);
        JobsSetup."Apply Usage Link by Default" := true;
        JobsSetup."Allow Sched/Contract Lines Def" := true;
        JobsSetup."Document No. Is Job No." := true;
        JobsSetup.Modify(true);
    end;

    local procedure CheckNoSeriesSetup(CurrentSetupField: Code[20]; NumberSeriesCode: Code[20]; SeriesDescription: Text[100]; StartNo: Code[20]; EndNo: Code[20]): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if CurrentSetupField <> '' then
            exit(CurrentSetupField);

        OnBeforeConfirmNoSeriesExists(NumberSeriesCode);
        if not NoSeries.Get(NumberSeriesCode) then begin
            NoSeries.Init();
            NoSeries.Code := NumberSeriesCode;
            NoSeries.Description := SeriesDescription;
            NoSeries."Manual Nos." := true;
            NoSeries.Validate("Default Nos.", true);
            OnBeforeInsertNoSeries(NoSeries);
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := NumberSeriesCode;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine.Insert(true);
            NoSeriesLine.Validate("Starting No.", StartNo);
            NoSeriesLine.Validate("Ending No.", EndNo);
            NoSeriesLine.Validate("Increment-by No.", 10);
            NoSeriesLine.Validate("Allow Gaps in Nos.", true);
            OnBeforeModifyNoSeriesLine(NoSeries, NoSeriesLine);
            NoSeriesLine.Modify(true);
        end;

        exit(NumberSeriesCode);
    end;


    local procedure CreateJobsGLAccounts()
    var
        GLAccountIndent: Codeunit "G/L Account-Indent";
    begin
        JobsDemoAccount.ReturnAccountKey(true);

        InsertGLAccount(JobsDemoAccount.WIPCosts(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Balance Sheet");
        InsertGLAccount(JobsDemoAccount.WIPAccruedCosts(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Balance Sheet");
        InsertGLAccount(JobsDemoAccount.JobCostsApplied(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement");
        InsertGLAccount(JobsDemoAccount.ItemCostsApplied(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement");
        InsertGLAccount(JobsDemoAccount.ResourceCostsApplied(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement");
        InsertGLAccount(JobsDemoAccount.GLCostsApplied(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement");
        InsertGLAccount(JobsDemoAccount.JobCostsAdjustment(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement");
        InsertGLAccount(JobsDemoAccount.GLExpense(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement");
        InsertGLAccount(JobsDemoAccount.WIPAccruedSales(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Balance Sheet");
        InsertGLAccount(JobsDemoAccount.WIPInvoicedSales(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Balance Sheet");
        InsertGLAccount(JobsDemoAccount.JobSalesApplied(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement");
        InsertGLAccount(JobsDemoAccount.JobSalesAdjustment(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement");
        InsertGLAccount(JobsDemoAccount.RecognizedCosts(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement");
        InsertGLAccount(JobsDemoAccount.RecognizedSales(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement");

        JobsDemoAccount.ReturnAccountKey(false);
        GLAccountIndent.Indent();
    end;

    local procedure InsertGLAccount("No.": Code[20]; AccountType: Enum "G/L Account Type"; "Income/Balance": Enum "G/L Account Income/Balance")
    var
        GLAccount: Record "G/L Account";
    begin
        JobsDemoAccount := JobsDemoAccounts.GetDemoAccount("No.");

        if GLAccount.Get(JobsDemoAccount."Account Value") then
            exit;

        GLAccount.Init();
        GLAccount.Validate("No.", JobsDemoAccount."Account Value");
        GLAccount.Validate(Name, JobsDemoAccount."Account Description");
        GLAccount.Validate("Account Type", AccountType);
        GLAccount.Validate("Income/Balance", "Income/Balance");
        GLAccount.Insert(true);
    end;

    local procedure CreateJobPostingGroup()
    var
        JobPostingGroup: Record "Job Posting Group";
    begin
        if JobPostingGroup.Get(JobsDemoDataSetup."Job Posting Group") then
            exit;

        JobsDemoAccount.ReturnAccountKey(false);

        JobPostingGroup.Init();
        JobPostingGroup.Validate("Code", JobsDemoDataSetup."Job Posting Group");
        JobPostingGroup.Validate("Description", JobPostingGroupTok);
        JobPostingGroup.Validate("WIP Costs Account", JobsDemoAccount.WIPCosts());
        JobPostingGroup.Validate("WIP Accrued Costs Account", JobsDemoAccount.WIPAccruedCosts());
        JobPostingGroup.Validate("Job Costs Applied Account", JobsDemoAccount.JobCostsApplied());
        JobPostingGroup.Validate("Item Costs Applied Account", JobsDemoAccount.ItemCostsApplied());
        JobPostingGroup.Validate("Resource Costs Applied Account", JobsDemoAccount.ResourceCostsApplied());
        JobPostingGroup.Validate("G/L Costs Applied Account", JobsDemoAccount.GLCostsApplied());
        JobPostingGroup.Validate("Job Costs Adjustment Account", JobsDemoAccount.JobCostsAdjustment());
        JobPostingGroup.Validate("G/L Expense Acc. (Contract)", JobsDemoAccount.GLExpense());
        JobPostingGroup.Validate("WIP Accrued Sales Account", JobsDemoAccount.WIPAccruedSales());
        JobPostingGroup.Validate("WIP Invoiced Sales Account", JobsDemoAccount.WIPInvoicedSales());
        JobPostingGroup.Validate("Job Sales Applied Account", JobsDemoAccount.JobSalesApplied());
        JobPostingGroup.Validate("Job Sales Adjustment Account", JobsDemoAccount.JobSalesAdjustment());
        JobPostingGroup.Validate("Recognized Costs Account", JobsDemoAccount.RecognizedCosts());
        JobPostingGroup.Validate("Recognized Sales Account", JobsDemoAccount.RecognizedSales());
        OnBeforeInsertJobPostingGroup(JobPostingGroup);
        JobPostingGroup.Insert(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmNoSeriesExists(var NumberSeriesCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertNoSeries(var NoSeries: Record "No. Series")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyNoSeriesLine(var NoSeries: Record "No. Series"; var NoSeriesLine: Record "No. Series Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePopulateJobsSetupFields(var JobsSetup: Record "Jobs Setup"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertJobPostingGroup(JobPostingGroup: Record "Job Posting Group")
    begin
    end;
}