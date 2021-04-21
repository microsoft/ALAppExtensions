// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

table 1867 "C5 InvenItemGroup"
{
    ReplicateData = false;

    fields
    {
        field(1; RecId; Integer)
        {
            Caption = 'Row number';
        }
        field(2; LastChanged; Date)
        {
            Caption = 'Last changed';
        }
        field(3; Group; Code[10])
        {
            Caption = 'Group';
        }
        field(4; GroupName; Text[30])
        {
            Caption = 'Group name';
        }
        field(5; SalesAcc; Text[10])
        {
            Caption = 'Sales a/c';
        }
        field(6; COGSAcc; Text[10])
        {
            Caption = 'COGS a/c';
        }
        field(7; SalesDiscAcc; Text[10])
        {
            Caption = 'LineDiscSales';
        }
        field(8; InventoryInflowAcc; Text[10])
        {
            Caption = 'Inven. inflow';
        }
        field(9; InventoryOutflowAcc; Text[10])
        {
            Caption = 'Inven. outflow';
        }
        field(10; LossAcc; Text[10])
        {
            Caption = 'Loss';
        }
        field(11; ProfitAcc; Text[10])
        {
            Caption = 'Profit';
        }
        field(12; InterimInflowOffset; Text[10])
        {
            Caption = 'Int. off. inflow a/c';
        }
        field(13; InterimOutflowOffset; Text[10])
        {
            Caption = 'Int. off. outflow a/c';
        }
        field(14; ProfitMarginPct; Decimal)
        {
            Caption = 'Profit margin';
        }
        field(15; InterimInflowAcc; Text[10])
        {
            Caption = 'Interim inflow';
        }
        field(16; InterimOutflowAcc; Text[10])
        {
            Caption = 'Interim outflow';
        }
        field(17; PurchDiscAcc; Text[10])
        {
            Caption = 'LineDiscPurchase';
        }
    }

    keys
    {
        key(PK; RecId)
        {
            Clustered = true;
        }
    }
}

