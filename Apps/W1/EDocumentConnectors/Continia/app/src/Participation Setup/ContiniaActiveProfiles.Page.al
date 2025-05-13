// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

page 6392 "Continia Active Profiles"
{
    ApplicationArea = All;
    Caption = 'Active Network Profile';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "Continia Activated Net. Prof.";
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
                    Width = 20;
                }
                field("Profile Direction"; Rec."Profile Direction") { }
            }
        }
    }

}

