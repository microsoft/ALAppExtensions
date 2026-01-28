namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;
using Microsoft.Finance.VAT.Reporting;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;

codeunit 42006 "GP IRS1099 Migration Validator"
{
    trigger OnRun()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        if not GPCompanyAdditionalSettings.GetMigrateVendor1099Enabled() then
            exit;

        ValidationSuiteIdTxt := GetValidationSuiteId();
        CompanyNameTxt := CompanyName();

        RunVendor1099MigrationValidation(GPCompanyAdditionalSettings);
    end;

    local procedure RunVendor1099MigrationValidation(var GPCompanyAdditionalSettings: Record "GP Company Additional Settings")
    var
        GPPM00200: Record "GP PM00200";
        Vendor: Record Vendor;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
        GPVendor1099MappingHelpers: Codeunit "GP Vendor 1099 Mapping Helpers";
        IRS1099Code: Code[10];
        ActualIRS1099Code: Code[20];
        TaxAmount: Decimal;
        VendorYear1099AmountDictionary: Dictionary of [Code[10], Decimal];
        EntityType: Text[50];
        VendorNo: Code[20];
    begin
        EntityType := Vendor1099EntityCaptionLbl;

        if GPCompanyAdditionalSettings.GetMigrateVendor1099Enabled() then begin
            GPPM00200.SetRange(TEN99TYPE, 2, 5);
            GPPM00200.SetFilter(VENDORID, '<>%1', '');
            if GPPM00200.FindSet() then
                repeat
                    if MigrationValidationAssert.IsSourceRowValidated(ValidationSuiteIdTxt, GPPM00200) then
                        continue;

                    VendorNo := CopyStr(GPPM00200.VENDORID.TrimEnd(), 1, MaxStrLen(VendorNo));
                    Vendor.SetLoadFields("No.", Name, "Federal ID No.");
                    if not Vendor.Get(VendorNo) then
                        continue;

                    MigrationValidationAssert.SetContext(ValidationSuiteIdTxt, EntityType, VendorNo);
                    IRS1099Code := GPVendor1099MappingHelpers.GetIRS1099BoxCode(System.Date2DMY(System.Today(), 3), GPPM00200.TEN99TYPE, GPPM00200.TEN99BOXNUMBER);

                    Clear(ActualIRS1099Code);
                    if IRS1099VendorFormBoxSetup.Get(Format(GPCompanyAdditionalSettings.Get1099TaxYear()), VendorNo) then
                        ActualIRS1099Code := IRS1099VendorFormBoxSetup."Form Box No.";

                    MigrationValidationAssert.ValidateAreEqual(Test_VEND1099IRS1099CODE_Tok, IRS1099Code, ActualIRS1099Code, IRS1099CodeLbl);
                    MigrationValidationAssert.ValidateAreEqual(Test_VEND1099FEDIDNO_Tok, CopyStr(GPPM00200.TXIDNMBR.TrimEnd(), 1, MaxStrLen(Vendor."Federal ID No.")), Vendor."Federal ID No.", FederalIdNoLbl);

                    Clear(VendorYear1099AmountDictionary);
                    BuildVendor1099Entries(VendorNo, VendorYear1099AmountDictionary);
                    foreach IRS1099Code in VendorYear1099AmountDictionary.Keys() do begin
                        TaxAmount := VendorYear1099AmountDictionary.Get(IRS1099Code);

                        if TaxAmount > 0 then begin
                            Clear(VendorLedgerEntry);
                            VendorLedgerEntry.SetLoadFields(Description, Amount);
                            VendorLedgerEntry.SetRange("Vendor No.", VendorNo);
                            VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Payment);
                            VendorLedgerEntry.SetRange(Description, IRS1099Code);

                            if not MigrationValidationAssert.ValidateRecordExists(Test_VEND1099TRXEXISTS_Tok, VendorLedgerEntry.FindFirst(), StrSubstNo(MissingBoxAndAmountLbl, IRS1099Code, TaxAmount)) then
                                continue;

                            VendorLedgerEntry.CalcFields(Amount);

                            MigrationValidationAssert.ValidateAreEqual(Test_VEND1099TEN99BOX_Tok, IRS1099Code, VendorLedgerEntry.Description, Vendor1099BoxLbl);
                            MigrationValidationAssert.ValidateAreEqual(Test_VEND1099TEN99TRXAMT_Tok, TaxAmount, VendorLedgerEntry.Amount, Vendor1099BoxAmountLbl);
                        end;
                    end;

                    MigrationValidationAssert.SetSourceRowValidated(ValidationSuiteIdTxt, GPPM00200);
                until GPPM00200.Next() = 0;
        end;
        Commit();
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

    internal procedure GetValidationSuiteId(): Code[20]
    begin
        exit('GP-US');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Migration Validation", OnPrepareValidation, '', false, false)]
    local procedure OnPrepareValidation(ProductID: Text[250])
    var
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
    begin
        if ProductID <> HybridGPWizard.ProductId() then
            exit;

        RegisterValidator();

        AddTest(Test_VEND1099IRS1099CODE_Tok, Vendor1099EntityCaptionLbl, IRS1099CodeLbl);
        AddTest(Test_VEND1099FEDIDNO_Tok, Vendor1099EntityCaptionLbl, FederalIdNoLbl);
        AddTest(Test_VEND1099TRXEXISTS_Tok, Vendor1099EntityCaptionLbl, Vendor1099MissingTrxLbl);
        AddTest(Test_VEND1099TEN99BOX_Tok, Vendor1099EntityCaptionLbl, Vendor1099TrxBoxNoLbl);
        AddTest(Test_VEND1099TEN99TRXAMT_Tok, Vendor1099EntityCaptionLbl, Vendor1099TrxAmtLbl);
    end;

    local procedure RegisterValidator()
    var
        ValidationSuite: Record "Validation Suite";
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
        ValidationSuiteId: Code[20];
        MigrationType: Text[250];
        ValidatorCodeunitId: Integer;
    begin
        ValidationSuiteId := GetValidationSuiteId();
        MigrationType := HybridGPWizard.ProductId();
        ValidatorCodeunitId := Codeunit::"GP IRS1099 Migration Validator";
        if not ValidationSuite.Get(ValidationSuiteId) then begin
            ValidationSuite.Validate(Id, ValidationSuiteId);
            ValidationSuite.Validate("Migration Type", MigrationType);
            ValidationSuite.Validate(Description, ValidatorDescriptionLbl);
            ValidationSuite.Validate("Codeunit Id", ValidatorCodeunitId);
            ValidationSuite.Validate(Automatic, true);
            ValidationSuite.Validate("Errors should fail migration", false);
            ValidationSuite.Insert(true);
        end;
    end;

    local procedure AddTest(Code: Code[30]; Entity: Text[50]; Description: Text)
    var
        ValidationSuiteLine: Record "Validation Suite Line";
    begin
        if not ValidationSuiteLine.Get(Code, GetValidationSuiteId()) then begin
            ValidationSuiteLine.Validate(Code, Code);
            ValidationSuiteLine.Validate("Validation Suite Id", GetValidationSuiteId());
            ValidationSuiteLine.Validate(Entity, Entity);
            ValidationSuiteLine.Validate("Test Description", Description);
            ValidationSuiteLine.Insert(true);
        end;
    end;

    var
        MigrationValidationAssert: Codeunit "Migration Validation Assert";
        ValidationSuiteIdTxt: Code[20];
        CompanyNameTxt: Text;
        FederalIdNoLbl: Label 'Federal ID No.';
        IRS1099CodeLbl: Label 'IRS 1099 Code';
        MissingBoxAndAmountLbl: Label 'Missing 1099 Box Payment. 1099 Box = %1, Amount = %2', Comment = '%1 = 1099 Box Code, %2 = Amount of the payment';
        Vendor1099BoxLbl: Label '1099 Box';
        Vendor1099BoxAmountLbl: Label '1099 Box Amount';
        Vendor1099MissingTrxLbl: Label 'Missing 1099 transaction';
        Vendor1099TrxBoxNoLbl: Label '1099 transaction Box No/Description';
        Vendor1099TrxAmtLbl: Label '1099 transaction amount';
        Vendor1099EntityCaptionLbl: Label 'Vendor 1099', MaxLength = 50;
        ValidatorDescriptionLbl: Label 'GP IRS 1099 migration validator', MaxLength = 250;
        Test_VEND1099IRS1099CODE_Tok: Label 'VEND1099IRS1099CODE', Locked = true;
        Test_VEND1099FEDIDNO_Tok: Label 'VEND1099FEDIDNO', Locked = true;
        Test_VEND1099TRXEXISTS_Tok: Label 'VEND1099TRXEXISTS', Locked = true;
        Test_VEND1099TEN99BOX_Tok: Label 'VEND1099TEN99BOX', Locked = true;
        Test_VEND1099TEN99TRXAMT_Tok: Label 'VEND1099TEN99TRXAMT', Locked = true;
}