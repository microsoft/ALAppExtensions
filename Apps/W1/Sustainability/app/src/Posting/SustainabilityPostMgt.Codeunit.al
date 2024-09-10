namespace Microsoft.Sustainability.Posting;

using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Emission;
using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Ledger;

codeunit 6212 "Sustainability Post Mgt"
{
    Access = Internal;

    procedure InsertLedgerEntry(SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
    begin
        SustainabilityLedgerEntry.Init();
        // AutoIncrement requires the PK to be empty
        SustainabilityLedgerEntry."Entry No." := 0;

        SustainabilityLedgerEntry."Account Name" := SustainabilityJnlLine."Account Name";

        SustainabilityLedgerEntry.TransferFields(SustainabilityJnlLine);

        CopyDataFromAccountCategory(SustainabilityLedgerEntry, SustainabilityJnlLine."Account Category");

        CopyDateFromAccountSubCategory(SustainabilityLedgerEntry, SustainabilityJnlLine."Account Category", SustainabilityJnlLine."Account Subcategory");

        SustainabilityLedgerEntry.Validate("User ID", CopyStr(UserId(), 1, 50));
        UpdateCarbonFeeEmission(SustainabilityLedgerEntry);
        SustainabilityLedgerEntry.Insert(true);
    end;

    procedure ResetFilters(var SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    begin
        SustainabilityJnlLine.Reset();
        SustainabilityJnlLine.FilterGroup(2);
        SustainabilityJnlLine.SetRange("Journal Template Name", SustainabilityJnlLine."Journal Template Name");
        SustainabilityJnlLine.SetRange("Journal Batch Name", SustainabilityJnlLine."Journal Batch Name");
        SustainabilityJnlLine.FilterGroup(0);
    end;

    procedure UpdateCarbonFeeEmission(var SustainabilityLedgerEntry: Record "Sustainability Ledger Entry")
    var
        AccountCategory: Record "Sustain. Account Category";
        ScopeType: Enum "Emission Scope";
    begin
        if AccountCategory.Get(SustainabilityLedgerEntry."Account Category") then
            ScopeType := AccountCategory."Emission Scope";

        UpdateCarbonFeeEmissionValues(SustainabilityLedgerEntry, ScopeType);
    end;

    local procedure UpdateCarbonFeeEmissionValues(
        var SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        ScopeType: Enum "Emission Scope"): Decimal
    var
        EmissionFee: Record "Emission Fee";
        CO2eEmission: Decimal;
        CarbonFee: Decimal;
        CO2Factor: Decimal;
        N2OFactor: Decimal;
        CH4Factor: Decimal;
        EmissionCarbonFee: Decimal;
    begin
        EmissionFee.SetFilter("Scope Type", '%1|%2', ScopeType, ScopeType::" ");
        EmissionFee.SetFilter("Starting Date", '<=%1|%2', SustainabilityLedgerEntry."Posting Date", 0D);
        EmissionFee.SetFilter("Ending Date", '>=%1|%2', SustainabilityLedgerEntry."Posting Date", 0D);
        EmissionFee.SetFilter("Country/Region Code", '%1|%2', SustainabilityLedgerEntry."Country/Region Code", '');

        if SustainabilityLedgerEntry."Emission CO2" <> 0 then
            if FindEmissionFeeForEmissionType(EmissionFee, Enum::"Emission Type"::CO2) then begin
                CO2Factor := EmissionFee."Carbon Equivalent Factor";
                EmissionCarbonFee := EmissionFee."Carbon Fee";
            end;

        if SustainabilityLedgerEntry."Emission N2O" <> 0 then
            if FindEmissionFeeForEmissionType(EmissionFee, Enum::"Emission Type"::N2O) then begin
                N2OFactor := EmissionFee."Carbon Equivalent Factor";
                EmissionCarbonFee += EmissionFee."Carbon Fee";
            end;

        if SustainabilityLedgerEntry."Emission CH4" <> 0 then
            if FindEmissionFeeForEmissionType(EmissionFee, Enum::"Emission Type"::CH4) then begin
                CH4Factor := EmissionFee."Carbon Equivalent Factor";
                EmissionCarbonFee += EmissionFee."Carbon Fee";
            end;

        CO2eEmission := (SustainabilityLedgerEntry."Emission CO2" * CO2Factor) + (SustainabilityLedgerEntry."Emission N2O" * N2OFactor) + (SustainabilityLedgerEntry."Emission CH4" * CH4Factor);
        CarbonFee := CO2eEmission * EmissionCarbonFee;

        SustainabilityLedgerEntry."CO2e Emission" := CO2eEmission;
        SustainabilityLedgerEntry."Carbon Fee" := CarbonFee;
    end;

    local procedure FindEmissionFeeForEmissionType(var EmissionFee: Record "Emission Fee"; EmissionType: Enum "Emission Type"): Boolean
    begin
        EmissionFee.SetRange("Emission Type", EmissionType);
        if EmissionFee.FindLast() then
            exit(true);
    end;

    internal procedure GetStartPostingProgressMessage(): Text
    begin
        exit(PostingSustainabilityJournalLbl);
    end;

    internal procedure GetCheckJournalLineProgressMessage(LineNo: Integer): Text
    begin
        exit(StrSubstNo(CheckSustainabilityJournalLineLbl, LineNo));
    end;

    internal procedure GetProgressingLineMessage(LineNo: Integer): Text
    begin
        exit(StrSubstNo(ProcessingLineLbl, LineNo));
    end;

    internal procedure GetJnlLinesPostedMessage(): Text
    begin
        exit(JnlLinesPostedLbl);
    end;

    internal procedure GetPostConfirmMessage(): Text
    begin
        exit(PostConfirmLbl);
    end;

    local procedure CopyDataFromAccountCategory(var SustainabilityLedgerEntry: Record "Sustainability Ledger Entry"; CategoryCode: Code[20])
    var
        SustainAccountCategory: Record "Sustain. Account Category";
    begin
        SustainAccountCategory.Get(CategoryCode);

        SustainabilityLedgerEntry.Validate("Emission Scope", SustainAccountCategory."Emission Scope");
        SustainabilityLedgerEntry.Validate(CO2, SustainAccountCategory.CO2);
        SustainabilityLedgerEntry.Validate(CH4, SustainAccountCategory.CH4);
        SustainabilityLedgerEntry.Validate(N2O, SustainAccountCategory.N2O);
        SustainabilityLedgerEntry.Validate("Calculation Foundation", SustainAccountCategory."Calculation Foundation");
    end;

    local procedure CopyDateFromAccountSubCategory(var SustainabilityLedgerEntry: Record "Sustainability Ledger Entry"; CategoryCode: Code[20]; SubCategoryCode: Code[20])
    var
        SustainAccountSubCategory: Record "Sustain. Account Subcategory";
    begin
        SustainAccountSubCategory.Get(CategoryCode, SubCategoryCode);

        SustainabilityLedgerEntry.Validate("Emission Factor CO2", SustainAccountSubCategory."Emission Factor CO2");
        SustainabilityLedgerEntry.Validate("Emission Factor CH4", SustainAccountSubCategory."Emission Factor CH4");
        SustainabilityLedgerEntry.Validate("Emission Factor N2O", SustainAccountSubCategory."Emission Factor N2O");
        SustainabilityLedgerEntry.Validate("Renewable Energy", SustainAccountSubCategory."Renewable Energy");
    end;

    var
        PostingSustainabilityJournalLbl: Label 'Posting Sustainability Journal Lines: \ #1', Comment = '#1 = sub-process progress message';
        CheckSustainabilityJournalLineLbl: Label 'Checking Sustainability Journal Line: %1', Comment = '%1 = Line No.';
        ProcessingLineLbl: Label 'Processing Line: %1', Comment = '%1 = Line No.';
        JnlLinesPostedLbl: Label 'The journal lines were successfully posted.';
        PostConfirmLbl: Label 'Do you want to post the journal lines?';
}