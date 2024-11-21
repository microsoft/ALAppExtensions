namespace Microsoft.Sustainability.Posting;

using Microsoft.Inventory.Ledger;
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

    procedure InsertValueEntry(SustainabilityJnlLine: Record "Sustainability Jnl. Line"; ValueEntry: Record "Value Entry"; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        ShouldCalcExpectedCO2e: Boolean;
    begin
        SustainabilityValueEntry.Init();

        SustainabilityValueEntry."Entry No." := SustainabilityValueEntry.GetLastEntryNo() + 1;
        SustainabilityValueEntry.CopyFromValueEntry(ValueEntry);

        SustainabilityValueEntry.Validate("User ID", CopyStr(UserId(), 1, 50));
        UpdateCarbonFeeEmissionForValueEntry(SustainabilityValueEntry, SustainabilityJnlLine);

        ShouldCalcExpectedCO2e :=
            ((SustainabilityValueEntry."Entry Type" = SustainabilityValueEntry."Entry Type"::"Direct Cost") and
            (((SustainabilityValueEntry."Item Ledger Entry Quantity" = 0) and (SustainabilityValueEntry."Invoiced Quantity" <> 0))));

        if ShouldCalcExpectedCO2e then
            CalcExpectedCO2e(
                SustainabilityValueEntry."Item Ledger Entry No.",
                SustainabilityValueEntry."Invoiced Quantity",
                ItemLedgerEntry.Quantity,
                SustainabilityValueEntry."CO2e Amount (Expected)",
                ItemLedgerEntry.Quantity = ItemLedgerEntry."Invoiced Quantity");

        SustainabilityValueEntry.Insert(true);
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

        UpdateCarbonFeeEmissionValues(
            ScopeType, SustainabilityLedgerEntry."Posting Date", SustainabilityLedgerEntry."Country/Region Code", SustainabilityLedgerEntry."Emission CO2",
            SustainabilityLedgerEntry."Emission N2O", SustainabilityLedgerEntry."Emission CH4", SustainabilityLedgerEntry."CO2e Emission", SustainabilityLedgerEntry."Carbon Fee");
    end;

    procedure UpdateCarbonFeeEmissionForValueEntry(var SustainabilityValueEntry: Record "Sustainability Value Entry"; SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    var
        AccountCategory: Record "Sustain. Account Category";
        ScopeType: Enum "Emission Scope";
        CO2eEmission: Decimal;
        CarbonFee: Decimal;
    begin
        if AccountCategory.Get(SustainabilityJnlLine."Account Category") then
            ScopeType := AccountCategory."Emission Scope";

        UpdateCarbonFeeEmissionValues(
            ScopeType, SustainabilityJnlLine."Posting Date", SustainabilityJnlLine."Country/Region Code", SustainabilityJnlLine."Emission CO2",
            SustainabilityJnlLine."Emission N2O", SustainabilityJnlLine."Emission CH4", CO2eEmission, CarbonFee);

        if SustainabilityValueEntry."Expected Emission" then
            SustainabilityValueEntry."CO2e Amount (Expected)" := CO2eEmission
        else
            SustainabilityValueEntry."CO2e Amount (Actual)" := CO2eEmission;

        SustainabilityValueEntry."CO2e per Unit" := CalcCO2ePerUnit(CO2eEmission, SustainabilityValueEntry."Valued Quantity");
    end;

    local procedure UpdateCarbonFeeEmissionValues(
        ScopeType: Enum "Emission Scope";
        PostingDate: Date;
        CountryRegionCode: Code[10];
        EmissionCO2: Decimal;
        EmissionN2O: Decimal;
        EmissionCH4: Decimal;
        var CO2eEmission: Decimal;
        var CarbonFee: Decimal): Decimal
    var
        EmissionFee: Record "Emission Fee";
        CO2Factor: Decimal;
        N2OFactor: Decimal;
        CH4Factor: Decimal;
        EmissionCarbonFee: Decimal;
    begin
        EmissionFee.SetFilter("Scope Type", '%1|%2', ScopeType, ScopeType::" ");
        EmissionFee.SetFilter("Starting Date", '<=%1|%2', PostingDate, 0D);
        EmissionFee.SetFilter("Ending Date", '>=%1|%2', PostingDate, 0D);
        EmissionFee.SetFilter("Country/Region Code", '%1|%2', CountryRegionCode, '');

        if EmissionCO2 <> 0 then
            if FindEmissionFeeForEmissionType(EmissionFee, Enum::"Emission Type"::CO2) then begin
                CO2Factor := EmissionFee."Carbon Equivalent Factor";
                EmissionCarbonFee := EmissionFee."Carbon Fee";
            end;

        if EmissionN2O <> 0 then
            if FindEmissionFeeForEmissionType(EmissionFee, Enum::"Emission Type"::N2O) then begin
                N2OFactor := EmissionFee."Carbon Equivalent Factor";
                EmissionCarbonFee += EmissionFee."Carbon Fee";
            end;

        if EmissionCH4 <> 0 then
            if FindEmissionFeeForEmissionType(EmissionFee, Enum::"Emission Type"::CH4) then begin
                CH4Factor := EmissionFee."Carbon Equivalent Factor";
                EmissionCarbonFee += EmissionFee."Carbon Fee";
            end;

        CO2eEmission := (EmissionCO2 * CO2Factor) + (EmissionN2O * N2OFactor) + (EmissionCH4 * CH4Factor);
        CarbonFee := CO2eEmission * EmissionCarbonFee;
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

    local procedure CalcCO2ePerUnit(CO2e: Decimal; Quantity: Decimal): Decimal
    begin
        if Quantity <> 0 then
            exit(CO2e / Quantity);

        exit(0);
    end;

    local procedure CalcExpectedCO2e(ItemLedgEntryNo: Integer; InvoicedQty: Decimal; Quantity: Decimal; var ExpectedCO2e: Decimal; CalcReminder: Boolean)
    var
        SustValueEntry: Record "Sustainability Value Entry";
    begin
        ExpectedCO2e := 0;

        SustValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type");
        SustValueEntry.SetRange("Item Ledger Entry No.", ItemLedgEntryNo);
        SustValueEntry.SetFilter("Entry Type", '<>%1', SustValueEntry."Entry Type"::Revaluation);
        if SustValueEntry.FindSet() and SustValueEntry."Expected Emission" then
            if CalcReminder then begin
                SustValueEntry.CalcSums("CO2e Amount (Expected)");
                ExpectedCO2e := -SustValueEntry."CO2e Amount (Expected)";
            end else begin
                SustValueEntry.SetRange("Expected Emission", true);
                SustValueEntry.SetRange(Adjustment, false);
                if SustValueEntry.IsEmpty() then
                    exit;

                SustValueEntry.CalcSums("CO2e Amount (Expected)");
                ExpectedCO2e := SustValueEntry."CO2e Amount (Expected)";
                ExpectedCO2e := CalcExpCO2eToBalance(ExpectedCO2e, InvoicedQty, Quantity);
            end;
    end;

    local procedure CalcExpCO2eToBalance(ExpectedCO2e: Decimal; InvoicedQty: Decimal; Quantity: Decimal): Decimal
    begin
        if (Quantity = 0) or (ExpectedCO2e = 0) or (InvoicedQty = 0) then
            exit(0);

        exit(-InvoicedQty / Quantity * ExpectedCO2e);
    end;

    var
        PostingSustainabilityJournalLbl: Label 'Posting Sustainability Journal Lines: \ #1', Comment = '#1 = sub-process progress message';
        CheckSustainabilityJournalLineLbl: Label 'Checking Sustainability Journal Line: %1', Comment = '%1 = Line No.';
        ProcessingLineLbl: Label 'Processing Line: %1', Comment = '%1 = Line No.';
        JnlLinesPostedLbl: Label 'The journal lines were successfully posted.';
        PostConfirmLbl: Label 'Do you want to post the journal lines?';
}