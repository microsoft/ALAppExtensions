// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

page 6395 "Continia Network Id. List"
{
    ApplicationArea = All;
    Caption = 'Network Identifier List';
    DeleteAllowed = false;
    Editable = false;
    Extensible = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = "Continia Network Identifier";
    SourceTableView = sorting("Scheme Id") order(ascending);
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Network Name"; Rec.Network) { }
                field("Scheme Id"; Rec."Scheme Id") { }
                field(Description; Rec.Description) { }
                field("Identifier Type Id"; Rec."Identifier Type Id") { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetContiniaNetworkIdTypes)
            {
                Caption = 'Import Network ID Types';
                Image = Import;
                ToolTip = 'Imports all the Network ID Types from Continia API.';

                trigger OnAction()
                var
                    ApiRequests: Codeunit "Continia Api Requests";
                begin
                    ApiRequests.GetNetworkIdTypes(Enum::"Continia E-Delivery Network"::Peppol);
                    ApiRequests.GetNetworkIdTypes(Enum::"Continia E-Delivery Network"::Nemhandel);
                end;
            }
        }

    }
}

