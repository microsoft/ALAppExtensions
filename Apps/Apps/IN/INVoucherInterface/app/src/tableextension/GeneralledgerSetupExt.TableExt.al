// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Setup;

tableextension 18933 "General ledger Setup Ext" extends "General Ledger Setup"
{
    fields
    {
        field(18929; "Activate Cheque No."; Boolean)
        {
            Caption = 'Activate Cheque No.';
        }
    }
}
