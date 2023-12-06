// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.AuditCodes;

codeunit 31368 "Source Code Setup Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Source Code Setup", 'OnAfterValidateEvent', 'Close Income Statement', false, false)]
    local procedure TestUsedOnAfterValidateCloseIncomeStatement(var Rec: Record "Source Code Setup")
    begin
        if Rec."Close Income Statement" = '' then
            exit;
        Rec.ThrowErrorIfUsedCZL(Rec.FieldNo("Close Income Statement"), Rec.FieldNo("Close Balance Sheet CZL"));
        Rec.ThrowErrorIfUsedCZL(Rec.FieldNo("Close Income Statement"), Rec.FieldNo("Open Balance Sheet CZL"));
    end;
}
