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
                DataItemTableView = sorting(Number) WHERE(Number = CONST(1));
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
                    column(AccName; AccName)
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
                        DataItemTableView = sorting(Number) WHERE(Number = FILTER(1 ..));
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
                                if not DimSetEntry.FindSet() then
                                    CurrReport.Break();
                            end else
                                if not Continue then
                                    CurrReport.Break();

                            DimText := GetDimensionText(DimSetEntry);
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not ShouldShowDim then
                                CurrReport.Break();
                            DimSetEntry.Reset();
                            DimSetEntry.SetRange("Dimension Set ID", "Gen. Journal Line"."Dimension Set ID")
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
                        column(Recurring_GenJnlTemplate; GenJnlTemplate.Recurring)
                        {
                        }
                        dataitem(DimensionLoopAllocations; "Integer")
                        {
                            DataItemTableView = sorting(Number) WHERE(Number = FILTER(1 ..));
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
                                    if not DimSetEntry.FindFirst() then
                                        CurrReport.Break();
                                end else
                                    if not Continue then
                                        CurrReport.Break();

                                AllocationDimText := GetDimensionText(DimSetEntry);
                            end;

                            trigger OnPreDataItem()
                            begin
                                if not ShouldShowDim then
                                    CurrReport.Break();
                                DimSetEntry.Reset();
                                DimSetEntry.SetRange("Dimension Set ID", "Gen. Jnl. Allocation"."Dimension Set ID")
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
                        OnBeforeGenJournalLineOnAfterGetRecord("Gen. Journal Line", "Gen. Journal Batch", GenJnlTemplate);

                        if "Currency Code" = '' then
                            "Amount (LCY)" := Amount;

                        UpdateLineBalance();

                        AccName := '';
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
                               not GenJnlTemplate.Recurring and
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
                                if GenJnlLine2."Bank Payment Type" <> GenJnlLine2."Bank Payment Type"::" " then
                                    AddError(StrSubstNo(CannotBeSpecifiedErr, FieldCaption("Bank Payment Type")));

                            if ("Account No." <> '') and ("Bal. Account No." <> '') then begin
                                PurchPostingType := false;
                                SalesPostingType := false;
                            end;
                            if "Account No." <> '' then
                                CheckAccountTypes("Account Type", AccName);
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

                        GenJnlTemplate.Get("Gen. Journal Batch"."Journal Template Name");
                        if GenJnlTemplate.Recurring then begin
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
                        if not GenJnlTemplate.Recurring then
                            if GenJnlManagement.GetJournalSimplePageModePreference(PAGE::"General Journal") then
                                SetCurrentKey("Document No.", "Line No.");

                        LastEnteredDocNo := '';
                        if "Gen. Journal Batch"."No. Series" <> '' then begin
                            NoSeries.Get("Gen. Journal Batch"."No. Series");
                            LastEnteredDocNo := GetLastEnteredDocumentNo("Gen. Journal Line");
                            LastEntrdDate := 0D;
                        end;

                        TempGenJournalLineCustVendIC.Reset();
                        TempGenJournalLineCustVendIC.DeleteAll();
                        VATEntryCreated := false;

                        GenJnlLine2.Reset();
                        GenJnlLine2.CopyFilters("Gen. Journal Line");

                        TempGLAccNetChange.DeleteAll();
                    end;
                }
                dataitem(ReconcileLoop; "Integer")
                {
                    DataItemTableView = sorting(Number);
                    column(GLAccNetChangeNo; TempGLAccNetChange."No.")
                    {
                    }
                    column(GLAccNetChangeName; TempGLAccNetChange.Name)
                    {
                    }
                    column(GLAccNetChangeNetChangeJnl; TempGLAccNetChange."Net Change in Jnl.")
                    {
                    }
                    column(GLAccNetChangeBalafterPost; TempGLAccNetChange."Balance after Posting")
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
                            TempGLAccNetChange.Find('-')
                        else
                            TempGLAccNetChange.Next();
                    end;

                    trigger OnPostDataItem()
                    begin
                        TempGLAccNetChange.DeleteAll();
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, TempGLAccNetChange.Count);
                    end;
                }
            }
            trigger OnPreDataItem()
            begin
                GLSetup.Get();
                SalesSetup.Get();
                PurchSetup.Get();
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
        GLSetup: Record "General Ledger Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        PurchSetup: Record "Purchases & Payables Setup";
        UserSetup: Record "User Setup";
        AccountingPeriod: Record "Accounting Period";
        GLAcc: Record "G/L Account";
        Currency: Record Currency;
        Cust: Record Customer;
        Vend: Record Vendor;
        BankAccPostingGr: Record "Bank Account Posting Group";
        BankAcc: Record "Bank Account";
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlLine2: Record "Gen. Journal Line";
        TempGenJnlLine: Record "Gen. Journal Line" temporary;
        TempGenJournalLineCustVendIC: Record "Gen. Journal Line" temporary;
        GenJnlAlloc: Record "Gen. Jnl. Allocation";
        OldCustLedgEntry: Record "Cust. Ledger Entry";
        OldVendLedgEntry: Record "Vendor Ledger Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        NoSeries: Record "No. Series";
        FA: Record "Fixed Asset";
        ICPartner: Record "IC Partner";
        DeprBook: Record "Depreciation Book";
        FADeprBook: Record "FA Depreciation Book";
        FASetup: Record "FA Setup";
        TempGLAccNetChange: Record "G/L Account Net Change" temporary;
        DimSetEntry: Record "Dimension Set Entry";
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
        AccName: Text[100];
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

    local procedure CheckRecurringLine(GenJnlLine2: Record "Gen. Journal Line")
    begin
        if GenJnlTemplate.Recurring then begin
            if GenJnlLine2."Recurring Method" = "Gen. Journal Recurring Method"::" " then
                AddError(StrSubstNo(FieldMustBeSpecifiedErr, GenJnlLine2.FieldCaption(GenJnlLine2."Recurring Method")));
            if Format(GenJnlLine2."Recurring Frequency") = '' then
                AddError(StrSubstNo(FieldMustBeSpecifiedErr, GenJnlLine2.FieldCaption(GenJnlLine2."Recurring Frequency")));
            if GenJnlLine2."Bal. Account No." <> '' then
                AddError(
                  StrSubstNo(
                    CannotBeSpecifiedWhenRecurringErr,
                    GenJnlLine2.FieldCaption(GenJnlLine2."Bal. Account No.")));
            case GenJnlLine2."Recurring Method" of
                GenJnlLine2."Recurring Method"::"V  Variable", GenJnlLine2."Recurring Method"::"RV Reversing Variable",
              GenJnlLine2."Recurring Method"::"F  Fixed", GenJnlLine2."Recurring Method"::"RF Reversing Fixed":
                    WarningIfZeroAmt("Gen. Journal Line");
                GenJnlLine2."Recurring Method"::"B  Balance", GenJnlLine2."Recurring Method"::"RB Reversing Balance":
                    WarningIfNonZeroAmt("Gen. Journal Line");
            end;
            if GenJnlLine2."Recurring Method".AsInteger() > GenJnlLine2."Recurring Method"::"V  Variable".AsInteger() then begin
                if GenJnlLine2."Account Type" = GenJnlLine2."Account Type"::"Fixed Asset" then
                    AddError(
                      StrSubstNo(
                        MustNotBeWhenErr,
                        GenJnlLine2.FieldCaption(GenJnlLine2."Recurring Method"), GenJnlLine2."Recurring Method",
                        GenJnlLine2.FieldCaption(GenJnlLine2."Account Type"), GenJnlLine2."Account Type"));
                if GenJnlLine2."Bal. Account Type" = GenJnlLine2."Bal. Account Type"::"Fixed Asset" then
                    AddError(
                      StrSubstNo(
                        MustNotBeWhenErr,
                        GenJnlLine2.FieldCaption(GenJnlLine2."Recurring Method"), GenJnlLine2."Recurring Method",
                        GenJnlLine2.FieldCaption(GenJnlLine2."Bal. Account Type"), GenJnlLine2."Bal. Account Type"));
            end;
        end else begin
            if GenJnlLine2."Recurring Method" <> "Gen. Journal Recurring Method"::" " then
                AddError(StrSubstNo(CannotBeSpecifiedErr, GenJnlLine2.FieldCaption(GenJnlLine2."Recurring Method")));
            if Format(GenJnlLine2."Recurring Frequency") <> '' then
                AddError(StrSubstNo(CannotBeSpecifiedErr, GenJnlLine2.FieldCaption(GenJnlLine2."Recurring Frequency")));
        end;
    end;

    local procedure CheckAllocations(GenJnlLine2: Record "Gen. Journal Line")
    begin
        if GenJnlLine2."Recurring Method" in [GenJnlLine2."Recurring Method"::"B  Balance", GenJnlLine2."Recurring Method"::"RB Reversing Balance"] then begin
            GenJnlAlloc.Reset();
            GenJnlAlloc.SetRange("Journal Template Name", GenJnlLine2."Journal Template Name");
            GenJnlAlloc.SetRange("Journal Batch Name", GenJnlLine2."Journal Batch Name");
            GenJnlAlloc.SetRange("Journal Line No.", GenJnlLine2."Line No.");
            if not GenJnlAlloc.FindFirst() then
                AddError(BalanceMethodsOnlyWithAllocErr);
        end;

        GenJnlAlloc.Reset();
        GenJnlAlloc.SetRange("Journal Template Name", GenJnlLine2."Journal Template Name");
        GenJnlAlloc.SetRange("Journal Batch Name", GenJnlLine2."Journal Batch Name");
        GenJnlAlloc.SetRange("Journal Line No.", GenJnlLine2."Line No.");
        GenJnlAlloc.SetFilter(Amount, '<>0');
        if GenJnlAlloc.FindFirst() then
            if not GenJnlTemplate.Recurring then
                AddError(AllocationWithRecurringOnlyErr)
            else begin
                GenJnlAlloc.SetRange("Account No.", '');
                if GenJnlAlloc.FindFirst() then
                    AddError(
                      StrSubstNo(
                        SpecifyInAllocationLinesErr,
                        GenJnlAlloc.FieldCaption("Account No."), GenJnlAlloc.Count()));
            end;

    end;

    local procedure MakeRecurringTexts(var GenJnlLine2: Record "Gen. Journal Line")
    begin
        if (GenJnlLine2."Posting Date" <> 0D) and (GenJnlLine2."Account No." <> '') and (GenJnlLine2."Recurring Method" <> "Gen. Journal Recurring Method"::" ") then begin
            Day := Date2DMY(GenJnlLine2."Posting Date", 1);
            Week := Date2DWY(GenJnlLine2."Posting Date", 2);
            Month := Date2DMY(GenJnlLine2."Posting Date", 2);
            MonthText := Format(GenJnlLine2."Posting Date", 0, MonthTextTok);
            AccountingPeriod.SetRange("Starting Date", 0D, GenJnlLine2."Posting Date");
            if not AccountingPeriod.FindLast() then
                AccountingPeriod.Name := '';
            GenJnlLine2."Document No." :=
                CopyStr(
                    DelChr(
                        PadStr(
                        StrSubstNo(GenJnlLine2."Document No.", Day, Week, Month, MonthText, AccountingPeriod.Name),
                        MaxStrLen(GenJnlLine2."Document No.")),
                        '>'),
                    1, MaxStrLen(GenJnlLine2."Document No."));
            GenJnlLine2.Description :=
                CopyStr(
                    DelChr(
                        PadStr(
                        StrSubstNo(GenJnlLine2.Description, Day, Week, Month, MonthText, AccountingPeriod.Name),
                        MaxStrLen(GenJnlLine2.Description)),
                        '>'),
                    1, MaxStrLen(GenJnlLine2.Description));
        end;
    end;

    local procedure CheckBalance()
    var
        GenJnlLine: Record "Gen. Journal Line";
        NextGenJnlLine: Record "Gen. Journal Line";
        DocBalance: Decimal;
        DateBalance: Decimal;
        TotalBalance: Decimal;
    begin
        GenJnlLine.Copy("Gen. Journal Line");
        LastLineNo := "Gen. Journal Line"."Line No.";
        NextGenJnlLine.Copy("Gen. Journal Line");
        NextGenJnlLine.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
        NextGenJnlLine.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
        if NextGenJnlLine.Next() = 0 then;
        MakeRecurringTexts(NextGenJnlLine);
        if not GenJnlLine.EmptyLine() then begin
            DocBalance := CalculateDocBalance(GenJnlLine);
            DateBalance := CalculateDateBalance(GenJnlLine);
            TotalBalance := CalculateTotalBalance(GenJnlLine);
            if GenJnlLine."Recurring Method".AsInteger() >= GenJnlLine."Recurring Method"::"RF Reversing Fixed".AsInteger() then begin
                DocBalanceReverse := DocBalanceReverse + GenJnlLine."Balance (LCY)";
                DateBalanceReverse := DateBalanceReverse + GenJnlLine."Balance (LCY)";
                TotalBalanceReverse := TotalBalanceReverse + GenJnlLine."Balance (LCY)";
            end;
            LastDocType := GenJnlLine."Document Type";
            LastDocNo := GenJnlLine."Document No.";
            LastDate := GenJnlLine."Posting Date";
            if TotalBalance = 0 then
                VATEntryCreated := false;
            if GenJnlTemplate."Force Doc. Balance" then begin
                VATEntryCreated :=
                  VATEntryCreated or
                  ((GenJnlLine."Account Type" = GenJnlLine."Account Type"::"G/L Account") and (GenJnlLine."Account No." <> '') and
                   (GenJnlLine."Gen. Posting Type" in [GenJnlLine."Gen. Posting Type"::Purchase, GenJnlLine."Gen. Posting Type"::Sale])) or
                  ((GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::"G/L Account") and (GenJnlLine."Bal. Account No." <> '') and
                   (GenJnlLine."Bal. Gen. Posting Type" in [GenJnlLine."Bal. Gen. Posting Type"::Purchase, GenJnlLine."Bal. Gen. Posting Type"::Sale]));
                TempGenJournalLineCustVendIC.IsCustVendICAdded(GenJnlLine);
                if (TempGenJournalLineCustVendIC.Count > 1) and VATEntryCreated then
                    AddError(
                      StrSubstNo(
                        MustBeSeparatedByEmptyLineErr,
                        GenJnlLine."Document Type", GenJnlLine."Document No.", GenJnlLine."Posting Date"));
            end;
        end;

        if (LastDate <> 0D) and (LastDocNo <> '') and
            ((NextGenJnlLine."Posting Date" <> LastDate) or
            // ("Document Type" <> LastDocType) OR
            ((NextGenJnlLine."Document Type" <> LastDocType) and (not GenJnlTemplate."Not Check Doc. Type")) or
            (NextGenJnlLine."Document No." <> LastDocNo) or
            (NextGenJnlLine."Line No." = LastLineNo))
        then begin
            if GenJnlTemplate."Force Doc. Balance" then begin
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
            if (NextGenJnlLine."Posting Date" <> LastDate) or
               (NextGenJnlLine."Document Type" <> LastDocType) or (NextGenJnlLine."Document No." <> LastDocNo)
            then begin
                TempGenJournalLineCustVendIC.Reset();
                TempGenJournalLineCustVendIC.DeleteAll();
                VATEntryCreated := false;
                CustPosting := false;
                VendPosting := false;
                SalesPostingType := false;
                PurchPostingType := false;
            end;
        end;

        if (LastDate <> 0D) and ((NextGenJnlLine."Posting Date" <> LastDate) or (NextGenJnlLine."Line No." = LastLineNo)) then begin
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

        if NextGenJnlLine."Line No." = LastLineNo then begin
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
        DimMgt: Codeunit DimensionManagement;
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        if not DimMgt.CheckDimIDComb(GenJournalLine."Dimension Set ID") then
            AddError(DimMgt.GetDimCombErr());

        TableID[1] := DimMgt.TypeToTableID1(GenJournalLine."Account Type".AsInteger());
        No[1] := GenJournalLine."Account No.";
        TableID[2] := DimMgt.TypeToTableID1(GenJournalLine."Bal. Account Type".AsInteger());
        No[2] := GenJournalLine."Bal. Account No.";
        TableID[3] := Database::Job;
        No[3] := GenJournalLine."Job No.";
        TableID[4] := Database::"Salesperson/Purchaser";
        No[4] := GenJournalLine."Salespers./Purch. Code";
        TableID[5] := Database::Campaign;
        No[5] := GenJournalLine."Campaign No.";
        OnAfterAssignDimTableID(GenJournalLine, TableID, No);

        if not DimMgt.CheckDimValuePosting(TableID, No, GenJournalLine."Dimension Set ID") then
            AddError(DimMgt.GetDimValuePostingErr());
    end;

    local procedure CalculateDocBalance(GenJournalLine: Record "Gen. Journal Line"): Decimal
    var
        GenJournalLine2: Record "Gen. Journal Line";
    begin
        GenJournalLine2.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        GenJournalLine2.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        GenJournalLine2.SetRange("Document Type", GenJournalLine."Document Type");
        GenJournalLine2.SetRange("Document No.", GenJournalLine."Document No.");
        GenJournalLine2.CalcSums("Balance (LCY)");
        exit(GenJournalLine2."Balance (LCY)");
    end;

    local procedure CalculateDateBalance(GenJournalLine: Record "Gen. Journal Line"): Decimal
    var
        GenJournalLine2: Record "Gen. Journal Line";
    begin
        GenJournalLine2.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        GenJournalLine2.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        GenJournalLine2.SetRange("Posting Date", GenJournalLine."Posting Date");
        GenJournalLine2.CalcSums("Balance (LCY)");
        exit(GenJournalLine2."Balance (LCY)");
    end;

    local procedure CalculateTotalBalance(GenJournalLine: Record "Gen. Journal Line"): Decimal
    var
        GenJournalLine2: Record "Gen. Journal Line";
    begin
        GenJournalLine2.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        GenJournalLine2.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        GenJournalLine2.CalcSums("Balance (LCY)");
        exit(GenJournalLine2."Balance (LCY)");
    end;

    procedure AddError(Text: Text[250])
    begin
        ErrorCounter := ErrorCounter + 1;
        ErrorText[ErrorCounter] := Text;
    end;

    local procedure ReconcileGLAccNo(GLAccNo: Code[20]; ReconcileAmount: Decimal)
    begin
        if not TempGLAccNetChange.Get(GLAccNo) then begin
            GLAcc.Get(GLAccNo);
            GLAcc.CalcFields("Balance at Date");
            TempGLAccNetChange.Init();
            TempGLAccNetChange."No." := GLAcc."No.";
            TempGLAccNetChange.Name := GLAcc.Name;
            TempGLAccNetChange."Balance after Posting" := GLAcc."Balance at Date";
            TempGLAccNetChange.Insert();
        end;
        TempGLAccNetChange."Net Change in Jnl." := TempGLAccNetChange."Net Change in Jnl." + ReconcileAmount;
        TempGLAccNetChange."Balance after Posting" := TempGLAccNetChange."Balance after Posting" + ReconcileAmount;
        TempGLAccNetChange.Modify();
    end;

    local procedure CheckGLAcc(var GenJnlLine: Record "Gen. Journal Line"; var AccName: Text[100])
    begin
        if not GLAcc.Get(GenJnlLine."Account No.") then
            AddError(
              StrSubstNo(
                MasterRecDoesNotExistErr,
                GLAcc.TableCaption, GenJnlLine."Account No."))
        else begin
            AccName := GLAcc.Name;

            if GLAcc.Blocked then
                AddError(
                  StrSubstNo(
                    MustBeForErr,
                    GLAcc.FieldCaption(Blocked), false, GLAcc.TableCaption, GenJnlLine."Account No."));
            if GLAcc."Account Type" <> GLAcc."Account Type"::Posting then begin
                GLAcc."Account Type" := GLAcc."Account Type"::Posting;
                AddError(
                  StrSubstNo(
                    MustBeForErr,
                    GLAcc.FieldCaption("Account Type"), GLAcc."Account Type", GLAcc.TableCaption, GenJnlLine."Account No."));
            end;
            if not GenJnlLine."System-Created Entry" then
                if GenJnlLine."Posting Date" = NormalDate(GenJnlLine."Posting Date") then
                    if not GLAcc."Direct Posting" then
                        AddError(
                          StrSubstNo(
                            MustBeForErr,
                            GLAcc.FieldCaption("Direct Posting"), true, GLAcc.TableCaption, GenJnlLine."Account No."));

            if GenJnlLine."Gen. Posting Type" <> GenJnlLine."Gen. Posting Type"::" " then begin
                case GenJnlLine."Gen. Posting Type" of
                    GenJnlLine."Gen. Posting Type"::Sale:
                        SalesPostingType := true;
                    GenJnlLine."Gen. Posting Type"::Purchase:
                        PurchPostingType := true;
                end;
                TestPostingType();

                if not VATPostingSetup.Get(GenJnlLine."VAT Bus. Posting Group", GenJnlLine."VAT Prod. Posting Group") then
                    AddError(
                      StrSubstNo(
                        RecordDoesNotExistErr,
                        VATPostingSetup.TableCaption, GenJnlLine."VAT Bus. Posting Group", GenJnlLine."VAT Prod. Posting Group"))
                else
                    if GenJnlLine."VAT Calculation Type" <> VATPostingSetup."VAT Calculation Type" then
                        AddError(
                          StrSubstNo(
                            MustBeErr,
                            GenJnlLine.FieldCaption(GenJnlLine."VAT Calculation Type"), VATPostingSetup."VAT Calculation Type"))
            end;

            if GLAcc."Reconciliation Account" then
                ReconcileGLAccNo(GenJnlLine."Account No.", Round(GenJnlLine."Amount (LCY)" / (1 + GenJnlLine."VAT %" / 100)));

            OnAfterCheckGLAcc(GenJnlLine, GLAcc, ErrorCounter, ErrorText);
        end;
    end;

    local procedure CheckCust(var GenJnlLine: Record "Gen. Journal Line"; var AccName: Text[100])
    begin
        if not Cust.Get(GenJnlLine."Account No.") then
            AddError(
              StrSubstNo(
                MasterRecDoesNotExistErr,
                Cust.TableCaption, GenJnlLine."Account No."))
        else begin
            AccName := Cust.Name;
            if Cust."Privacy Blocked" then
                AddError(Cust.GetPrivacyBlockedGenericErrorText(Cust));
            if ((Cust.Blocked = Cust.Blocked::All) or
                ((Cust.Blocked = Cust.Blocked::Invoice) and
                 (GenJnlLine."Document Type" in [GenJnlLine."Document Type"::Invoice, GenJnlLine."Document Type"::" "]))
                )
            then
                AddError(
                  StrSubstNo(
                    MustNotBeBlockedTypeErr,
                    GenJnlLine."Account Type", Cust.Blocked, GenJnlLine.FieldCaption(GenJnlLine."Document Type"), GenJnlLine."Document Type"));
            if GenJnlLine."Currency Code" <> '' then
                if not Currency.Get(GenJnlLine."Currency Code") then
                    AddError(
                      StrSubstNo(
                        CurrencyNotFoundErr,
                        GenJnlLine."Currency Code"));
            if (Cust."IC Partner Code" <> '') and (GenJnlTemplate.Type = GenJnlTemplate.Type::Intercompany) then
                if ICPartner.Get(Cust."IC Partner Code") then begin
                    if ICPartner.Blocked then
                        AddError(
                          StrSubstNo(
                            TwoTextsWithSpaceTok,
                            StrSubstNo(
                              IsLinkedToErr,
                              Cust.TableCaption, GenJnlLine."Account No.", ICPartner.TableCaption, GenJnlLine."IC Partner Code"),
                            StrSubstNo(
                              MustBeForErr,
                              ICPartner.FieldCaption(Blocked), false, ICPartner.TableCaption, Cust."IC Partner Code")));
                end else
                    AddError(
                      StrSubstNo(
                        TwoTextsWithSpaceTok,
                        StrSubstNo(
                          IsLinkedToErr,
                          Cust.TableCaption, GenJnlLine."Account No.", ICPartner.TableCaption, Cust."IC Partner Code"),
                        StrSubstNo(
                          MasterRecDoesNotExistErr,
                          ICPartner.TableCaption, Cust."IC Partner Code")));
            CustPosting := true;
            TestPostingType();

            if GenJnlLine."Recurring Method" = "Gen. Journal Recurring Method"::" " then
                if GenJnlLine."Document Type" in
                   [GenJnlLine."Document Type"::Invoice, GenJnlLine."Document Type"::"Credit Memo",
                    GenJnlLine."Document Type"::"Finance Charge Memo", GenJnlLine."Document Type"::Reminder]
                then begin
                    OldCustLedgEntry.Reset();
                    OldCustLedgEntry.SetCurrentKey("Document No.");
                    OldCustLedgEntry.SetRange("Document Type", GenJnlLine."Document Type");
                    OldCustLedgEntry.SetRange("Document No.", GenJnlLine."Document No.");
                    if OldCustLedgEntry.FindFirst() then
                        AddError(
                          StrSubstNo(
                            SalesDocAlreadyExistsErr, GenJnlLine."Document Type", GenJnlLine."Document No."));

                    if SalesSetup."Ext. Doc. No. Mandatory" or
                       (GenJnlLine."External Document No." <> '')
                    then begin
                        if GenJnlLine."External Document No." = '' then
                            AddError(
                              StrSubstNo(
                                MustBeEnteredErr, GenJnlLine.FieldCaption(GenJnlLine."External Document No.")));

                        OldCustLedgEntry.Reset();
                        OldCustLedgEntry.SetCurrentKey("External Document No.");
                        OldCustLedgEntry.SetRange("Document Type", GenJnlLine."Document Type");
                        OldCustLedgEntry.SetRange("Customer No.", GenJnlLine."Account No.");
                        OldCustLedgEntry.SetRange("External Document No.", GenJnlLine."External Document No.");
                        if OldCustLedgEntry.FindFirst() then
                            AddError(
                              StrSubstNo(
                                SalesDocAlreadyExistsErr,
                                GenJnlLine."Document Type", GenJnlLine."External Document No."));
                        CheckAgainstPrevLines("Gen. Journal Line");
                    end;
                end;
        end;
    end;

    local procedure CheckVend(var GenJnlLine: Record "Gen. Journal Line"; var AccName: Text[100])
    var
        VendorMgt: Codeunit "Vendor Mgt.";
    begin
        if not Vend.Get(GenJnlLine."Account No.") then
            AddError(
              StrSubstNo(
                MasterRecDoesNotExistErr,
                Vend.TableCaption, GenJnlLine."Account No."))
        else begin
            AccName := Vend.Name;
            if Vend."Privacy Blocked" then
                AddError(Vend.GetPrivacyBlockedGenericErrorText(Vend));
            if ((Vend.Blocked = Vend.Blocked::All) or
                ((Vend.Blocked = Vend.Blocked::Payment) and (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Payment))
                )
            then
                AddError(
                  StrSubstNo(
                    MustNotBeBlockedTypeErr,
                    GenJnlLine."Account Type", Vend.Blocked, GenJnlLine.FieldCaption(GenJnlLine."Document Type"), GenJnlLine."Document Type"));
            if GenJnlLine."Currency Code" <> '' then
                if not Currency.Get(GenJnlLine."Currency Code") then
                    AddError(
                      StrSubstNo(
                        CurrencyNotFoundErr,
                        GenJnlLine."Currency Code"));

            if (Vend."IC Partner Code" <> '') and (GenJnlTemplate.Type = GenJnlTemplate.Type::Intercompany) then
                if ICPartner.Get(Vend."IC Partner Code") then begin
                    if ICPartner.Blocked then
                        AddError(
                          StrSubstNo(
                            TwoTextsWithSpaceTok,
                            StrSubstNo(
                              IsLinkedToErr,
                              Vend.TableCaption, GenJnlLine."Account No.", ICPartner.TableCaption, Vend."IC Partner Code"),
                            StrSubstNo(
                              MustBeForErr,
                              ICPartner.FieldCaption(Blocked), false, ICPartner.TableCaption, Vend."IC Partner Code")));
                end else
                    AddError(
                      StrSubstNo(
                        TwoTextsWithSpaceTok,
                        StrSubstNo(
                          IsLinkedToErr,
                          Vend.TableCaption, GenJnlLine."Account No.", ICPartner.TableCaption, GenJnlLine."IC Partner Code"),
                        StrSubstNo(
                          MasterRecDoesNotExistErr,
                          ICPartner.TableCaption, Vend."IC Partner Code")));
            VendPosting := true;
            TestPostingType();

            if GenJnlLine."Recurring Method" = "Gen. Journal Recurring Method"::" " then
                if GenJnlLine."Document Type" in
                   [GenJnlLine."Document Type"::Invoice, GenJnlLine."Document Type"::"Credit Memo",
                    GenJnlLine."Document Type"::"Finance Charge Memo", GenJnlLine."Document Type"::Reminder]
                then begin
                    OldVendLedgEntry.Reset();
                    OldVendLedgEntry.SetCurrentKey("Document No.");
                    OldVendLedgEntry.SetRange("Document Type", GenJnlLine."Document Type");
                    OldVendLedgEntry.SetRange("Document No.", GenJnlLine."Document No.");
                    if OldVendLedgEntry.FindFirst() then
                        AddError(
                          StrSubstNo(
                            PurchaseDocAlreadyExistsErr,
                            GenJnlLine."Document Type", GenJnlLine."Document No."));

                    if PurchSetup."Ext. Doc. No. Mandatory" or
                       (GenJnlLine."External Document No." <> '')
                    then begin
                        if GenJnlLine."External Document No." = '' then
                            AddError(
                              StrSubstNo(
                                MustBeEnteredErr, GenJnlLine.FieldCaption(GenJnlLine."External Document No.")));

                        OldVendLedgEntry.Reset();
                        OldVendLedgEntry.SetCurrentKey("External Document No.");
                        VendorMgt.SetFilterForExternalDocNo(
                          OldVendLedgEntry, GenJnlLine."Document Type", GenJnlLine."External Document No.", GenJnlLine."Account No.", GenJnlLine."Document Date");
                        if OldVendLedgEntry.FindFirst() then
                            AddError(
                              StrSubstNo(
                                PurchaseDocAlreadyExistsErr,
                                GenJnlLine."Document Type", GenJnlLine."External Document No."))
                        else
                            CheckExtDocNoInPostedPurchDoc(GenJnlLine);
                        CheckAgainstPrevLines("Gen. Journal Line");
                    end;
                end;
        end;
    end;

    local procedure CheckEmployee(var GenJnlLine: Record "Gen. Journal Line"; var AccName: Text[100])
    begin
        if not Employee.Get(GenJnlLine."Account No.") then
            AddError(StrSubstNo(MasterRecDoesNotExistErr, Employee.TableCaption, GenJnlLine."Account No."))
        else begin
            AccName := Employee."No.";
            if Employee."Privacy Blocked" then
                AddError(StrSubstNo(MustBeForErr, Employee.FieldCaption("Privacy Blocked"), false, Employee.TableCaption, AccName))
        end;
    end;

    local procedure CheckBankAcc(var GenJnlLine: Record "Gen. Journal Line"; var AccName: Text[100])
    begin
        if not BankAcc.Get(GenJnlLine."Account No.") then
            AddError(
              StrSubstNo(
                MasterRecDoesNotExistErr,
                BankAcc.TableCaption, GenJnlLine."Account No."))
        else begin
            AccName := BankAcc.Name;

            if BankAcc.Blocked then
                AddError(
                  StrSubstNo(
                    MustBeForErr,
                    BankAcc.FieldCaption(Blocked), false, BankAcc.TableCaption, GenJnlLine."Account No."));
            if (GenJnlLine."Currency Code" <> BankAcc."Currency Code") and (BankAcc."Currency Code" <> '') then
                AddError(
                  StrSubstNo(
                    MustBeErr,
                    GenJnlLine.FieldCaption(GenJnlLine."Currency Code"), BankAcc."Currency Code"));

            if GenJnlLine."Currency Code" <> '' then
                if not Currency.Get(GenJnlLine."Currency Code") then
                    AddError(
                      StrSubstNo(
                        CurrencyNotFoundErr,
                        GenJnlLine."Currency Code"));

            if GenJnlLine."Bank Payment Type" <> GenJnlLine."Bank Payment Type"::" " then
                if (GenJnlLine."Bank Payment Type" = GenJnlLine."Bank Payment Type"::"Computer Check") and (GenJnlLine.Amount < 0) then
                    if BankAcc."Currency Code" <> GenJnlLine."Currency Code" then
                        AddError(
                          StrSubstNo(
                            MustNotBeFilledWhenErr,
                            GenJnlLine.FieldCaption(GenJnlLine."Bank Payment Type"), GenJnlLine.FieldCaption(GenJnlLine."Currency Code"),
                            GenJnlLine.TableCaption, BankAcc.TableCaption));

            if BankAccPostingGr.Get(BankAcc."Bank Acc. Posting Group") then
                if BankAccPostingGr."G/L Account No." <> '' then
                    ReconcileGLAccNo(
                      BankAccPostingGr."G/L Account No.",
                      Round(GenJnlLine."Amount (LCY)" / (1 + GenJnlLine."VAT %" / 100)));
        end;
    end;

    local procedure CheckFixedAsset(var GenJnlLine: Record "Gen. Journal Line"; var AccName: Text[100])
    begin
        if not FA.Get(GenJnlLine."Account No.") then
            AddError(
              StrSubstNo(
                MasterRecDoesNotExistErr,
                FA.TableCaption, GenJnlLine."Account No."))
        else begin
            AccName := FA.Description;
            if FA.Blocked then
                AddError(
                  StrSubstNo(
                    MustBeForErr,
                    FA.FieldCaption(Blocked), false, FA.TableCaption, GenJnlLine."Account No."));
            if FA.Inactive then
                AddError(
                  StrSubstNo(
                    MustBeForErr,
                    FA.FieldCaption(Inactive), false, FA.TableCaption, GenJnlLine."Account No."));
            if FA."Budgeted Asset" then
                AddError(
                  StrSubstNo(
                    MustNotHaveEqualErr,
                    FA.TableCaption, GenJnlLine."Account No.", FA.FieldCaption("Budgeted Asset"), true));
            if DeprBook.Get(GenJnlLine."Depreciation Book Code") then
                CheckFAIntegration(GenJnlLine)
            else
                AddError(
                  StrSubstNo(
                    MasterRecDoesNotExistErr,
                    DeprBook.TableCaption, GenJnlLine."Depreciation Book Code"));
            if not FADeprBook.Get(FA."No.", GenJnlLine."Depreciation Book Code") then
                AddError(
                  StrSubstNo(
                    RecordDoesNotExistErr,
                    FADeprBook.TableCaption, FA."No.", GenJnlLine."Depreciation Book Code"));
        end;
    end;

    local procedure CheckICPartner(var GenJnlLine: Record "Gen. Journal Line"; var AccName: Text[100])
    begin
        if not ICPartner.Get(GenJnlLine."Account No.") then
            AddError(
              StrSubstNo(
                MasterRecDoesNotExistErr,
                ICPartner.TableCaption, GenJnlLine."Account No."))
        else begin
            AccName := ICPartner.Name;
            if ICPartner.Blocked then
                AddError(
                  StrSubstNo(
                    MustBeForErr,
                    ICPartner.FieldCaption(Blocked), false, ICPartner.TableCaption, GenJnlLine."Account No."));
        end;
    end;

    local procedure TestFixedAsset(var GenJnlLine: Record "Gen. Journal Line")
    begin
        FASetup.Get();
        if GenJnlLine."Job No." <> '' then
            AddError(
              StrSubstNo(
                MustNotBeSpecifiedInFAJnlErr, GenJnlLine.FieldCaption(GenJnlLine."Job No.")));
        if GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::" " then
            AddError(
              StrSubstNo(
                MustBeSpecifiedInFAJnlErr, GenJnlLine.FieldCaption(GenJnlLine."FA Posting Type")));
        if GenJnlLine."Depreciation Book Code" = '' then
            AddError(
              StrSubstNo(
                MustBeSpecifiedInFAJnlErr, GenJnlLine.FieldCaption(GenJnlLine."Depreciation Book Code")));
        if GenJnlLine."Depreciation Book Code" = GenJnlLine."Duplicate in Depreciation Book" then
            AddError(
              StrSubstNo(
                MustBeDifferentThanErr,
                GenJnlLine.FieldCaption(GenJnlLine."Depreciation Book Code"), GenJnlLine.FieldCaption(GenJnlLine."Duplicate in Depreciation Book")));
        CheckFADocNo(GenJnlLine);
        if GenJnlLine."Account Type" = GenJnlLine."Bal. Account Type" then
            AddError(
              StrSubstNo(
                MustNotBothBeErr,
                GenJnlLine.FieldCaption(GenJnlLine."Account Type"), GenJnlLine.FieldCaption(GenJnlLine."Bal. Account Type"), GenJnlLine."Account Type"));
        if GenJnlLine."Account Type" = GenJnlLine."Account Type"::"Fixed Asset" then
            if (GenJnlLine."FA Posting Type" in
                [GenJnlLine."FA Posting Type"::"Acquisition Cost", GenJnlLine."FA Posting Type"::Disposal, GenJnlLine."FA Posting Type"::Maintenance]) or
               (FASetup."FA Acquisition As Custom 2" and (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::"Custom 2"))
            then begin
                if (GenJnlLine."Gen. Bus. Posting Group" <> '') or (GenJnlLine."Gen. Prod. Posting Group" <> '') then
                    if GenJnlLine."Gen. Posting Type" = GenJnlLine."Gen. Posting Type"::" " then
                        AddError(StrSubstNo(FieldMustBeSpecifiedErr, GenJnlLine.FieldCaption(GenJnlLine."Gen. Posting Type")));
            end else begin
                if GenJnlLine."Gen. Posting Type" <> GenJnlLine."Gen. Posting Type"::" " then
                    AddError(
                      StrSubstNo(
                        MustNotBeSpecifiedWhenErr,
                        GenJnlLine.FieldCaption(GenJnlLine."Gen. Posting Type"), GenJnlLine.FieldCaption(GenJnlLine."FA Posting Type"), GenJnlLine."FA Posting Type"));
                if GenJnlLine."Gen. Bus. Posting Group" <> '' then
                    AddError(
                      StrSubstNo(
                        MustNotBeSpecifiedWhenErr,
                        GenJnlLine.FieldCaption(GenJnlLine."Gen. Bus. Posting Group"), GenJnlLine.FieldCaption(GenJnlLine."FA Posting Type"), GenJnlLine."FA Posting Type"));
                if GenJnlLine."Gen. Prod. Posting Group" <> '' then
                    AddError(
                      StrSubstNo(
                        MustNotBeSpecifiedWhenErr,
                        GenJnlLine.FieldCaption(GenJnlLine."Gen. Prod. Posting Group"), GenJnlLine.FieldCaption(GenJnlLine."FA Posting Type"), GenJnlLine."FA Posting Type"));
            end;
        if GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::"Fixed Asset" then
            if (GenJnlLine."FA Posting Type" in
                [GenJnlLine."FA Posting Type"::"Acquisition Cost", GenJnlLine."FA Posting Type"::Disposal, GenJnlLine."FA Posting Type"::Maintenance]) or
               (FASetup."FA Acquisition As Custom 2" and (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::"Custom 2"))
            then begin
                if (GenJnlLine."Bal. Gen. Bus. Posting Group" <> '') or (GenJnlLine."Bal. Gen. Prod. Posting Group" <> '') then
                    if GenJnlLine."Bal. Gen. Posting Type" = GenJnlLine."Bal. Gen. Posting Type"::" " then
                        AddError(StrSubstNo(FieldMustBeSpecifiedErr, GenJnlLine.FieldCaption(GenJnlLine."Bal. Gen. Posting Type")));
            end else begin
                if GenJnlLine."Bal. Gen. Posting Type" <> GenJnlLine."Bal. Gen. Posting Type"::" " then
                    AddError(
                      StrSubstNo(
                        MustNotBeSpecifiedWhenErr,
                        GenJnlLine.FieldCaption(GenJnlLine."Bal. Gen. Posting Type"), GenJnlLine.FieldCaption(GenJnlLine."FA Posting Type"), GenJnlLine."FA Posting Type"));
                if GenJnlLine."Bal. Gen. Bus. Posting Group" <> '' then
                    AddError(
                      StrSubstNo(
                        MustNotBeSpecifiedWhenErr,
                        GenJnlLine.FieldCaption(GenJnlLine."Bal. Gen. Bus. Posting Group"), GenJnlLine.FieldCaption(GenJnlLine."FA Posting Type"), GenJnlLine."FA Posting Type"));
                if GenJnlLine."Bal. Gen. Prod. Posting Group" <> '' then
                    AddError(
                      StrSubstNo(
                        MustNotBeSpecifiedWhenErr,
                        GenJnlLine.FieldCaption(GenJnlLine."Bal. Gen. Prod. Posting Group"), GenJnlLine.FieldCaption(GenJnlLine."FA Posting Type"), GenJnlLine."FA Posting Type"));
            end;
        TempErrorText :=
          '%1 ' +
          StrSubstNo(
            MustNotBeSpecifiedTogetherErr,
            GenJnlLine.FieldCaption(GenJnlLine."FA Posting Type"), GenJnlLine."FA Posting Type");
        if GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::"Acquisition Cost" then begin
            if GenJnlLine."Depr. Acquisition Cost" then
                AddError(StrSubstNo(TempErrorText, GenJnlLine.FieldCaption(GenJnlLine."Depr. Acquisition Cost")));
            if GenJnlLine."Salvage Value" <> 0 then
                AddError(StrSubstNo(TempErrorText, GenJnlLine.FieldCaption(GenJnlLine."Salvage Value")));
            if GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::Maintenance then
                if GenJnlLine.Quantity <> 0 then
                    AddError(StrSubstNo(TempErrorText, GenJnlLine.FieldCaption(GenJnlLine.Quantity)));
            if GenJnlLine."Insurance No." <> '' then
                AddError(StrSubstNo(TempErrorText, GenJnlLine.FieldCaption(GenJnlLine."Insurance No.")));
        end;
        if (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::Maintenance) and GenJnlLine."Depr. until FA Posting Date" then
            AddError(StrSubstNo(TempErrorText, GenJnlLine.FieldCaption(GenJnlLine."Depr. until FA Posting Date")));
        if (GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::Maintenance) and (GenJnlLine."Maintenance Code" <> '') then
            AddError(StrSubstNo(TempErrorText, GenJnlLine.FieldCaption(GenJnlLine."Maintenance Code")));

        if (GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::Depreciation) and
           (GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::"Custom 1") and
           (GenJnlLine."No. of Depreciation Days" <> 0)
        then
            AddError(StrSubstNo(TempErrorText, GenJnlLine.FieldCaption(GenJnlLine."No. of Depreciation Days")));

        if (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::Disposal) and GenJnlLine."FA Reclassification Entry" then
            AddError(StrSubstNo(TempErrorText, GenJnlLine.FieldCaption(GenJnlLine."FA Reclassification Entry")));

        if (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::Disposal) and (GenJnlLine."Budgeted FA No." <> '') then
            AddError(StrSubstNo(TempErrorText, GenJnlLine.FieldCaption(GenJnlLine."Budgeted FA No.")));

        if GenJnlLine."FA Posting Date" = 0D then
            GenJnlLine."FA Posting Date" := GenJnlLine."Posting Date";
        if DeprBook.Get(GenJnlLine."Depreciation Book Code") then
            if DeprBook."Use Same FA+G/L Posting Dates" and (GenJnlLine."Posting Date" <> GenJnlLine."FA Posting Date") then
                if not GenJnlLine."FA Reclassification Entry" then
                    AddError(
                      StrSubstNo(
                        MustBeIdenticalErr,
                        GenJnlLine.FieldCaption(GenJnlLine."Posting Date"), GenJnlLine.FieldCaption(GenJnlLine."FA Posting Date")));
        if GenJnlLine."FA Posting Date" <> 0D then begin
            if GenJnlLine."FA Posting Date" <> NormalDate(GenJnlLine."FA Posting Date") then
                AddError(
                  StrSubstNo(
                    CannotBeClosingDateErr,
                    GenJnlLine.FieldCaption(GenJnlLine."FA Posting Date")));
            if not (GenJnlLine."FA Posting Date" in [DMY2Date(1, 1, 2) .. DMY2Date(31, 12, 9998)]) then
                AddError(
                  StrSubstNo(
                    PostingDateNotInRangeErr,
                    GenJnlLine.FieldCaption(GenJnlLine."FA Posting Date")));
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
            if (GenJnlLine."FA Posting Date" < AllowFAPostingFrom) or
               (GenJnlLine."FA Posting Date" > AllowFAPostingTo)
            then
                AddError(
                  StrSubstNo(
                    PostingDateNotInRangeErr,
                    GenJnlLine.FieldCaption(GenJnlLine."FA Posting Date")));
        end;
        FASetup.Get();
        if (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::"Acquisition Cost") and
           (GenJnlLine."Insurance No." <> '') and (GenJnlLine."Depreciation Book Code" <> FASetup."Insurance Depr. Book")
        then
            AddError(
              StrSubstNo(
                InsuranceIntegrationNotActiveErr,
                GenJnlLine.FieldCaption(GenJnlLine."Depreciation Book Code"), GenJnlLine."Depreciation Book Code"));

        if GenJnlLine."FA Error Entry No." > 0 then begin
            TempErrorText :=
              '%1 ' +
              StrSubstNo(
                MustNotBeSpecifiedWhen2Err,
                GenJnlLine.FieldCaption(GenJnlLine."FA Error Entry No."));
            if GenJnlLine."Depr. until FA Posting Date" then
                AddError(StrSubstNo(TempErrorText, GenJnlLine.FieldCaption(GenJnlLine."Depr. until FA Posting Date")));
            if GenJnlLine."Depr. Acquisition Cost" then
                AddError(StrSubstNo(TempErrorText, GenJnlLine.FieldCaption(GenJnlLine."Depr. Acquisition Cost")));
            if GenJnlLine."Duplicate in Depreciation Book" <> '' then
                AddError(StrSubstNo(TempErrorText, GenJnlLine.FieldCaption(GenJnlLine."Duplicate in Depreciation Book")));
            if GenJnlLine."Use Duplication List" then
                AddError(StrSubstNo(TempErrorText, GenJnlLine.FieldCaption(GenJnlLine."Use Duplication List")));
            if GenJnlLine."Salvage Value" <> 0 then
                AddError(StrSubstNo(TempErrorText, GenJnlLine.FieldCaption(GenJnlLine."Salvage Value")));
            if GenJnlLine."Insurance No." <> '' then
                AddError(StrSubstNo(TempErrorText, GenJnlLine.FieldCaption(GenJnlLine."Insurance No.")));
            if GenJnlLine."Budgeted FA No." <> '' then
                AddError(StrSubstNo(TempErrorText, GenJnlLine.FieldCaption(GenJnlLine."Budgeted FA No.")));
            if GenJnlLine."Recurring Method" <> "Gen. Journal Recurring Method"::" " then
                AddError(StrSubstNo(TempErrorText, GenJnlLine.FieldCaption(GenJnlLine."Recurring Method")));
            if GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::Maintenance then
                AddError(StrSubstNo(TempErrorText, GenJnlLine."FA Posting Type"));
        end;

    end;

    local procedure CheckFAIntegration(var GenJnlLine: Record "Gen. Journal Line")
    var
        GLIntegration: Boolean;
    begin
        if GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::" " then
            exit;
        case GenJnlLine."FA Posting Type" of
            GenJnlLine."FA Posting Type"::"Acquisition Cost":
                GLIntegration := DeprBook."G/L Integration - Acq. Cost";
            GenJnlLine."FA Posting Type"::Depreciation:
                GLIntegration := DeprBook."G/L Integration - Depreciation";
            GenJnlLine."FA Posting Type"::"Write-Down":
                GLIntegration := DeprBook."G/L Integration - Write-Down";
            GenJnlLine."FA Posting Type"::Appreciation:
                GLIntegration := DeprBook."G/L Integration - Appreciation";
            GenJnlLine."FA Posting Type"::"Custom 1":
                GLIntegration := DeprBook."G/L Integration - Custom 1";
            GenJnlLine."FA Posting Type"::"Custom 2":
                GLIntegration := DeprBook."G/L Integration - Custom 2";
            GenJnlLine."FA Posting Type"::Disposal:
                GLIntegration := DeprBook."G/L Integration - Disposal";
            GenJnlLine."FA Posting Type"::Maintenance:
                GLIntegration := DeprBook."G/L Integration - Maintenance";
        end;
        if not GLIntegration then
            AddError(
              StrSubstNo(
                MustNotBePostedWhenGLIntegrationErr,
                GenJnlLine."FA Posting Type"));

        if not DeprBook."G/L Integration - Depreciation" then begin
            if GenJnlLine."Depr. until FA Posting Date" then
                AddError(
                  StrSubstNo(
                    MustNotBeSpecWhenGLIntegrationErr,
                    GenJnlLine.FieldCaption(GenJnlLine."Depr. until FA Posting Date")));
            if GenJnlLine."Depr. Acquisition Cost" then
                AddError(
                  StrSubstNo(
                    MustNotBeSpecWhenGLIntegrationErr,
                    GenJnlLine.FieldCaption(GenJnlLine."Depr. Acquisition Cost")));
        end;
    end;

    local procedure TestFixedAssetFields(var GenJnlLine: Record "Gen. Journal Line")
    begin
        if GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::" " then
            AddError(StrSubstNo(MustNotBeSpecifiedErr, GenJnlLine.FieldCaption(GenJnlLine."FA Posting Type")));
        if GenJnlLine."Depreciation Book Code" <> '' then
            AddError(StrSubstNo(MustNotBeSpecifiedErr, GenJnlLine.FieldCaption(GenJnlLine."Depreciation Book Code")));
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

    local procedure WarningIfNegativeAmt(GenJnlLine: Record "Gen. Journal Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeWarningIfNegativeAmt(GenJnlLine, IsHandled);
        if IsHandled then
            exit;

        if (GenJnlLine.Amount < 0) and not AmountError then begin
            AmountError := true;
            AddError(StrSubstNo(MustBePositiveErr, GenJnlLine.FieldCaption(Amount)));
        end;
    end;

    local procedure WarningIfPositiveAmt(GenJnlLine: Record "Gen. Journal Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeWarningIfPositiveAmt(GenJnlLine, IsHandled);
        if IsHandled then
            exit;

        if (GenJnlLine.Amount > 0) and not AmountError then begin
            AmountError := true;
            AddError(StrSubstNo(MustBeNegativeErr, GenJnlLine.FieldCaption(Amount)));
        end;
    end;

    local procedure WarningIfZeroAmt(GenJnlLine: Record "Gen. Journal Line")
    begin
        if (GenJnlLine.Amount = 0) and not AmountError then begin
            AmountError := true;
            AddError(StrSubstNo(FieldMustBeSpecifiedErr, GenJnlLine.FieldCaption(Amount)));
        end;
    end;

    local procedure WarningIfNonZeroAmt(GenJnlLine: Record "Gen. Journal Line")
    begin
        if (GenJnlLine.Amount <> 0) and not AmountError then begin
            AmountError := true;
            AddError(StrSubstNo(MustNotBeZeroErr, GenJnlLine.FieldCaption(Amount)));
        end;
    end;

    local procedure CheckAgainstPrevLines(GenJnlLine: Record "Gen. Journal Line")
    var
        i: Integer;
        AccType: Enum "Gen. Journal Account Type";
        AccNo: Code[20];
        ErrorFound: Boolean;
    begin
        if (GenJnlLine."External Document No." = '') or
           not (GenJnlLine."Account Type" in
                [GenJnlLine."Account Type"::Customer, GenJnlLine."Account Type"::Vendor]) and
           not (GenJnlLine."Bal. Account Type" in
                [GenJnlLine."Bal. Account Type"::Customer, GenJnlLine."Bal. Account Type"::Vendor])
        then
            exit;

        if GenJnlLine."Account Type" in [GenJnlLine."Account Type"::Customer, GenJnlLine."Account Type"::Vendor] then begin
            AccType := GenJnlLine."Account Type";
            AccNo := GenJnlLine."Account No.";
        end else begin
            AccType := GenJnlLine."Bal. Account Type";
            AccNo := GenJnlLine."Bal. Account No.";
        end;

        TempGenJnlLine.Reset();
        TempGenJnlLine.SetRange("External Document No.", GenJnlLine."External Document No.");

        i := 0;
        while (i < 2) and not ErrorFound do begin
            i := i + 1;
            if i = 1 then begin
                TempGenJnlLine.SetRange("Account Type", AccType);
                TempGenJnlLine.SetRange("Account No.", AccNo);
                TempGenJnlLine.SetRange("Bal. Account Type");
                TempGenJnlLine.SetRange("Bal. Account No.");
            end else begin
                TempGenJnlLine.SetRange("Account Type");
                TempGenJnlLine.SetRange("Account No.");
                TempGenJnlLine.SetRange("Bal. Account Type", AccType);
                TempGenJnlLine.SetRange("Bal. Account No.", AccNo);
            end;
            if TempGenJnlLine.FindFirst() then begin
                ErrorFound := true;
                AddError(
                  StrSubstNo(
                    AlreadyUsedInLineErr, GenJnlLine.FieldCaption("External Document No."), GenJnlLine."External Document No.",
                    TempGenJnlLine."Line No.", GenJnlLine.FieldCaption("Document No."), TempGenJnlLine."Document No."));
            end;
        end;

        TempGenJnlLine.Reset();
        TempGenJnlLine := GenJnlLine;
        TempGenJnlLine.Insert();
    end;

    local procedure CheckICDocument()
    var
        GenJnlLine4: Record "Gen. Journal Line";
        ICGLAccount: Record "IC G/L Account";
    begin
        if GenJnlTemplate.Type = GenJnlTemplate.Type::Intercompany then begin
            if ("Gen. Journal Line"."Posting Date" <> LastDate) or ("Gen. Journal Line"."Document Type" <> LastDocType) or ("Gen. Journal Line"."Document No." <> LastDocNo) then begin
                GenJnlLine4.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
                GenJnlLine4.SetRange("Journal Template Name", "Gen. Journal Line"."Journal Template Name");
                GenJnlLine4.SetRange("Journal Batch Name", "Gen. Journal Line"."Journal Batch Name");
                GenJnlLine4.SetRange("Posting Date", "Gen. Journal Line"."Posting Date");
                GenJnlLine4.SetRange("Document No.", "Gen. Journal Line"."Document No.");
                GenJnlLine4.SetFilter("IC Partner Code", '<>%1', '');
                if GenJnlLine4.FindFirst() then
                    CurrentICPartner := GenJnlLine4."IC Partner Code"
                else
                    CurrentICPartner := '';
            end;
            if (CurrentICPartner <> '') and ("Gen. Journal Line"."IC Direction" = "Gen. Journal Line"."IC Direction"::Outgoing) then begin
                if ("Gen. Journal Line"."Account Type" in ["Gen. Journal Line"."Account Type"::"G/L Account", "Gen. Journal Line"."Account Type"::"Bank Account"]) and
                   ("Gen. Journal Line"."Bal. Account Type" in ["Gen. Journal Line"."Bal. Account Type"::"G/L Account", "Gen. Journal Line"."Account Type"::"Bank Account"]) and
                   ("Gen. Journal Line"."Account No." <> '') and
                   ("Gen. Journal Line"."Bal. Account No." <> '')
                then
                    AddError(
                      StrSubstNo(
                        CannotEnterGLBankAccErr, "Gen. Journal Line".FieldCaption("Gen. Journal Line"."Account No."), "Gen. Journal Line".FieldCaption("Gen. Journal Line"."Bal. Account No.")))
                else
                    if (("Gen. Journal Line"."Account Type" in ["Gen. Journal Line"."Account Type"::"G/L Account", "Gen. Journal Line"."Account Type"::"Bank Account"]) and ("Gen. Journal Line"."Account No." <> '')) xor
                       (("Gen. Journal Line"."Bal. Account Type" in ["Gen. Journal Line"."Bal. Account Type"::"G/L Account", "Gen. Journal Line"."Account Type"::"Bank Account"]) and
                        ("Gen. Journal Line"."Bal. Account No." <> ''))
                    then begin
                        if "Gen. Journal Line"."IC Partner G/L Acc. No." = '' then
                            AddError(
                              StrSubstNo(
                                FieldMustBeSpecifiedErr, "Gen. Journal Line".FieldCaption("Gen. Journal Line"."IC Partner G/L Acc. No.")))
                        else
                            if ICGLAccount.Get("Gen. Journal Line"."IC Partner G/L Acc. No.") then
                                if ICGLAccount.Blocked then
                                    AddError(
                                      StrSubstNo(
                                        MustBeForErr,
                                        ICGLAccount.FieldCaption(Blocked), false, "Gen. Journal Line".FieldCaption("Gen. Journal Line"."IC Partner G/L Acc. No."),
                                        "Gen. Journal Line"."IC Partner G/L Acc. No."
                                        ));
                    end else
                        if "Gen. Journal Line"."IC Partner G/L Acc. No." <> '' then
                            AddError(
                              StrSubstNo(
                                CannotBeSpecifiedErr, "Gen. Journal Line".FieldCaption("Gen. Journal Line"."IC Partner G/L Acc. No.")));
            end else
                if "Gen. Journal Line"."IC Partner G/L Acc. No." <> '' then begin
                    if "Gen. Journal Line"."IC Direction" = "Gen. Journal Line"."IC Direction"::Incoming then
                        AddError(
                          StrSubstNo(
                            MustNotBeSpecifiedWhenIsErr, "Gen. Journal Line".FieldCaption("Gen. Journal Line"."IC Partner G/L Acc. No."), "Gen. Journal Line".FieldCaption("Gen. Journal Line"."IC Direction"), Format("Gen. Journal Line"."IC Direction")));
                    if CurrentICPartner = '' then
                        AddError(
                          StrSubstNo(
                            MustNotBeSpecifiedWhenInterDocErr, "Gen. Journal Line".FieldCaption("Gen. Journal Line"."IC Partner G/L Acc. No.")));
                end;
        end;
    end;

    local procedure TestJobFields(var GenJnlLine: Record "Gen. Journal Line")
    var
        Job: Record Job;
        JT: Record "Job Task";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestJobFields(GenJnlLine, ErrorCounter, ErrorText, IsHandled);
        if IsHandled then
            exit;

        if (GenJnlLine."Job No." = '') or (GenJnlLine."Account Type" <> GenJnlLine."Account Type"::"G/L Account") then
            exit;
        if not Job.Get(GenJnlLine."Job No.") then
            AddError(StrSubstNo(MasterRecDoesNotExistErr, Job.TableCaption, GenJnlLine."Job No."))
        else
            if Job.Blocked <> Job.Blocked::" " then
                AddError(
                  StrSubstNo(
                    MustNotBeFor4Err, Job.FieldCaption(Blocked), Job.Blocked, Job.TableCaption, GenJnlLine."Job No."));

        if GenJnlLine."Job Task No." = '' then
            AddError(StrSubstNo(FieldMustBeSpecifiedErr, GenJnlLine.FieldCaption(GenJnlLine."Job Task No.")))
        else
            if not JT.Get(GenJnlLine."Job No.", GenJnlLine."Job Task No.") then
                AddError(StrSubstNo(MasterRecDoesNotExistErr, JT.TableCaption, GenJnlLine."Job Task No."));

        OnAfterTestJobFields(GenJnlLine, ErrorCounter, ErrorText);
    end;

    local procedure CheckFADocNo(GenJnlLine: Record "Gen. Journal Line")
    var
        DeprBookLocal: Record "Depreciation Book";
        FAJnlLine: Record "FA Journal Line";
        OldFALedgEntry: Record "FA Ledger Entry";
        OldMaintenanceLedgEntry: Record "Maintenance Ledger Entry";
        FANo: Code[20];
    begin
        if GenJnlLine."Account Type" = GenJnlLine."Account Type"::"Fixed Asset" then
            FANo := GenJnlLine."Account No.";
        if GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::"Fixed Asset" then
            FANo := GenJnlLine."Bal. Account No.";
        if (FANo = '') or
           (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::" ") or
           (GenJnlLine."Depreciation Book Code" = '') or
           (GenJnlLine."Document No." = '')
        then
            exit;
        if not DeprBookLocal.Get(GenJnlLine."Depreciation Book Code") then
            exit;
        if DeprBookLocal."Allow Identical Document No." then
            exit;

        FAJnlLine."FA Posting Type" := "FA Journal Line FA Posting Type".FromInteger(GenJnlLine."FA Posting Type".AsInteger() - 1);
        if GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::Maintenance then begin
            OldFALedgEntry.SetCurrentKey(
              "FA No.", "Depreciation Book Code", "FA Posting Category", "FA Posting Type", "Document No.");
            OldFALedgEntry.SetRange("FA No.", FANo);
            OldFALedgEntry.SetRange("Depreciation Book Code", GenJnlLine."Depreciation Book Code");
            OldFALedgEntry.SetRange("FA Posting Category", OldFALedgEntry."FA Posting Category"::" ");
            OldFALedgEntry.SetRange("FA Posting Type", FAJnlLine.ConvertToLedgEntry(FAJnlLine));
            OldFALedgEntry.SetRange("Document No.", GenJnlLine."Document No.");
            if not OldFALedgEntry.IsEmpty() then
                AddError(
                  StrSubstNo(
                    AlreadyExistsErr,
                    GenJnlLine.FieldCaption(GenJnlLine."Document No."), GenJnlLine."Document No."));
        end else begin
            OldMaintenanceLedgEntry.SetCurrentKey(
              "FA No.", "Depreciation Book Code", "Document No.");
            OldMaintenanceLedgEntry.SetRange("FA No.", FANo);
            OldMaintenanceLedgEntry.SetRange("Depreciation Book Code", GenJnlLine."Depreciation Book Code");
            OldMaintenanceLedgEntry.SetRange("Document No.", GenJnlLine."Document No.");
            if not OldMaintenanceLedgEntry.IsEmpty() then
                AddError(
                  StrSubstNo(
                    AlreadyExistsErr,
                    GenJnlLine.FieldCaption(GenJnlLine."Document No."), GenJnlLine."Document No."));
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
        until DimSetEntry.Next() = 0;
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
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.CopyFilters(FromGenJournalLine);
        GenJournalLine.SetCurrentKey("Document No.");
        if GenJournalLine.FindLast() then;
        exit(GenJournalLine."Document No.");
    end;

    local procedure IsGapInNosForDocNo(var FromGenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        if LastEnteredDocNo = '' then
            exit(false);
        if FromGenJournalLine."Document No." = LastEnteredDocNo then
            exit(false);

        GenJournalLine.CopyFilters(FromGenJournalLine);
        GenJournalLine.SetRange("Document No.", IncStr(FromGenJournalLine."Document No."));
        exit(GenJournalLine.IsEmpty);
    end;

    local procedure CheckExtDocNoInPostedPurchDoc(GenJnlLine: Record "Gen. Journal Line")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        case GenJnlLine."Document Type" of
            GenJnlLine."Document Type"::Invoice:
                begin
                    PurchInvHeader.Reset();
                    PurchInvHeader.SetCurrentKey("Vendor Invoice No.");
                    PurchInvHeader.SetRange("Vendor Invoice No.", GenJnlLine."External Document No.");
                    PurchInvHeader.SetRange("Pay-to Vendor No.", GenJnlLine."Account No.");
                    if not PurchInvHeader.IsEmpty then
                        AddError(
                          StrSubstNo(
                            PurchaseDocAlreadyExistsErr,
                            GenJnlLine."Document Type", GenJnlLine."External Document No."));
                end;
            GenJnlLine."Document Type"::"Credit Memo":
                begin
                    PurchCrMemoHdr.Reset();
                    PurchCrMemoHdr.SetCurrentKey("Vendor Cr. Memo No.");
                    PurchCrMemoHdr.SetRange("Vendor Cr. Memo No.", GenJnlLine."External Document No.");
                    PurchCrMemoHdr.SetRange("Pay-to Vendor No.", GenJnlLine."Account No.");
                    if not PurchCrMemoHdr.IsEmpty then
                        AddError(
                          StrSubstNo(
                            PurchaseDocAlreadyExistsErr,
                            GenJnlLine."Document Type", GenJnlLine."External Document No."));
                end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignDimTableID(GenJournalLine: Record "Gen. Journal Line"; var TableID: array[10] of Integer; var No: array[10] of Code[20])
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterCheckGLAcc(GenJournalLine: Record "Gen. Journal Line"; GLAccount: Record "G/L Account"; var ErrorCounter: Integer; var ErrorText: array[50] of Text[250])
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterCheckGenJnlLine(GenJournalLine: Record "Gen. Journal Line"; var ErrorCounter: Integer; var ErrorText: array[50] of Text[250])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestJobFields(GenJournalLine: Record "Gen. Journal Line"; var ErrorCounter: Integer; var ErrorText: array[50] of Text[250])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestJobFields(var GenJournalLine: Record "Gen. Journal Line"; var ErrorCounter: Integer; var ErrorText: Array[50] of Text[250]; var IsHandled: Boolean)
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
