codeunit 148042 "Library - MX DIOT"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        DIOTDataMgmt: Codeunit "DIOT Data Management";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";

    trigger OnRun()
    begin
        // [FEATURE] [DIOT] [Library]
    end;

    procedure CreateDIOTVendor(var Vendor: Record Vendor; VATBusPostingGroup: Code[20]; IsLocal: Boolean)
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        Vendor.Validate("Tax Identification Type", Vendor."Tax Identification Type"::"Legal Entity");
        Vendor.Validate(Name, LibraryUtility.GenerateGUID());
        Vendor.Validate("DIOT Type of Operation", Vendor."DIOT Type of Operation"::Others);
        Vendor.Validate("VAT Registration No.", LibraryUtility.GenerateGUID());
        Vendor.Validate("RFC No.", GenerateValidRFCNo());
        if IsLocal then
            Vendor.Validate("Country/Region Code", DIOTDataMgmt.GetMXCountryCode())
        else
            Vendor.Validate("Country/Region Code", FindForeignCountryCode());
        Vendor.Modify(true);
    end;

    procedure FindForeignCountryCode(): Code[20]
    var
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.SetFilter(Code, '<>%1', DIOTDataMgmt.GetMXCountryCode());
        CountryRegion.FindFirst();
        exit(CountryRegion.Code);
    end;

    procedure FindBaseAmountConceptNo(): Integer
    var
        DIOTConcept: Record "DIOT Concept";
    begin
        DIOTConcept.SetRange("Column Type", DIOTConcept."Column Type"::"VAT Base");
        DIOTConcept.FindFirst();
        exit(DIOTConcept."Concept No.");
    end;

    procedure FindVATAmountConceptNo(): Integer
    var
        DIOTConcept: Record "DIOT Concept";
    begin
        DIOTConcept.SetRange("Column Type", DIOTConcept."Column Type"::"Vat Amount");
        DIOTConcept.FindFirst();
        exit(DIOTConcept."Concept No.");
    end;

    procedure GenerateValidRFCNo(): Text[12]
    begin
        exit('00' + LibraryUtility.GenerateGUID());
    end;

    procedure InsertDIOTConceptLink(ConceptNo: Integer; VATPostingSetup: Record "VAT Posting Setup")
    var
        DIOTConceptLink: Record "DIOT Concept Link";
    begin
        with DIOTConceptLink do begin
            Init();
            "DIOT Concept No." := ConceptNo;
            "VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
            "VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
            Insert(true);
        end;
    end;

    procedure MockPurchaseVATEntry(var VATEntry: Record "VAT Entry"; VATPostingSetup: Record "VAT Posting Setup"; PostingDate: Date; VendorNo: Code[20])
    begin
        VATEntry.Init();
        VATEntry."Entry No." := LibraryUtility.GetNewRecNo(VATEntry, VATEntry.FieldNo("Entry No."));
        VATEntry."Posting Date" := PostingDate;
        VATEntry."Document No." := LibraryUtility.GenerateGUID();
        VATEntry."Document Type" := VATEntry."Document Type"::Invoice;
        VATEntry.Type := VATEntry.Type::Purchase;
        VATEntry."Bill-to/Pay-to No." := VendorNo;
        VATEntry."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        VATEntry."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
        VATEntry.Base := LibraryRandom.RandDec(1000, 2);
        VATEntry.Amount := VATEntry.Base * VATPostingSetup."VAT %" / 100;
        VATEntry.Insert(true);
    end;

    procedure OpenDIOTSetupWizardStep(var DIOTSetupWizard: TestPage "DIOT Setup Wizard"; StepNo: Integer)
    var
        i: Integer;
    begin
        DIOTSetupWizard.OpenEdit();
        for i := 1 to StepNo do
            DIOTSetupWizard.ActionNext.Invoke();
    end;
}