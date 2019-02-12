// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13616 GeneralLedgerSetup extends "General Ledger Setup"
{
    fields
    {
        field(13652; "FIK Import Format"; code[20])
        {
            Caption = 'FIK Import Format';
            TableRelation = "Data Exch. Def" WHERE (Type = CONST ("Bank Statement Import"));
        }
    }
}