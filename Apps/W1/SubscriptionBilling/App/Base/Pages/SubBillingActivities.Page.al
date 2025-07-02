namespace Microsoft.SubscriptionBilling;

using System.Visualization;
#if not CLEAN26
using Microsoft.Foundation.Task;
#endif
using Microsoft.Sales.Document;
using Microsoft.Purchases.Document;
#if not CLEAN26
using Microsoft.Projects.Project.Job;
#endif
using Microsoft.RoleCenters;

page 8085 "Sub. Billing Activities"
{
    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "Subscription Billing Cue";
    ApplicationArea = Basic, Suite;
    Permissions = tabledata "Subscription Billing Cue" = rimd;

    layout
    {
        area(content)
        {
#if not CLEAN26
            cuegroup("My User Tasks")
            {
                ObsoleteReason = 'Removed as tasks are already a part of other role centers.';
                ObsoleteState = Pending;
                ObsoleteTag = '26.0';
                Visible = false;
                Caption = 'My User Tasks';
                field("UserTaskManagement.GetMyPendingUserTasksCount"; UserTaskManagement.GetMyPendingUserTasksCount())
                {
                    ObsoleteReason = 'Removed as tasks are already a part of other role centers.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '26.0';
                    Visible = false;
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
                ObsoleteReason = 'Removed as projects are not relevant in context of Subscription Billing';
                ObsoleteState = Pending;
                ObsoleteTag = '26.0';
                Visible = false;
                Caption = 'Projects to Budget';
                field("Jobs Over Budget"; Rec."Jobs Over Budget")
                {
                    ObsoleteReason = 'Removed as projects are not relevant in context of Subscription Billing';
                    ObsoleteState = Pending;
                    ObsoleteTag = '26.0';
                    Visible = false;
                    Caption = 'Over Budget';
                    DrillDownPageId = "Job List";
                    Editable = false;
                    ToolTip = 'Specifies the number of projects where the usage cost exceeds the budgeted cost.';
                }
            }
#endif

            cuegroup("Open Posted Documents Customer")
            {
                Caption = 'Open Posting Documents Customer';
                field("Customer Contract Invoices"; Rec."Cust. Sub. Contr. Invoices")
                {
                    Caption = 'Contract Invoices';
                    DrillDownPageId = "Sales Invoice List";
                    Editable = false;
                    ToolTip = 'Specifies the Open Customer Subscription Contract Invoices.';
                }
                field("Customer Contract Credit Memos"; Rec."Cust. Sub. Contr. Credit Memos")
                {
                    Caption = 'Contract Credit Memos';
                    DrillDownPageId = "Sales Credit Memos";
                    Editable = false;
                    ToolTip = 'Specifies the Open Customer Subscription Contract Credit Memos.';
                }
            }
            cuegroup("Open Posted Documents Vendor")
            {
                Caption = 'Open Posting Documents Vendor';
                field("Vendor Contract Invoices"; Rec."Vend. Sub. Contr. Invoices")
                {
                    Caption = 'Contract Invoices';
                    DrillDownPageId = "Purchase Invoices";
                    Editable = false;
                    ToolTip = 'Specifies the Open Vendor Subscription Contract Invoices.';
                }
                field("Vendor Contract Credit Memos"; Rec."Vend. Contr. Credit Memos")
                {
                    Caption = 'Contract Credit Memos';
                    DrillDownPageId = "Purchase Credit Memos";
                    Editable = false;
                    ToolTip = 'Specifies the Open Vendor Subscription Contract Credit Memos.';
                }
            }
            cuegroup("Service Commitments without Customer Contract")
            {
                Caption = 'Subscription Lines without Contract';
                field("Serv. Comm. wo Cust. Contract"; Rec."Sub. L. wo Cust. Sub. Contract")
                {
                    Caption = 'Customer';
                    DrillDownPageId = "Serv. Comm. WO Cust. Contract";
                    Editable = false;
                    ToolTip = 'Specifies the Subscription Lines without Customer Contract.';
                }
                field("Serv. Comm. wo Vend. Contract"; Rec."Sub. L. wo Vend. Sub. Contract")
                {
                    Caption = 'Vendor';
                    DrillDownPageId = "Serv. Comm. WO Vend. Contract";
                    Editable = false;
                    ToolTip = 'Specifies the Subscription Lines without Vendor Subscription Contract.';
                }
            }
            cuegroup(Overdue)
            {
                Caption = 'Subscription Lines';
                field(OverdueField; Rec.Overdue)
                {
                    Editable = false;
                    ToolTip = 'Specifies the overdue Subscription Lines.';
                    trigger OnDrillDown()
                    begin
                        SubBillingActivitiesCue.DrillDownOverdueServiceCommitments();
                    end;
                }
                field("Not Invoiced"; Rec."Not Invoiced")
                {
                    DrillDownPageId = "Billing Lines";
                    Editable = false;
                    ToolTip = 'Specifies the Billing Lines for Subscription Lines that have not been called into Posting Documents, yet.';
                }
            }
            cuegroup("Balances")
            {
                Caption = 'Balances';
                CueGroupLayout = Wide;
                field("Revenue current Month"; Rec."Revenue current Month")
                {
                    Image = Cash;
                    ToolTip = 'Specifies the Balance between posted Contract Invoices and Contract Credit Memos for Customer Subscription Contracts in current Month.';
                }
                field("Cost current Month"; Rec."Cost current Month")
                {
                    Image = Cash;
                    ToolTip = 'Specifies the Balance between posted Contract Invoices and Contract Credit Memos for Vendor Subscription Contracts in current Month.';
                }
                field("Revenue previous Month"; Rec."Revenue previous Month")
                {
                    Image = Cash;
                    ToolTip = 'Specifies the Balance between posted Contract Invoices and Contract Credit Memos for Customer Subscription Contracts in previous Month.';
                }
                field("Cost previous Month"; Rec."Cost previous Month")
                {
                    Image = Cash;
                    ToolTip = 'Specifies the Balance between posted Contract Invoices and Contract Credit Memos for Vendor Subscription Contracts in previous Month.';
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
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        TaskParameters: Dictionary of [Text, Text];
    begin
        if CalcTaskId <> 0 then
            if CurrPage.CancelBackgroundTask(CalcTaskId) then;
        CurrPage.EnqueueBackgroundTask(CalcTaskId, Codeunit::"Sub. Billing Activities Cue", TaskParameters, 120000, PageBackgroundTaskErrorLevel::Warning);
    end;

    trigger OnAfterGetRecord()
    var
        ServiceContractSetup: Record "Subscription Contract Setup";
    begin
        if not ServiceContractSetup.Get() then begin
            ServiceContractSetup.Init();
            ServiceContractSetup.Insert();
        end;
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

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    begin
        if TaskId <> CalcTaskId then
            exit;

        CalcTaskId := 0;

        Rec.Get();
        SubBillingActivitiesCue.EvaluateResults(Results, Rec);

        if Rec.WritePermission then
            if Rec.Modify() then
                Commit();

        CurrPage.Update();
    end;

    local procedure SetMyJobsFilter()
    begin
        Rec.SetFilter("Job No. Filter", SubBillingActivitiesCue.GetMyJobsFilter());
    end;

    var
        SubBillingActivitiesCue: Codeunit "Sub. Billing Activities Cue";
        CuesAndKpisCodeunit: Codeunit "Cues And KPIs";
#if not CLEAN26
        UserTaskManagement: Codeunit "User Task Management";
#endif
        CalcTaskId: Integer;
}
