// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.Email;

/// <summary>
/// Methods for testing the agent setup upon activation.
/// </summary>
codeunit 4397 "SOA Test Setup"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Email Inbox" = rd;
    TableNo = "SOA Setup";

    trigger OnRun()
    begin
        if TestEmailConnection then
            EmailConnectionTest(Rec);
        if TestEmailCount then
            EmailCountTest(Rec);
    end;

    procedure SetTestEmailConnection(TestConnection: Boolean)
    begin
        TestEmailConnection := TestConnection;
    end;

    procedure SetTestEmailCount(TestCount: Boolean)
    begin
        TestEmailCount := TestCount;
    end;

    procedure EmailConnectionTest(var TempSOASetup: Record "SOA Setup" temporary)
    var
        TempFilters: Record "Email Retrieval Filters" temporary;
        EmailInbox: Record "Email Inbox";
        Email: Codeunit "Email";
    begin
        TempFilters."Unread Emails" := true;
        TempFilters."Earliest Email" := TempSOASetup."Last Sync At";
        TempFilters."Max No. of Emails" := 1;
        Email.RetrieveEmails(TempSOASetup."Email Account ID", TempSOASetup."Email Connector", EmailInbox, TempFilters);

        // Delete all emails retrieved as they are not used.
        if EmailInbox.FindSet() then
            EmailInbox.DeleteAll();
    end;

    procedure EmailCountTest(var TempSOASetup: Record "SOA Setup" temporary)
    var
        EmailInbox: Record "Email Inbox";
        TempFilters: Record "Email Retrieval Filters" temporary;
        Email: Codeunit "Email";
        SOAEmailSetup: Codeunit "SOA Email Setup";
    begin
        TempFilters."Unread Emails" := true;
        TempFilters."Earliest Email" := TempSOASetup."Last Sync At";
        TempFilters."Max No. of Emails" := SOAEmailSetup.GetMaxNoOfEmails();

        Email.RetrieveEmails(TempSOASetup."Email Account ID", TempSOASetup."Email Connector", EmailInbox, TempFilters);
        EmailCount := EmailInbox.Count;

        // Delete all emails retrieved as they are not used.
        if EmailInbox.FindSet() then
            EmailInbox.DeleteAll();
    end;

    procedure GetEmailCount(): Integer
    begin
        exit(EmailCount);
    end;


    var
        TestEmailConnection: Boolean;
        TestEmailCount: Boolean;
        EmailCount: Integer;

}