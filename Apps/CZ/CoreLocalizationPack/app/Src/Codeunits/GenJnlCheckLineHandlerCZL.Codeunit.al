// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.VAT.Setup;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Enums;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using System.Security.User;

codeunit 31316 "Gen.Jnl.Check Line Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure UserChecksAllowedOnAfterCheckGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
    begin
        if UserSetupAdvManagementCZL.IsCheckAllowed() and (not GenJournalLine."From Adjustment CZL") then
            UserSetupAdvManagementCZL.CheckGeneralJournalLine(GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnAfterCheckAccountNo', '', false, false)]
    local procedure CheckPrepaymentApplicationMethodOnAfterCheckAccountNo(var GenJournalLine: Record "Gen. Journal Line")
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        if (not GenJournalLine.Prepayment) or (GenJournalLine."Account No." = '') then
            exit;

        case GenJournalLine."Account Type" of
            GenJournalLine."Account Type"::Customer:
                begin
                    Customer.Get(GenJournalLine."Account No.");
                    Customer.TestField("Application Method", Customer."Application Method"::Manual, ErrorInfo.Create());
                end;
            GenJournalLine."Account Type"::Vendor:
                begin
                    Vendor.Get(GenJournalLine."Account No.");
                    Vendor.TestField("Application Method", Vendor."Application Method"::Manual, ErrorInfo.Create());
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnAfterCheckBalAccountNo', '', false, false)]
    local procedure CheckPrepaymentApplicationMethodOnAfterCheckBalAccountNo(var GenJournalLine: Record "Gen. Journal Line")
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        if (not GenJournalLine.Prepayment) or (GenJournalLine."Bal. Account No." = '') then
            exit;

        case GenJournalLine."Bal. Account Type" of
            GenJournalLine."Bal. Account Type"::Customer:
                begin
                    Customer.Get(GenJournalLine."Bal. Account No.");
                    Customer.TestField("Application Method", Customer."Application Method"::Manual, ErrorInfo.Create());
                end;
            GenJournalLine."Bal. Account Type"::Vendor:
                begin
                    Vendor.Get(GenJournalLine."Bal. Account No.");
                    Vendor.TestField("Application Method", Vendor."Application Method"::Manual, ErrorInfo.Create());
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnCheckDimensionsOnAfterAssignDimTableIDs', '', false, false)]
    local procedure IsCheckDimensionsEnabledOnCheckDimensionsOnAfterAssignDimTableIDs(var GenJournalLine: Record "Gen. Journal Line"; var CheckDone: Boolean)
    begin
        CheckDone := not GenJournalLine.IsCheckDimensionsEnabledCZL();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnBeforeRunCheck', '', false, false)]
    local procedure CheckVatDateOnBeforeRunCheck(var GenJournalLine: Record "Gen. Journal Line")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        if not GenJournalLine.IsReplaceVATDateEnabled() then begin
            if GenJournalLine."VAT Date CZL" = 0D then
                GenJournalLine.Validate("VAT Date CZL", GenJournalLine."Posting Date");
            exit;
        end;
#pragma warning restore AL0432
#endif
        if GenJournalLine."VAT Reporting Date" = 0D then
            GenJournalLine.Validate("VAT Reporting Date", GenJournalLine."Posting Date");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure CheckVatDateOnAfterCheckGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        VATPostingSetup: Record "VAT Posting Setup";
        VATDateHandlerCZL: Codeunit "VAT Date Handler CZL";
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
        VATDateNeeded: Boolean;
        MustBeLessOrEqualErr: Label 'must be less or equal to %1', Comment = '%1 = fieldcaption of VAT Date CZL';
    begin
        if VATReportingDateMgt.IsVATDateEnabled() then begin
            VATDateNeeded := false;
            if GenJournalLine."Gen. Posting Type" <> Enum::"General Posting Type"::" " then
                if VATPostingSetup.Get(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group") then
                    VATDateNeeded := true;
            if GenJournalLine."Bal. Gen. Posting Type" <> Enum::"General Posting Type"::" " then
                if VATPostingSetup.Get(GenJournalLine."Bal. VAT Bus. Posting Group", GenJournalLine."Bal. VAT Prod. Posting Group") then
                    VATDateNeeded := true;
            if VATDateNeeded then
                VATDateHandlerCZL.CheckVATDateCZL(GenJournalLine);
            if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) and
               (GenJournalLine."Document Type" in [GenJournalLine."Document Type"::"Credit Memo", GenJournalLine."Document Type"::Invoice])
            then
                GenJournalLine.TestField("Original Doc. VAT Date CZL");
#if not CLEAN22
#pragma warning disable AL0432
            if not GenJournalLine.IsReplaceVATDateEnabled() then
                if GenJournalLine."Original Doc. VAT Date CZL" > GenJournalLine."VAT Date CZL" then
                    GenJournalLine.FieldError("Original Doc. VAT Date CZL", StrSubstNo(MustBeLessOrEqualErr, GenJournalLine.FieldCaption(GenJournalLine."VAT Date CZL")));
            if GenJournalLine.IsReplaceVATDateEnabled() then
#pragma warning restore AL0432
#endif
                if GenJournalLine."Original Doc. VAT Date CZL" > GenJournalLine."VAT Reporting Date" then
                    GenJournalLine.FieldError("Original Doc. VAT Date CZL", StrSubstNo(MustBeLessOrEqualErr, GenJournalLine.FieldCaption(GenJournalLine."VAT Reporting Date")));
        end;
        if GenJournalLine."Original Doc. Partner Type CZL" <> GenJournalLine."Original Doc. Partner Type CZL"::" " then begin
            GenJournalLine.TestField("Account Type", GenJournalLine."Account Type"::"G/L Account".AsInteger());
            GenJournalLine.TestField("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account".AsInteger());
            GenJournalLine.TestField("Original Doc. Partner No. CZL");
            case GenJournalLine."Gen. Posting Type" of
                GenJournalLine."Gen. Posting Type"::Sale:
                    GenJournalLine.TestField("Original Doc. Partner Type CZL", GenJournalLine."Original Doc. Partner Type CZL"::Customer);
                GenJournalLine."Gen. Posting Type"::Purchase:
                    GenJournalLine.TestField("Original Doc. Partner Type CZL", GenJournalLine."Original Doc. Partner Type CZL"::Vendor);
            end;
        end;
    end;
}
