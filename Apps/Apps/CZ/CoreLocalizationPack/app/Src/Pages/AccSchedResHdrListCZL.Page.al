// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

using System.Security.User;

page 31203 "Acc. Sched. Res. Hdr. List CZL"
{
    Caption = 'Acc. Schedule Res. Header List';
    CardPageId = "Acc. Sched. Res. Overview CZL";
    Editable = false;
    PageType = List;
    SourceTable = "Acc. Schedule Result Hdr. CZL";

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                ShowCaption = false;
                field("Result Code"; Rec."Result Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the result code of account schedule results.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of account schedule results.';
                }
                field("Date Filter"; Rec."Date Filter")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date filter of account schedule results.';
                }
                field("Acc. Schedule Name"; Rec."Acc. Schedule Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the account schedule.';
                }
                field("Column Layout Name"; Rec."Column Layout Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the column layout that you want to use in the window.';
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
                field("Result Date"; Rec."Result Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the created date of account schedule results.';
                }
                field("Result Time"; Rec."Result Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the created time of account schedule results.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Acc. Schedule Result")
            {
                Caption = 'Acc. Schedule Result';
                action(Card)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = page "Acc. Sched. Res. Overview CZL";
                    RunPageLink = "Result Code" = field("Result Code"),
                                  "Acc. Schedule Name" = field("Acc. Schedule Name");
                    ShortcutKey = 'Shift+F7';
                    ToolTip = 'The funkction opens the account schedule result card.';
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'Functions';
                action(Print)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Print';
                    Ellipsis = true;
                    Image = Print;
                    ToolTip = 'Allows print the account schedule results.';

                    trigger OnAction()
                    begin
                        AccScheduleResultHdrCZL := Rec;
                        AccScheduleResultHdrCZL.SetRecFilter();
                        Report.RunModal(Report::"Account Schedule Result CZL", true, false, AccScheduleResultHdrCZL);
                    end;
                }
                action("Export to Excel")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Export to Excel';
                    Ellipsis = true;
                    Image = ExportToExcel;
                    ToolTip = 'Allows the account schedule results export to excel.';

                    trigger OnAction()
                    var
                        ExpAccSchedResExcCZL: Report "Exp. Acc. Sched. Res. Exc. CZL";
                    begin
                        ExpAccSchedResExcCZL.SetOptions(Rec."Result Code", false);
                        ExpAccSchedResExcCZL.Run();
                    end;
                }
            }
        }
    }

    var
        AccScheduleResultHdrCZL: Record "Acc. Schedule Result Hdr. CZL";
}

