// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

xmlport 1870 "C5 InvenItemGroup"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'InvenItemGroupDocument';
            tableelement(C5InvenItemGroup; "C5 InvenItemGroup")
            {
                fieldelement(Group; C5InvenItemGroup.Group) { }
                fieldelement(GroupName; C5InvenItemGroup.GroupName) { }
                fieldelement(SalesAcc; C5InvenItemGroup.SalesAcc) { }
                fieldelement(COGSAcc; C5InvenItemGroup.COGSAcc) { }
                fieldelement(SalesDiscAcc; C5InvenItemGroup.SalesDiscAcc) { }
                fieldelement(InventoryInflowAcc; C5InvenItemGroup.InventoryInflowAcc) { }
                fieldelement(InventoryOutflowAcc; C5InvenItemGroup.InventoryOutflowAcc) { }
                fieldelement(LossAcc; C5InvenItemGroup.LossAcc) { }
                fieldelement(ProfitAcc; C5InvenItemGroup.ProfitAcc) { }
                fieldelement(InterimInflowOffset; C5InvenItemGroup.InterimInflowOffset) { }
                fieldelement(InterimOutflowOffset; C5InvenItemGroup.InterimOutflowOffset) { }
                fieldelement(ProfitMarginPct; C5InvenItemGroup.ProfitMarginPct) { }
                fieldelement(InterimInflowAcc; C5InvenItemGroup.InterimInflowAcc) { }
                fieldelement(InterimOutflowAcc; C5InvenItemGroup.InterimOutflowAcc) { }
                fieldelement(PurchDiscAcc; C5InvenItemGroup.PurchDiscAcc) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5InvenItemGroup.RecId := Counter;
                    Counter += 1;
                end;
            }
        }
    }

    var
        Counter: Integer;
}

