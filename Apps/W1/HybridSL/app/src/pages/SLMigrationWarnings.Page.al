// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

page 47021 "SL Migration Warnings"
{
    ApplicationArea = All;
    Caption = 'SL Migration Warnings';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "SL Migration Warnings";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Id; Rec.Id)
                {
                    ToolTip = 'Specifies the Id in which the warning occured.';
                }
                field(Company; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the company in which the warning occured.';
                }
                field("Migration Area"; Rec."Migration Area")
                {
                    ToolTip = 'Specifies the Migration Area in which the warning occured.';
                }
                field(Context; Rec.Context)
                {
                    ToolTip = 'Specifies the Context in which the warning occured.';
                }
                field("Warning Text"; Rec."Warning Text")
                {
                    ToolTip = 'Specifies the Warning Text in which the warning occured.';
                }
                field("Modifed Date"; Rec."SystemModifiedAt")
                {
                    ToolTip = 'Specifies the Date the warning last occured.';
                }
                field("Created Date"; Rec."SystemCreatedAt")
                {
                    ToolTip = 'Specifies the Date the warning originally occured.';
                }
            }
        }
    }
}
