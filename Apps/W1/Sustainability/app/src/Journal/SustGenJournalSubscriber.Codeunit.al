namespace Microsoft.Sustainability.Journal;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Posting;
using Microsoft.Sustainability.Setup;

codeunit 6251 "Sust. Gen. Journal Subscriber"
{

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterUpdateSalesPurchLCY', '', false, false)]
    local procedure OnAfterUpdateSalesPurchLCY(var GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."Sust. Account No." <> '' then
            GenJournalLine.CheckSustGenJournalLine(GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterAccountNoOnValidateGetGLAccount', '', false, false)]
    local procedure OnAfterAccountNoOnValidateGetGLAccount(var GenJournalLine: Record "Gen. Journal Line"; var GLAccount: Record "G/L Account")
    begin
        GenJournalLine.Validate("Sust. Account No.", GLAccount."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterAccountNoOnValidateGetGLBalAccount', '', false, false)]
    local procedure OnAfterAccountNoOnValidateGetGLBalAccount(var GenJournalLine: Record "Gen. Journal Line"; var GLAccount: Record "G/L Account")
    begin
        if GenJournalLine."Sust. Account No." = '' then
            GenJournalLine.Validate("Sust. Account No.", GLAccount."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnCodeOnAfterStartOrContinuePosting', '', false, false)]
    local procedure OnAfterPostGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
        PostSustainabilityLine(GenJournalLine);
    end;

    local procedure PostSustainabilityLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
        Sign: Integer;
        CO2ToPost: Decimal;
        CH4ToPost: Decimal;
        N2OToPost: Decimal;
    begin
        Sign := GetPostingSign(GenJournalLine);

        CO2ToPost := GenJournalLine."Total Emission CO2" * Sign;
        CH4ToPost := GenJournalLine."Total Emission CH4" * Sign;
        N2OToPost := GenJournalLine."Total Emission N2O" * Sign;

        SustainabilitySetup.Get();
        if not CanPostSustainabilityJnlLine(GenJournalLine, CO2ToPost, CH4ToPost, N2OToPost) then
            exit;

        SustainabilityJnlLine.Init();
        SustainabilityJnlLine."Journal Template Name" := GenJournalLine."Journal Template Name";
        SustainabilityJnlLine."Journal Batch Name" := '';
        SustainabilityJnlLine."Source Code" := GenJournalLine."Source Code";
        SustainabilityJnlLine.Validate("Posting Date", GenJournalLine."Posting Date");

        case GenJournalLine."Document Type" of
            GenJournalLine."Document Type"::" ":
                SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::" ");
            GenJournalLine."Document Type"::Invoice:
                SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::Invoice);
            GenJournalLine."Document Type"::"Credit Memo":
                SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::"Credit Memo");
        end;

        SustainabilityJnlLine.Validate("Document No.", GenJournalLine."Document No.");
        SustainabilityJnlLine.Validate("Account No.", GenJournalLine."Sust. Account No.");
        SustainabilityJnlLine.Validate("Reason Code", GenJournalLine."Reason Code");
        SustainabilityJnlLine.Validate("Account Category", GenJournalLine."Sust. Account Category");
        SustainabilityJnlLine.Validate("Account Subcategory", GenJournalLine."Sust. Account Subcategory");
        SustainabilityJnlLine.Validate("Unit of Measure", SustainabilitySetup."Emission Unit of Measure Code");
        SustainabilityJnlLine."Dimension Set ID" := GenJournalLine."Dimension Set ID";
        SustainabilityJnlLine."Shortcut Dimension 1 Code" := GenJournalLine."Shortcut Dimension 1 Code";
        SustainabilityJnlLine."Shortcut Dimension 2 Code" := GenJournalLine."Shortcut Dimension 2 Code";
        SustainabilityJnlLine.Validate("Emission CO2", CO2ToPost);
        SustainabilityJnlLine.Validate("Emission CH4", CH4ToPost);
        SustainabilityJnlLine.Validate("Emission N2O", N2OToPost);
        SustainabilityJnlLine.Validate("Country/Region Code", GenJournalLine."Country/Region Code");
        SustainabilityPostMgt.InsertLedgerEntry(SustainabilityJnlLine);
    end;

    local procedure GetPostingSign(GenJournalLine: Record "Gen. Journal Line"): Integer
    var
        Sign: Integer;
    begin
        Sign := 1;

        case GenJournalLine."Document Type" of
            GenJournalLine."Document Type"::" ":
                if GenJournalLine.Amount < 0 then
                    Sign := -1;
            GenJournalLine."Document Type"::"Credit Memo":
                Sign := -1;
        end;

        exit(Sign);
    end;

    local procedure CanPostSustainabilityJnlLine(GenJournalLine: Record "Gen. Journal Line"; CO2ToPost: Decimal; CH4ToPost: Decimal; N2OToPost: Decimal): Boolean
    var
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
    begin
        if GenJournalLine."Sust. Account No." = '' then
            exit(false);

        GenJournalLine.CheckSustGenJournalLine(GenJournalLine);
        if SustainAccountSubcategory.Get(GenJournalLine."Sust. Account Category", GenJournalLine."Sust. Account Subcategory") then
            if not SustainAccountSubcategory."Renewable Energy" then
                if (CO2ToPost = 0) and (CH4ToPost = 0) and (N2OToPost = 0) then
                    Error(EmissionMustNotBeZeroErr, GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", GenJournalLine."Line No.");

        if (CO2ToPost <> 0) or (CH4ToPost <> 0) or (N2OToPost <> 0) then
            exit(true);
    end;

    var
        EmissionMustNotBeZeroErr: Label 'The Emission fields must have a value that is not 0 for Journal Template Name=%1 ,Journal Batch Name=%2 ,Line No.=%3.', Comment = '%1 = Journal Template Name , %2 = Journal Batch Name , %3 = Line No.';
}