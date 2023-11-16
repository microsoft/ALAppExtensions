// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Reports;

using Microsoft.Bank.BankAccount;
using Microsoft.CRM.Campaign;
using Microsoft.CRM.Team;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Setup;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.Maintenance;
using Microsoft.FixedAssets.Setup;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Period;
using Microsoft.HumanResources.Employee;
using Microsoft.Intercompany.BankAccount;
using Microsoft.Intercompany.GLAccount;
using Microsoft.Intercompany.Journal;
using Microsoft.Intercompany.Partner;
using Microsoft.Projects.Project.Job;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Setup;
using System.Security.User;
using System.Utilities;

report 11722 "General Journal - Test CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/GeneralJournalTest.rdl';
    Caption = 'General Journal - Test CZ';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Gen. Journal Batch"; "Gen. Journal Batch")
        {
            DataItemTableView = sorting("Journal Template Name", Name);
            column(JnlTmplName_GenJnlBatch; "Journal Template Name")
            {
            }
            column(Name_GenJnlBatch; Name)
            {
            }
            column(CompanyName; COMPANYPROPERTY.DisplayName())
            {
            }
            column(GeneralJnlTestCaption; GeneralJnlTestLbl)
            {
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                PrintOnlyIfDetail = true;
                column(JnlTemplateName_GenJnlBatch; "Gen. Journal Batch"."Journal Template Name")
                {
                }
                column(JnlName_GenJnlBatch; "Gen. Journal Batch".Name)
                {
                }
                column(GenJnlLineFilter; GenJnlLineFilter)
                {
                }
                column(GenJnlLineFilterTableCaption; "Gen. Journal Line".TableCaption + ': ' + GenJnlLineFilter)
                {
                }
                column(Number_Integer; Number)
                {
                }
                column(PageNoCaption; PageNoLbl)
                {
                }
                column(JnlTmplNameCaption_GenJnlBatch; "Gen. Journal Batch".FieldCaption("Journal Template Name"))
                {
                }
                column(JournalBatchCaption; JnlBatchNameLbl)
                {
                }
                column(PostingDateCaption; PostingDateLbl)
                {
                }
                column(DocumentTypeCaption; DocumentTypeLbl)
                {
                }
                column(DocNoCaption_GenJnlLine; "Gen. Journal Line".FieldCaption("Document No."))
                {
                }
                column(AccountTypeCaption; AccountTypeLbl)
                {
                }
                column(AccNoCaption_GenJnlLine; "Gen. Journal Line".FieldCaption("Account No."))
                {
                }
                column(AccNameCaption; AccNameLbl)
                {
                }
                column(DescCaption_GenJnlLine; "Gen. Journal Line".FieldCaption(Description))
                {
                }
                column(PostingTypeCaption; GenPostingTypeLbl)
                {
                }
                column(GenBusPostGroupCaption; GenBusPostingGroupLbl)
                {
                }
                column(GenProdPostGroupCaption; GenProdPostingGroupLbl)
                {
                }
                column(AmountCaption_GenJnlLine; "Gen. Journal Line".FieldCaption(Amount))
                {
                }
                column(BalAccNoCaption_GenJnlLine; "Gen. Journal Line".FieldCaption("Bal. Account No."))
                {
                }
                column(BalLCYCaption_GenJnlLine; "Gen. Journal Line".FieldCaption("Balance (LCY)"))
                {
                }
                dataitem("Gen. Journal Line"; "Gen. Journal Line")
                {
                    DataItemLink = "Journal Template Name" = field("Journal Template Name"), "Journal Batch Name" = field(Name);
                    DataItemLinkReference = "Gen. Journal Batch";
                    DataItemTableView = sorting("Journal Template Name", "Journal Batch Name", "Line No.");
                    RequestFilterFields = "Posting Date";
                    column(PostingDate_GenJnlLine; Format("Posting Date"))
                    {
                    }
                    column(DocType_GenJnlLine; "Document Type")
                    {
                    }
                    column(DocNo_GenJnlLine; "Document No.")
                    {
                    }
                    column(ExtDocNo_GenJnlLine; "External Document No.")
                    {
                    }
                    column(AccountType_GenJnlLine; "Account Type")
                    {
                    }
                    column(AccountNo_GenJnlLine; "Account No.")
                    {
                    }
                    column(AccName; AccNameGlobal)
                    {
                    }
                    column(Description_GenJnlLine; Description)
                    {
                    }
                    column(GenPostType_GenJnlLine; "Gen. Posting Type")
                    {
                    }
                    column(GenBusPosGroup_GenJnlLine; "Gen. Bus. Posting Group")
                    {
                    }
                    column(GenProdPostGroup_GenJnlLine; "Gen. Prod. Posting Group")
                    {
                    }
                    column(Amount_GenJnlLine; Amount)
                    {
                    }
                    column(CurrencyCode_GenJnlLine; "Currency Code")
                    {
                    }
                    column(BalAccNo_GenJnlLine; "Bal. Account No.")
                    {
                    }
                    column(BalanceLCY_GenJnlLine; "Balance (LCY)")
                    {
                    }
                    column(AmountLCY; AmountLCY)
                    {
                    }
                    column(BalanceLCY; BalanceLCY)
                    {
                    }
                    column(AmountLCY_GenJnlLine; "Amount (LCY)")
                    {
                    }
                    column(JnlTmplName_GenJnlLine; "Journal Template Name")
                    {
                    }
                    column(JnlBatchName_GenJnlLine; "Journal Batch Name")
                    {
                    }
                    column(LineNo_GenJnlLine; "Line No.")
                    {
                    }
                    column(TotalLCYCaption; AmountLCYLbl)
                    {
                    }
                    dataitem(DimensionLoop; "Integer")
                    {
                        DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                        column(DimText; DimText)
                        {
                        }
                        column(Number_DimensionLoop; Number)
                        {
                        }
                        column(DimensionsCaption; DimensionsLbl)
                        {
                        }
                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then begin
                                if not DimensionSetEntryGlobal.FindSet() then
                                    CurrReport.Break();
                            end else
                                if not Continue then
                                    CurrReport.Break();

                            DimText := GetDimensionText(DimensionSetEntryGlobal);
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not ShouldShowDim then
                                CurrReport.Break();
                            DimensionSetEntryGlobal.Reset();
                            DimensionSetEntryGlobal.SetRange("Dimension Set ID", "Gen. Journal Line"."Dimension Set ID")
                        end;
                    }
                    dataitem("Gen. Jnl. Allocation"; "Gen. Jnl. Allocation")
                    {
                        DataItemLink = "Journal Template Name" = field("Journal Template Name"), "Journal Batch Name" = field("Journal Batch Name"), "Journal Line No." = field("Line No.");
                        DataItemTableView = sorting("Journal Template Name", "Journal Batch Name", "Journal Line No.", "Line No.");
                        column(AccountNo_GenJnlAllocation; "Account No.")
                        {
                        }
                        column(AccountName_GenJnlAllocation; "Account Name")
                        {
                        }
                        column(AllocationQuantity_GenJnlAllocation; "Allocation Quantity")
                        {
                        }
                        column(AllocationPct_GenJnlAllocation; "Allocation %")
                        {
                        }
                        column(Amount_GenJnlAllocation; Amount)
                        {
                        }
                        column(JournalLineNo_GenJnlAllocation; "Journal Line No.")
                        {
                        }
                        column(LineNo_GenJnlAllocation; "Line No.")
                        {
                        }
                        column(JournalBatchName_GenJnlAllocation; "Journal Batch Name")
                        {
                        }
                        column(AccountNoCaption_GenJnlAllocation; FieldCaption("Account No."))
                        {
                        }
                        column(AccountNameCaption_GenJnlAllocation; FieldCaption("Account Name"))
                        {
                        }
                        column(AllocationQuantityCaption_GenJnlAllocation; FieldCaption("Allocation Quantity"))
                        {
                        }
                        column(AllocationPctCaption_GenJnlAllocation; FieldCaption("Allocation %"))
                        {
                        }
                        column(AmountCaption_GenJnlAllocation; FieldCaption(Amount))
                        {
                        }
                        column(Recurring_GenJnlTemplate; GenJournalTemplate.Recurring)
                        {
                        }
                        dataitem(DimensionLoopAllocations; "Integer")
                        {
                            DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                            column(AllocationDimText; AllocationDimText)
                            {
                            }
                            column(Number_DimensionLoopAllocations; Number)
                            {
                            }
                            column(DimensionAllocationsCaption; DimensionAllocationsLbl)
                            {
                            }
                            trigger OnAfterGetRecord()
                            begin
                                if Number = 1 then begin
                                    if not DimensionSetEntryGlobal.FindFirst() then
                                        CurrReport.Break();
                                end else
                                    if not Continue then
                                        CurrReport.Break();

                                AllocationDimText := GetDimensionText(DimensionSetEntryGlobal);
                            end;

                            trigger OnPreDataItem()
                            begin
                                if not ShouldShowDim then
                                    CurrReport.Break();
                                DimensionSetEntryGlobal.Reset();
                                DimensionSetEntryGlobal.SetRange("Dimension Set ID", "Gen. Jnl. Allocation"."Dimension Set ID")
                            end;
                        }
                    }
                    dataitem(ErrorLoop; "Integer")
                    {
                        DataItemTableView = sorting(Number);
                        column(ErrorTextNumber; ErrorText[Number])
                        {
                        }
                        column(WarningCaption; WarningLbl)
                        {
                        }
                        trigger OnPostDataItem()
                        begin
                            ErrorCounter := 0;
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetRange(Number, 1, ErrorCounter);
                        end;
                    }
                    trigger OnAfterGetRecord()
                    var
                        PaymentTerms: Record "Payment Terms";
                        UserSetupManagement: Codeunit "User Setup Management";
                    begin
                        OnBeforeGenJournalLineOnAfterGetRecord("Gen. Journal Line", "Gen. Journal Batch", GenJournalTemplate);

                        if "Currency Code" = '' then
                            "Amount (LCY)" := Amount;

                        UpdateLineBalance();

                        AccNameGlobal := '';
                        BalAccName := '';

                        if not EmptyLine() then begin
                            MakeRecurringTexts("Gen. Journal Line");

                            AmountError := false;

                            if ("Account No." = '') and ("Bal. Account No." = '') then
                                AddError(StrSubstNo(OneOfTwoFieldsMustBeSpecifiedErr, FieldCaption("Account No."), FieldCaption("Bal. Account No.")))
                            else
                                if ("Account Type" <> "Account Type"::"Fixed Asset") and
                                   ("Bal. Account Type" <> "Bal. Account Type"::"Fixed Asset")
                                then
                                    TestFixedAssetFields("Gen. Journal Line");
                            CheckICDocument();
                            if "Account No." <> '' then
                                case "Account Type" of
                                    "Account Type"::"G/L Account":
                                        begin
                                            if ("Gen. Bus. Posting Group" <> '') or ("Gen. Prod. Posting Group" <> '') or
                                               ("VAT Bus. Posting Group" <> '') or ("VAT Prod. Posting Group" <> '')
                                            then
                                                if "Gen. Posting Type" = "Gen. Posting Type"::" " then
                                                    AddError(StrSubstNo(FieldMustBeSpecifiedErr, FieldCaption("Gen. Posting Type")));

                                            if ("Gen. Posting Type" <> "Gen. Posting Type"::" ") and
                                               ("VAT Posting" = "VAT Posting"::"Automatic VAT Entry")
                                            then begin
                                                if "VAT Amount" + "VAT Base Amount" <> Amount then
                                                    AddError(
                                                      StrSubstNo(
                                                        SumMustBeErr, FieldCaption("VAT Amount"), FieldCaption("VAT Base Amount"),
                                                        FieldCaption(Amount)));
                                                if "Currency Code" <> '' then
                                                    if "VAT Amount (LCY)" + "VAT Base Amount (LCY)" <> "Amount (LCY)" then
                                                        AddError(
                                                          StrSubstNo(
                                                            SumMustBeErr, FieldCaption("VAT Amount (LCY)"),
                                                            FieldCaption("VAT Base Amount (LCY)"), FieldCaption("Amount (LCY)")));
                                            end;
                                            TestJobFields("Gen. Journal Line");
                                        end;
                                    "Account Type"::Customer, "Account Type"::Vendor:
                                        begin
                                            if "Gen. Posting Type" <> "Gen. Posting Type"::" " then
                                                AddError(
                                                  StrSubstNo(
                                                    MustBeEmptyErr,
                                                    FieldCaption("Gen. Posting Type"), FieldCaption("Account Type"), "Account Type"));
                                            if ("Gen. Bus. Posting Group" <> '') or ("Gen. Prod. Posting Group" <> '') or
                                               ("VAT Bus. Posting Group" <> '') or ("VAT Prod. Posting Group" <> '')
                                            then
                                                AddError(
                                                  StrSubstNo(
                                                    MustNotBeCompletedErr,
                                                    FieldCaption("Gen. Bus. Posting Group"), FieldCaption("Gen. Prod. Posting Group"),
                                                    FieldCaption("VAT Bus. Posting Group"), FieldCaption("VAT Prod. Posting Group"),
                                                    FieldCaption("Account Type"), "Account Type"));

                                            if "Document Type" <> "Document Type"::" " then
                                                if "Account Type" = "Account Type"::Customer then
                                                    case "Document Type" of
                                                        "Document Type"::"Credit Memo":
                                                            WarningIfPositiveAmt("Gen. Journal Line");
                                                        "Document Type"::Payment:
                                                            if ("Applies-to Doc. Type" = "Applies-to Doc. Type"::"Credit Memo") and
                                                               ("Applies-to Doc. No." <> '')
                                                            then
                                                                WarningIfNegativeAmt("Gen. Journal Line")
                                                            else
                                                                WarningIfPositiveAmt("Gen. Journal Line");
                                                        "Document Type"::Refund:
                                                            WarningIfNegativeAmt("Gen. Journal Line");
                                                        else
                                                            WarningIfNegativeAmt("Gen. Journal Line");
                                                    end
                                                else
                                                    case "Document Type" of
                                                        "Document Type"::"Credit Memo":
                                                            WarningIfNegativeAmt("Gen. Journal Line");
                                                        "Document Type"::Payment:
                                                            if ("Applies-to Doc. Type" = "Applies-to Doc. Type"::"Credit Memo") and
                                                               ("Applies-to Doc. No." <> '')
                                                            then
                                                                WarningIfPositiveAmt("Gen. Journal Line")
                                                            else
                                                                WarningIfNegativeAmt("Gen. Journal Line");
                                                        "Document Type"::Refund:
                                                            WarningIfPositiveAmt("Gen. Journal Line");
                                                        else
                                                            WarningIfPositiveAmt("Gen. Journal Line");
                                                    end;

                                            if Amount * "Sales/Purch. (LCY)" < 0 then
                                                AddError(
                                                  StrSubstNo(
                                                    MustBeSameSignErr,
                                                    FieldCaption("Sales/Purch. (LCY)"), FieldCaption(Amount)));
                                            if "Job No." <> '' then
                                                AddError(StrSubstNo(CannotBeSpecifiedErr, FieldCaption("Job No.")));
                                        end;
                                    "Account Type"::"Bank Account":
                                        begin
                                            if "Gen. Posting Type" <> "Gen. Posting Type"::" " then
                                                AddError(
                                                  StrSubstNo(
                                                    MustBeEmptyErr,
                                                    FieldCaption("Gen. Posting Type"), FieldCaption("Account Type"), "Account Type"));
                                            if ("Gen. Bus. Posting Group" <> '') or ("Gen. Prod. Posting Group" <> '') or
                                               ("VAT Bus. Posting Group" <> '') or ("VAT Prod. Posting Group" <> '')
                                            then
                                                AddError(
                                                  StrSubstNo(
                                                    MustNotBeCompletedErr,
                                                    FieldCaption("Gen. Bus. Posting Group"), FieldCaption("Gen. Prod. Posting Group"),
                                                    FieldCaption("VAT Bus. Posting Group"), FieldCaption("VAT Prod. Posting Group"),
                                                    FieldCaption("Account Type"), "Account Type"));

                                            if "Job No." <> '' then
                                                AddError(StrSubstNo(CannotBeSpecifiedErr, FieldCaption("Job No.")));
                                            if (Amount < 0) and ("Bank Payment Type" = "Bank Payment Type"::"Computer Check") then
                                                if not "Check Printed" then
                                                    AddError(StrSubstNo(MustBeYesErr, FieldCaption("Check Printed")));
                                        end;
                                    "Account Type"::"Fixed Asset":
                                        TestFixedAsset("Gen. Journal Line");
                                end;

                            if "Bal. Account No." <> '' then
                                case "Bal. Account Type" of
                                    "Bal. Account Type"::"G/L Account":
                                        begin
                                            if ("Bal. Gen. Bus. Posting Group" <> '') or ("Bal. Gen. Prod. Posting Group" <> '') or
                                               ("Bal. VAT Bus. Posting Group" <> '') or ("Bal. VAT Prod. Posting Group" <> '')
                                            then
                                                if "Bal. Gen. Posting Type" = "Bal. Gen. Posting Type"::" " then
                                                    AddError(StrSubstNo(FieldMustBeSpecifiedErr, FieldCaption("Bal. Gen. Posting Type")));

                                            if ("Bal. Gen. Posting Type" <> "Bal. Gen. Posting Type"::" ") and
                                               ("VAT Posting" = "VAT Posting"::"Automatic VAT Entry")
                                            then begin
                                                if "Bal. VAT Amount" + "Bal. VAT Base Amount" <> -Amount then
                                                    AddError(
                                                      StrSubstNo(
                                                        SumMustBeNegativeErr, FieldCaption("Bal. VAT Amount"), FieldCaption("Bal. VAT Base Amount"),
                                                        FieldCaption(Amount)));
                                                if "Currency Code" <> '' then
                                                    if "Bal. VAT Amount (LCY)" + "Bal. VAT Base Amount (LCY)" <> -"Amount (LCY)" then
                                                        AddError(
                                                          StrSubstNo(
                                                            SumMustBeNegativeErr, FieldCaption("Bal. VAT Amount (LCY)"),
                                                            FieldCaption("Bal. VAT Base Amount (LCY)"), FieldCaption("Amount (LCY)")));
                                            end;
                                        end;
                                    "Bal. Account Type"::Customer, "Bal. Account Type"::Vendor:
                                        begin
                                            if "Bal. Gen. Posting Type" <> "Bal. Gen. Posting Type"::" " then
                                                AddError(
                                                  StrSubstNo(
                                                    MustBeEmptyErr,
                                                    FieldCaption("Bal. Gen. Posting Type"), FieldCaption("Bal. Account Type"), "Bal. Account Type"));
                                            if ("Bal. Gen. Bus. Posting Group" <> '') or ("Bal. Gen. Prod. Posting Group" <> '') or
                                               ("Bal. VAT Bus. Posting Group" <> '') or ("Bal. VAT Prod. Posting Group" <> '')
                                            then
                                                AddError(
                                                  StrSubstNo(
                                                    MustNotBeCompletedErr,
                                                    FieldCaption("Bal. Gen. Bus. Posting Group"), FieldCaption("Bal. Gen. Prod. Posting Group"),
                                                    FieldCaption("Bal. VAT Bus. Posting Group"), FieldCaption("Bal. VAT Prod. Posting Group"),
                                                    FieldCaption("Bal. Account Type"), "Bal. Account Type"));

                                            if "Document Type".AsInteger() <> 0 then
                                                if ("Bal. Account Type" = "Bal. Account Type"::Customer) =
                                                   ("Document Type" in ["Document Type"::Payment, "Document Type"::"Credit Memo"])
                                                then
                                                    WarningIfNegativeAmt("Gen. Journal Line")
                                                else
                                                    WarningIfPositiveAmt("Gen. Journal Line");

                                            if Amount * "Sales/Purch. (LCY)" > 0 then
                                                AddError(
                                                  StrSubstNo(
                                                    MustHaveDifferentSignErr,
                                                    FieldCaption("Sales/Purch. (LCY)"), FieldCaption(Amount)));
                                            if "Job No." <> '' then
                                                AddError(StrSubstNo(CannotBeSpecifiedErr, FieldCaption("Job No.")));
                                        end;
                                    "Bal. Account Type"::"Bank Account":
                                        begin
                                            if "Bal. Gen. Posting Type" <> "Bal. Gen. Posting Type"::" " then
                                                AddError(
                                                  StrSubstNo(
                                                    MustBeEmptyErr,
                                                    FieldCaption("Bal. Gen. Posting Type"), FieldCaption("Bal. Account Type"), "Bal. Account Type"));
                                            if ("Bal. Gen. Bus. Posting Group" <> '') or ("Bal. Gen. Prod. Posting Group" <> '') or
                                               ("Bal. VAT Bus. Posting Group" <> '') or ("Bal. VAT Prod. Posting Group" <> '')
                                            then
                                                AddError(
                                                  StrSubstNo(
                                                    MustNotBeCompletedErr,
                                                    FieldCaption("Bal. Gen. Bus. Posting Group"), FieldCaption("Bal. Gen. Prod. Posting Group"),
                                                    FieldCaption("Bal. VAT Bus. Posting Group"), FieldCaption("Bal. VAT Prod. Posting Group"),
                                                    FieldCaption("Bal. Account Type"), "Bal. Account Type"));

                                            if "Job No." <> '' then
                                                AddError(StrSubstNo(CannotBeSpecifiedErr, FieldCaption("Job No.")));
                                            if (Amount > 0) and ("Bank Payment Type" = "Bank Payment Type"::"Computer Check") then
                                                if not "Check Printed" then
                                                    AddError(StrSubstNo(MustBeYesErr, FieldCaption("Check Printed")));
                                        end;
                                    "Bal. Account Type"::"Fixed Asset":
                                        TestFixedAsset("Gen. Journal Line");
                                end;

                            if ("Account No." <> '') and
                               not "System-Created Entry" and
                               (Amount = 0) and
                               not GenJournalTemplate.Recurring and
                               not "Allow Zero-Amount Posting" and
                               ("Account Type" <> "Account Type"::"Fixed Asset")
                            then
                                WarningIfZeroAmt("Gen. Journal Line");

                            CheckRecurringLine("Gen. Journal Line");
                            CheckAllocations("Gen. Journal Line");

                            if "Posting Date" = 0D then
                                AddError(StrSubstNo(FieldMustBeSpecifiedErr, FieldCaption("Posting Date")))
                            else begin
                                if "Posting Date" <> NormalDate("Posting Date") then
                                    if ("Account Type" <> "Account Type"::"G/L Account") or
                                       ("Bal. Account Type" <> "Bal. Account Type"::"G/L Account")
                                    then
                                        AddError(
                                          StrSubstNo(
                                            MustBeClosingDateErr, FieldCaption("Posting Date")));

                                if not UserSetupManagement.TestAllowedPostingDate("Posting Date", TempErrorText) then
                                    AddError(TempErrorText);

                                if "Gen. Journal Batch"."No. Series" <> '' then begin
                                    if NoSeries."Date Order" and ("Posting Date" < LastEntrdDate) then
                                        AddError(LineOrderAccordingPostingDateErr);
                                    LastEntrdDate := "Posting Date";
                                end;
                            end;

                            if "Document Date" <> 0D then
                                if ("Document Date" <> NormalDate("Document Date")) and
                                   (("Account Type" <> "Account Type"::"G/L Account") or
                                    ("Bal. Account Type" <> "Bal. Account Type"::"G/L Account"))
                                then
                                    AddError(
                                      StrSubstNo(
                                        MustBeClosingDateErr, FieldCaption("Document Date")));

                            if "Document No." = '' then
                                AddError(StrSubstNo(FieldMustBeSpecifiedErr, FieldCaption("Document No.")))
                            else
                                if "Gen. Journal Batch"."No. Series" <> '' then
                                    if IsGapInNosForDocNo("Gen. Journal Line") then
                                        AddError(GapInNoSeriesErr);

                            if ("Account Type" in ["Account Type"::Customer, "Account Type"::Vendor, "Account Type"::"Fixed Asset"]) and
                               ("Bal. Account Type" in ["Bal. Account Type"::Customer, "Bal. Account Type"::Vendor, "Bal. Account Type"::"Fixed Asset"])
                            then
                                AddError(
                                  StrSubstNo(
                                    MustBeGLBankAccErr,
                                    FieldCaption("Account Type"), FieldCaption("Bal. Account Type")));

                            if Amount * "Amount (LCY)" < 0 then
                                AddError(
                                  StrSubstNo(
                                    MustBeSameSignErr, FieldCaption("Amount (LCY)"), FieldCaption(Amount)));

                            if ("Account Type" = "Account Type"::"G/L Account") and
                               ("Bal. Account Type" = "Bal. Account Type"::"G/L Account")
                            then
                                if "Applies-to Doc. No." <> '' then
                                    AddError(StrSubstNo(CannotBeSpecifiedErr, FieldCaption("Applies-to Doc. No.")));

                            if (("Account Type" = "Account Type"::"G/L Account") and
                                ("Bal. Account Type" = "Bal. Account Type"::"G/L Account")) or
                               ("Document Type" <> "Document Type"::Invoice)
                            then
                                if PaymentTerms.Get("Payment Terms Code") then begin
                                    if ("Document Type" = "Document Type"::"Credit Memo") and
                                       (not PaymentTerms."Calc. Pmt. Disc. on Cr. Memos")
                                    then begin
                                        if "Pmt. Discount Date" <> 0D then
                                            AddError(StrSubstNo(CannotBeSpecifiedErr, FieldCaption("Pmt. Discount Date")));
                                        if "Payment Discount %" <> 0 then
                                            AddError(StrSubstNo(MustBeZeroErr, FieldCaption("Payment Discount %")));
                                    end;
                                end else begin
                                    if "Pmt. Discount Date" <> 0D then
                                        AddError(StrSubstNo(CannotBeSpecifiedErr, FieldCaption("Pmt. Discount Date")));
                                    if "Payment Discount %" <> 0 then
                                        AddError(StrSubstNo(MustBeZeroErr, FieldCaption("Payment Discount %")));
                                end;

                            if (("Account Type" = "Account Type"::"G/L Account") and
                                ("Bal. Account Type" = "Bal. Account Type"::"G/L Account")) or
                               ("Applies-to Doc. No." <> '')
                            then
                                if "Applies-to ID" <> '' then
                                    AddError(StrSubstNo(CannotBeSpecifiedErr, FieldCaption("Applies-to ID")));

                            if ("Account Type" <> "Account Type"::"Bank Account") and
                               ("Bal. Account Type" <> "Bal. Account Type"::"Bank Account")
                            then
                                if GenJournalLineGlobal."Bank Payment Type" <> GenJournalLineGlobal."Bank Payment Type"::" " then
                                    AddError(StrSubstNo(CannotBeSpecifiedErr, FieldCaption("Bank Payment Type")));

                            if ("Account No." <> '') and ("Bal. Account No." <> '') then begin
                                PurchPostingType := false;
                                SalesPostingType := false;
                            end;
                            if "Account No." <> '' then
                                CheckAccountTypes("Account Type", AccNameGlobal);
                            if "Bal. Account No." <> '' then begin
                                Codeunit.Run(Codeunit::"Exchange Acc. G/L Journal Line", "Gen. Journal Line");
                                CheckAccountTypes("Account Type", BalAccName);
                                Codeunit.Run(Codeunit::"Exchange Acc. G/L Journal Line", "Gen. Journal Line");
                            end;

                            CheckDimensions("Gen. Journal Line");

                            OnAfterCheckGenJnlLine("Gen. Journal Line", ErrorCounter, ErrorText);
                        end;

                        CheckBalance();
                        AmountLCY += "Amount (LCY)";
                        BalanceLCY += "Balance (LCY)";
                    end;

                    trigger OnPreDataItem()
                    begin
                        CopyFilter("Journal Batch Name", "Gen. Journal Batch".Name);
                        GenJnlLineFilter := GetFilters();

                        GenJournalTemplate.Get("Gen. Journal Batch"."Journal Template Name");
                        if GenJournalTemplate.Recurring then begin
                            if GetFilter("Posting Date") <> '' then
                                AddError(
                                  StrSubstNo(
                                    CannotBeFilteredWhenRecurringErr,
                                    FieldCaption("Posting Date")));
                            SetRange("Posting Date", 0D, WorkDate());
                            if GetFilter("Expiration Date") <> '' then
                                AddError(
                                  StrSubstNo(
                                    CannotBeFilteredWhenRecurringErr,
                                    FieldCaption("Expiration Date")));
                            SetFilter("Expiration Date", '%1 | %2..', 0D, WorkDate());
                        end;

                        // If simple view is used then order gen. journal lines by doc no. and line no.
                        if not GenJournalTemplate.Recurring then
                            if GenJnlManagement.GetJournalSimplePageModePreference(PAGE::"General Journal") then
                                SetCurrentKey("Document No.", "Line No.");

                        LastEnteredDocNo := '';
                        if "Gen. Journal Batch"."No. Series" <> '' then begin
                            NoSeries.Get("Gen. Journal Batch"."No. Series");
                            LastEnteredDocNo := GetLastEnteredDocumentNo("Gen. Journal Line");
                            LastEntrdDate := 0D;
                        end;

                        TempCustVendICGenJournalLine.Reset();
                        TempCustVendICGenJournalLine.DeleteAll();
                        VATEntryCreated := false;

                        GenJournalLineGlobal.Reset();
                        GenJournalLineGlobal.CopyFilters("Gen. Journal Line");

                        TempGLAccountNetChange.DeleteAll();
                    end;
                }
                dataitem(ReconcileLoop; "Integer")
                {
                    DataItemTableView = sorting(Number);
                    column(GLAccNetChangeNo; TempGLAccountNetChange."No.")
                    {
                    }
                    column(GLAccNetChangeName; TempGLAccountNetChange.Name)
                    {
                    }
                    column(GLAccNetChangeNetChangeJnl; TempGLAccountNetChange."Net Change in Jnl.")
                    {
                    }
                    column(GLAccNetChangeBalafterPost; TempGLAccountNetChange."Balance after Posting")
                    {
                    }
                    column(ReconciliationCaption; ReconciliationLbl)
                    {
                    }
                    column(NoCaption; NoLbl)
                    {
                    }
                    column(NameCaption; NameLbl)
                    {
                    }
                    column(NetChangeinJnlCaption; NetChangeinJnlLbl)
                    {
                    }
                    column(BalafterPostingCaption; BalafterPostingLbl)
                    {
                    }
                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then
                            TempGLAccountNetChange.Find('-')
                        else
                            TempGLAccountNetChange.Next();
                    end;

                    trigger OnPostDataItem()
                    begin
                        TempGLAccountNetChange.DeleteAll();
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, TempGLAccountNetChange.Count);
                    end;
                }
            }
            trigger OnPreDataItem()
            begin
                GeneralLedgerSetup.Get();
                SalesReceivablesSetup.Get();
                PurchasesPayablesSetup.Get();
                AmountLCY := 0;
                BalanceLCY := 0;

                "Gen. Journal Line".CopyFilter("Journal Batch Name", Name);
                "Gen. Journal Line".CopyFilter("Journal Template Name", "Journal Template Name");
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ShowDim; ShouldShowDim)
                    {
                        ApplicationArea = Dimensions;
                        Caption = 'Show Dimensions';
                        ToolTip = 'Specifies if you want dimensions information for the journal lines to be included in the report.';
                    }
                }
            }
        }
    }

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        UserSetup: Record "User Setup";
        AccountingPeriod: Record "Accounting Period";
        GLAccount: Record "G/L Account";
        Currency: Record Currency;
        Customer: Record Customer;
        Vendor: Record Vendor;
        BankAccountPostingGroup: Record "Bank Account Posting Group";
        BankAccount: Record "Bank Account";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalLineGlobal: Record "Gen. Journal Line";
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        TempCustVendICGenJournalLine: Record "Gen. Journal Line" temporary;
        GenJnlAllocation: Record "Gen. Jnl. Allocation";
        OldCustLedgerEntry: Record "Cust. Ledger Entry";
        OldVendorLedgerEntry: Record "Vendor Ledger Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        NoSeries: Record "No. Series";
        FixedAsset: Record "Fixed Asset";
        ICPartner: Record "IC Partner";
        DepreciationBook: Record "Depreciation Book";
        FADepreciationBook: Record "FA Depreciation Book";
        FASetup: Record "FA Setup";
