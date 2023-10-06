// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 10020 "IRS 1096 Form Line Relation"
{
    Caption = 'IRS 1096 Form Line Relation';

    fields
    {
        field(1; "Form No."; Code[20])
        {
            Caption = 'Form No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
    }

    keys
    {
        key(PK; "Form No.", "Line No.", "Entry No.")
        {
            Clustered = true;
        }
    }
}

