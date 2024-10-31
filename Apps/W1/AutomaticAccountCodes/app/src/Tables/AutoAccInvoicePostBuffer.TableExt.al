// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

using Microsoft.Finance.ReceivablesPayables;

tableextension 4853 "AutoAcc. Invoice Post. Buffer" extends "Invoice Post. Buffer"
{
    fields
    {
        field(4850; "Automatic Account Group"; Code[10])
        {
            Caption = 'Automatic Account Group';
            DataClassification = SystemMetadata;
            TableRelation = "Automatic Account Header";
            ObsoleteReason = 'This table will be replaced by table Invoice Posting Buffer in new Invoice Posting implementation.';
            ObsoleteState = Removed;
            ObsoleteTag = '26.0';
        }
    }
}
