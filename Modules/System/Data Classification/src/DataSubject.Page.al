// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 1754 "Data Subject"
{
    Extensible = false;
    DeleteAllowed = false;
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = "Data Privacy Entities";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table Caption"; "Table Caption")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Style = StandardAccent;
                    StyleExpr = TRUE;

                    trigger OnDrillDown()
                    begin
                        PAGE.Run("Page No.");
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Data Privacy Setup")
            {
                ApplicationArea = All;
                Caption = 'Data Privacy Utility';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Open the Data Privacy Setup page.';

                trigger OnAction()
                var
                    DataClassificationMgt: Codeunit "Data Classification Mgt.";
                begin
                    if "Table Caption" <> '' then
                        DataClassificationMgt.SetEntityType(Rec, "Table Caption");
                end;
            }
        }
    }

    trigger OnInit()
    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        DataClassificationMgt.OnGetPrivacyMasterTables(Rec);
    end;
}

