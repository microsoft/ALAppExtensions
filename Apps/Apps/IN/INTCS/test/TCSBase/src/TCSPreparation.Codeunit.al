codeunit 18912 "TCS-Preparation"
{
    Subtype = Test;

    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        Storage: Dictionary of [Text, Text];
        EffectiveDateLbl: Label 'EffectiveDate', locked = true;
        TCSNOCTypeLbl: Label 'TCSNOCType', locked = true;
        TCSAssesseeCodeLbl: Label 'TCSAssesseeCode', locked = true;
        TCSConcessionalCodeLbl: Label 'TCSConcessionalCode', locked = true;
        CompanySetupErr: Label 'Company Information setup not created', Locked = true;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CreateTCSSetup()
    var
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        AssesseeCode: Record "Assessee Code";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [SCENARIO] [354739] Check if the program is allowing you to design the TCS Posting Setup, TCS Rates, TCS NOC, Concessional Codes, Assessee Codes, TCAN No.

        // [GIVEN] Create TCS posting setup, TCS Rates, TCS Nature of Collection, Concessional Code, Assessee Code
        // [WHEN] TCS Setup Created- TCS posting setup, TCS Rates, TCS Nature of Collection, Concessional Code, Assessee Code
        CreateTCSNatureOfCollection(TCSNatureOfCollection);
        CreateTCSPostingSetup(TCSNatureOfCollection.Code);
        CreateAssesseeCode(AssesseeCode);
        CreateTCANNo();
        CreateConcessionalCode(ConcessionalCode);
        CreateTCSRates(TCSNatureOfCollection.Code, AssesseeCode.Code, ConcessionalCode.Code, WorkDate());

        // [THEN] TCS Setup Verified
        VerifyTCSSetup(TCSNatureOfCollection.Code, AssesseeCode.Code, ConcessionalCode.Code);
    end;

    [Test]
    procedure InsertTCSDetailsonCompanyInformation()
    var
        CompInfo: Record "Company Information";
    begin
        // [SCENARIO] [354740] Check if the program is allowing you to design the TDS/TCS related fields in Company Information

        // [GIVEN] TCS Setup create for Company Information
        // [WHEN] TCS Setup created for Company Information
        Compinfo.Get();
        if CompInfo."P.A.N. No." = '' then
            CompInfo."P.A.N. No." := LibraryUtility.GenerateRandomCode(CompInfo.FieldNo("P.A.N. No."), Database::"Company Information");
        CompInfo.Validate("Circle No.", LibraryUtility.GenerateRandomText(30));
        CompInfo.Validate("Ward No.", LibraryUtility.GenerateRandomText(30));
        CompInfo.Validate("Assessing Officer", LibraryUtility.GenerateRandomText(30));
        CompInfo.Validate("Deductor Category", CreateDeductorCategory());
        if CompInfo."State Code" = '' then
            CompInfo.Validate("State Code", CreateStateCode());
        CompInfo.Validate("T.C.A.N. No.", CreateTCANNo());
        CompInfo.Modify(true);

        // [THEN] Company Information Verified
        VerifyCompanyInformation();
    end;

    local procedure CreateTCSNatureOfCollection(var TCSNatureOfCollection: Record "TCS Nature Of Collection")
    begin
        TCSNatureOfCollection.Init();
        TCSNatureOfCollection.Validate(Code, LibraryUtility.GenerateRandomCode(TCSNatureOfCollection.FieldNo(Code), Database::"TCS Nature Of Collection"));
        TCSNatureOfCollection.Validate(Description, TCSNatureOfCollection.Code);
        TCSNatureOfCollection.Insert(true);
    end;

    local procedure CreateStateCode(): Code[10]
    var
        State: Record State;
    begin
        if State.FindFirst() then
            exit(State.Code)
        else begin
            State.Init();
            State.Validate(Code, LibraryRandom.RandText(2));
            State.Validate(Description, State.Code);
            State.Insert(true);
            exit(State.Code);
        end;
    end;

    local procedure CreateDeductorCategory(): Code[20]
    var
        DeductorCategory: Record "Deductor Category";
    begin
        DeductorCategory.SetRange("DDO Code Mandatory", false);
        DeductorCategory.SetRange("PAO Code Mandatory", false);
        DeductorCategory.SetRange("State Code Mandatory", false);
        DeductorCategory.SetRange("Ministry Details Mandatory", false);
        DeductorCategory.SetRange("Transfer Voucher No. Mandatory", false);
        if DeductorCategory.FindFirst() then
            exit(DeductorCategory.Code)
        else begin
            DeductorCategory.Init();
            DeductorCategory.Validate(Code, LibraryUtility.GenerateRandomText(1));
            DeductorCategory.Insert(true);
            exit(DeductorCategory.Code);
        end;
    end;

    local procedure CreateTCSPostingSetup(TCSNatureOfCollectionCode: Code[20])
    var
        TCSPostingSetup: Record "TCS Posting Setup";
    begin
        TCSPostingSetup.Init();
        TCSPostingSetup.Validate("TCS Nature of Collection", TCSNatureOfCollectionCode);
        TCSPostingSetup.Validate("Effective Date", WorkDate());
        TCSPostingSetup.Validate("TCS Account No.", LibraryERM.CreateGLAccountNoWithDirectPosting());
        TCSPostingSetup.Insert(true);
    end;

    local procedure CreateAssesseeCode(var AssesseeCode: Record "Assessee Code")
    begin
        AssesseeCode.Init();
        AssesseeCode.Validate(Code, LibraryUtility.GenerateRandomCode(AssesseeCode.FieldNo(Code), Database::"Assessee Code"));
        AssesseeCode.Validate(Description, AssesseeCode.Code);
        AssesseeCode.Insert(true);
    end;

    local procedure CreateTCANNo(): Code[10]
    var
        TCANNo: Record "T.C.A.N. No.";
    begin
        TCANNo.Init();
        TCANNo.Validate(Code, LibraryUtility.GenerateRandomCode(TCANNo.FieldNo(Code), Database::"T.C.A.N. No."));
        TCANNo.Validate(Description, TCANNo.Code);
        TCANNo.Insert(true);
        exit(TCANNo.Code);
    end;

    local procedure CreateConcessionalCode(var ConcessionalCode: Record "Concessional Code")
    begin
        ConcessionalCode.Init();
        ConcessionalCode.Validate(Code, LibraryUtility.GenerateRandomCode(ConcessionalCode.FieldNo(Code), Database::"Concessional Code"));
        ConcessionalCode.Validate(Description, ConcessionalCode.Code);
        ConcessionalCode.Insert(true);
    end;

    local procedure CreateTCSRates(
        TCSNOC: Code[10];
        AssesseeCode: Code[10];
        ConcessionalCode: Code[10];
        EffectiveDate: Date)
    begin
        Storage.Set(TCSNOCTypeLbl, TCSNOC);
        Storage.Set(TCSAssesseeCodeLbl, AssesseeCode);
        Storage.Set(TCSConcessionalCodeLbl, ConcessionalCode);
        Storage.Set(EffectiveDateLbl, Format(EffectiveDate, 0, 9));
        CreateTaxRate();
    end;

    local procedure CreateTaxRate()
    var
        TCSSetup: Record "TCS Setup";
        PageTaxtype: TestPage "Tax Types";
    begin
        if not TCSSetup.Get() then
            exit;
        PageTaxtype.OpenEdit();
        PageTaxtype.Filter.SetFilter(Code, TCSSetup."Tax Type");
        PageTaxtype.TaxRates.Invoke();
    end;

    local procedure VerifyTCSSetup(TCSNOC: Code[10]; AssesseeCode: Code[10]; ConcessinalCode: Code[10])
    var
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        AssesseeCodes: Record "Assessee Code";
        ConcessionalCodes: Record "Concessional Code";
    begin
        TCSNatureOfCollection.Get(TCSNOC);
        AssesseeCodes.Get(AssesseeCode);
        ConcessionalCodes.Get(ConcessinalCode);
    end;

    local procedure VerifyCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.SetFilter("P.A.N. No.", '<>%1', '');
        CompanyInformation.SetFilter("Circle No.", '<>%1', '');
        CompanyInformation.SetFilter("Ward No.", '<>%1', '');
        CompanyInformation.SetFilter("State Code", '<>%1', '');
        CompanyInformation.SetFilter("T.C.A.N. No.", '<>%1', '');
        CompanyInformation.SetFilter("Assessing Officer", '<>%1', '');
        CompanyInformation.SetFilter("Deductor Category", '<>%1', '');
        if CompanyInformation.IsEmpty then
            Error(CompanySetupErr);
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRate: TestPage "Tax Rates")
    var
        EffectiveDate: Date;
    begin
        Evaluate(EffectiveDate, Storage.Get(EffectiveDateLbl), 9);

        TaxRate.AttributeValue1.SetValue(Storage.Get(TCSNOCTypeLbl));
        TaxRate.AttributeValue2.SetValue(Storage.Get(TCSAssesseeCodeLbl));
        TaxRate.AttributeValue3.SetValue(Storage.Get(TCSConcessionalCodeLbl));
        TaxRate.AttributeValue4.SetValue(EffectiveDate);
        TaxRate.AttributeValue5.SetValue(LibraryRandom.RandIntInRange(2, 4));
        TaxRate.AttributeValue6.SetValue(LibraryRandom.RandIntInRange(8, 10));
        TaxRate.AttributeValue7.SetValue(LibraryRandom.RandIntInRange(8, 10));
        TaxRate.AttributeValue8.SetValue(LibraryRandom.RandIntInRange(1, 2));
        TaxRate.AttributeValue9.SetValue(LibraryRandom.RandIntInRange(1, 2));
        TaxRate.AttributeValue10.SetValue(LibraryRandom.RandIntInRange(8000, 10000));
        TaxRate.AttributeValue11.SetValue(LibraryRandom.RandIntInRange(8000, 10000));
        TaxRate.OK().Invoke();
    end;
}