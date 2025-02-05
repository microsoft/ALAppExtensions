// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

page 6396 "Network Profile List"
{

    Caption = 'Network Profiles';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "Network Profile";
    ApplicationArea = All;

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
                ToolTip = 'Imports all the Network Profiles from Continia API.';
                Image = Import;

                trigger OnAction()
                var
                    ApiRequests: Codeunit "Api Requests";
                begin
                    ApiRequests.GetNetworkProfiles(Enum::"E-Delivery Network"::peppol);
                    ApiRequests.GetNetworkProfiles(Enum::"E-Delivery Network"::nemhandel);
                end;
            }
        }

    }
}

