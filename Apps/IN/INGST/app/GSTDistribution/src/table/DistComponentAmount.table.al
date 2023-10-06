// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GST.Base;
using Microsoft.Inventory.Location;

table 18201 "Dist. Component Amount"
{
    Caption = 'Dist. Component Amount';

    fields
    {
        field(1; "Distribution No."; Code[20])
        {
            Caption = 'Distribution No.';
            DataClassification = CustomerContent;
        }
        field(2; "GST Component Code"; Code[30])
        {
            Caption = 'GST Component Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(3; "GST Base Amount"; Decimal)
        {
            Caption = 'GST Base Amount';
            DataClassification = CustomerContent;
        }
        field(4; "GST Amount"; Decimal)
        {
            Caption = 'GST Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "GST Registration No."; Code[20])
        {
            Caption = 'GST Registration No.';
            DataClassification = CustomerContent;
        }
        field(6; "To Location Code"; Code[10])
        {
            Caption = 'To Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location where("GST Input Service Distributor" = filter(false));
        }
        field(7; "Distribution %"; Decimal)
        {
            Caption = 'Distribution %';
            DataClassification = CustomerContent;
        }
        field(8; "GST Credit"; enum "GST Credit")
        {
            Caption = 'GST Credit';
            DataClassification = CustomerContent;
        }
        field(9; Type; Enum Type)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(10; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = if (Type = const("G/L Account")) "G/L Account"
                where(
                    "Direct Posting" = const(false),
                    "Account Type" = const(Posting),
                    Blocked = const(false));
        }
        field(11; "Debit Amount"; Decimal)
        {
            Caption = 'Debit Amount';
            DataClassification = CustomerContent;
        }
        field(12; "Credit Amount"; Decimal)
        {
            Caption = 'Credit Amount';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Distribution No.", "GST Component Code", "To Location Code", "GST Credit", Type, "No.")
        {
            Clustered = true;
        }
    }
}
