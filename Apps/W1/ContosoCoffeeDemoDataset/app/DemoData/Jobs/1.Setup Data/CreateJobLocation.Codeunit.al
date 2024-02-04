codeunit 5196 "Create Job Location"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        JobsModuleSetup: Record "Jobs Module Setup";
        CommonLocation: Codeunit "Create Common Location";
    begin
        JobsModuleSetup.Get();

        if JobsModuleSetup."Job Location" = '' then
            JobsModuleSetup.Validate("Job Location", CommonLocation.MainLocation());

        JobsModuleSetup.Modify(true);
    end;
}