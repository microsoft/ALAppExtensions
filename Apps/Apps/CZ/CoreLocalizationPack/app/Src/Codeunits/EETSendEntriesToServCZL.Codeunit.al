// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

codeunit 31119 "EET Send Entries To Serv. CZL"
{
    Permissions = tabledata "EET Entry CZL" = r;

    trigger OnRun()
    begin
        EETEntryCZL.SetCurrentKey(EETEntryCZL."Status");
        EETEntryCZL.SetFilterToSending();
        if EETEntryCZL.FindSet() then
            repeat
                OutgoingEETEntryCZL.Get(EETEntryCZL."Entry No.");
                OutgoingEETEntryCZL.Send(false);
            until EETEntryCZL.Next() = 0;
    end;

    var
        EETEntryCZL: Record "EET Entry CZL";
        OutgoingEETEntryCZL: Record "EET Entry CZL";
}
