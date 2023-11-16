// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Security.User;

page 31199 "User Setup Lines CZL"
{
    AutoSplitKey = true;
    Caption = 'User Setup Lines';
    DataCaptionFields = "User ID";
    PageType = Worksheet;
    SourceTable = "User Setup Line CZL";

    layout
    {
        area(content)
        {
            field("UserSetupLine.Type"; UserSetupLineCZL.Type)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Enabled Code / Journal';
                ToolTip = 'Specifies selecting an area, for which will be setuped the user''s filters.';

                trigger OnValidate()
                begin
                    SetLinesFilter();
                    UserCheckLineTypeOnAfterVal();
                end;
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code / Name"; Rec."Code / Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code/name for related row type.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("List")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'List';
                Image = List;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Open the page for user setup lines.';

                trigger OnAction()
                var
                    UserSetupLineCZL: Record "User Setup Line CZL";
                begin
                    UserSetupLineCZL.SetRange("User ID", Rec.GetRangeMin("User ID"));
                    Page.Run(Page::"User Setup Lines List CZL", UserSetupLineCZL);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        UserSetupLineCZL.Init();
        SetLinesFilter();
    end;

    var
        UserSetupLineCZL: Record "User Setup Line CZL";

    procedure SetLinesFilter()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange(Type, UserSetupLineCZL.Type);
        Rec.FilterGroup(0);
    end;

    local procedure UserCheckLineTypeOnAfterVal()
    begin
        CurrPage.Update();
    end;
}
