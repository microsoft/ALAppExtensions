// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Finance.ReceivablesPayables;

using Microsoft.Bank.Reconciliation;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.Setup;
using Microsoft.Service.Document;
using Microsoft.Service.Setup;

codeunit 31034 "Posting Group Management CZL"
{
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Replaced by Posting Group Change codeunit.';

    var
        CannotChangePostingGroupErr: Label 'You cannot change the value %1 to %2 because %3 has not been filled in.', Comment = '%1 = old posting group; %2 = new posting group; %3 = tablecaption of Subst. Vendor/Customer Posting Group';

    [Obsolete('Replaced by ChangePostingGroup function in Posting Group Change codeunit.', '22.0')]
    procedure CheckPostingGroupChange(NewPostingGroup: Code[20]; OldPostingGroup: Code[20]; Variant: Variant)
    var
        SourceRecordRef: RecordRef;
        CustomerVendorNo: Code[20];
        CheckedPostingGroup: Option "None",Customer,CustomerInService,Vendor;
    begin
        if OldPostingGroup = NewPostingGroup then
            exit;

        SourceRecordRef.GetTable(Variant);
        case SourceRecordRef.Number of
            Database::"Sales Header":
                CheckPostingGroupChangeInSalesHeader(NewPostingGroup, OldPostingGroup);
            Database::"Purchase Header":
                CheckPostingGroupChangeInPurchaseHeader(NewPostingGroup, OldPostingGroup);
            Database::"Gen. Journal Line":
                CheckPostingGroupChangeInGenJnlLine(NewPostingGroup, OldPostingGroup, Variant);
            Database::"Finance Charge Memo Header":
                CheckPostingGroupChangeInFinChrgMemoHeader(NewPostingGroup, OldPostingGroup);
            Database::"Service Header":
                CheckPostingGroupChangeInServiceHeader(NewPostingGroup, OldPostingGroup);
            Database::"Bank Acc. Reconciliation Line":
                CheckPostingGroupChangeInBankAccReconLine(NewPostingGroup, OldPostingGroup, Variant);
            else begin
                OnCheckPostingGroupChange(NewPostingGroup, OldPostingGroup, SourceRecordRef, CheckedPostingGroup, CustomerVendorNo);
                case CheckedPostingGroup of
                    CheckedPostingGroup::Customer:
                        CheckCustomerPostingGroupChangeAndCustomer(NewPostingGroup, OldPostingGroup, CustomerVendorNo);
                    CheckedPostingGroup::CustomerInService:
                        CheckCustomerPostingGroupChangeAndCustomerInService(NewPostingGroup, OldPostingGroup, CustomerVendorNo);
                    CheckedPostingGroup::Vendor:
                        CheckVendorPostingGroupChangeAndVendor(NewPostingGroup, OldPostingGroup, CustomerVendorNo);
                    else
                        exit;
                end;
            end;
        end;
    end;

    local procedure CheckPostingGroupChangeInSalesHeader(NewPostingGroup: Code[20]; OldPostingGroup: Code[20])
    begin
        CheckCustomerPostingGroupChange(NewPostingGroup, OldPostingGroup);
    end;

    local procedure CheckPostingGroupChangeInPurchaseHeader(NewPostingGroup: Code[20]; OldPostingGroup: Code[20])
    begin
        CheckVendorPostingGroupChange(NewPostingGroup, OldPostingGroup);
    end;

    local procedure CheckPostingGroupChangeInGenJnlLine(NewPostingGroup: Code[20]; OldPostingGroup: Code[20]; GenJournalLine: Record "Gen. Journal Line")
    begin
        case GenJournalLine."Account Type" of
            GenJournalLine."Account Type"::Customer:
                CheckCustomerPostingGroupChangeAndCustomer(NewPostingGroup, OldPostingGroup, GenJournalLine."Account No.");
            GenJournalLine."Account Type"::Vendor:
                CheckVendorPostingGroupChangeAndVendor(NewPostingGroup, OldPostingGroup, GenJournalLine."Account No.");
            else
                GenJournalLine.FieldError(GenJournalLine."Account Type");
        end;
    end;

    local procedure CheckPostingGroupChangeInFinChrgMemoHeader(NewPostingGroup: Code[20]; OldPostingGroup: Code[20])
    begin
        CheckCustomerPostingGroupChange(NewPostingGroup, OldPostingGroup);
    end;

    local procedure CheckPostingGroupChangeInServiceHeader(NewPostingGroup: Code[20]; OldPostingGroup: Code[20])
    begin
        CheckCustomerPostingGroupChangeAndCustomerInService(NewPostingGroup, OldPostingGroup, '');
    end;

    local procedure CheckPostingGroupChangeInBankAccReconLine(NewPostingGroup: Code[20]; OldPostingGroup: Code[20]; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    begin
        case BankAccReconciliationLine."Account Type" of
            BankAccReconciliationLine."Account Type"::Customer:
                CheckCustomerPostingGroupChangeAndCustomer(NewPostingGroup, OldPostingGroup, BankAccReconciliationLine."Account No.");
            BankAccReconciliationLine."Account Type"::Vendor:
                CheckVendorPostingGroupChangeAndVendor(NewPostingGroup, OldPostingGroup, BankAccReconciliationLine."Account No.");
            else
                BankAccReconciliationLine.FieldError(BankAccReconciliationLine."Account Type");
        end;
    end;

    procedure CheckCustomerPostingGroupChange(NewPostingGroup: Code[20]; OldPostingGroup: Code[20])
    begin
        CheckCustomerPostingGroupChangeAndCustomer(NewPostingGroup, OldPostingGroup, '');
    end;

    procedure CheckVendorPostingGroupChange(NewPostingGroup: Code[20]; OldPostingGroup: Code[20])
    begin
        CheckVendorPostingGroupChangeAndVendor(NewPostingGroup, OldPostingGroup, '');
    end;

    procedure CheckCustomerPostingGroupChangeAndCustomer(NewPostingGroup: Code[20]; OldPostingGroup: Code[20]; CustomerNo: Code[20])
    begin
        CheckAllowChangeSalesSetup();
        if not HasCustomerSamePostingGroup(NewPostingGroup, CustomerNo) then
            CheckCustomerPostingGroupSubstSetup(NewPostingGroup, OldPostingGroup);
    end;

    procedure CheckCustomerPostingGroupChangeAndCustomerInService(NewPostingGroup: Code[20]; OldPostingGroup: Code[20]; CustomerNo: Code[20])
    begin
        CheckAllowChangeServiceSetup();
        if not HasCustomerSamePostingGroup(NewPostingGroup, CustomerNo) then
            CheckCustomerPostingGroupSubstSetup(NewPostingGroup, OldPostingGroup);
    end;

    procedure CheckVendorPostingGroupChangeAndVendor(NewPostingGroup: Code[20]; OldPostingGroup: Code[20]; VendorNo: Code[20])
    begin
        CheckAllowChangePurchaseSetup();
        if not HasVendorSamePostingGroup(NewPostingGroup, VendorNo) then
            CheckVendorPostingGroupSubstSetup(NewPostingGroup, OldPostingGroup);
    end;

    procedure CheckCustomerPostingGroupSubstSetup(NewPostingGroup: Code[20]; OldPostingGroup: Code[20])
    var
        SubstCustPostingGroupCZL: Record "Subst. Cust. Posting Group CZL";
    begin
        if not SubstCustPostingGroupCZL.Get(OldPostingGroup, NewPostingGroup) then
            Error(CannotChangePostingGroupErr, OldPostingGroup, NewPostingGroup, SubstCustPostingGroupCZL.TableCaption());
    end;

    procedure CheckVendorPostingGroupSubstSetup(NewPostingGroup: Code[20]; OldPostingGroup: Code[20])
    var
        SubstVendPostingGroupCZL: Record "Subst. Vend. Posting Group CZL";
    begin
        if not SubstVendPostingGroupCZL.Get(OldPostingGroup, NewPostingGroup) then
            Error(CannotChangePostingGroupErr, OldPostingGroup, NewPostingGroup, SubstVendPostingGroupCZL.TableCaption());
    end;

    procedure CheckAllowChangeSalesSetup()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.TestField("Allow Multiple Posting Groups");
    end;

    procedure CheckAllowChangeServiceSetup()
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
    begin
        ServiceMgtSetup.Get();
        ServiceMgtSetup.TestField("Allow Multiple Posting Groups");
    end;

    procedure CheckAllowChangePurchaseSetup()
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.TestField("Allow Multiple Posting Groups");
    end;

    procedure HasCustomerSamePostingGroup(NewPostingGroup: Code[20]; CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        if Customer.Get(CustomerNo) then
            exit(NewPostingGroup = Customer."Customer Posting Group");
        exit(false);
    end;

    procedure HasVendorSamePostingGroup(NewPostingGroup: Code[20]; VendorNo: Code[20]): Boolean
    var
        Vendor: Record Vendor;
    begin
        if Vendor.Get(VendorNo) then
            exit(NewPostingGroup = Vendor."Vendor Posting Group");
        exit(false);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPostingGroupChange(NewPostingGroup: Code[20]; OldPostingGroup: Code[20]; SourceRecordRef: RecordRef; var CheckedPostingGroup: Option "None",Customer,CustomerInService,Vendor; var CustomerVendorNo: Code[20])
    begin
    end;
}

#endif
