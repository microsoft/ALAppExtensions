// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

using Microsoft.Sales.Document;

tableextension 4863 "AutoAcc Sales Line" extends "Sales Line"
{
    fields
    {

        field(4850; "Automatic Account Group"; Code[10])
        {
            Caption = 'Automatic Account Group';
            TableRelation = "Automatic Account Header";
        }

    }
}
