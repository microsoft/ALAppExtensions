#if not CLEAN27
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

codeunit 4583 "SO Agent"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    ObsoleteReason = 'This codeunit is no longer used.';
    ObsoleteState = Pending;
    ObsoleteTag = '27.0';

    /// <summary>
    /// Limit cannot be greater than 100
    /// </summary>
    /// <param name="Limit">Limit of the number of emails that can be processed in 24 hours</param>
    [IntegrationEvent(false, false)]
    [Obsolete('This event is no longer used. There is no limit on the number of emails that can be processed in 24 hours.', '27.0')]
    internal procedure OnGetEmailProcessLimitPer24Hours(var limit: Integer)
    begin
    end;
}
#endif