#pragma warning disable AL0432
        TempGLAccountNetChange: Record "G/L Account Net Change" temporary;
#pragma warning restore AL0432
        DimensionSetEntryGlobal: Record "Dimension Set Entry";
        Employee: Record Employee;
        GenJnlManagement: Codeunit GenJnlManagement;
        CannotBeFilteredWhenRecurringErr: Label '%1 cannot be filtered when you post recurring journals.', Comment = '%1 = Filtered Field Caption';
        OneOfTwoFieldsMustBeSpecifiedErr: Label '%1 or %2 must be specified.', Comment = '%1 = First Field Caption ; %2 = Second Field Caption';
        FieldMustBeSpecifiedErr: Label '%1 must be specified.', Comment = '%1 = Field Caption';
        SumMustBeErr: Label '%1 + %2 must be %3.', Comment = '%1 = Left Operand Field Caption ; %2 = Right Operand Field Caption ; %3 = Result Field Caption';
        MustBeEmptyErr: Label '%1 must be " " when %2 is %3.', Comment = '%1 = Checked Field Caption ; %2 = Condional Field Caption ; %3 = Conditional Field Value';
        MustNotBeCompletedErr: Label '%1, %2, %3 or %4 must not be completed when %5 is %6.', Comment = '%1 = Checked Field 1 Caption ; %2 = Checked Field 2 Caption ; %3 = Checked Field 3 Caption ; %4 = Checked Field 4 Caption ; %5 = Condional Field Caption ; %6 = Conditional Field Value';
        MustBeNegativeErr: Label '%1 must be negative.', Comment = '%1 = Checked Field Caption';
        MustBePositiveErr: Label '%1 must be positive.', Comment = '%1 = Checked Field Caption';
        MustBeSameSignErr: Label '%1 must have the same sign as %2.', Comment = '%1 = Compared Field 1 Caption ; %2 = Compared Field 2 Caption';
        CannotBeSpecifiedErr: Label '%1 cannot be specified.', Comment = '%1 = Checked Field Caption';
        MustBeYesErr: Label '%1 must be Yes.', Comment = '%1 = Checked Field Caption';
        SumMustBeNegativeErr: Label '%1 + %2 must be -%3.', Comment = '%1 = Left Operand Field Caption ; %2 = Right Operand Field Caption ; %3 = Result Field Caption';
        MustHaveDifferentSignErr: Label '%1 must have a different sign than %2.', Comment = '%1 = Compared Field 1 Caption ; %2 = Compared Field 2 Caption';
        MustBeClosingDateErr: Label '%1 must only be a closing date for G/L entries.', Comment = '%1 = Date Field Caption';
        LineOrderAccordingPostingDateErr: Label 'The lines are not listed according to Posting Date because they were not entered in that order.';
        GapInNoSeriesErr: Label 'There is a gap in the number series.';
        MustBeGLBankAccErr: Label '%1 or %2 must be G/L Account or Bank Account.', Comment = '%1 = Account Type ; %2 = Balance Account Type';
        MustBeZeroErr: Label '%1 must be 0.', Comment = '%1 = Checked Field Caption';
        CannotBeSpecifiedWhenRecurringErr: Label '%1 cannot be specified when using recurring journals.', Comment = '%1 = Balance Account No.';
        MustNotBeWhenErr: Label '%1 must not be %2 when %3 = %4.', Comment = '%1 = Checked Field Caption ; %2 = Checked Field Value ; %3 = Condifional Field Caption ; %4 = Conditional Field Value';
        AllocationWithRecurringOnlyErr: Label 'Allocations can only be used with recurring journals.';
        SpecifyInAllocationLinesErr: Label 'Specify %1 in the %2 allocation lines.', Comment = '%1 = Account No. ; %2 = No. Of Allocation Lines';
        MonthTextTok: Label '<Month Text>', Locked = true;
        MustBeSeparatedByEmptyLineErr: Label '%1 %2 posted on %3, must be separated by an empty line.', Comment = '%1 = Document Type ; %2 = Document No. ; %3 = Posting Date';
        OutOfBalanceErr: Label '%1 %2 is out of balance by %3.', Comment = '%1 = Document Type ; %2 = Document No. ; %3 = Balance Amount';
        ReversingEntriesOutOfBalanceErr: Label 'The reversing entries for %1 %2 are out of balance by %3.', Comment = '%1 = Document Type ; %2 = Document No. ; %3 = Balance Amount';
        LinesOutOfBalanceErr: Label 'As of %1, the lines are out of balance by %2.', Comment = '%1 = Date ; %2 = Balance Amount';
        ReversingEntriesOutOfBalance2Err: Label 'As of %1, the reversing entries are out of balance by %2.', Comment = '%1 = Date ; %2 = Balance Amount';
        LineTotalOutOfBalanceErr: Label 'The total of the lines is out of balance by %1.', Comment = '%1 = Balance Amount';
        ReversingTotalOutOfBalanceErr: Label 'The total of the reversing entries is out of balance by %1.', Comment = '%1 = Balance Amount';
        MustBeForErr: Label '%1 must be %2 for %3 %4.', Comment = '%1 = Field Caption ; %2 = Field Value ; %3 = Table Caption ; %4 = Primary Key Value';
        RecordDoesNotExistErr: Label '%1 %2 %3 does not exist.', Comment = '%1 = Table Caption ; %2 = Primary Key Field Name ; %3 = Primary Key Field Value';
        MustBeErr: Label '%1 must be %2.', Comment = '%1 = Field Caption ; %2 = Field Value';
        CurrencyNotFoundErr: Label 'The currency %1 cannot be found. Check the currency table.', Comment = '%1 = Currency Code';
        SalesDocAlreadyExistsErr: Label 'Sales %1 %2 already exists.', Comment = '%1 = Document Type ; %2 = Document No.';
        PurchaseDocAlreadyExistsErr: Label 'Purchase %1 %2 already exists.', Comment = '%1 = Document Type ; %2 = Document No.';
        MustBeEnteredErr: Label '%1 must be entered.', Comment = '%1 = Field Caption';
        MustNotBeFilledWhenErr: Label '%1 must not be filled when %2 is different in %3 and %4.', Comment = '%1 = Check Field Caption ; %2 = Compared Field Caption; %3 = Compared Table Caption ; %4 = Compared Primary Key Value';
        MustNotHaveEqualErr: Label '%1 %2 must not have %3 = %4.', Comment = '%1 = Table Caption ; %2 = Primary Key Value ; %3 = Checked Field Caption ; %4 = Checked Field Value';
        MustNotBeSpecifiedInFAJnlErr: Label '%1 must not be specified in fixed asset journal lines.', Comment = '%1 = Job No. Field Caption';
        MustBeSpecifiedInFAJnlErr: Label '%1 must be specified in fixed asset journal lines.', Comment = '%1 = Checked Field Caption';
        MustBeDifferentThanErr: Label '%1 must be different than %2.', Comment = '%1 = Field Caption ; %2 = Compared Field Caption';
        MustNotBothBeErr: Label '%1 and %2 must not both be %3.', Comment = '%1 = Account Type Field Caption ; %2 = Bal. Account Type Field Caption ; %3 = Account Type Field Value';
        MustNotBeSpecifiedWhenErr: Label '%1 must not be specified when %2 = %3.', Comment = '%1 = Checked Field Caption ; %2 = Conditional Field Caption ; %3 = Conditional Field Value';
        MustNotBeSpecifiedTogetherErr: Label 'must not be specified together with %1 = %2.', Comment = '%1 = Field Caption ; %2 = Field Value';
        MustBeIdenticalErr: Label '%1 must be identical to %2.', Comment = '%1 = Field Caption ; %2 = Identical Field Caption';
        CannotBeClosingDateErr: Label '%1 cannot be a closing date.', Comment = '%1 = Date Field Caption';
        PostingDateNotInRangeErr: Label '%1 is not within your range of allowed posting dates.', Comment = '%1 = Date Field Caption';
        InsuranceIntegrationNotActiveErr: Label 'Insurance integration is not activated for %1 %2.', Comment = '%1 = Field Caption ; %3 = Field Value';
        MustNotBeSpecifiedWhen2Err: Label 'must not be specified when %1 is specified.', Comment = '%1 = Field Caption';
        MustNotBePostedWhenGLIntegrationErr: Label 'When G/L integration is not activated, %1 must not be posted in the general journal.', Comment = '%1 = FA Posting Type';
        MustNotBeSpecWhenGLIntegrationErr: Label 'When G/L integration is not activated, %1 must not be specified in the general journal.', Comment = '%1 = Field Caption';
        MustNotBeSpecifiedErr: Label '%1 must not be specified.', Comment = '%1 = Field Caption';
        CustGenPostTypeCombinationErr: Label 'The combination of Customer and Gen. Posting Type Purchase is not allowed.';
        VendGenPostTypeCombinationErr: Label 'The combination of Vendor and Gen. Posting Type Sales is not allowed.';
        BalanceMethodsOnlyWithAllocErr: Label 'The Balance and Reversing Balance recurring methods can be used only with Allocations.';
        MustNotBeZeroErr: Label '%1 must not be 0.', Comment = '%1 = Field Caption';
        GenJnlLineFilter: Text;
        AllowFAPostingFrom: Date;
        AllowFAPostingTo: Date;
        LastDate: Date;
        LastDocType: Enum "Gen. Journal Document Type";
        LastDocNo: Code[20];
        LastEnteredDocNo: Code[20];
        LastEntrdDate: Date;
        BalanceLCY: Decimal;
        AmountLCY: Decimal;
        DocBalanceReverse: Decimal;
        DateBalanceReverse: Decimal;
        TotalBalanceReverse: Decimal;
        AccNameGlobal: Text[100];
        LastLineNo: Integer;
        Day: Integer;
        Week: Integer;
        Month: Integer;
        MonthText: Text[30];
        AmountError: Boolean;
        ErrorCounter: Integer;
        ErrorText: array[50] of Text[250];
        TempErrorText: Text[250];
        BalAccName: Text[100];
        VATEntryCreated: Boolean;
        CustPosting: Boolean;
        VendPosting: Boolean;
        SalesPostingType: Boolean;
        PurchPostingType: Boolean;
        DimText: Text[75];
        AllocationDimText: Text[75];
        ShouldShowDim: Boolean;
        Continue: Boolean;
        DocTypesTxt: Label 'Document,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund';
        AlreadyUsedInLineErr: Label '%1 %2 is already used in line %3 (%4 %5).', Comment = '%1 = External Document No. Caption ; %2 = External Document No. ; %3 = Line No. ; %4 = Document Type Caption ; %5 = Document Type';
        MustNotBeBlockedTypeErr: Label '%1 must not be blocked with type %2 when %3 is %4.', Comment = '%1 = Account Type ; %2 = Account No. ; %3 = Blocked Type ; %4 = Document Type ; %5 = Document No.';
        CurrentICPartner: Code[20];
        CannotEnterGLBankAccErr: Label 'You cannot enter G/L Account or Bank Account in both %1 and %2.', Comment = '%1 = Account No. Field Caption ; %2 = Bal. Account No. Field Caption';
        IsLinkedToErr: Label '%1 %2 is linked to %3 %4.', Comment = '%1 = Table Caption ; %2 = Primary Key Value ; %3 = Linked Table Caption ; %4 = Linked Primary Key Value';
        MustNotBeSpecifiedWhenIsErr: Label '%1 must not be specified when %2 is %3.', Comment = '%1 = Checked Field Caption ; %2 = Conditional Field Caption ; %3 = Conditional Field Value';
        MustNotBeSpecifiedWhenInterDocErr: Label '%1 must not be specified when the document is not an intercompany transaction.', Comment = '%1 = Field Caption';
        MasterRecDoesNotExistErr: Label '%1 %2 does not exist.', Comment = '%1 = Table Caption ; %2 = Primary Key Value';
        MustNotBeFor4Err: Label '%1 must not be %2 for %3 %4.', Comment = '%1 = Checked Field Caption ; %2 = Checked Field Value ; %3 = Table Caption ; %4 = Primary Key Value';
        AlreadyExistsErr: Label '%1 %2 already exists.', Comment = '%1 = Field Caption ; %2 = Field Value';
        GeneralJnlTestLbl: Label 'General Journal - Test';
        PageNoLbl: Label 'Page';
        JnlBatchNameLbl: Label 'Journal Batch';
        PostingDateLbl: Label 'Posting Date';
        DocumentTypeLbl: Label 'Document Type';
        AccountTypeLbl: Label 'Account Type';
        AccNameLbl: Label 'Name';
        GenPostingTypeLbl: Label 'Gen. Posting Type';
        GenBusPostingGroupLbl: Label 'Gen. Bus. Posting Group';
        GenProdPostingGroupLbl: Label 'Gen. Prod. Posting Group';
        AmountLCYLbl: Label 'Total (LCY)';
        DimensionsLbl: Label 'Dimensions';
        WarningLbl: Label 'Warning!';
        ReconciliationLbl: Label 'Reconciliation';
        NoLbl: Label 'No.';
        NameLbl: Label 'Name';
        NetChangeinJnlLbl: Label 'Net Change in Jnl.';
        BalafterPostingLbl: Label 'Balance after Posting';
        DimensionAllocationsLbl: Label 'Allocation Dimensions';
        DimCodeValueTextTok: Label '%1 - %2', Comment = '%1 = Dimension Code ; %2 = Dimension Value Code', Locked = true;
        TwoTextsWithSpaceTok: Label '%1 %2', Comment = '%1 = First Text ; %2 = Second Text', Locked = true;

    local procedure CheckRecurringLine(GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalTemplate.Recurring then begin
            if GenJournalLine."Recurring Method" = "Gen. Journal Recurring Method"::" " then
                AddError(StrSubstNo(FieldMustBeSpecifiedErr, GenJournalLine.FieldCaption(GenJournalLine."Recurring Method")));
            if Format(GenJournalLine."Recurring Frequency") = '' then
                AddError(StrSubstNo(FieldMustBeSpecifiedErr, GenJournalLine.FieldCaption(GenJournalLine."Recurring Frequency")));
            if GenJournalLine."Bal. Account No." <> '' then
                AddError(
                  StrSubstNo(
                    CannotBeSpecifiedWhenRecurringErr,
                    GenJournalLine.FieldCaption(GenJournalLine."Bal. Account No.")));
            case GenJournalLine."Recurring Method" of
                GenJournalLine."Recurring Method"::"V  Variable", GenJournalLine."Recurring Method"::"RV Reversing Variable",
              GenJournalLine."Recurring Method"::"F  Fixed", GenJournalLine."Recurring Method"::"RF Reversing Fixed":
                    WarningIfZeroAmt("Gen. Journal Line");
                GenJournalLine."Recurring Method"::"B  Balance", GenJournalLine."Recurring Method"::"RB Reversing Balance":
                    WarningIfNonZeroAmt("Gen. Journal Line");
            end;
            if GenJournalLine."Recurring Method".AsInteger() > GenJournalLine."Recurring Method"::"V  Variable".AsInteger() then begin
                if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Fixed Asset" then
                    AddError(
                      StrSubstNo(
                        MustNotBeWhenErr,
                        GenJournalLine.FieldCaption(GenJournalLine."Recurring Method"), GenJournalLine."Recurring Method",
                        GenJournalLine.FieldCaption(GenJournalLine."Account Type"), GenJournalLine."Account Type"));
                if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Fixed Asset" then
                    AddError(
                      StrSubstNo(
                        MustNotBeWhenErr,
                        GenJournalLine.FieldCaption(GenJournalLine."Recurring Method"), GenJournalLine."Recurring Method",
                        GenJournalLine.FieldCaption(GenJournalLine."Bal. Account Type"), GenJournalLine."Bal. Account Type"));
            end;
        end else begin
            if GenJournalLine."Recurring Method" <> "Gen. Journal Recurring Method"::" " then
                AddError(StrSubstNo(CannotBeSpecifiedErr, GenJournalLine.FieldCaption(GenJournalLine."Recurring Method")));
            if Format(GenJournalLine."Recurring Frequency") <> '' then
                AddError(StrSubstNo(CannotBeSpecifiedErr, GenJournalLine.FieldCaption(GenJournalLine."Recurring Frequency")));
        end;
    end;

    local procedure CheckAllocations(GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."Recurring Method" in [GenJournalLine."Recurring Method"::"B  Balance", GenJournalLine."Recurring Method"::"RB Reversing Balance"] then begin
            GenJnlAllocation.Reset();
            GenJnlAllocation.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
            GenJnlAllocation.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
            GenJnlAllocation.SetRange("Journal Line No.", GenJournalLine."Line No.");
            if not GenJnlAllocation.FindFirst() then
                AddError(BalanceMethodsOnlyWithAllocErr);
        end;

        GenJnlAllocation.Reset();
        GenJnlAllocation.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        GenJnlAllocation.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        GenJnlAllocation.SetRange("Journal Line No.", GenJournalLine."Line No.");
        GenJnlAllocation.SetFilter(Amount, '<>0');
        if GenJnlAllocation.FindFirst() then
            if not GenJournalTemplate.Recurring then
                AddError(AllocationWithRecurringOnlyErr)
            else begin
                GenJnlAllocation.SetRange("Account No.", '');
                if GenJnlAllocation.FindFirst() then
                    AddError(
                      StrSubstNo(
                        SpecifyInAllocationLinesErr,
                        GenJnlAllocation.FieldCaption("Account No."), GenJnlAllocation.Count()));
            end;

    end;

    local procedure MakeRecurringTexts(var GenJournalLine: Record "Gen. Journal Line")
    begin
        if (GenJournalLine."Posting Date" <> 0D) and (GenJournalLine."Account No." <> '') and (GenJournalLine."Recurring Method" <> "Gen. Journal Recurring Method"::" ") then begin
            Day := Date2DMY(GenJournalLine."Posting Date", 1);
            Week := Date2DWY(GenJournalLine."Posting Date", 2);
            Month := Date2DMY(GenJournalLine."Posting Date", 2);
            MonthText := Format(GenJournalLine."Posting Date", 0, MonthTextTok);
            AccountingPeriod.SetRange("Starting Date", 0D, GenJournalLine."Posting Date");
            if not AccountingPeriod.FindLast() then
                AccountingPeriod.Name := '';
            GenJournalLine."Document No." :=
                CopyStr(
                    DelChr(
                        PadStr(
                        StrSubstNo(GenJournalLine."Document No.", Day, Week, Month, MonthText, AccountingPeriod.Name),
                        MaxStrLen(GenJournalLine."Document No.")),
                        '>'),
                    1, MaxStrLen(GenJournalLine."Document No."));
            GenJournalLine.Description :=
                CopyStr(
                    DelChr(
                        PadStr(
                        StrSubstNo(GenJournalLine.Description, Day, Week, Month, MonthText, AccountingPeriod.Name),
                        MaxStrLen(GenJournalLine.Description)),
                        '>'),
                    1, MaxStrLen(GenJournalLine.Description));
        end;
    end;

    local procedure CheckBalance()
    var
        BalanceGenJournalLine: Record "Gen. Journal Line";
        NextGenJournalLine: Record "Gen. Journal Line";
        DocBalance: Decimal;
        DateBalance: Decimal;
        TotalBalance: Decimal;
    begin
        BalanceGenJournalLine.Copy("Gen. Journal Line");
        LastLineNo := "Gen. Journal Line"."Line No.";
        NextGenJournalLine.Copy("Gen. Journal Line");
        NextGenJournalLine.SetRange("Journal Template Name", BalanceGenJournalLine."Journal Template Name");
        NextGenJournalLine.SetRange("Journal Batch Name", BalanceGenJournalLine."Journal Batch Name");
        if NextGenJournalLine.Next() = 0 then;
        MakeRecurringTexts(NextGenJournalLine);
        if not BalanceGenJournalLine.EmptyLine() then begin
            DocBalance := CalculateDocBalance(BalanceGenJournalLine);
            DateBalance := CalculateDateBalance(BalanceGenJournalLine);
            TotalBalance := CalculateTotalBalance(BalanceGenJournalLine);
            if BalanceGenJournalLine."Recurring Method".AsInteger() >= BalanceGenJournalLine."Recurring Method"::"RF Reversing Fixed".AsInteger() then begin
                DocBalanceReverse := DocBalanceReverse + BalanceGenJournalLine."Balance (LCY)";
                DateBalanceReverse := DateBalanceReverse + BalanceGenJournalLine."Balance (LCY)";
                TotalBalanceReverse := TotalBalanceReverse + BalanceGenJournalLine."Balance (LCY)";
            end;
            LastDocType := BalanceGenJournalLine."Document Type";
            LastDocNo := BalanceGenJournalLine."Document No.";
            LastDate := BalanceGenJournalLine."Posting Date";
            if TotalBalance = 0 then
                VATEntryCreated := false;
            if GenJournalTemplate."Force Doc. Balance" then begin
                VATEntryCreated :=
                  VATEntryCreated or
                  ((BalanceGenJournalLine."Account Type" = BalanceGenJournalLine."Account Type"::"G/L Account") and (BalanceGenJournalLine."Account No." <> '') and
                   (BalanceGenJournalLine."Gen. Posting Type" in [BalanceGenJournalLine."Gen. Posting Type"::Purchase, BalanceGenJournalLine."Gen. Posting Type"::Sale])) or
                  ((BalanceGenJournalLine."Bal. Account Type" = BalanceGenJournalLine."Bal. Account Type"::"G/L Account") and (BalanceGenJournalLine."Bal. Account No." <> '') and
                   (BalanceGenJournalLine."Bal. Gen. Posting Type" in [BalanceGenJournalLine."Bal. Gen. Posting Type"::Purchase, BalanceGenJournalLine."Bal. Gen. Posting Type"::Sale]));
                TempCustVendICGenJournalLine.IsCustVendICAdded(BalanceGenJournalLine);
                if (TempCustVendICGenJournalLine.Count > 1) and VATEntryCreated then
                    AddError(
                      StrSubstNo(
                        MustBeSeparatedByEmptyLineErr,
                        BalanceGenJournalLine."Document Type", BalanceGenJournalLine."Document No.", BalanceGenJournalLine."Posting Date"));
            end;
        end;

        if (LastDate <> 0D) and (LastDocNo <> '') and
            ((NextGenJournalLine."Posting Date" <> LastDate) or
            ((NextGenJournalLine."Document Type" <> LastDocType) and (not GenJournalTemplate."Not Check Doc. Type CZL")) or
            (NextGenJournalLine."Document No." <> LastDocNo) or
            (NextGenJournalLine."Line No." = LastLineNo))
        then begin
            if GenJournalTemplate."Force Doc. Balance" then begin
                case true of
                    DocBalance <> 0:
                        AddError(
                          StrSubstNo(
                            OutOfBalanceErr,
                            SelectStr(LastDocType.AsInteger() + 1, DocTypesTxt), LastDocNo, DocBalance));
                    DocBalanceReverse <> 0:
                        AddError(
                          StrSubstNo(
                            ReversingEntriesOutOfBalanceErr,
                            SelectStr(LastDocType.AsInteger() + 1, DocTypesTxt), LastDocNo, DocBalanceReverse));
                end;
                DocBalanceReverse := 0;
            end;
            if (NextGenJournalLine."Posting Date" <> LastDate) or
               (NextGenJournalLine."Document Type" <> LastDocType) or (NextGenJournalLine."Document No." <> LastDocNo)
            then begin
                TempCustVendICGenJournalLine.Reset();
                TempCustVendICGenJournalLine.DeleteAll();
                VATEntryCreated := false;
                CustPosting := false;
                VendPosting := false;
                SalesPostingType := false;
                PurchPostingType := false;
            end;
        end;

        if (LastDate <> 0D) and ((NextGenJournalLine."Posting Date" <> LastDate) or (NextGenJournalLine."Line No." = LastLineNo)) then begin
            case true of
                DateBalance <> 0:
                    AddError(
                      StrSubstNo(
                        LinesOutOfBalanceErr,
                        LastDate, DateBalance));
                DateBalanceReverse <> 0:
                    AddError(
                      StrSubstNo(
                        ReversingEntriesOutOfBalance2Err,
                        LastDate, DateBalanceReverse));
            end;
            DocBalanceReverse := 0;
            DateBalanceReverse := 0;
        end;

        if NextGenJournalLine."Line No." = LastLineNo then begin
            case true of
                TotalBalance <> 0:
                    AddError(
                      StrSubstNo(
                        LineTotalOutOfBalanceErr,
                        TotalBalance));
                TotalBalanceReverse <> 0:
                    AddError(
                      StrSubstNo(
                        ReversingTotalOutOfBalanceErr,
                        TotalBalanceReverse));
            end;
            DocBalanceReverse := 0;
            DateBalanceReverse := 0;
            TotalBalanceReverse := 0;
            LastDate := 0D;
            LastDocType := LastDocType::" ";
            LastDocNo := '';
        end;

    end;

    local procedure CheckDimensions(GenJournalLine: Record "Gen. Journal Line")
    var
        DimensionManagement: Codeunit DimensionManagement;
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        if not DimensionManagement.CheckDimIDComb(GenJournalLine."Dimension Set ID") then
            AddError(DimensionManagement.GetDimCombErr());

        TableID[1] := DimensionManagement.TypeToTableID1(GenJournalLine."Account Type".AsInteger());
        No[1] := GenJournalLine."Account No.";
        TableID[2] := DimensionManagement.TypeToTableID1(GenJournalLine."Bal. Account Type".AsInteger());
        No[2] := GenJournalLine."Bal. Account No.";
        TableID[3] := Database::Job;
        No[3] := GenJournalLine."Job No.";
        TableID[4] := Database::"Salesperson/Purchaser";
        No[4] := GenJournalLine."Salespers./Purch. Code";
        TableID[5] := Database::Campaign;
        No[5] := GenJournalLine."Campaign No.";
        OnAfterAssignDimTableID(GenJournalLine, TableID, No);

        if not DimensionManagement.CheckDimValuePosting(TableID, No, GenJournalLine."Dimension Set ID") then
            AddError(DimensionManagement.GetDimValuePostingErr());
    end;

    local procedure CalculateDocBalance(GenJournalLine: Record "Gen. Journal Line"): Decimal
    var
        DocBalanceGenJournalLine: Record "Gen. Journal Line";
    begin
        DocBalanceGenJournalLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        DocBalanceGenJournalLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        DocBalanceGenJournalLine.SetRange("Document Type", GenJournalLine."Document Type");
        DocBalanceGenJournalLine.SetRange("Document No.", GenJournalLine."Document No.");
        DocBalanceGenJournalLine.CalcSums("Balance (LCY)");
        exit(DocBalanceGenJournalLine."Balance (LCY)");
    end;

    local procedure CalculateDateBalance(GenJournalLine: Record "Gen. Journal Line"): Decimal
    var
        DateBalanceGenJournalLine: Record "Gen. Journal Line";
    begin
        DateBalanceGenJournalLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        DateBalanceGenJournalLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        DateBalanceGenJournalLine.SetRange("Posting Date", GenJournalLine."Posting Date");
        DateBalanceGenJournalLine.CalcSums("Balance (LCY)");
        exit(DateBalanceGenJournalLine."Balance (LCY)");
    end;

    local procedure CalculateTotalBalance(GenJournalLine: Record "Gen. Journal Line"): Decimal
    var
        TotalBalanceGenJournalLine: Record "Gen. Journal Line";
    begin
        TotalBalanceGenJournalLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        TotalBalanceGenJournalLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        TotalBalanceGenJournalLine.CalcSums("Balance (LCY)");
        exit(TotalBalanceGenJournalLine."Balance (LCY)");
    end;

    procedure AddError(Text: Text[250])
    begin
        ErrorCounter := ErrorCounter + 1;
        ErrorText[ErrorCounter] := Text;
    end;

    local procedure ReconcileGLAccNo(GLAccNo: Code[20]; ReconcileAmount: Decimal)
    begin
        if not TempGLAccountNetChange.Get(GLAccNo) then begin
            GLAccount.Get(GLAccNo);
            GLAccount.CalcFields("Balance at Date");
            TempGLAccountNetChange.Init();
            TempGLAccountNetChange."No." := GLAccount."No.";
            TempGLAccountNetChange.Name := GLAccount.Name;
            TempGLAccountNetChange."Balance after Posting" := GLAccount."Balance at Date";
            TempGLAccountNetChange.Insert();
        end;
        TempGLAccountNetChange."Net Change in Jnl." := TempGLAccountNetChange."Net Change in Jnl." + ReconcileAmount;
        TempGLAccountNetChange."Balance after Posting" := TempGLAccountNetChange."Balance after Posting" + ReconcileAmount;
        TempGLAccountNetChange.Modify();
    end;

    local procedure CheckGLAcc(var GenJournalLine: Record "Gen. Journal Line"; var AccName: Text[100])
    begin
        if not GLAccount.Get(GenJournalLine."Account No.") then
            AddError(
              StrSubstNo(
                MasterRecDoesNotExistErr,
                GLAccount.TableCaption, GenJournalLine."Account No."))
        else begin
            AccName := GLAccount.Name;

            if GLAccount.Blocked then
                AddError(
                  StrSubstNo(
                    MustBeForErr,
                    GLAccount.FieldCaption(Blocked), false, GLAccount.TableCaption, GenJournalLine."Account No."));
            if GLAccount."Account Type" <> GLAccount."Account Type"::Posting then begin
                GLAccount."Account Type" := GLAccount."Account Type"::Posting;
                AddError(
                  StrSubstNo(
                    MustBeForErr,
                    GLAccount.FieldCaption("Account Type"), GLAccount."Account Type", GLAccount.TableCaption, GenJournalLine."Account No."));
            end;
            if not GenJournalLine."System-Created Entry" then
                if GenJournalLine."Posting Date" = NormalDate(GenJournalLine."Posting Date") then
                    if not GLAccount."Direct Posting" then
                        AddError(
                          StrSubstNo(
                            MustBeForErr,
                            GLAccount.FieldCaption("Direct Posting"), true, GLAccount.TableCaption, GenJournalLine."Account No."));

            if GenJournalLine."Gen. Posting Type" <> GenJournalLine."Gen. Posting Type"::" " then begin
                case GenJournalLine."Gen. Posting Type" of
                    GenJournalLine."Gen. Posting Type"::Sale:
                        SalesPostingType := true;
                    GenJournalLine."Gen. Posting Type"::Purchase:
                        PurchPostingType := true;
                end;
                TestPostingType();

                if not VATPostingSetup.Get(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group") then
                    AddError(
                      StrSubstNo(
                        RecordDoesNotExistErr,
                        VATPostingSetup.TableCaption, GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group"))
                else
                    if GenJournalLine."VAT Calculation Type" <> VATPostingSetup."VAT Calculation Type" then
                        AddError(
                          StrSubstNo(
                            MustBeErr,
                            GenJournalLine.FieldCaption(GenJournalLine."VAT Calculation Type"), VATPostingSetup."VAT Calculation Type"))
            end;

            if GLAccount."Reconciliation Account" then
                ReconcileGLAccNo(GenJournalLine."Account No.", Round(GenJournalLine."Amount (LCY)" / (1 + GenJournalLine."VAT %" / 100)));

            OnAfterCheckGLAcc(GenJournalLine, GLAccount, ErrorCounter, ErrorText);
        end;
    end;

    local procedure CheckCust(var GenJournalLine: Record "Gen. Journal Line"; var AccName: Text[100])
    begin
        if not Customer.Get(GenJournalLine."Account No.") then
            AddError(
              StrSubstNo(
                MasterRecDoesNotExistErr,
                Customer.TableCaption, GenJournalLine."Account No."))
        else begin
            AccName := Customer.Name;
            if Customer."Privacy Blocked" then
                AddError(Customer.GetPrivacyBlockedGenericErrorText(Customer));
            if ((Customer.Blocked = Customer.Blocked::All) or
                ((Customer.Blocked = Customer.Blocked::Invoice) and
                 (GenJournalLine."Document Type" in [GenJournalLine."Document Type"::Invoice, GenJournalLine."Document Type"::" "]))
                )
            then
                AddError(
                  StrSubstNo(
                    MustNotBeBlockedTypeErr,
                    GenJournalLine."Account Type", Customer.Blocked, GenJournalLine.FieldCaption(GenJournalLine."Document Type"), GenJournalLine."Document Type"));
            if GenJournalLine."Currency Code" <> '' then
                if not Currency.Get(GenJournalLine."Currency Code") then
                    AddError(
                      StrSubstNo(
                        CurrencyNotFoundErr,
                        GenJournalLine."Currency Code"));
            if (Customer."IC Partner Code" <> '') and (GenJournalTemplate.Type = GenJournalTemplate.Type::Intercompany) then
                if ICPartner.Get(Customer."IC Partner Code") then begin
                    if ICPartner.Blocked then
                        AddError(
                          StrSubstNo(
                            TwoTextsWithSpaceTok,
                            StrSubstNo(
                              IsLinkedToErr,
                              Customer.TableCaption, GenJournalLine."Account No.", ICPartner.TableCaption, GenJournalLine."IC Partner Code"),
                            StrSubstNo(
                              MustBeForErr,
                              ICPartner.FieldCaption(Blocked), false, ICPartner.TableCaption, Customer."IC Partner Code")));
                end else
                    AddError(
                      StrSubstNo(
                        TwoTextsWithSpaceTok,
                        StrSubstNo(
                          IsLinkedToErr,
                          Customer.TableCaption, GenJournalLine."Account No.", ICPartner.TableCaption, Customer."IC Partner Code"),
                        StrSubstNo(
                          MasterRecDoesNotExistErr,
                          ICPartner.TableCaption, Customer."IC Partner Code")));
            CustPosting := true;
            TestPostingType();

            if GenJournalLine."Recurring Method" = "Gen. Journal Recurring Method"::" " then
                if GenJournalLine."Document Type" in
                   [GenJournalLine."Document Type"::Invoice, GenJournalLine."Document Type"::"Credit Memo",
                    GenJournalLine."Document Type"::"Finance Charge Memo", GenJournalLine."Document Type"::Reminder]
                then begin
                    OldCustLedgerEntry.Reset();
                    OldCustLedgerEntry.SetCurrentKey("Document No.");
                    OldCustLedgerEntry.SetRange("Document Type", GenJournalLine."Document Type");
                    OldCustLedgerEntry.SetRange("Document No.", GenJournalLine."Document No.");
                    if OldCustLedgerEntry.FindFirst() then
                        AddError(
                          StrSubstNo(
                            SalesDocAlreadyExistsErr, GenJournalLine."Document Type", GenJournalLine."Document No."));

                    if SalesReceivablesSetup."Ext. Doc. No. Mandatory" or
                       (GenJournalLine."External Document No." <> '')
                    then begin
                        if GenJournalLine."External Document No." = '' then
                            AddError(
                              StrSubstNo(
                                MustBeEnteredErr, GenJournalLine.FieldCaption(GenJournalLine."External Document No.")));

                        OldCustLedgerEntry.Reset();
                        OldCustLedgerEntry.SetCurrentKey("External Document No.");
                        OldCustLedgerEntry.SetRange("Document Type", GenJournalLine."Document Type");
                        OldCustLedgerEntry.SetRange("Customer No.", GenJournalLine."Account No.");
                        OldCustLedgerEntry.SetRange("External Document No.", GenJournalLine."External Document No.");
                        if OldCustLedgerEntry.FindFirst() then
                            AddError(
                              StrSubstNo(
                                SalesDocAlreadyExistsErr,
                                GenJournalLine."Document Type", GenJournalLine."External Document No."));
                        CheckAgainstPrevLines("Gen. Journal Line");
                    end;
                end;
        end;
    end;

    local procedure CheckVend(var GenJournalLine: Record "Gen. Journal Line"; var AccName: Text[100])
    var
        VendorMgt: Codeunit "Vendor Mgt.";
    begin
        if not Vendor.Get(GenJournalLine."Account No.") then
            AddError(
              StrSubstNo(
                MasterRecDoesNotExistErr,
                Vendor.TableCaption, GenJournalLine."Account No."))
        else begin
            AccName := Vendor.Name;
            if Vendor."Privacy Blocked" then
                AddError(Vendor.GetPrivacyBlockedGenericErrorText(Vendor));
            if ((Vendor.Blocked = Vendor.Blocked::All) or
                ((Vendor.Blocked = Vendor.Blocked::Payment) and (GenJournalLine."Document Type" = GenJournalLine."Document Type"::Payment))
                )
            then
                AddError(
                  StrSubstNo(
                    MustNotBeBlockedTypeErr,
                    GenJournalLine."Account Type", Vendor.Blocked, GenJournalLine.FieldCaption(GenJournalLine."Document Type"), GenJournalLine."Document Type"));
            if GenJournalLine."Currency Code" <> '' then
                if not Currency.Get(GenJournalLine."Currency Code") then
                    AddError(
                      StrSubstNo(
                        CurrencyNotFoundErr,
                        GenJournalLine."Currency Code"));

            if (Vendor."IC Partner Code" <> '') and (GenJournalTemplate.Type = GenJournalTemplate.Type::Intercompany) then
                if ICPartner.Get(Vendor."IC Partner Code") then begin
                    if ICPartner.Blocked then
                        AddError(
                          StrSubstNo(
                            TwoTextsWithSpaceTok,
                            StrSubstNo(
                              IsLinkedToErr,
                              Vendor.TableCaption, GenJournalLine."Account No.", ICPartner.TableCaption, Vendor."IC Partner Code"),
                            StrSubstNo(
                              MustBeForErr,
                              ICPartner.FieldCaption(Blocked), false, ICPartner.TableCaption, Vendor."IC Partner Code")));
                end else
                    AddError(
                      StrSubstNo(
                        TwoTextsWithSpaceTok,
                        StrSubstNo(
                          IsLinkedToErr,
                          Vendor.TableCaption, GenJournalLine."Account No.", ICPartner.TableCaption, GenJournalLine."IC Partner Code"),
                        StrSubstNo(
                          MasterRecDoesNotExistErr,
                          ICPartner.TableCaption, Vendor."IC Partner Code")));
            VendPosting := true;
            TestPostingType();

            if GenJournalLine."Recurring Method" = "Gen. Journal Recurring Method"::" " then
                if GenJournalLine."Document Type" in
                   [GenJournalLine."Document Type"::Invoice, GenJournalLine."Document Type"::"Credit Memo",
                    GenJournalLine."Document Type"::"Finance Charge Memo", GenJournalLine."Document Type"::Reminder]
                then begin
                    OldVendorLedgerEntry.Reset();
                    OldVendorLedgerEntry.SetCurrentKey("Document No.");
                    OldVendorLedgerEntry.SetRange("Document Type", GenJournalLine."Document Type");
                    OldVendorLedgerEntry.SetRange("Document No.", GenJournalLine."Document No.");
                    if OldVendorLedgerEntry.FindFirst() then
                        AddError(
                          StrSubstNo(
                            PurchaseDocAlreadyExistsErr,
                            GenJournalLine."Document Type", GenJournalLine."Document No."));

                    if PurchasesPayablesSetup."Ext. Doc. No. Mandatory" or
                       (GenJournalLine."External Document No." <> '')
                    then begin
                        if GenJournalLine."External Document No." = '' then
                            AddError(
                              StrSubstNo(
                                MustBeEnteredErr, GenJournalLine.FieldCaption(GenJournalLine."External Document No.")));

                        OldVendorLedgerEntry.Reset();
                        OldVendorLedgerEntry.SetCurrentKey("External Document No.");
                        VendorMgt.SetFilterForExternalDocNo(
                          OldVendorLedgerEntry, GenJournalLine."Document Type", GenJournalLine."External Document No.", GenJournalLine."Account No.", GenJournalLine."Document Date");
                        if OldVendorLedgerEntry.FindFirst() then
                            AddError(
                              StrSubstNo(
                                PurchaseDocAlreadyExistsErr,
                                GenJournalLine."Document Type", GenJournalLine."External Document No."))
                        else
                            CheckExtDocNoInPostedPurchDoc(GenJournalLine);
                        CheckAgainstPrevLines("Gen. Journal Line");
                    end;
                end;
        end;
    end;

    local procedure CheckEmployee(var GenJournalLine: Record "Gen. Journal Line"; var AccName: Text[100])
    begin
        if not Employee.Get(GenJournalLine."Account No.") then
            AddError(StrSubstNo(MasterRecDoesNotExistErr, Employee.TableCaption, GenJournalLine."Account No."))
        else begin
            AccName := Employee."No.";
            if Employee."Privacy Blocked" then
                AddError(StrSubstNo(MustBeForErr, Employee.FieldCaption("Privacy Blocked"), false, Employee.TableCaption, AccName))
        end;
    end;

    local procedure CheckBankAcc(var GenJournalLine: Record "Gen. Journal Line"; var AccName: Text[100])
    begin
        if not BankAccount.Get(GenJournalLine."Account No.") then
            AddError(
              StrSubstNo(
                MasterRecDoesNotExistErr,
                BankAccount.TableCaption, GenJournalLine."Account No."))
        else begin
            AccName := BankAccount.Name;

            if BankAccount.Blocked then
                AddError(
                  StrSubstNo(
                    MustBeForErr,
                    BankAccount.FieldCaption(Blocked), false, BankAccount.TableCaption, GenJournalLine."Account No."));
            if (GenJournalLine."Currency Code" <> BankAccount."Currency Code") and (BankAccount."Currency Code" <> '') then
                AddError(
                  StrSubstNo(
                    MustBeErr,
                    GenJournalLine.FieldCaption(GenJournalLine."Currency Code"), BankAccount."Currency Code"));

            if GenJournalLine."Currency Code" <> '' then
                if not Currency.Get(GenJournalLine."Currency Code") then
                    AddError(
                      StrSubstNo(
                        CurrencyNotFoundErr,
                        GenJournalLine."Currency Code"));

            if GenJournalLine."Bank Payment Type" <> GenJournalLine."Bank Payment Type"::" " then
                if (GenJournalLine."Bank Payment Type" = GenJournalLine."Bank Payment Type"::"Computer Check") and (GenJournalLine.Amount < 0) then
                    if BankAccount."Currency Code" <> GenJournalLine."Currency Code" then
                        AddError(
                          StrSubstNo(
                            MustNotBeFilledWhenErr,
                            GenJournalLine.FieldCaption(GenJournalLine."Bank Payment Type"), GenJournalLine.FieldCaption(GenJournalLine."Currency Code"),
                            GenJournalLine.TableCaption, BankAccount.TableCaption));

            if BankAccountPostingGroup.Get(BankAccount."Bank Acc. Posting Group") then
                if BankAccountPostingGroup."G/L Account No." <> '' then
                    ReconcileGLAccNo(
                      BankAccountPostingGroup."G/L Account No.",
                      Round(GenJournalLine."Amount (LCY)" / (1 + GenJournalLine."VAT %" / 100)));
        end;
    end;

    local procedure CheckFixedAsset(var GenJournalLine: Record "Gen. Journal Line"; var AccName: Text[100])
    begin
        if not FixedAsset.Get(GenJournalLine."Account No.") then
            AddError(
              StrSubstNo(
                MasterRecDoesNotExistErr,
                FixedAsset.TableCaption, GenJournalLine."Account No."))
        else begin
            AccName := FixedAsset.Description;
            if FixedAsset.Blocked then
                AddError(
                  StrSubstNo(
                    MustBeForErr,
                    FixedAsset.FieldCaption(Blocked), false, FixedAsset.TableCaption, GenJournalLine."Account No."));
            if FixedAsset.Inactive then
                AddError(
                  StrSubstNo(
                    MustBeForErr,
                    FixedAsset.FieldCaption(Inactive), false, FixedAsset.TableCaption, GenJournalLine."Account No."));
            if FixedAsset."Budgeted Asset" then
                AddError(
                  StrSubstNo(
                    MustNotHaveEqualErr,
                    FixedAsset.TableCaption, GenJournalLine."Account No.", FixedAsset.FieldCaption("Budgeted Asset"), true));
            if DepreciationBook.Get(GenJournalLine."Depreciation Book Code") then
                CheckFAIntegration(GenJournalLine)
            else
                AddError(
                  StrSubstNo(
                    MasterRecDoesNotExistErr,
                    DepreciationBook.TableCaption, GenJournalLine."Depreciation Book Code"));
            if not FADepreciationBook.Get(FixedAsset."No.", GenJournalLine."Depreciation Book Code") then
                AddError(
                  StrSubstNo(
                    RecordDoesNotExistErr,
                    FADepreciationBook.TableCaption, FixedAsset."No.", GenJournalLine."Depreciation Book Code"));
        end;
    end;

    local procedure CheckICPartner(var GenJournalLine: Record "Gen. Journal Line"; var AccName: Text[100])
    begin
        if not ICPartner.Get(GenJournalLine."Account No.") then
            AddError(
              StrSubstNo(
                MasterRecDoesNotExistErr,
                ICPartner.TableCaption, GenJournalLine."Account No."))
        else begin
            AccName := ICPartner.Name;
            if ICPartner.Blocked then
                AddError(
                  StrSubstNo(
                    MustBeForErr,
                    ICPartner.FieldCaption(Blocked), false, ICPartner.TableCaption, GenJournalLine."Account No."));
        end;
    end;

    local procedure TestFixedAsset(var GenJournalLine: Record "Gen. Journal Line")
    begin
        FASetup.Get();
        if GenJournalLine."Job No." <> '' then
            AddError(
              StrSubstNo(
                MustNotBeSpecifiedInFAJnlErr, GenJournalLine.FieldCaption(GenJournalLine."Job No.")));
        if GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::" " then
            AddError(
              StrSubstNo(
                MustBeSpecifiedInFAJnlErr, GenJournalLine.FieldCaption(GenJournalLine."FA Posting Type")));
        if GenJournalLine."Depreciation Book Code" = '' then
            AddError(
              StrSubstNo(
                MustBeSpecifiedInFAJnlErr, GenJournalLine.FieldCaption(GenJournalLine."Depreciation Book Code")));
        if GenJournalLine."Depreciation Book Code" = GenJournalLine."Duplicate in Depreciation Book" then
            AddError(
              StrSubstNo(
                MustBeDifferentThanErr,
                GenJournalLine.FieldCaption(GenJournalLine."Depreciation Book Code"), GenJournalLine.FieldCaption(GenJournalLine."Duplicate in Depreciation Book")));
        CheckFADocNo(GenJournalLine);
        if GenJournalLine."Account Type" = GenJournalLine."Bal. Account Type" then
            AddError(
              StrSubstNo(
                MustNotBothBeErr,
                GenJournalLine.FieldCaption(GenJournalLine."Account Type"), GenJournalLine.FieldCaption(GenJournalLine."Bal. Account Type"), GenJournalLine."Account Type"));
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Fixed Asset" then
            if (GenJournalLine."FA Posting Type" in
                [GenJournalLine."FA Posting Type"::"Acquisition Cost", GenJournalLine."FA Posting Type"::Disposal, GenJournalLine."FA Posting Type"::Maintenance]) or
               (FASetup.IsFAAcquisitionAsCustom2CZL() and (GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::"Custom 2"))
            then begin
                if (GenJournalLine."Gen. Bus. Posting Group" <> '') or (GenJournalLine."Gen. Prod. Posting Group" <> '') then
                    if GenJournalLine."Gen. Posting Type" = GenJournalLine."Gen. Posting Type"::" " then
                        AddError(StrSubstNo(FieldMustBeSpecifiedErr, GenJournalLine.FieldCaption(GenJournalLine."Gen. Posting Type")));
            end else begin
                if GenJournalLine."Gen. Posting Type" <> GenJournalLine."Gen. Posting Type"::" " then
                    AddError(
                      StrSubstNo(
                        MustNotBeSpecifiedWhenErr,
                        GenJournalLine.FieldCaption(GenJournalLine."Gen. Posting Type"), GenJournalLine.FieldCaption(GenJournalLine."FA Posting Type"), GenJournalLine."FA Posting Type"));
                if GenJournalLine."Gen. Bus. Posting Group" <> '' then
                    AddError(
                      StrSubstNo(
                        MustNotBeSpecifiedWhenErr,
                        GenJournalLine.FieldCaption(GenJournalLine."Gen. Bus. Posting Group"), GenJournalLine.FieldCaption(GenJournalLine."FA Posting Type"), GenJournalLine."FA Posting Type"));
                if GenJournalLine."Gen. Prod. Posting Group" <> '' then
                    AddError(
                      StrSubstNo(
                        MustNotBeSpecifiedWhenErr,
                        GenJournalLine.FieldCaption(GenJournalLine."Gen. Prod. Posting Group"), GenJournalLine.FieldCaption(GenJournalLine."FA Posting Type"), GenJournalLine."FA Posting Type"));
            end;
        if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Fixed Asset" then
            if (GenJournalLine."FA Posting Type" in
                [GenJournalLine."FA Posting Type"::"Acquisition Cost", GenJournalLine."FA Posting Type"::Disposal, GenJournalLine."FA Posting Type"::Maintenance]) or
               (FASetup.IsFAAcquisitionAsCustom2CZL() and (GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::"Custom 2"))
            then begin
                if (GenJournalLine."Bal. Gen. Bus. Posting Group" <> '') or (GenJournalLine."Bal. Gen. Prod. Posting Group" <> '') then
                    if GenJournalLine."Bal. Gen. Posting Type" = GenJournalLine."Bal. Gen. Posting Type"::" " then
                        AddError(StrSubstNo(FieldMustBeSpecifiedErr, GenJournalLine.FieldCaption(GenJournalLine."Bal. Gen. Posting Type")));
            end else begin
                if GenJournalLine."Bal. Gen. Posting Type" <> GenJournalLine."Bal. Gen. Posting Type"::" " then
                    AddError(
                      StrSubstNo(
                        MustNotBeSpecifiedWhenErr,
                        GenJournalLine.FieldCaption(GenJournalLine."Bal. Gen. Posting Type"), GenJournalLine.FieldCaption(GenJournalLine."FA Posting Type"), GenJournalLine."FA Posting Type"));
                if GenJournalLine."Bal. Gen. Bus. Posting Group" <> '' then
                    AddError(
                      StrSubstNo(
                        MustNotBeSpecifiedWhenErr,
                        GenJournalLine.FieldCaption(GenJournalLine."Bal. Gen. Bus. Posting Group"), GenJournalLine.FieldCaption(GenJournalLine."FA Posting Type"), GenJournalLine."FA Posting Type"));
                if GenJournalLine."Bal. Gen. Prod. Posting Group" <> '' then
                    AddError(
                      StrSubstNo(
                        MustNotBeSpecifiedWhenErr,
                        GenJournalLine.FieldCaption(GenJournalLine."Bal. Gen. Prod. Posting Group"), GenJournalLine.FieldCaption(GenJournalLine."FA Posting Type"), GenJournalLine."FA Posting Type"));
            end;
        TempErrorText :=
          '%1 ' +
          StrSubstNo(
            MustNotBeSpecifiedTogetherErr,
            GenJournalLine.FieldCaption(GenJournalLine."FA Posting Type"), GenJournalLine."FA Posting Type");
        if GenJournalLine."FA Posting Type" <> GenJournalLine."FA Posting Type"::"Acquisition Cost" then begin
            if GenJournalLine."Depr. Acquisition Cost" then
                AddError(StrSubstNo(TempErrorText, GenJournalLine.FieldCaption(GenJournalLine."Depr. Acquisition Cost")));
            if GenJournalLine."Salvage Value" <> 0 then
                AddError(StrSubstNo(TempErrorText, GenJournalLine.FieldCaption(GenJournalLine."Salvage Value")));
            if GenJournalLine."FA Posting Type" <> GenJournalLine."FA Posting Type"::Maintenance then
                if GenJournalLine.Quantity <> 0 then
                    AddError(StrSubstNo(TempErrorText, GenJournalLine.FieldCaption(GenJournalLine.Quantity)));
            if GenJournalLine."Insurance No." <> '' then
                AddError(StrSubstNo(TempErrorText, GenJournalLine.FieldCaption(GenJournalLine."Insurance No.")));
        end;
        if (GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::Maintenance) and GenJournalLine."Depr. until FA Posting Date" then
            AddError(StrSubstNo(TempErrorText, GenJournalLine.FieldCaption(GenJournalLine."Depr. until FA Posting Date")));
        if (GenJournalLine."FA Posting Type" <> GenJournalLine."FA Posting Type"::Maintenance) and (GenJournalLine."Maintenance Code" <> '') then
            AddError(StrSubstNo(TempErrorText, GenJournalLine.FieldCaption(GenJournalLine."Maintenance Code")));

        if (GenJournalLine."FA Posting Type" <> GenJournalLine."FA Posting Type"::Depreciation) and
           (GenJournalLine."FA Posting Type" <> GenJournalLine."FA Posting Type"::"Custom 1") and
           (GenJournalLine."No. of Depreciation Days" <> 0)
        then
            AddError(StrSubstNo(TempErrorText, GenJournalLine.FieldCaption(GenJournalLine."No. of Depreciation Days")));

        if (GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::Disposal) and GenJournalLine."FA Reclassification Entry" then
            AddError(StrSubstNo(TempErrorText, GenJournalLine.FieldCaption(GenJournalLine."FA Reclassification Entry")));

        if (GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::Disposal) and (GenJournalLine."Budgeted FA No." <> '') then
            AddError(StrSubstNo(TempErrorText, GenJournalLine.FieldCaption(GenJournalLine."Budgeted FA No.")));

        if GenJournalLine."FA Posting Date" = 0D then
            GenJournalLine."FA Posting Date" := GenJournalLine."Posting Date";
        if DepreciationBook.Get(GenJournalLine."Depreciation Book Code") then
            if DepreciationBook."Use Same FA+G/L Posting Dates" and (GenJournalLine."Posting Date" <> GenJournalLine."FA Posting Date") then
                if not GenJournalLine."FA Reclassification Entry" then
                    AddError(
                      StrSubstNo(
                        MustBeIdenticalErr,
                        GenJournalLine.FieldCaption(GenJournalLine."Posting Date"), GenJournalLine.FieldCaption(GenJournalLine."FA Posting Date")));
        if GenJournalLine."FA Posting Date" <> 0D then begin
            if GenJournalLine."FA Posting Date" <> NormalDate(GenJournalLine."FA Posting Date") then
                AddError(
                  StrSubstNo(
                    CannotBeClosingDateErr,
                    GenJournalLine.FieldCaption(GenJournalLine."FA Posting Date")));
            if not (GenJournalLine."FA Posting Date" in [DMY2Date(1, 1, 2) .. DMY2Date(31, 12, 9998)]) then
                AddError(
                  StrSubstNo(
                    PostingDateNotInRangeErr,
                    GenJournalLine.FieldCaption(GenJournalLine."FA Posting Date")));
            if (AllowFAPostingFrom = 0D) and (AllowFAPostingTo = 0D) then begin
                if UserId <> '' then
                    if UserSetup.Get(UserId) then begin
                        AllowFAPostingFrom := UserSetup."Allow FA Posting From";
                        AllowFAPostingTo := UserSetup."Allow FA Posting To";
                    end;
                if (AllowFAPostingFrom = 0D) and (AllowFAPostingTo = 0D) then begin
                    FASetup.Get();
                    AllowFAPostingFrom := FASetup."Allow FA Posting From";
                    AllowFAPostingTo := FASetup."Allow FA Posting To";
                end;
                if AllowFAPostingTo = 0D then
                    AllowFAPostingTo := DMY2Date(31, 12, 9998);
            end;
            if (GenJournalLine."FA Posting Date" < AllowFAPostingFrom) or
               (GenJournalLine."FA Posting Date" > AllowFAPostingTo)
            then
                AddError(
                  StrSubstNo(
                    PostingDateNotInRangeErr,
                    GenJournalLine.FieldCaption(GenJournalLine."FA Posting Date")));
        end;
        FASetup.Get();
        if (GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::"Acquisition Cost") and
           (GenJournalLine."Insurance No." <> '') and (GenJournalLine."Depreciation Book Code" <> FASetup."Insurance Depr. Book")
        then
            AddError(
              StrSubstNo(
                InsuranceIntegrationNotActiveErr,
                GenJournalLine.FieldCaption(GenJournalLine."Depreciation Book Code"), GenJournalLine."Depreciation Book Code"));

        if GenJournalLine."FA Error Entry No." > 0 then begin
            TempErrorText :=
              '%1 ' +
              StrSubstNo(
                MustNotBeSpecifiedWhen2Err,
                GenJournalLine.FieldCaption(GenJournalLine."FA Error Entry No."));
            if GenJournalLine."Depr. until FA Posting Date" then
                AddError(StrSubstNo(TempErrorText, GenJournalLine.FieldCaption(GenJournalLine."Depr. until FA Posting Date")));
            if GenJournalLine."Depr. Acquisition Cost" then
                AddError(StrSubstNo(TempErrorText, GenJournalLine.FieldCaption(GenJournalLine."Depr. Acquisition Cost")));
            if GenJournalLine."Duplicate in Depreciation Book" <> '' then
                AddError(StrSubstNo(TempErrorText, GenJournalLine.FieldCaption(GenJournalLine."Duplicate in Depreciation Book")));
            if GenJournalLine."Use Duplication List" then
                AddError(StrSubstNo(TempErrorText, GenJournalLine.FieldCaption(GenJournalLine."Use Duplication List")));
            if GenJournalLine."Salvage Value" <> 0 then
                AddError(StrSubstNo(TempErrorText, GenJournalLine.FieldCaption(GenJournalLine."Salvage Value")));
            if GenJournalLine."Insurance No." <> '' then
                AddError(StrSubstNo(TempErrorText, GenJournalLine.FieldCaption(GenJournalLine."Insurance No.")));
            if GenJournalLine."Budgeted FA No." <> '' then
                AddError(StrSubstNo(TempErrorText, GenJournalLine.FieldCaption(GenJournalLine."Budgeted FA No.")));
            if GenJournalLine."Recurring Method" <> "Gen. Journal Recurring Method"::" " then
                AddError(StrSubstNo(TempErrorText, GenJournalLine.FieldCaption(GenJournalLine."Recurring Method")));
            if GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::Maintenance then
                AddError(StrSubstNo(TempErrorText, GenJournalLine."FA Posting Type"));
        end;

    end;

    local procedure CheckFAIntegration(var GenJournalLine: Record "Gen. Journal Line")
    var
        GLIntegration: Boolean;
    begin
        if GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::" " then
            exit;
        case GenJournalLine."FA Posting Type" of
            GenJournalLine."FA Posting Type"::"Acquisition Cost":
                GLIntegration := DepreciationBook."G/L Integration - Acq. Cost";
            GenJournalLine."FA Posting Type"::Depreciation:
                GLIntegration := DepreciationBook."G/L Integration - Depreciation";
            GenJournalLine."FA Posting Type"::"Write-Down":
                GLIntegration := DepreciationBook."G/L Integration - Write-Down";
            GenJournalLine."FA Posting Type"::Appreciation:
                GLIntegration := DepreciationBook."G/L Integration - Appreciation";
            GenJournalLine."FA Posting Type"::"Custom 1":
                GLIntegration := DepreciationBook."G/L Integration - Custom 1";
            GenJournalLine."FA Posting Type"::"Custom 2":
                GLIntegration := DepreciationBook."G/L Integration - Custom 2";
            GenJournalLine."FA Posting Type"::Disposal:
                GLIntegration := DepreciationBook."G/L Integration - Disposal";
            GenJournalLine."FA Posting Type"::Maintenance:
                GLIntegration := DepreciationBook."G/L Integration - Maintenance";
        end;
        if not GLIntegration then
            AddError(
              StrSubstNo(
                MustNotBePostedWhenGLIntegrationErr,
                GenJournalLine."FA Posting Type"));

        if not DepreciationBook."G/L Integration - Depreciation" then begin
            if GenJournalLine."Depr. until FA Posting Date" then
                AddError(
                  StrSubstNo(
                    MustNotBeSpecWhenGLIntegrationErr,
                    GenJournalLine.FieldCaption(GenJournalLine."Depr. until FA Posting Date")));
            if GenJournalLine."Depr. Acquisition Cost" then
                AddError(
                  StrSubstNo(
                    MustNotBeSpecWhenGLIntegrationErr,
                    GenJournalLine.FieldCaption(GenJournalLine."Depr. Acquisition Cost")));
        end;
    end;

    local procedure TestFixedAssetFields(var GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."FA Posting Type" <> GenJournalLine."FA Posting Type"::" " then
            AddError(StrSubstNo(MustNotBeSpecifiedErr, GenJournalLine.FieldCaption(GenJournalLine."FA Posting Type")));
        if GenJournalLine."Depreciation Book Code" <> '' then
            AddError(StrSubstNo(MustNotBeSpecifiedErr, GenJournalLine.FieldCaption(GenJournalLine."Depreciation Book Code")));
    end;

    procedure TestPostingType()
    begin
        case true of
            CustPosting and PurchPostingType:
                AddError(CustGenPostTypeCombinationErr);
            VendPosting and SalesPostingType:
                AddError(VendGenPostTypeCombinationErr);
        end;
    end;

    local procedure WarningIfNegativeAmt(GenJournalLine: Record "Gen. Journal Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeWarningIfNegativeAmt(GenJournalLine, IsHandled);
        if IsHandled then
            exit;

        if (GenJournalLine.Amount < 0) and not AmountError then begin
            AmountError := true;
            AddError(StrSubstNo(MustBePositiveErr, GenJournalLine.FieldCaption(Amount)));
        end;
    end;

    local procedure WarningIfPositiveAmt(GenJournalLine: Record "Gen. Journal Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeWarningIfPositiveAmt(GenJournalLine, IsHandled);
        if IsHandled then
            exit;

        if (GenJournalLine.Amount > 0) and not AmountError then begin
            AmountError := true;
            AddError(StrSubstNo(MustBeNegativeErr, GenJournalLine.FieldCaption(Amount)));
        end;
    end;

    local procedure WarningIfZeroAmt(GenJournalLine: Record "Gen. Journal Line")
    begin
        if (GenJournalLine.Amount = 0) and not AmountError then begin
            AmountError := true;
            AddError(StrSubstNo(FieldMustBeSpecifiedErr, GenJournalLine.FieldCaption(Amount)));
        end;
    end;

    local procedure WarningIfNonZeroAmt(GenJournalLine: Record "Gen. Journal Line")
    begin
        if (GenJournalLine.Amount <> 0) and not AmountError then begin
            AmountError := true;
            AddError(StrSubstNo(MustNotBeZeroErr, GenJournalLine.FieldCaption(Amount)));
        end;
    end;

    local procedure CheckAgainstPrevLines(GenJournalLine: Record "Gen. Journal Line")
    var
        i: Integer;
        AccType: Enum "Gen. Journal Account Type";
        AccNo: Code[20];
        ErrorFound: Boolean;
    begin
        if (GenJournalLine."External Document No." = '') or
           not (GenJournalLine."Account Type" in
                [GenJournalLine."Account Type"::Customer, GenJournalLine."Account Type"::Vendor]) and
           not (GenJournalLine."Bal. Account Type" in
                [GenJournalLine."Bal. Account Type"::Customer, GenJournalLine."Bal. Account Type"::Vendor])
        then
            exit;

        if GenJournalLine."Account Type" in [GenJournalLine."Account Type"::Customer, GenJournalLine."Account Type"::Vendor] then begin
            AccType := GenJournalLine."Account Type";
            AccNo := GenJournalLine."Account No.";
        end else begin
            AccType := GenJournalLine."Bal. Account Type";
            AccNo := GenJournalLine."Bal. Account No.";
        end;

        TempGenJournalLine.Reset();
        TempGenJournalLine.SetRange("External Document No.", GenJournalLine."External Document No.");

        i := 0;
        while (i < 2) and not ErrorFound do begin
            i := i + 1;
            if i = 1 then begin
                TempGenJournalLine.SetRange("Account Type", AccType);
                TempGenJournalLine.SetRange("Account No.", AccNo);
                TempGenJournalLine.SetRange("Bal. Account Type");
                TempGenJournalLine.SetRange("Bal. Account No.");
            end else begin
                TempGenJournalLine.SetRange("Account Type");
                TempGenJournalLine.SetRange("Account No.");
                TempGenJournalLine.SetRange("Bal. Account Type", AccType);
                TempGenJournalLine.SetRange("Bal. Account No.", AccNo);
            end;
            if TempGenJournalLine.FindFirst() then begin
                ErrorFound := true;
                AddError(
                  StrSubstNo(
                    AlreadyUsedInLineErr, GenJournalLine.FieldCaption("External Document No."), GenJournalLine."External Document No.",
                    TempGenJournalLine."Line No.", GenJournalLine.FieldCaption("Document No."), TempGenJournalLine."Document No."));
            end;
        end;

        TempGenJournalLine.Reset();
        TempGenJournalLine := GenJournalLine;
        TempGenJournalLine.Insert();
    end;

    local procedure CheckICDocument()
    var
        ICGenJournalLine: Record "Gen. Journal Line";
    begin
        if GenJournalTemplate.Type = GenJournalTemplate.Type::Intercompany then begin
            if ("Gen. Journal Line"."Posting Date" <> LastDate) or ("Gen. Journal Line"."Document Type" <> LastDocType) or ("Gen. Journal Line"."Document No." <> LastDocNo) then begin
                ICGenJournalLine.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
                ICGenJournalLine.SetRange("Journal Template Name", "Gen. Journal Line"."Journal Template Name");
                ICGenJournalLine.SetRange("Journal Batch Name", "Gen. Journal Line"."Journal Batch Name");
                ICGenJournalLine.SetRange("Posting Date", "Gen. Journal Line"."Posting Date");
                ICGenJournalLine.SetRange("Document No.", "Gen. Journal Line"."Document No.");
                ICGenJournalLine.SetFilter("IC Partner Code", '<>%1', '');
                if ICGenJournalLine.FindFirst() then
                    CurrentICPartner := ICGenJournalLine."IC Partner Code"
                else
                    CurrentICPartner := '';
            end;
            CheckICAccountNo();
        end;
    end;

    local procedure TestJobFields(var GenJournalLine: Record "Gen. Journal Line")
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestJobFields(GenJournalLine, ErrorCounter, ErrorText, IsHandled);
        if IsHandled then
            exit;

        if (GenJournalLine."Job No." = '') or (GenJournalLine."Account Type" <> GenJournalLine."Account Type"::"G/L Account") then
            exit;
        if not Job.Get(GenJournalLine."Job No.") then
            AddError(StrSubstNo(MasterRecDoesNotExistErr, Job.TableCaption, GenJournalLine."Job No."))
        else
            if Job.Blocked <> Job.Blocked::" " then
                AddError(
                  StrSubstNo(
                    MustNotBeFor4Err, Job.FieldCaption(Blocked), Job.Blocked, Job.TableCaption, GenJournalLine."Job No."));

        if GenJournalLine."Job Task No." = '' then
            AddError(StrSubstNo(FieldMustBeSpecifiedErr, GenJournalLine.FieldCaption(GenJournalLine."Job Task No.")))
        else
            if not JobTask.Get(GenJournalLine."Job No.", GenJournalLine."Job Task No.") then
                AddError(StrSubstNo(MasterRecDoesNotExistErr, JobTask.TableCaption, GenJournalLine."Job Task No."));

        OnAfterTestJobFields(GenJournalLine, ErrorCounter, ErrorText);
    end;

    local procedure CheckFADocNo(GenJournalLine: Record "Gen. Journal Line")
    var
        FAJournalLine: Record "FA Journal Line";
        OldFALedgerEntry: Record "FA Ledger Entry";
        OldMaintenanceLedgerEntry: Record "Maintenance Ledger Entry";
        FANo: Code[20];
    begin
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Fixed Asset" then
            FANo := GenJournalLine."Account No.";
        if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Fixed Asset" then
            FANo := GenJournalLine."Bal. Account No.";
        if (FANo = '') or
           (GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::" ") or
           (GenJournalLine."Depreciation Book Code" = '') or
           (GenJournalLine."Document No." = '')
        then
            exit;
        if not DepreciationBook.Get(GenJournalLine."Depreciation Book Code") then
            exit;
        if DepreciationBook."Allow Identical Document No." then
            exit;

        FAJournalLine."FA Posting Type" := "FA Journal Line FA Posting Type".FromInteger(GenJournalLine."FA Posting Type".AsInteger() - 1);
        if GenJournalLine."FA Posting Type" <> GenJournalLine."FA Posting Type"::Maintenance then begin
            OldFALedgerEntry.SetCurrentKey(
              "FA No.", "Depreciation Book Code", "FA Posting Category", "FA Posting Type", "Document No.");
            OldFALedgerEntry.SetRange("FA No.", FANo);
            OldFALedgerEntry.SetRange("Depreciation Book Code", GenJournalLine."Depreciation Book Code");
            OldFALedgerEntry.SetRange("FA Posting Category", OldFALedgerEntry."FA Posting Category"::" ");
            OldFALedgerEntry.SetRange("FA Posting Type", FAJournalLine.ConvertToLedgEntry(FAJournalLine));
            OldFALedgerEntry.SetRange("Document No.", GenJournalLine."Document No.");
            if not OldFALedgerEntry.IsEmpty() then
                AddError(
                  StrSubstNo(
                    AlreadyExistsErr,
                    GenJournalLine.FieldCaption(GenJournalLine."Document No."), GenJournalLine."Document No."));
        end else begin
            OldMaintenanceLedgerEntry.SetCurrentKey(
              "FA No.", "Depreciation Book Code", "Document No.");
            OldMaintenanceLedgerEntry.SetRange("FA No.", FANo);
            OldMaintenanceLedgerEntry.SetRange("Depreciation Book Code", GenJournalLine."Depreciation Book Code");
            OldMaintenanceLedgerEntry.SetRange("Document No.", GenJournalLine."Document No.");
            if not OldMaintenanceLedgerEntry.IsEmpty() then
                AddError(
                  StrSubstNo(
                    AlreadyExistsErr,
                    GenJournalLine.FieldCaption(GenJournalLine."Document No."), GenJournalLine."Document No."));
        end;
    end;

    procedure InitializeRequest(NewShowDim: Boolean)
    begin
        ShouldShowDim := NewShowDim;
    end;

    local procedure GetDimensionText(var DimensionSetEntry: Record "Dimension Set Entry"): Text[75]
    var
        DimensionText: Text[75];
        Separator: Code[10];
        DimValue: Text[45];
    begin
        Separator := '';
        DimValue := '';
        Continue := false;

        repeat
            DimValue := StrSubstNo(DimCodeValueTextTok, DimensionSetEntry."Dimension Code", DimensionSetEntry."Dimension Value Code");
            if MaxStrLen(DimensionText) < StrLen(DimensionText + Separator + DimValue) then begin
                Continue := true;
                exit(DimensionText);
            end;
            DimensionText := CopyStr(DimensionText + Separator + DimValue, 1, MaxStrLen(DimensionText));
            Separator := '; ';
        until DimensionSetEntry.Next() = 0;
        exit(DimensionText);
    end;

    local procedure CheckAccountTypes(AccountType: Enum "Gen. Journal Account Type"; var Name: Text[100])
    begin
        case AccountType of
            AccountType::"G/L Account":
                CheckGLAcc("Gen. Journal Line", Name);
            AccountType::Customer:
                CheckCust("Gen. Journal Line", Name);
            AccountType::Vendor:
                CheckVend("Gen. Journal Line", Name);
            AccountType::"Bank Account":
                CheckBankAcc("Gen. Journal Line", Name);
            AccountType::"Fixed Asset":
                CheckFixedAsset("Gen. Journal Line", Name);
            AccountType::"IC Partner":
                CheckICPartner("Gen. Journal Line", Name);
            AccountType::Employee:
                CheckEmployee("Gen. Journal Line", Name);
        end;
    end;

    local procedure GetLastEnteredDocumentNo(var FromGenJournalLine: Record "Gen. Journal Line"): Code[20]
    var
        LastGenJournalLine: Record "Gen. Journal Line";
    begin
        LastGenJournalLine.CopyFilters(FromGenJournalLine);
        LastGenJournalLine.SetCurrentKey("Document No.");
        if LastGenJournalLine.FindLast() then;
        exit(LastGenJournalLine."Document No.");
    end;

    local procedure IsGapInNosForDocNo(var FromGenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        EmptyGenJournalLine: Record "Gen. Journal Line";
    begin
        if LastEnteredDocNo = '' then
            exit(false);
        if FromGenJournalLine."Document No." = LastEnteredDocNo then
            exit(false);

        EmptyGenJournalLine.CopyFilters(FromGenJournalLine);
        EmptyGenJournalLine.SetRange("Document No.", IncStr(FromGenJournalLine."Document No."));
        exit(EmptyGenJournalLine.IsEmpty());
    end;

    local procedure CheckExtDocNoInPostedPurchDoc(GenJournalLine: Record "Gen. Journal Line")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        case GenJournalLine."Document Type" of
            GenJournalLine."Document Type"::Invoice:
                begin
                    PurchInvHeader.Reset();
                    PurchInvHeader.SetCurrentKey("Vendor Invoice No.");
                    PurchInvHeader.SetRange("Vendor Invoice No.", GenJournalLine."External Document No.");
                    PurchInvHeader.SetRange("Pay-to Vendor No.", GenJournalLine."Account No.");
                    if not PurchInvHeader.IsEmpty then
                        AddError(
                          StrSubstNo(
                            PurchaseDocAlreadyExistsErr,
                            GenJournalLine."Document Type", GenJournalLine."External Document No."));
                end;
            GenJournalLine."Document Type"::"Credit Memo":
                begin
                    PurchCrMemoHdr.Reset();
                    PurchCrMemoHdr.SetCurrentKey("Vendor Cr. Memo No.");
                    PurchCrMemoHdr.SetRange("Vendor Cr. Memo No.", GenJournalLine."External Document No.");
                    PurchCrMemoHdr.SetRange("Pay-to Vendor No.", GenJournalLine."Account No.");
                    if not PurchCrMemoHdr.IsEmpty then
                        AddError(
                          StrSubstNo(
                            PurchaseDocAlreadyExistsErr,
                            GenJournalLine."Document Type", GenJournalLine."External Document No."));
                end;
        end;
    end;

    local procedure CheckICAccountNo()
    var
        ICGLAccount: Record "IC G/L Account";
        ICBankAccount: Record "IC Bank Account";
    begin
#if not CLEAN22
#pragma warning disable AL0432
        if (CurrentICPartner <> '') and ("Gen. Journal Line"."IC Direction" = "Gen. Journal Line"."IC Direction"::Outgoing) then begin
            if ("Gen. Journal Line"."Account Type" in ["Gen. Journal Line"."Account Type"::"G/L Account", "Gen. Journal Line"."Account Type"::"Bank Account"]) and
               ("Gen. Journal Line"."Bal. Account Type" in ["Gen. Journal Line"."Bal. Account Type"::"G/L Account", "Gen. Journal Line"."Account Type"::"Bank Account"]) and
               ("Gen. Journal Line"."Account No." <> '') and
               ("Gen. Journal Line"."Bal. Account No." <> '')
            then
                AddError(StrSubstNo(CannotEnterGLBankAccErr, "Gen. Journal Line".FieldCaption("Account No."), "Gen. Journal Line".FieldCaption("Bal. Account No.")))
            else
                if (("Gen. Journal Line"."Account Type" in ["Gen. Journal Line"."Account Type"::"G/L Account", "Gen. Journal Line"."Account Type"::"Bank Account"]) and ("Gen. Journal Line"."Account No." <> '')) xor
                   (("Gen. Journal Line"."Bal. Account Type" in ["Gen. Journal Line"."Bal. Account Type"::"G/L Account", "Gen. Journal Line"."Account Type"::"Bank Account"]) and
                    ("Gen. Journal Line"."Bal. Account No." <> ''))
                then
                    if "Gen. Journal Line"."IC Partner G/L Acc. No." = '' then
                        AddError(StrSubstNo(FieldMustBeSpecifiedErr, "Gen. Journal Line".FieldCaption("IC Partner G/L Acc. No.")))
                    else begin
                        if ICGLAccount.Get("Gen. Journal Line"."IC Partner G/L Acc. No.") then
                            if ICGLAccount.Blocked then
                                AddError(StrSubstNo(MustBeForErr, ICGLAccount.FieldCaption(Blocked), false,
                                    "Gen. Journal Line".FieldCaption("IC Partner G/L Acc. No."), "Gen. Journal Line"."IC Partner G/L Acc. No."));

                        if "Gen. Journal Line"."IC Account Type" = "IC Journal Account Type"::"Bank Account" then
                            if ICBankAccount.Get("Gen. Journal Line"."IC Account No.", CurrentICPartner) then
                                if ICBankAccount.Blocked then
                                    AddError(StrSubstNo(MustBeForErr, ICGLAccount.FieldCaption(Blocked), false,
                                        "Gen. Journal Line".FieldCaption("IC Account No."), "Gen. Journal Line"."IC Account No."));
                    end
                else
                    if "Gen. Journal Line"."IC Partner G/L Acc. No." <> '' then
                        AddError(StrSubstNo(CannotBeSpecifiedErr, "Gen. Journal Line".FieldCaption("IC Partner G/L Acc. No.")));
        end else
            if "Gen. Journal Line"."IC Partner G/L Acc. No." <> '' then begin
                if "Gen. Journal Line"."IC Direction" = "Gen. Journal Line"."IC Direction"::Incoming then
                    AddError(StrSubstNo(MustNotBeSpecifiedWhenIsErr, "Gen. Journal Line".FieldCaption("IC Partner G/L Acc. No."), "Gen. Journal Line".FieldCaption("IC Direction"), Format("Gen. Journal Line"."IC Direction")));
                if CurrentICPartner = '' then
                    AddError(StrSubstNo(MustNotBeSpecifiedWhenInterDocErr, "Gen. Journal Line".FieldCaption("IC Partner G/L Acc. No.")));
            end;
#pragma warning restore AL0432
#else
        if (CurrentICPartner <> '') and ("Gen. Journal Line"."IC Direction" = "Gen. Journal Line"."IC Direction"::Outgoing) then begin
            if ("Gen. Journal Line"."Account Type" in ["Gen. Journal Line"."Account Type"::"G/L Account", "Gen. Journal Line"."Account Type"::"Bank Account"]) and
               ("Gen. Journal Line"."Bal. Account Type" in ["Gen. Journal Line"."Bal. Account Type"::"G/L Account", "Gen. Journal Line"."Account Type"::"Bank Account"]) and
               ("Gen. Journal Line"."Account No." <> '') and
               ("Gen. Journal Line"."Bal. Account No." <> '')
            then
                AddError(StrSubstNo(CannotEnterGLBankAccErr, "Gen. Journal Line".FieldCaption("Account No."), "Gen. Journal Line".FieldCaption("Bal. Account No.")))
            else
                if (("Gen. Journal Line"."Account Type" in ["Gen. Journal Line"."Account Type"::"G/L Account", "Gen. Journal Line"."Account Type"::"Bank Account"]) and ("Gen. Journal Line"."Account No." <> '')) xor
                   (("Gen. Journal Line"."Bal. Account Type" in ["Gen. Journal Line"."Bal. Account Type"::"G/L Account", "Gen. Journal Line"."Account Type"::"Bank Account"]) and
                    ("Gen. Journal Line"."Bal. Account No." <> ''))
                then
                    if "Gen. Journal Line"."IC Account No." = '' then
                        AddError(StrSubstNo(FieldMustBeSpecifiedErr, "Gen. Journal Line".FieldCaption("IC Account No.")))
                    else begin
                        if "Gen. Journal Line"."IC Account Type" = "IC Journal Account Type"::"G/L Account" then
                            if ICGLAccount.Get("Gen. Journal Line"."IC Account No.") then
                                if ICGLAccount.Blocked then
                                    AddError(StrSubstNo(MustBeForErr, ICGLAccount.FieldCaption(Blocked), false,
                                        "Gen. Journal Line".FieldCaption("IC Account No."), "Gen. Journal Line"."IC Account No."));

                        if "Gen. Journal Line"."IC Account Type" = "IC Journal Account Type"::"Bank Account" then
                            if ICBankAccount.Get("Gen. Journal Line"."IC Account No.", CurrentICPartner) then
                                if ICBankAccount.Blocked then
                                    AddError(StrSubstNo(MustBeForErr, ICGLAccount.FieldCaption(Blocked), false,
                                        "Gen. Journal Line".FieldCaption("IC Account No."), "Gen. Journal Line"."IC Account No."));
                    end
                else
                    if "Gen. Journal Line"."IC Account No." <> '' then
                        AddError(StrSubstNo(CannotBeSpecifiedErr, "Gen. Journal Line".FieldCaption("IC Account No.")));
        end else
            if "Gen. Journal Line"."IC Account No." <> '' then begin
                if "Gen. Journal Line"."IC Direction" = "Gen. Journal Line"."IC Direction"::Incoming then
                    AddError(StrSubstNo(MustNotBeSpecifiedWhenIsErr, "Gen. Journal Line".FieldCaption("IC Account No."), "Gen. Journal Line".FieldCaption("IC Direction"), Format("Gen. Journal Line"."IC Direction")));
                if CurrentICPartner = '' then
                    AddError(StrSubstNo(MustNotBeSpecifiedWhenInterDocErr, "Gen. Journal Line".FieldCaption("IC Account No.")));
            end;
#endif
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignDimTableID(GenJournalLine: Record "Gen. Journal Line"; var TableID: array[10] of Integer; var No: array[10] of Code[20])
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterCheckGLAcc(GenJournalLine: Record "Gen. Journal Line"; GLAccount: Record "G/L Account"; var ErrorCounter: Integer; var ErrorText: array[50] of Text[250])
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterCheckGenJnlLine(GenJournalLine: Record "Gen. Journal Line"; var ErrorCounter: Integer; var ErrorText: array[50] of Text[250])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestJobFields(GenJournalLine: Record "Gen. Journal Line"; var ErrorCounter: Integer; var ErrorText: array[50] of Text[250])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestJobFields(var GenJournalLine: Record "Gen. Journal Line"; var ErrorCounter: Integer; var ErrorText: array[50] of Text[250]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWarningIfNegativeAmt(GenJournalLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWarningIfPositiveAmt(GenJournalLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGenJournalLineOnAfterGetRecord(var GenJournalLine: Record "Gen. Journal Line"; var GenJournalBatch: Record "Gen. Journal Batch"; var GenJournalTemplate: Record "Gen. Journal Template")
    begin
    end;
}
