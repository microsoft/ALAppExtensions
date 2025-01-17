// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Currency;

table 31116 "Enhanced Currency Buffer CZL"
{
    Caption = 'Enhanced Currency Buffer';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(2; "Total Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Total Amount';
        }
        field(3; "Total Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Total Amount (LCY)';
        }
        field(4; Counter; Integer)
        {
            Caption = 'Counter';
        }
        field(5; "Total Credit Amount"; Decimal)
        {
            Caption = 'Total Credit Amount';
        }
        field(6; "Total Debit Amount"; Decimal)
        {
            Caption = 'Total Debit Amount';
        }
    }

    keys
    {
        key(Key1; "Currency Code")
        {
            Clustered = true;
        }
    }
}
