// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

pageextension 10791 "Intrastat Report Setup ES" extends "Intrastat Report Setup"
{
    layout
    {
        addafter("Zip Files")
        {
            field("Max. No. of Lines in File"; Rec."Max. No. of Lines in File")
            {
                ApplicationArea = All;
                MaxValue = 10000;
            }
        }
    }
}