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
    SourceTableView = sorting("Scheme ID") order(ascending);

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
                field("Scheme ID"; "Scheme ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'The scheme ID of the identifier type.';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'The description of the identifier type.';
                }
                field("Identifier Type ID"; "Identifier Type ID")
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
            action(GetContiniaNetworkIDTypes)
            {
                ApplicationArea = All;
                Caption = 'Import Network ID Types';
                ToolTip = 'Imports all the Network ID Types from Continia API';
                Image = Import;
                trigger OnAction()
                var
                    APIRequests: Codeunit "API Requests";
                begin
                    APIRequests.GetNetworkIDTypes(Enum::"Network"::peppol);
                    APIRequests.GetNetworkIDTypes(Enum::"Network"::nemhandel);
                end;
            }
        }

    }
}

