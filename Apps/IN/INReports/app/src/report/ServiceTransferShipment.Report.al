// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.ServicesTransfer;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Location;
using System.Utilities;

report 18040 "Service Transfer Shipment"
{
    DefaultLayout = RDLC;
    RDLCLayout = './rdlc/ServiceTransferShipment.rdl';
    Caption = 'Service Transfer Shipment';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Service Transfer Shpt. Header"; "Service Transfer Shpt. Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";
            RequestFilterHeading = 'Service Transfer Shpt. Header';

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

                    column(CopyTextCaption; StrSubstNo(TransferShpLbl, CopyText))
                    {
                    }
                    column(TransferToAddr1; ServiceTransferToAddr[1])
                    {
                    }
                    column(TransferFromAddr1; ServiceTransferFromAddr[1])
                    {
                    }
                    column(TransferToAddr2; ServiceTransferToAddr[2])
                    {
                    }
                    column(TransferFromAddr2; ServiceTransferFromAddr[2])
                    {
                    }
                    column(TransferToAddr3; ServiceTransferToAddr[3])
                    {
                    }
                    column(TransferFromAddr3; ServiceTransferFromAddr[3])
                    {
                    }
                    column(TransferToAddr4; ServiceTransferToAddr[4])
                    {
                    }
                    column(TransferFromAddr4; ServiceTransferFromAddr[4])
                    {
                    }
                    column(TransferToAddr5; ServiceTransferToAddr[5])
                    {
                    }
                    column(TransferToAddr6; ServiceTransferToAddr[6])
                    {
                    }
                    column(PostDate_TransShptHeader; Format("Service Transfer Shpt. Header"."Shipment Date", 0, 4))
                    {
                    }
                    column(No2_TransShptHeader; "Service Transfer Shpt. Header"."No.")
                    {
                    }
                    column(TransferToAddr7; ServiceTransferToAddr[7])
                    {
                    }
                    column(TransferToAddr8; ServiceTransferToAddr[8])
                    {
                    }
                    column(TransferFromAddr5; ServiceTransferFromAddr[5])
                    {
                    }
                    column(TransferFromAddr6; ServiceTransferFromAddr[6])
                    {
                    }
                    column(ShiptDate_TransShptHeader; Format("Service Transfer Shpt. Header"."Shipment Date", 0, 4))
                    {
                    }
                    column(TransferFromAddr7; ServiceTransferFromAddr[7])
                    {
                    }
                    column(TransferFromAddr8; ServiceTransferFromAddr[8])
                    {
                    }
                    column(PageCaption; StrSubstNo(PageLbl, ''))
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(TransShptHdrNoCaption; TransShptHdrNoCaptionLbl)
                    {
                    }
                    column(TransShptShptDateCaption; TransShptShptDateCaptionLbl)
                    {
                    }
                    column(CompanyRegistrationLbl; CompanyRegistrationLbl)
                    {
                    }
                    column(CompanyInfo_GST_RegistrationNo; CompanyInformation."GST Registration No.")
                    {
                    }
                    column(ReceiveLocLbl; ReceiveLocLbl)
                    {
                    }
                    column(ShipLocLbl; ShipLocLbl)
                    {
                    }
                    column(GstRegistrationLbl; GstRegistrationLbl)
                    {
                    }
                    column(ShipGST; Location."GST Registration No.")
                    {
                    }
                    column(ReceiveGST; Location1."GST Registration No.")
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
                    column(GSTComponentCode4; GSTComponentCode[4] + ' Amount')
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
                    dataitem(DimensionLoop1; Integer)
                    {
                        DataItemLinkReference = "Service Transfer Shpt. Header";
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
                            DimText := GetDimensionText(DimensionSetEntry1, Number, Continue);
                            if not Continue then
                                CurrReport.Break();
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not ShowIntInfo then
                                CurrReport.Break();
                        end;
                    }
                    dataitem("Service Transfer Shpt. Line"; "Service Transfer Shpt. Line")
                    {
                        DataItemLink = "Document No." = field("No.");
                        DataItemLinkReference = "Service Transfer Shpt. Header";
                        DataItemTableView = sorting("Document No.", "Line No.");

                        column(ShowInternalInfo; ShowIntInfo)
                        {
                        }
                        column(NoOfCopies; NoOfCopy)
                        {
                        }
                        column(From_TransShptLine; "Transfer From G/L Account No.")
                        {
                        }
                        column(Desc_TransShptLine; "From G/L Account Description")
                        {
                            IncludeCaption = true;
                        }
                        column(LineNo_TransShptLine; "Line No.")
                        {
                        }
                        column(DocNo_TransShptLine; "Document No.")
                        {
                        }
                        column(Transfer_Price; "Transfer Price")
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
                                DimText := GetDimensionText(DimensionSetEntry2, Number, Continue);
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
                            DimensionSetEntry2.SetRange("Dimension Set ID", "Dimension Set ID");

                            Clear(CGSTAmt);
                            Clear(SGSTAmt);
                            Clear(IGSTAmt);

                            DetailedGSTLedgerEntry.Reset();
                            DetailedGSTLedgerEntry.SetRange("Document No.", "Service Transfer Shpt. Line"."Document No.");
                            if DetailedGSTLedgerEntry.FindSet() then
                                repeat
                                    if DetailedGSTLedgerEntry."GST Component Code" = 'CGST' then
                                        CGSTAmt += Abs(DetailedGSTLedgerEntry."GST Amount");

                                    if DetailedGSTLedgerEntry."GST Component Code" = 'SGST' then
                                        SGSTAmt += Abs(DetailedGSTLedgerEntry."GST Amount");

                                    if DetailedGSTLedgerEntry."GST Component Code" = 'IGST' then
                                        IGSTAmt += Abs(DetailedGSTLedgerEntry."GST Amount");

                                    if DetailedGSTLedgerEntry."GST Component Code" = 'UGST' then
                                        UGSTAmt += Abs(DetailedGSTLedgerEntry."GST Amount");
                                until DetailedGSTLedgerEntry.Next() = 0;
                        end;

                        trigger OnPreDataItem()
                        begin
                            MoreLines := FindLast();
                            while MoreLines and ("From G/L Account Description" = '') and ("Transfer From G/L Account No." = '') do
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
                        CopyText := CopyTxt;
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
                DimensionSetEntry1.SetRange("Dimension Set ID", "Dimension Set ID");

                ServiceTransferShptTransferFrom(ServiceTransferFromAddr, "Service Transfer Shpt. Header");
                ServiceTransferShptTransferTo(ServiceTransferToAddr, "Service Transfer Shpt. Header");
                Location.Get("Transfer-from Code");
                Location1.Get("Transfer-to Code");
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


    trigger OnInitReport()
    begin
        CompanyInformation.Get();
    end;

    var
        DimensionSetEntry2: Record "Dimension Set Entry";
        DimensionSetEntry1: Record "Dimension Set Entry";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        CompanyInformation: Record "Company Information";
        Location: Record Location;
        Location1: Record Location;
        FormatAddress: Codeunit "Format Address";
        ServiceTransferFromAddr: array[8] of Text[50];
        ServiceTransferToAddr: array[8] of Text[50];
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
        CGSTAmt: Decimal;
        SGSTAmt: Decimal;
        IGSTAmt: Decimal;
        UGSTAmt: Decimal;
        CompanyRegistrationLbl: Label 'Company Registration No.';
        ReceiveLocLbl: Label 'Receiving Location';
        ShipLocLbl: Label 'Shipping Location';
        GstRegistrationLbl: Label 'GST Registration No.';
        CopyTxt: Label 'Copy';
        TransferShpLbl: Label 'Service Transfer Invoice %1', Comment = '%1 = Transfer Shipment No.';
        PageLbl: Label 'Page %1', Comment = '%1 = Page No';
        TransShptHdrNoCaptionLbl: Label 'Invoice No.';
        TransShptShptDateCaptionLbl: Label 'Shipment Date';
        HdrDimCaptionLbl: Label 'Header Dimensions';
        LineDimCaptionLbl: Label 'Line Dimensions';
        CGSTLbl: Label 'CGST Amount';
        SGSTLbl: Label 'SGST Amount';
        IGSTLbl: Label 'IGST Amount';
        UGSTLbl: Label 'UGST Amount';

    local procedure ServiceTransferShptTransferFrom(
        var AddrArray: array[8] OF Text[50];
        var ServiceTransferShptHeader: Record "Service Transfer Shpt. Header")
    begin
        FormatAddress.FormatAddr(
            AddrArray,
            ServiceTransferShptHeader."Transfer-from Name",
            ServiceTransferShptHeader."Transfer-from Name 2",
            '',
            ServiceTransferShptHeader."Transfer-from Address",
            CopyStr(ServiceTransferShptHeader."Transfer-from Address 2", 1, 50),
            ServiceTransferShptHeader."Transfer-from City",
            ServiceTransferShptHeader."Transfer-from Post Code",
            '',
            '');
    end;

    local procedure ServiceTransferShptTransferTo(
        var AddrArray: array[8] OF Text[50];
        var ServiceTransferShptHeader: Record "Service Transfer Shpt. Header")
    begin
        FormatAddress.FormatAddr(
            AddrArray,
            ServiceTransferShptHeader."Transfer-to Name",
            ServiceTransferShptHeader."Transfer-to Name 2",
            '',
            ServiceTransferShptHeader."Transfer-to Address",
            CopyStr(ServiceTransferShptHeader."Transfer-to Address 2", 1, 50),
            ServiceTransferShptHeader."Transfer-to City",
            ServiceTransferShptHeader."Transfer-to Post Code",
            '',
            '');
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
