// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Bank.BankAccount;

tableextension 5283 "Audit File Export Setup SAF-T" extends "Audit File Export Setup"
{
    fields
    {
        field(5280; "SAF-T Modification"; Enum "SAF-T Modification") { }
        field(5281; "Dimension No."; Integer) { }
        field(5282; "Not Applicable VAT Code"; Code[9]) { }
        field(5283; "Default Payment Method Code"; Code[10])
        {
            TableRelation = "Payment Method";
        }
    }
}
