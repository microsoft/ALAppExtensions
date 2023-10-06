// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ServicesTransfer;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Setup;
using System.Reflection;

codeunit 18350 "Service Transfer Post"
{
    TableNo = "Service Transfer Header";

    trigger OnRun()
    begin
        ServiceTransferHeader.Copy(Rec);
        Code();
        Rec := ServiceTransferHeader;
    end;

    var
        TempTransferBufferStage: Record "Transfer Buffer" temporary;
        TempTransferBufferFinal: Record "Transfer Buffer" temporary;
        TempGSTPostingBufferStage: Record "GST Posting Buffer" temporary;
        TempGSTPostingBufferFinal: Record "GST Posting Buffer" temporary;
        ServiceTransferHeader: Record "Service Transfer Header";
        GenJnlLine: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        SourceCode: Code[10];
        PostedServiceTransferShptDocNo: Code[20];
        PostedServiceTransferRcptDocNo: Code[20];
        TransferAmount: Decimal;
        GSTAmount: Decimal;
        InvoiceRoundingAmount: Decimal;
        ControlAccount: Boolean;
        PreviewMode: Boolean;
        ShipReceiveQst: Label '&Ship,&Receive';
        SameLocErr: Label 'Service Transfer order %1 canNot be posted because %2 and %3 are the same.', Comment = '%1 = Transfer Order;%2 = From Location;%3 = To Location';
        ServTransDimErr: Label 'The combination of dimensions used in Service Transfer order %1 is blocked. %2.', Comment = '%1 = Order No ;%2 = Error';
        ServTransDimCombErr: Label 'The combination of dimensions used in Service Transfer order %1, line no. %2 is blocked. %3.', Comment = '%1 = Order No ;%2 = Line No ;%3 = Error';
        PostMsg: Label 'Posting transfer lines     #2######', Comment = '#2###';
        ServTransMsg: Label 'Service Transfer Order %1.', Comment = 'Service Transfer Order %1.';
        NoSeriesErr: Label '%1 must not be empty in %2 or %3.', Comment = '%1 = Field Name, %2 = Table Name, %3 = Table Name ';
        ServiceTranTxt: Label 'Service Transfer - %1', Comment = '%1 = Transfer Doc ';
        ServTransDelMsg: Label 'Service Transfer Order %1 has been deleted.', Comment = '%1 = Service Transfer Order No';
        LocationCodeErr: Label 'Please specIfy the Location Code or Location GST Registration No. for the selected Document.';
        ServiceTransferLineErr: Label 'There is nothing to post. Service Transfer Line not available for the selected Document.';

    local procedure InsertDetailedGSTLedgerEnfo(
            DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
            ServiceTransferHeader: Record "Service Transfer Header";
            DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
            DocTransferType: Enum "Service Doc Transfer Type")
    var
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        LocationFrom: Record Location;
        LocationTo: Record Location;
    begin
        if (ServiceTransferHeader."Transfer-from Code" = '') or (ServiceTransferHeader."Transfer-to Code" = '') then
            exit;

        LocationFrom.Get(ServiceTransferHeader."Transfer-from Code");
        LocationTo.Get(ServiceTransferHeader."Transfer-to Code");

        DetailedGSTLedgerEntryInfo.Init();
        DetailedGSTLedgerEntryInfo."Entry No." := DetailedGSTLedgerEntry."Entry No.";
        DetailedGSTLedgerEntryInfo."Original Doc. No." := ServiceTransferHeader."No.";
        DetailedGSTLedgerEntryInfo.Positive := DetailedGSTLedgerEntry."GST Amount" > 0;
        DetailedGSTLedgerEntryInfo."User ID" := CopyStr(UserId, 1, MaxStrLen(DetailedGSTLedgerEntryInfo."User ID"));
        DetailedGSTLedgerEntryInfo.Cess := DetailedGSTEntryBuffer.Cess;
        DetailedGSTLedgerEntryInfo."Component Calc. Type" := DetailedGSTEntryBuffer."Component Calc. Type";
        DetailedGSTLedgerEntryInfo."Cess Amount Per Unit Factor" := DetailedGSTEntryBuffer."Cess Amt Per Unit Factor (LCY)";
        DetailedGSTLedgerEntryInfo."Cess UOM" := DetailedGSTEntryBuffer."Cess UOM";
        DetailedGSTLedgerEntryInfo."Cess Factor Quantity" := DetailedGSTEntryBuffer."Cess Factor Quantity";
        if DocTransferType = DocTransferType::"Service Transfer Shipment" then begin
            DetailedGSTLedgerEntryInfo."Location State Code" := LocationFrom."State Code";
            DetailedGSTLedgerEntryInfo."Location ARN No." := LocationFrom."Location ARN No.";
            DetailedGSTLedgerEntryInfo."Buyer/Seller State Code" := LocationTo."State Code";
            DetailedGSTLedgerEntryInfo."Shipping Address State Code" := '';
            DetailedGSTLedgerEntryInfo."Original Doc. Type" := DetailedGSTLedgerEntryInfo."Original Doc. Type"::"Transfer Shipment";
        end else begin
            DetailedGSTLedgerEntryInfo."Location ARN No." := LocationTo."Location ARN No.";
            DetailedGSTLedgerEntryInfo."Location State Code" := LocationTo."State Code";
            DetailedGSTLedgerEntryInfo."Buyer/Seller State Code" := LocationFrom."State Code";
            DetailedGSTLedgerEntryInfo."Shipping Address State Code" := '';
            DetailedGSTLedgerEntryInfo."Original Doc. Type" := DetailedGSTLedgerEntryInfo."Original Doc. Type"::"Transfer Receipt";
        end;
        DetailedGSTLedgerEntryInfo.Insert(true);
    end;

    local procedure Code()
    var
        ServiceTransferLine: Record "Service Transfer Line";
        DefaultNumber: Integer;
    begin
        ServiceTransferLine.SetRange("Document No.", ServiceTransferHeader."No.");
        if ServiceTransferLine.FindSet() then
            repeat
                if not ServiceTransferLine.Shipped and (DefaultNumber = 0) then
                    DefaultNumber := 1;
                if ServiceTransferLine.Shipped and (DefaultNumber = 0) then
                    DefaultNumber := 2;
            until (ServiceTransferLine.Next() = 0) or (DefaultNumber > 0);

        if DefaultNumber = 0 then
            Error(ServiceTransferLineErr);

        PostingSelection(DefaultNumber);

        if PreviewMode then
            GenJnlPostPreview.ThrowError();
    end;

    local procedure PostingSelection(DefaultNumber: Integer)
    begin
        GLSetup.Get();

        case StrMenu(ShipReceiveQst, DefaultNumber) of
            1:
                ServiceTransferPostShipment(ServiceTransferHeader);
            2:
                ServiceTransferPostReceipt(ServiceTransferHeader);
        end;
    end;

    local procedure ServiceTransferPostShipment(ServiceTransferHeader: Record "Service Transfer Header")
    var
        ServiceTransferLine: Record "Service Transfer Line";
        SourceCodeSetup: Record "Source Code Setup";
        GSTBaseValidation: Codeunit "GST Base Validation";
        DocTransferType: Enum "Service Doc Transfer Type";
        GSTRoundingAmount: Decimal;
        Window: Dialog;
    begin
        ClearPostingBuffer(ServiceTransferHeader."No.");
        GSTBaseValidation.CheckGSTAccountingPeriod(ServiceTransferHeader."Shipment Date", false);
        CheckServiceTransfer(ServiceTransferHeader, true);

        CheckDim();
        GLSetup.Get();
        TempTransferBufferStage.DeleteAll();
        TempGSTPostingBufferStage.DeleteAll();
        Window.Open('#1#################################\\' + PostMsg);
        Window.Update(1, StrSubstNo(ServTransMsg, ServiceTransferHeader."No."));

        SourceCodeSetup.Get();
        SourceCode := SourceCodeSetup."Service Transfer Shipment";

        //Fill Detailed GST Buffer
        FillDetailLedgBufferServTran(ServiceTransferHeader."No.");

        // Insert Service Transfer Shipment Header
        PostedServiceTransferShptDocNo := InsertServiceTransShptHeader(ServiceTransferHeader);
        InsertServiceTransShptLine();

        TempTransferBufferFinal.SetCurrentKey("sorting no.");
        TempTransferBufferFinal.SetAscending("Sorting No.", false);
        if TempTransferBufferFinal.FindSet() then
            repeat
                PostTransLineToGenJnlLine(ServiceTransferHeader, true);
            until TempTransferBufferFinal.Next() = 0;

        //Post GST Ledger G/L    
        TempGSTPostingBufferFinal.SetCurrentKey(
        "Transaction Type", Type, "Gen. Bus. Posting Group",
        "Gen. Prod. Posting Group", "GST Component Code", "GST Group Type", "Account No.",
        "Dimension Set ID", "GST Reverse Charge", Availment, "Normal Payment",
        "Forex Fluctuation", "Document Line No.");
        TempGSTPostingBufferFinal.SetAscending("Document Line No.", false);
        if TempGSTPostingBufferFinal.FindSet() then
            repeat
                PostTransLineToGenJnlLineGST(ServiceTransferHeader, true);
                GSTRoundingAmount += TempGSTPostingBufferFinal."GST Amount";
            until TempGSTPostingBufferFinal.Next() = 0;

        if (GSTRoundingAmount <> 0) and (ServiceTransferHeader."GST Inv. Rounding Precision" <> 0) then begin
            InvoiceRoundingAmount :=
              -Round(GSTRoundingAmount -
                Round(
                  GSTRoundingAmount,
                  ServiceTransferHeader."GST Inv. Rounding Precision",
                  ServiceTransferHeader.GSTInvoiceRoundingDirection()),
                GLSetup."Inv. Rounding Precision (LCY)");
            if InvoiceRoundingAmount <> 0 then
                PostGSTInvoiceRounding(ServiceTransferHeader, true);
        end;

        ServiceTransferLine.SetRange("Document No.", ServiceTransferHeader."No.");
        ServiceTransferLine.SetFilter("Transfer From G/L Account No.", '<>%1', '');
        if ServiceTransferLine.FindSet(true, false) then
            repeat
                InsertDetailedGSTLedgEntryServiceTransfer(
                    ServiceTransferLine, ServiceTransferHeader,
                    PostedServiceTransferShptDocNo, GenJnlPostLine.GetNextTransactionNo(),
                    DocTransferType::"Service Transfer Shipment");
                ServiceTransferLine.Shipped := true;
                ServiceTransferLine.Modify();
            until ServiceTransferLine.Next() = 0;

        ControlAccount := true;
        PostTransLineToGenJnlLine(ServiceTransferHeader, true);
        ServiceTransferHeader."External Doc No." := PostedServiceTransferShptDocNo;
        ServiceTransferHeader.Status := Status::Shipped;
        ServiceTransferHeader.Modify();
        Window.Close();
    end;

    local procedure ServiceTransferPostReceipt(ServiceTransferHeader: Record "Service Transfer Header")
    var
        SourceCodeSetup: Record "Source Code Setup";
        ServiceTransferLine: Record "Service Transfer Line";
        GSTBaseValidation: Codeunit "GST Base Validation";
        DocTransferType: Enum "Service Doc Transfer Type";
        GSTRoundingAmount: Decimal;
        Window: Dialog;
    begin
        ClearPostingBuffer(ServiceTransferHeader."No.");
        GSTBaseValidation.CheckGSTAccountingPeriod(ServiceTransferHeader."Receipt Date", false);
        CheckServiceTransfer(ServiceTransferHeader, false);
        CheckDim();

        TempTransferBufferStage.DeleteAll();
        TempGSTPostingBufferStage.DeleteAll();
        Window.Open('#1#################################\\' + PostMsg);
        Window.Update(1, StrSubstNo(ServTransMsg, ServiceTransferHeader."No."));
        GLSetup.Get();
        SourceCodeSetup.Get();
        SourceCode := SourceCodeSetup."Service Transfer Receipt";

        //Fill Detailed GST Buffer
        FillDetailLedgBufferServTran(ServiceTransferHeader."No.");

        // Insert Service Transfer Receipt Header
        PostedServiceTransferRcptDocNo := InsertServiceTransRcptHeader(ServiceTransferHeader);
        InsertServiceTransRcptLine();

        TempTransferBufferFinal.SetCurrentKey("sorting no.");
        TempTransferBufferFinal.SetAscending("Sorting No.", false);
        if TempTransferBufferFinal.FindSet() then
            if TempTransferBufferFinal.FindSet() then
                repeat
                    PostTransLineToGenJnlLine(ServiceTransferHeader, false);
                until TempTransferBufferFinal.Next() = 0;

        TempGSTPostingBufferFinal.SetCurrentKey(
        "Transaction Type", Type, "Gen. Bus. Posting Group",
        "Gen. Prod. Posting Group", "GST Component Code", "GST Group Type", "Account No.",
        "Dimension Set ID", "GST Reverse Charge", Availment, "Normal Payment",
        "Forex Fluctuation", "Document Line No.");
        TempGSTPostingBufferFinal.SetAscending("Document Line No.", false);
        if TempGSTPostingBufferFinal.FindSet() then
            repeat
                PostTransLineToGenJnlLineGST(ServiceTransferHeader, false);
                GSTRoundingAmount += TempGSTPostingBufferFinal."GST Amount";
            until TempGSTPostingBufferFinal.Next() = 0;

        if (GSTRoundingAmount <> 0) and (ServiceTransferHeader."GST Inv. Rounding Precision" <> 0) then begin
            InvoiceRoundingAmount :=
              -Round(GSTRoundingAmount -
                Round(
                  GSTRoundingAmount,
                  ServiceTransferHeader."GST Inv. Rounding Precision",
                  ServiceTransferHeader.GSTInvoiceRoundingDirection()),
                GLSetup."Inv. Rounding Precision (LCY)");
            if InvoiceRoundingAmount <> 0 then
                PostGSTInvoiceRounding(ServiceTransferHeader, false);
        end;
        ServiceTransferLine.SetRange("Document No.", ServiceTransferHeader."No.");
        ServiceTransferLine.SetFilter("Transfer From G/L Account No.", '<>%1', '');
        if ServiceTransferLine.FindSet() then
            repeat
                InsertDetailedGSTLedgEntryServiceTransfer(
                 ServiceTransferLine, ServiceTransferHeader,
                 PostedServiceTransferRcptDocNo,
                 GenJnlPostLine.GetNextTransactionNo(), DocTransferType::"Service Transfer Receipt");
            until ServiceTransferLine.Next() = 0;

        ControlAccount := true;
        PostTransLineToGenJnlLine(ServiceTransferHeader, false);

        if not PreviewMode then
            DeleteOneServiceTransferOrder();

        Window.Close();
    end;

    local procedure CheckServiceTransfer(ServiceTransferHeader: Record "Service Transfer Header"; Ship: Boolean)
    var
        ServiceTransferLine: Record "Service Transfer Line";
    begin
        ServiceTransferHeader.TestField("Transfer-from Code");
        ServiceTransferHeader.TestField("Transfer-to Code");

        if Ship then begin
            ServiceTransferHeader.TestField(Status, Status::Open);
            ServiceTransferHeader.TestField("Ship Control Account");
        end else begin
            ServiceTransferHeader.TestField(Status, Status::Shipped);
            ServiceTransferHeader.TestField("Receive Control Account");
            ServiceTransferHeader.TestField("Receipt Date");
        end;

        if ServiceTransferHeader."Transfer-from Code" = ServiceTransferHeader."Transfer-to Code" then
            Error(
                SameLocErr,
                ServiceTransferHeader."No.",
                ServiceTransferHeader.FieldCaption("Transfer-from Code"),
                ServiceTransferHeader.FieldCaption("Transfer-to Code"));

        ServiceTransferHeader.TestField("Transfer-from State");
        ServiceTransferHeader.TestField("Transfer-to State");
        ServiceTransferHeader.TestField("Shipment Date");
        ServiceTransferLine.SetRange("Document No.", ServiceTransferHeader."No.");
        if ServiceTransferLine.FindSet() then
            repeat
                if Ship then begin
                    ServiceTransferLine.TestField("Transfer From G/L Account No.");
                    ServiceTransferLine.TestField(Shipped, false);
                end else begin
                    ServiceTransferLine.TestField("Transfer To G/L Account No.");
                    ServiceTransferLine.TestField(Shipped, true);
                end;

                ServiceTransferLine.TestField("Transfer Price");
                ServiceTransferLine.TestField("GST Group Code");
                ServiceTransferLine.TestField("SAC Code");
            until ServiceTransferLine.Next() = 0;
    end;

    local procedure CheckDim()
    var
        ServiceTransferLine: Record "Service Transfer Line";
    begin
        ServiceTransferLine."Line No." := 0;
        CheckDimComb(ServiceTransferHeader, ServiceTransferLine);

        ServiceTransferLine.SetRange("Document No.", ServiceTransferHeader."No.");
        if ServiceTransferLine.FindFirst() then
            CheckDimComb(ServiceTransferHeader, ServiceTransferLine);
    end;

    local procedure CheckDimComb(
        ServiceTransferHeader: Record "Service Transfer Header";
        ServiceTransferLine: Record "service transfer line")
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        if ServiceTransferLine."Line No." = 0 then
            if not DimensionManagement.CheckDimIDComb(ServiceTransferHeader."Dimension Set ID") then
                Error(
                  ServTransDimErr,
                  ServiceTransferHeader."No.",
                  DimensionManagement.GetDimCombErr());

        if ServiceTransferLine."Line No." <> 0 then
            if not DimensionManagement.CheckDimIDComb(ServiceTransferLine."Dimension Set ID") then
                Error(
                  ServTransDimCombErr,
                  ServiceTransferHeader."No.",
                  ServiceTransferLine."Line No.",
                  DimensionManagement.GetDimCombErr());
    end;

    local procedure InsertServiceTransShptHeader(ServTransHeader: Record "Service Transfer Header"): Code[20]
    var
        ServiceTransferShptHeader: Record "Service Transfer Shpt. Header";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        ServiceTransferShptHeader.LockTable();

        ServiceTransferShptHeader.Init();
        ServiceTransferShptHeader."Service Transfer Order No." := ServTransHeader."No.";
        ServiceTransferShptHeader."Transfer-from Code" := ServTransHeader."Transfer-from Code";
        ServiceTransferShptHeader."Transfer-from Name" := ServTransHeader."Transfer-from Name";
        ServiceTransferShptHeader."Transfer-from Name 2" := ServTransHeader."Transfer-from Name 2";
        ServiceTransferShptHeader."Transfer-from Address" := ServTransHeader."Transfer-from Address";
        ServiceTransferShptHeader."Transfer-from Address 2" := ServTransHeader."Transfer-from Address 2";
        ServiceTransferShptHeader."Transfer-from Post Code" := ServTransHeader."Transfer-from Post Code";
        ServiceTransferShptHeader."Transfer-from City" := ServTransHeader."Transfer-from City";
        ServiceTransferShptHeader."Transfer-from State" := ServTransHeader."Transfer-from State";
        ServiceTransferShptHeader."Transfer-to Code" := ServTransHeader."Transfer-to Code";
        ServiceTransferShptHeader."Transfer-to Name" := ServTransHeader."Transfer-to Name";
        ServiceTransferShptHeader."Transfer-to Name 2" := ServTransHeader."Transfer-to Name 2";
        ServiceTransferShptHeader."Transfer-to Address" := ServTransHeader."Transfer-to Address";
        ServiceTransferShptHeader."Transfer-to Address 2" := ServTransHeader."Transfer-to Address 2";
        ServiceTransferShptHeader."Transfer-to Post Code" := ServTransHeader."Transfer-to Post Code";
        ServiceTransferShptHeader."Transfer-to City" := ServTransHeader."Transfer-to City";
        ServiceTransferShptHeader."Transfer-to State" := ServTransHeader."Transfer-to State";
        ServiceTransferShptHeader."Shipment Date" := ServTransHeader."Shipment Date";
        ServiceTransferShptHeader."Receipt Date" := ServTransHeader."Receipt Date";
        ServiceTransferShptHeader.Status := Status::Shipped;
        ServiceTransferShptHeader."Shortcut Dimension 1 Code" := ServTransHeader."Shortcut Dimension 1 Code";
        ServiceTransferShptHeader."Shortcut Dimension 2 Code" := ServTransHeader."Shortcut Dimension 2 Code";
        ServiceTransferShptHeader."Ship Control Account" := ServTransHeader."Ship Control Account";
        ServiceTransferShptHeader."Receive Control Account" := ServTransHeader."Receive Control Account";
        ServiceTransferShptHeader."Dimension Set ID" := ServTransHeader."Dimension Set ID";
        ServiceTransferShptHeader."Assigned User ID" := ServTransHeader."Assigned User ID";
        GetServiceShipmentPostingNoSeries(ServTransHeader);
        ServiceTransferShptHeader."No. Series" := ServTransHeader."No. Series";
        ServiceTransferShptHeader."No." := NoSeriesManagement.GetNextNo(
        ServiceTransferShptHeader."No. Series", ServTransHeader."Shipment Date", true);
        ServiceTransferShptHeader.Insert();
        exit(ServiceTransferShptHeader."No.");
    end;

    local procedure InsertServiceTransShptLine()
    var
        ServiceTransferShptLine: Record "Service Transfer Shpt. Line";
        ServiceTransferLine: Record "Service Transfer Line";
    begin
        ServiceTransferLine.SetRange("Document No.", ServiceTransferHeader."No.");
        if ServiceTransferLine.FindSet() then
            repeat
                ServiceTransferShptLine.LockTable();
                ServiceTransferShptLine.Init();
                ServiceTransferShptLine."Document No." := PostedServiceTransferShptDocNo;
                ServiceTransferShptLine."Line No." := ServiceTransferLine."Line No.";
                ServiceTransferShptLine."Transfer From G/L Account No." := ServiceTransferLine."Transfer From G/L Account No.";
                ServiceTransferShptLine."Transfer To G/L Account No." := ServiceTransferLine."Transfer To G/L Account No.";
                ServiceTransferShptLine."Transfer Price" := ServiceTransferLine."Transfer Price";
                ServiceTransferShptLine."Ship Control A/C No." := ServiceTransferLine."Ship Control A/C No.";
                ServiceTransferShptLine."Receive Control A/C No." := ServiceTransferLine."Receive Control A/C No.";
                ServiceTransferShptLine.Shipped := true;
                ServiceTransferShptLine."Shortcut Dimension 1 Code" := ServiceTransferLine."Shortcut Dimension 1 Code";
                ServiceTransferShptLine."Shortcut Dimension 2 Code" := ServiceTransferLine."Shortcut Dimension 2 Code";
                ServiceTransferShptLine.Exempted := ServiceTransferLine.Exempted;
                ServiceTransferShptLine."GST Group Code" := ServiceTransferLine."GST Group Code";
                ServiceTransferShptLine."SAC Code" := ServiceTransferLine."SAC Code";
                ServiceTransferShptLine."GST Rounding Type" := ServiceTransferLine."GST Rounding Type";
                ServiceTransferShptLine."GST Rounding Precision" := ServiceTransferLine."GST Rounding Precision";
                ServiceTransferShptLine."Dimension Set ID" := ServiceTransferLine."Dimension Set ID";
                ServiceTransferShptLine."From G/L Account Description" := ServiceTransferLine."From G/L Account Description";
                ServiceTransferShptLine."To G/L Account Description" := ServiceTransferLine."To G/L Account Description";
                ServiceTransferShptLine.Insert();
                if not ServiceTransferLine.Shipped then begin
                    FillTransferBuffer(ServiceTransferLine, true, ServiceTransferLine."Line No.");
                    FillGSTPostingBuffer(ServiceTransferLine, true);
                end;
            until ServiceTransferLine.Next() = 0;
    end;

    local procedure InsertServiceTransRcptHeader(ServTransHeader: Record "Service Transfer Header"): Code[20]
    var
        ServiceTransferRcptHeader: Record "Service Transfer Rcpt. Header";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        ServiceTransferRcptHeader.LockTable();
        ServiceTransferRcptHeader.Init();
        ServiceTransferRcptHeader."Service Transfer Order No." := ServTransHeader."No.";
        ServiceTransferRcptHeader."Transfer-from Code" := ServTransHeader."Transfer-from Code";
        ServiceTransferRcptHeader."Transfer-from Name" := ServTransHeader."Transfer-from Name";
        ServiceTransferRcptHeader."Transfer-from Name 2" := ServTransHeader."Transfer-from Name 2";
        ServiceTransferRcptHeader."Transfer-from Address" := ServTransHeader."Transfer-from Address";
        ServiceTransferRcptHeader."Transfer-from Address 2" := ServTransHeader."Transfer-from Address 2";
        ServiceTransferRcptHeader."Transfer-from Post Code" := ServTransHeader."Transfer-from Post Code";
        ServiceTransferRcptHeader."Transfer-from City" := ServTransHeader."Transfer-from City";
        ServiceTransferRcptHeader."Transfer-from State" := ServTransHeader."Transfer-from State";
        ServiceTransferRcptHeader."Transfer-to Code" := ServTransHeader."Transfer-to Code";
        ServiceTransferRcptHeader."Transfer-to Name" := ServTransHeader."Transfer-to Name";
        ServiceTransferRcptHeader."Transfer-to Name 2" := ServTransHeader."Transfer-to Name 2";
        ServiceTransferRcptHeader."Transfer-to Address" := ServTransHeader."Transfer-to Address";
        ServiceTransferRcptHeader."Transfer-to Address 2" := ServTransHeader."Transfer-to Address 2";
        ServiceTransferRcptHeader."Transfer-to Post Code" := ServTransHeader."Transfer-to Post Code";
        ServiceTransferRcptHeader."Transfer-to City" := ServTransHeader."Transfer-to City";
        ServiceTransferRcptHeader."Transfer-to State" := ServTransHeader."Transfer-to State";
        ServiceTransferRcptHeader."Shipment Date" := ServTransHeader."Shipment Date";
        ServiceTransferRcptHeader."Receipt Date" := ServTransHeader."Receipt Date";
        ServiceTransferRcptHeader.Status := Status::Shipped;
        ServiceTransferRcptHeader."Shortcut Dimension 1 Code" := ServTransHeader."Shortcut Dimension 1 Code";
        ServiceTransferRcptHeader."Shortcut Dimension 2 Code" := ServTransHeader."Shortcut Dimension 2 Code";
        ServiceTransferRcptHeader."Ship Control Account" := ServTransHeader."Ship Control Account";
        ServiceTransferRcptHeader."Receive Control Account" := ServTransHeader."Receive Control Account";
        ServiceTransferRcptHeader."Dimension Set ID" := ServTransHeader."Dimension Set ID";
        ServiceTransferRcptHeader."Assigned User ID" := ServTransHeader."Assigned User ID";
        ServiceTransferRcptHeader."External Doc No." := ServTransHeader."External Doc No.";
        GetServiceReceiptPostingNoSeries(ServTransHeader);
        ServiceTransferRcptHeader."No. Series" := ServTransHeader."No. Series";
        ServiceTransferRcptHeader."No." := NoSeriesManagement.GetNextNo(
            ServiceTransferRcptHeader."No. Series", ServTransHeader."Receipt Date", true);
        ServiceTransferRcptHeader.Insert();
        exit(ServiceTransferRcptHeader."No.");
    end;

    local procedure InsertServiceTransRcptLine()
    var
        ServiceTransferRcptLine: Record "Service Transfer Rcpt. Line";
        ServiceTransferLine: Record "Service Transfer Line";
    begin
        ServiceTransferLine.SetRange("Document No.", ServiceTransferHeader."No.");
        if ServiceTransferLine.FindSet() then
            repeat
                ServiceTransferRcptLine.LockTable();
                ServiceTransferRcptLine.Init();
                ServiceTransferRcptLine."Document No." := PostedServiceTransferRcptDocNo;
                ServiceTransferRcptLine."Line No." := ServiceTransferLine."Line No.";
                ServiceTransferRcptLine."Transfer From G/L Account No." := ServiceTransferLine."Transfer From G/L Account No.";
                ServiceTransferRcptLine."Transfer To G/L Account No." := ServiceTransferLine."Transfer To G/L Account No.";
                ServiceTransferRcptLine."Transfer Price" := ServiceTransferLine."Transfer Price";
                ServiceTransferRcptLine."Ship Control A/C No." := ServiceTransferLine."Ship Control A/C No.";
                ServiceTransferRcptLine."Receive Control A/C No." := ServiceTransferLine."Receive Control A/C No.";
                ServiceTransferRcptLine.Shipped := true;
                ServiceTransferRcptLine."Shortcut Dimension 1 Code" := ServiceTransferLine."Shortcut Dimension 1 Code";
                ServiceTransferRcptLine."Shortcut Dimension 2 Code" := ServiceTransferLine."Shortcut Dimension 2 Code";
                ServiceTransferRcptLine."GST Rounding Type" := ServiceTransferLine."GST Rounding Type";
                ServiceTransferRcptLine."GST Rounding Precision" := ServiceTransferLine."GST Rounding Precision";
                ServiceTransferRcptLine."GST Group Code" := ServiceTransferLine."GST Group Code";
                ServiceTransferRcptLine."SAC Code" := ServiceTransferLine."SAC Code";
                ServiceTransferRcptLine.Exempted := ServiceTransferLine.Exempted;
                ServiceTransferRcptLine."Dimension Set ID" := ServiceTransferLine."Dimension Set ID";
                ServiceTransferRcptLine."From G/L Account Description" := ServiceTransferLine."From G/L Account Description";
                ServiceTransferRcptLine."To G/L Account Description" := ServiceTransferLine."To G/L Account Description";
                ServiceTransferRcptLine.Insert();
                if ServiceTransferLine.Shipped then begin
                    FillTransferBuffer(ServiceTransferLine, false, ServiceTransferLine."Line No.");
                    FillGSTPostingBuffer(ServiceTransferLine, false);
                end;
            until ServiceTransferLine.Next() = 0;
    end;

    local procedure FillTransferBuffer(
        ServiceTransferLine: Record "Service Transfer Line";
        Ship: Boolean;
        SortingNo: Integer)
    var
        GLAccount: Record "G/L Account";
    begin
        TempTransferBufferStage."System-Created Entry" := true;
        if Ship then begin
            TempTransferBufferStage."G/L Account" := ServiceTransferLine."Transfer From G/L Account No.";
            TempTransferBufferStage.Amount := -ServiceTransferLine."Transfer Price";
            GLAccount.Get(ServiceTransferLine."Transfer From G/L Account No.");
        end else begin
            TempTransferBufferStage."G/L Account" := ServiceTransferLine."Transfer To G/L Account No.";
            TempTransferBufferStage.Amount := ServiceTransferLine."Transfer Price";
            GLAccount.Get(ServiceTransferLine."Transfer To G/L Account No.");
        end;
        TempTransferBufferStage."Global Dimension 1 Code" := ServiceTransferLine."Shortcut Dimension 1 Code";
        TempTransferBufferStage."Global Dimension 2 Code" := ServiceTransferLine."Shortcut Dimension 2 Code";
        TempTransferBufferStage."Dimension Set ID" := ServiceTransferLine."Dimension Set ID";
        TransferAmount += TempTransferBufferStage.Amount;
        UpdTransferBuffer(SortingNo);
    end;

    local procedure UpdTransferBuffer(SortingNo: Decimal)
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimensionManagement.UpdateGlobalDimFromDimSetID(TempTransferBufferStage."Dimension Set ID",
          TempTransferBufferStage."Global Dimension 1 Code", TempTransferBufferStage."Global Dimension 2 Code");
        TempTransferBufferFinal := TempTransferBufferStage;
        if TempTransferBufferFinal.Find() then begin
            TempTransferBufferFinal.Amount := TempTransferBufferFinal.Amount + TempTransferBufferStage.Amount;
            TempTransferBufferFinal.Modify();
        end else begin
            TempTransferBufferFinal."Sorting No." := SortingNo;
            TempTransferBufferFinal.Insert();

        end;
    end;

    local procedure PostTransLineToGenJnlLine(ServiceTransferHeader: Record "service transfer Header"; Ship: Boolean)
    begin
        GenJnlLine.Init();
        if Ship then begin
            GenJnlLine."Document No." := PostedServiceTransferShptDocNo;
            GenJnlLine."Posting Date" := ServiceTransferHeader."Shipment Date";
            GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::Sale
        end else begin
            GenJnlLine."Document No." := PostedServiceTransferRcptDocNo;
            GenJnlLine."Posting Date" := ServiceTransferHeader."Receipt Date";
            GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::Purchase
        end;
        GenJnlLine."Document Date" := GenJnlLine."Posting Date";
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Invoice;
        GenJnlLine."System-Created Entry" := TempTransferBufferFinal."System-Created Entry";
        if ControlAccount then begin
            if Ship then
                GenJnlLine."Account No." := ServiceTransferHeader."Ship Control Account"
            else
                GenJnlLine."Account No." := ServiceTransferHeader."Receive Control Account";
            GenJnlLine.Amount := -(GSTAmount + TransferAmount + InvoiceRoundingAmount);
            GenJnlLine."Shortcut Dimension 1 Code" := ServiceTransferHeader."Shortcut Dimension 1 Code";
            GenJnlLine."Shortcut Dimension 2 Code" := ServiceTransferHeader."Shortcut Dimension 2 Code";
            GenJnlLine."Dimension Set ID" := ServiceTransferHeader."Dimension Set ID";
        end else begin
            GenJnlLine."Account No." := TempTransferBufferFinal."G/L Account";
            GenJnlLine.Amount := TempTransferBufferFinal.Amount;
            GenJnlLine."Shortcut Dimension 1 Code" := TempTransferBufferFinal."Global Dimension 1 Code";
            GenJnlLine."Shortcut Dimension 2 Code" := TempTransferBufferFinal."Global Dimension 2 Code";
            GenJnlLine."Dimension Set ID" := TempTransferBufferFinal."Dimension Set ID";
            GenJnlLine."Gen. Bus. Posting Group" := TempTransferBufferFinal."Gen. Bus. Posting Group";
            GenJnlLine."Gen. Prod. Posting Group" := TempTransferBufferFinal."Gen. Prod. Posting Group";
        end;
        GenJnlLine."VAT Posting" := GenJnlLine."VAT Posting"::"Manual VAT Entry";
        GenJnlLine."VAT Prod. Posting Group" := 'NO VAT';
        GenJnlLine."VAT Bus. Posting Group" := '';
        GenJnlLine."VAT Base Amount" := GenJnlLine.Amount;
        GenJnlLine."Source Code" := SourceCode;
        GenJnlLine.Description := StrSubstNo(ServiceTranTxt, ServiceTransferHeader."No.");
        if GenJnlLine.Amount <> 0 then
            GenJnlPostLine.RunWithCheck(GenJnlLine);
    end;

    local procedure DeleteOneServiceTransferOrder()
    var
        ServiceTransferLine: Record "Service Transfer Line";
        DoNotDelete: Boolean;
        No: Code[20];
    begin
        No := ServiceTransferHeader."No.";
        ServiceTransferLine.SetRange("Document No.", ServiceTransferHeader."No.");
        ServiceTransferLine.SetFilter("Transfer From G/L Account No.", '<>%1', '');
        ServiceTransferLine.SetFilter("Transfer To G/L Account No.", '<>%1', '');
        if ServiceTransferLine.FindSet() then
            repeat
                if not ServiceTransferLine.Shipped then
                    DoNotDelete := true;
            until ServiceTransferLine.Next() = 0;

        if not DoNotDelete then begin
            if ServiceTransferLine.FindSet() then
                ServiceTransferLine.DeleteAll();
            ServiceTransferHeader.Delete();
            Message(ServTransDelMsg, No);
        end;
    end;

    local procedure ClearPostingBuffer(DocNo: Code[20])
    var
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
    begin
        DetailedGSTEntryBuffer.SetCurrentKey("Transaction Type", "Document Type", "Document No.", "Line No.");
        DetailedGSTEntryBuffer.SetRange("Transaction Type", DetailedGSTEntryBuffer."Transaction Type"::"Service Transfer");
        DetailedGSTEntryBuffer.SetRange("Document No.", DocNo);
        DetailedGSTEntryBuffer.DeleteAll(true);
    end;

    local procedure FillDetailLedgBufferServTran(DocNo: Code[20])
    var
        ServiceTransferLine: Record "Service Transfer Line";
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        TaxTransValue: Record "Tax Transaction Value";
        GSTSetup: Record "GST Setup";
        Sign: Integer;
        LastEntryNo: Integer;
        DocumentType: Enum "Document Type Enum";
        TransactionType: Enum "Transaction Type Enum";
    begin
        if not GSTSetup.Get() then
            exit;
        GSTSetup.TestField("GST Tax Type");

        Sign := GetSign(DocumentType::Quote, TransactionType::"Service Transfer");
        if DetailedGSTEntryBuffer.FindLast() then
            LastEntryNo := DetailedGSTEntryBuffer."Entry No." + 1
        else
            LastEntryNo := 1;

        ServiceTransferLine.Reset();
        ServiceTransferLine.SetRange("Document No.", DocNo);
        if ServiceTransferLine.FindSet() then
            repeat
                TaxTransValue.Reset();
                TaxTransValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
                TaxTransValue.SetRange("Tax Record ID", ServiceTransferLine.RecordId);
                TaxTransValue.SetRange("Value Type", TaxTransValue."Value Type"::COMPONENT);
                TaxTransValue.SetFilter(Percent, '<>%1', 0);
                if TaxTransValue.FindSet() then
                    repeat
                        DetailedGSTEntryBuffer.Init();
                        DetailedGSTEntryBuffer."Entry No." := LastEntryNo;
                        DetailedGSTEntryBuffer."Document Type" := DetailedGSTEntryBuffer."Document Type"::Quote;
                        DetailedGSTEntryBuffer."Transaction Type" := DetailedGSTEntryBuffer."Transaction Type"::"Service Transfer";
                        DetailedGSTEntryBuffer."Document No." := ServiceTransferHeader."No.";
                        DetailedGSTEntryBuffer."Posting Date" := ServiceTransferHeader."Shipment Date";
                        DetailedGSTEntryBuffer.Type := DetailedGSTEntryBuffer.Type::"G/L Account";
                        DetailedGSTEntryBuffer."No." := ServiceTransferLine."Transfer From G/L Account No.";
                        DetailedGSTEntryBuffer."Source No." := '';
                        DetailedGSTEntryBuffer."HSN/SAC Code" := ServiceTransferLine."SAC Code";
                        DetailedGSTEntryBuffer."Location Code" := ServiceTransferHeader."Transfer-from Code";
                        DetailedGSTEntryBuffer."Line No." := ServiceTransferLine."Line No.";
                        DetailedGSTEntryBuffer."Source Type" := "Source Type"::" ";
                        DetailedGSTEntryBuffer.Exempted := ServiceTransferLine.Exempted;
                        DetailedGSTEntryBuffer."GST Input/Output Credit Amount" := Sign * TaxTransValue.Amount;
                        DetailedGSTEntryBuffer."GST Base Amount" := Sign * ServiceTransferLine."Transfer Price";
                        DetailedGSTEntryBuffer."GST %" := TaxTransValue.Percent;
                        DetailedGSTEntryBuffer."GST Rounding Precision" := ServiceTransferLine."GST Rounding Precision";
                        DetailedGSTEntryBuffer."GST Rounding Type" := ServiceTransferLine."GST Rounding Type";
                        DetailedGSTEntryBuffer."GST Inv. Rounding Precision" := ServiceTransferHeader."GST Inv. Rounding Precision";
                        DetailedGSTEntryBuffer."GST Inv. Rounding Type" := ServiceTransferHeader."GST Inv. Rounding Type";
                        DetailedGSTEntryBuffer."Currency Factor" := 1;
                        DetailedGSTEntryBuffer."GST Amount" := Sign * TaxTransValue.Amount;
                        DetailedGSTEntryBuffer."GST Input/Output Credit Amount" := Sign * TaxTransValue.Amount;
                        DetailedGSTEntryBuffer."GST Component Code" := GetGSTComponent(TaxTransValue."Value ID");
                        DetailedGSTEntryBuffer."GST Group Code" := ServiceTransferLine."GST Group Code";
                        DetailedGSTEntryBuffer.Insert();
                        LastEntryNo += 1;
                    until TaxTransValue.Next() = 0
            until ServiceTransferLine.Next() = 0;
    end;

    local procedure GetSign(
        DocumentType: Enum "Document Type Enum";
        TransactionType: Enum "Transaction Type Enum") Sign: Integer
    begin
        if DocumentType in [DocumentType::Order, DocumentType::Invoice, DocumentType::Quote, DocumentType::"Blanket Order"] then
            Sign := 1
        else
            Sign := -1;
        if TransactionType = TransactionType::Purchase then
            Sign := Sign * 1
        else
            Sign := Sign * -1;
        exit(Sign);
    end;

    local procedure FillGSTPostingBuffer(ServiceTransferLine: Record "Service Transfer Line"; Ship: Boolean)
    var
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        GLAccount: Record "G/L Account";
        GSTBaseValidation: Codeunit "GST Base Validation";
        GSTStateCode: Code[10];
    begin
        ServiceTransferHeader.TestField("Transfer-from State");
        ServiceTransferHeader.TestField("Transfer-to State");
        if Ship then
            GSTStateCode := ServiceTransferHeader."Transfer-from State"
        else
            GSTStateCode := ServiceTransferHeader."Transfer-to State";
        DetailedGSTEntryBuffer.Reset();
        DetailedGSTEntryBuffer.SetCurrentKey("Transaction Type", "Document Type", "Document No.", "Line No.");
        DetailedGSTEntryBuffer.SetRange("Transaction Type", DetailedGSTEntryBuffer."Transaction Type"::"Service Transfer");
        DetailedGSTEntryBuffer.SetRange("Document Type", 0);
        DetailedGSTEntryBuffer.SetRange("Document No.", ServiceTransferLine."Document No.");
        DetailedGSTEntryBuffer.SetRange("Line No.", ServiceTransferLine."Line No.");
        DetailedGSTEntryBuffer.SetFilter("GST Base Amount", '<>%1', 0);
        if DetailedGSTEntryBuffer.FindSet() then
            repeat
                TempGSTPostingBufferStage.Type := TempGSTPostingBufferStage.Type::"G/L Account";
                TempGSTPostingBufferStage."Global Dimension 1 Code" := ServiceTransferLine."Shortcut Dimension 1 Code";
                TempGSTPostingBufferStage."Global Dimension 2 Code" := ServiceTransferLine."Shortcut Dimension 2 Code";
                TempGSTPostingBufferStage."Dimension Set ID" := ServiceTransferLine."Dimension Set ID";
                TempGSTPostingBufferStage."GST Group Code" := ServiceTransferLine."GST Group Code";
                if Ship then begin
                    TempGSTPostingBufferStage."GST Base Amount" := GSTBaseValidation.RoundGSTPrecision(DetailedGSTEntryBuffer."GST Base Amount");
                    TempGSTPostingBufferStage."GST Amount" := GSTBaseValidation.RoundGSTPrecision(DetailedGSTEntryBuffer."GST Amount");
                    GLAccount.Get(ServiceTransferLine."Transfer From G/L Account No.");
                    TempGSTPostingBufferStage."Gen. Prod. Posting Group" := GLAccount."Gen. Prod. Posting Group";
                    TempGSTPostingBufferStage."Account No." := GetGSTPayableAccountNo(GSTStateCode, DetailedGSTEntryBuffer."GST Component Code");
                end else begin
                    TempGSTPostingBufferStage."GST Base Amount" := -GSTBaseValidation.RoundGSTPrecision(DetailedGSTEntryBuffer."GST Base Amount");
                    TempGSTPostingBufferStage."GST Amount" := -GSTBaseValidation.RoundGSTPrecision(DetailedGSTEntryBuffer."GST Amount");
                    GLAccount.Get(ServiceTransferLine."Transfer To G/L Account No.");
                    TempGSTPostingBufferStage."Gen. Prod. Posting Group" := GLAccount."Gen. Prod. Posting Group";
                    TempGSTPostingBufferStage."Account No." := GetGSTReceivableAccountNo(GSTStateCode, DetailedGSTEntryBuffer."GST Component Code");
                end;
                TempGSTPostingBufferStage."GST %" := DetailedGSTEntryBuffer."GST %";
                TempGSTPostingBufferStage."GST Component Code" := DetailedGSTEntryBuffer."GST Component Code";
                GSTAmount += TempGSTPostingBufferStage."GST Amount";
                UpdateGSTPostingBuffer(DetailedGSTEntryBuffer."Line No.");
            until DetailedGSTEntryBuffer.Next() = 0;
    end;

    local procedure UpdateGSTPostingBuffer(LineNo: Integer)
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimensionManagement.UpdateGlobalDimFromDimSetID(TempGSTPostingBufferStage."Dimension Set ID",
          TempGSTPostingBufferStage."Global Dimension 1 Code", TempGSTPostingBufferStage."Global Dimension 2 Code");
        TempGSTPostingBufferFinal := TempGSTPostingBufferStage;
        if TempGSTPostingBufferFinal.Find() then begin
            TempGSTPostingBufferFinal."GST Base Amount" += TempGSTPostingBufferStage."GST Base Amount";
            TempGSTPostingBufferFinal."GST Amount" += TempGSTPostingBufferStage."GST Amount";
            TempGSTPostingBufferFinal.Modify();
        end else begin
            TempGSTPostingBufferFinal."Document Line No." := LineNo;
            TempGSTPostingBufferFinal.Insert();
        end;
    end;

    local procedure PostTransLineToGenJnlLineGST(ServiceTransferHeader: Record "Service Transfer Header"; Ship: Boolean) DocTransferType: Enum "Service Doc Transfer Type";
    begin
        GenJnlLine.Init();
        GenJnlLine.Description := StrSubstNo(ServiceTranTxt, ServiceTransferHeader."No.");
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Invoice;
        if TempGSTPostingBufferFinal."GST Amount" <> 0 then begin
            GenJnlLine.Validate(Amount, Round(TempGSTPostingBufferFinal."GST Amount"));
            GenJnlLine."Account No." := TempGSTPostingBufferFinal."Account No.";
        end;
        GenJnlLine."VAT Posting" := GenJnlLine."VAT Posting"::"Manual VAT Entry";
        GenJnlLine."System-Created Entry" := TempTransferBufferFinal."System-Created Entry";
        GenJnlLine."Gen. Bus. Posting Group" := TempGSTPostingBufferFinal."Gen. Bus. Posting Group";
        GenJnlLine."Gen. Prod. Posting Group" := TempGSTPostingBufferFinal."Gen. Prod. Posting Group";
        GenJnlLine."Shortcut Dimension 1 Code" := TempGSTPostingBufferFinal."Global Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := TempGSTPostingBufferFinal."Global Dimension 2 Code";
        GenJnlLine."Dimension Set ID" := TempGSTPostingBufferFinal."Dimension Set ID";
        GenJnlLine."Source Code" := SourceCode;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        if Ship then begin
            GenJnlLine."Document No." := PostedServiceTransferShptDocNo;
            GenJnlLine."Location Code" := ServiceTransferHeader."Transfer-from Code";
            GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::Sale;
            GenJnlLine."Posting Date" := ServiceTransferHeader."Shipment Date";
            InsertGSTLedgerEntryServiceTransfer(
              TempGSTPostingBufferFinal, ServiceTransferHeader,
              GenJnlPostLine.GetNextTransactionNo(), Format(GenJnlLine."Document Type"), GenJnlLine."Document No.",
              GenJnlLine."Source Code", DocTransferType::"Service Transfer Shipment");
        end else begin
            GenJnlLine."Location Code" := ServiceTransferHeader."Transfer-to Code";
            GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::Purchase;
            GenJnlLine."Document No." := PostedServiceTransferRcptDocNo;
            GenJnlLine."Posting Date" := ServiceTransferHeader."Receipt Date";
            InsertGSTLedgerEntryServiceTransfer(
               TempGSTPostingBufferFinal, ServiceTransferHeader,
               GenJnlPostLine.GetNextTransactionNo(), Format(GenJnlLine."Document Type"), GenJnlLine."Document No.",
             GenJnlLine."Source Code", DocTransferType::"Service Transfer Receipt");
        end;
        GenJnlPostLine.RunWithCheck(GenJnlLine);
    end;

    local procedure InsertGSTLedgerEntryServiceTransfer(
        GSTPostingBuffer: Record "GST Posting Buffer";
        ServiceTransferHeader: Record "Service Transfer Header";
        NextTransactionNo: Integer;
        DocumentType: Text;
        DocumentNo: Code[20];
        SourceCode: Code[10];
        DocTransferType: Enum "Service Doc Transfer Type")
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
        GSTLedEntryDocType: Enum "Detail GST Document Type";
    begin
        GSTLedgerEntry.Init();
        GSTLedgerEntry."Entry No." := 0;
        GSTLedgerEntry."Gen. Bus. Posting Group" := GSTPostingBuffer."Gen. Bus. Posting Group";
        GSTLedgerEntry."Gen. Prod. Posting Group" := GSTPostingBuffer."Gen. Prod. Posting Group";
        GSTLedgerEntry."Posting Date" := ServiceTransferHeader."Receipt Date";
        GSTLedgerEntry."Document No." := DocumentNo;
        Evaluate(GSTLedEntryDocType, DocumentType);
        GSTLedgerEntry."Document Type" := GSTLedEntryDocType;
        GSTLedgerEntry."GST Base Amount" := GSTPostingBuffer."GST Base Amount";
        GSTLedgerEntry."GST Amount" := GSTPostingBuffer."GST Amount";
        GSTLedgerEntry."Transaction Type" := GSTLedgerEntry."Transaction Type"::Purchase;
        GSTLedgerEntry."External Document No." := ServiceTransferHeader."External Doc No.";
        GSTLedgerEntry."Source Type" := GSTLedgerEntry."Source Type"::VEnDor;
        if DocTransferType = DocTransferType::"Service Transfer Shipment" then begin
            GSTLedgerEntry."Transaction Type" := GSTLedgerEntry."Transaction Type"::Sales;
            GSTLedgerEntry."External Document No." := ServiceTransferHeader."No.";
            GSTLedgerEntry."Posting Date" := ServiceTransferHeader."Shipment Date";
            GSTLedgerEntry."Source Type" := GSTLedgerEntry."Source Type"::Customer
        end;
        GSTLedgerEntry."GST Base Amount" := GSTPostingBuffer."GST Base Amount";
        GSTLedgerEntry."User ID" := CopyStr(UserId, 1, MaxStrLen(GSTLedgerEntry."User ID"));
        GSTLedgerEntry."Source Code" := SourceCode;
        GSTLedgerEntry."Transaction No." := NextTransactionNo;
        GSTLedgerEntry."GST Component Code" := GSTPostingBuffer."GST Component Code";
        GSTLedgerEntry.Insert(true);
    end;

    local procedure InsertDetailedGSTLedgEntryServiceTransfer(
        ServiceTransferLine: Record "Service Transfer Line";
        ServiceTransferHeader: Record "Service Transfer Header";
        DocumentNo: Code[20];
        TransactionNo: Integer;
        DocTransferType: Enum "Service Doc Transfer Type")
    var
        Location: Record Location;
        Location2: Record Location;
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        Location.Get(ServiceTransferHeader."Transfer-from Code");
        Location.TestField("State Code");
        if (Location."GST Registration No." = '') and (Location."Location ARN No." = '') then
            Error(LocationCodeErr);
        Location2.Get(ServiceTransferHeader."Transfer-to Code");
        if (Location2."GST Registration No." = '') and (Location2."Location ARN No." = '') then
            Error(LocationCodeErr);

        DetailedGSTEntryBuffer.SetCurrentKey("Transaction Type", "Document Type", "Document No.", "Line No.");
        DetailedGSTEntryBuffer.SetRange("Transaction Type", DetailedGSTEntryBuffer."Transaction Type"::"Service Transfer");
        DetailedGSTEntryBuffer.SetRange("Document Type", 0);
        DetailedGSTEntryBuffer.SetRange("Document No.", ServiceTransferLine."Document No.");
        DetailedGSTEntryBuffer.SetRange("Line No.", ServiceTransferLine."Line No.");
        if DetailedGSTEntryBuffer.FindSet() then
            repeat
                DetailedGSTLedgerEntry.Init();
                DetailedGSTLedgerEntry."Entry No." := 0;
                DetailedGSTLedgerEntry."Entry Type" := DetailedGSTLedgerEntry."Entry Type"::"Initial Entry";
                DetailedGSTLedgerEntry."Document Type" := DetailedGSTLedgerEntry."Document Type"::Invoice;
                DetailedGSTLedgerEntry."Document No." := DocumentNo;
                DetailedGSTLedgerEntry.Type := Type::"G/L Account";
                DetailedGSTLedgerEntry."GST Jurisdiction Type" := GETGSTJurisdictionType(ServiceTransferHeader);
                DetailedGSTLedgerEntry."GST Group Type" := "GST Group Type"::Service;
                DetailedGSTLedgerEntry."GST Without Payment of Duty" := false;
                DetailedGSTLedgerEntry."GST Component Code" := DetailedGSTEntryBuffer."GST Component Code";
                DetailedGSTLedgerEntry."GST Exempted Goods" := ServiceTransferLine.Exempted;
                if DocTransferType = DocTransferType::"Service Transfer Shipment" then begin
                    DetailedGSTLedgerEntry."G/L Account No." := GetGSTPayableAccountNo(Location."State Code", DetailedGSTEntryBuffer."GST Component Code");
                    DetailedGSTLedgerEntry.Quantity := -1;
                    DetailedGSTLedgerEntry."Location Code" := ServiceTransferHeader."Transfer-from Code";
                    DetailedGSTLedgerEntry."Location  Reg. No." := Location."GST Registration No.";
                    DetailedGSTLedgerEntry."Buyer/Seller Reg. No." := Location2."GST Registration No.";
                    DetailedGSTLedgerEntry."Transaction Type" := DetailedGSTLedgerEntry."Transaction Type"::Sales;
                    DetailedGSTLedgerEntry."No." := ServiceTransferLine."Transfer From G/L Account No.";
                    DetailedGSTLedgerEntry."Posting Date" := ServiceTransferHeader."Shipment Date";
                    DetailedGSTLedgerEntry."External Document No." := ServiceTransferHeader."No.";
                    DetailedGSTLedgerEntry."Source Type" := "Source Type"::Customer;
                    DetailedGSTLedgerEntry."GST Customer Type" := "GST Customer Type"::Registered;
                    DetailedGSTLedgerEntry."Liable to Pay" := true;
                end else begin
                    DetailedGSTLedgerEntry."G/L Account No." := GetGSTReceivableAccountNo(Location2."State Code", DetailedGSTEntryBuffer."GST Component Code");
                    DetailedGSTLedgerEntry.Quantity := 1;
                    DetailedGSTLedgerEntry."Location Code" := ServiceTransferHeader."Transfer-to Code";
                    DetailedGSTLedgerEntry."Location  Reg. No." := Location2."GST Registration No.";
                    DetailedGSTLedgerEntry."Buyer/Seller Reg. No." := Location."GST Registration No.";
                    DetailedGSTLedgerEntry."Transaction Type" := DetailedGSTLedgerEntry."Transaction Type"::Purchase;
                    DetailedGSTLedgerEntry."No." := ServiceTransferLine."Transfer To G/L Account No.";
                    DetailedGSTLedgerEntry."Posting Date" := ServiceTransferHeader."Receipt Date";
                    DetailedGSTLedgerEntry."External Document No." := ServiceTransferHeader."External Doc No.";
                    DetailedGSTLedgerEntry."Source Type" := "Source Type"::VEnDor;
                    DetailedGSTLedgerEntry."GST Vendor Type" := "GST Vendor Type"::Registered;
                    DetailedGSTLedgerEntry."Credit Availed" := true;
                    DetailedGSTLedgerEntry."Eligibility for ITC" := "Eligibility for ITC"::"Input Services";
                end;
                UpdateDetailedGSTLedgerEntryServiceTransfer(
                  DetailedGSTLedgerEntry, ServiceTransferLine."Document No.", ServiceTransferLine."Line No.", TransactionNo, DocTransferType);
                DetailedGSTLedgerEntry.TestField("HSN/SAC Code");
                if ServiceTransferLine.Shipped and
                   (ServiceTransferLine."Transfer To G/L Account No." <> DetailedGSTLedgerEntry."No.")
                then
                    DetailedGSTLedgerEntry."No." := ServiceTransferLine."Transfer To G/L Account No.";
                DetailedGSTLedgerEntry."Skip Tax Engine Trigger" := true;
                DetailedGSTLedgerEntry.Insert(true);

                InsertDetailedGSTLedgerEnfo(DetailedGSTLedgerEntry, ServiceTransferHeader, DetailedGSTEntryBuffer, DocTransferType);
            until DetailedGSTEntryBuffer.Next() = 0;
    end;

    local procedure UpdateDetailedGSTLedgerEntryServiceTransfer(
        var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DocumentNo: Code[20];
        LineNo: Integer;
        TransactionNo: Integer;
        DocTransferType: Enum "Service Doc Transfer Type")
    var
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        GSTBaseValidation: Codeunit "GST Base Validation";
    begin
        DetailedGSTEntryBuffer.SetCurrentKey("Transaction Type", "Document Type", "Document No.", "Line No.");
        DetailedGSTEntryBuffer.SetRange("Transaction Type", DetailedGSTEntryBuffer."Transaction Type"::"Service Transfer");
        DetailedGSTEntryBuffer.SetRange("Document Type", DetailedGSTEntryBuffer."Document Type"::Quote);
        DetailedGSTEntryBuffer.SetRange("Document No.", DocumentNo);
        DetailedGSTEntryBuffer.SetRange("Line No.", LineNo);
        DetailedGSTEntryBuffer.SetRange("GST Component Code", DetailedGSTLedgerEntry."GST Component Code");
        if DetailedGSTEntryBuffer.FindFirst() then begin
            DetailedGSTLedgerEntry.Type := DetailedGSTEntryBuffer.Type;
            DetailedGSTLedgerEntry."No." := DetailedGSTEntryBuffer."No.";
            DetailedGSTLedgerEntry."Product Type" := DetailedGSTEntryBuffer."Product Type";
            DetailedGSTLedgerEntry."Source No." := DetailedGSTEntryBuffer."Source No.";
            DetailedGSTLedgerEntry."HSN/SAC Code" := DetailedGSTEntryBuffer."HSN/SAC Code";
            DetailedGSTLedgerEntry."GST Component Code" := DetailedGSTEntryBuffer."GST Component Code";
            DetailedGSTLedgerEntry."GST Group Code" := DetailedGSTEntryBuffer."GST Group Code";
            DetailedGSTLedgerEntry."Document Line No." := DetailedGSTEntryBuffer."Line No.";
            DetailedGSTLedgerEntry."GST Base Amount" := GSTBaseValidation.RoundGSTPrecision(DetailedGSTEntryBuffer."GST Base Amount");
            DetailedGSTLedgerEntry."GST Amount" := GSTBaseValidation.RoundGSTPrecision(DetailedGSTEntryBuffer."GST Amount");
            DetailedGSTLedgerEntry."GST %" := DetailedGSTEntryBuffer."GST %";
            DetailedGSTLedgerEntry."Remaining Base Amount" := 0;
            DetailedGSTLedgerEntry."Remaining GST Amount" := 0;
            DetailedGSTLedgerEntry."Amount Loaded on Item" := 0;
            DetailedGSTLedgerEntry."GST Credit" := DetailedGSTLedgerEntry."GST Credit"::Availment;
            if DocTransferType = DocTransferType::"Service Transfer Receipt" then
                ReverseDetailedGSTEntryQtyAmt(DetailedGSTLedgerEntry);
            DetailedGSTLedgerEntry."GST Rounding Type" := DetailedGSTEntryBuffer."GST Rounding Type";
            DetailedGSTLedgerEntry."GST Rounding Precision" := DetailedGSTEntryBuffer."GST Rounding Precision";
            DetailedGSTLedgerEntry."GST Inv. Rounding Type" := DetailedGSTEntryBuffer."GST Inv. Rounding Type";
            DetailedGSTLedgerEntry."GST Inv. Rounding Precision" := DetailedGSTEntryBuffer."GST Inv. Rounding Precision";
            DetailedGSTLedgerEntry."Transaction No." := TransactionNo;
        end;
    end;

    local procedure PostGSTInvoiceRounding(ServiceTransferHeader: Record "Service Transfer Header"; Ship: Boolean)
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        InventorySetup.TestField("Service Rounding Account");

        GenJnlLine.Init();
        GenJnlLine.Description := StrSubstNo(ServiceTranTxt, ServiceTransferHeader."No.");
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Invoice;
        GenJnlLine."Source Code" := SourceCode;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine.Validate(Amount, InvoiceRoundingAmount);
        GenJnlLine."Account No." := InventorySetup."Service Rounding Account";
        GenJnlLine."VAT Posting" := GenJnlLine."VAT Posting"::"Manual VAT Entry";
        GenJnlLine."System-Created Entry" := TempTransferBufferStage."System-Created Entry";
        GenJnlLine."Gen. Bus. Posting Group" := TempGSTPostingBufferStage."Gen. Bus. Posting Group";
        GenJnlLine."Gen. Prod. Posting Group" := TempGSTPostingBufferStage."Gen. Prod. Posting Group";
        GenJnlLine."Shortcut Dimension 1 Code" := TempGSTPostingBufferStage."Global Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := TempGSTPostingBufferStage."Global Dimension 2 Code";
        GenJnlLine."Dimension Set ID" := TempGSTPostingBufferStage."Dimension Set ID";
        if Ship then begin
            GenJnlLine."Document No." := PostedServiceTransferShptDocNo;
            GenJnlLine."Location Code" := ServiceTransferHeader."Transfer-from Code";
            GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::Sale;
            GenJnlLine."Posting Date" := ServiceTransferHeader."Shipment Date";
        end else begin
            GenJnlLine."Location Code" := ServiceTransferHeader."Transfer-to Code";
            GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::Purchase;
            GenJnlLine."Document No." := PostedServiceTransferRcptDocNo;
            GenJnlLine."Posting Date" := ServiceTransferHeader."Receipt Date";
        end;
        GenJnlPostLine.RunWithCheck(GenJnlLine);
    end;

    local procedure ReverseDetailedGSTEntryQtyAmt(var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry")
    begin
        DetailedGSTLedgerEntry."GST Base Amount" := -DetailedGSTLedgerEntry."GST Base Amount";
        DetailedGSTLedgerEntry."GST Amount" := -DetailedGSTLedgerEntry."GST Amount";
        DetailedGSTLedgerEntry."Amount Loaded on Item" := -DetailedGSTLedgerEntry."Amount Loaded on Item";
    end;

    local procedure GetGSTComponent(ComponentID: Integer): Code[30]
    var
        GSTSetup: Record "GST Setup";
        TaxComponent: Record "Tax Component";
    begin
        if not GSTSetup.Get() then
            exit;
        GSTSetup.TestField("GST Tax Type");
        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxComponent.SetRange(Id, ComponentID);
        if TaxComponent.FindFirst() then
            exit(TaxComponent.Name);
    end;

    local procedure GETGSTJurisdictionType(ServiceTransferHeader: Record "Service Transfer Header"): Enum "GST Jurisdiction Type"
    var
        GSTJurisdictionType: Enum "GST Jurisdiction Type";
    begin
        if ServiceTransferHeader."Transfer-from State" <> ServiceTransferHeader."Transfer-to State" then
            exit(GSTJurisdictionType::Interstate)
        else
            exit(GSTJurisdictionType::Intrastate);
    end;

    local procedure GetGSTPayableAccountNo(LocationCode: Code[10]; GSTComponentCode: Code[30]): Code[20]
    var
        GSTPostingSetup: Record "GST Posting Setup";
    begin
        GSTPostingSetup.Reset();
        GSTPostingSetup.SetRange("State Code", LocationCode);
        GSTPostingSetup.SetRange("Component ID", GSTComponentID(GSTComponentCode));
        GSTPostingSetup.FindFirst();
        exit(GSTPostingSetup."Payable Account")
    end;

    local procedure GetGSTReceivableAccountNo(LocationCode: Code[10]; GSTComponentCode: Code[30]): Code[20]
    var
        GSTPostingSetup: Record "GST Posting Setup";
    begin
        GSTPostingSetup.Reset();
        GSTPostingSetup.SetRange("State Code", LocationCode);
        GSTPostingSetup.SetRange("Component ID", GSTComponentID(GSTComponentCode));
        GSTPostingSetup.FindFirst();
        exit(GSTPostingSetup."Receivable Account")
    end;

    local procedure GSTComponentID(ComponentCode: Code[30]): Integer
    var
        GSTSetup: Record "GST Setup";
        TaxComponent: Record "Tax Component";
    begin
        if not GSTSetup.Get() then
            exit;
        GSTSetup.TestField("GST Tax Type");

        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxComponent.SetRange(Name, ComponentCode);
        if TaxComponent.FindFirst() then
            exit(TaxComponent.Id)
    end;

    //Find No. Series
    local procedure GetServiceReceiptPostingNoSeries(var ServiceTransferHeader: Record "Service Transfer Header")
    var
        PostingNoSeries: Record "Posting No. Series";
        InventorySetup: Record "Inventory Setup";
        Location: Record Location;
        NoSeriesCode: Code[20];
    begin
        PostingNoSeries.SetRange("Table Id", Database::"Service Transfer Header");
        NoSeriesCode := LoopPostingNoSeries(
            PostingNoSeries,
            ServiceTransferHeader,
            PostingNoSeries."Document Type"::"Service Transfer Receipt");
        if NoSeriesCode <> '' then
            ServiceTransferHeader."No. Series" := NoSeriesCode
        else begin
            InventorySetup.Get();
            if InventorySetup."Posted Serv. Trans. Rcpt. Nos." = '' then
                Error(NoSeriesErr, InventorySetup.FieldCaption("Posted Serv. Trans. Rcpt. Nos."),
                  Location.TableCaption, InventorySetup.TableCaption);
            ServiceTransferHeader."No. Series" := InventorySetup."Posted Serv. Trans. Rcpt. Nos.";
        end;
    end;

    local procedure GetServiceShipmentPostingNoSeries(var ServiceTransferHeader: Record "Service Transfer Header")
    var
        PostingNoSeries: Record "Posting No. Series";
        InventorySetup: Record "Inventory Setup";
        Location: Record Location;
        NoSeriesCode: Code[20];
    begin
        PostingNoSeries.SetRange("Table Id", Database::"Service Transfer Header");
        NoSeriesCode := LoopPostingNoSeries(
            PostingNoSeries,
            ServiceTransferHeader,
            PostingNoSeries."Document Type"::"Service Transfer Shipment");
        if NoSeriesCode <> '' then
            ServiceTransferHeader."No. Series" := NoSeriesCode
        else begin
            InventorySetup.Get();
            if InventorySetup."Posted Serv. Trans. Shpt. Nos." = '' then
                Error(NoSeriesErr, InventorySetup.FieldCaption("Posted Transfer Shpt. Nos."),
                  Location.TableCaption, InventorySetup.TableCaption);
            ServiceTransferHeader."No. Series" := InventorySetup."Posted Serv. Trans. Shpt. Nos.";
        end;
    end;

    local procedure LoopPostingNoSeries(
        var PostingNoSeries: Record "Posting No. Series";
        Record: Variant;
        PostingDocumentType: Enum "Posting Document Type"): Code[20]
    var
        Filters: Text;
    begin
        PostingNoSeries.SetRange("Document Type", PostingDocumentType);
        if PostingNoSeries.FindSet() then
            repeat
                Filters := GetRecordView(PostingNoSeries);
                if RecordViewFound(Record, Filters) then begin
                    PostingNoSeries.TestField("Posting No. Series");
                    exit(PostingNoSeries."Posting No. Series");
                end;
            until PostingNoSeries.Next() = 0;
    end;

    local procedure RecordViewFound(Record: Variant; Filters: Text) Found: Boolean;
    var
        Field: Record Field;
        DuplicateRecRef: RecordRef;
        TempRecRef: RecordRef;
        FieldRef: FieldRef;
        TempFieldRef: FieldRef;
    begin
        DuplicateRecRef.GetTable(Record);
        Clear(TempRecRef);
        TempRecRef.Open(DuplicateRecRef.Number(), true);
        Field.SetRange(TableNo, DuplicateRecRef.Number());
        if Field.FindSet() then
            repeat
                FieldRef := DuplicateRecRef.Field(Field."No.");
                TempFieldRef := TempRecRef.Field(Field."No.");
                TempFieldRef.Value := FieldRef.Value();
            until Field.Next() = 0;

        TempRecRef.Insert();
        Found := true;
        if Filters = '' then
            exit;

        TempRecRef.SetView(Filters);
        Found := TempRecRef.Find();
    end;

    local procedure GetRecordView(var PostingNoSeries: Record "Posting No. Series") Filters: Text;
    var
        ConditionInStream: InStream;
    begin
        PostingNoSeries.CalcFields(Condition);
        PostingNoSeries.Condition.CREATEINSTREAM(ConditionInStream);
        ConditionInStream.Read(Filters);
    end;

    //GST Posting No. Series Table
    [EventSubscriber(ObjectType::Table, Database::"Posting No. Series", 'OnBeforeRun', '', false, false)]
    local procedure ValidatePostingSeriesDocumentType(var PostingNoSeries: Record "Posting No. Series"; var IsHandled: Boolean)
    begin
        case PostingNoSeries."Document Type" of
            PostingNoSeries."Document Type"::"Service Transfer Shipment":
                begin
                    PostingNoSeries."Table Id" := Database::"Service Transfer Header";
                    IsHandled := true;
                end;
            PostingNoSeries."Document Type"::"Service Transfer Receipt":
                begin
                    PostingNoSeries."Table Id" := Database::"Service Transfer Header";
                    IsHandled := true;
                end;
        end;
    end;

    procedure PreviewDocument(var ServiceTransferHeader: Record "Service Transfer Header" temporary)
    var
        ServiceTransferPost: Codeunit "Service Transfer Post";
        GSTPreviewHandler: Codeunit "GST Preview Handler";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePreviewDocument(ServiceTransferHeader, IsHandled);
        if IsHandled then
            exit;

        GSTPreviewHandler.ClearBuffers();
        GenJnlPostPreview.Preview(ServiceTransferPost, ServiceTransferHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnRunPreview', '', false, false)]
    local procedure OnRunPreviewForServiceTransfer(var Result: Boolean; Subscriber: Variant; RecVar: Variant)
    var
        RecRef: RecordRef;
    begin
        if not RecVar.IsRecord() then
            exit;

        RecRef.GetTable(RecVar);
        if RecRef.Number() <> Database::"Service Transfer Header" then
            exit;

        RunServiceTransferPreview(Result, Subscriber, RecVar);
    end;

    local procedure RunServiceTransferPreview(var Result: Boolean; Subscriber: Variant; RecVar: Variant)
    var
        ServiceTransferPost: Codeunit "Service Transfer Post";
    begin
        ServiceTransferPost := Subscriber;
        ServiceTransferPost.SetPreviewMode(true);
        Result := ServiceTransferPost.Run(RecVar);
    end;

    procedure SetPreviewMode(NewPreviewMode: Boolean)
    begin
        PreviewMode := NewPreviewMode;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePreviewDocument(var ServiceTransferHeader: Record "Service Transfer Header"; var IsHandled: Boolean)
    begin
    end;
}
