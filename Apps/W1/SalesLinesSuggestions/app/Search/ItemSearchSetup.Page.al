// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using System;

page 7280 "Item Search Setup"
{
    PageType = Card;
    Caption = 'Item Search Setup';
    InherentEntitlements = X;
    InherentPermissions = X;
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Status; ItemSearchCapability)
                {
                    Caption = 'Item Search Capability';
                    ApplicationArea = All;
                    QuickEntry = false;
                    Editable = false;
#pragma warning disable AA0219
                    ToolTip = 'Status of the item search capability.';
#pragma warning restore AA0219
                }
            }
        }

    }
    actions
    {
        area(Processing)
        {
            action(EnableItemSearch)
            {
                ApplicationArea = All;
                Caption = 'Enable Item Search';
                ToolTip = 'Enable the item search capability.';
                Image = Setup;
                trigger OnAction()
                var
                    ALSearch: DotNet ALSearch;
                begin
                    ALSearch.EnableItemSearch();
                    UpdateItemSearchStatus();
                end;
            }
            action(DisableItemSearch)
            {
                ApplicationArea = All;
                Caption = 'Disable Item Search';
                ToolTip = 'Disable the item search capability.';
                Image = Setup;
                trigger OnAction()
                var
                    ALSearch: DotNet ALSearch;
                begin
                    ALSearch.DisableItemSearch();
                    UpdateItemSearchStatus();
                end;
            }
            action(Refresh)
            {
                ApplicationArea = All;
                Caption = 'Refresh Status';
                ToolTip = 'Refresh status of the item search capability.';
                Image = Refresh;
                trigger OnAction()
                begin
                    UpdateItemSearchStatus();
                end;
            }
        }
        area(Promoted)
        {
            actionref(EnableItemSearch_Promoted; EnableItemSearch)
            {
            }
            actionref(DisableItemSearch_Promoted; DisableItemSearch)
            {
            }
            actionref(Refresh_Promoted; Refresh)
            {
            }
        }
    }

    trigger OnOpenPage()
    begin
        UpdateItemSearchStatus();
    end;

    local procedure UpdateItemSearchStatus()
    var
        ALSearch: DotNet ALSearch;
    begin
        if ALSearch.IsItemSearchReady() then
            ItemSearchCapability := 'Ready'
        else
            ItemSearchCapability := 'Not Ready';
    end;

    var
        ItemSearchCapability: Text[100];

}