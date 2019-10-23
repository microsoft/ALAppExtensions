// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

pageextension 1444 "Headlines RC Rel. Mgt. Ext." extends "Headline RC Relationship Mgt."
{

    layout
    {
        addlast(Content)
        {
            group(TopCustomerVisible)
            {
                Visible = IsTopCustomerVisible;
                Editable = false;
                ShowCaption = false;

                field(TopCustomerText; TopCustomerText)
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnDrillDown()
                    var
                        EssentialBusHeadlineMgt: Codeunit "Essential Bus. Headline Mgt.";
                    begin
                        EssentialBusHeadlineMgt.OnDrillDownTopCustomer();
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        OnSetVisibility(IsTopCustomerVisible, TopCustomerText);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetVisibility(var TopCustomerVisible: Boolean; var TopCustomerText: Text[250])
    begin
    end;

    var
        [InDataSet]
        IsTopCustomerVisible: Boolean;
        [InDataSet]
        TopCustomerText: Text[250];
}