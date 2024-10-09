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

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Network; Network)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the network name of the profile';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the network profile.';
                }
                field("Process Identifier"; "Process Identifier")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the process identifier value of the profile.';
                }
                field("Document Identifier"; "Document Identifier")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the document identifier value of the profile.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetNetworkProfiles)
            {
                ApplicationArea = All;
                Caption = 'Import Network Profiles';
                ToolTip = 'Imports all the Network Profiles from Continia API';
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

