codeunit 4799 "Create FA Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "FA Setup" = rim;

    trigger OnRun()
    var
        FASetup: Record "FA Setup";
        FAModuleSetup: Record "FA Module Setup";
        FANoSeries: Codeunit "Create FA No Series";
    begin
        if not FASetup.Get() then begin
            FASetup.Init();
            FASetup.Insert(true);
        end;

        FAModuleSetup.Get();

        FASetup.Validate("Fixed Asset Nos.", FANoSeries.FixedAsset());
        FASetup.Validate("Insurance Nos.", FANoSeries.Insurance());
        FASetup.Validate("Default Depr. Book", FAModuleSetup."Default Depreciation Book");
        FASetup.Validate("Insurance Depr. Book", FAModuleSetup."Default Depreciation Book");

        FASetup.Modify(true);
    end;
}