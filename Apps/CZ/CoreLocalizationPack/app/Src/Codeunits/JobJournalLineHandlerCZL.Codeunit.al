// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Projects.Project.Journal;

#if not CLEAN22
using Microsoft.Inventory.Item;
#endif
using System.Security.User;

codeunit 31077 "Job Journal Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnBeforeValidateEvent', 'Entry Type', false, false)]
    local procedure InvtMovementTemplateOnBeforeValidateEntryType(var Rec: Record "Job Journal Line"; CurrFieldNo: Integer)
    begin
        if (Rec."Invt. Movement Template CZL" <> '') and (CurrFieldNo = Rec.FieldNo("Entry Type")) then
            Rec.TestField("Invt. Movement Template CZL", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnBeforeValidateEvent', 'Gen. Bus. Posting Group', false, false)]
    local procedure InvtMovementTemplateOnBeforeValidateGenBusPostingGroup(var Rec: Record "Job Journal Line"; CurrFieldNo: Integer)
    begin
        if (Rec."Invt. Movement Template CZL" <> '') and (CurrFieldNo = Rec.FieldNo("Gen. Bus. Posting Group")) then
            Rec.TestField("Invt. Movement Template CZL", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnAfterSetupNewLine', '', false, false)]
    local procedure InvtMovementTemplateOnAfterSetupNewLine(var JobJournalLine: Record "Job Journal Line"; LastJobJournalLine: Record "Job Journal Line")
    begin
        JobJournalLine.Validate("Invt. Movement Template CZL", LastJobJournalLine."Invt. Movement Template CZL");
    end;
#if not CLEAN22
#pragma warning disable AL0432

    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure CopyFromItemOnAfterAssignItemValues(var JobJournalLine: Record "Job Journal Line"; Item: Record Item)
    begin
        JobJournalLine."Tariff No. CZL" := Item."Tariff No.";
        JobJournalLine."Statistic Indication CZL" := Item."Statistic Indication CZL";
        JobJournalLine."Net Weight CZL" := Item."Net Weight";
        JobJournalLine."Country/Reg. of Orig. Code CZL" := Item."Country/Region of Origin Code";
    end;
#pragma warning restore AL0432
#endif

    [EventSubscriber(ObjectType::Codeunit, Codeunit::JobJnlManagement, 'OnBeforeOpenJnl', '', false, false)]
    local procedure JournalTemplateUserRestrictionsOnBeforeOpenJnl(var JobJournalLine: Record "Job Journal Line")
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
        UserSetupLineTypeCZL: Enum "User Setup Line Type CZL";
        JournalTemplateName: Code[10];
    begin
        JournalTemplateName := JobJournalLine.GetRangeMax("Journal Template Name");
        UserSetupLineTypeCZL := UserSetupLineTypeCZL::"Job Journal";
        UserSetupAdvManagementCZL.CheckJournalTemplate(UserSetupLineTypeCZL, JournalTemplateName);
    end;
}
