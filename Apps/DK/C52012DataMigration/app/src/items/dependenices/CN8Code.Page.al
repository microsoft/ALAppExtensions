// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page  1864 "C5 CN8Code"
{
    PageType = Card;
    SourceTable = "C5 CN8Code";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Item CN8 Codes';
    layout
    {
        area(content)
        {
            group(General)
            {
                field(CN8Code;CN8Code) { ApplicationArea=All; }
                field(Txt;Txt) { ApplicationArea=All; }
                field(SupplementaryUnits;SupplementaryUnits) { ApplicationArea=All; }
            }
        }
    }    
}