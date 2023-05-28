codeunit 5113 "Create Jobs Setup"
{
    Permissions = tabledata "Jobs Setup" = rim,
        tabledata "No. Series" = rim,
        tabledata "No. Series Line" = rim;

    var
        JobsDemoAccount: Record "Jobs Demo Account";
        JobsDemoDataSetup: Record "Jobs Demo Data Setup";
        JobsDemoAccounts: Codeunit "Jobs Demo Accounts";
        DoRunTriggers: Boolean;
        JobsNosTok: Label 'JOBS', MaxLength = 20;
        JobNosDescTok: Label 'Jobs', MaxLength = 100;
        JobNosStartTok: Label 'J00020', MaxLength = 20;
        JobNosEndTok: Label 'J99999', MaxLength = 20;

    trigger OnRun()
    begin
        DoRunTriggers := true;
        OnBeforeStartCreation(DoRunTriggers);
        JobsDemoDataSetup.Get();

        CreateJobsSetup(JobsNosTok);
        CreateServiceGLAccounts();
    end;

    local procedure CreateJobsSetup(JobNos: Code[20])
    var
        JobsSetup: Record "Jobs Setup";
        IsHandled: Boolean;
    begin
        if not JobsSetup.Get() then begin
            JobsSetup.Init();
            JobsSetup.Insert(DoRunTriggers);
        end;
        OnBeforePopulateJobsSetupFields(JobsSetup, IsHandled);
        if IsHandled then
            exit;
        JobsSetup."Job Nos." := CheckNoSeriesSetup(JobsSetup."Job Nos.", JobNos, JobNosDescTok, JobNosStartTok, JobNosEndTok);
        JobsSetup."Apply Usage Link by Default" := true;
        JobsSetup."Allow Sched/Contract Lines Def" := true;
        JobsSetup."Document No. Is Job No." := true;
        JobsSetup.Modify(DoRunTriggers);
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
            NoSeries.Insert(DoRunTriggers);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := NumberSeriesCode;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine.Insert(DoRunTriggers);
            NoSeriesLine.Validate("Starting No.", StartNo);
            NoSeriesLine.Validate("Ending No.", EndNo);
            NoSeriesLine.Validate("Increment-by No.", 10);
            NoSeriesLine.Validate("Allow Gaps in Nos.", true);
            OnBeforeModifyNoSeriesLine(NoSeries, NoSeriesLine);
            NoSeriesLine.Modify(true);
        end;

        exit(NumberSeriesCode);
    end;


    local procedure CreateServiceGLAccounts()
    var
        GLAccountIndent: Codeunit "G/L Account-Indent";
    begin
        JobsDemoAccount.ReturnAccountKey(true);

        // This function would be used by WIP scenarios to create the WIP G/L accounts


        JobsDemoAccount.ReturnAccountKey(false);
        GLAccountIndent.Indent();
    end;

    // This function would be used by WIP scenarios to create the WIP G/L accounts
#pragma warning disable AA0228
    local procedure InsertGLAccount("No.": Code[20]; AccountType: Enum "G/L Account Type"; "Income/Balance": Enum "G/L Account Income/Balance")
#pragma warning restore AA0228
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
        GLAccount.Insert(DoRunTriggers);
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
    local procedure OnBeforeStartCreation(var DoRunTriggers: Boolean)
    begin
    end;
}