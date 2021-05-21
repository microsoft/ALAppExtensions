page 1167 "COHUB Companies Overview"
{
    Caption = 'Company Hub';
    PageType = ListPlus;
    PromotedActionCategories = 'New,Process,Report,Setup,Errors,Tasks';
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            part(CompanyKPIInfo; "COHUB Company Summary")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Summary';
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Setup)
            {
                Caption = 'Setup';
                Image = Setup;
                action("Manage Environment Links")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Environment Links';
                    Image = CustomerList;
                    RunObject = Page "COHUB Enviroment List";
                    ToolTip = 'Show the list of enviroments that you have access to in the Company Hub.';
                    Visible = true;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                }

                action(ReloadAllCompanies)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reload all companies';
                    Image = WorkCenterLoad;
                    RunObject = Codeunit "COHUB Reload Companies";
                    ToolTip = 'Reload all companies and update the data.';
                    Visible = true;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                }
            }

            group(Tasks)
            {
                action("My User Tasks")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'My User Tasks';
                    Image = Task;
                    RunObject = Page "COHUB My User Tasks";
                    ToolTip = 'View pending user tasks that are assigned to you across all companies.';
                    Visible = true;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                }
            }

            group(Errors)
            {
                Caption = 'Errors';
                Image = Setup;

                action("Check Errors")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Check Errors';
                    Image = Log;
                    RunObject = Codeunit "COHUB Show Activity Log";
                    ToolTip = 'Show a list of synchronization errors.';
                    Visible = true;
                    Promoted = false;
                }
                action("Delete Errors")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Delete Errors';
                    Image = Delete;
                    RunObject = Codeunit "COHUB Delete Activity Log";
                    ToolTip = 'Clear the list of synchronization errors.';
                    Visible = true;
                    Promoted = false;
                }
            }
        }
    }
}

