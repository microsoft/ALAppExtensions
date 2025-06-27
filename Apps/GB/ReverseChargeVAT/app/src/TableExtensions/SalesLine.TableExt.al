// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Sales.Document;

tableextension 10563 "Sales Line" extends "Sales Line"
{
    fields
    {
        field(10507; "Reverse Charge Item GB"; Boolean)
        {
            Caption = 'Reverse Charge Item';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(10508; "Reverse Charge GB"; Decimal)
        {
            Caption = 'Reverse Charge';
            DataClassification = CustomerContent;
        }
    }

    var
        ReverseChargeApplies: Boolean;

    procedure SetReverseChargeAppliesGB()
    begin
        ReverseChargeApplies := true;
    end;

    procedure GetReverseChargeApplies(): Boolean
    begin
        exit(ReverseChargeApplies);
    end;
}