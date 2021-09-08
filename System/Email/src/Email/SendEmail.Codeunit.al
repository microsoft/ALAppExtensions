// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8890 "Send Email"
{
    Access = Internal;
    TableNo = "Email Message";

    trigger OnRun()
    var
        EmailMessage: Codeunit "Email Message";
    begin
        EmailMessage.Get(Rec.Id);
        EmailConnector.Send(EmailMessage, AccountId);
    end;

    procedure SetConnector(NewEmailConnector: Interface "Email Connector")
    begin
        EmailConnector := NewEmailConnector;
    end;

    procedure SetAccount(NewAccountId: Guid)
    begin
        AccountId := NewAccountId;
    end;

    var
        EmailConnector: Interface "Email Connector";
        AccountId: Guid;
}