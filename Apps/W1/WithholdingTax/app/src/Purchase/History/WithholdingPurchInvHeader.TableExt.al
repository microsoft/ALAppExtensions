// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Purchases.History;

tableextension 6798 "Withholding Purch. Inv. Header" extends "Purch. Inv. Header"
{
    fields
    {
        field(6784; "Wthldg. Tax Bus. Post. Group"; Code[20])
        {
            Caption = 'Withholding Tax Bus. Post. Group';
            TableRelation = "Wthldg. Tax Bus. Post. Group";
            DataClassification = CustomerContent;
        }
        field(6790; "Rem. Wthldg. Tax Pre. Amt(LCY)"; Decimal)
        {
            CalcFormula = sum("Withholding Tax Entry"."Remaining Unrealized Amount" where("Document Type" = const(Invoice),
                                                                                          "Document No." = field("No.")));
            Caption = 'Rem. Withholding Tax Prepaid Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6791; "Paid Wthldg. Tax Pre. Amt(LCY)"; Decimal)
        {
            CalcFormula = sum("Withholding Tax Entry".Amount where("Document Type" = const(Payment),
                                                                   "Document No." = field("No.")));
            Caption = 'Paid Withholding Tax Prepaid Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6792; "Tot. Wthldg. Tax Pre. Amt(LCY)"; Decimal)
        {
            CalcFormula = sum("Withholding Tax Entry"."Unrealized Amount" where("Document Type" = const(Invoice),
                                                                                "Document No." = field("No.")));
            Caption = 'Total Withholding Tax Prepaid Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6793; "WHT Actual Vendor No."; Code[20])
        {
            Caption = 'Actual Vendor No.';
            DataClassification = CustomerContent;
        }
        field(6794; "WHT Printed Tax Document"; Boolean)
        {
            Caption = 'Printed Tax Document';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6795; "WHT Posted Tax Document"; Boolean)
        {
            Caption = 'Posted Tax Document';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6796; "Wthldg. Tax Date Filter"; Date)
        {
            Caption = 'Tax Date Filter';
            FieldClass = FlowFilter;
        }
        field(6797; "Wthldg. Tax Document Marked"; Boolean)
        {
            Caption = 'Tax Document Marked';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6798; "WHT Invoice Print Type"; Option)
        {
            Caption = 'Invoice Print Type';
            Editable = false;
            DataClassification = CustomerContent;
            OptionCaption = 'Invoice,Tax Invoice (Items),Tax Invoice (Services)';
            OptionMembers = Invoice,"Tax Invoice (Items)","Tax Invoice (Services)";
        }
    }
}