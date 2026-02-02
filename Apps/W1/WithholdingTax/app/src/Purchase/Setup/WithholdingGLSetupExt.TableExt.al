// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Finance.GeneralLedger.Setup;
using System.Utilities;

tableextension 6790 "Withholding GL Setup Ext" extends "General Ledger Setup"
{
    fields
    {
        field(6784; "Enable Withholding Tax"; Boolean)
        {
            Caption = 'Enable Withholding Tax';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if Rec."Enable Withholding Tax" then
                    if not ConfirmManagement.GetResponseOrDefault(ConfirmEnableWithholdingTaxQst, false) then
                        Error('');
            end;
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

    var
        ConfirmManagement: Codeunit "Confirm Management";
        ConfirmEnableWithholdingTaxQst: Label 'Withholding Tax feature is currently in preview. We strongly recommend that you first enable and test this feature on a sandbox environment that has a copy of production data before doing this on a production environment.\\Are you sure you want to enable this feature?';
}