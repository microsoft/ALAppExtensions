// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Shipping;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Transfer;
using System.Utilities;

report 18024 "Transfer Order GST"
{
    DefaultLayout = RDLC;
    RDLCLayout = './rdlc/TransferOrder.rdl';
    Caption = 'Transfer Order';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Transfer Header"; "Transfer Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Transfer-from Code", "Transfer-to Code";
            RequestFilterHeading = 'Transfer Order';

            column(No_TransferHdr; "No.")
            {
            }
            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = sorting(Number);

                dataitem(PageLoop; Integer)
                {
                    DataItemTableView = sorting(Number)
                                        where(Number = const(1));

                    column(CopyCaption; StrSubstNo(TransferOrdeLbl, CopyText))
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
                    column(InTransitCode_TransHdr; "Transfer Header"."In-Transit Code")
                    {
                        IncludeCaption = true;
                    }
                    column(PostingDate_TransHdr; Format("Transfer Header"."Posting Date", 0, 4))
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
                    column(PageCaption; StrSubstNo(PageLbl, ''))
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(ShptMethodDesc; ShipmentMethod.Description)
                    {
                    }
                    column(GSTComponentCode1; GSTComponentCodeName[2] + ' Amount')
                    {
                    }
                    column(GSTComponentCode2; GSTComponentCodeName[3] + ' Amount')
                    {
                    }
                    column(GSTComponentCode3; GSTComponentCodeName[5] + ' Amount')
                    {
                    }
                    column(GSTComponentCode4; GSTComponentCodeName[6] + ' Amount')
                    {
                    }
                    column(GSTCompAmount1; Abs(GSTCompAmount[2]))
                    {
                    }
                    column(GSTCompAmount2; Abs(GSTCompAmount[3]))
                    {
                    }
                    column(GSTCompAmount3; Abs(GSTCompAmount[5]))
                    {
                    }
                    column(GSTCompAmount4; Abs(GSTCompAmount[6]))
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
                    column(HSNSAC; HSNSACCodeLbl)
                    {
                    }
                    dataitem(DimensionLoop1; Integer)
                    {
                        DataItemLinkReference = "Transfer Header";
                        DataItemTableView = sorting(Number)
                                            where(Number = filter(1 ..));

                        column(DimText; DimText)
                        {
                        }
                        column(Number_DimensionLoop1; Number)
                        {
                        }
                        column(HdrDimensionsCaption; HdrDimensionsCaptionLbl)
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
                    dataitem("Transfer Line"; "Transfer Line")
                    {
                        DataItemLink = "Document No." = field("No.");
                        DataItemLinkReference = "Transfer Header";
                        DataItemTableView = sorting("Document No.", "Line No.")
                                            where("Derived From Line No." = const(0));

                        column(ItemNo_TransLine; "Item No.")
                        {
                            IncludeCaption = true;
                        }
                        column(Desc_TransLine; Description)
                        {
                            IncludeCaption = true;
                        }
                        column(Qty_TransLine; Quantity)
                        {
                            IncludeCaption = true;
                        }
                        column(UOM_TransLine; "Unit of Measure")
                        {
                            IncludeCaption = true;
                        }
                        column(Qty_TransLineShipped; "Quantity Shipped")
                        {
                            IncludeCaption = true;
                        }
                        column(QtyReceived_TransLine; "Quantity Received")
                        {
                            IncludeCaption = true;
                        }
                        column(TransFromBinCode_TransLine; "Transfer-from Bin Code")
                        {
                            IncludeCaption = true;
                        }
                        column(TransToBinCode_TransLine; "Transfer-To Bin Code")
                        {
                            IncludeCaption = true;
                        }
                        column(LineNo_TransLine; "Line No.")
                        {
                        }
                        column(Amount_TransLine; "Transfer Line".Amount)
                        {
                        }
                        column(TransferPrice_TransferLine; "Transfer Line"."Transfer Price")
                        {
                        }
                        column(HSNSACCode; "Transfer Line"."HSN/SAC Code")
                        {
                        }
                        dataitem(DimensionLoop2; Integer)
                        {
                            DataItemTableView = sorting(Number)
                                                where(Number = filter(1 ..));

                            column(DimText2; DimText)
                            {
                            }
                            column(Number_DimensionLoop2; Number)
                            {
                            }
                            column(LineDimensionsCaption; LineDimensionsCaptionLbl)
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
                            if IsGSTApplicable then begin
                                j := 1;
                                TaxTrnasactionValue.Reset();
                                TaxTrnasactionValue.SetRange("Tax Record ID", "Transfer Line".RecordId);
                                TaxTrnasactionValue.SetRange("Value Type", TaxTrnasactionValue."Value Type"::COMPONENT);
                                TaxTrnasactionValue.SetFilter(Percent, '<>%1', 0);
                                if TaxTrnasactionValue.FindSet() then
                                    repeat
                                        j := TaxTrnasactionValue."Value ID";
                                        GSTComponentCode[j] := TaxTrnasactionValue."Value ID";
                                        TaxTrnasactionValue1.Reset();
                                        TaxTrnasactionValue1.SetRange("Tax Record ID", "Transfer Line".RecordId);
                                        TaxTrnasactionValue1.SetRange("Tax Type", 'GST');
                                        TaxTrnasactionValue1.SetRange("Value Type", TaxTrnasactionValue1."Value Type"::COMPONENT);
                                        TaxTrnasactionValue1.SetRange("Value ID", GSTComponentCode[j]);
                                        if TaxTrnasactionValue1.FindSet() then
                                            repeat
                                                GSTCompAmount[j] += TaxTrnasactionValue1.Amount;
                                            until TaxTrnasactionValue1.Next() = 0;
                                        j += 1;
                                    until TaxTrnasactionValue.Next() = 0;
                            end;
                            TaxTrnasactionValue.Reset();
                            TaxTrnasactionValue.SetRange("Tax Record ID", "Transfer Line".RecordId);
                            TaxTrnasactionValue.SetRange("Tax Type", 'GST');
                            TaxTrnasactionValue.SetRange("Value Type", TaxTrnasactionValue."Value Type"::COMPONENT);
                            TaxTrnasactionValue.SetFilter(Percent, '<>%1', 0);
                            if TaxTrnasactionValue.FindSet() then
                                repeat
                                    j := TaxTrnasactionValue."Value ID";
                                    case TaxTrnasactionValue."Value ID" of
                                        6:
                                            GSTComponentCodeName[j] := 'SGST';
                                        2:
                                            GSTComponentCodeName[j] := 'CGST';
                                        3:
                                            GSTComponentCodeName[j] := 'IGST';
                                        5:
                                            GSTComponentCodeName[j] := 'UTGST';
                                    end;
                                    j += 1;
                                until TaxTrnasactionValue.Next() = 0;
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(GSTCompAmount);
                    if Number > 1 then begin
                        CopyText := CopyLbl;
                        OutputNo += 1;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCopy) + 1;
                    CopyText := '';
                    SetRange(Number, 1, NoOfLoops);
                    OutputNo := 1;
                end;
            }

            trigger OnAfterGetRecord()
            var
                TransferLine: Record "Transfer Line";
            begin
                DimSetEntry1.SetRange("Dimension Set ID", "Dimension Set ID");
                FormatAddr.TransferHeaderTransferFrom(TransferFromAddr, "Transfer Header");
                FormatAddr.TransferHeaderTransferTo(TransferToAddr, "Transfer Header");

                TransferLine.SetRange("Document No.", "Transfer Header"."No.");
                TransferLine.FindFirst();
                if not ShipmentMethod.Get("Shipment Method Code") then
                    ShipmentMethod.Init();

                IsGSTApplicable := CheckGSTDoc(TransferLine);
                TransferFromCodeRegNo.Get("Transfer Header"."Transfer-from Code");
                TransferToCodeRegNo.Get("Transfer Header"."Transfer-to Code");
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
        ShptMethodDescCaption = 'Shipment Method';
    }


    trigger OnInitReport()
    begin
        CompanyInformation.Get();
    end;

    var
        TaxTrnasactionValue: Record "Tax Transaction Value";
        TaxTrnasactionValue1: Record "Tax Transaction Value";
        ShipmentMethod: Record "Shipment Method";
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        CompanyInformation: Record "Company Information";
        TransferFromCodeRegNo: Record "Location";
        TransferToCodeRegNo: Record "Location";
        FormatAddr: Codeunit "Format Address";
        TransferFromAddr: array[8] of Text[50];
        TransferToAddr: array[8] of Text[50];
        NoOfCopy: Integer;
        NoOfLoops: Integer;
        CopyText: Text[30];
        DimText: Text[120];
        ShowIntInfo: Boolean;
        Continue: Boolean;
        OutputNo: Integer;
        GSTCompAmount: array[20] of Decimal;
        GSTComponentCode: array[20] of Integer;
        GSTComponentCodeName: array[10] of Code[20];
        IsGSTApplicable: Boolean;
        J: Integer;
        CopyLbl: Label 'COPY', Locked = true;
        TransferOrdeLbl: Label 'Transfer Order %1', Comment = '%1 No. Of Copy';
        PageLbl: Label 'Page %1', Comment = '%1 No.';
        HdrDimensionsCaptionLbl: Label 'Header Dimensions', Locked = true;
        LineDimensionsCaptionLbl: Label 'Line Dimensions', Locked = true;
        AmountLbl: Label 'Amount', Locked = true;
        TotalTaxAmountLbl: Label 'Total Amount', Locked = true;
        TransferFromRegNoLbl: Label 'Recipient GST Reg. No.', Locked = true;
        TransferToRegNoLbl: Label 'Supplier GST Reg. No.', Locked = true;
        HSNSACCodeLbl: Label 'HSN/SAC Code', Locked = true;

    local procedure CheckGSTDoc(TransferLine: Record "Transfer Line"): Boolean
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
