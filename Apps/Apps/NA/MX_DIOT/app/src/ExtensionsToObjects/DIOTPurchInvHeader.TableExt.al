// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.History;

tableextension 27034 "DIOT Purch. Inv. Header" extends "Purch. Inv. Header"
{
    fields
    {
        field(27030; "DIOT Type of Operation"; Enum "DIOT Type of Operation")
        {
            Caption = 'DIOT Type of Operation';
            DataClassification = CustomerContent;
        }
    }
}
