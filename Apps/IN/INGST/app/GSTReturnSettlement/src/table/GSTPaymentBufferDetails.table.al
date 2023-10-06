// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

using Microsoft.Finance.GST.Base;

table 18322 "GST Payment Buffer Details"
{
    fields
    {
        field(1; "GST Registration No."; Code[20])
        {
            Caption = 'GST Registration No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "GST Registration Nos.";
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "GST Component Code"; Code[30])
        {
            Caption = 'GST Component Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(7; "Payment Liability"; Decimal)
        {
            Caption = 'Payment Liability';
            DataClassification = CustomerContent;
            Editable = false;
            MinValue = 0;
        }
        field(10; "Net Payment Liability"; Decimal)
        {
            Caption = 'Net Payment Liability';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "Total Credit Available"; Decimal)
        {
            Caption = 'Total Credit Available';
            DataClassification = CustomerContent;
            Editable = false;
            MinValue = 0;
        }
        field(14; "Credit Utilized"; Decimal)
        {
            Caption = 'Credit Utilized';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(15; "Payment Amount"; Decimal)
        {
            Caption = 'Payment Amount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(27; "Surplus Credit"; Decimal)
        {
            Caption = 'Surplus Credit';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(28; "Surplus Cr. Utilized"; Decimal)
        {
            Caption = 'Surplus Cr. Utilized';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(29; "Carry Forward"; Decimal)
        {
            Caption = 'Carry Forward';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(30; "SetOff Component Code"; Code[30])
        {
            Caption = 'SetOff Component Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "GST Registration No.", "Document No.", "GST Component Code", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

