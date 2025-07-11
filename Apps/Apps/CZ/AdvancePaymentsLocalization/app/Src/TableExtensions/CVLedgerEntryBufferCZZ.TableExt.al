// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.ReceivablesPayables;

tableextension 31006 "CV Ledger Entry Buffer CZZ" extends "CV Ledger Entry Buffer"
{
    fields
    {
        field(31010; "Advance Letter No. CZZ"; Code[20])
        {
            Caption = 'Advance Letter No.';
            DataClassification = CustomerContent;
        }
    }
}
