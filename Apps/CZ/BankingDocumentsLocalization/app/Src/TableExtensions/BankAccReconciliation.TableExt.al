// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.Reconciliation;

tableextension 31288 "Bank Acc. Reconciliation CZB" extends "Bank Acc. Reconciliation"
{
    fields
    {
        field(11707; "Created From Bank Stat. CZB"; Boolean)
        {
            Caption = 'Created From Bank Statement';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}
