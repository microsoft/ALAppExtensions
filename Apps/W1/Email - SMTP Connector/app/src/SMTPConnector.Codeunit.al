// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The e-mail connector for the SMTP protocol.
/// </summary>
codeunit 4512 "SMTP Connector"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeAddFrom(var FromName: Text; var FromAddress: Text)
    begin
    end;
}