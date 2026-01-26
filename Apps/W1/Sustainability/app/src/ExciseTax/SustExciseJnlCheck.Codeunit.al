// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ExciseTax;

using Microsoft.Finance.Dimension;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sustainability.Setup;
using System.Utilities;

codeunit 6273 "Sust. Excise Jnl.-Check"
{

    procedure CheckCommonConditionsBeforePosting(var SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line")
    begin
        if SustainabilityExciseJnlLine."Line No." = 0 then
            Error(SustainabilityExciseJnlLineEmptyErr);

        // This condition should be met by design, but checking in case of customization
        if not (SustainabilityExciseJnlLine.GetRangeMax("Journal Template Name") = SustainabilityExciseJnlLine.GetRangeMin("Journal Template Name")) then
            Error(SustainabilityExciseJournalTemplateMismatchErr);

        if not (SustainabilityExciseJnlLine.GetRangeMax("Journal Batch Name") = SustainabilityExciseJnlLine.GetRangeMin("Journal Batch Name")) then
            Error(SustainabilityExciseJournalBatchMismatchErr);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure CheckSustainabilityExciseJournalLineWithErrorCollect(SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line"; var TempErrorMessages: Record "Error Message" temporary)
    var
        ErrorMessageManagement: Codeunit "Error Message Management";
    begin
        if not TryCheckJournalLine(SustainabilityExciseJnlLine) then
            ErrorMessageManagement.InsertTempLineErrorMessage(TempErrorMessages, SustainabilityExciseJnlLine.RecordId(), Database::"Sust. Excise Jnl. Line", 0, GetLastErrorText(), GetLastErrorCallStack());

        ErrorMessageManagement.CollectErrors(TempErrorMessages);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure CheckAllExciseJournalLinesWithErrorCollect(var SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line"; var TempErrorMessages: Record "Error Message" temporary)
    begin
        if SustainabilityExciseJnlLine.FindSet() then
            repeat
                CheckSustainabilityExciseJournalLineWithErrorCollect(SustainabilityExciseJnlLine, TempErrorMessages);
            until SustainabilityExciseJnlLine.Next() = 0;
    end;

    procedure CheckSustainabilityExciseJournalLine(SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line")
    var
        SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch";
    begin
        SustainabilityExciseJnlBatch.Get(SustainabilityExciseJnlLine."Journal Template Name", SustainabilityExciseJnlLine."Journal Batch Name");
        SustainabilityExciseJnlLine.TestField("Posting Date", ErrorInfo.Create());
        SustainabilityExciseJnlLine.TestField("Document Type", ErrorInfo.Create());
        SustainabilityExciseJnlLine.TestField("Document No.", ErrorInfo.Create());
        SustainabilityExciseJnlLine.TestField(Description, ErrorInfo.Create());
        SustainabilityExciseJnlLine.TestField("Source No.", ErrorInfo.Create());

        SustainabilityExciseJnlLine.Validate("Document Type");
        TestRequiredFieldsFromSetupForJnlLine(SustainabilityExciseJnlLine);

        if SustainabilityExciseJnlBatch.Type <> SustainabilityExciseJnlBatch.Type::EPR then
            SustainabilityExciseJnlLine.TestField("Material Breakdown No.", '');

        if SustainabilityExciseJnlBatch.Type <> SustainabilityExciseJnlBatch.Type::CBAM then begin
            SustainabilityExciseJnlLine.TestField("Emission Verified", false);
            SustainabilityExciseJnlLine.TestField("CBAM Compliance", false);
            SustainabilityExciseJnlLine.TestField("Total Embedded CO2e Emission", 0);
            SustainabilityExciseJnlLine.TestField("CO2e Unit of Measure", '');
            SustainabilityExciseJnlLine.TestField("CBAM Certificates Required", false);
            SustainabilityExciseJnlLine.TestField("Carbon Pricing Paid", false);
            SustainabilityExciseJnlLine.TestField("Already Paid Emission", 0);
            SustainabilityExciseJnlLine.TestField("Adjusted CBAM Cost", 0);
            SustainabilityExciseJnlLine.TestField("Certificate Amount", 0);
        end;

        TestEmissionAmount(SustainabilityExciseJnlLine);

        TestDimensionsForJnlLine(SustainabilityExciseJnlLine);

        OnAfterCheckSustainabilityExciseJournalLine(SustainabilityExciseJnlLine);
    end;

    [TryFunction]
    local procedure TryCheckJournalLine(SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line")
    var
        SustainabilityExciseJnlCheck: Codeunit "Sust. Excise Jnl.-Check";
    begin
        SustainabilityExciseJnlCheck.CheckSustainabilityExciseJournalLine(SustainabilityExciseJnlLine);
    end;

    local procedure TestEmissionAmount(SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line")
    begin
        if AllEmissionsZeroCheck(SustainabilityExciseJnlLine) then
            Error(ErrorInfo.Create(AllEmissionsZeroErr, true, SustainabilityExciseJnlLine));
    end;

    local procedure AllEmissionsZeroCheck(SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line"): Boolean
    begin
        if (SustainabilityExciseJnlLine."Total Emission Cost" = 0) and (SustainabilityExciseJnlLine."Total Embedded CO2e Emission" = 0) then
            exit(true);
    end;

    local procedure TestRequiredFieldsFromSetupForJnlLine(SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line")
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustainabilitySetup.Get();
        if SustainabilitySetup."Country/Region Mandatory" then
            SustainabilityExciseJnlLine.TestField("Country/Region Code", ErrorInfo.Create());

        if SustainabilitySetup."Resp. Center Mandatory" then
            SustainabilityExciseJnlLine.TestField("Responsibility Center", ErrorInfo.Create());
    end;

    local procedure TestDimensionsForJnlLine(SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line")
    var
        DimMgt: Codeunit DimensionManagement;
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        if not DimMgt.CheckDimIDComb(SustainabilityExciseJnlLine."Dimension Set ID") then
            Error(ErrorInfo.Create(DimMgt.GetDimCombErr(), true, SustainabilityExciseJnlLine));

        if SustainabilityExciseJnlLine."Partner Type" = SustainabilityExciseJnlLine."Partner Type"::Customer then begin
            TableID[1] := Database::Customer;
            No[1] := SustainabilityExciseJnlLine."Partner No.";
        end;

        if SustainabilityExciseJnlLine."Partner Type" = SustainabilityExciseJnlLine."Partner Type"::Vendor then begin
            TableID[1] := Database::Vendor;
            No[1] := SustainabilityExciseJnlLine."Partner No.";
        end;

        TableID[2] := SustainabilityExciseJnlLine.ExciseLineTypeToTableID(SustainabilityExciseJnlLine."Source Type");
        No[2] := SustainabilityExciseJnlLine."Source No.";

        if not DimMgt.CheckDimValuePosting(TableID, No, SustainabilityExciseJnlLine."Dimension Set ID") then
            Error(ErrorInfo.Create(DimMgt.GetDimValuePostingErr(), true, SustainabilityExciseJnlLine));
    end;

    var
        SustainabilityExciseJnlLineEmptyErr: Label 'There is nothing to post.';
        SustainabilityExciseJournalTemplateMismatchErr: Label 'The journal template name must be the same for all lines.';
        SustainabilityExciseJournalBatchMismatchErr: Label 'The journal batch name must be the same for all lines.';
        AllEmissionsZeroErr: Label 'At least one emission must be specified.';

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckSustainabilityExciseJournalLine(SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line")
    begin
    end;
}