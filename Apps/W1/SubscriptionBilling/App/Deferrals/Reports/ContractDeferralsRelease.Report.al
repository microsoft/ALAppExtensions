namespace Microsoft.SubscriptionBilling;

using Microsoft.Foundation.AuditCodes;
using Microsoft.Sales.Setup;
using Microsoft.Sales.History;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.History;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;

report 8051 "Contract Deferrals Release"
{
    ApplicationArea = All;
    Caption = 'Contract Deferrals Release';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PostingDateReq; PostingDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the posting date on which the release is posted.';
                    }
                    field(PostUntilDateReq; PostUntilDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Post Until Date';
                        ToolTip = 'Specifies the date up to which contract deferrals are considered for release.';

                        trigger OnValidate()
                        begin
                            if PostUntilDate > PostingDate then
                                Error(PostUntilDateMustBeBeforePostingDateErr);
                        end;
                    }
                }
            }
        }
    }
    trigger OnInitReport()
    begin
        LineNo := 0;
        PostingDate := WorkDate();
        PostUntilDate := WorkDate();
        AllowGUI := true;
    end;

    trigger OnPreReport()
    begin
        TestDates();
        GetAndTestSourceCode();

        FilterAndCountContractDeferrals();

        Window.Open(ContractDeferralsReleaseTxt + ContractProgressTxt);

        ReleaseAllCustomerContractDeferralsAndInsertTempGenJournalLines();
        PostTempGenJnlLineBufferForCustomerDeferrals();
        ReleaseAllVendorContractDeferralsAndInsertTempGenJournalLines();
        PostTempGenJnlLineBufferForVendorDeferrals();
    end;

    trigger OnPostReport()
    begin
        Window.Close();
    end;

    var
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        SalesSetup: Record "Sales & Receivables Setup";
        GenPostingSetup: Record "General Posting Setup";
        SourceCodeSetup: Record "Source Code Setup";
        PurchaseSetup: Record "Purchases & Payables Setup";
        CustomerContractDeferrals: Record "Customer Contract Deferral";
        CustContractDeferralsToUpdate: Record "Customer Contract Deferral";
        VendContractDeferralsToUpdate: Record "Vendor Contract Deferral";
        VendorContractDeferrals: Record "Vendor Contract Deferral";
        PurchaseInvoiceLine: Record "Purch. Inv. Line";
        CustomerDeferralsMngmt: Codeunit "Customer Deferrals Mngmt.";
        VendorDeferralsMngmt: Codeunit "Vendor Deferrals Mngmt.";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        Window: Dialog;
        PostingDate: Date;
        PostUntilDate: Date;
        ContractDeferralIteration: Integer;
        TotalContractDeferralsCount: Integer;
        LineDiscountPosting: Boolean;
        PostingDateIsEmptyErr: Label 'You must fill in the Posting Date field.';
        PostUntilDateIsEmptyErr: Label 'You must fill in the Post Until Date field.';
        PostUntilDateMustBeBeforePostingDateErr: Label 'Posting until Date must be before then Posting Date.';
        ContractDeferralsReleaseTxt: Label 'Contract Deferrals Release...\';
        ContractProgressTxt: Label 'Contract: #1###############\\@2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@';
        ReleasingOfContractNoTxt: Label 'Release Contract Deferral of %1.';
        AllowGUI: Boolean;
        LineNo: Integer;

    local procedure TestDates()
    begin
        if PostUntilDate = 0D then
            Error(PostUntilDateIsEmptyErr);
        if PostingDate = 0D then
            Error(PostingDateIsEmptyErr);
        if PostUntilDate > PostingDate then
            Error(PostUntilDateMustBeBeforePostingDateErr);
    end;

    local procedure FilterAndCountContractDeferrals()
    begin
        ContractDeferralIteration := 0;

        CustomerContractDeferrals.SetRange("Posting Date", 0D, PostUntilDate);
        CustomerContractDeferrals.SetRange("Document Posting Date", 0D, PostUntilDate);
        CustomerContractDeferrals.SetRange(Released, false);
        VendorContractDeferrals.SetRange("Posting Date", 0D, PostUntilDate);
        VendorContractDeferrals.SetRange("Document Posting Date", 0D, PostUntilDate);
        VendorContractDeferrals.SetRange(Released, false);
        TotalContractDeferralsCount := VendorContractDeferrals.Count + CustomerContractDeferrals.Count;
    end;

    local procedure ReleaseAllCustomerContractDeferralsAndInsertTempGenJournalLines()
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        if CustomerContractDeferrals.FindSet() then begin
            GetLineDiscountPostingSetup(Enum::"Service Partner"::Customer);
            repeat
                if SalesInvoiceLine.Get(CustomerContractDeferrals."Document No.", CustomerContractDeferrals."Document Line No.") then
                    ReleaseCustomerContractDeferralAndInsertTempGenJournalLine(CustomerContractDeferrals, SalesInvoiceLine."Gen. Bus. Posting Group", SalesInvoiceLine."Gen. Prod. Posting Group");
            until CustomerContractDeferrals.Next() = 0;
        end;
    end;

    internal procedure ReleaseCustomerContractDeferralAndInsertTempGenJournalLine(var CustomerContractDeferral: Record "Customer Contract Deferral"; GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20])
    begin
        CheckGenPostingSetup(GenBusPostingGroup, GenProdPostingGroup, Enum::"Service Partner"::Customer);
        ReleaseContractDeferral(Enum::"Service Partner"::Customer, CustomerContractDeferral."Entry No.");
        InsertTempGenJournalLine(
            CustomerContractDeferral."Document No.",
            CustomerContractDeferral."Contract No.",
            CustomerContractDeferral."Entry No.",
            CustomerContractDeferral."Dimension Set ID",
            GenPostingSetup."Customer Contract Account",
            GenPostingSetup."Cust. Contr. Deferral Account",
            GenBusPostingGroup,
            GenProdPostingGroup,
            GetPostingAmount(CustomerContractDeferral.Amount, CustomerContractDeferral."Discount Amount"));
        if LineDiscountPosting and (CustomerContractDeferral."Discount Amount" <> 0) then
            InsertTempGenJournalLine(
                CustomerContractDeferral."Document No.",
                CustomerContractDeferral."Contract No.",
                CustomerContractDeferral."Entry No.",
                CustomerContractDeferral."Dimension Set ID",
                GenPostingSetup."Sales Line Disc. Account",
                GenPostingSetup."Cust. Contr. Deferral Account",
                GenBusPostingGroup,
                GenProdPostingGroup,
                -CustomerContractDeferral."Discount Amount");
    end;

    local procedure ReleaseAllVendorContractDeferralsAndInsertTempGenJournalLines()
    begin
        if VendorContractDeferrals.FindSet() then begin
            GetLineDiscountPostingSetup(Enum::"Service Partner"::Vendor);
            repeat
                if PurchaseInvoiceLine.Get(VendorContractDeferrals."Document No.", VendorContractDeferrals."Document Line No.") then
                    ReleaseVendorContractDeferralsAndInsertTempGenJournalLines(VendorContractDeferrals, PurchaseInvoiceLine."Gen. Bus. Posting Group", PurchaseInvoiceLine."Gen. Prod. Posting Group");
            until VendorContractDeferrals.Next() = 0;
        end;
    end;

    internal procedure ReleaseVendorContractDeferralsAndInsertTempGenJournalLines(var VendorContractDeferral: Record "Vendor Contract Deferral"; GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20])
    begin
        CheckGenPostingSetup(GenBusPostingGroup, GenProdPostingGroup, Enum::"Service Partner"::Vendor);
        ReleaseContractDeferral(Enum::"Service Partner"::Vendor, VendorContractDeferral."Entry No.");
        InsertTempGenJournalLine(
            VendorContractDeferral."Document No.",
            VendorContractDeferral."Contract No.",
            VendorContractDeferral."Entry No.",
            VendorContractDeferral."Dimension Set ID",
            GenPostingSetup."Vendor Contract Account",
            GenPostingSetup."Vend. Contr. Deferral Account",
            GenBusPostingGroup,
            GenProdPostingGroup,
            GetPostingAmount(VendorContractDeferral.Amount, VendorContractDeferral."Discount Amount"));
        if LineDiscountPosting and (VendorContractDeferral."Discount Amount" <> 0) then
            InsertTempGenJournalLine(
                VendorContractDeferral."Document No.",
                VendorContractDeferral."Contract No.",
                VendorContractDeferral."Entry No.",
                VendorContractDeferral."Dimension Set ID",
                GenPostingSetup."Purch. Line Disc. Account",
                GenPostingSetup."Vend. Contr. Deferral Account",
                GenBusPostingGroup,
                GenProdPostingGroup,
                -VendorContractDeferral."Discount Amount");
    end;

    local procedure GetLineDiscountPostingSetup(Partner: Enum "Service Partner")
    begin
        case Partner of
            Enum::"Service Partner"::Customer:
                begin
                    SalesSetup.Get();
                    LineDiscountPosting := SalesSetup."Discount Posting" in
                       [SalesSetup."Discount Posting"::"Line Discounts", SalesSetup."Discount Posting"::"All Discounts"];
                end;
            Enum::"Service Partner"::Vendor:
                begin
                    PurchaseSetup.Get();
                    LineDiscountPosting := PurchaseSetup."Discount Posting" in
                       [PurchaseSetup."Discount Posting"::"Line Discounts", PurchaseSetup."Discount Posting"::"All Discounts"];
                end;
        end;
    end;

    local procedure CheckGenPostingSetup(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; Partner: Enum "Service Partner")
    begin
        GenPostingSetup.Get(GenBusPostingGroup, GenProdPostingGroup);
        case Partner of
            Enum::"Service Partner"::Customer:
                begin
                    GenPostingSetup.TestField("Customer Contract Account");
                    if LineDiscountPosting then
                        GenPostingSetup.TestField("Sales Line Disc. Account");
                end;
            Enum::"Service Partner"::Vendor:
                begin
                    GenPostingSetup.TestField("Vendor Contract Account");
                    if LineDiscountPosting then
                        GenPostingSetup.TestField("Purch. Line Disc. Account");
                end;
        end;
    end;

    local procedure ReleaseContractDeferral(Partner: Enum "Service Partner"; DeferralEntryNo: Integer)
    begin
        case Partner of
            Enum::"Service Partner"::Customer:
                if CustContractDeferralsToUpdate.Get(DeferralEntryNo) then begin
                    CustContractDeferralsToUpdate.Released := true;
                    CustContractDeferralsToUpdate."Release Posting Date" := PostingDate;
                    CustContractDeferralsToUpdate.Modify(false);
                end;
            Enum::"Service Partner"::Vendor:
                if VendContractDeferralsToUpdate.Get(DeferralEntryNo) then begin
                    VendContractDeferralsToUpdate.Released := true;
                    VendContractDeferralsToUpdate."Release Posting Date" := PostingDate;
                    VendContractDeferralsToUpdate.Modify(false);
                end;
        end;
    end;

    local procedure GetPostingAmount(Amount: Decimal; DiscountAmount: Decimal): Decimal
    begin
        if LineDiscountPosting then
            exit(Amount + DiscountAmount)
        else
            exit(Amount);
    end;

    local procedure InsertTempGenJournalLine(DocumentNo: Code[20]; ContractNo: Code[20]; DeferralEntryNo: Integer; DimSetID: Integer; AccountNo: Code[20]; BalAccountNo: Code[20]; GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; PostingAmount: Decimal)
    begin
        UpdateWindow(ContractNo);
        InsertTempGenJournalLine(DocumentNo, ContractNo, DeferralEntryNo, DimSetID, AccountNo, BalAccountNo, PostingAmount, GenBusPostingGroup, GenProdPostingGroup);
    end;

    local procedure InsertTempGenJournalLine(DocumentNo: Code[20]; ContractNo: Code[20]; DeferralEntryNo: Integer; DimSetID: Integer; AccountNo: Code[20]; BalAccountNo: Code[20]; PostingAmount: Decimal; GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20])
    begin
        LineNo += 1;
        TempGenJournalLine."Account No." := AccountNo;
        TempGenJournalLine."Bal. Account No." := BalAccountNo;
        TempGenJournalLine."Document No." := DocumentNo;
        TempGenJournalLine."Sub. Contract No." := ContractNo;
        TempGenJournalLine."Gen. Bus. Posting Group" := GenBusPostingGroup;
        TempGenJournalLine."Gen. Prod. Posting Group" := GenProdPostingGroup;
        TempGenJournalLine."Dimension Set ID" := DimSetID;
        TempGenJournalLine.Amount := PostingAmount;
        TempGenJournalLine."Line No." := LineNo;
        TempGenJournalLine."Deferral Line No." := DeferralEntryNo;
        TempGenJournalLine.Insert(false);
    end;

    internal procedure PostTempGenJnlLineBufferForCustomerDeferrals()
    begin
        TempGenJournalLine.Reset();
        TempGenJournalLine.SetCurrentKey("Document No.", "Sub. Contract No.", "Gen. Bus. Posting Group", "Gen. Prod. Posting Group");
        if TempGenJournalLine.FindSet() then
            repeat
                CustomerDeferralsMngmt.SetDeferralNo(TempGenJournalLine."Deferral Line No.");
                PostGenJnlLine(TempGenJournalLine, PostingDate, SourceCodeSetup."Contract Deferrals Release");
            until TempGenJournalLine.Next() = 0;
        ResetTempGenJournalLine();
        CustomerDeferralsMngmt.SetDeferralNo(0);
    end;

    internal procedure PostTempGenJnlLineBufferForVendorDeferrals()
    begin
        TempGenJournalLine.Reset();
        TempGenJournalLine.SetCurrentKey("Document No.", "Sub. Contract No.", "Gen. Bus. Posting Group", "Gen. Prod. Posting Group");
        if TempGenJournalLine.FindSet() then
            repeat
                VendorDeferralsMngmt.SetDeferralNo(TempGenJournalLine."Deferral Line No.");
                PostGenJnlLine(TempGenJournalLine, PostingDate, SourceCodeSetup."Contract Deferrals Release");
                VendorDeferralsMngmt.SetDeferralNo(0);
            until TempGenJournalLine.Next() = 0;
        ResetTempGenJournalLine();
    end;

    local procedure ResetTempGenJournalLine()
    begin
        TempGenJournalLine.Reset();
        TempGenJournalLine.DeleteAll(false);
    end;

    local procedure UpdateWindow(ContractNo: Code[20])
    begin
        if not AllowGUI then
            exit;
        ContractDeferralIteration += 1;
        Window.Update(1, ContractNo);
        Window.Update(2, Round(ContractDeferralIteration / TotalContractDeferralsCount * 10000, 1));
    end;

    internal procedure GetAndTestSourceCode()
    begin
        SourceCodeSetup.Get();
        SourceCodeSetup.TestField("Contract Deferrals Release");
    end;

    procedure PostGenJnlLine(var TempGenJournalLine: Record "Gen. Journal Line" temporary; PostingDate: Date; SourceCodeSetupContractDeferralsRelease: Code[10])
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.Init();
        GenJnlLine."Document No." := TempGenJournalLine."Document No.";
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."VAT Posting" := GenJnlLine."VAT Posting"::"Manual VAT Entry";
        GenJnlLine.Validate("Account No.", TempGenJournalLine."Account No.");
        GenJnlLine."Posting Date" := PostingDate;
        GenJnlLine.Description := StrSubstNo(ReleasingOfContractNoTxt, Format(GenJnlLine."Posting Date", 0, '<Month Text> <Year4>'));
        GenJnlLine."Sub. Contract No." := TempGenJournalLine."Sub. Contract No.";
        GenJnlLine.Validate(Amount, TempGenJournalLine.Amount);
        GenJnlLine.Validate("Dimension Set ID", TempGenJournalLine."Dimension Set ID");
        GenJnlLine."Source Code" := SourceCodeSetupContractDeferralsRelease;
        GenJnlLine."System-Created Entry" := true;
        GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::" ";
        GenJnlLine."Gen. Bus. Posting Group" := '';
        GenJnlLine."Gen. Prod. Posting Group" := '';
        GenJnlLine."VAT Bus. Posting Group" := '';
        GenJnlLine."VAT Prod. Posting Group" := '';
        GenJnlPostLine.RunWithCheck(GenJnlLine);

        GenJnlLine.Validate("Account No.", TempGenJournalLine."Bal. Account No.");
        GenJnlLine.Validate("Dimension Set ID", TempGenJournalLine."Dimension Set ID");
        GenJnlLine.Validate(Amount, -TempGenJournalLine.Amount);
        GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::" ";
        GenJnlLine."Gen. Bus. Posting Group" := '';
        GenJnlLine."Gen. Prod. Posting Group" := '';
        GenJnlLine."VAT Bus. Posting Group" := '';
        GenJnlLine."VAT Prod. Posting Group" := '';
        GenJnlLine.Description := StrSubstNo(ReleasingOfContractNoTxt, Format(GenJnlLine."Posting Date", 0, '<Month Text> <Year4>'));
        GenJnlPostLine.RunWithCheck(GenJnlLine);
    end;


    internal procedure SetRequestPageParameters(NewPostUntilDate: Date; NewPostingDate: Date)
    begin
        PostUntilDate := NewPostUntilDate;
        PostingDate := NewPostingDate;
    end;

    internal procedure SetAllowGUI(NewAllowGUI: Boolean)
    begin
        AllowGUI := NewAllowGUI;
    end;
}
