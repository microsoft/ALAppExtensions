// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;
using Microsoft.Bank.Payment;

tableextension 10836 "Vendor Bank Account" extends "Vendor Bank Account"
{
    fields
    {
        field(10805; "Agency Code FR"; Text[5])
        {
            Caption = 'Agency Code';
            InitValue = '00000';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if StrLen("Agency Code FR") < 5 then
                    "Agency Code FR" := PadStr('', 5 - StrLen("Agency Code FR"), '0') + "Agency Code FR";
                "RIB Checked FR" := RIBKeyFR.Check("Bank Branch No.", "Agency Code FR", "Bank Account No.", "RIB Key FR");
            end;
        }
        field(10806; "RIB Key FR"; Integer)
        {
            Caption = 'RIB Key';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "RIB Checked FR" := RIBKeyFR.Check("Bank Branch No.", "Agency Code FR", "Bank Account No.", "RIB Key FR");
            end;
        }
        field(10807; "RIB Checked FR"; Boolean)
        {
            Caption = 'RIB Checked';
            Editable = false;
            DataClassification = CustomerContent;
        }
        modify("Bank Branch No.")
        {
            trigger OnBeforeValidate()
            begin
                "RIB Checked FR" := RIBKeyFR.Check("Bank Branch No.", "Agency Code FR", "Bank Account No.", "RIB Key FR");
            end;
        }
        modify("Bank Account No.")
        {
            trigger OnBeforeValidate()
            begin
                "RIB Checked FR" := RIBKeyFR.Check("Bank Branch No.", "Agency Code FR", "Bank Account No.", "RIB Key FR");
            end;
        }
    }

    var
        RIBKeyFR: Codeunit "RIB Key FR";
}