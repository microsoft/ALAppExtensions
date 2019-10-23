// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148088 "MTDTestMisc"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Making Tax Digital]
    end;

    var
        LibraryMakingTaxDigital: Codeunit "Library - Making Tax Digital";
        Assert: Codeunit Assert;

    [Test]
    [Scope('OnPrem')]
    procedure MTDPayment_DiffersFromPayment()
    var
        MTDPayment: array[2] of Record "MTD Payment";
    begin
        // [FEATURE] [UT] [VAT Payment]
        // [SCENARIO 258181] TAB 10531 MTDPayment.DiffersFromPayment()
        MockAndGetVATPayment(MTDPayment[1], WorkDate(), WorkDate(), 1, WorkDate(), 1);

        MTDPayment[2] := MTDPayment[1];
        Assert.Isfalse(MTDPayment[1].DiffersFromPayment(MTDPayment[2]), '');

        MTDPayment[2]."Received Date" += 1;
        Assert.IsTrue(MTDPayment[1].DiffersFromPayment(MTDPayment[2]), '');

        MTDPayment[2] := MTDPayment[1];
        MTDPayment[2].Amount += 0.01;
        Assert.IsTrue(MTDPayment[1].DiffersFromPayment(MTDPayment[2]), '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure MTDLiability_DiffersFromLiability()
    var
        MTDLiability: array[2] of Record "MTD Liability";
    begin
        // [FEATURE] [UT] [VAT Liability]
        // [SCENARIO 258181] TAB 10530 MTDLiability.DiffersFromLiability()
        MockAndGetVATLiability(MTDLiability[1], WorkDate(), WorkDate(), 1, 1, WorkDate());

        MTDLiability[2] := MTDLiability[1];
        Assert.Isfalse(MTDLiability[1].DiffersFromLiability(MTDLiability[2]), '');

        MTDLiability[2]."Original Amount" += 0.01;
        Assert.IsTrue(MTDLiability[1].DiffersFromLiability(MTDLiability[2]), '');

        MTDLiability[2] := MTDLiability[1];
        MTDLiability[2]."Outstanding Amount" += 0.01;
        Assert.IsTrue(MTDLiability[1].DiffersFromLiability(MTDLiability[2]), '');

        MTDLiability[2] := MTDLiability[1];
        MTDLiability[2]."Due Date" += 1;
        Assert.IsTrue(MTDLiability[1].DiffersFromLiability(MTDLiability[2]), '');
    end;

    local procedure MockAndGetVATPayment(var MTDPayment: Record "MTD Payment"; StartDate: Date; EndDate: Date; EntryNo: Integer; ReceivedDate: Date; NewAmount: Decimal)
    begin
        LibraryMakingTaxDigital.MockVATPayment(MTDPayment, StartDate, EndDate, EntryNo, ReceivedDate, NewAmount);
    end;

    local procedure MockAndGetVATLiability(var MTDLiability: Record "MTD Liability"; StartDate: Date; EndDate: Date; OriginalAmount: Decimal; OutstandingAmount: Decimal; DueDate: Date)
    begin
        LibraryMakingTaxDigital.MockVATLiability(
          MTDLiability, StartDate, EndDate, MTDLiability.Type::"VAT Return Debit Charge", OriginalAmount, OutstandingAmount, DueDate);
    end;
}
