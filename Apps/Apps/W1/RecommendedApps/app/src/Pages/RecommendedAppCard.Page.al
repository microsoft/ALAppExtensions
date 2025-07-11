// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Environment.Configuration;

page 4751 "Recommended App Card"
{
    Caption = 'Recommended App Card';
    PageType = Card;
    SourceTable = "Recommended Apps";
    DataCaptionExpression = Rec.Name;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            field(Name; Rec.Name)
            {
                ApplicationArea = All;
                ToolTip = 'Name';
            }
            field(Publisher; Rec.Publisher)
            {
                ApplicationArea = All;
                ToolTip = 'Publisher';
            }
            field("Recommended By"; Rec."Recommended By")
            {
                ApplicationArea = All;
                ToolTip = 'Recommended By';
                Caption = 'Recommended By';
            }
            field("Description"; Rec."Long Description")
            {
                ApplicationArea = All;
                ToolTip = 'Description';
                Caption = 'Description';
                MultiLine = true;
            }
            field("View on AppSource"; 'Link to AppSource')
            {
                ApplicationArea = All;
                ToolTip = 'View app on Microsoft Business Central AppSource';
                Caption = 'View on AppSource';

                trigger OnDrillDown()
                begin
                    Hyperlink(RecommendedApps.GetAppURL(Rec.Id));
                end;
            }
        }
    }

    var
        RecommendedApps: Codeunit "Recommended Apps";
}
