// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

page 6395 "Network Id. List"
{

    Caption = 'Network Identifier List';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = None;
    ShowFilter = false;
    SourceTable = "Network Identifier";
    SourceTableView = sorting("Scheme Id") order(ascending);
    ApplicationArea = All;

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
                ToolTip = 'Imports all the Network ID Types from Continia API.';
                Image = Import;

                trigger OnAction()
                var
                    ApiRequests: Codeunit "Api Requests";
                begin
                    ApiRequests.GetNetworkIdTypes(Enum::"E-Delivery Network"::peppol);
                    ApiRequests.GetNetworkIdTypes(Enum::"E-Delivery Network"::nemhandel);
                end;
            }
        }

    }
}

