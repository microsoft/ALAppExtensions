// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

using Microsoft.Finance.ReceivablesPayables;

tableextension 4854 "AutoAcc Invoice Posting Buffer" extends "Invoice Posting Buffer"
{
    fields
    {
        field(4850; "Automatic Account Group"; Code[10])
        {
            Caption = 'Automatic Account Group';
            DataClassification = SystemMetadata;
            TableRelation = "Automatic Account Header";
        }
    }
}
