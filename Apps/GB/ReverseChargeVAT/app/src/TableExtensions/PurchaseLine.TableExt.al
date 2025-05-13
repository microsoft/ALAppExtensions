// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Purchases.Document;

tableextension 10556 "Purchase Line" extends "Purchase Line"
{
    fields
    {
        field(10507; "Reverse Charge Item GB"; Boolean)
        {
            Caption = 'Reverse Charge Item';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}