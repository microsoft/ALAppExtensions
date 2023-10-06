// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Shipping;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Intrastat;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Transfer;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Service.History;
using System.IO;

report 18036 "E-Way Bill File Format GST"
{
    Caption = 'E-Way Bill File Format';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Detailed GST Ledger Entry"; "Detailed GST Ledger Entry")
        {
            DataItemTableView = sorting("Entry No.")
                                order(ascending)
                                where("Entry Type" = filter("Initial Entry"),
                                Type = filter(Item | "Fixed Asset"),
                                "GST Group Type" = filter(Goods));

            trigger OnAfterGetRecord()
            var
                DocumentNo: Code[20];
                DocumentLineNo: Integer;
                OriginalInvoiceNo: Code[20];
                ItemChargeAssgnLineNo: Integer;
            begin
                DelGSTLedgerEntryInfo.Get("Detailed GST Ledger Entry"."Entry No.");
                if TransType = TransType::Transfers then
                    if not (DelGSTLedgerEntryInfo."Original Doc. Type" in [DelGSTLedgerEntryInfo."Original Doc. Type"::"Transfer Shipment"]) then
                        CurrReport.Skip();

                if "Detailed GST Ledger Entry".FindSet() then
                    repeat
                        if (DocumentNo <> "Document No.") or
                            (DocumentLineNo <> "Document Line No.") or
                            (OriginalInvoiceNo <> "Original Invoice No.") or
                            (ItemChargeAssgnLineNo <> DelGSTLedgerEntryInfo."Item Charge Assgn. Line No.")
                        then begin
                            ClearVariables();
                            InitializeVariables();


                            if not ServiceDoc then begin
                                GetSupplySubDocType();
                                GetGSTAmount();
                                TempExcelBuffer.NewRow();
                                TempExcelBuffer.AddColumn(SupplyType, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(SubType, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(DocType, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn("Document No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn("Posting Date", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetTransactionType(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetFromOtherPartyName(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetFromGSTIN(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetFromAddress(true), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetFromAddress(false), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetPlaceState(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetPostCode(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetFromState(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetDispatchState(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetToOtherPartyName(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetToGSTIN(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetToAddress(true), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetToAddress(false), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetToPlace(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetToPostCode(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetToState(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetShipToState(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                if Type = Type::Item then begin
                                    TempExcelBuffer.AddColumn(Item.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                    TempExcelBuffer.AddColumn(Item.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                end else
                                    if Type = Type::"Fixed Asset" then begin
                                        TempExcelBuffer.AddColumn(FixedAsset.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                        TempExcelBuffer.AddColumn(FixedAsset.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                    end;

                                TempExcelBuffer.AddColumn("HSN/SAC Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetUOM(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(Abs(Quantity), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                                TempExcelBuffer.AddColumn(Abs("GST Base Amount"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                                TempExcelBuffer.AddColumn(GetTaxRate(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                                TempExcelBuffer.AddColumn(Abs(CGSTAmount), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                                TempExcelBuffer.AddColumn(Abs(SGSTAmount), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                                TempExcelBuffer.AddColumn(Abs(IGSTAmount), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                                TempExcelBuffer.AddColumn(Abs(CessAmount), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                                TempExcelBuffer.AddColumn(Abs(CessNonAdvolAmount), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                                TempExcelBuffer.AddColumn(Abs(Others), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                                TempExcelBuffer.AddColumn(Abs(TotalInvoiceValue), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                                TempExcelBuffer.AddColumn(GetTransMode(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetDistance(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                                TempExcelBuffer.AddColumn(GetTransName(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetTransID(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetVehicleNo(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                                TempExcelBuffer.AddColumn(GetVehicleType(), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                            end;
                        end;
                        DocumentNo := "Document No.";
                        DocumentLineNo := "Document Line No.";
                        OriginalInvoiceNo := "Original Invoice No.";
                        ItemChargeAssgnLineNo := DelGSTLedgerEntryInfo."Item Charge Assgn. Line No.";
                    until Next() = 0;
            end;

            trigger OnPostDataItem()
            begin
                CreateExcelBook();
            end;

            trigger OnPreDataItem()
            begin
                if StartDate = 0D then
                    Error(StartDateErr);

                if EndDate = 0D then
                    Error(EndDateErr);

                if (StartDate <> 0D) and (EndDate <> 0D) and (StartDate > EndDate) then
                    Error(StartDtGreaterErr);

                if LocationRegNo = '' then
                    Error(LocRegNoErr);

                if TransType = TransType::" " then
                    Error(TransTypeErr);

                if (TransType = TransType::Transfers) and (SourceNo <> '') then
                    Error(TransferSourceErr);

                SetRange("Posting Date", StartDate, EndDate);
                SetRange("Location  Reg. No.", LocationRegNo);
                case TransType of
                    TransType::Sales:
                        begin
                            SetRange("Source Type", "Source Type"::Customer);
                            if SourceNo <> '' then
                                SetRange("Source No.", SourceNo);
                            SetRange("TransAction Type", "TransAction Type"::Sales);
                        end;

                    TransType::Purchase:
                        begin
                            SetRange("Source Type", "Source Type"::Vendor);
                            if SourceNo <> '' then
                                SetRange("Source No.", SourceNo);
                            SetRange("TransAction Type", "TransAction Type"::Purchase);
                        end;

                    TransType::Transfers:
                        begin
                            SetRange("Source Type", "Source Type"::" ");
                            SetRange("Source No.", '');
                            SetRange("TransAction Type", "TransAction Type"::Sales);
                        end;
                end;

                MakeExcelHeader();
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field("Start Date"; StartDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Start Date';
                        ToolTip = 'Specifies the starting date of the report.';
                    }
                    field("End Date"; EndDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'End Date';
                        ToolTip = 'Specifies the ending date of the report.';
                    }
                    field("Location GST Reg. No."; LocationRegNo)
                    {
                        TableRelation = "GST Registration Nos.";
                        ApplicationArea = Basic, Suite;
                        Caption = 'Location GST Reg. No.';
                        ToolTip = 'Specifies the GST registration number of the location for which the report will be generated.';
                    }
                    field("TransAction Type"; TransType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Transaction Type';
                        ToolTip = 'Specifies the transaction type for which the report will be generated.';

                        trigger OnValidate()
                        begin
                            CASE TransType OF
                                TransType::Sales:
                                    SourceType := SourceType::Customer;
                                TransType::Purchase:
                                    SourceType := SourceType::Vendor;
                                TransType::Transfers:
                                    SourceType := SourceType::" ";
                            end;
                        end;
                    }
                    field("Source Type"; SourceType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Source Type';
                        ToolTip = 'Specifies the source type e.g. Customer/Vendor, for which report will be generated.';
                        Editable = false;

                    }
                    field("Source No."; SourceNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Source No.';
                        ToolTip = 'Specifies the source number as per defined type in source type, for which the report will be generated.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            Customer: Record Customer;
                            Vendor: Record Vendor;
                            CustomerList: Page "Customer List";
                            VendorList: Page "Vendor List";
                        begin
                            CASE SourceType OF
                                SourceType::Customer:
                                    if CustomerList.RunModal() = Action::OK then begin
                                        CustomerList.GetRecord(Customer);
                                        SourceNo := Customer."No.";
                                    end;

                                SourceType::Vendor:
                                    if VendorList.RunModal() = Action::OK then begin
                                        VendorList.GetRecord(Vendor);
                                        SourceNo := Vendor."No.";
                                    end;
                            end;
                        end;
                    }
                }
            }
        }

        Actions
        {
        }
    }

    labels
    {
    }


    trigger OnPreReport()
    begin
        TempExcelBuffer.DeleteAll();
    end;

    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        DelGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        Vendor: Record Vendor;
        OrderAddress: Record "Order Address";
        Customer: Record Customer;
        ShipToAddress: Record "Ship-to Address";
        Location: Record "Location";
        CompanyInformation: Record "Company Information";
        Item: Record Item;
        FixedAsset: Record "Fixed Asset";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        StartDate: Date;
        EndDate: Date;
        LocationRegNo: Code[15];
        SourceType: Option " ",Customer,Vendor;
        SourceNo: Code[20];
        TransType: Option " ",Sales,Purchase,Transfers;
        SupplyType: Option Inward,Outward;
        SubType: Option " ",Supply,Export,"Job Work","Recipient Not Known",Import,"Job Work Returns","Sales Returns",Others;
        DocType: Option " ","Tax Invoice","Bill of Supply","Bill of Entry","Delivery Challan","Credit Note",Others;
        CGSTAmount: Decimal;
        SGSTAmount: Decimal;
        IGSTAmount: Decimal;
        CessAmount: Decimal;
        Others: Decimal;
        ServiceNo: Code[20];
        DetailGstLENo: Code[20];
        TotalInvoiceValue: Decimal;
        CessNonAdvolAmount: Decimal;
        ServiceDoc: Boolean;
        StartDateErr: Label 'You must enter Start Date.';
        EndDateErr: Label 'You must enter End Date.';
        StartDtGreaterErr: Label 'You must not enter Start Date that is greater than End Date.';
        LocRegNoErr: Label 'You must enter Location Reg. No.';
        TransTypeErr: Label 'You must enter TransAction Type.';
        URPTxt: Label 'urp';
        SupplyTypeTxt: Label 'Supply Type';
        SubTypeTxt: Label 'Sub Type';
        DocTypeTxt: Label 'Doc Type';
        DocNoTxt: Label 'Doc No.';
        DocDateTxt: Label 'Doc Date';
        FromOtherPartyNameTxt: Label 'From Other Party Name';
        FromGSTINTxt: Label 'From GSTIN';
        FromAddress1Txt: Label 'From Address1';
        FromAddress2Txt: Label 'From Address 2';
        FromPlaceTxt: Label 'From Place';
        TransactionTypeTxt: Label 'Transaction Type';
        FromPinCodeTxt: Label 'Dispatch Pin Code';
        FromStateTxt: Label 'Bill From State';
        ToOtherPartyNameTxt: Label 'To Other Party Name';
        ToGSTINTxt: Label 'To GSTIN';
        ToAddress1Txt: Label 'To Address 1';
        ToAddress2Txt: Label 'To Address 2';
        ToPlaceTxt: Label 'To Place';
        ToPinCodeTxt: Label 'Ship To Pin Code';
        ToStateTxt: Label 'Bill To State';
        ProductTxt: Label 'Product';
        DescriptionTxt: Label 'Description';
        HSNTxt: Label 'HSN';
        UnitTxt: Label 'Unit';
        QtyTxt: Label 'Qty';
        AssessableValueTxt: Label 'Assessable Value';
        TaxRateTxt: Label 'Rate(S + C + I + Cess + CESS NONADVOL)';
        CGSTTxt: Label 'CGST';
        SGSTTxt: Label 'SGST';
        IGSTTxt: Label 'IGST';
        CESSTxt: Label 'CESS';
        CGSTAmountTxt: Label 'CGST Amount';
        SGSTAmountTxt: Label 'SGST Amount';
        IGSTAmountTxt: Label 'IGST Amount';
        CessAmountTxt: Label 'CESS Amount';
        CessNonAdvolAmountTxt: Label 'CESS Non Advol Amount';
        OthersTxt: Label 'Others';
        TotalInvoiceValueTxt: Label 'Total Invoice Value';
        TransModeTxt: Label 'Trans Mode';
        DistaceTxt: Label 'Distance (Km)';
        TransNameTxt: Label 'Trans Name';
        TransIdTxt: Label 'Trans ID';
        TransDocNoTxt: Label 'Trans Doc No';
        TransDateTxt: Label 'Trans Date';
        VehicleNoTxt: Label 'Vehicle No.';
        DispatchStateTxt: Label 'Dispatch From State';
        ShipToStateTxt: Label 'Ship To State';
        VehicleTypeTxt: Label 'Vehicle Type';
        SupplyTypeDescTxt: Label 'Supply_Type_Desc';
        TransferSourceErr: Label 'Source No. must be blank for transAction type:Transfer.';

    local procedure MakeExcelHeader()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(SupplyTypeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(SubTypeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DocTypeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DocNoTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DocDateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TransactionTypeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(FromOtherPartyNameTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(FromGSTINTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(FromAddress1Txt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(FromAddress2Txt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(FromPlaceTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(FromPinCodeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(FromStateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DispatchStateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ToOtherPartyNameTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ToGSTINTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ToAddress1Txt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ToAddress2Txt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ToPlaceTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ToPinCodeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ToStateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ShipToStateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ProductTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DescriptionTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(HSNTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(UnitTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(QtyTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(AssessableValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxRateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CGSTAmountTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(SGSTAmountTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(IGSTAmountTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CessAmountTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CessNonAdvolAmountTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(OthersTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TotalInvoiceValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TransModeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DistaceTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TransNameTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TransIdTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TransDocNoTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TransDateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(VehicleNoTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(VehicleTypeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(SupplyTypeDescTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure ClearVariables()
    begin
        SubType := SubType::" ";
        DocType := DocType::" ";
        ServiceDoc := false;
        CGSTAmount := 0;
        SGSTAmount := 0;
        IGSTAmount := 0;
        CessAmount := 0;
        CessNonAdvolAmount := 0;
        TotalInvoiceValue := 0;
    end;

    local procedure InitializeVariables()
    var
        ServInvDoc: Boolean;
        ServCrMemoDoc: Boolean;
    begin
        if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Customer then
            if DelGSTLedgerEntryInfo."Ship-to Code" <> '' then
                ShipToAddress.Get("Detailed GST Ledger Entry"."Source No.", DelGSTLedgerEntryInfo."Ship-to Code")
            else
                Customer.Get("Detailed GST Ledger Entry"."Source No.")
        else
            if "Detailed GST Ledger Entry"."Source Type" = "Source Type"::Vendor then
                if DelGSTLedgerEntryInfo."Order Address Code" <> '' then
                    OrderAddress.get("Detailed GST Ledger Entry"."Source No.", DelGSTLedgerEntryInfo."Order Address Code")
                else
                    Vendor.Get("Detailed GST Ledger Entry"."Source No.");

        if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Vendor then
            if DelGSTLedgerEntryInfo."Bill to-Location(POS)" <> '' then
                Location.Get(DelGSTLedgerEntryInfo."Bill to-Location(POS)")
            else
                if "Detailed GST Ledger Entry"."Location Code" <> '' then
                    Location.Get("Detailed GST Ledger Entry"."Location Code")
                else
                    CompanyInformation.Get();

        if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Customer then
            if "Detailed GST Ledger Entry"."Location Code" <> '' then
                Location.Get("Detailed GST Ledger Entry"."Location Code")
            else
                CompanyInformation.Get();

        if "Detailed GST Ledger Entry".Type = "Detailed GST Ledger Entry".Type::Item then
            Item.Get("Detailed GST Ledger Entry"."No.")
        else
            if "Detailed GST Ledger Entry".Type = "Detailed GST Ledger Entry".Type::"Fixed Asset" then
                FixedAsset.Get("Detailed GST Ledger Entry"."No.");

        if "Detailed GST Ledger Entry"."TransAction Type" = "Detailed GST Ledger Entry"."TransAction Type"::Sales then begin
            if ("Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::Invoice) and
                ServiceInvoiceHeader.Get("Detailed GST Ledger Entry"."Document No.") then
                ServInvDoc := true;

            if ("Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::"Credit Memo") and
                ServiceCrMemoHeader.Get("Detailed GST Ledger Entry"."Document No.") then
                ServCrMemoDoc := true;

            if ServInvDoc or ServCrMemoDoc then
                ServiceDoc := true;
        end;
    end;

    local procedure GetSupplySubDocType()
    begin
        if "Detailed GST Ledger Entry"."TransAction Type" = "Detailed GST Ledger Entry"."TransAction Type"::Sales then
            if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::"Credit Memo" then begin
                SupplyType := SupplyType::Inward;
                SubType := SubType::"Sales Returns";
                DocType := DocType::"Credit Note";
            end else
                if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::Invoice then begin
                    SupplyType := SupplyType::Outward;
                    case "Detailed GST Ledger Entry"."GST Customer Type" of
                        "Detailed GST Ledger Entry"."GST Customer Type"::"Deemed Export",
                        "Detailed GST Ledger Entry"."GST Customer Type"::"SEZ Development",
                           "Detailed GST Ledger Entry"."GST Customer Type"::"SEZ Unit",
                           "Detailed GST Ledger Entry"."GST Customer Type"::Registered:
                            begin
                                SubType := SubType::Supply;
                                DocType := DocType::"Tax Invoice";
                            end;

                        "Detailed GST Ledger Entry"."GST Customer Type"::Exempted:
                            begin
                                SubType := SubType::Supply;
                                DocType := DocType::"Bill of Supply";
                            end;

                        "Detailed GST Ledger Entry"."GST Customer Type"::Export:
                            begin
                                SubType := SubType::Export;
                                DocType := DocType::"Tax Invoice";
                            end;

                        "Detailed GST Ledger Entry"."GST Customer Type"::Unregistered:
                            begin
                                SubType := SubType::"Recipient Not Known";
                                DocType := DocType::"Tax Invoice";
                            end;
                    end;
                end;
        if "Detailed GST Ledger Entry"."TransAction Type" = "Detailed GST Ledger Entry"."TransAction Type"::Purchase then
            if ("Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::"Credit Memo") and
               ("Detailed GST Ledger Entry"."GST Vendor Type" in [
                    "Detailed GST Ledger Entry"."GST Vendor Type"::Registered,
                    "Detailed GST Ledger Entry"."GST Vendor Type"::SEZ,
                    "Detailed GST Ledger Entry"."GST Vendor Type"::Exempted,
                    "Detailed GST Ledger Entry"."GST Vendor Type"::Composite,
                    "Detailed GST Ledger Entry"."GST Vendor Type"::Unregistered])
            then begin
                SupplyType := SupplyType::Outward;
                SubType := SubType::Others;
                DocType := DocType::"Credit Note";
            end else
                if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::Invoice then begin
                    SupplyType := SupplyType::Inward;
                    case "Detailed GST Ledger Entry"."GST Vendor Type" of
                        "Detailed GST Ledger Entry"."GST Vendor Type"::Registered,
                        "Detailed GST Ledger Entry"."GST Vendor Type"::SEZ,
                        "Detailed GST Ledger Entry"."GST Vendor Type"::Unregistered:
                            begin
                                SubType := SubType::Supply;
                                DocType := DocType::"Tax Invoice";
                            end;

                        "Detailed GST Ledger Entry"."GST Vendor Type"::Exempted,
                        "Detailed GST Ledger Entry"."GST Vendor Type"::Composite:
                            begin
                                SubType := SubType::Supply;
                                DocType := DocType::"Bill of Supply";
                            end;


                        "Detailed GST Ledger Entry"."GST Vendor Type"::Import:
                            begin
                                SubType := SubType::Import;
                                DocType := DocType::"Bill of Entry";
                            end;
                    end;
                end;
    end;

    local procedure GetFromOtherPartyName() FromOtherPartyName: Text[50]
    begin
        if SupplyType = SupplyType::Inward then
            case SubType of
                SubType::Supply, SubType::Import:
                    if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Vendor then
                        if DelGSTLedgerEntryInfo."Order Address Code" <> '' then
                            FromOtherPartyName := CopyStr(OrderAddress.Name, 1, 50)
                        else
                            FromOtherPartyName := CopyStr(Vendor.Name, 1, 50);

                SubType::"Sales Returns":
                    if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Customer then
                        if DelGSTLedgerEntryInfo."Ship-to Code" <> '' then
                            FromOtherPartyName := CopyStr(ShipToAddress.Name, 1, 50)
                        else
                            FromOtherPartyName := CopyStr(Customer.Name, 1, 50);
            end;

        if SupplyType = SupplyType::Outward then
            if SubType in [SubType::Supply, SubType::Export, SubType::"Recipient Not Known", SubType::Others] then
                if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::" " then begin
                    TransferShipmentHeader.Get("Detailed GST Ledger Entry"."Document No.");
                    Location.Get(TransferShipmentHeader."Transfer-from Code");
                    FromOtherPartyName := CopyStr(Location.Name, 1, 50);
                end else
                    if "Detailed GST Ledger Entry"."Location Code" <> '' then
                        FromOtherPartyName := CopyStr(Location.Name, 1, 50)
                    else
                        FromOtherPartyName := CopyStr(CompanyInformation.Name, 1, 50);
    end;

    local procedure GetFromGSTIN() FromGSTIN: Code[15]
    begin
        if SupplyType = SupplyType::Inward then
            if "Detailed GST Ledger Entry"."GST Vendor Type" = "Detailed GST Ledger Entry"."GST Vendor Type"::Unregistered then
                FromGSTIN := URPTxt
            else
                if "Detailed GST Ledger Entry"."GST Customer Type" = "Detailed GST Ledger Entry"."GST Customer Type"::Unregistered then
                    FromGSTIN := URPTxt
                else
                    FromGSTIN := CopyStr("Detailed GST Ledger Entry"."Buyer/Seller Reg. No.", 1, 15)
        else
            FromGSTIN := CopyStr("Detailed GST Ledger Entry"."Location  Reg. No.", 1, 15);
    end;

    local procedure GetFromAddress(Address1: Boolean) FromAddress: Text[50]
    begin
        if SupplyType = SupplyType::Inward then
            case SubType of
                SubType::Supply, SubType::Import:
                    if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Vendor then
                        if DelGSTLedgerEntryInfo."Order Address Code" <> '' then
                            if Address1 then
                                FromAddress := CopyStr(OrderAddress.Address, 1, 50)
                            else
                                FromAddress := OrderAddress."Address 2"
                        else
                            if Address1 then
                                FromAddress := CopyStr(Vendor.Address, 1, 50)
                            else
                                FromAddress := Vendor."Address 2";

                SubType::"Sales Returns":
                    if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Customer then
                        if DelGSTLedgerEntryInfo."Ship-to Code" <> '' then
                            if Address1 then
                                FromAddress := CopyStr(ShipToAddress.Address, 1, 50)
                            else
                                FromAddress := ShipToAddress."Address 2"
                        else
                            if Address1 then
                                FromAddress := CopyStr(Customer.Address, 1, 50)
                            else
                                FromAddress := Customer."Address 2"
                    else
                        if SubType in [SubType::Supply, SubType::Export, SubType::"Recipient Not Known", SubType::Others] then
                            if "Detailed GST Ledger Entry"."Source Type" = "Source Type"::" " then begin
                                TransferShipmentHeader.Get("Detailed GST Ledger Entry"."Document No.");
                                Location.Get(TransferShipmentHeader."Transfer-from Code");
                                if Address1 then
                                    FromAddress := CopyStr(Location.Address, 1, 50)
                                else
                                    FromAddress := Location."Address 2";
                            end else
                                if "Detailed GST Ledger Entry"."Location Code" <> '' then
                                    if Address1 then
                                        FromAddress := CopyStr(Location.Address, 1, 50)
                                    else
                                        FromAddress := Location."Address 2"
                                else
                                    if Address1 then
                                        FromAddress := CopyStr(CompanyInformation.Address, 1, 50)
                                    else
                                        FromAddress := CompanyInformation."Address 2";
            end;
    end;

    local procedure GetPlaceState() FromPlace: Text[30]
    begin
        if SupplyType = SupplyType::Inward then
            case SubType of
                SubType::Supply, SubType::Import:
                    if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Vendor then
                        if DelGSTLedgerEntryInfo."Order Address Code" <> '' then
                            FromPlace := OrderAddress.City
                        else
                            FromPlace := Vendor.City;

                SubType::"Sales Returns":
                    if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Customer then
                        if DelGSTLedgerEntryInfo."Ship-to Code" <> '' then
                            FromPlace := ShipToAddress.City
                        else
                            FromPlace := Customer.City;
                else
                    if SubType in [SubType::Supply, SubType::Export, SubType::"Recipient Not Known", SubType::Others] then
                        if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::" " then begin
                            TransferShipmentHeader.Get("Detailed GST Ledger Entry"."Document No.");
                            Location.Get(TransferShipmentHeader."Transfer-from Code");
                            FromPlace := Location.City;
                        end else
                            if "Detailed GST Ledger Entry"."Location Code" <> '' then
                                FromPlace := Location.City
                            else
                                FromPlace := CompanyInformation.City;
            end;
    end;

    local procedure GetTransactionType() TransactionType: Text[30]
    var
        DetailedGSTLedEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        case "Detailed GST Ledger Entry"."GST Place of Supply" of
            "Detailed GST Ledger Entry"."GST Place of Supply"::"Bill-to Address":
                TransactionType := 'Regular';
            "Detailed GST Ledger Entry"."GST Place of Supply"::"Ship-to Address":
                TransactionType := 'Bill To- Ship To';
        end;
        if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Vendor then begin
            DetailedGSTLedEntryInfo.SetRange(DetailedGSTLedEntryInfo."Entry No.", "Detailed GST Ledger Entry"."Entry No.");
            if DetailedGSTLedEntryInfo.FindFirst() then
                if DetailedGSTLedEntryInfo."Order Address Code" <> '' then
                    TransactionType := 'Bill From- Dispatch From'
                else
                    TransactionType := 'Regular';
        end;
    end;

    local procedure GetPostCode() FromPostCode: Code[20]
    begin
        if SupplyType = SupplyType::Inward then
            case SubType of
                SubType::Supply, SubType::Import:
                    if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Vendor then
                        if DelGSTLedgerEntryInfo."Order Address Code" <> '' then
                            FromPostCode := OrderAddress."Post Code"
                        else
                            FromPostCode := Vendor."Post Code";

                SubType::"Sales Returns":
                    if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Customer then
                        if DelGSTLedgerEntryInfo."Ship-to Code" <> '' then
                            FromPostCode := ShipToAddress."Post Code"
                        else
                            FromPostCode := Customer."Post Code";
                else
                    if SubType in [SubType::Supply, SubType::Export, SubType::"Recipient Not Known", SubType::Others] then
                        if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::" " then begin
                            TransferShipmentHeader.Get("Detailed GST Ledger Entry"."Document No.");
                            Location.Get(TransferShipmentHeader."Transfer-from Code");
                            FromPostCode := Location."Post Code";
                        end else
                            if "Detailed GST Ledger Entry"."Location Code" <> '' then
                                FromPostCode := Location."Post Code"
                            else
                                FromPostCode := CompanyInformation."Post Code";
            end;
    end;

    local procedure GetFromState() FromState: Text[50]
    var
        ShipToAdd: Record "Ship-to Address";
        State: Record State;
        FromStateCode: Code[10];
    begin
        if SupplyType = SupplyType::Inward then
            case SubType of
                SubType::Supply:
                    FromStateCode := DelGSTLedgerEntryInfo."Buyer/Seller State Code";

                SubType::"Sales Returns":
                    if DelGSTLedgerEntryInfo."Ship-to Code" <> '' then
                        if "Detailed GST Ledger Entry"."GST Customer Type" in [
                            "Detailed GST Ledger Entry"."GST Customer Type"::"Deemed Export",
                            "Detailed GST Ledger Entry"."GST Customer Type"::"SEZ Development",
                            "Detailed GST Ledger Entry"."GST Customer Type"::"SEZ Unit"]
                        then begin
                            ShipToAddress.Get("Detailed GST Ledger Entry"."Source No.", DelGSTLedgerEntryInfo."Ship-to Code");
                            FromStateCode := ShipToAdd.State;
                        end else
                            FromStateCode := DelGSTLedgerEntryInfo."Shipping Address State Code";
                else
                    if "Detailed GST Ledger Entry"."GST Customer Type" in [
                        "Detailed GST Ledger Entry"."GST Customer Type"::"Deemed Export",
                        "Detailed GST Ledger Entry"."GST Customer Type"::"SEZ Development",
                        "Detailed GST Ledger Entry"."GST Customer Type"::"SEZ Unit"]
                    then begin
                        Customer.Get("Detailed GST Ledger Entry"."Source No.");
                        FromStateCode := Customer."State Code";
                    end else
                        FromStateCode := DelGSTLedgerEntryInfo."Buyer/Seller State Code";
            end
        else
            if SubType in [SubType::Supply, SubType::Export, SubType::"Recipient Not Known", SubType::Others] then
                FromStateCode := DelGSTLedgerEntryInfo."Location State Code";

        if State.Get(FromStateCode) then
            FromState := State.Description;
    end;

    local procedure GetToOtherPartyName() ToOtherPartyName: Text[50]
    begin
        if SupplyType = SupplyType::Inward then
            if SubType in [SubType::Supply, SubType::Import, SubType::"Sales Returns"] then
                if "Detailed GST Ledger Entry"."Location Code" <> '' then
                    ToOtherPartyName := CopyStr(Location.Name, 1, 50)
                else
                    ToOtherPartyName := CopyStr(CompanyInformation.Name, 1, 50);

        if SupplyType = SupplyType::Outward then
            case SubType of
                SubType::Supply, SubType::Export, SubType::"Recipient Not Known":
                    if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Customer then
                        if DelGSTLedgerEntryInfo."Ship-to Code" <> '' then
                            ToOtherPartyName := CopyStr(ShipToAddress.Name, 1, 50)
                        else
                            ToOtherPartyName := CopyStr(Customer.Name, 1, 50)
                    else
                        if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::" " then begin
                            TransferShipmentHeader.Get("Detailed GST Ledger Entry"."Document No.");
                            Location.Get(TransferShipmentHeader."Transfer-to Code");
                            ToOtherPartyName := CopyStr(Location.Name, 1, 50)
                        end;

                SubType::Others:
                    if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Vendor then
                        if DelGSTLedgerEntryInfo."Order Address Code" <> '' then
                            ToOtherPartyName := CopyStr(OrderAddress.Name, 1, 50)
                        else
                            ToOtherPartyName := CopyStr(Vendor.Name, 1, 50);
            end;
    end;

    local procedure GetToGSTIN() ToGSTIN: Code[15]
    begin
        if SupplyType = SupplyType::Inward then
            ToGSTIN := CopyStr("Detailed GST Ledger Entry"."Location  Reg. No.", 1, 15)
        else
            case SubType of
                SubType::Supply:
                    ToGSTIN := CopyStr("Detailed GST Ledger Entry"."Buyer/Seller Reg. No.", 1, 15);
                SubType::"Recipient Not Known", SubType::Export:
                    ToGSTIN := URPTxt;
                SubType::Others:
                    if "Detailed GST Ledger Entry"."GST Vendor Type" = "Detailed GST Ledger Entry"."GST Vendor Type"::Unregistered then
                        ToGSTIN := URPTxt
                    else
                        ToGSTIN := CopyStr("Detailed GST Ledger Entry"."Buyer/Seller Reg. No.", 1, 15);
            end;
    end;

    local procedure GetToAddress(ToAddress1: Boolean) ToAddress: Text[50]
    begin
        if SupplyType = SupplyType::Inward then
            if SubType in [SubType::Supply, SubType::Import, SubType::"Sales Returns"] then
                if "Detailed GST Ledger Entry"."Location Code" <> '' then
                    if ToAddress1 then
                        ToAddress := CopyStr(Location.Address, 1, 50)
                    else
                        ToAddress := CopyStr(Location."Address 2", 1, 50)
                else
                    if ToAddress1 then
                        ToAddress := CopyStr(CompanyInformation.Address, 1, 50)
                    else
                        ToAddress := CompanyInformation."Address 2";

        if SupplyType = SupplyType::Outward then
            case SubType of
                SubType::Supply, SubType::Export, SubType::"Recipient Not Known":
                    if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::" " then begin
                        TransferShipmentHeader.Get("Detailed GST Ledger Entry"."Document No.");
                        Location.Get(TransferShipmentHeader."Transfer-to Code");
                        if ToAddress1 then
                            ToAddress := CopyStr(Location.Address, 1, 50)
                        else
                            ToAddress := CopyStr(Location."Address 2", 1, 50)
                    end else
                        if DelGSTLedgerEntryInfo."Ship-to Code" <> '' then
                            if ToAddress1 then
                                ToAddress := CopyStr(ShipToAddress.Address, 1, 50)
                            else
                                ToAddress := ShipToAddress."Address 2"
                        else
                            if ToAddress1 then
                                ToAddress := CopyStr(Customer.Address, 1, 50)
                            else
                                ToAddress := Customer."Address 2";

                SubType::Others:
                    if DelGSTLedgerEntryInfo."Order Address Code" <> '' then
                        if ToAddress1 then
                            ToAddress := CopyStr(OrderAddress.Address, 1, 50)
                        else
                            ToAddress := OrderAddress."Address 2"
                    else
                        if ToAddress1 then
                            ToAddress := CopyStr(Vendor.Address, 1, 50)
                        else
                            ToAddress := Vendor."Address 2";
            end;
    end;

    local procedure GetToPlace() ToPlace: Text[30]
    begin
        if SupplyType = SupplyType::Inward then
            if SubType in [SubType::Supply, SubType::Import, SubType::"Sales Returns"] then
                if "Detailed GST Ledger Entry"."Location Code" <> '' then
                    ToPlace := Location.City
                else
                    ToPlace := CompanyInformation.City;

        if SupplyType = SupplyType::Outward then
            case SubType of
                SubType::Supply, SubType::Export, SubType::"Recipient Not Known":
                    if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::" " then begin
                        TransferShipmentHeader.Get("Detailed GST Ledger Entry"."Document No.");
                        Location.Get(TransferShipmentHeader."Transfer-to Code");
                        ToPlace := Location.City;
                    end else
                        if DelGSTLedgerEntryInfo."Ship-to Code" <> '' then
                            ToPlace := ShipToAddress.City
                        else
                            ToPlace := Customer.City;

                SubType::Others:
                    if DelGSTLedgerEntryInfo."Order Address Code" <> '' then
                        ToPlace := OrderAddress.City
                    else
                        ToPlace := Vendor.City;
            end;
    end;

    local procedure GetToPostCode() ToPostCode: Code[20]
    begin
        if SupplyType = SupplyType::Inward then
            if SubType in [SubType::Supply, SubType::Import, SubType::"Sales Returns"] then
                if "Detailed GST Ledger Entry"."Location Code" <> '' then
                    ToPostCode := Location."Post Code"
                else
                    ToPostCode := CompanyInformation."Post Code";

        if SupplyType = SupplyType::Outward then
            case SubType of
                SubType::Supply, SubType::Export, SubType::"Recipient Not Known":
                    if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::" " then begin
                        TransferShipmentHeader.Get("Detailed GST Ledger Entry"."Document No.");
                        Location.Get(TransferShipmentHeader."Transfer-to Code");
                        ToPostCode := Location."Post Code";
                    end else
                        if DelGSTLedgerEntryInfo."Ship-to Code" <> '' then
                            ToPostCode := ShipToAddress."Post Code"
                        else
                            ToPostCode := Customer."Post Code";

                SubType::Others:
                    if DelGSTLedgerEntryInfo."Order Address Code" <> '' then
                        ToPostCode := OrderAddress."Post Code"
                    else
                        ToPostCode := Vendor."Post Code";
            end;
    end;

    local procedure GetToState() ToState: Text[50]
    var
        State: Record State;
        ToStateCode: Code[10];
    begin
        if SupplyType = SupplyType::Inward then
            if SubType in [SubType::Supply, SubType::"Sales Returns"] then
                ToStateCode := DelGSTLedgerEntryInfo."Location State Code"
            else
                if SubType = SubType::Import then
                    ToStateCode := '';

        if SupplyType = SupplyType::Outward then
            case SubType of
                SubType::Supply, SubType::"Recipient Not Known", SubType::Others:
                    if DelGSTLedgerEntryInfo."Ship-to Code" <> '' then
                        ToStateCode := DelGSTLedgerEntryInfo."Shipping Address State Code"
                    else
                        ToStateCode := DelGSTLedgerEntryInfo."Buyer/Seller State Code";

                SubType::Export:
                    if DelGSTLedgerEntryInfo."Ship-to Code" <> '' then begin
                        ShipToAddress.Get("Detailed GST Ledger Entry"."Source No.", DelGSTLedgerEntryInfo."Ship-to Code");
                        ToStateCode := ShipToAddress.State;
                    end else begin
                        Customer.Get("Detailed GST Ledger Entry"."Source No.");
                        ToStateCode := Customer."State Code";
                    end;
            end;
        if State.Get(ToStateCode) then
            ToState := State.Description;
    end;

    local procedure GetUOM() UOMDesc: Text[10]
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        UnitOfMeasure: Record "Unit of Measure";
        TransferShipmentLine: Record "Transfer Shipment Line";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        if "Detailed GST Ledger Entry"."TransAction Type" = "Detailed GST Ledger Entry"."TransAction Type"::Sales then begin
            if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::Invoice then
                if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Customer then begin
                    if SalesInvoiceLine.Get("Detailed GST Ledger Entry"."Document No.", "Detailed GST Ledger Entry"."Document Line No.") then
                        if UnitOfMeasure.Get(SalesInvoiceLine."Unit of Measure Code") then
                            UOMDesc := CopyStr(UnitOfMeasure.Description, 1, 10)
                end else
                    if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::" " then begin
                        TransferShipmentLine.Get("Detailed GST Ledger Entry"."Document No.", "Detailed GST Ledger Entry"."Document Line No.");
                        if UnitOfMeasure.Get(TransferShipmentLine."Unit of Measure Code") then
                            UOMDesc := CopyStr(UnitOfMeasure.Description, 1, 10)
                    end;

            if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::"Credit Memo" then
                if SalesCrMemoLine.Get("Detailed GST Ledger Entry"."Document No.", "Detailed GST Ledger Entry"."Document Line No.") then
                    if UnitOfMeasure.Get(SalesCrMemoLine."Unit of Measure Code") then
                        UOMDesc := CopyStr(UnitOfMeasure.Description, 1, 10);
        end else
            if "Detailed GST Ledger Entry"."TransAction Type" = "Detailed GST Ledger Entry"."TransAction Type"::Purchase then
                if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::Invoice then begin
                    PurchInvLine.Get("Detailed GST Ledger Entry"."Document No.", "Detailed GST Ledger Entry"."Document Line No.");
                    if UnitOfMeasure.Get(PurchInvLine."Unit of Measure Code") then
                        UOMDesc := CopyStr(UnitOfMeasure.Description, 1, 10);
                end else
                    if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::"Credit Memo" then begin
                        PurchCrMemoLine.Get("Detailed GST Ledger Entry"."Document No.", "Detailed GST Ledger Entry"."Document Line No.");
                        if UnitOfMeasure.Get(PurchCrMemoLine."Unit of Measure Code") then
                            UOMDesc := CopyStr(UnitOfMeasure.Description, 1, 10);
                    end;
    end;

    local procedure GetGSTAmount()
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGstLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        DetailedGSTLedgerEntry.SetRange("Document Type", "Detailed GST Ledger Entry"."Document Type");
        DetailedGSTLedgerEntry.SetRange("Document No.", "Detailed GST Ledger Entry"."Document No.");
        DetailedGSTLedgerEntry.SetRange("Document Line No.", "Detailed GST Ledger Entry"."Document Line No.");
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                if DetailedGSTLedgerEntry."GST Component Code" = CGSTTxt then
                    CGSTAmount := DetailedGSTLedgerEntry."GST Amount";

                if DetailedGSTLedgerEntry."GST Component Code" = SGSTTxt then
                    SGSTAmount := DetailedGSTLedgerEntry."GST Amount";

                if DetailedGSTLedgerEntry."GST Component Code" = IGSTTxt then
                    IGSTAmount := DetailedGSTLedgerEntry."GST Amount";

                if DetailedGSTLedgerEntry."GST Component Code" = CESSTxt then
                    if DetailedGSTLedgerEntry."GST Customer Type" <> DetailedGSTLedgerEntry."GST Customer Type"::Exempted then begin
                        DetailedGstLedgerEntryInfo.SetRange("Entry No.", DetailedGSTLedgerEntry."Entry No.");
                        if DetailedGstLedgerEntryInfo.FindFirst() then
                            CessNonAdvolAmount := (DetailedGSTLedgerEntry.Quantity * DetailedGstLedgerEntryInfo."Cess Amount Per Unit Factor");

                        CESSAmount := ((DetailedGSTLedgerEntry."GST Amount") - (CessNonAdvolAmount));
                    end;
                GetTotalInvoiceValue(DetailedGSTLedgerEntry);
            until DetailedGSTLedgerEntry.Next() = 0;
    end;
    //Function For Showing Other Charges In 'Others' Field
    local procedure GetOthersValue()
    var
        DetailedGstLedEntry: Record "Detailed GST Ledger Entry";
    begin
        if DetailGstLENo <> "Detailed GST Ledger Entry"."Document No." then begin
            Others := 0;
            DetailedGstLedEntry.SetRange("Document No.", "Detailed GST Ledger Entry"."Document No.");
            DetailedGstLedEntry.SetRange("GST Group Type", DetailedGstLedEntry."GST Group Type"::Service);
            if DetailedGstLedEntry.FindSet() then
                repeat
                    if ServiceNo <> DetailedGstLedEntry."No." then begin
                        Others += DetailedGstLedEntry."GST Base Amount";
                        ServiceNo := DetailedGstLedEntry."No.";
                    end;
                until DetailedGstLedEntry.Next() = 0;
            DetailGstLENo := DetailedGstLedEntry."Document No.";
            ServiceNo := '';
        end;
    end;

    local procedure GetTotalInvoiceValue(var DetailedGstLedgerEntry: Record "Detailed GST Ledger Entry")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if DetailedGstLedgerEntry."Transaction Type" = DetailedGstLedgerEntry."Transaction Type"::Purchase then begin
            VendorLedgerEntry.SetRange("Document No.", DetailedGstLedgerEntry."Document No.");
            if VendorLedgerEntry.Find('-') then
                VendorLedgerEntry.CalcFields("Amount (LCY)");
            TotalInvoiceValue := VendorLedgerEntry."Amount (LCY)";
        end
        else
            if DetailedGstLedgerEntry."Transaction Type" = DetailedGstLedgerEntry."Transaction Type"::Sales then begin
                CustomerLedgerEntry.SetRange("Document No.", DetailedGstLedgerEntry."Document No.");
                if CustomerLedgerEntry.Find('-') then
                    CustomerLedgerEntry.CalcFields("Amount (LCY)");
                TotalInvoiceValue := CustomerLedgerEntry."Amount (LCY)";
            end;

    end;

    local procedure GetTransMode() TransMode: Text[50]
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        TransportMethod: Record "Transport Method";
    begin
        if "Detailed GST Ledger Entry"."Transaction Type" = "Detailed GST Ledger Entry"."Transaction Type"::Sales then begin
            if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::Invoice then
                if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Customer then begin
                    if SalesInvoiceHeader.Get("Detailed GST Ledger Entry"."Document No.") then
                        if TransportMethod.Get(SalesInvoiceHeader."Transport Method") then
                            TransMode := TransportMethod.Code;
                end else
                    if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::" " then begin
                        TransferShipmentHeader.Get("Detailed GST Ledger Entry"."Document No.");
                        if TransportMethod.Get(TransferShipmentHeader."Transport Method") then
                            TransMode := TransportMethod.Code;
                    end;

            if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::"Credit Memo" then
                if SalesCrMemoHeader.Get("Detailed GST Ledger Entry"."Document No.") then
                    if TransportMethod.Get(SalesCrMemoHeader."Transport Method") then
                        TransMode := TransportMethod.Code;
        end else
            if "Detailed GST Ledger Entry"."Transaction Type" = "Detailed GST Ledger Entry"."Transaction Type"::Purchase then
                if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::Invoice then begin
                    PurchInvHeader.Get("Detailed GST Ledger Entry"."Document No.");
                    if TransportMethod.Get(PurchInvHeader."Transport Method") then
                        TransMode := TransportMethod.Code;
                end else
                    if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::"Credit Memo" then begin
                        PurchCrMemoHdr.Get("Detailed GST Ledger Entry"."Document No.");
                        if TransportMethod.Get(PurchCrMemoHdr."Transport Method") then
                            TransMode := TransportMethod.Code;
                    end;
    end;

    local procedure GetDistance(): Decimal
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TransferShipmentHead: Record "Transfer Shipment Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        if "Detailed GST Ledger Entry"."TransAction Type" = "Detailed GST Ledger Entry"."TransAction Type"::Sales then begin
            if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::Invoice then begin
                if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Customer then
                    if SalesInvoiceHeader.Get("Detailed GST Ledger Entry"."Document No.") then
                        exit(SalesInvoiceHeader."Distance (Km)");

                if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::" " then
                    if TransferShipmentHead.Get("Detailed GST Ledger Entry"."Document No.") then
                        exit(TransferShipmentHead."Distance (Km)");
            end;

            if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::"Credit Memo" then
                if SalesCrMemoHeader.Get("Detailed GST Ledger Entry"."Document No.") then
                    exit(SalesCrMemoHeader."Distance (Km)");
        end;
        if "Detailed GST Ledger Entry"."TransAction Type" = "Detailed GST Ledger Entry"."TransAction Type"::Purchase then begin
            if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::Invoice then
                if PurchInvHeader.Get("Detailed GST Ledger Entry"."Document No.") then
                    exit(PurchInvHeader."Distance (Km)");

            if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::"Credit Memo" then
                if PurchCrMemoHdr.Get("Detailed GST Ledger Entry"."Document No.") then
                    exit(PurchCrMemoHdr."Distance (Km)");
        end;
    end;

    local procedure GetTransName() TransName: Text[50]
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        ShippingAgent: Record "Shipping Agent";
    begin
        if "Detailed GST Ledger Entry"."TransAction Type" = "Detailed GST Ledger Entry"."TransAction Type"::Sales then begin
            if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::Invoice then
                if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Customer then begin
                    if SalesInvoiceHeader.Get("Detailed GST Ledger Entry"."Document No.") then
                        if ShippingAgent.Get(SalesInvoiceHeader."Shipping Agent Code") then
                            TransName := ShippingAgent.Name;
                end else
                    if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::" " then begin
                        TransferShipmentHeader.Get("Detailed GST Ledger Entry"."Document No.");
                        if ShippingAgent.Get(TransferShipmentHeader."Shipping Agent Code") then
                            TransName := ShippingAgent.Name;
                    end;
            if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::"Credit Memo" then
                if SalesCrMemoHeader.Get("Detailed GST Ledger Entry"."Document No.") then
                    TransName := ShippingAgent.Name;
        end else
            if "Detailed GST Ledger Entry"."TransAction Type" = "Detailed GST Ledger Entry"."TransAction Type"::Purchase then
                if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::Invoice then begin
                    PurchInvHeader.Get("Detailed GST Ledger Entry"."Document No.");
                    if ShippingAgent.Get(PurchInvHeader."Shipping Agent Code") then
                        TransName := ShippingAgent.Name;
                end else
                    if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::"Credit Memo" then begin
                        PurchCrMemoHdr.Get("Detailed GST Ledger Entry"."Document No.");
                        if ShippingAgent.Get(PurchCrMemoHdr."Shipping Agent Code") then
                            TransName := ShippingAgent.Name;
                    end;
    end;

    local procedure GetTransID() TransID: Code[15]
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TransferShipmentHead: Record "Transfer Shipment Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        ShippingAgent: Record "Shipping Agent";
    begin
        if "Detailed GST Ledger Entry"."TransAction Type" = "Detailed GST Ledger Entry"."TransAction Type"::Sales then begin
            if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::Invoice then
                if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Customer then begin
                    if SalesInvoiceHeader.Get("Detailed GST Ledger Entry"."Document No.") then
                        if ShippingAgent.Get(SalesInvoiceHeader."Shipping Agent Code") then
                            TransID := CopyStr(ShippingAgent."GST Registration No.", 1, 15);
                end else
                    if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::" " then begin
                        TransferShipmentHeader.Get("Detailed GST Ledger Entry"."Document No.");
                        if ShippingAgent.Get(TransferShipmentHead."Shipping Agent Code") then
                            TransID := CopyStr(ShippingAgent."GST Registration No.", 1, 15);
                    end;
            if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::"Credit Memo" then
                if SalesCrMemoHeader.Get("Detailed GST Ledger Entry"."Document No.") then
                    TransID := CopyStr(ShippingAgent."GST Registration No.", 1, 15)
        end else
            if "Detailed GST Ledger Entry"."TransAction Type" = "Detailed GST Ledger Entry"."TransAction Type"::Purchase then
                if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::Invoice then begin
                    PurchInvHeader.Get("Detailed GST Ledger Entry"."Document No.");
                    if ShippingAgent.Get(PurchInvHeader."Shipping Agent Code") then
                        TransID := CopyStr(ShippingAgent."GST Registration No.", 1, 15);
                end else
                    if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::"Credit Memo" then begin
                        PurchCrMemoHdr.Get("Detailed GST Ledger Entry"."Document No.");
                        if ShippingAgent.Get(PurchCrMemoHdr."Shipping Agent Code") then
                            TransID := CopyStr(ShippingAgent."GST Registration No.", 1, 15);
                    end;
    end;

    local procedure GetVehicleNo() VehicleNo: Code[20]
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        if "Detailed GST Ledger Entry"."TransAction Type" = "Detailed GST Ledger Entry"."TransAction Type"::Sales then begin
            if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::Invoice then
                if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Customer then begin
                    if SalesInvoiceHeader.Get("Detailed GST Ledger Entry"."Document No.") then
                        VehicleNo := SalesInvoiceHeader."Vehicle No.";
                end else
                    if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::" " then begin
                        TransferShipmentHeader.Get("Detailed GST Ledger Entry"."Document No.");
                        VehicleNo := TransferShipmentHeader."Vehicle No.";
                    end;
            if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::"Credit Memo" then
                if SalesCrMemoHeader.Get("Detailed GST Ledger Entry"."Document No.") then
                    VehicleNo := SalesCrMemoHeader."Vehicle No.";
        end else
            if "Detailed GST Ledger Entry"."TransAction Type" = "Detailed GST Ledger Entry"."TransAction Type"::Purchase then
                if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::Invoice then begin
                    PurchInvHeader.Get("Detailed GST Ledger Entry"."Document No.");
                    VehicleNo := PurchInvHeader."Vehicle No.";
                end else
                    if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::"Credit Memo" then begin
                        PurchCrMemoHdr.Get("Detailed GST Ledger Entry"."Document No.");
                        VehicleNo := PurchCrMemoHdr."Vehicle No.";
                    end;
    end;

    local procedure GetDispatchState() DispatchState: Text[50]
    var
        PurchaseHead: Record "Purchase Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        State: Record State;
    begin
        if SupplyType = SupplyType::Outward then
            if SubType in [SubType::Supply, SubType::"Recipient Not Known"] then begin
                SalesInvoiceLine.SetRange("Document No.", "Detailed GST Ledger Entry"."Document No.");
                SalesInvoiceLine.SetRange("Drop Shipment", true);
                if SalesInvoiceLine.FindFirst() then begin
                    PurchaseHead.SetRange("No.", SalesInvoiceLine."Order No.");
                    if PurchaseHead.FindFirst() then
                        if State.Get(PurchaseHead.State) then
                            DispatchState := State.Description;
                end;
            end;
    end;

    local procedure GetShipToState() ShipToState: Text[50]
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        State: Record State;
        ShipToStateCode: Code[10];
    begin
        if SupplyType = SupplyType::Outward then
            if SubType in [SubType::Supply, SubType::"Recipient Not Known"] then begin
                SalesInvoiceLine.SetRange("Document No.", "Detailed GST Ledger Entry"."Document No.");
                SalesInvoiceLine.SetRange("Drop Shipment", true);
                if SalesInvoiceLine.FindFirst() then begin
                    SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.");
                    if SalesInvoiceHeader."Ship-to Code" <> '' then
                        ShipToStateCode := SalesInvoiceHeader."GST Ship-to State Code"
                    else
                        ShipToStateCode := SalesInvoiceHeader."GST Bill-to State Code"
                end;
            end;
        if State.Get(ShipToStateCode) then
            ShipToState := State.Description;
    end;

    local procedure GetVehicleType() VehicleType: Text[10]
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TransferShptHeader: Record "Transfer Shipment Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        if "Detailed GST Ledger Entry"."TransAction Type" = "Detailed GST Ledger Entry"."TransAction Type"::Sales then begin
            if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::Invoice then
                if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::Customer then begin
                    if SalesInvoiceHeader.Get("Detailed GST Ledger Entry"."Document No.") then
                        VehicleType := Format(SalesInvoiceHeader."Vehicle Type");
                end else
                    if "Detailed GST Ledger Entry"."Source Type" = "Detailed GST Ledger Entry"."Source Type"::" " then begin
                        TransferShptHeader.Get("Detailed GST Ledger Entry"."Document No.");
                        VehicleType := Format(TransferShptHeader."Vehicle Type");
                    end;

            if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::"Credit Memo" then
                if SalesCrMemoHeader.Get("Detailed GST Ledger Entry"."Document No.") then
                    VehicleType := Format(SalesCrMemoHeader."Vehicle Type");
        end else
            if "Detailed GST Ledger Entry"."TransAction Type" = "Detailed GST Ledger Entry"."TransAction Type"::Purchase then
                if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::Invoice then begin
                    PurchInvHeader.Get("Detailed GST Ledger Entry"."Document No.");
                    VehicleType := Format(PurchInvHeader."Vehicle Type");
                end else
                    if "Detailed GST Ledger Entry"."Document Type" = "Detailed GST Ledger Entry"."Document Type"::"Credit Memo" then begin
                        PurchCrMemoHdr.Get("Detailed GST Ledger Entry"."Document No.");
                        VehicleType := Format(PurchCrMemoHdr."Vehicle Type");
                    end;
    end;

    local procedure GetTaxRate() TaxRate: Text[12]
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGstLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        CGSTTaxRate: Decimal;
        SGSTTaxRate: Decimal;
        IGSTTaxRate: Decimal;
        CESSTaxRate: Decimal;
        CESSAdvolTaxRate: Decimal;
    begin
        DetailedGSTLedgerEntry.SetRange("Document Type", "Detailed GST Ledger Entry"."Document Type");
        DetailedGSTLedgerEntry.SetRange("Document No.", "Detailed GST Ledger Entry"."Document No.");
        DetailedGSTLedgerEntry.SetRange("Document Line No.", "Detailed GST Ledger Entry"."Document Line No.");
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                if DetailedGSTLedgerEntry."GST Component Code" = 'SGST' then
                    SGSTTaxRate := DetailedGSTLedgerEntry."GST %";
                if DetailedGSTLedgerEntry."GST Component Code" = 'CGST' then
                    CGSTTaxRate := DetailedGSTLedgerEntry."GST %";
                if DetailedGSTLedgerEntry."GST Component Code" = 'IGST' then
                    IGSTTaxRate := DetailedGSTLedgerEntry."GST %";
                if DetailedGSTLedgerEntry."GST Component Code" = 'CESS' then begin
                    CessTaxRate := DetailedGSTLedgerEntry."GST %";
                    DetailedGstLedgerEntryInfo.SetRange("Entry No.", DetailedGSTLedgerEntry."Entry No.");
                    if DetailedGstLedgerEntryInfo.FindFirst() then
                        CESSAdvolTaxRate := DetailedGstLedgerEntryInfo."Cess Amount Per Unit Factor";
                end;

                TaxRate :=
                  Format(SGSTTaxRate) + '+' + Format(CGSTTaxRate) + '+' + Format(IGSTTaxRate) + '+' + Format(CessTaxRate) + '+' + Format(CESSAdvolTaxRate);
            until DetailedGSTLedgerEntry.Next() = 0;
    end;

    local procedure CreateExcelBook()
    begin
        TempExcelBuffer.CreateNewBook('E-WayBill');
        TempExcelBuffer.WriteSheet('E-WayBill', CompanyName(), UserId());
        TempExcelBuffer.CloseBook();
        TempExcelBuffer.OpenExcel();
    end;
}
