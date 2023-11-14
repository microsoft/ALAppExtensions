// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.Currency;

table 11742 "Currency Nominal Value CZP"
{
    Caption = 'Currency Nominal Value';
    LookupPageID = "Currency Nominal Values CZP";

    fields
    {
        field(1; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(2; "Nominal Value"; Decimal)
        {
            BlankZero = true;
            Caption = 'Value';
            DecimalPlaces = 0 : 2;
            NotBlank = true;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Currency Code", "Nominal Value")
        {
            Clustered = true;
        }
    }
}
