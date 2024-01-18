codeunit 148407 "Library - Fixed Asset CZF"
{

    trigger OnRun()
    begin
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";

    procedure CreateTaxDepreciationGroup(var TaxDepreciationGroupCZF: Record "Tax Depreciation Group CZF"; StartingDate: Date)
    begin
        TaxDepreciationGroupCZF.Init();
        TaxDepreciationGroupCZF.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(TaxDepreciationGroupCZF.FieldNo(Code), DATABASE::"Tax Depreciation Group CZF"),
            1, MaxStrLen(TaxDepreciationGroupCZF.Code)));
        TaxDepreciationGroupCZF.Validate("Starting Date", StartingDate);
        TaxDepreciationGroupCZF.Validate(Description, TaxDepreciationGroupCZF.Code); // Validating Description as Code because value is not important.
        TaxDepreciationGroupCZF.Insert(true);
    end;

    procedure CreateFALocation(var FALocation: Record "FA Location")
    begin
        FALocation.Init();
        FALocation.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(FALocation.FieldNo(Code), DATABASE::"FA Location"),
            1, MaxStrLen(FALocation.Code)));
        FALocation.Validate(Name, FALocation.Code); // Validating Description as Code because value is not important.
        FALocation.Insert(true);
    end;

    procedure CreateFAExtendedPostingGroup(var FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF"; FAPostingGroupCode: Code[20]; FAPostingType: Enum "FA Extended Posting Type CZF"; ReasonCode: Code[10])
    begin
        FAExtendedPostingGroupCZF.Init();
        FAExtendedPostingGroupCZF.Validate("FA Posting Group Code", FAPostingGroupCode);
        FAExtendedPostingGroupCZF.Validate("FA Posting Type", FAPostingType);
        FAExtendedPostingGroupCZF.Validate(Code, ReasonCode);
        FAExtendedPostingGroupCZF.Insert(true);
    end;

    procedure GenerateDeprecationGroupCode(): Text
    var
        TaxDepreciationGroupCZF: Record "Tax Depreciation Group CZF";
    begin
        exit(
          CopyStr(
            LibraryUtility.GenerateRandomCode(TaxDepreciationGroupCZF.FieldNo("Depreciation Group"), DATABASE::"Tax Depreciation Group CZF"),
            1, MaxStrLen(TaxDepreciationGroupCZF."Depreciation Group")));
    end;

    procedure RunCalculateDepreciation(var FixedAsset: Record "Fixed Asset"; DepreciationBookCode: Code[10]; FAPostingDate: Date; DocumentNo: Code[20]; PostingDescription: Text[100])
    var
        FixedAsset2: Record "Fixed Asset";
        CalculateDepreciationCZF: Report "Calculate Depreciation CZF";
    begin
        FixedAsset2.Copy(FixedAsset);
        CalculateDepreciationCZF.InitializeRequest(
          DepreciationBookCode, FAPostingDate, false, 0,
          0D, DocumentNo, PostingDescription, false);
        CalculateDepreciationCZF.SetTableView(FixedAsset2);
        CalculateDepreciationCZF.UseRequestPage(false);
        CalculateDepreciationCZF.RunModal();
    end;
}

