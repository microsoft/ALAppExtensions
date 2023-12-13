// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Location;

using Microsoft.Bank.BankAccount;

tableextension 11794 "Responsibility Center CZL" extends "Responsibility Center"
{
    fields
    {
        field(11720; "Default Bank Account Code CZL"; Code[20])
        {
            Caption = 'Default Bank Account Code';
            TableRelation = "Bank Account" where("Currency Code" = const(''));
            DataClassification = CustomerContent;
        }
    }
}
