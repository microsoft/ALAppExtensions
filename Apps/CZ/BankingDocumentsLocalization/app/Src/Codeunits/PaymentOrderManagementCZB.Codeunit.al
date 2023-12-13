// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank;
using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using System.Security.User;
using System.Utilities;

codeunit 31356 "Payment Order Management CZB"
{
    Permissions = tabledata "Iss. Payment Order Header CZB" = rm;

    var
        TempErrorMessage: Record "Error Message" temporary;
        BankOperationsFunctionsCZB: Codeunit "Bank Operations Functions CZB";
        BankOperationsFunctionsCZL: Codeunit "Bank Operations Functions CZL";
        ConfirmManagement: Codeunit "Confirm Management";
        ErrorMessageLogSuspended: Boolean;

    procedure PaymentOrderSelection(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB"; var SelectedBankAccountForPaymentOrder: Boolean)
    var
        BankAccount: Record "Bank Account";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePaymentOrderSelection(PaymentOrderHeaderCZB, SelectedBankAccountForPaymentOrder, IsHandled);
        if IsHandled then
            exit;

        BankAccount.SetRange(Blocked, false);
        SelectedBankAccountForPaymentOrder := SelectBankAccount(BankAccount);
        if SelectedBankAccountForPaymentOrder then begin
            CheckBankAccessAllowed(BankAccount."No.");
            PaymentOrderHeaderCZB.FilterGroup := 2;
            PaymentOrderHeaderCZB.SetRange("Bank Account No.", BankAccount."No.");
            PaymentOrderHeaderCZB.FilterGroup := 0;
        end;
    end;

    procedure IssuedPaymentOrderSelection(var IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB"; var SelectedBankAccountForPaymentOrder: Boolean)
    var
        BankAccount: Record "Bank Account";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeIssuedPaymentOrderSelection(IssPaymentOrderHeaderCZB, SelectedBankAccountForPaymentOrder, IsHandled);
        if IsHandled then
            exit;

        SelectedBankAccountForPaymentOrder := SelectBankAccount(BankAccount);
        if SelectedBankAccountForPaymentOrder then begin
            CheckBankAccessAllowed(BankAccount."No.");
            IssPaymentOrderHeaderCZB.FilterGroup := 2;
            IssPaymentOrderHeaderCZB.SetRange("Bank Account No.", BankAccount."No.");
            IssPaymentOrderHeaderCZB.FilterGroup := 0;
        end;
    end;

    local procedure SelectBankAccount(var BankAccount: Record "Bank Account") IsSelected: Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSelectBankAccount(BankAccount, IsSelected, IsHandled);
        if IsHandled then
            exit;

        case BankAccount.Count() of
            0:
                exit(false);
            1:
                begin
                    BankAccount.FindFirst();
                    exit(true);
                end;
            else
                exit(Page.RunModal(Page::"Bank Account List", BankAccount) = Action::LookupOK);
        end;
    end;

    procedure CheckPaymentOrderLineFormat(PaymentOrderLineCZB: Record "Payment Order Line CZB"; ShowErrorMessages: Boolean): Boolean
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        TempErrorMessage2: Record "Error Message" temporary;
        IsHandled: Boolean;
        MustBeSpecifiedErr: Label '%1 or %2 in %3 must be specified.', Comment = '%1 = Account No. FieldCaption; %2 = IBAN FieldCaption; %3 = RecordId';
    begin
        IsHandled := false;
        OnBeforeCheckPaymentOrderLineFormat(PaymentOrderLineCZB, ShowErrorMessages, TempErrorMessage2, IsHandled);
        if not IsHandled then begin
            TempErrorMessage2.LogIfEqualTo(
                PaymentOrderLineCZB, PaymentOrderLineCZB.FieldNo(PaymentOrderLineCZB."Amount Must Be Checked"), TempErrorMessage2."Message Type"::Error, true);
            TempErrorMessage2.LogIfEmpty(
                PaymentOrderLineCZB, PaymentOrderLineCZB.FieldNo(PaymentOrderLineCZB.Amount), TempErrorMessage2."Message Type"::Error);
            TempErrorMessage2.LogIfLessThan(
                PaymentOrderLineCZB, PaymentOrderLineCZB.FieldNo(PaymentOrderLineCZB.Amount), TempErrorMessage2."Message Type"::Error, 0);
            TempErrorMessage2.LogIfEmpty(
                PaymentOrderLineCZB, PaymentOrderLineCZB.FieldNo(PaymentOrderLineCZB."Due Date"), TempErrorMessage2."Message Type"::Error);
            PaymentOrderHeaderCZB.Get(PaymentOrderLineCZB."Payment Order No.");
            if not PaymentOrderHeaderCZB."Foreign Payment Order" then
                TempErrorMessage2.LogIfEmpty(
                    PaymentOrderLineCZB, PaymentOrderLineCZB.FieldNo(PaymentOrderLineCZB."Variable Symbol"), TempErrorMessage2."Message Type"::Error);
            TempErrorMessage2.LogIfInvalidCharacters(
                PaymentOrderLineCZB, PaymentOrderLineCZB.FieldNo(PaymentOrderLineCZB."Variable Symbol"), TempErrorMessage2."Message Type"::Error,
                BankOperationsFunctionsCZB.GetValidCharactersForVariableSymbol());
            TempErrorMessage2.LogIfInvalidCharacters(
                PaymentOrderLineCZB, PaymentOrderLineCZB.FieldNo(PaymentOrderLineCZB."Constant Symbol"), TempErrorMessage2."Message Type"::Error,
                BankOperationsFunctionsCZB.GetValidCharactersForConstantSymbol());
            TempErrorMessage2.LogIfInvalidCharacters(
                PaymentOrderLineCZB, PaymentOrderLineCZB.FieldNo(PaymentOrderLineCZB."Specific Symbol"), TempErrorMessage2."Message Type"::Error,
                BankOperationsFunctionsCZB.GetValidCharactersForSpecificSymbol());
            if (PaymentOrderLineCZB."Account No." = '') and (PaymentOrderLineCZB.IBAN = '') then
                TempErrorMessage2.LogMessage(
                    PaymentOrderLineCZB, 0, TempErrorMessage2."Message Type"::Error,
                    StrSubstNo(MustBeSpecifiedErr, PaymentOrderLineCZB.FieldCaption(PaymentOrderLineCZB."Account No."), PaymentOrderLineCZB.FieldCaption(PaymentOrderLineCZB.IBAN), PaymentOrderLineCZB.RecordId));
        end;

        SaveErrorMessage(TempErrorMessage2);
        exit(not HasErrorMessages(TempErrorMessage2, ShowErrorMessages));
    end;

    procedure CheckPaymentOrderLineBankAccountNo(PaymentOrderLineCZB: Record "Payment Order Line CZB"; ShowErrorMessages: Boolean): Boolean
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        BankAccount: Record "Bank Account";
        TempErrorMessage2: Record "Error Message" temporary;
        IsHandled: Boolean;
        AccountNoMalformedErr: Label '%1 %2 in %3 is malformed.', Comment = '%1 = Account No. FieldCaption; %2 = Account No.; %3 = RecordId';
    begin
        IsHandled := false;
        OnBeforeCheckPaymentOrderLineBankAccountNo(PaymentOrderLineCZB, ShowErrorMessages, TempErrorMessage2, IsHandled);
        if not IsHandled then begin
            PaymentOrderHeaderCZB.Get(PaymentOrderLineCZB."Payment Order No.");
            BankAccount.Get(PaymentOrderHeaderCZB."Bank Account No.");

            if not BankAccount."Check CZ Format on Issue CZB" or PaymentOrderHeaderCZB."Foreign Payment Order" then
                exit(true);

            TempErrorMessage2.LogIfInvalidCharacters(
                PaymentOrderLineCZB, PaymentOrderLineCZB.FieldNo(PaymentOrderLineCZB."Account No."), TempErrorMessage2."Message Type"::Error,
                BankOperationsFunctionsCZL.GetValidCharactersForBankAccountNo());
            if not BankOperationsFunctionsCZL.CheckBankAccountNo(PaymentOrderLineCZB."Account No.", false) then
                TempErrorMessage2.LogMessage(
                    PaymentOrderLineCZB, PaymentOrderLineCZB.FieldNo(PaymentOrderLineCZB."Account No."), TempErrorMessage2."Message Type"::Error,
                    StrSubstNo(AccountNoMalformedErr, PaymentOrderLineCZB.FieldCaption(PaymentOrderLineCZB."Account No."), PaymentOrderLineCZB."Account No.", PaymentOrderLineCZB.RecordId));
        end;

        SaveErrorMessage(TempErrorMessage2);
        exit(not HasErrorMessages(TempErrorMessage2, ShowErrorMessages));
    end;

    procedure CheckPaymentOrderLineCustVendBlocked(PaymentOrderLineCZB: Record "Payment Order Line CZB"; ShowErrorMessages: Boolean): Boolean
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        TempErrorMessage2: Record "Error Message" temporary;
        IsHandled: Boolean;
        CustVendBlockedErr: Label '%1 %2 in %3 is blocked.', Comment = '%1 = TableCaption; %2 = No.; %3 = RecordId';
        PrivacyBlockedErr: Label '%1 %2 in %3 is blocked for privacy.', Comment = '%1 = TableCaption; %2 = No.; %3 = RecordId';
    begin
        IsHandled := false;
        OnBeforeCheckPaymentOrderLineCustVendBlocked(PaymentOrderLineCZB, ShowErrorMessages, TempErrorMessage2, IsHandled);
        if not IsHandled then
            case PaymentOrderLineCZB.Type of
                PaymentOrderLineCZB.Type::Customer:
                    begin
                        Customer.Get(PaymentOrderLineCZB."No.");
                        if Customer."Privacy Blocked" then
                            TempErrorMessage2.LogMessage(
                                PaymentOrderLineCZB, PaymentOrderLineCZB.FieldNo(PaymentOrderLineCZB."No."), TempErrorMessage2."Message Type"::Warning,
                                StrSubstNo(PrivacyBlockedErr, Customer.TableCaption, Customer."No.", PaymentOrderLineCZB.RecordId));

                        if Customer.Blocked in [Customer.Blocked::All] then
                            TempErrorMessage2.LogMessage(
                                PaymentOrderLineCZB, PaymentOrderLineCZB.FieldNo(PaymentOrderLineCZB."No."), TempErrorMessage2."Message Type"::Warning,
                                StrSubstNo(CustVendBlockedErr, Customer.TableCaption, Customer."No.", PaymentOrderLineCZB.RecordId));
                    end;
                PaymentOrderLineCZB.Type::Vendor:
                    begin
                        Vendor.Get(PaymentOrderLineCZB."No.");
                        if Vendor."Privacy Blocked" then
                            TempErrorMessage2.LogMessage(
                                PaymentOrderLineCZB, PaymentOrderLineCZB.FieldNo(PaymentOrderLineCZB."No."), TempErrorMessage2."Message Type"::Warning,
                                StrSubstNo(PrivacyBlockedErr, Vendor.TableCaption, Vendor."No.", PaymentOrderLineCZB.RecordId));

                        if Vendor.Blocked in [Vendor.Blocked::All] then
                            TempErrorMessage2.LogMessage(
                                PaymentOrderLineCZB, PaymentOrderLineCZB.FieldNo(PaymentOrderLineCZB."No."), TempErrorMessage2."Message Type"::Warning,
                                StrSubstNo(CustVendBlockedErr, Vendor.TableCaption, Vendor."No.", PaymentOrderLineCZB.RecordId));
                    end;
            end;

        SaveErrorMessage(TempErrorMessage2);
        exit(not HasErrorMessages(TempErrorMessage2, ShowErrorMessages));
    end;

    procedure CheckPaymentOrderLineApply(PaymentOrderLineCZB: Record "Payment Order Line CZB"; ShowErrorMessages: Boolean): Boolean
    var
        TempErrorMessage2: Record "Error Message" temporary;
        ErrorMessageID: Integer;
        TempErrorMessageLogSuspended: Boolean;
    begin
        TempErrorMessage.Reset();
        if TempErrorMessage.FindLast() then
            ErrorMessageID := TempErrorMessage.ID;

        TempErrorMessageLogSuspended := ErrorMessageLogSuspended;
        ErrorMessageLogSuspended := false;

        CheckPaymentOrderLineApplyToOtherEntries(PaymentOrderLineCZB, false);

        ErrorMessageLogSuspended := TempErrorMessageLogSuspended;

        TempErrorMessage.Reset();
        TempErrorMessage.SetFilter(ID, '%1..', ErrorMessageID + 1);
        TempErrorMessage.CopyToTemp(TempErrorMessage2);

        if ErrorMessageLogSuspended then
            TempErrorMessage.DeleteAll(true);

        exit(not HasErrorMessages(TempErrorMessage2, ShowErrorMessages))
    end;

    procedure CheckPaymentOrderLineCustom(PaymentOrderLineCZB: Record "Payment Order Line CZB"; ShowErrorMessages: Boolean): Boolean
    var
        TempErrorMessage2: Record "Error Message" temporary;
    begin
        OnCheckPaymentOrderLineCustom(PaymentOrderLineCZB, ShowErrorMessages, TempErrorMessage2);

        SaveErrorMessage(TempErrorMessage2);
        exit(not HasErrorMessages(TempErrorMessage2, ShowErrorMessages))
    end;

    local procedure CheckPaymentOrderLineApplyToOtherEntries(PaymentOrderLineCZB: Record "Payment Order Line CZB"; ShowErrorMessages: Boolean): Boolean
    var
        TempErrorMessage2: Record "Error Message" temporary;
        IsHandled: Boolean;
        SuggestedAmountToApplyErr: Label '%1 Ledger Entry No. %2 is suggested to application on other documents in the system.', Comment = '%1 = Type, %2 = Applies-to C/V/E Entry No.';
    begin
        IsHandled := false;
        OnBeforeCheckPaymentOrderLineApplyToOtherEntries(PaymentOrderLineCZB, ShowErrorMessages, TempErrorMessage2, IsHandled);
        if not IsHandled then begin
            if not IsLedgerEntryApplied(PaymentOrderLineCZB) then
                exit;

            TempErrorMessage2.LogMessage(
                PaymentOrderLineCZB, PaymentOrderLineCZB.FieldNo("Applies-to C/V/E Entry No."), TempErrorMessage2."Message Type"::Warning,
                StrSubstNo(
                    SuggestedAmountToApplyErr,
                    PaymentOrderLineCZB.FieldCaption(PaymentOrderLineCZB."Applies-to C/V/E Entry No."), PaymentOrderLineCZB."Applies-to C/V/E Entry No.", PaymentOrderLineCZB.RecordId()));
        end;

        SaveErrorMessage(TempErrorMessage2);
        exit(not HasErrorMessages(TempErrorMessage2, ShowErrorMessages));
    end;

    local procedure IsLedgerEntryApplied(PaymentOrderLineCZB: Record "Payment Order Line CZB"): Boolean
    var
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
        PaymentOrderLineCZB2: Record "Payment Order Line CZB";
    begin
        if PaymentOrderLineCZB."Applies-to C/V/E Entry No." = 0 then
            exit(false);

        IssPaymentOrderLineCZB.SetRange(Type, PaymentOrderLineCZB.Type);
        IssPaymentOrderLineCZB.SetRange("No.", PaymentOrderLineCZB."No.");
        IssPaymentOrderLineCZB.SetRange("Applies-to C/V/E Entry No.", PaymentOrderLineCZB."Applies-to C/V/E Entry No.");
        IssPaymentOrderLineCZB.SetFilter(Status, '<>%1', IssPaymentOrderLineCZB.Status::Canceled);
        if not IssPaymentOrderLineCZB.IsEmpty() then
            exit(true);

        PaymentOrderLineCZB2.SetRange(Type, PaymentOrderLineCZB.Type);
        PaymentOrderLineCZB2.SetRange("No.", PaymentOrderLineCZB."No.");
        PaymentOrderLineCZB2.SetRange("Applies-to C/V/E Entry No.", PaymentOrderLineCZB."Applies-to C/V/E Entry No.");
        PaymentOrderLineCZB2.SetFilter("Payment Order No.", '<>%1', PaymentOrderLineCZB."Payment Order No.");
        if not PaymentOrderLineCZB2.IsEmpty() then
            exit(true);

        PaymentOrderLineCZB2.SetRange("Payment Order No.", PaymentOrderLineCZB."Payment Order No.");
        PaymentOrderLineCZB2.SetFilter("Line No.", '<>%1', PaymentOrderLineCZB."Line No.");
        if not PaymentOrderLineCZB2.IsEmpty() then
            exit(true);
    end;

    local procedure HasErrorMessages(var TempErrorMessage2: Record "Error Message" temporary; ShowErrorMessages: Boolean): Boolean
    var
        HasMessages: Boolean;
    begin
        HasMessages := TempErrorMessage2.ErrorMessageCount(TempErrorMessage2."Message Type"::Information) > 0;
        TempErrorMessage2.HasErrors(ShowErrorMessages);
        if ShowErrorMessages then
            TempErrorMessage2.ShowErrorMessages(true);

        exit(HasMessages);
    end;

    local procedure SaveErrorMessage(var TempErrorMessage2: Record "Error Message" temporary)
    begin
        if ErrorMessageLogSuspended then
            exit;

        TempErrorMessage2.Reset();
        TempErrorMessage2.CopyToTemp(TempErrorMessage);
    end;

    procedure CopyErrorMessageToTemp(var TempErrorMessage2: Record "Error Message" temporary)
    begin
        TempErrorMessage.Reset();
        TempErrorMessage.CopyToTemp(TempErrorMessage2);
    end;

    procedure ClearErrorMessageLog()
    begin
        TempErrorMessage.ClearLog();
    end;

    procedure SuspendErrorMessageLog(NewErrorMessageLogSuspended: Boolean)
    begin
        ErrorMessageLogSuspended := NewErrorMessageLogSuspended;
    end;

    procedure ProcessErrorMessages(ShowMessage: Boolean; RollBackOnError: Boolean)
    var
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
        IsHandled: Boolean;
        TwoPlaceholdersTok: Label '%1\\%2', Locked = true;
        ContinueQst: Label 'Do you want to continue?';
    begin
        IsHandled := false;
        OnBeforeProcessErrorMessages(TempErrorMessage, ShowMessage, RollBackOnError, IsHandled);
        if IsHandled then
            exit;

        if TempErrorMessage.HasErrors(ShowMessage) then
            TempErrorMessage.ShowErrorMessages(RollBackOnError);

        TempErrorMessage.Reset();
        TempErrorMessage.SetRange("Message Type", TempErrorMessage."Message Type"::Warning);
        TempErrorMessage.SetFilter("Field Number", '%1', PaymentOrderLineCZB.FieldNo("Applies-to C/V/E Entry No."));
        if TempErrorMessage.FindSet() then
            repeat
                if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(TwoPlaceholdersTok, TempErrorMessage."Message", ContinueQst), false) then
                    Error('');
            until TempErrorMessage.Next() = 0;
    end;

    local procedure CheckBankAccessAllowed(BankAccountNo: Code[20])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        UserSetupAdvManagementCZB: Codeunit "User Setup Adv. Management CZB";
        UserSetupLineTypeCZL: Enum "User Setup Line Type CZL";
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."User Checks Allowed CZL" then
            UserSetupAdvManagementCZB.CheckBankAccountNo(UserSetupLineTypeCZL::"Payment Order", BankAccountNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePaymentOrderSelection(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB"; var BankSelected: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIssuedPaymentOrderSelection(var IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB"; var BankSelected: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckPaymentOrderLineFormat(var PaymentOrderLineCZB: Record "Payment Order Line CZB"; var ShowErrorMessages: Boolean; var TempErrorMessage: Record "Error Message" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckPaymentOrderLineBankAccountNo(var PaymentOrderLineCZB: Record "Payment Order Line CZB"; var ShowErrorMessages: Boolean; var TempErrorMessage: Record "Error Message" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckPaymentOrderLineCustVendBlocked(var PaymentOrderLineCZB: Record "Payment Order Line CZB"; var ShowErrorMessages: Boolean; var TempErrorMessage: Record "Error Message" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckPaymentOrderLineApplyToOtherEntries(var PaymentOrderLineCZB: Record "Payment Order Line CZB"; var ShowErrorMessages: Boolean; var TempErrorMessage: Record "Error Message" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPaymentOrderLineCustom(var PaymentOrderLineCZB: Record "Payment Order Line CZB"; var ShowErrorMessages: Boolean; var TempErrorMessage: Record "Error Message" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessErrorMessages(var TempErrorMessage: Record "Error Message" temporary; var ShowMessage: Boolean; var RollBackOnError: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSelectBankAccount(var BankAccount: Record "Bank Account"; var IsSelected: Boolean; var IsHandled: Boolean)
    begin
    end;
}
