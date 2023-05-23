// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8897 "Email Error Handler"
{
    Access = Internal;
    InherentPermissions = X;
    InherentEntitlements = X;
    TableNo = "Email Outbox";
    Permissions = tabledata "Email Outbox" = rimd;

    trigger OnRun()
    var
        Email: Codeunit Email;
    begin
        if IsNullGuid(Rec."Message Id") then
            exit;

        if Rec.Status <> Rec.Status::Failed then begin
            Rec.Status := Rec.Status::Failed;
            Rec.Modify();
            Commit();
        end;

        Email.OnAfterEmailSendFailed(Rec);
    end;
}
