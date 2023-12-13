// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

table 31098 "Acc. Sched. Expr. Buffer CZL"
{
    Caption = 'Acc. Sched. Expression Buffer';
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; Expression; Text[250])
        {
            Caption = 'Expression';
            DataClassification = SystemMetadata;
        }
        field(3; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = SystemMetadata;
        }
        field(4; "Acc. Sched. Row No."; Code[20])
        {
            Caption = 'Acc. Sched. Row No.';
            DataClassification = SystemMetadata;
        }
        field(5; "Totaling Type"; Enum "Acc. Schedule Line Totaling Type")
        {
            Caption = 'Totaling Type';
            DataClassification = SystemMetadata;
        }
        field(6; "Dimension 1 Totaling"; Text[250])
        {
            Caption = 'Dimension 1 Totaling';
            DataClassification = SystemMetadata;
        }
        field(7; "Dimension 2 Totaling"; Text[250])
        {
            Caption = 'Dimension 2 Totaling';
            DataClassification = SystemMetadata;
        }
        field(8; "Dimension 3 Totaling"; Text[250])
        {
            Caption = 'Dimension 3 Totaling';
            DataClassification = SystemMetadata;
        }
        field(9; "Dimension 4 Totaling"; Text[250])
        {
            Caption = 'Dimension 4 Totaling';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }
}
