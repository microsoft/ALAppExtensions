// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.Agents;

table 4593 "SOA KPI"
{
    DataClassification = CustomerContent;
    Access = Internal;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    ReplicateData = false;
    Caption = 'Sales Order Agent';
    Permissions = tabledata "SOA Setup" = r, tabledata "Agent Task" = r, tabledata "Agent Task Message" = r;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            ToolTip = 'Specifies the primary key. This value should be a blank code as the table is a singleton table.';
        }
        field(2; "Received Emails"; Integer)
        {
            Caption = 'Received emails';
            ToolTip = 'Specifies the total number of emails that the agent has received.';
        }
        field(3; "Total Emails"; Integer)
        {
            Caption = 'Total emails';
            ToolTip = 'Specifies the total number of emails that the agent has received or created.';
        }
        field(4; "Total Quotes Created"; Integer)
        {
            Caption = 'Quotes created';
            ToolTip = 'Specifies the total number of quotes that the agent has created. Both active and inactive quotes are included.';
        }
        field(5; "Total Orders Created"; Integer)
        {
            Caption = 'Orders created';
            ToolTip = 'Specifies the total number of orders that the agent has created. Both active and inactive orders are included.';
        }
        field(6; "Total Amount Orders"; Decimal)
        {
            Caption = 'Amount inc. Tax of orders';
            ToolTip = 'Specifies the total amount including tax of all orders that the agent has created. Both active and inactive orders are included.';
            AutoFormatType = 1;
            AutoFormatExpression = '';
        }
        field(20; "Last Updated DateTime"; DateTime)
        {
            Caption = 'Updated at';
            ToolTip = 'Specifies the date and time when the KPI was last updated.';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    internal procedure GetSafe()
    begin
        Rec.ReadIsolation := IsolationLevel::ReadCommitted;
        if not Rec.Get() then
            Rec.Insert();
    end;

    internal procedure UpdateEntryKPIs(var SOAKPIEntry: Record "SOA KPI Entry"; PreviousAmount: Decimal; InsertedRecord: Boolean)
    begin
        Rec.GetSafe();
        case SOAKPIEntry."Record Type" of
            SOAKPIEntry."Record Type"::"Sales Order":
                begin
                    if InsertedRecord then begin
                        Rec."Total Orders Created" += 1;
                        Rec."Total Amount Orders" += SOAKPIEntry."Amount Including Tax";
                        Rec.Modify();
                        exit;
                    end;

                    if SOAKPIEntry."Amount Including Tax" > PreviousAmount then begin
                        Rec."Total Amount Orders" += SOAKPIEntry."Amount Including Tax" - PreviousAmount;
                        Rec.Modify();
                    end;
                    exit;
                end;
            SOAKPIEntry."Record Type"::"Sales Quote":
                if InsertedRecord then begin
                    Rec."Total Quotes Created" += 1;
                    Rec.Modify();
                    exit;
                end;
        end;
    end;

    internal procedure UpdateEmailKPIs(var AgentSecurityID: Guid)
    begin
        UpdateEmailKPIs(AgentSecurityID, true);
    end;

    internal procedure UpdateEmailKPIs(var AgentSecurityID: Guid; UseRefreshInterval: Boolean)
    var
        SOASetup: Record "SOA Setup";
        AgentTask: Record "Agent Task";
        AgentTaskMessage: Record "Agent Task Message";
        BlankUpdatedDateTime: DateTime;
        UpdateDateTime: DateTime;
    begin
        if IsNullGuid(AgentSecurityID) then
            exit;

        SOASetup.SetRange("Agent User Security ID", AgentSecurityID);
        if SOASetup.IsEmpty() then
            exit;

        Clear(BlankUpdatedDateTime);
        Rec.GetSafe();

        if UseRefreshInterval then
            if Rec."Last Updated DateTime" <> BlankUpdatedDateTime then
                if CurrentDateTime() - Rec."Last Updated DateTime" < RefreshKPIsInterval() then
                    exit;

        UpdateDateTime := CurrentDateTime;

        AgentTask.SetRange("Agent User Security ID", AgentSecurityID);
        AgentTask.ReadIsolation := IsolationLevel::ReadCommitted;
        AgentTaskMessage.ReadIsolation := IsolationLevel::ReadCommitted;
        if AgentTask.FindSet() then
            repeat
                AgentTaskMessage.SetRange("Task ID", AgentTask.ID);
                AgentTaskMessage.SetRange(Type);
                if Rec."Last Updated DateTime" <> BlankUpdatedDateTime then
                    AgentTaskMessage.SetFilter(SystemCreatedAt, '>=%1', Rec."Last Updated DateTime");

                Rec."Total Emails" += AgentTaskMessage.Count;
                AgentTaskMessage.SetRange(Type, AgentTaskMessage.Type::Input);
                Rec."Received Emails" += AgentTaskMessage.Count;
            until AgentTask.Next() = 0;

        Rec."Last Updated DateTime" := UpdateDateTime;
        Rec.Modify();
    end;

    local procedure RefreshKPIsInterval(): Integer
    begin
        if not Rec.Get() then
            exit(1000); // 1 seconds

        if Rec."Received Emails" < 50 then
            exit(1000); // 1 seconds

        if Rec."Received Emails" < 100 then
            exit(60000); // 1 minute

        exit(300000); // 5 minutes
    end;
}