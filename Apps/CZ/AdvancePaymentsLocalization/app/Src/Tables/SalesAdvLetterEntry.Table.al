// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Enums;
using Microsoft.Foundation.Reporting;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using System.Security.AccessControl;

table 31006 "Sales Adv. Letter Entry CZZ"
{
    Caption = 'Sales Adv. Letter Entry';
    DataClassification = CustomerContent;
    LookupPageId = "Sales Adv. Letter Entries CZZ";
    DrillDownPageId = "Sales Adv. Letter Entries CZZ";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Sales Adv. Letter No."; Code[20])
        {
            Caption = 'Sales Adv. Letter No.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Adv. Letter Header CZZ";
        }
        field(10; "Entry Type"; Enum "Advance Letter Entry Type CZZ")
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
        }
        field(13; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(15; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(16; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";
        }
        field(17; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DataClassification = CustomerContent;
        }
        field(18; "VAT Identifier"; Code[20])
        {
            Caption = 'VAT Identifier';
            DataClassification = CustomerContent;
        }
        field(19; "VAT Calculation Type"; Enum "Tax Calculation Type")
        {
            Caption = 'VAT Calculation Type';
            DataClassification = CustomerContent;
        }
        field(25; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(26; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 15;
            MinValue = 0;
        }
        field(28; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(30; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(33; "VAT Date"; Date)
        {
            Caption = 'VAT Date';
            DataClassification = CustomerContent;
        }
        field(35; "VAT Entry No."; Integer)
        {
            Caption = 'VAT Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "VAT Entry";
        }
        field(38; "Cust. Ledger Entry No."; Integer)
        {
            Caption = 'Cust. Ledger Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "Cust. Ledger Entry";
        }
        field(39; "Det. Cust. Ledger Entry No."; Integer)
        {
            Caption = 'Detailed Cust. Ledger Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "Detailed Cust. Ledg. Entry";
        }
        field(40; "VAT Base Amount"; Decimal)
        {
            Caption = 'VAT Base Amount';
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
        }
        field(41; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
        }
        field(42; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
        }
        field(45; "VAT Base Amount (LCY)"; Decimal)
        {
            Caption = 'VAT Base Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(46; "VAT Amount (LCY)"; Decimal)
        {
            Caption = 'VAT Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(47; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(50; Cancelled; Boolean)
        {
            Caption = 'Cancelled';
            DataClassification = CustomerContent;
        }
        field(55; "Related Entry"; Integer)
        {
            Caption = 'Related Entry';
            DataClassification = CustomerContent;
            TableRelation = "Sales Adv. Letter Entry CZZ";
        }
        field(60; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(61; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(70; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
            Editable = false;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Sales Adv. Letter No.", "Entry Type")
        {
        }
        key(Key3; "Related Entry")
        {
        }
        key(Key4; "Document No.", "Posting Date", Cancelled)
        {
        }
        key(Key5; "Posting Date")
        {
        }
        key(Key6; "Det. Cust. Ledger Entry No.")
        {
        }
    }

    procedure ShowDimensions()
    var
        DimensionManagement: Codeunit DimensionManagement;
        DimensionSetCaptionTok: Label '%1 %2', Locked = true;
    begin
        DimensionManagement.ShowDimensionSet("Dimension Set ID", StrSubstNo(DimensionSetCaptionTok, TableCaption, "Entry No."));
    end;

    procedure PrintRecords(ShowRequestPage: Boolean)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        DummyReportSelections: Record "Report Selections";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePrintRecords(DummyReportSelections, Rec, ShowRequestPage, IsHandled);
        if not IsHandled then
            DocumentSendingProfile.TrySendToPrinter(
              DummyReportSelections.Usage::"Sales Advance VAT Document CZZ".AsInteger(), Rec, FieldNo("Customer No."), ShowRequestPage);
    end;

    procedure EmailRecords(ShowDialog: Boolean)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        DummyReportSelections: Record "Report Selections";
        ReportDistributionManagement: Codeunit "Report Distribution Management";
        DocumentTypeTxt: Text[50];
        IsHandled: Boolean;
    begin
        DocumentTypeTxt := ReportDistributionManagement.GetFullDocumentTypeText(Rec);

        IsHandled := false;
        OnBeforeEmailRecords(DummyReportSelections, Rec, DocumentTypeTxt, ShowDialog, IsHandled);
        if not IsHandled then
            DocumentSendingProfile.TrySendToEMail(
              DummyReportSelections.Usage::"Sales Advance VAT Document CZZ".AsInteger(), Rec, FieldNo("Document No."), DocumentTypeTxt, FieldNo("Customer No."), ShowDialog);
    end;

    procedure CalcUsageVATAmountLines(var SalesInvoiceHeader: Record "Sales Invoice Header"; var VATAmountLine: Record "VAT Amount Line")
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
    begin
        SalesAdvLetterEntryCZZ.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if SalesAdvLetterEntryCZZ.FindSet() then
            repeat
                VATAmountLine.Init();
                VATAmountLine."VAT Identifier" := SalesAdvLetterEntryCZZ."VAT Identifier";
                VATAmountLine."VAT Calculation Type" := SalesAdvLetterEntryCZZ."VAT Calculation Type";
                VATAmountLine."VAT %" := SalesAdvLetterEntryCZZ."VAT %";
                VATAmountLine."VAT Base" := -SalesAdvLetterEntryCZZ."VAT Base Amount";
                VATAmountLine."VAT Amount" := -SalesAdvLetterEntryCZZ."VAT Amount";
                VATAmountLine."Amount Including VAT" := -SalesAdvLetterEntryCZZ.Amount;
                VATAmountLine."VAT Base (LCY) CZL" := -SalesAdvLetterEntryCZZ."VAT Base Amount (LCY)";
                VATAmountLine."VAT Amount (LCY) CZL" := -SalesAdvLetterEntryCZZ."VAT Amount (LCY)";
                if SalesInvoiceHeader."Prices Including VAT" then
                    VATAmountLine."Line Amount" := VATAmountLine."Amount Including VAT"
                else
                    VATAmountLine."Line Amount" := VATAmountLine."VAT Base";
                VATAmountLine.InsertLine();
            until SalesAdvLetterEntryCZZ.Next() = 0;
    end;

    procedure CalcDocumentAmount(): Decimal
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
    begin
        SalesAdvLetterEntryCZZ.SetRange("Document No.", "Document No.");
        SalesAdvLetterEntryCZZ.CalcSums(Amount);
        exit(SalesAdvLetterEntryCZZ.Amount)
    end;

    internal procedure GetCustomerNo(): Code[20]
    var
        SalesAdvLetterHeader: Record "Sales Adv. Letter Header CZZ";
    begin
        SalesAdvLetterHeader.Get("Sales Adv. Letter No.");
        exit(SalesAdvLetterHeader."Bill-to Customer No.");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintRecords(var ReportSelections: Record "Report Selections"; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; ShowRequestPage: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEmailRecords(var ReportSelections: Record "Report Selections"; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; DocTxt: Text; ShowDialog: Boolean; var IsHandled: Boolean)
    begin
    end;
}
