// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 1867 "C5 InvenItemGroup"
{
    PageType = Card;
    SourceTable = "C5 InvenItemGroup";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Item Groups';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Group;Group) { ApplicationArea=All; }
                field(GroupName;GroupName) { ApplicationArea=All; }
                field(SalesAcc;SalesAcc) { ApplicationArea=All; }
                field(COGSAcc;COGSAcc) { ApplicationArea=All; }
                field(SalesDiscAcc;SalesDiscAcc) { ApplicationArea=All; }
                field(InventoryInflowAcc;InventoryInflowAcc) { ApplicationArea=All; }
                field(InventoryOutflowAcc;InventoryOutflowAcc) { ApplicationArea=All; }
                field(LossAcc;LossAcc) { ApplicationArea=All; }
                field(ProfitAcc;ProfitAcc) { ApplicationArea=All; }
                field(InterimInflowOffset;InterimInflowOffset) { ApplicationArea=All; }
                field(InterimOutflowOffset;InterimOutflowOffset) { ApplicationArea=All; }
                field(ProfitMarginPct;ProfitMarginPct) { ApplicationArea=All; }
                field(InterimInflowAcc;InterimInflowAcc) { ApplicationArea=All; }
                field(InterimOutflowAcc;InterimOutflowAcc) { ApplicationArea=All; }
                field(PurchDiscAcc;PurchDiscAcc) { ApplicationArea=All; }
            }
        }
    }    
}