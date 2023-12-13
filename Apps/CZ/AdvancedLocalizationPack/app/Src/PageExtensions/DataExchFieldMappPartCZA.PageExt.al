// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.IO;

pageextension 31243 "Data Exch Field Mapp. Part CZA" extends "Data Exch Field Mapping Part"
{
    layout
    {
        addlast(Group)
        {
            field("Date Formula_CZA"; Rec."Date Formula CZA")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Date formula for calculating the resulting date';
            }
        }
    }
}
