// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.PayablesAgent;

using Microsoft.EServices.EDocumentConnector.Microsoft365;
using System.Email;

codeunit 3310 "PA Validate Setup"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Email Inbox" = rid;

    var
        OutlookSetup: Record "Outlook Setup";

    procedure SetOutlookSetup(NewOutlookSetup: Record "Outlook Setup")
    begin
        OutlookSetup := NewOutlookSetup;
    end;

    trigger OnRun()
    var
        TempEmailInbox: Record "Email Inbox" temporary;
        TempFilters: Record "Email Retrieval Filters" temporary;
        Email: Codeunit "Email";
    begin
        TempFilters."Unread Emails" := true;
        TempFilters."Earliest Email" := OutlookSetup."Last Sync At";
        TempFilters."Max No. of Emails" := 1;
        Email.RetrieveEmails(OutlookSetup."Email Account ID", OutlookSetup."Email Connector", TempEmailInbox, TempFilters);
    end;

}