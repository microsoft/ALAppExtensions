codeunit 4778 "Create Svc Location"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SvcDemoDataSetup: Record "Service Module Setup";
        CommonLocation: Codeunit "Create Common Location";
    begin
        SvcDemoDataSetup.Get();

        if SvcDemoDataSetup."Service Location" = '' then
            SvcDemoDataSetup.Validate("Service Location", CommonLocation.MainLocation());

        SvcDemoDataSetup.Modify();
    end;
}