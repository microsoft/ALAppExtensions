namespace Microsoft.DataMigration.GP;

using System.Integration;
using Microsoft.Purchases.Vendor;

codeunit 42004 "GP Cloud Migration US"
{
    [EventSubscriber(ObjectType::Codeunit, CodeUnit::"Data Migration Mgt.", 'OnAfterMigrationFinished', '', false, false)]
    local procedure OnAfterMigrationFinishedSubscriber(var DataMigrationStatus: Record "Data Migration Status"; WasAborted: Boolean; StartTime: DateTime; Retry: Boolean)
    var
        HelperFunctions: Codeunit "Helper Functions";
    begin
        if not (DataMigrationStatus."Migration Type" = HelperFunctions.GetMigrationTypeTxt()) then
            exit;

        RunPostMigration();
    end;

    procedure RunPostMigration()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPPopulateVendor1099Data: Codeunit "GP Populate Vendor 1099 Data";
    begin
        if GPCompanyAdditionalSettings.GetMigrateVendor1099Enabled() then begin
            BindSubscription(GPPopulateVendor1099Data);
            GPPopulateVendor1099Data.Run();
            UnbindSubscription(GPPopulateVendor1099Data);
        end;

        SetPreferredVendorBankAccountsUseForElectronicPayments();
    end;

    local procedure SetPreferredVendorBankAccountsUseForElectronicPayments()
    var
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        Vendor.SetFilter("Preferred Bank Account Code", '<>%1', '');
        if Vendor.FindSet() then
            repeat
                if VendorBankAccount.Get(Vendor."No.", Vendor."Preferred Bank Account Code") then begin
                    VendorBankAccount.Validate("Use for Electronic Payments", true);
                    VendorBankAccount.Modify();
                end;
            until Vendor.Next() = 0;
    end;
}