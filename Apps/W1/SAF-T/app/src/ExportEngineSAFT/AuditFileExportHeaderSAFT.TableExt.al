// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

tableextension 5284 "Audit File Export Header SAF-T" extends "Audit File Export Header"
{
    fields
    {
        field(5280; "Export Currency Information"; Boolean)
        {
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(5281; "Number of G/L Entries"; Integer)
        {
            Caption = 'Number of G/L Entries';
            DataClassification = CustomerContent;
        }
        field(5282; "Total G/L Entry Debit"; Decimal)
        {
            Caption = 'Total G/L Entry Debit';
            DataClassification = CustomerContent;
        }
        field(5283; "Total G/L Entry Credit"; Decimal)
        {
            Caption = 'Total G/L Entry Credit';
            DataClassification = CustomerContent;
        }
    }
}
