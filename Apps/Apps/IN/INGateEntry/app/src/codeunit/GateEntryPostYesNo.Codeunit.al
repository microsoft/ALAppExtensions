// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

codeunit 18603 "Gate Entry- Post (Yes/No)"
{
    TableNo = "Gate Entry Header";
    trigger OnRun()
    begin
        GateEntryHeader.Copy(Rec);
        Code();
        Rec := GateEntryHeader;
    end;

    var
        GateEntryHeader: Record "Gate Entry Header";
        GateEntryPost: Codeunit "Gate Entry Post";
        SuccessfullyLbl: Label 'Gate Entry Posted successfully.';
        ConfirmPostLbl: Label 'Do you want to Post the Gate Entry?';

    local procedure Code()
    begin
        if not Confirm(ConfirmPostLbl, false) then
            exit;
        GateEntryPost.Run(GateEntryHeader);
        Message(SuccessfullyLbl);
    end;
}
