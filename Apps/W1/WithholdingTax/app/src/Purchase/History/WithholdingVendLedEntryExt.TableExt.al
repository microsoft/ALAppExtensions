// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Purchases.Payables;

tableextension 6792 "Withholding Vend Led Entry Ext" extends "Vendor Ledger Entry"
{
    fields
    {
        field(6784; "Rem. Amt for Withholding Tax"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Rem. Amt for Withholding Tax';
            DataClassification = CustomerContent;
        }
        field(6785; "WHT Rem. Amt"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Rem. Amt';
            DataClassification = CustomerContent;
        }
        field(6786; "Withholding Tax Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = '';
            CalcFormula = sum("Withholding Tax Entry".Amount where("Bill-to/Pay-to No." = field("Vendor No."),
                                                        "Original Document No." = field("Document No.")));
            Caption = 'Withholding Tax Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6787; "Withholding Tax Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = '';
            CalcFormula = sum("Withholding Tax Entry"."Amount (LCY)" where("Bill-to/Pay-to No." = field("Vendor No."),
                                                                "Original Document No." = field("Document No.")));
            Caption = 'Withholding Tax Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
    }
}