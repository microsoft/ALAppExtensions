codeunit 31353 "Issue Payment Order CZB"
{
    Permissions = tabledata "Iss. Payment Order Header CZB" = im,
                  tabledata "Iss. Payment Order Line CZB" = im;
    TableNo = "Payment Order Header CZB";

    trigger OnRun()
    begin
        PaymentOrderHeaderCZB.Copy(Rec);
        Code();
        Rec := PaymentOrderHeaderCZB;
    end;

    var
        BankAccount: Record "Bank Account";
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        PaymentOrderManagementCZB: Codeunit "Payment Order Management CZB";
        NothingtoIssueErr: Label 'There is nothing to issue.';
#if not CLEAN19
        DuplicityFoundErr: Label '%1 %2 was found. Resolve this before issue banking document.', Comment = '%1 = TableCaption, %2 = No.';
#endif

    local procedure Code()
    var
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
        User: Record User;
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        OnBeforeIssuePaymentOrder(PaymentOrderHeaderCZB);
        PaymentOrderHeaderCZB.CheckPaymentOrderIssueRestrictions();

        PaymentOrderHeaderCZB.TestField("Bank Account No.");
        PaymentOrderHeaderCZB.TestField("Document Date");
        BankAccount.Get(PaymentOrderHeaderCZB."Bank Account No.");
        BankAccount.TestField(Blocked, false);

        SetPaymentOrderLineFilters(PaymentOrderLineCZB, PaymentOrderHeaderCZB);
        if PaymentOrderLineCZB.IsEmpty() then
            Error(NothingtoIssueErr);

        CheckPaymentOrderLines(PaymentOrderHeaderCZB);
        if GuiAllowed() then
            CheckUnreliablePayers(PaymentOrderHeaderCZB);
        OnCodeOnAfterCheck(PaymentOrderHeaderCZB);

        PaymentOrderLineCZB.LockTable();
        if PaymentOrderLineCZB.FindLast() then;

        // insert header
        IssPaymentOrderHeaderCZB.Init();
        IssPaymentOrderHeaderCZB.TransferFields(PaymentOrderHeaderCZB);
        BankAccount.TestField("Issued Payment Order Nos. CZB");
        if BankAccount."Issued Payment Order Nos. CZB" <> IssPaymentOrderHeaderCZB."No. Series" then
            IssPaymentOrderHeaderCZB."No." := NoSeriesManagement.GetNextNo(BankAccount."Issued Payment Order Nos. CZB", IssPaymentOrderHeaderCZB."Document Date", true);

        PaymentOrderHeaderCZB."Last Issuing No." := IssPaymentOrderHeaderCZB."No.";

        IssPaymentOrderHeaderCZB."Pre-Assigned No. Series" := PaymentOrderHeaderCZB."No. Series";
        IssPaymentOrderHeaderCZB."Pre-Assigned No." := PaymentOrderHeaderCZB."No.";
        if User.Get(PaymentOrderHeaderCZB.SystemModifiedBy) then
            IssPaymentOrderHeaderCZB."Pre-Assigned User ID" := User."User Name";
        OnBeforeIssuedPaymentOrderHeaderInsert(IssPaymentOrderHeaderCZB, PaymentOrderHeaderCZB);
        IssPaymentOrderHeaderCZB.Insert();
        OnAfterIssuedPaymentOrderHeaderInsert(IssPaymentOrderHeaderCZB, PaymentOrderHeaderCZB);

        // insert lines
        if PaymentOrderLineCZB.FindSet() then
            repeat
                IssPaymentOrderLineCZB.Init();
                IssPaymentOrderLineCZB.TransferFields(PaymentOrderLineCZB);
                IssPaymentOrderLineCZB."Payment Order No." := IssPaymentOrderHeaderCZB."No.";
                PaymentOrderLineCZB.CalcFields("Third Party Bank Account");
                if PaymentOrderLineCZB.Type <> PaymentOrderLineCZB.Type::Vendor then
                    Clear(PaymentOrderLineCZB."Third Party Bank Account");
                IssPaymentOrderLineCZB."Third Party Bank Account" := PaymentOrderLineCZB."Third Party Bank Account";
                OnBeforeIssuedPaymentOrderLineInsert(IssPaymentOrderLineCZB, PaymentOrderLineCZB);
                IssPaymentOrderLineCZB.Insert();
                OnAfterIssuedPaymentOrderLineInsert(IssPaymentOrderLineCZB, PaymentOrderLineCZB);
            until PaymentOrderLineCZB.Next() = 0;

        OnAfterIssuePaymentOrder(PaymentOrderHeaderCZB);

        // delete non issued payment order
        PaymentOrderHeaderCZB.SuspendStatusCheck(true);
        PaymentOrderHeaderCZB.Delete(true);
    end;

    local procedure CheckPaymentOrderLines(PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    var
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckPaymentOrderLines(PaymentOrderHeaderCZB, IsHandled);
        if IsHandled then
            exit;

        PaymentOrderManagementCZB.ClearErrorMessageLog();
        SetPaymentOrderLineFilters(PaymentOrderLineCZB, PaymentOrderHeaderCZB);
        PaymentOrderLineCZB.FindSet();
        repeat
            IsHandled := false;
            OnBeforeCheckPaymentOrderLine(PaymentOrderLineCZB, IsHandled);
            if not IsHandled then begin
                PaymentOrderManagementCZB.CheckPaymentOrderLineFormat(PaymentOrderLineCZB, false);
                PaymentOrderManagementCZB.CheckPaymentOrderLineBankAccountNo(PaymentOrderLineCZB, false);
                PaymentOrderManagementCZB.CheckPaymentOrderLineCustVendBlocked(PaymentOrderLineCZB, false);
                PaymentOrderManagementCZB.CheckPaymentOrderLineApply(PaymentOrderLineCZB, false);
                PaymentOrderManagementCZB.CheckPaymentOrderLineCustom(PaymentOrderLineCZB, false);
            end;
        until PaymentOrderLineCZB.Next() = 0;

        PaymentOrderManagementCZB.ProcessErrorMessages(true, true);
    end;

    local procedure CheckUnreliablePayers(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    var
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
        CheckAmount: Decimal;
        UnreliablePayerLinesCount: Integer;
        UnreliablePayerCheckPossible: Boolean;
        BankAccIsForeignQst: Label 'The bank account %1 of vendor %2 is foreign.\\Do you want to continue?', Comment = '%1 = Bank Account No., %2 = Vendor No.';
        BankAccNotPublicQst: Label 'The bank account %1 of vendor %2 is not public.\\Do you want to continue?', Comment = '%1 = Bank Account No., %2 = Vendor No.';
        UncVATPayerLinesExistQst: Label 'There are %1 lines with unreliable VAT payer.\\Do you want to continue?', Comment = '%1 = Count of Lines';
        UncVATPayerStatusNotCheckedQst: Label 'The unreliable VAT payer status has not been checked.\\Do you want to continue?';
    begin
        if PaymentOrderHeaderCZB.UnreliablePayerCheckExpired() then
            PaymentOrderHeaderCZB.ImportUnreliablePayerStatus();

        SetPaymentOrderLineFilters(PaymentOrderLineCZB, PaymentOrderHeaderCZB);
        PaymentOrderLineCZB.SetRange(Type, PaymentOrderLineCZB.Type::Vendor);
        if not PaymentOrderLineCZB.FindSet() then
            exit;
        repeat
            if PaymentOrderLineCZB.IsUnreliablePayerCheckPossible() then begin
                UnreliablePayerCheckPossible := true;

                if PaymentOrderHeaderCZB."Unreliable Pay. Check DateTime" <> 0DT then begin
                    if PaymentOrderLineCZB."VAT Unreliable Payer" then
                        UnreliablePayerLinesCount += 1;

                    PaymentOrderLineCZB.CalcFields("Third Party Bank Account");
                    if not PaymentOrderLineCZB."Public Bank Account" then begin
                        CheckAmount := Abs(PaymentOrderLineCZB."Amount (LCY)");
                        if PaymentOrderLineCZB."Applies-to C/V/E Entry No." <> 0 then begin
                            VendorLedgerEntry.Get(PaymentOrderLineCZB."Applies-to C/V/E Entry No.");
                            VendorLedgerEntry.CalcFields("Original Amt. (LCY)");
                            CheckAmount := Abs(VendorLedgerEntry."Original Amt. (LCY)");
                        end;
                        if (not PaymentOrderLineCZB."Third Party Bank Account") and
                           UnreliablePayerMgtCZL.PublicBankAccountCheckPossible(PaymentOrderHeaderCZB."Document Date", CheckAmount) and
                           not UnreliablePayerMgtCZL.ForeignBankAccountCheckPossible(
                             PaymentOrderLineCZB."No.", PaymentOrderLineCZB."Cust./Vendor Bank Account Code")
                        then
                            ConfirmProcess(StrSubstNo(BankAccNotPublicQst, PaymentOrderLineCZB."Cust./Vendor Bank Account Code", PaymentOrderLineCZB."No."));
                    end;

                    if (not PaymentOrderLineCZB."Third Party Bank Account") and
                       UnreliablePayerMgtCZL.ForeignBankAccountCheckPossible(PaymentOrderLineCZB."No.", PaymentOrderLineCZB."Cust./Vendor Bank Account Code")
                    then
                        ConfirmProcess(StrSubstNo(BankAccIsForeignQst, PaymentOrderLineCZB."Cust./Vendor Bank Account Code", PaymentOrderLineCZB."No."));
                end;
            end;
        until PaymentOrderLineCZB.Next() = 0;

        if UnreliablePayerCheckPossible then begin
            if PaymentOrderHeaderCZB."Unreliable Pay. Check DateTime" = 0DT then
                ConfirmProcess(UncVATPayerStatusNotCheckedQst);
            if UnreliablePayerLinesCount > 0 then
                ConfirmProcess(StrSubstNo(UncVATPayerLinesExistQst, UnreliablePayerLinesCount));
        end;
    end;

    local procedure SetPaymentOrderLineFilters(var PaymentOrderLineCZB: Record "Payment Order Line CZB"; PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    begin
        PaymentOrderLineCZB.SetRange("Payment Order No.", PaymentOrderHeaderCZB."No.");
        PaymentOrderLineCZB.SetRange("Skip Payment", false);
        OnAfterSetPaymentOrderLineFilters(PaymentOrderLineCZB, PaymentOrderHeaderCZB);
    end;

    local procedure ConfirmProcess(ConfirmQuestion: Text)
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if not ConfirmManagement.GetResponseOrDefault(ConfirmQuestion, false) then
            Error('');
    end;
#if not CLEAN19
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Issue Payment Order CZB", 'OnBeforeIssuePaymentOrder', '', false, false)]
    local procedure CheckObsoleteOnBeforeIssuePaymentOrderCZB(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    var
        DuplicitPaymentOrderHeader: Record "Payment Order Header";
    begin
        if DuplicitPaymentOrderHeader.Get(PaymentOrderHeaderCZB."No.") then
            Error(DuplicityFoundErr, DuplicitPaymentOrderHeader.TableCaption(), DuplicitPaymentOrderHeader."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Issue Payment Order", 'OnBeforeIssuePaymentOrder', '', false, false)]
    local procedure CheckObsoleteOnBeforeIssuePaymentOrder(var PaymentOrderHeader: Record "Payment Order Header")
    var
        DuplicitPaymentOrderHeaderCZB: Record "Payment Order Header CZB";
    begin
        if DuplicitPaymentOrderHeaderCZB.Get(PaymentOrderHeader."No.") then
            Error(DuplicityFoundErr, DuplicitPaymentOrderHeaderCZB.TableCaption(), DuplicitPaymentOrderHeaderCZB."No.");
    end;
#pragma warning restore
#endif

    [IntegrationEvent(false, false)]
    local procedure OnAfterIssuedPaymentOrderHeaderInsert(var IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB"; var PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIssuedPaymentOrderLineInsert(var IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB"; var PaymentOrderLineCZB: Record "Payment Order Line CZB")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIssuePaymentOrder(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetPaymentOrderLineFilters(var PaymentOrderLineCZB: Record "Payment Order Line CZB"; PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIssuedPaymentOrderHeaderInsert(var IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB"; var PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIssuedPaymentOrderLineInsert(var IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB"; var PaymentOrderLineCZB: Record "Payment Order Line CZB")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIssuePaymentOrder(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnAfterCheck(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckPaymentOrderLines(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckPaymentOrderLine(var PaymentOrderLineCZB: Record "Payment Order Line CZB"; var IsHandled: Boolean);
    begin
    end;
}
