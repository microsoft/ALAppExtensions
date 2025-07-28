// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Table Shopify Payout (ID 30125).
/// </summary>
table 30125 "Shpfy Payout"
{
    Caption = 'Shopify Payout';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; BigInteger)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
        }
        field(2; Status; Enum "Shpfy Payout Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(3; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(4; Currency; Code[10])
        {
            Caption = 'Currency';
            DataClassification = CustomerContent;
        }
        field(5; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = Currency;
        }
        field(6; "Adjustments Fee Amount"; Decimal)
        {
            Caption = 'Adjustments Fee Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = Currency;
        }
        field(7; "Adjustments Gross Amount"; Decimal)
        {
            Caption = 'Adjustments Gross Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = Currency;
        }
        field(8; "Charges Fee Amount"; Decimal)
        {
            Caption = 'Charges Fee Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = Currency;
        }
        field(9; "Charges Gross Amount"; Decimal)
        {
            Caption = 'Charges Gross Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = Currency;
        }
        field(10; "Refunds Fee Amount"; Decimal)
        {
            Caption = 'Refunds Fee Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = Currency;
        }
        field(11; "Refunds Gross Amount"; Decimal)
        {
            Caption = 'Refunds Gross Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = Currency;
        }
        field(12; "Reserved Funds Fee Amount"; Decimal)
        {
            Caption = 'Reserved Funds Fee Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = Currency;
        }
        field(13; "Reserved Funds Gross Amount"; Decimal)
        {
            Caption = 'Reserved Funds Gross Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = Currency;
        }
        field(14; "Retried Payouts Fee Amount"; Decimal)
        {
            Caption = 'Retried Payouts Fee Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = Currency;
        }
        field(15; "Retried Payouts Gross Amount"; Decimal)
        {
            Caption = 'Retried Payouts Gross Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = Currency;
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
        key(Key1; Date)
        {
        }
    }

}
