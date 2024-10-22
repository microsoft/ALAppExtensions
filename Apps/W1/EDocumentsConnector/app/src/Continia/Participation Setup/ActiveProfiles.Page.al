// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

page 6392 "Active Profiles"
{
    Caption = 'Active Network Profile';
    PageType = ListPart;
    SourceTable = "Activated Net. Prof.";
    SourceTableView = where(Disabled = filter(0DT));

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Network Profile Description"; Rec."Network Profile Description")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the profile.';
                    Width = 20;
                }
                field("Profile Direction"; Rec."Profile Direction")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the direction of the profile.';

                }
            }
        }
    }

}

