namespace Microsoft.SubscriptionBilling;

using System.Security.AccessControl;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.Dimension;

table 8072 "Vendor Contract Deferral"

{
    Caption = 'Vendor Contract Deferral';
    DataClassification = CustomerContent;
    DrillDownPageId = "Vendor Contract Deferrals";
    LookupPageId = "Vendor Contract Deferrals";
    Access = Internal;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "Vendor Contract"."No.";
        }
        field(3; "Document Type"; Enum "Rec. Billing Document Type")
        {
            Caption = 'Document Type';
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(5; "Contract Type"; Code[10])
        {
            Caption = 'Contract Type';
            TableRelation = "Contract Type".Code;
        }
        field(6; "Released"; Boolean)
        {
            Caption = 'Released';
        }
        field(7; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(8; Amount; Decimal)
        {
            Caption = 'Amount';
            AutoFormatType = 1;
        }
        field(9; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(10; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(13; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            AutoFormatType = 1;
        }
        field(14; "Deferral Base Amount"; Decimal)
        {
            Caption = 'Deferral Base Amount';
            AutoFormatType = 1;
        }
        field(15; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            DecimalPlaces = 0 : 5;
        }
        field(16; "Pay-to Vendor No."; Code[20])
        {
            Caption = 'Pay-to Vendor No.';
            TableRelation = Vendor;
        }
        field(17; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
        }
        field(18; "Document Posting Date"; Date)
        {
            Caption = 'Document Posting Date';
            Editable = false;
        }
        field(19; "Release Posting Date"; Date)
        {
            Caption = 'Release Posting Date';
        }
        field(20; "G/L Entry No."; Integer)
        {
            Caption = 'General Ledger Entry No.';
            TableRelation = "G/L Entry";
        }
        field(21; "Number of Days"; Integer)
        {
            Caption = 'Number of Days';
        }
        field(22; "Contract Line No."; Integer)
        {
            Caption = 'Contract Line No.';
            TableRelation = "Vendor Contract Line"."Line No.";
        }
        field(23; "Service Object Description"; Text[100])
        {
            Caption = 'Service Object Description';
        }
        field(24; "Service Commitment Description"; Text[100])
        {
            Caption = 'Service Commitment Description';
        }
        field(25; Discount; Boolean)
        {
            Caption = 'Discount';
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
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
        key(SK1; "Contract No.")
        {
        }
    }
    internal procedure InitFromPurchaseLine(PurchaseLine: Record "Purchase Line"; var Sign: Integer)
    begin
        case PurchaseLine."Document Type" of
            Enum::"Purchase Document Type"::"Credit Memo":
                begin
                    "Document Type" := "Document Type"::"Credit Memo";
                    Sign := -1;
                end;
            Enum::"Purchase Document Type"::Invoice:
                begin
                    "Document Type" := "Document Type"::Invoice;
                    Sign := 1;
                end;
        end;
        if (PurchaseLine.Quantity < 0) and (not PurchaseLine."Discount") then
            Sign := Sign * -1;
        Rec."Vendor No." := PurchaseLine."Pay-to Vendor No.";
        Rec."Dimension Set ID" := PurchaseLine."Dimension Set ID";
        Rec."Discount %" := PurchaseLine."Line Discount %";
        Rec."Document Line No." := PurchaseLine."Line No.";
        Rec."Pay-to Vendor No." := PurchaseLine."Pay-to Vendor No.";
        Rec.Discount := PurchaseLine."Discount";
    end;

    internal procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
        DimTextLbl: Label '%1 %2', Locked = true;
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", CopyStr(StrSubstNo(DimTextLbl, TableCaption, "Entry No."), 1, 250));
    end;

    internal procedure FilterOnDocumentTypeAndDocumentNo(RecurringBillingDocumentType: Enum "Rec. Billing Document Type"; DocumentNo: Code[20])
    begin
        Rec.SetRange("Document Type", RecurringBillingDocumentType);
        Rec.SetRange("Document No.", DocumentNo);
    end;
}