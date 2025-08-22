// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Integration.Entity;

#pragma warning disable AS0049
codeunit 4594 "SOA - KPI Track Agents"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    EventSubscriberInstance = Manual;
    Access = Internal;
#pragma warning restore AS0049

    [EventSubscriber(ObjectType::Table, Database::"Sales Quote Entity Buffer", 'OnAfterInsertEvent', '', false, false)]
    local procedure InsertSalesQuoteChanged(var Rec: Record "Sales Quote Entity Buffer")
    var
        SOAKPITrackAll: Codeunit "SOA - KPI Track All";
    begin
        SOAKPITrackAll.UpdateSalesQuoteBuffer(Rec, BlankSOAKPIEntry.Status::Active, false);
    end;

    var
        BlankSOAKPIEntry: Record "SOA KPI Entry";
}