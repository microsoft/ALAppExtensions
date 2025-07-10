// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Job;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Projects.Project.Journal;
using Microsoft.Projects.Project.Posting;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;

codeunit 6262 "Sust. Job Subscriber"
{

    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnCopyFromResourceOnAfterCheckResource', '', false, false)]
    local procedure OnCopyFromResourceOnAfterCheckResource(var JobJournalLine: Record "Job Journal Line"; Resource: Record Resource)
    begin
        if SustainabilitySetup.IsValueChainTrackingEnabled() then
            JobJournalLine.Validate("Sust. Account No.", Resource."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnCopyFromItemOnAfterCheckItem', '', false, false)]
    local procedure OnCopyFromItemOnAfterCheckItem(var JobJournalLine: Record "Job Journal Line"; Item: Record Item)
    begin
        if SustainabilitySetup.IsValueChainTrackingEnabled() then
            JobJournalLine.Validate("Sust. Account No.", Item."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnAfterAssignGLAccountValues', '', false, false)]
    local procedure OnAfterAssignGLAccountValues(var JobJournalLine: Record "Job Journal Line"; GLAccount: Record "G/L Account")
    begin
        if SustainabilitySetup.IsValueChainTrackingEnabled() then
            JobJournalLine.Validate("Sust. Account No.", GLAccount."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnAfterValidateEvent', Quantity, false, false)]
    local procedure OnAfterValidateQuantityEvent(var Rec: Record "Job Journal Line")
    begin
        Rec.UpdateSustainabilityEmission(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnAfterValidateEvent', "No.", false, false)]
    local procedure OnAfterValidateNoEvent(var Rec: Record "Job Journal Line")
    begin
        if Rec."No." = '' then
            Rec.Validate("Sust. Account No.", '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Jnl.-Post Line", 'OnPostItemOnBeforeAssignItemJnlLine', '', false, false)]
    local procedure OnPostItemJnlLineOnAfterPrepareItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; var JobJournalLine: Record "Job Journal Line")
    begin
        if (ItemJnlLine.Quantity <> 0) or (ItemJnlLine."Invoiced Quantity" <> 0) then
            UpdateSustainabilityItemJournalLine(ItemJnlLine, JobJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Transfer Line", 'OnAfterFromGenJnlLineToJnlLine', '', false, false)]
    local procedure OnAfterFromGenJnlLineToJnlLine(var JobJnlLine: Record "Job Journal Line"; GenJnlLine: Record "Gen. Journal Line")
    begin
        JobJnlLine."Sust. Account No." := GenJnlLine."Sust. Account No.";
        JobJnlLine."Sust. Account Name" := GenJnlLine."Sust. Account Name";
        JobJnlLine."Sust. Account Category" := GenJnlLine."Sust. Account Category";
        JobJnlLine."Sust. Account Subcategory" := GenJnlLine."Sust. Account Subcategory";
        JobJnlLine."CO2e per Unit" := GenJnlLine."CO2e per Unit";
        JobJnlLine."Total CO2e" := GenJnlLine."Total CO2e";
    end;

    local procedure UpdateSustainabilityItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; var JobJournalLine: Record "Job Journal Line")
    var
        GHGCredit: Boolean;
        Sign: Integer;
        CO2eToPost: Decimal;
    begin
        GHGCredit := JobJournalLine.IsGHGCreditLine();
        Sign := JobJournalLine.GetPostingSign(GHGCredit);

        if ItemJournalLine."Invoiced Quantity" <> 0 then
            CO2eToPost := JobJournalLine."CO2e per Unit" * Abs(ItemJournalLine."Invoiced Quantity") * JobJournalLine."Qty. per Unit of Measure"
        else
            CO2eToPost := JobJournalLine."CO2e per Unit" * Abs(ItemJournalLine.Quantity) * JobJournalLine."Qty. per Unit of Measure";

        CO2eToPost := CO2eToPost * Sign;

        if not CanPostSustainabilityJnlLine(JobJournalLine."Sust. Account No.", JobJournalLine."Sust. Account Category", JobJournalLine."Sust. Account Subcategory", CO2eToPost) then
            exit;

        ItemJournalLine."Sust. Account No." := JobJournalLine."Sust. Account No.";
        ItemJournalLine."Sust. Account Name" := JobJournalLine."Sust. Account Name";
        ItemJournalLine."Sust. Account Category" := JobJournalLine."Sust. Account Category";
        ItemJournalLine."Sust. Account Subcategory" := JobJournalLine."Sust. Account Subcategory";
        ItemJournalLine."CO2e per Unit" := JobJournalLine."CO2e per Unit";
        ItemJournalLine."Total CO2e" := CO2eToPost;
    end;

    local procedure CanPostSustainabilityJnlLine(AccountNo: Code[20]; AccountCategory: Code[20]; AccountSubCategory: Code[20]; CO2eToPost: Decimal): Boolean
    var
        SustAccountCategory: Record "Sustain. Account Category";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
    begin
        if AccountNo = '' then
            exit(false);

        if not SustainabilitySetup.IsValueChainTrackingEnabled() then
            exit(false);

        if SustAccountCategory.Get(AccountCategory) then
            if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
                Error(NotAllowedToPostSustEntryForWaterOrWasteErr, AccountNo);

        if SustainAccountSubcategory.Get(AccountCategory, AccountSubCategory) then
            if not SustainAccountSubcategory."Renewable Energy" then
                if (CO2eToPost = 0) then
                    Error(CO2eMustNotBeZeroErr);

        if (CO2eToPost <> 0) then
            exit(true);
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        CO2eMustNotBeZeroErr: Label 'The CO2e fields must have a value that is not 0.';
        NotAllowedToPostSustEntryForWaterOrWasteErr: Label 'It is not allowed to post Sustainability Entry for water or waste in Job Journal document for Account No. %1', Comment = '%1 = Sustainability Account No.';
}