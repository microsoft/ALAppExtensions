// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Payables;

page 10072 "IRS 1099 Vendor Overview"
{
    PageType = List;
    SourceTable = "IRS 1099 Vend. Form Box Buffer";
    SourceTableTemporary = true;
    ApplicationArea = BasicUS;
    UsageCategory = ReportsAndAnalysis;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(ReportingPeriod)
            {
                ShowCaption = false;
                field(IRSReportingPeriodNoField; IRSReportingPeriodNo)
                {
                    Caption = 'Reporting Period No.';
                    ToolTip = 'Specifies the reporting period to filter the data.';
                    ApplicationArea = BasicUS;
                    TableRelation = "IRS Reporting Period";
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        RefreshData();
                    end;
                }
            }
            repeater(Group)
            {
                Editable = false;
                field("Vendor No."; Rec."Vendor No.")
                {
                    Tooltip = 'Specifies the vendor number.';
                }
                field("Form No."; Rec."Form No.")
                {
                    Tooltip = 'Specifies the number of the 1099 form.';
                }
                field("Form Box No."; Rec."Form Box No.")
                {
                    Tooltip = 'Specifies the number of the 1099 form box.';
                }
                field(Amount; Rec.Amount)
                {
                    Tooltip = 'Specifies the total amount of all transactions for the vendor, form number and form box number in the selected reporting period.';

                    trigger OnDrillDown()
                    begin
                        ShowRelatedVendorLedgerEntries();
                    end;
                }
            }
        }
    }

    var

    var
        TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary;
        IRSReportingPeriodNo: Code[20];

    trigger OnOpenPage()
    var
        IRSReportingPeriod: Codeunit "IRS Reporting Period";
    begin
        IRSReportingPeriodNo := IRSReportingPeriod.GetReportingPeriod(WorkDate());
        RefreshData();
    end;

    local procedure RefreshData()
    var
        IRS1099CalcParameters: Record "IRS 1099 Calc. Params";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
        NoDataForSelectedPeriodMsg: Label 'No data found for the selected reporting period.';
    begin
        Rec.Reset();
        Rec.DeleteAll();
        TempVendFormBoxBuffer.Reset();
        TempVendFormBoxBuffer.DeleteAll();
        IRS1099CalcParameters."Period No." := IRSReportingPeriodNo;
        IRSFormsFacade.GetVendorFormBoxAmount(TempVendFormBoxBuffer, IRS1099CalcParameters);
        TempVendFormBoxBuffer.SetRange("Buffer Type", TempVendFormBoxBuffer."Buffer Type"::Amount);
        if not TempVendFormBoxBuffer.FindSet() then begin
            Message(NoDataForSelectedPeriodMsg);
            exit;
        end;
        repeat
            Rec := TempVendFormBoxBuffer;
            Rec.Insert();
        until TempVendFormBoxBuffer.Next() = 0;
        Rec.Reset();
        if Rec.FindFirst() then;
    end;

    local procedure ShowRelatedVendorLedgerEntries()
    var
        VendorLedgEntry: Record "Vendor Ledger Entry";
        TempVendorLedgEntry: Record "Vendor Ledger Entry" temporary;
    begin
        if Rec.Amount = 0 then
            exit;
        TempVendFormBoxBuffer.Reset();
        TempVendFormBoxBuffer.SetRange("Parent Entry No.", Rec."Entry No.");
        TempVendFormBoxBuffer.SetRange("Buffer Type", TempVendFormBoxBuffer."Buffer Type"::"Ledger Entry");
        if not TempVendFormBoxBuffer.FindSet() then
            exit;
        repeat
            VendorLedgEntry.Get(TempVendFormBoxBuffer."Vendor Ledger Entry No.");
            TempVendorLedgEntry := VendorLedgEntry;
            TempVendorLedgEntry.Insert();
        until TempVendFormBoxBuffer.Next() = 0;
        Page.Run(0, TempVendorLedgEntry);
    end;
}