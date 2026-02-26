// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Bank.Check;

tableextension 6797 "WHT Check Ledg. Entry Ext" extends "Check Ledger Entry"
{
    fields
    {
        field(6784; "Withholding Tax Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec.GetCurrencyCodeFromBank();
            Caption = 'Withholding Tax Amount';
            DataClassification = CustomerContent;
        }
        field(6785; "WHT PDC Check No."; Code[20])
        {
            Caption = 'PDC Check No.';
            DataClassification = CustomerContent;
        }
        field(6786; "WHT Interest Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec.GetCurrencyCodeFromBank();
            Caption = 'Interest Amount';
            DataClassification = CustomerContent;
        }
    }
}