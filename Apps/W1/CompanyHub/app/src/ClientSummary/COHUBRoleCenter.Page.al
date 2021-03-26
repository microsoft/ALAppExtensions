page 1151 "COHUB Role Center"
{
    Caption = 'Company Hub';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
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
        area(Embedding)
        {
            action(CompanyHub)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Company Hub';
                Image = Task;
                RunObject = Page "COHUB Companies Overview";
                ToolTip = 'View and easily access all companies you work in. View key KPIs and manage User Tasks for each company.';
                Visible = true;
            }

            action("My User Tasks")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'My User Tasks';
                Image = Task;
                RunObject = Page "COHUB My User Tasks";
                ToolTip = 'View pending user tasks that are assigned to you across all companies.';
                Visible = true;
            }
        }

        area(sections)
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
                }

                action("Groups")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Enviroment Groups';
                    Image = CustomerGroup;
                    RunObject = page "COHUB Group List";
                    ToolTip = 'Show enviroment groups.';
                    Visible = true;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                }

                action(ReloadAllCompanies)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reload all companies';
                    Image = WorkCenterLoad;
                    RunObject = Codeunit "COHUB Reload Companies";
                    ToolTip = 'Reload all companies and update the data.';
                    Visible = true;
                }
            }
        }
    }
}

