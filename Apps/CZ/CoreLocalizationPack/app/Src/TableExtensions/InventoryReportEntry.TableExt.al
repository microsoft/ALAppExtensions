// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Reconciliation;

tableextension 31027 "Inventory Report Entry CZL" extends "Inventory Report Entry"
{
    fields
    {
        field(11764; "Inv. Rounding Adj. CZL"; Decimal)
        {
            Caption = 'Inv. Rounding Adj.';
            DataClassification = CustomerContent;
        }
        field(11765; "Consumption CZL"; Decimal)
        {
            Caption = 'Consumption';
            DataClassification = CustomerContent;
        }
        field(11766; "Change In Inv.Of WIP CZL"; Decimal)
        {
            Caption = 'Change In Inv.Of WIP';
            DataClassification = CustomerContent;
        }
        field(11767; "Change In Inv.Of Product CZL"; Decimal)
        {
            Caption = 'Change In Inv.Of Product';
            DataClassification = CustomerContent;
        }
    }
}
