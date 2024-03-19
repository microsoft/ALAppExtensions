// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Vendor;

codeunit 148004 "Library IRS 1099 Form Box"
{
    var
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryIRSReportingPeriod: Codeunit "Library IRS Reporting Period";
        LibraryUtility: Codeunit "Library - Utility";
        IRS1099VendorFormBox: Codeunit "IRS 1099 Vendor Form Box";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit "Assert";

    procedure CreateSingleFormInReportingPeriod(ReportingDate: Date): Code[20]
    begin
        exit(CreateSingleFormInReportingPeriod(ReportingDate, ReportingDate));
    end;

    procedure CreateSingleFormInReportingPeriod(StartingDate: Date; EndingDate: Date): Code[20]
    var
        IRS1099Form: Record "IRS 1099 Form";
    begin
        IRS1099Form.Validate("Period No.", LibraryIRSReportingPeriod.GetReportingPeriod(StartingDate, EndingDate));
        IRS1099Form.Validate("No.", LibraryUtility.GenerateGUID());
        IRS1099Form.Insert(true);
        exit(IRS1099Form."No.");
    end;

    procedure CreateSingleFormBoxInReportingPeriod(ReportingDate: Date; FormNo: Code[20]): Code[20]
    begin
        exit(CreateSingleFormBoxInReportingPeriod(ReportingDate, ReportingDate, FormNo));
    end;

    procedure CreateSingleFormBoxInReportingPeriod(StartingDate: Date; EndingDate: Date; FormNo: Code[20]): Code[20]
    var
        IRS1099FormBox: Record "IRS 1099 Form Box";
    begin
        IRS1099FormBox.Validate("Period No.", LibraryIRSReportingPeriod.GetReportingPeriod(StartingDate, EndingDate));
        IRS1099FormBox.Validate("Form No.", FormNo);
        IRS1099FormBox.Validate("No.", LibraryUtility.GenerateGUID());
        IRS1099FormBox.Insert(true);
        exit(IRS1099FormBox."No.");
    end;

    procedure CreateVendorNoWithFormBox(ReportingDate: Date; FormNo: Code[20]; FormBoxNo: Code[20]): Code[20]
    begin
        exit(CreateVendorNoWithFormBox(ReportingDate, ReportingDate, FormNo, FormBoxNo));
    end;

    procedure CreateVendorNoWithFormBox(StartingDate: Date; EndingDate: Date; FormNo: Code[20]; FormBoxNo: Code[20]): Code[20]
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        AssignFormBoxForVendorInPeriod(Vendor."No.", StartingDate, EndingDate, FormNo, FormBoxNo);
        exit(Vendor."No.");
    end;

    procedure AddAdjustmentAmountForVendor(PostingDate: Date; VendorNo: Code[20]; FormNo: Code[20]; FormBoxNo: Code[20]; Amount: Decimal)
    begin
        AddAdjustmentAmountForVendor(PostingDate, PostingDate, VendorNo, FormNo, FormBoxNo, Amount);
    end;

    procedure AddAdjustmentAmountForVendor(StartingDate: Date; EndingDate: Date; VendorNo: Code[20]; FormNo: Code[20]; FormBoxNo: Code[20]; Amount: Decimal)
    var
        IRS1099VendorFormBoxAdj: Record "IRS 1099 Vendor Form Box Adj.";
    begin
        IRS1099VendorFormBoxAdj.Validate("Period No.", LibraryIRSReportingPeriod.GetReportingPeriod(StartingDate, EndingDate));
        IRS1099VendorFormBoxAdj.Validate("Vendor No.", VendorNo);
        IRS1099VendorFormBoxAdj.Validate("Form No.", FormNo);
        IRS1099VendorFormBoxAdj.Validate("Form Box No.", FormBoxNo);
        IRS1099VendorFormBoxAdj.Validate(Amount, Amount);
        IRS1099VendorFormBoxAdj.Insert(true);
    end;

    procedure GetVendorFormBoxAmount(var TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary; PeriodNo: Code[20]; FormNo: Code[20]; VendorNo: Code[20])
    var
        IRS1099CalcParameters: Record "IRS 1099 Calc. Params";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
    begin
        IRS1099CalcParameters."Period No." := PeriodNo;
        IRS1099CalcParameters."Form No." := FormNo;
        IRS1099CalcParameters."Vendor No." := VendorNo;
        IRSFormsFacade.GetVendorFormBoxAmount(TempVendFormBoxBuffer, IRS1099CalcParameters);
    end;

    procedure AssignFormBoxForVendorInPeriod(VendNo: Code[20]; StartingDate: Date; EndingDate: Date; FormNo: Code[20]; FormBoxNo: Code[20])
    var
        IRS1099VendorFormBoxSetupRec: Record "IRS 1099 Vendor Form Box Setup";
    begin
        IRS1099VendorFormBoxSetupRec.Validate("Period No.", LibraryIRSReportingPeriod.GetReportingPeriod(StartingDate, EndingDate));
        IRS1099VendorFormBoxSetupRec.Validate("Vendor No.", VendNo);
        IRS1099VendorFormBoxSetupRec.Validate("Form No.", FormNo);
        IRS1099VendorFormBoxSetupRec.Validate("Form Box No.", FormBoxNo);
        IRS1099VendorFormBoxSetupRec.Insert(true);
    end;

    procedure MockConnectedEntriesForVendFormBoxBuffer(var TempIRS1099VendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary) Result: List of [Integer]
    begin
        Result.Add(MockConnectedEntryForVendFormBoxBuffer(TempIRS1099VendFormBoxBuffer));
        Result.Add(MockConnectedEntryForVendFormBoxBuffer(TempIRS1099VendFormBoxBuffer));
    end;

    procedure MockConnectedEntryForVendFormBoxBuffer(var TempIRS1099VendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary) VendLedgEntryNo: Integer
    var
        CurrIRS1099VendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer";
        EntryNo: Integer;
    begin
        CurrIRS1099VendFormBoxBuffer.Copy(TempIRS1099VendFormBoxBuffer);
        TempIRS1099VendFormBoxBuffer.Reset();
        if TempIRS1099VendFormBoxBuffer.FindLast() then
            EntryNo := TempIRS1099VendFormBoxBuffer."Entry No.";
        EntryNo += 1;
        TempIRS1099VendFormBoxBuffer."Entry No." := EntryNo;
        TempIRS1099VendFormBoxBuffer."Parent Entry No." := CurrIRS1099VendFormBoxBuffer."Entry No.";
        TempIRS1099VendFormBoxBuffer."Buffer Type" := TempIRS1099VendFormBoxBuffer."Buffer Type"::"Ledger Entry";
        TempIRS1099VendFormBoxBuffer."Vendor Ledger Entry No." := LibraryRandom.RandInt(100);
        TempIRS1099VendFormBoxBuffer.Insert();
        VendLedgEntryNo := TempIRS1099VendFormBoxBuffer."Vendor Ledger Entry No.";
        TempIRS1099VendFormBoxBuffer.Copy(CurrIRS1099VendFormBoxBuffer);
        exit(VendLedgEntryNo);
    end;

    procedure SuggestVendorsForFormBoxSetup(StartingDate: Date; EndingDate: Date)
    begin
        IRS1099VendorFormBox.SuggestVendorsForFormBoxSetup(LibraryIRSReportingPeriod.GetReportingPeriod(StartingDate, EndingDate));
    end;

    procedure PropagateVendorFormBoxSetupToVendorLedgerEntries(StartingDate: Date; EndingDate: Date; VendorNo: Code[20]; FormNo: Code[20]; FormBoxNo: Code[20])
    var
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
    begin
        IRS1099VendorFormBoxSetup.Get(LibraryIRSReportingPeriod.GetReportingPeriod(StartingDate, EndingDate), VendorNo);
        IRS1099VendorFormBox.PropagateVendorFormBoxSetupToExistingEntries(IRS1099VendorFormBoxSetup);
    end;

    procedure VerifyFormBoxSetupCountForVendors(StartingDate: Date; EndingDate: Date; ExpectedCount: Integer)
    var
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
    begin
        IRS1099VendorFormBoxSetup.SetRange("Period No.", LibraryIRSReportingPeriod.GetReportingPeriod(StartingDate, EndingDate));
        Assert.RecordCount(IRS1099VendorFormBoxSetup, ExpectedCount);
    end;

    procedure VerifyCurrTempVendFormBoxBufferIncludedIn1099(var TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary; PeriodNo: Code[20]; FormNo: Code[20]; FormBoxNo: Code[20]; VendorNo: Code[20]; ExpectedAmount: Decimal)
    begin
        VerifyCurrTempVendFormBoxBuffer(TempVendFormBoxBuffer, PeriodNo, FormNo, FormBoxNo, VendorNo, ExpectedAmount, ExpectedAmount, true);
    end;

    procedure VerifyCurrTempVendFormBoxBuffer(var TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary; PeriodNo: Code[20]; FormNo: Code[20]; FormBoxNo: Code[20]; VendorNo: Code[20]; ExpectedAmount: Decimal; IncludeIn1099: Boolean)
    begin
        VerifyCurrTempVendFormBoxBuffer(TempVendFormBoxBuffer, PeriodNo, FormNo, FormBoxNo, VendorNo, ExpectedAmount, ExpectedAmount, IncludeIn1099);
    end;

    procedure VerifyCurrTempVendFormBoxBuffer(var TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary; PeriodNo: Code[20]; FormNo: Code[20]; FormBoxNo: Code[20]; VendorNo: Code[20]; ExpectedAmount: Decimal; ExpectedReportingAmount: Decimal; IncludeIn1099: Boolean)
    begin
        TempVendFormBoxBuffer.SetRange("Period No.", PeriodNo);
        TempVendFormBoxBuffer.SetRange("Form No.", FormNo);
        TempVendFormBoxBuffer.SetRange("Form Box No.", FormBoxNo);
        TempVendFormBoxBuffer.SetRange("Vendor No.", VendorNo);
        TempVendFormBoxBuffer.FindFirst();
        Assert.RecordCount(TempVendFormBoxBuffer, 1);
        TempVendFormBoxBuffer.TestField("Amount", ExpectedAmount);
        TempVendFormBoxBuffer.TestField("Reporting Amount", ExpectedReportingAmount);
        TempVendFormBoxBuffer.TestField("Include in 1099", IncludeIn1099);
        TempVendFormBoxBuffer.Reset();
    end;

    procedure VerifyConnectedEntryInVendFormBoxBuffer(var TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary; ExpectedEntryNo: Integer)
    begin
        TempVendFormBoxBuffer.SetRange("Parent Entry No.", TempVendFormBoxBuffer."Entry No.");
        TempVendFormBoxBuffer.SetRange("Buffer Type", TempVendFormBoxBuffer."Buffer Type"::"Ledger Entry");
        TempVendFormBoxBuffer.FindFirst();
        TempVendFormBoxBuffer.TestField("Vendor Ledger Entry No.", ExpectedEntryNo);
        TempVendFormBoxBuffer.Reset();
    end;
}
