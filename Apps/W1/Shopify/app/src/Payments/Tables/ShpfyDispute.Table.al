// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Table Shopify Payout (ID 30125).
/// </summary>
/// 
table 30155 "Shpfy Dispute"
{
    Access = Internal;
    Caption = 'Shopify Dispute';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; BigInteger)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
        }
        field(2; "Source Order Id"; BigInteger)
        {
            BlankZero = true;
            Caption = 'Source Order Id';
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Order Header";
        }
        field(3; Type; Enum "Shpfy Dispute Type")
        {
            Caption = 'Type';
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
        field(6; "Reason"; Enum "Shpfy Dispute Reason")
        {
            Caption = 'Shopify Dispute Reason';
            DataClassification = CustomerContent;
        }
        field(7; "Network Reason Code"; Text[100])
        {
            Caption = 'Network Reason Code';
            DataClassification = CustomerContent;
        }
        field(8; "Status"; Enum "Shpfy Dispute Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(9; "Evidence Due By"; DateTime)
        {
            Caption = 'Evidence Due By';
            DataClassification = CustomerContent;
        }
        field(10; "Evidence Sent On"; DateTime)
        {
            Caption = 'Evidence Sent On';
            DataClassification = CustomerContent;
        }
        field(11; "Finalized On"; DateTime)
        {
            Caption = 'Finalized On';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }
}