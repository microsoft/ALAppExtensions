codeunit 5194 "Create Job Posting Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        JobsDemoDataSetup: Record "Jobs Module Setup";
        ContosoJob: Codeunit "Contoso Job";
        JobGLAccount: Codeunit "Create Job GL Account";
    begin
        JobsDemoDataSetup.Get();

        if JobsDemoDataSetup."Job Posting Group" = '' then begin
            ContosoJob.InsertJopPostingGroup(DefaultJobPostingGroup(), SettingUpDescriptionLbl, JobGLAccount.WIPJobCosts(), JobGLAccount.WIPJobCosts(), JobGLAccount.JobCostsApplied(), JobGLAccount.JobCostsApplied(), JobGLAccount.WIPInvoicedSales(), JobGLAccount.WIPInvoicedSales(), JobGLAccount.JobSalesApplied(), JobGLAccount.JobSalesApplied(), JobGLAccount.RecognizedCosts(), JobGLAccount.RecognizedCosts());
            JobsDemoDataSetup.Validate("Job Posting Group", DefaultJobPostingGroup());
        end;

        JobsDemoDataSetup.Modify(true);
    end;

    var
        SettingUpTok: Label 'Setting up', MaxLength = 20;
        SettingUpDescriptionLbl: Label 'Setting up', MaxLength = 100;

    procedure DefaultJobPostingGroup(): Code[20]
    begin
        exit(SettingUpTok);
    end;
}