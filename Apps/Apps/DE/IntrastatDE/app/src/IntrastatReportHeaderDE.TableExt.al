// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

tableextension 11030 "Intrastat Report Header DE" extends "Intrastat Report Header"
{
    fields
    {
        field(11029; "Test Submission"; Boolean)
        {
            Caption = 'Test Submission';
        }
    }
}
