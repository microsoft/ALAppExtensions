// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Requisition;

using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Setup;

reportextension 11701 "Carry Out Action Msg. Req. CZA" extends "Carry Out Action Msg. - Req."
{
    requestpage
    {
        layout
        {
            addlast(Options)
            {
                field(PurchOrderHeaderNoSeries; PurchOrderHeader."No. Series")
                {
                    ApplicationArea = Planning;
                    Caption = 'No. Series';
                    ToolTip = 'Specifies no. series for reporting';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        PurchasesPayablesSetupCZA.Get();
                        PurchasesPayablesSetupCZA.TestField("Order Nos.");
                        if NoSeriesManagementCZA.SelectSeries(PurchasesPayablesSetupCZA."Order Nos.", '', PurchOrderHeader."No. Series") then
                            NoSeriesManagementCZA.TestSeries(PurchasesPayablesSetupCZA."Order Nos.", PurchOrderHeader."No. Series");
                    end;

                    trigger OnValidate()
                    begin
                        PurchasesPayablesSetupCZA.Get();
                        PurchasesPayablesSetupCZA.TestField("Order Nos.");
                        if PurchOrderHeader."No. Series" <> '' then
                            NoSeriesManagementCZA.TestSeries(PurchasesPayablesSetupCZA."Order Nos.", PurchOrderHeader."No. Series");
                    end;
                }
            }
        }
    }

    var
        PurchasesPayablesSetupCZA: Record "Purchases & Payables Setup";
        NoSeriesManagementCZA: Codeunit NoSeriesManagement;
}
