#if not CLEAN20
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The e-mail connector for the SMTP protocol.
/// </summary>
codeunit 4512 "SMTP Connector"
{
    ObsoleteReason = 'Event has moved to SMTP API app, SMTP Message codeunit.';
    ObsoleteState = Pending;
    ObsoleteTag = '20.0';
    Access = Public;

    [Obsolete('Moved to SMTP API app, SMTP Message codeunit.', '20.0')]
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeAddFrom(var FromName: Text; var FromAddress: Text)
    begin
    end;
}
#endif