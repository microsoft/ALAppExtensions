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

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Network Name"; Network)
                {
                    ApplicationArea = All;
                    ToolTip = 'The Network Name of the Network Identifier';
                }
                field("Scheme Id"; "Scheme Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'The scheme Id of the identifier type.';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'The description of the identifier type.';
                }
                field("Identifier Type Id"; "Identifier Type Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'The EAS code of the identifier type.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetContiniaNetworkIdTypes)
            {
                ApplicationArea = All;
                Caption = 'Import Network ID Types';
                ToolTip = 'Imports all the Network ID Types from Continia API';
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

