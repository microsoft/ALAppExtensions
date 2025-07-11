// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

using System.Security.User;

page 31205 "Acc. Schedule Result Hist. CZL"
{
    Caption = 'Acc. Schedule Result History';
    Editable = false;
    PageType = List;
    SourceTable = "Acc. Schedule Result Hist. CZL";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                ShowCaption = false;
                field("Variant No."; Rec."Variant No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the no. of the variant';
                }
                field("New Value"; Rec."New Value")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies new code for the fixed asset location.';
                }
                field("Old Value"; Rec."Old Value")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the old value of the account schedule result';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID of the user associated with the entry.';

                    trigger OnDrillDown()
                    var
                        UserManagement: Codeunit "User Management";
                    begin
                        UserManagement.DisplayUserInformation(Rec."User ID");
                    end;
                }
                field("Modified DateTime"; Rec."Modified DateTime")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies modified date time';
                }
            }
        }
    }
}
