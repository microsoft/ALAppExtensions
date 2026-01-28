// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Finance.GeneralLedger.Ledger;

tableextension 6795 "Withholding G/L Register Ext" extends "G/L Register"
{
    fields
    {
        field(6784; "From Withholding Tax Entry No."; Integer)
        {
            Caption = 'From Withholding Tax Entry No.';
            TableRelation = "Withholding Tax Entry";
            DataClassification = CustomerContent;
        }
        field(6785; "To Withholding Tax Entry No."; Integer)
        {
            Caption = 'To Withholding Tax Entry No.';
            TableRelation = "Withholding Tax Entry";
            DataClassification = CustomerContent;
        }
    }
}