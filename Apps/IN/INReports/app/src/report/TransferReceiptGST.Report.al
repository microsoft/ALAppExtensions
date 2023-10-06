// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GST.Base;
using Microsoft.Foundation.Address;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Transfer;
using System.Utilities;

report 18025 "Transfer Receipt GST"
{
    DefaultLayout = RDLC;
    RDLCLayout = './rdlc/TransferReceipt.rdl';
    Caption = 'Transfer Receipt';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Transfer Receipt Header"; "Transfer Receipt Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Transfer-from Code";
            RequestFilterHeading = 'Posted Transfer Receipt';

            column(No_TransRcptHdr; "No.")
            {
            }
            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = sorting(Number);

                dataitem(PageLoop; Integer)
                {
                    DataItemTableView = sorting(Number)
                                        where(Number = const(1));

                    column(CopyText; StrSubstNo(TransferReceiptLbl, CopyText))
                    {
                    }
                    column(TransferToAddr1; TransferToAddr[1])
                    {
                    }
                    column(TransferToAddr2; TransferToAddr[2])
                    {
                    }
                    column(TransferToAddr3; TransferToAddr[3])
                    {
                    }
                    column(TransferToAddr4; TransferToAddr[4])
                    {
                    }
                    column(TransferToAddr5; TransferToAddr[5])
                    {
                    }
                    column(TransferToAddr6; TransferToAddr[6])
                    {
                    }
                    column(InTransitCode_TransRcptHdr; "Transfer Receipt Header"."In-Transit Code")
                    {
                        IncludeCaption = true;
                    }
                    column(PostingDate_TransRcptHdr; "Transfer Receipt Header"."Posting Date")
                    {
                    }
                    column(No2_TransRcptHdr; "Transfer Receipt Header"."No.")
                    {
                    }
                    column(TransferToAddr7; TransferToAddr[7])
                    {
                    }
                    column(TransferToAddr8; TransferToAddr[8])
                    {
                    }
                    column(RcptDate_TransRcptHdr; "Transfer Receipt Header"."Receipt Date")
                    {
                        IncludeCaption = true;
                    }
                    column(TransferFromAddr8; TransferFromAddr[8])
                    {
                    }
                    column(TransferFromAddr7; TransferFromAddr[7])
                    {
                    }
                    column(TransferFromAddr6; TransferFromAddr[6])
                    {
                    }
                    column(TransferFromAddr5; TransferFromAddr[5])
                    {
                    }
                    column(TransferFromAddr4; TransferFromAddr[4])
                    {
                    }
                    column(TransferFromAddr3; TransferFromAddr[3])
                    {
                    }
                    column(TransferFromAddr2; TransferFromAddr[2])
                    {
                    }
                    column(TransferFromAddr1; TransferFromAddr[1])
                    {
                    }
                    column(PageCaption; StrSubstNo(PageLbl, ''))
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(TransRcptHdrNo2Caption; TransRcptHdrNo2CaptionLbl)
                    {
                    }
                    column(GSTComponentCode1; GSTComponentCode[1] + ' Amount')
                    {
                    }
                    column(GSTComponentCode2; GSTComponentCode[2] + ' Amount')
                    {
                    }
                    column(GSTComponentCode3; GSTComponentCode[3] + ' Amount')
                    {
                    }
                    column(GSTComponentCode4; GSTComponentCode[4] + 'Amount')
                    {
                    }
                    column(GSTCompAmount1; Abs(GSTCompAmount[1]))
                    {
                    }
                    column(GSTCompAmount2; Abs(GSTCompAmount[2]))
                    {
                    }
                    column(GSTCompAmount3; Abs(GSTCompAmount[3]))
                    {
                    }
                    column(GSTCompAmount4; Abs(GSTCompAmount[4]))
                    {
                    }
                    column(TransferGSTRegNo; TransferLocation."GST Registration No.")
                    {
                    }
                    column(ReceiptGSTRegNo; ReceiptLocation."GST Registration No.")
                    {
                    }
                    column(Supplier; SupplierLbl)
                    {
                    }
                    column(Receipt; ReceiptLbl)
                    {
                    }
                    column(Total; TotalLbl)
                    {
                    }
                    column(TotalWithTax; TotalWithTaxLbl)
                    {
                    }
                    column(CGSTAmt; Abs(CGSTAmt))
                    {
                    }
                    column(SGSTAmt; Abs(SGSTAmt))
                    {
                    }
                    column(IGSTAmt; Abs(IGSTAmt))
                    {
                    }
                    column(UGSTAmt; Abs(UGSTAmt))
                    {
                    }
                    column(CGSTLbl; CGSTLbl)
                    {
                    }
                    column(SGSTLbl; SGSTLbl)
                    {
                    }
                    column(IGSTLbl; IGSTLbl)
                    {
                    }
                    column(UGSTLbl; UGSTLbl)
                    {
                    }
                    dataitem(DimensionLoop1; Integer)
                    {
                        DataItemLinkReference = "Transfer Receipt Header";
                        DataItemTableView = sorting(Number)
                                            where(Number = filter(1 ..));

                        column(DimText; DimText)
                        {
                        }
                        column(DimensionLoop1Number; Number)
                        {
                        }
                        column(HdrDimCaption; HdrDimCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            DimText := GetDimensionText(DimSetEntry1, Number, Continue);
                            if not Continue then
                                CurrReport.Break();
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not ShowIntInfo then
                                CurrReport.Break();
                        end;
                    }
                    dataitem("Transfer Receipt Line"; "Transfer Receipt Line")
                    {
                        DataItemLink = "Document No." = field("No.");
                        DataItemLinkReference = "Transfer Receipt Header";
                        DataItemTableView = sorting("Document No.", "Line No.");

                        column(ShowInternalInfo; ShowIntInfo)
                        {
                        }
                        column(ItemNo_TransRcpLine; "Item No.")
                        {
                            IncludeCaption = true;
                        }
                        column(Desc_TransRcpLine; Description)
                        {
                            IncludeCaption = true;
                        }
                        column(Qty_TransRcpLine; Quantity)
                        {
                            IncludeCaption = true;
                        }
                        column(UOM_TransRcpLine; "Unit of Measure")
                        {
                            IncludeCaption = true;
                        }
                        column(Amount; "Transfer Receipt Line".Amount)
                        {
                        }
                        column(LineNo_TransRcpLine; "Line No.")
                        {
                        }
                        column(HSNSACCode; "Transfer Receipt Line"."HSN/SAC Code")
                        {
                        }
                        dataitem(DimensionLoop2; Integer)
                        {
                            DataItemTableView = sorting(Number)
                                                where(Number = filter(1 ..));

                            column(DimText2; DimText)
                            {
                            }
                            column(DimensionLoop2Number; Number)
                            {
                            }
                            column(LineDimCaption; LineDimCaptionLbl)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                DimText := GetDimensionText(DimSetEntry2, Number, Continue);
                                if not Continue then
                                    CurrReport.Break();
                            end;

                            trigger OnPreDataItem()
                            begin
                                if not ShowIntInfo then
                                    CurrReport.Break();
                            end;
                        }

                        trigger OnPreDataItem()
                        begin
                            MoreLines := FindLast();
                            while MoreLines and (Description = '') and ("Item No." = '') and (Quantity = 0) do
                                MoreLines := Next(-1) <> 0;

                            if not MoreLines then
                                CurrReport.Break();

                            SetRange("Line No.", 0, "Line No.");
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    if Number > 1 then begin
                        CopyText := CopyLbl;
                        OutputNo += 1;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := 1 + Abs(NoOfCopy);
                    CopyText := '';
                    SetRange(Number, 1, NoOfLoops);
                    OutputNo := 1;
                end;
            }

            trigger OnAfterGetRecord()
            var
                TransferReceiptLine: Record "Transfer Receipt Line";
            begin
                Clear(CGSTAmt);
                Clear(SGSTAmt);
                Clear(IGSTAmt);
                DimSetEntry1.SetRange("Dimension Set ID", "Dimension Set ID");
                FormatAddr.TransferRcptTransferFrom(TransferFromAddr, "Transfer Receipt Header");
                FormatAddr.TransferRcptTransferTo(TransferToAddr, "Transfer Receipt Header");
                TransferLocation.Get("Transfer Receipt Header"."Transfer-from Code");
                ReceiptLocation.Get("Transfer Receipt Header"."Transfer-to Code");
                TransferReceiptLine.SetRange("Document No.", "Transfer Receipt Header"."No.");
                if TransferReceiptLine.FindFirst() then
                    DetailedGSTLedgerEntry.Reset();

                DetailedGSTLedgerEntry.SetRange("Document No.", "TransferReceiptLine"."Document No.");
                if DetailedGSTLedgerEntry.FindSet() then
                    repeat
                        if DetailedGSTLedgerEntry."GST Component Code" = 'CGST' then
                            CGSTAmt += (DetailedGSTLedgerEntry."GST Amount");

                        if DetailedGSTLedgerEntry."GST Component Code" = 'SGST' then
                            SGSTAmt += (DetailedGSTLedgerEntry."GST Amount");

                        if DetailedGSTLedgerEntry."GST Component Code" = 'IGST' then
                            IGSTAmt += (DetailedGSTLedgerEntry."GST Amount");

                        if DetailedGSTLedgerEntry."GST Component Code" = 'UGST' then
                            UGSTAmt += (DetailedGSTLedgerEntry."GST Amount");
                    until DetailedGSTLedgerEntry.Next() = 0;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(NoOfCopies; NoOfCopy)
                    {
                        Caption = 'No. of Copies';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the number of copies that need to be printed.';
                    }
                    field(ShowInternalInfo; ShowIntInfo)
                    {
                        Caption = 'Show Internal Information';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the line internal information';
                    }
                }
            }
        }
    }

    labels
    {
        PostingDateCaption = 'Posting Date';
    }

    var
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        TransferLocation: Record "Location";
        ReceiptLocation: Record "Location";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        FormatAddr: Codeunit "Format Address";
        TransferFromAddr: array[8] of Text[50];
        TransferToAddr: array[8] of Text[50];
        MoreLines: Boolean;
        NoOfCopy: Integer;
        NoOfLoops: Integer;
        CopyText: Text[30];
        DimText: Text[120];
        ShowIntInfo: Boolean;
        Continue: Boolean;
        OutputNo: Integer;
        GSTComponentCode: array[20] of Code[10];
        GSTCompAmount: array[20] of Decimal;
        CGSTAmt: Decimal;
        SGSTAmt: Decimal;
        IGSTAmt: Decimal;
        UGSTAmt: Decimal;
        TransRcptHdrNo2CaptionLbl: Label 'Shipment No.';
        HdrDimCaptionLbl: Label 'Header Dimensions';
        LineDimCaptionLbl: Label 'Line Dimensions';
        CopyLbl: Label 'COPY';
        TransferReceiptLbl: Label 'Transfer Receipt %1', Comment = '%1 No. Of Copy';
        PageLbl: Label 'Page %1', Comment = '%1 No.';
        SupplierLbl: Label 'Supplier-GST Reg.No';
        ReceiptLbl: Label 'Receipt-GST Reg.No';
        TotalWithTaxLbl: Label 'Total Amount';
        TotalLbl: Label 'Amount';
        CGSTLbl: Label 'CGST Amount';
        SGSTLbl: Label 'SGST Amount';
        IGSTLbl: Label 'IGST Amount';
        UGSTLbl: Label 'UGST Amount';

    local procedure GetDimensionText(
        var DimSetEntry: Record "Dimension Set Entry";
        Number: Integer;
        var Continue: Boolean): Text[120]
    var
        DimensionText: Text[120];
        PrevDimText: Text[75];
        DimensionTextLbl: Label '%1; %2 - %3', Comment = ' %1 = DimText, %2 = Dimension Code, %3 = Dimension Value Code';
        DimensionLbl: Label '%1 - %2', Comment = '%1 = Dimension Code, %2 = Dimension Value Code';
    begin
        Continue := false;
        if Number = 1 then
            if not DimSetEntry.FindSet() then
                exit;

        repeat
            PrevDimText := CopyStr((DimensionText), 1, 75);
            if DimensionText = '' then
                DimensionText := StrSubstNo(DimensionLbl, DimSetEntry."Dimension Code", DimSetEntry."Dimension Value Code")
            else
                DimensionText := CopyStr(
                    StrSubstNo(
                        DimensionTextLbl,
                        DimensionText,
                        DimSetEntry."Dimension Code",
                        DimSetEntry."Dimension Value Code"),
                    1,
                    120);

            if StrLen(DimensionText) > MaxStrLen(PrevDimText) then begin
                Continue := true;
                exit(PrevDimText);
            end;
        until DimSetEntry.Next() = 0;

        exit(DimensionText)
    end;
}
