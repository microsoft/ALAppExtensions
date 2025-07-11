// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

page 6396 "Continia Network Profile List"
{
    ApplicationArea = All;
    Caption = 'Network Profiles';
    DeleteAllowed = false;
    Editable = false;
    Extensible = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Continia Network Profile";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Network; Rec.Network) { }
                field(Description; Rec.Description) { }
                field("Process Identifier"; Rec."Process Identifier") { }
                field("Document Identifier"; Rec."Document Identifier") { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetNetworkProfiles)
            {
                Caption = 'Import Network Profiles';
                Image = Import;
                ToolTip = 'Imports all the Network Profiles from Continia API.';

                trigger OnAction()
                var
                    ApiRequests: Codeunit "Continia Api Requests";
                begin
                    ApiRequests.GetNetworkProfiles(Enum::"Continia E-Delivery Network"::Peppol);
                    ApiRequests.GetNetworkProfiles(Enum::"Continia E-Delivery Network"::Nemhandel);
                end;
            }
        }

    }
}

