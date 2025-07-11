// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Shipping;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Transfer;
using System.Utilities;

report 18026 "Transfer Shipment GST"
{
    DefaultLayout = RDLC;
    RDLCLayout = './rdlc/TransferShipment.rdl';
    Caption = 'Transfer Shipment';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Transfer Shipment Header"; "Transfer Shipment Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Transfer-from Code", "Transfer-to Code";
            RequestFilterHeading = 'Posted Transfer Shipment';

            column(No_TransShptHeader; "No.")
            {
            }
            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = sorting(Number);

                dataitem(PageLoop; Integer)
                {
                    DataItemTableView = sorting(Number)
                                        where(Number = const(1));

                    column(CopyTextCaption; StrSubstNo(TransferShipmenLbl, CopyText))
                    {
                    }
                    column(TransferToAddr1; TransferToAddr[1])
                    {
                    }
                    column(TransferFromAddr1; TransferFromAddr[1])
                    {
                    }
                    column(TransferToAddr2; TransferToAddr[2])
                    {
                    }
                    column(TransferFromAddr2; TransferFromAddr[2])
                    {
                    }
                    column(TransferToAddr3; TransferToAddr[3])
                    {
                    }
                    column(TransferFromAddr3; TransferFromAddr[3])
                    {
                    }
                    column(TransferToAddr4; TransferToAddr[4])
                    {
                    }
                    column(TransferFromAddr4; TransferFromAddr[4])
                    {
                    }
                    column(TransferToAddr5; TransferToAddr[5])
                    {
                    }
                    column(TransferToAddr6; TransferToAddr[6])
                    {
                    }
                    column(InTransit_TransShptHeader; "Transfer Shipment Header"."In-Transit Code")
                    {
                        IncludeCaption = true;
                    }
                    column(PostDate_TransShptHeader; Format("Transfer Shipment Header"."Posting Date", 0, 4))
                    {
                    }
                    column(No2_TransShptHeader; "Transfer Shipment Header"."No.")
                    {
                    }
                    column(TransferToAddr7; TransferToAddr[7])
                    {
                    }
                    column(TransferToAddr8; TransferToAddr[8])
                    {
                    }
                    column(TransferFromAddr5; TransferFromAddr[5])
                    {
                    }
                    column(TransferFromAddr6; TransferFromAddr[6])
                    {
                    }
                    column(ShiptDate_TransShptHeader; Format("Transfer Shipment Header"."Shipment Date"))
                    {
                    }
                    column(TransferFromAddr7; TransferFromAddr[7])
                    {
                    }
                    column(TransferFromAddr8; TransferFromAddr[8])
                    {
                    }
                    column(PageCaption; StrSubstNo(PageLbl, ''))
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(Desc_ShptMethod; ShipmentMethod.Description)
                    {
                    }
                    column(TransShptHdrNoCaption; TransShptHdrNoCaptionLbl)
                    {
                    }
                    column(TransShptShptDateCaption; TransShptShptDateCaptionLbl)
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
                    column(IsGSTApplicable; IsGSTApplicable)
                    {
                    }
                    column(Amount; AmountLbl)
                    {
                    }
                    column(TotalTaxAmount; TotalTaxAmountLbl)
                    {
                    }
                    column(TransferFromRegCode; TransferFromRegNoLbl)
                    {
                    }
                    column(TransferToRegCode; TransferToRegNoLbl)
                    {
                    }
                    column(FromGSTRegNo; TransferFromCodeRegNo."GST Registration No.")
                    {
                    }
                    column(ToGSTRegNo; TransferToCodeRegNo."GST Registration No.")
                    {
                    }
                    column(HSNSAC; "Transfer Shipment Line"."HSN/SAC Code")
                    {
                    }
                    column(HSNSACCode; HSNSACCodeLbl)
                    {
                    }
                    dataitem(DimensionLoop1; Integer)
                    {
                        DataItemLinkReference = "Transfer Shipment Header";
                        DataItemTableView = sorting(Number)
                                            where(Number = filter(1 ..));

                        column(DimText; DimText)
                        {
                        }
                        column(Number_DimensionLoop1; Number)
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
                    dataitem("Transfer Shipment Line"; "Transfer Shipment Line")
                    {
                        DataItemLink = "Document No." = field("No.");
                        DataItemLinkReference = "Transfer Shipment Header";
                        DataItemTableView = sorting("Document No.", "Line No.");

                        column(ShowInternalInfo; ShowIntInfo)
                        {
                        }
                        column(NoOfCopies; NoOfCopy)
                        {
                        }
                        column(ItemNo_TransShptLine; "Item No.")
                        {
                            IncludeCaption = true;
                        }
                        column(Desc_TransShptLine; Description)
                        {
                            IncludeCaption = true;
                        }
                        column(Qty_TransShptLine; Quantity)
                        {
                            IncludeCaption = true;
                        }
                        column(UOM_TransShptLine; "Unit of Measure")
                        {
                            IncludeCaption = true;
                        }
                        column(LineNo_TransShptLine; "Line No.")
                        {
                        }
                        column(DocNo_TransShptLine; "Document No.")
                        {
                        }
                        column(GSTBaseAmount_TransferShipmentLine; Amount)
                        {
                        }
                        column(CGSTAmt; CGSTAmt)
                        {
                        }
                        column(SGSTAmt; SGSTAmt)
                        {
                        }
                        column(IGSTAmt; IGSTAmt)
                        {
                        }
                        column(UGSTAmt; UGSTAmt)
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
                        dataitem(DimensionLoop2; Integer)
                        {
                            DataItemTableView = sorting(Number)
                                                where(Number = filter(1 ..));
                            column(DimText4; DimText)
                            {
                            }
                            column(Number_DimensionLoop2; Number)
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
                        trigger OnAfterGetRecord()
                        begin
                            Clear(CGSTAmt);
                            Clear(SGSTAmt);
                            Clear(IGSTAmt);

                            DetailedGSTLedger.Reset();
                            DetailedGSTLedger.SetRange("Document No.", "Transfer Shipment Line"."Document No.");
                            if DetailedGSTLedger.FindSet() then
                                repeat
                                    if DetailedGSTLedger."GST Component Code" = 'CGST' then
                                        CGSTAmt += Abs(DetailedGSTLedger."GST Amount");

                                    if DetailedGSTLedger."GST Component Code" = 'SGST' then
                                        SGSTAmt += Abs(DetailedGSTLedger."GST Amount");

                                    if DetailedGSTLedger."GST Component Code" = 'IGST' then
                                        IGSTAmt += Abs(DetailedGSTLedger."GST Amount");

                                    if DetailedGSTLedger."GST Component Code" = 'UGST' then
                                        UGSTAmt += Abs(DetailedGSTLedger."GST Amount");
                                until DetailedGSTLedger.Next() = 0;
                        end;

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
            begin
                DimSetEntry1.SetRange("Dimension Set ID", "Dimension Set ID");

                FormatAddr.TransferShptTransferFrom(TransferFromAddr, "Transfer Shipment Header");
                FormatAddr.TransferShptTransferTo(TransferToAddr, "Transfer Shipment Header");

                if not ShipmentMethod.Get("Shipment Method Code") then
                    ShipmentMethod.Init();

                IsGSTApplicable := CheckGSTDoc("Transfer Shipment Line");
                TransferFromCodeRegNo.Get("Transfer Shipment Header"."Transfer-from Code");
                TransferToCodeRegNo.Get("Transfer Shipment Header"."Transfer-to Code");
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
        ShptMethodCaption = 'Shipment Method';
    }

    var
        ShipmentMethod: Record "Shipment Method";
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        TransferFromCodeRegNo: Record "Location";
        TransferToCodeRegNo: Record "Location";
        DetailedGSTLedger: Record "Detailed GST Ledger Entry";
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
        GSTCompAmount: array[20] of Decimal;
        GSTComponentCode: array[20] of Code[10];
        IsGSTApplicable: Boolean;
        CGSTAmt: Decimal;
        SGSTAmt: Decimal;
        IGSTAmt: Decimal;
        UGSTAmt: Decimal;
        TransShptHdrNoCaptionLbl: Label 'Shipment No.';
        TransShptShptDateCaptionLbl: Label 'Shipment Date';
        HdrDimCaptionLbl: Label 'Header Dimensions';
        LineDimCaptionLbl: Label 'Line Dimensions';
        CopyLbl: Label 'COPY';
        TransferShipmenLbl: Label 'Transfer Shipment %1', Comment = '%1 No. Of Copy';
        PageLbl: Label 'Page %1', Comment = '%1 No.';
        AmountLbl: Label 'Amount';
        TotalTaxAmountLbl: Label 'Total Amount';
        TransferFromRegNoLbl: Label 'Recipient GST Reg. No.';
        TransferToRegNoLbl: Label 'Supplier GST Reg. No.';
        HSNSACCodeLbl: Label 'HSN/SAC Code';
        CGSTLbl: Label 'CGST Amount';
        SGSTLbl: Label 'SGST Amount';
        IGSTLbl: Label 'IGST Amount';
        UGSTLbl: Label 'UGST Amount';

    local procedure CheckGSTDoc(TransferLine: Record "Transfer Shipment Line"): Boolean
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        TaxTransactionValue.Reset();
        TaxTransactionValue.SetRange("Tax Record ID", TransferLine.RecordId);
        TaxTransactionValue.SetRange("Tax Type", 'GST');
        if not TaxTransactionValue.IsEmpty then
            exit(true);
    end;

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
