namespace Microsoft.SubscriptionBilling;

using System.Visualization;
using Microsoft.Foundation.Task;
using Microsoft.Sales.Document;
using Microsoft.Purchases.Document;
using Microsoft.Projects.Project.Job;
using Microsoft.RoleCenters;

page 8085 "Sub. Billing Activities"
{
    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "Subscription Billing Cue";
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            cuegroup("My User Tasks")
            {
                Caption = 'My User Tasks';
                field("UserTaskManagement.GetMyPendingUserTasksCount"; UserTaskManagement.GetMyPendingUserTasksCount())
                {
                    Caption = 'Pending User Tasks';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of pending tasks that are assigned to you or to a group that you are a member of.';

                    trigger OnDrillDown()
                    var
                        UserTaskList: Page "User Task List";
                    begin
                        UserTaskList.SetPageToShowMyPendingUserTasks();
                        UserTaskList.Run();
                    end;
                }
            }
            cuegroup("Jobs to Budget")
            {
                Caption = 'Projects to Budget';
                field("Jobs Over Budget"; Rec."Jobs Over Budget")
                {
                    Caption = 'Over Budget';
                    DrillDownPageID = "Job List";
                    Editable = false;
                    ToolTip = 'Specifies the number of projects where the usage cost exceeds the budgeted cost.';
                }
            }

            cuegroup("Open Posted Documents Customer")
            {
                Caption = 'Open Posting Documents Customer';
                field("Customer Contract Invoices"; Rec."Customer Contract Invoices")
                {
                    Caption = 'Contract Invoices';
                    DrillDownPageID = "Sales Invoice List";
                    Editable = false;
                    ToolTip = 'Shows Open Customer Contract Invoices.';
                }
                field("Customer Contract Credit Memos"; Rec."Customer Contract Credit Memos")
                {
                    Caption = 'Contract Credit Memos';
                    DrillDownPageID = "Sales Credit Memos";
                    Editable = false;
                    ToolTip = 'Shows Open Customer Contract Credit Memos.';
                }
            }
            cuegroup("Open Posted Documents Vendor")
            {
                Caption = 'Open Posting Documents Vendor';
                field("Vendor Contract Invoices"; Rec."Vendor Contract Invoices")
                {
                    Caption = 'Contract Invoices';
                    DrillDownPageID = "Purchase Invoices";
                    Editable = false;
                    ToolTip = 'Shows Open Vendor Contract Invoices.';
                }
                field("Vendor Contract Credit Memos"; Rec."Vendor Contract Credit Memos")
                {
                    Caption = 'Contract Credit Memos';
                    DrillDownPageID = "Purchase Credit Memos";
                    Editable = false;
                    ToolTip = 'Shows Open Vendor Contract Credit Memos.';
                }
            }
            cuegroup("Service Commitments without Customer Contract")
            {
                Caption = 'Service Commitments without Contract';
                field("Serv. Comm. wo Cust. Contract"; Rec."Serv. Comm. wo Cust. Contract")
                {
                    Caption = 'Customer';
                    DrillDownPageID = "Serv. Comm. WO Cust. Contract";
                    Editable = false;
                    ToolTip = 'Shows Service Commitments without Customer Contract.';
                }
                field("Serv. Comm. wo Vend. Contract"; Rec."Serv. Comm. wo Vend. Contract")
                {
                    Caption = 'Vendor';
                    DrillDownPageID = "Serv. Comm. WO Vend. Contract";
                    Editable = false;
                    ToolTip = 'Shows Service Commitments without Vendor Contract.';
                }
            }
            cuegroup(Overdue)
            {
                Caption = 'Service Commitments';
                field(OverdueField; Rec.Overdue)
                {
                    Editable = false;
                    ToolTip = 'Shows overdue Service Commitments.';
                    trigger OnDrillDown()
                    var
                    begin
                        Page.Run(Page::"Overdue Service Commitments", TempOverdueServiceCommitments);
                    end;
                }
                field("Not Invoiced"; Rec."Not Invoiced")
                {
                    DrillDownPageID = "Billing Lines";
                    Editable = false;
                    ToolTip = 'Shows Billing Lines for Service Commitments that have not been called into Posting Documents, yet.';
                }
            }
            cuegroup("Balances")
            {
                Caption = 'Balances';
                CueGroupLayout = Wide;
                field("Revenue current Month"; Rec."Revenue current Month")
                {
                    Image = Cash;
                    ToolTip = 'Saldo between posted Contract Invoices and Contract Credit Memos for Customer Contracts in current Month.';
                }
                field("Cost current Month"; Rec."Cost current Month")
                {
                    Image = Cash;
                    ToolTip = 'Saldo between posted Contract Invoices and Contract Credit Memos for Vendor Contracts in current Month.';
                }
                field("Revenue previous Month"; Rec."Revenue previous Month")
                {
                    Image = Cash;
                    ToolTip = 'Saldo between posted Contract Invoices and Contract Credit Memos for Customer Contracts in previous Month.';
                }
                field("Cost previous Month"; Rec."Cost previous Month")
                {
                    Image = Cash;
                    ToolTip = 'Saldo between posted Contract Invoices and Contract Credit Memos for Vendor Contracts in previous Month.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Set Up Cues")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Set Up Cues';
                Image = Setup;
                ToolTip = 'Set up the cues (status tiles) related to the role.';

                trigger OnAction()
                var
                    CueRecordRef: RecordRef;
                begin
                    CueRecordRef.GetTable(Rec);
                    CuesAndKpisCodeunit.OpenCustomizePageForCurrentUser(CueRecordRef.Number);
                end;
            }
            action(Refresh)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Refresh';
                Image = Refresh;
                ToolTip = 'Executes the Refresh action.';

                trigger OnAction()
                begin
                    SetMyJobsFilter();
                    RefreshRoleCenter();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        ServiceContractSetup: Record "Service Contract Setup";
    begin
        if not ServiceContractSetup.get() then begin
            ServiceContractSetup.Init();
            ServiceContractSetup.Insert();
        end;

        CalculateCueFieldValues();
    end;

    trigger OnOpenPage()
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(false);
        end;

        SetMyJobsFilter();
        RoleCenterNotificationMgt.ShowNotifications();
    end;

    local procedure SetMyJobsFilter()
    begin
        Rec.SetFilter("Job No. Filter", SubBillingActivitiesCue.GetMyJobsFilter());
    end;

    local procedure RefreshRoleCenter()
    begin
        CurrPage.Update();
    end;

    local procedure CalculateCueFieldValues()
    begin
        if Rec.FieldActive("Revenue current Month") then
            Rec."Revenue current Month" := SubBillingActivitiesCue.RevenueCurrentMonth();
        if Rec.FieldActive("Cost current Month") then
            Rec."Cost current Month" := SubBillingActivitiesCue.CostCurrentMonth();
        if Rec.FieldActive("Revenue previous Month") then
            Rec."Revenue previous Month" := SubBillingActivitiesCue.RevenuePreviousMonth();
        if Rec.FieldActive("Cost previous Month") then
            Rec."Cost previous Month" := SubBillingActivitiesCue.CostPreviousMonth();
        if Rec.FieldActive(Overdue) then
            Rec.Overdue := TempOverdueServiceCommitments.FillAndCountOverdueServiceCommitments();
    end;

    var
        TempOverdueServiceCommitments: Record "Overdue Service Commitments" temporary;
        SubBillingActivitiesCue: Codeunit "Sub. Billing Activities Cue";
        CuesAndKpisCodeunit: Codeunit "Cues And KPIs";
        UserTaskManagement: Codeunit "User Task Management";
}
