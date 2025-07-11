// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Reconcilation;

using Microsoft.Finance.TaxBase;

table 18284 "Posted GST Reconciliation"
{
    Caption = 'Posted GST Reconciliation';

    fields
    {
        field(1; "GSTIN No."; Code[20])
        {
            Caption = 'GSTIN No.';
            DataClassification = CustomerContent;
        }
        field(2; "State Code"; Code[10])
        {
            Caption = 'State Code';
            TableRelation = State;
            DataClassification = CustomerContent;
        }
        field(3; "Reconciliation Month"; Integer)
        {
            Caption = 'Reconciliation Month';
            DataClassification = CustomerContent;
        }
        field(4; "Reconciliation Year"; Integer)
        {
            Caption = 'Reconciliation Year';
            DataClassification = CustomerContent;
        }
        field(5; "GST Component"; Code[30])
        {
            Caption = 'GST Component';
            DataClassification = CustomerContent;
        }
        field(6; "GST Amount"; Decimal)
        {
            Caption = 'GST Amount';
            DataClassification = CustomerContent;
        }
        field(7; "GST Prev. Period B/F Amount"; Decimal)
        {
            Caption = 'GST Prev. Period B/F Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(8; "GST Amount Utilized"; Decimal)
        {
            Caption = 'GST Amount Utilized';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "GST Prev. Period C/F Amount"; Decimal)
        {
            Caption = 'GST Prev. Period C/F Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Source Type"; Enum "GSTReco Source Type")
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Payment Posted (Sales)"; Boolean)
        {
            Caption = 'Payment Posted (Sales)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Payment Posted (Sales Export)"; Boolean)
        {
            Caption = 'Payment Posted (Sales Export)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "Payment Posted (Adv-Rev)"; Boolean)
        {
            Caption = 'Payment Posted (Adv-Rev)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14; "Payment Posted (Invoice-Rev)"; Boolean)
        {
            Caption = 'Payment Posted (Invoice-Rev)';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "GSTIN No.", "State Code", "Reconciliation Month", "Reconciliation Year", "GST Component")
        {
            Clustered = true;
        }
        key(Key2; "GSTIN No.", "Reconciliation Month", "Reconciliation Year", "Source Type")
        {
        }
        key(Key3; "GSTIN No.", "Reconciliation Year", "GST Component", "Source Type")
        {
        }
        key(Key4; "GSTIN No.", "State Code", "GST Component", "Reconciliation Year", "Reconciliation Month")
        {
        }
    }
}
