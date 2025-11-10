namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Payables;
using Microsoft.Finance.VAT.Reporting;

codeunit 42006 "GP US Migration Validator"
{
    trigger OnRun()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        if not GPCompanyAdditionalSettings.Get(CompanyName()) then
            exit;

        ValidatorCodeLbl := GetValidatorCode();
        CompanyNameTxt := CompanyName();

        RunVendor1099MigrationValidation(GPCompanyAdditionalSettings);
    end;

    local procedure RunVendor1099MigrationValidation(var GPCompanyAdditionalSettings: Record "GP Company Additional Settings")
    var
        GPPM00200: Record "GP PM00200";
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
        TempIRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup" temporary;
        TempGPVendor: Record Vendor temporary;
        Vendor: Record Vendor;
        TempGPVendorLedgerEntry: Record "Vendor Ledger Entry" temporary;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        GPVendor1099MappingHelpers: Codeunit "GP Vendor 1099 Mapping Helpers";
        GPIRS1099Code: Code[10];
        TaxPeriod: Code[20];
        TaxAmount: Decimal;
        VendorYear1099AmountDictionary: Dictionary of [Code[10], Decimal];
        BCFormAndBoxNo: Text[50];
        EntityType: Text[50];
        GPFormAndBoxNo: Text[50];
    begin
        if CompanyValidationProgress.Get(CompanyNameTxt, ValidatorCodeLbl, ValidationStepVendor1099Lbl) then
            exit;

        EntityType := Vendor1099EntityCaptionLbl;
        TaxPeriod := Format(GPCompanyAdditionalSettings.Get1099TaxYear());

        // GP
        if GPCompanyAdditionalSettings.GetMigrateVendor1099Enabled() then begin
            GPPM00200.SetRange(TEN99TYPE, 2, 5);
            GPPM00200.SetFilter(VENDORID, '<>%1', '');
            if GPPM00200.FindSet() then
                repeat
                    if Vendor.Get(GPPM00200.VENDORID) then begin
                        GPIRS1099Code := GPVendor1099MappingHelpers.GetIRS1099BoxCode(System.Date2DMY(System.Today(), 3), GPPM00200.TEN99TYPE, GPPM00200.TEN99BOXNUMBER);

                        if not TempGPVendor.Get(Vendor."No.") then begin
                            TempGPVendor."No." := Vendor."No.";
                            TempGPVendor."Federal ID No." := CopyStr(GPPM00200.TXIDNMBR.TrimEnd(), 1, MaxStrLen(TempGPVendor."Federal ID No."));
                            TempGPVendor.Insert();

                            AssignIRS1099CodeToVendor(GPIRS1099Code, Vendor, GPCompanyAdditionalSettings, TempIRS1099VendorFormBoxSetup);
                        end;

                        Clear(VendorYear1099AmountDictionary);
                        BuildVendor1099Entries(Vendor."No.", VendorYear1099AmountDictionary);
                        foreach GPIRS1099Code in VendorYear1099AmountDictionary.Keys() do begin
                            TaxAmount := VendorYear1099AmountDictionary.Get(GPIRS1099Code);

                            if TaxAmount > 0 then begin
                                TempGPVendorLedgerEntry."Vendor No." := Vendor."No.";
                                TempGPVendorLedgerEntry.Description := GPIRS1099Code;
                                TempGPVendorLedgerEntry.Amount := TaxAmount;
                                TempGPVendorLedgerEntry.Insert();
                            end;
                        end;
                    end;
                until GPPM00200.Next() = 0;
        end;

        // Validate - Vendor 1099
        Vendor.SetLoadFields("No.", Name, "Federal ID No.", "IRS 1099 Form Box No.");
        if TempGPVendor.FindSet() then
            repeat
                MigrationValidationMgmt.SetContext(ValidatorCodeLbl, EntityType, TempGPVendor."No.");
                BCFormAndBoxNo := '';
                GPFormAndBoxNo := '';

                if not Vendor.Get(TempGPVendor."No.") then
                    continue;

                if IRS1099VendorFormBoxSetup.Get(TaxPeriod, Vendor."No.") then
                    BCFormAndBoxNo := StrSubstNo(ExpectedFormAndBoxNoTok, TaxPeriod, IRS1099VendorFormBoxSetup."Form No.", IRS1099VendorFormBoxSetup."Form Box No.");

                if TempIRS1099VendorFormBoxSetup.Get(TaxPeriod, TempGPVendor."No.") then
                    GPFormAndBoxNo := StrSubstNo(ExpectedFormAndBoxNoTok, TaxPeriod, TempIRS1099VendorFormBoxSetup."Form No.", TempIRS1099VendorFormBoxSetup."Form Box No.");

                // Vendor: "Federal ID No.", "IRS 1099 Code"
                MigrationValidationMgmt.ValidateAreEqual('VEND1099FEDIDNO', TempGPVendor."Federal ID No.", Vendor."Federal ID No.", FederalIdNoLbl);
                MigrationValidationMgmt.ValidateAreEqual('VEND1099IRS1099CODE', GPFormAndBoxNo, BCFormAndBoxNo, IRS1099CodeLbl);

                TempGPVendorLedgerEntry.SetRange("Vendor No.", Vendor."No.");
                TempGPVendorLedgerEntry.SetRange("Document Type", TempGPVendorLedgerEntry."Document Type"::Payment);
                if TempGPVendorLedgerEntry.FindSet() then
                    repeat
                        VendorLedgerEntry.SetRange("Document Type", TempGPVendorLedgerEntry."Document Type");
                        VendorLedgerEntry.SetRange("Vendor No.", TempGPVendorLedgerEntry."Vendor No.");
                        VendorLedgerEntry.SetRange(Description, TempGPVendorLedgerEntry.Description);

                        // Vendor Ledger Entry exists?
                        if not MigrationValidationMgmt.ValidateRecordExists('VEND1099TRXEXISTS', VendorLedgerEntry.FindFirst(), StrSubstNo(MissingBoxAndAmountLbl, TempGPVendorLedgerEntry.Description, TempGPVendorLedgerEntry.Amount)) then
                            continue;

                        VendorLedgerEntry.CalcFields(Amount);

                        // VendorLedgerEntry amount
                        MigrationValidationMgmt.ValidateAreEqual('VEND1099TEN99TRXAMT', TempGPVendorLedgerEntry.Amount, VendorLedgerEntry.Amount, Vendor1099BoxAmountLbl);
                    until TempGPVendorLedgerEntry.Next() = 0;
            until TempGPVendor.Next() = 0;

        LogValidationProgress(ValidationStepVendor1099Lbl);
    end;

    local procedure AssignIRS1099CodeToVendor(IRS1099Code: Code[10]; var Vendor: Record Vendor; var GPCompanyAdditionalSettings: Record "GP Company Additional Settings"; var TempIRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup")
    var
        IRS1099FormBox: Record "IRS 1099 Form Box";
    begin
        IRS1099FormBox.SetRange("No.", IRS1099Code);
        if not IRS1099FormBox.FindFirst() then
            exit;

        TempIRS1099VendorFormBoxSetup.Validate("Period No.", Format(GPCompanyAdditionalSettings.Get1099TaxYear()));
        TempIRS1099VendorFormBoxSetup.Validate("Vendor No.", Vendor."No.");
        TempIRS1099VendorFormBoxSetup.Validate("Form No.", IRS1099FormBox."Form No.");
        TempIRS1099VendorFormBoxSetup.Validate("Form Box No.", IRS1099Code);
        TempIRS1099VendorFormBoxSetup.Insert();
    end;

    local procedure BuildVendor1099Entries(VendorNo: Code[20]; var VendorYear1099AmountDictionary: Dictionary of [Code[10], Decimal])
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPPM00204: Record "GP PM00204";
        GPVendor1099MappingHelpers: Codeunit "GP Vendor 1099 Mapping Helpers";
        IRS1099Code: Code[10];
        TaxAmount: Decimal;
        TaxYear: Integer;
    begin
        TaxYear := GPCompanyAdditionalSettings.Get1099TaxYear();
        GPPM00204.SetRange(VENDORID, VendorNo);
        GPPM00204.SetRange(YEAR1, TaxYear);
        GPPM00204.SetFilter(TEN99AMNT, '>0');
        if GPPM00204.FindSet() then
            repeat
                IRS1099Code := GPVendor1099MappingHelpers.GetIRS1099BoxCode(TaxYear, GPPM00204.TEN99TYPE, GPPM00204.TEN99BOXNUMBER);
                if IRS1099Code <> '' then
                    if VendorYear1099AmountDictionary.Get(IRS1099Code, TaxAmount) then
                        VendorYear1099AmountDictionary.Set(IRS1099Code, TaxAmount + GPPM00204.TEN99AMNT)
                    else
                        VendorYear1099AmountDictionary.Add(IRS1099Code, GPPM00204.TEN99AMNT);
            until GPPM00204.Next() = 0;
    end;

    local procedure LogValidationProgress(ValidationStep: Code[20])
    begin
        Clear(CompanyValidationProgress);
        CompanyValidationProgress.Validate("Company Name", CompanyNameTxt);
        CompanyValidationProgress.Validate("Validator Code", ValidatorCodeLbl);
        CompanyValidationProgress.Validate("Validation Step", ValidationStep);
        CompanyValidationProgress.Insert(true);
    end;

    internal procedure GetValidatorCode(): Code[20]
    begin
        exit('GP-US');
    end;

    var
        CompanyValidationProgress: Record "Company Validation Progress";
        MigrationValidationMgmt: Codeunit "Migration Validation Mgmt.";
        ValidatorCodeLbl: Code[20];
        CompanyNameTxt: Text;
        ExpectedFormAndBoxNoTok: Label '%1: %2-%3', Comment = '%1 = Tax period, %2 = IRS 1099 Form No., %3 = IRS 1099 Form Box No.';
        FederalIdNoLbl: Label 'Federal ID No.';
        IRS1099CodeLbl: Label 'IRS 1099 Code';
        MissingBoxAndAmountLbl: Label 'Missing 1099 Box Payment. 1099 Box = %1, Amount = %2', Comment = '%1 = 1099 Box Code, %2 = Amount of the payment';
        Vendor1099BoxAmountLbl: Label '1099 Box Amount';
        Vendor1099EntityCaptionLbl: Label 'Vendor 1099', MaxLength = 50;
        ValidationStepVendor1099Lbl: Label 'VENDOR1099', MaxLength = 20;
}