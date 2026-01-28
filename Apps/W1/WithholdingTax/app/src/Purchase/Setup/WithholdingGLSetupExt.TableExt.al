// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Finance.GeneralLedger.Setup;

tableextension 6790 "Withholding GL Setup Ext" extends "General Ledger Setup"
{
    fields
    {
        field(6784; "Enable Withholding Tax"; Boolean)
        {
            Caption = 'Enable Withholding Tax';
            DataClassification = CustomerContent;
        }
        field(6785; "Manual Sales Wthldg. Tax Calc."; Boolean)
        {
            Caption = 'Manual Sales Withholding Tax Calc.';
            DataClassification = CustomerContent;
        }
        field(6786; "WHT Enable Tax Invoices"; Boolean)
        {
            Caption = 'Enable Tax Invoices';
            DataClassification = CustomerContent;
        }
        field(6787; "WHT Print Tax Inv. on Posting"; Boolean)
        {
            Caption = 'Print Tax Invoices on Posting';
            DataClassification = CustomerContent;
        }
        field(6788; "Round Amount Wthldg. Tax Calc"; Boolean)
        {
            Caption = 'Round Amount Withholding Tax Calc';
            DataClassification = CustomerContent;
        }
        field(6789; "Min. Wthldg. Tax Calc Inv. Amt"; Boolean)
        {
            Caption = 'Min. Withholding Tax Calc only on Inv. Amt';
            DataClassification = CustomerContent;
        }
    }
}