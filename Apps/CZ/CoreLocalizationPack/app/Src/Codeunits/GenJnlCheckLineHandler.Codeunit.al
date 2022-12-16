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
}
