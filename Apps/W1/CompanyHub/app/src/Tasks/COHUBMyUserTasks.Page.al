page 1154 "COHUB My User Tasks"
{
    Caption = 'My User Tasks';
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "COHUB User Task";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Company Display Name"; Rec."Company Display Name")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Display Name';
                    ToolTip = 'Specifies the display name of the company.';
                    Visible = true;
                }
                field("Enviroment Name"; EnvironmentName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Environment Name';
                    ToolTip = 'Specifies the name of the environment.';
                    Visible = false;
                }
                field(Title; Rec.Title)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Title';
                    ToolTip = 'Specifies the name of the environment.';
                    DrillDown = true;
                    Visible = true;

                    trigger OnDrillDown();
                    begin
                        HyperLink(Rec.Link);
                    end;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Due date';
                    ToolTip = 'Specifies the due date of the task.';
                    StyleExpr = StyleTxt;
                    Visible = true;
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Priority';
                    ToolTip = 'Specifies the priority of the task.';
                    Visible = true;
                }
                field("Percent Complete"; Rec."Percent Complete")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Percent Complete';
                    ToolTip = 'Specifies the completion percentage of the task.';
                    Visible = true;
                }
                field("Last Refreshed"; Rec."Last Refreshed")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Last Refreshed';
                    ToolTip = 'Specifies the last refreshed date of this record.';
                    Visible = true;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Created By';
                    ToolTip = 'Specifies user who created the task.';
                    Visible = false;
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Created Date';
                    ToolTip = 'Specifies date when the task was created.';
                    Visible = false;
                }
                field("User Task Group"; Rec."User Task Group Assigned To")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'User Task Group';
                    ToolTip = 'Specifies the group that the task is assigned to.';
                    Visible = true;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Go To Company")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Go To Company';
                Enabled = GoToCompanyIsEnabled;
                Image = Company;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                Scope = Repeater;
                ToolTip = 'Log into the company and see tasks that are assigned to you or your group.';
                Visible = true;

                trigger OnAction();
                var
                    COHUBEnviroment: Record "COHUB Enviroment";
                begin
                    if COHUBEnviroment.Get(Rec."Enviroment No.") then
                        if COHUBEnviroment.Link <> '' then
                            HyperLink(
                              COHUBEnviroment.Link +
                              '&company=' + Rec."Company Name" + '&page=1170' + FilterForMyUserTasksListTxt);
                end;
            }
            action(RefreshCurrentCompany)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Refresh Current Task';
                Enabled = GoToCompanyIsEnabled;
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Repeater;
                ToolTip = 'Refresh data for the selected Tasks Company.';
                Visible = true;

                trigger OnAction();
                var
                    COHUBCore: Codeunit "COHUB Core";
                begin
                    COHUBCore.UpdateEnviromentCompany(Rec."Enviroment No.", Rec."Company Name", Rec."Assigned To");
                    CurrPage.Update(false);
                end;
            }
            action(MarkTaskComplete)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Mark Task Complete';
                Image = Completed;
                ToolTip = 'Mark this task as completed.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Visible = true;

                trigger OnAction();
                var
                    COHUBCore: Codeunit "COHUB Core";
                begin
                    COHUBCore.SetUserTaskComplete(Rec."Enviroment No.", Rec."Company Name", Rec."Assigned To", Rec.ID);
                    CurrPage.Update(false);
                end;
            }

            action(ReloadAllCompanies)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Refresh all data';
                Image = WorkCenterLoad;
                RunObject = Codeunit "COHUB Reload Companies";
                ToolTip = 'Refresh data from all companies.';
                Visible = true;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
            }
        }
    }

    trigger OnAfterGetRecord();
    var
        COHUBEnviroment: Record "COHUB Enviroment";
    begin
        StyleTxt := SetStyle();
        COHUBEnviroment.Get(Rec."Enviroment No.");
        EnvironmentName := COHUBEnviroment.Name;
    end;

    trigger OnOpenPage();
    begin
        Rec.SetRange("Assigned To", UserSecurityId());
        Rec.SetFilter("Percent Complete", '<%1', 100);
        if Rec.Count() > 0 then
            GoToCompanyIsEnabled := true;
    end;

    var
        StyleTxt: Text;
        EnvironmentName: Text;
        GoToCompanyIsEnabled: Boolean;
        FilterForMyUserTasksListTxt: Label '&filter=''ShouldShowPendingTasks'' IS ''1''', Locked = true;


    local procedure SetStyle(): Text;
    begin
        if (Rec."Due Date" <> 0D) and (Rec."Due Date" <= DT2DATE(CurrentDateTime())) then
            exit('Unfavorable');

        exit('');
    end;
}
