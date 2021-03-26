// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 1868 "C5 InvenPriceGroup"
{
    PageType = Card;
    SourceTable = "C5 InvenPriceGroup";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Inventory Price Groups';
    layout
    {
        area(content)
        {
            group(General)
            {
                field(Group;Group) { ApplicationArea=All; }
                field(GroupName;GroupName) { ApplicationArea=All; }
                field(InclVat;InclVat) { ApplicationArea=All; }
                field(Roundoff1;Roundoff1) { ApplicationArea=All; }
                field(Roundoff10;Roundoff10) { ApplicationArea=All; }
                field(Roundoff100;Roundoff100) { ApplicationArea=All; }
                field(Roundoff1000;Roundoff1000) { ApplicationArea=All; }
                field(Roundoff1000Plus;Roundoff1000Plus) { ApplicationArea=All; }
            }
        }
    }    
}