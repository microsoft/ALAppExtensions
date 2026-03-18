// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

using Microsoft.FixedAssets.Ledger;

tableextension 7416 "Excise FA Ledger Entry Ext" extends "FA Ledger Entry"
{
    fields
    {
        field(7412; "Excise Tax Posted"; Boolean)
        {
            Caption = 'Excise Tax Posted';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}