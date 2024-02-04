codeunit 5210 "Create Job Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Jobs Setup" = rim;

    trigger OnRun()
    var
        JobsSetup: Record "Jobs Setup";
        JobsDemoDataSetup: Record "Jobs Module Setup";
        JobNoSeries: Codeunit "Create Job No Series";
    begin
        if not JobsSetup.Get() then begin
            JobsSetup.Init();
            JobsSetup.Insert(true);
        end;

        JobsDemoDataSetup.Get();

        if JobsSetup."Job Nos." = '' then
            JobsSetup.Validate("Job Nos.", JobNoSeries.Job());

        JobsSetup.Validate("Apply Usage Link by Default", true);
        JobsSetup.Validate("Allow Sched/Contract Lines Def", true);
        JobsSetup.Validate("Document No. Is Job No.", true);
        JobsSetup.Validate("Automatic Update Job Item Cost", true);
        JobsSetup.Validate("Default WIP Posting Method", JobsSetup."Default WIP Posting Method"::"Per Job");
        JobsSetup.Validate("Default Job Posting Group", JobsDemoDataSetup."Job Posting Group");
        JobsSetup.Modify(true);
    end;
}