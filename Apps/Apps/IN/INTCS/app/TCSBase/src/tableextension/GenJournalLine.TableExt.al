// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TCS.TCSBase;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using System.Utilities;

tableextension 18808 "Gen. Journal Line" extends "Gen. Journal Line"
{
    fields
    {
        field(18807; "TCS Nature of Collection"; Code[10])
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                TCSNatureOfCollection: Record "TCS Nature Of Collection";
            begin
                TestField("TDS Section Code", '');
                TestField("TDS Certificate Receivable", false);

                if "Document Type" <> "Document Type"::Payment then
                    if TCSNatureOfCollection.Get("TCS Nature of Collection") and (TCSNatureOfCollection."TCS On Recpt. Of Pmt.") then
                        Error(TCSRecptPmtDocTypeErr, "Journal Template Name", "Journal Batch Name", "Line No.");

                "TCS on Recpt. Of Pmt. Amount" := 0;
            end;
        }
        field(18808; "Pay TCS"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(18809; "T.C.A.N. No."; Code[10])
        {
            TableRelation = "T.C.A.N. No.";
            DataClassification = CustomerContent;
        }
        field(18810; "Excl. GST in TCS Base"; Boolean)
        {
            Caption = 'Exclude GST in TCS Base';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not ("Document Type" in ["Document Type"::Invoice, "Document Type"::"Credit Memo"]) then
                    error(ExcludeGSTDocTypeErr);
            end;
        }
        modify("TDS Section Code")
        {
            trigger OnAfterValidate()
            begin
                TestField("TCS Nature of Collection", '');
            end;
        }
        modify("TDS Certificate Receivable")
        {
            trigger OnAfterValidate()
            begin
                if "TDS Certificate Receivable" then
                    TestField("TCS Nature of Collection", '');
            end;
        }
        field(18811; "TCS On Recpt. Of Pmt. Amount"; Decimal)
        {
            Caption = 'TCS On Recpt. Of Pmt. Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TCSNatureOfCollection: Record "TCS Nature Of Collection";
                SalesLineBufferTCSOnPmt: Record "Sales Line Buffer TCS On Pmt.";
            begin
                TestField("Document Type", "Document Type"::Payment);
                TestField("Bal. Account No.");
                TCSNatureOfCollection.Get("TCS Nature of Collection");
                if not TCSNatureOfCollection."TCS on Recpt. Of Pmt." then
                    Error(TCSRecptPmtErr);

                if Abs("TCS on Recpt. Of Pmt. Amount") > Abs(Amount) then
                    Error(TCSPayAmtErr);

                if "TCS on Recpt. Of Pmt. Amount" < 0 then
                    Error(TCSPayAmtNegErr);

                SalesLineBufferTCSOnPmt.SetRange("Payment Transaction No.", "Document No.");
                SalesLineBufferTCSOnPmt.SetRange("User ID", UserId);
                SalesLineBufferTCSOnPmt.DeleteAll();
            end;
        }
    }

    var
        TCSRecptPmtDocTypeErr: Label 'You are not allowed to select this Nature of Collection in Gen. Journal Line. Journal Template Name=%1, Journal Batch Name=%2 Line No=%3 with Document Type as Invoice.',
            Comment = '%1 = Journal Template Name, %2 = Journal Batch Name, %3 = Line No.';
        ConfirmMessageMsg: label 'NOC Type %1 is not attached with Customer No. %2, Do you want to assign to customer & Continue ?', Comment = '%1= Noc Type, %2=Customer No..';
        ExcludeGSTDocTypeErr: Label 'Exclude GST in TCS Base is allowed only for Document Type Invoice and Credit Memo.';
        TCSPayAmtErr: Label 'TCS on Recpt. Of Pmt. amount should not be greater than Amount.';
        TCSPayAmtNegErr: Label ' TCS on Recpt. Of Pmt. amount should not be less than 0.';
        TCSRecptPmtErr: Label 'The TCS on Recpt. Of Pmt. field should be true for entering amount in this field.';

    procedure AllowedNOCLookup(var GenJournalLine: Record "Gen. Journal Line"; CustomerNo: Code[20])
    var
        AllowedNOC: Record "Allowed Noc";
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        TCSNatureOfCollections: Page "TCS Nature Of Collections";
    begin
        if "Account Type" = "Account Type"::Customer then begin
            TCSNatureOfCollection.reset();
            AllowedNoc.Reset();
            AllowedNoc.SetRange("Customer No.", CustomerNo);
            if AllowedNoc.findset() then
                repeat
                    TCSNatureOfCollection.SetRange(Code, AllowedNoc."TCS Nature of Collection");
                    if "Document Type" <> "Document Type"::Payment then
                        TCSNatureOfCollection.SetRange("TCS on Recpt. Of Pmt.", false);

                    if TCSNatureOfCollection.FindFirst() then
                        TCSNatureOfCollection.mark(true);
                until AllowedNoc.Next() = 0;

            TCSNatureOfCollection.SetRange(code);
            TCSNatureOfCollection.MarkedOnly(true);
            TCSNatureOfCollections.SetTableView(TCSNatureOfCollection);
            TCSNatureOfCollections.LookupMode(true);
            TCSNatureOfCollections.Editable(false);
            if TCSNatureOfCollections.RunModal() = Action::LookupOK then begin
                TCSNatureOfCollections.GetRecord(TCSNatureOfCollection);
                CheckDefaultandAssignNOC(GenJournalLine, TCSNatureOfCollection.Code);
            end;
        end;
    end;

    procedure GetOpenPostedLinesForTCSOnPaymentCalculation(var GenJournalLine: Record "Gen. Journal Line")
    var
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesLineBuferTCSOnPmt: Record "Sales Line Buffer TCS On Pmt.";
        TaxBaseSubscribers: Codeunit "Tax Base Subscribers";
        GSTBaseAmount: Decimal;
        GSTAmount: Decimal;
    begin
        TestField("Document Type", "Document Type"::Payment);
        TestField("TCS Nature of Collection");
        TCSNatureOfCollection.Get("TCS Nature of Collection");
        TCSNatureOfCollection.TestField("TCS On Recpt. Of Pmt.");

        CustLedgerEntry.SetCurrentKey("Customer No.", Open, Positive, "Due Date");
        CustLedgerEntry.SetRange("Customer No.", "Account No.");
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        GSTBaseAmount := 0;
        GSTAmount := 0;
        if CustLedgerEntry.FindSet() then
            repeat
                SalesInvoiceLine.SetRange("Document No.", CustLedgerEntry."Document No.");
                SalesInvoiceLine.SetRange("TCS Nature of Collection", '');
                if SalesInvoiceLine.FindSet() then
                    repeat
                        if not SalesLineBuferTCSOnPmt.Get("Document No.", "Line No.", SalesInvoiceLine."Document No.", SalesInvoiceLine."Line No.", USERID) then begin
                            SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.");
                            SalesLineBuferTCSOnPmt.Init();
                            SalesLineBuferTCSOnPmt."Payment Transaction No." := "Document No.";
                            SalesLineBuferTCSOnPmt."Payment Transaction Line No." := "Line No.";
                            SalesLineBuferTCSOnPmt."Customer No." := CustLedgerEntry."Customer No.";
                            SalesLineBuferTCSOnPmt."Posted Invoice No." := SalesInvoiceLine."Document No.";
                            SalesLineBuferTCSOnPmt."Invoice Line No." := SalesInvoiceLine."Line No.";
                            SalesLineBuferTCSOnPmt."User ID" := CopyStr(UserId(), 1, 50);
                            SalesLineBuferTCSOnPmt.Type := SalesInvoiceLine.Type;
                            SalesLineBuferTCSOnPmt."No." := SalesInvoiceLine."No.";
                            SalesLineBuferTCSOnPmt.Description := SalesInvoiceLine.Description;
                            SalesLineBuferTCSOnPmt."Description 2" := SalesInvoiceLine."Description 2";
                            SalesLineBuferTCSOnPmt."Location Code" := SalesInvoiceLine."Location Code";
                            SalesLineBuferTCSOnPmt."Unit of Measure Code" := SalesInvoiceLine."Unit of Measure code";
                            SalesLineBuferTCSOnPmt.Quantity := SalesInvoiceLine.Quantity;
                            SalesLineBuferTCSOnPmt."Unit Price" := SalesInvoiceLine."Unit Price";
                            SalesLineBuferTCSOnPmt."Line Amount" := SalesInvoiceLine."Line Amount";
                            SalesLineBuferTCSOnPmt."Line Discount Amount" := SalesInvoiceLine."Line Discount Amount";
                            SalesLineBuferTCSOnPmt."Inv. Discount Amount" := SalesInvoiceLine."Inv. Discount Amount";
                            SalesLineBuferTCSOnPmt."TCS Nature of Collection" := SalesInvoiceLine."TCS Nature of Collection";
                            TaxBaseSubscribers.GetGSTAmountForSalesInvLines(SalesInvoiceLine, GSTBaseAmount, GSTAmount);
                            SalesLineBuferTCSOnPmt."GST Base Amount" := Abs(GSTBaseAmount);
                            SalesLineBuferTCSOnPmt."Total GST Amount" := Abs(GSTAmount);
                            SalesLineBuferTCSOnPmt.Amount := SalesInvoiceLine."Amount" + SalesLineBuferTCSOnPmt."Total GST Amount";
                            SalesLineBuferTCSOnPmt."Posting Date" := SalesInvoiceHeader."Posting Date";
                            SalesLineBuferTCSOnPmt."Source Code" := CustLedgerEntry."Source Code";
                            SalesLineBuferTCSOnPmt.Insert();
                        end;
                    until SalesInvoiceLine.Next() = 0;
            until CustLedgerEntry.Next() = 0;
        Commit();

        SalesLineBuferTCSOnPmt.SetRange("Payment Transaction No.", "Document No.");
        SalesLineBuferTCSOnPmt.SetRange("User ID", UserId);
        if Page.RunModal(Page::"Sales Line Buffer TCS On Pmt.", SalesLineBuferTCSOnPmt) = Action::LookupOK then begin
            SalesLineBuferTCSOnPmt.SetRange(Select, true);
            SalesLineBuferTCSOnPmt.CalcSums(Amount);

            if Abs(SalesLineBuferTCSOnPmt.Amount) > Abs(Amount) then
                Error(TCSPayAmtErr);

            GenJournalLine."TCS on Recpt. Of Pmt. Amount" := SalesLineBuferTCSOnPmt.Amount;

            SalesLineBuferTCSOnPmt.SetRange("Payment Transaction No.", "Document No.");
            SalesLineBuferTCSOnPmt.SetRange("User ID", UserId);
            SalesLineBuferTCSOnPmt.DeleteAll();
        end;
    end;

    procedure CheckTCSOnRecptOfPmtAmount()
    begin
        if "Document Type" <> "Document Type"::Payment then
            exit;

        if "TCS Nature of Collection" = '' then
            exit;

        if Abs("TCS on Recpt. Of Pmt. Amount") > Abs(Amount) then
            Error(TCSPayAmtErr);
    end;

    local procedure CheckDefaultandAssignNOC(var GenJournalLine: Record "Gen. Journal Line"; NocType: code[10])
    var
        AllowedNOC: Record "Allowed Noc";
    begin
        AllowedNOC.Reset();
        AllowedNOC.SetRange("Customer No.", GenJournalLine."Account No.");
        AllowedNOC.SetRange("TCS Nature of Collection", NocType);
        if AllowedNOC.findfirst() then
            GenJournalLine.Validate("TCS Nature of Collection", AllowedNOC."TCS Nature of Collection")
        else
            ConfirmAssignNOC(GenJournalLine, NocType);
    end;

    local procedure ConfirmAssignNOC(var GenJournalLine: Record "Gen. Journal Line"; NocType: code[10])
    var
        AllowedNOC: Record "Allowed NOC";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if ConfirmManagement.GetResponseOrDefault
        (strSubstNo(ConfirmMessageMsg, NocType, GenJournalLine."Account No."), true)
        then begin
            AllowedNOC.init();
            AllowedNOC."TCS Nature of Collection" := NocType;
            AllowedNOC."Customer No." := GenJournalLine."Account No.";
            AllowedNOC.insert();
            GenJournalLine.Validate("TCS Nature of Collection", NocType);
        end;
    end;
}
