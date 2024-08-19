namespace Microsoft.DataMigration.GP;

using System.Integration;
using System.Environment.Configuration;
using System.Environment;
using Microsoft.Purchases.Vendor;
using Microsoft.Finance.VAT.Reporting;

codeunit 42004 "GP Cloud Migration US"
{
    var
        IRSFormFeatureKeyIdTok: Label 'IRSForm', Locked = true;

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
            EnsureSupportedReportingYear();
            SetupIRSFormsFeatureIfNeeded();
            BindSubscription(GPPopulateVendor1099Data);
            GPPopulateVendor1099Data.Run();
            UnbindSubscription(GPPopulateVendor1099Data);
        end;

        SetPreferredVendorBankAccountsUseForElectronicPayments();
    end;

    local procedure EnsureSupportedReportingYear()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPVendor1099MappingHelpers: Codeunit "GP Vendor 1099 Mapping Helpers";
        CurrentYear: Integer;
    begin
        GPCompanyAdditionalSettings.GetSingleInstance();
        CurrentYear := System.Date2DMY(Today(), 3);

        // If the configured tax year is less than the minimum supported year (example: 0), default it to the current year
        if (GPCompanyAdditionalSettings."1099 Tax Year" < GPVendor1099MappingHelpers.GetMinimumSupportedTaxYear()) then begin
            GPCompanyAdditionalSettings."1099 Tax Year" := CurrentYear;
            GPCompanyAdditionalSettings.Modify();
        end;
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

    internal procedure IsIRSFormsFeatureEnabled(): Boolean
    var
#if not CLEAN25
        FeatureManagementFacade: Codeunit "Feature Management Facade";
#endif
        IsEnabled: Boolean;
    begin
        IsEnabled := true;

#if not CLEAN25
        IsEnabled := FeatureManagementFacade.IsEnabled(IRSFormFeatureKeyIdTok);
#endif

        exit(IsEnabled);
    end;

    local procedure SetupIRSFormsFeatureIfNeeded()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPIRSFormData: Codeunit "GP IRS Form Data";
        ReportingYear: Integer;
    begin
        if not IsIRSFormsFeatureEnabled() then
            exit;

        GPCompanyAdditionalSettings.GetSingleInstance();
        ReportingYear := GPCompanyAdditionalSettings.Get1099TaxYear();

        GPIRSFormData.CreateIRSFormsReportingPeriodIfNeeded(ReportingYear);
    end;
}