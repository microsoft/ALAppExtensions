// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace System.Visualization;

pageextension 1442 "Headlines RC Accountant Ext." extends "Headline RC Accountant"
{

    layout
    {
        addlast(Content)
        {
            group(LargestOrder)
            {
                Visible = LargestOrderVisible;
                ShowCaption = false;
                Editable = false;

                field(LargestOrderText; LargestOrderText)
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = true;
                    ShowCaption = false;

                    trigger OnDrillDown()
                    var
                        EssentialBusHeadlineMgt: Codeunit "Essential Bus. Headline Mgt.";
                    begin
                        EssentialBusHeadlineMgt.OnDrillDownLargestOrder();
                    end;
                }
            }

            group(LargestSale)
            {
                Visible = LargestSaleVisible;
                ShowCaption = false;
                Editable = false;

                field(LargestSaleText; LargestSaleText)
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = true;
                    ShowCaption = false;

                    trigger OnDrillDown()
                    var
                        EssentialBusHeadlineMgt: Codeunit "Essential Bus. Headline Mgt.";
                    begin
                        EssentialBusHeadlineMgt.OnDrillDownLargestSale();
                    end;
                }
            }

            group(SalesIncrease)
            {
                Visible = SalesIncreaseVisible;
                ShowCaption = false;
                Editable = false;

                field(SalesIncreaseText; SalesIncreaseText)
                {
                    ApplicationArea = Basic, Suite;
                    ShowCaption = false;

                    trigger OnDrillDown()
                    var
                        EssentialBusHeadlineMgt: Codeunit "Essential Bus. Headline Mgt.";
                    begin
                        EssentialBusHeadlineMgt.OnDrillDownSalesIncrease();
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        OnSetVisibility(LargestOrderVisible, LargestOrderText,
                        LargestSaleVisible, LargestSaleText,
                        SalesIncreaseVisible, SalesIncreaseText);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetVisibility(var LargestOrderVisible: Boolean; var LargestOrderText: Text[250];
                                    var LargestSaleVisible: Boolean; var LargestSaleText: Text[250];
                                    var SalesIncreaseVisible: Boolean; var SalesIncreaseText: Text[250])
    begin
    end;

    var
        LargestOrderVisible: Boolean;
        LargestOrderText: Text[250];
        LargestSaleVisible: Boolean;
        LargestSaleText: Text[250];
        SalesIncreaseVisible: Boolean;
        SalesIncreaseText: Text[250];

}