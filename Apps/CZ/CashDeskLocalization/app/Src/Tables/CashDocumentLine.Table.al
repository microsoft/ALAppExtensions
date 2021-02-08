#pragma warning disable AL0432
table 11733 "Cash Document Line CZP"
{
    Caption = 'Cash Document Line';
    DrillDownPageID = "Cash Document Lines CZP";

    fields
    {
        field(1; "Cash Desk No."; Code[20])
        {
            Caption = 'Cash Desk No.';
            TableRelation = "Cash Desk CZP";
            DataClassification = CustomerContent;
        }
        field(2; "Cash Document No."; Code[20])
        {
            Caption = 'Cash Document No.';
            TableRelation = "Cash Document Header CZP"."No." where("Cash Desk No." = field("Cash Desk No."));
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Gen. Document Type"; Enum "Cash Document Gen.Doc.Type CZP")
        {
            Caption = 'Gen. Document Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(5; "Account Type"; Enum "Cash Document Account Type CZP")
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
#if not CLEAN18
                if "Account Type" <> xRec."Account Type" then
                    TestField("Advance Letter Link Code", '');
#endif
                GetCashDeskEventCZP();
                if CashDeskEventCZP."Account Type" <> CashDeskEventCZP."Account Type"::" " then
                    CashDeskEventCZP.TestField("Account Type", "Account Type");

                GetCashDocumentHeaderCZP();

                TempCashDocumentLineCZP := Rec;
                Init();
                "Document Type" := CashDocumentHeaderCZP."Document Type";
                "Account Type" := TempCashDocumentLineCZP."Account Type";
                "Cash Desk Event" := TempCashDocumentLineCZP."Cash Desk Event";
                UpdateAmounts();
                UpdateDocumentType();
            end;
        }
        field(6; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = if ("Account Type" = const(" ")) "Standard Text" else
            if ("Account Type" = const("G/L Account")) "G/L Account" else
            if ("Account Type" = const(Customer)) Customer else
            if ("Account Type" = const(Vendor)) Vendor else
            if ("Account Type" = const(Employee)) Employee else
            if ("Account Type" = const("Bank Account")) "Bank Account" where("Account Type CZP" = const("Bank Account")) else
            if ("Account Type" = const("Fixed Asset")) "Fixed Asset";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                StandardText: Record "Standard Text";
                GLAccount: Record "G/L Account";
                Customer: Record Customer;
                Vendor: Record Vendor;
                CashDeskCZP: Record "Bank Account";
                Employee: Record Employee;
            begin
#if not CLEAN18
                if "Account No." <> xRec."Account No." then
                    TestField("Advance Letter Link Code", '');
#endif
                GetCashDeskEventCZP();
                if CashDeskEventCZP."Account No." <> '' then
                    CashDeskEventCZP.TestField("Account No.", "Account No.");

                GetCashDocumentHeaderCZP();
                if ("Account Type" in ["Account Type"::Customer, "Account Type"::Vendor]) and ("Account No." <> '') then
                    if CashDocumentHeaderCZP."Partner No." = '' then begin
                        case "Account Type" of
                            "Account Type"::Customer:
                                CashDocumentHeaderCZP."Partner Type" := CashDocumentHeaderCZP."Partner Type"::Customer;
                            "Account Type"::Vendor:
                                CashDocumentHeaderCZP."Partner Type" := CashDocumentHeaderCZP."Partner Type"::Vendor;
                        end;
                        CashDocumentHeaderCZP.SetSkipLineNoToUpdateLine("Line No.");
                        CashDocumentHeaderCZP.Validate("Partner No.", "Account No.");
                        CashDocumentHeaderCZP.Modify();
                        CashDocumentHeaderCZP.SetSkipLineNoToUpdateLine(0);
                        CashDocumentHeaderCZP.Get("Cash Desk No.", "Cash Document No.");
                    end;

                TempCashDocumentLineCZP := Rec;
                Init();
                "Document Type" := CashDocumentHeaderCZP."Document Type";
                "External Document No." := TempCashDocumentLineCZP."External Document No.";
                "Cash Desk Event" := TempCashDocumentLineCZP."Cash Desk Event";
                "Account Type" := TempCashDocumentLineCZP."Account Type";
                "Account No." := TempCashDocumentLineCZP."Account No.";
                "Gen. Document Type" := TempCashDocumentLineCZP."Gen. Document Type";
                if "Account No." = '' then
                    exit;

                "Currency Code" := CashDocumentHeaderCZP."Currency Code";
                "Responsibility Center" := CashDocumentHeaderCZP."Responsibility Center";
                if "External Document No." = '' then
                    "External Document No." := CashDocumentHeaderCZP."External Document No.";
                "Reason Code" := CashDocumentHeaderCZP."Reason Code";

                case "Account Type" of
                    "Account Type"::" ":
                        begin
                            StandardText.Get("Account No.");
                            Description := StandardText.Description;
                        end;
                    "Account Type"::"G/L Account":
                        begin
                            GLAccount.Get("Account No.");
                            GLAccount.CheckGLAcc();
                            Description := GLAccount.Name;
                            if not "System-Created Entry" then
                                GLAccount.TestField("Direct Posting", true);
                            if (GLAccount."VAT Bus. Posting Group" <> '') or
                               (GLAccount."VAT Prod. Posting Group" <> '')
                            then
                                GLAccount.TestField("Gen. Posting Type");
                            Description := GLAccount.Name;
                            "Gen. Posting Type" := GLAccount."Gen. Posting Type";
                            "VAT Bus. Posting Group" := GLAccount."VAT Bus. Posting Group";
                            "VAT Prod. Posting Group" := GLAccount."VAT Prod. Posting Group";
                        end;
                    "Account Type"::Customer:
                        begin
                            Customer.Get("Account No.");
                            Description := Customer.Name;
                            "Posting Group" := Customer."Customer Posting Group";
                            "Gen. Posting Type" := "Gen. Posting Type"::" ";
                            "VAT Bus. Posting Group" := '';
                            "VAT Prod. Posting Group" := '';
                        end;
                    "Account Type"::Vendor:
                        begin
                            Vendor.Get("Account No.");
                            Description := Vendor.Name;
                            "Posting Group" := Vendor."Vendor Posting Group";
                            "Gen. Posting Type" := "Gen. Posting Type"::" ";
                            "VAT Bus. Posting Group" := '';
                            "VAT Prod. Posting Group" := '';
                        end;
                    "Account Type"::"Bank Account":
                        begin
                            CashDeskCZP.Get("Account No.");
                            CashDeskCZP.TestField(Blocked, false);
                            Description := CashDeskCZP.Name;
                            "Gen. Posting Type" := "Gen. Posting Type"::" ";
                            "VAT Bus. Posting Group" := '';
                            "VAT Prod. Posting Group" := '';
                        end;
                    "Account Type"::"Fixed Asset":
                        begin
                            FixedAsset.Get("Account No.");
                            FixedAsset.TestField(Blocked, false);
                            FixedAsset.TestField(Inactive, false);
                            FixedAsset.TestField("Budgeted Asset", false);
                            GetFAPostingGroup();
                            Description := FixedAsset.Description;
                        end;
                    "Account Type"::Employee:
                        begin
                            CashDocumentHeaderCZP.TestField("Currency Code", '');
                            Employee.Get("Account No.");
                            Description := CopyStr(Employee.FullName(), 1, MaxStrLen(Description));
                        end;
                end;

                if not ("Account Type" in ["Account Type"::" ", "Account Type"::"Fixed Asset"]) then
                    Validate("VAT Prod. Posting Group");

                CreateDim(
                  TypeToTableID("Account Type".AsInteger()), "Account No.",
                  Database::"Salesperson/Purchaser", "Salespers./Purch. Code",
                  Database::"Responsibility Center", "Responsibility Center",
                  Database::"Cash Desk Event CZP", "Cash Desk Event");
            end;
        }
        field(7; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(8; "Posting Group"; Code[20])
        {
            Caption = 'Posting Group';
            TableRelation = if ("Account Type" = const("Fixed Asset")) "FA Posting Group" else
            if ("Account Type" = const("Bank Account")) "Bank Account Posting Group" else
            if ("Account Type" = const(Customer)) "Customer Posting Group" else
            if ("Account Type" = const(Vendor)) "Vendor Posting Group";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PostingGroupManagement: Codeunit "Posting Group Management";
            begin
                if CurrFieldNo = FieldNo("Posting Group") then
                    PostingGroupManagement.CheckPostingGroupChange("Posting Group", xRec."Posting Group", Rec);
            end;
        }
        field(14; "Applies-To Doc. Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Applies-To Doc. Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Applies-To Doc. Type" <> xRec."Applies-To Doc. Type" then
                    Validate("Applies-To Doc. No.", '');
            end;
        }
        field(15; "Applies-To Doc. No."; Code[20])
        {
            Caption = 'Applies-To Doc. No.';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                GenJournalLine: Record "Gen. Journal Line";
                CashDocumentPostCZP: Codeunit "Cash Document-Post CZP";
                PaymentToleranceMgt: Codeunit "Payment Tolerance Management";
                AccountNo: Code[20];
                AccountType: Enum "Gen. Journal Account Type";
                PreviousAmount: Decimal;
            begin
                GetCashDocumentHeaderCZP();
                CashDocumentPostCZP.InitGenJnlLine(CashDocumentHeaderCZP, Rec);
                CashDocumentPostCZP.GetGenJnlLine(GenJournalLine);
                PreviousAmount := GenJournalLine.Amount;

                if GenJournalLine."Bal. Account Type" in [GenJournalLine."Bal. Account Type"::Customer,
                                                      GenJournalLine."Bal. Account Type"::Vendor,
                                                      GenJournalLine."Bal. Account Type"::Employee]
                then begin
                    AccountNo := GenJournalLine."Bal. Account No.";
                    AccountType := GenJournalLine."Bal. Account Type";
                end else begin
                    AccountNo := GenJournalLine."Account No.";
                    AccountType := GenJournalLine."Account Type";
                end;

                if (AccountType.AsInteger() <> GenJournalLine."Account Type"::Customer.AsInteger()) and
                   (AccountType.AsInteger() <> GenJournalLine."Account Type"::Vendor.AsInteger()) and
                   (AccountType.AsInteger() <> GenJournalLine."Account Type"::Employee.AsInteger())
                then begin
                    AccountType := GenJournalLine."Bal. Account Type";
                    AccountNo := GenJournalLine."Bal. Account No.";
                end;
                case AccountType of
                    AccountType::Customer:
                        LookupApplyCustEntry(GenJournalLine, AccountNo);
                    AccountType::Vendor:
                        LookupApplyVendEntry(GenJournalLine, AccountNo);
                    AccountType::Employee:
                        LookupApplyEmplEntry(GenJournalLine, AccountNo);
                end;
                if GenJournalLine."Applies-to Doc. No." = '' then
                    exit;

                if AccountNo = '' then
                    Validate("Account No.", GenJournalLine."Account No.");
                "Applies-To Doc. Type" := GenJournalLine."Applies-to Doc. Type";
                "Applies-To Doc. No." := GenJournalLine."Applies-to Doc. No.";
                "Applies-to ID" := GenJournalLine."Applies-to ID";
                Validate(Amount, SignAmount() * GenJournalLine.Amount);
                if PreviousAmount <> 0 then
                    if not PaymentToleranceMgt.PmtTolGenJnl(GenJournalLine) then
                        exit;
            end;

            trigger OnValidate()
            var
                GenJournalLine: Record "Gen. Journal Line";
                GenJournalBatch: Record "Gen. Journal Batch";
                CustLedgEntry: Record "Cust. Ledger Entry";
                VendorLedgEntry: Record "Vendor Ledger Entry";
                EmployeeLedgEntry: Record "Employee Ledger Entry";
                CashDocumentPostCZP: Codeunit "Cash Document-Post CZP";
            begin
                GetCashDocumentHeaderCZP();
                CashDocumentPostCZP.InitGenJnlLine(CashDocumentHeaderCZP, Rec);
                CashDocumentPostCZP.GetGenJnlLine(GenJournalLine);
                GenJournalLine.SetSuppressCommit(true);
                GenJournalBatch.Insert(); // only for "Applies-to Doc. No." validation
                GenJournalLine.Validate("Applies-to Doc. No.");
                GenJournalBatch.Delete();

                if ("Applies-To Doc. No." = '') and (xRec."Applies-To Doc. No." <> '') then begin
                    PaymentToleranceMgt.DelPmtTolApllnDocNo(GenJournalLine, xRec."Applies-To Doc. No.");

                    case "Account Type" of
                        "Account Type"::Customer:
                            begin
                                CustLedgEntry.SetCurrentKey("Document No.");
                                CustLedgEntry.SetRange("Document No.", xRec."Applies-To Doc. No.");
                                if not (xRec."Applies-To Doc. Type" = "Gen. Document Type"::" ") then
                                    CustLedgEntry.SetRange("Document Type", xRec."Applies-To Doc. Type");
                                CustLedgEntry.SetRange("Customer No.", "Account No.");
                                CustLedgEntry.SetRange(Open, true);
                                if CustLedgEntry.FindFirst() then
                                    if CustLedgEntry."Amount to Apply" <> 0 then begin
                                        CustLedgEntry."Amount to Apply" := 0;
                                        Codeunit.Run(Codeunit::"Cust. Entry-Edit", CustLedgEntry);
                                    end;
                            end;
                        "Account Type"::Vendor:
                            begin
                                VendorLedgEntry.SetCurrentKey("Document No.");
                                VendorLedgEntry.SetRange("Document No.", xRec."Applies-To Doc. No.");
                                if not (xRec."Applies-To Doc. Type" = "Gen. Document Type"::" ") then
                                    VendorLedgEntry.SetRange("Document Type", xRec."Applies-To Doc. Type");
                                VendorLedgEntry.SetRange("Vendor No.", "Account No.");
                                VendorLedgEntry.SetRange(Open, true);
                                if VendorLedgEntry.FindFirst() then
                                    if VendorLedgEntry."Amount to Apply" <> 0 then begin
                                        VendorLedgEntry."Amount to Apply" := 0;
                                        Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendorLedgEntry);
                                    end;
                            end;
                        "Account Type"::Employee:
                            begin
                                EmployeeLedgEntry.SetCurrentKey("Document No.");
                                EmployeeLedgEntry.SetRange("Document No.", xRec."Applies-To Doc. No.");
                                if not (xRec."Applies-To Doc. Type" = "Gen. Document Type"::" ") then
                                    EmployeeLedgEntry.SetRange("Document Type", xRec."Applies-To Doc. Type");
                                EmployeeLedgEntry.SetRange("Employee No.", "Account No.");
                                EmployeeLedgEntry.SetRange(Open, true);
                                if EmployeeLedgEntry.FindFirst() then
                                    if EmployeeLedgEntry."Amount to Apply" <> 0 then begin
                                        EmployeeLedgEntry."Amount to Apply" := 0;
                                        Codeunit.Run(Codeunit::"Empl. Entry-Edit", EmployeeLedgEntry);
                                    end;
                            end;
                    end;
                end;

                if (Amount = 0) and ("Applies-To Doc. No." <> '') then begin
                    TestField("Currency Code", GenJournalLine."Currency Code");
                    Validate("Account No.", GenJournalLine."Account No.");

                    case "Account Type" of
                        "Account Type"::Customer:
                            begin
                                GenJournalLine.GetAppliedCustLedgerEntry(CustLedgEntry);
                                CustLedgEntry.CalcFields("Remaining Amount");
                                GenJournalLine.Validate(Amount, GetAmtToApplyCust(CustLedgEntry, GenJournalLine));
                            end;
                        "Account Type"::Vendor:
                            begin
                                GenJournalLine.GetAppliedVendLedgerEntry(VendorLedgEntry);
                                VendorLedgEntry.CalcFields("Remaining Amount");
                                GenJournalLine.Validate(Amount, GetAmtToApplyVend(VendorLedgEntry, GenJournalLine));
                            end;
                        "Account Type"::Employee:
                            begin
                                GenJournalLine.GetAppliedEmplLedgerEntry(EmployeeLedgEntry);
                                EmployeeLedgEntry.CalcFields("Remaining Amount");
                                GenJournalLine.Validate(Amount, GetAmtToApplyEmpl(EmployeeLedgEntry));
                            end;
                    end;
                    Validate(Amount, SignAmount() * GenJournalLine.Amount);
                    "Applies-To Doc. Type" := GenJournalLine."Applies-to Doc. Type";
                    "Applies-To Doc. No." := GenJournalLine."Applies-to Doc. No.";
                    "Applies-to ID" := GenJournalLine."Applies-to ID";
                end;

                if ("Applies-To Doc. No." <> xRec."Applies-To Doc. No.") and (Amount <> 0) then begin
                    if xRec."Applies-To Doc. No." <> '' then
                        PaymentToleranceMgt.DelPmtTolApllnDocNo(GenJournalLine, xRec."Applies-To Doc. No.");
                    PaymentToleranceMgt.PmtTolGenJnl(GenJournalLine);
                end;
            end;
        }
        field(16; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(17; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
        }
        field(20; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
#if not CLEAN18
                if Amount <> xRec.Amount then
                    TestField("Advance Letter Link Code", '');
#endif
                TestField("Account Type");
                TestField("Account No.");
                UpdateAmounts();
            end;
        }
        field(21; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                CurrExchRate: Record "Currency Exchange Rate";
            begin
                GetCashDocumentHeaderCZP();
                if CashDocumentHeaderCZP."Currency Code" = '' then
                    Validate(Amount, "Amount (LCY)")
                else
                    Validate(Amount, Round(CurrExchRate.ExchangeAmtLCYToFCY(CashDocumentHeaderCZP."Posting Date", CashDocumentHeaderCZP."Currency Code",
                          "Amount (LCY)", CashDocumentHeaderCZP."Currency Factor"), Currency."Amount Rounding Precision"));
            end;
        }
        field(24; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(25; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(26; "Document Type"; Enum "Cash Document Type CZP")
        {
            Caption = 'Cash Document Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(28; "Applies-to ID"; Code[50])
        {
            Caption = 'Applies-to ID';
            DataClassification = CustomerContent;
        }
        field(36; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(40; "Cash Desk Event"; Code[10])
        {
            Caption = 'Cash Desk Event';
            TableRelation = "Cash Desk Event CZP";
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                CashDeskEventCZP: Record "Cash Desk Event CZP";
            begin
                GetCashDocumentHeaderCZP();
                CashDeskEventCZP.FilterGroup(2);
                CashDeskEventCZP.SetFilter("Document Type", '%1|%2', CashDocumentHeaderCZP."Document Type"::" ", CashDocumentHeaderCZP."Document Type");
                CashDeskEventCZP.SetFilter("Cash Desk No.", '%1|%2', '', CashDocumentHeaderCZP."Cash Desk No.");
                CashDeskEventCZP.FilterGroup(0);
                CashDeskEventCZP.Code := "Cash Desk Event";
                if Page.RunModal(0, CashDeskEventCZP) = Action::LookupOK then
                    Validate("Cash Desk Event", CashDeskEventCZP.Code);
            end;

            trigger OnValidate()
            begin
                if "Cash Desk Event" <> xRec."Cash Desk Event" then
                    if "Cash Desk Event" <> '' then begin
                        CashDeskCZP.Get("Cash Desk No.");
                        GetCashDeskEventCZP();
                        GetCashDocumentHeaderCZP();
                        case CashDocumentHeaderCZP."Document Type" of
                            CashDocumentHeaderCZP."Document Type"::Receipt:
                                CashDeskEventCZP.TestField("Document Type", CashDeskEventCZP."Document Type"::Receipt);
                            CashDocumentHeaderCZP."Document Type"::Withdrawal:
                                CashDeskEventCZP.TestField("Document Type", CashDeskEventCZP."Document Type"::Withdrawal);
                        end;
                        TempCashDocumentLineCZP := Rec;
                        Init();
                        "External Document No." := TempCashDocumentLineCZP."External Document No.";
                        "Cash Desk Event" := TempCashDocumentLineCZP."Cash Desk Event";
                        Validate("Account Type", CashDeskEventCZP."Account Type");
                        Validate("System-Created Entry", true);
                        if CashDeskEventCZP."Account No." <> '' then
                            Validate("Account No.", CashDeskEventCZP."Account No.");
                        Validate(Description, CashDeskEventCZP.Description);
                        Validate("Gen. Posting Type", CashDeskEventCZP."Gen. Posting Type");
                        if CashDeskEventCZP."VAT Bus. Posting Group" <> '' then
                            Validate("VAT Bus. Posting Group", CashDeskEventCZP."VAT Bus. Posting Group");
                        if CashDeskEventCZP."VAT Prod. Posting Group" <> '' then
                            Validate("VAT Prod. Posting Group", CashDeskEventCZP."VAT Prod. Posting Group");
                        if CashDeskEventCZP."Global Dimension 1 Code" <> '' then
                            Validate("Shortcut Dimension 1 Code", CashDeskEventCZP."Global Dimension 1 Code");
                        if CashDeskEventCZP."Global Dimension 2 Code" <> '' then
                            Validate("Shortcut Dimension 2 Code", CashDeskEventCZP."Global Dimension 2 Code");
                        Validate("Gen. Document Type", CashDeskEventCZP."Gen. Document Type".AsInteger());
                        "Currency Code" := CashDocumentHeaderCZP."Currency Code";
                        Validate("Salespers./Purch. Code", CashDocumentHeaderCZP."Salespers./Purch. Code");
                        CreateDim(
                          TypeToTableID("Account Type".AsInteger()), "Account No.",
                          Database::"Salesperson/Purchaser", "Salespers./Purch. Code",
                          Database::"Responsibility Center", "Responsibility Center",
                          Database::"Cash Desk Event CZP", "Cash Desk Event");
                    end;
            end;
        }
        field(42; "Salespers./Purch. Code"; Code[20])
        {
            Caption = 'Salespers./Purch. Code';
            TableRelation = "Salesperson/Purchaser";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CreateDim(
                  TypeToTableID("Account Type".AsInteger()), "Account No.",
                  Database::"Salesperson/Purchaser", "Salespers./Purch. Code",
                  Database::"Responsibility Center", "Responsibility Center",
                  Database::"Cash Desk Event CZP", "Cash Desk Event");
            end;
        }
        field(43; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
            DataClassification = CustomerContent;
        }
        field(51; "VAT Base Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Base Amount';
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                GetCashDocumentHeaderCZP();
                "VAT Base Amount" := Round("VAT Base Amount", Currency."Amount Rounding Precision");

                case "VAT Calculation Type" of
                    "VAT Calculation Type"::"Normal VAT",
                  "VAT Calculation Type"::"Reverse Charge VAT":
                        "VAT Amount" :=
                          Round("VAT Base Amount" * ("VAT %" / 100),
                            Currency."Amount Rounding Precision", Currency.VATRoundingDirection());
                    "VAT Calculation Type"::"Full VAT":
                        if "VAT Base Amount" <> 0 then
                            FieldError("VAT Base Amount", StrSubstNo(MustBeZeroErr, FieldCaption("VAT Calculation Type"),
                                "VAT Calculation Type"));
                end;

                if CashDocumentHeaderCZP."Currency Code" = '' then begin
                    "VAT Base Amount (LCY)" := "VAT Base Amount";
                    "VAT Amount (LCY)" := "VAT Amount";
                end else begin
                    "VAT Base Amount (LCY)" := Round("VAT Base Amount" / CashDocumentHeaderCZP."Currency Factor");
                    "VAT Amount (LCY)" := Round("VAT Amount" / CashDocumentHeaderCZP."Currency Factor");
                end;

                "Amount Including VAT" := "VAT Base Amount" + "VAT Amount";
                "Amount Including VAT (LCY)" := "VAT Base Amount (LCY)" + "VAT Amount (LCY)";
                "VAT Difference" := 0;
                "VAT Difference (LCY)" := 0;
            end;
        }
        field(52; "Amount Including VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                GetCashDocumentHeaderCZP();
                "Amount Including VAT" := Round("Amount Including VAT", Currency."Amount Rounding Precision");

                case "VAT Calculation Type" of
                    "VAT Calculation Type"::"Normal VAT",
                  "VAT Calculation Type"::"Reverse Charge VAT":
                        "VAT Amount" := Round("Amount Including VAT" * "VAT %" / (100 + "VAT %"), Currency."Amount Rounding Precision");
                    "VAT Calculation Type"::"Full VAT":
                        "VAT Base Amount" := 0;
                end;

                if CashDocumentHeaderCZP."Currency Code" = '' then begin
                    "Amount Including VAT (LCY)" := "Amount Including VAT";
                    "VAT Amount (LCY)" := "VAT Amount";
                end else begin
                    "Amount Including VAT (LCY)" := Round("Amount Including VAT" / CashDocumentHeaderCZP."Currency Factor");
                    "VAT Amount (LCY)" := Round("VAT Amount" / CashDocumentHeaderCZP."Currency Factor");
                end;

                "VAT Base Amount" := "Amount Including VAT" - "VAT Amount";
                "VAT Base Amount (LCY)" := "Amount Including VAT (LCY)" - "VAT Amount (LCY)";
                "VAT Difference" := 0;
                "VAT Difference (LCY)" := 0;
            end;
        }
        field(53; "VAT Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                GeneralLedgerSetup.Get();
                GetCashDocumentHeaderCZP();
                CashDeskCZP.Get("Cash Desk No.");

                if CurrFieldNo = FieldNo("VAT Amount") then
                    CashDeskCZP.TestField("Allow VAT Difference");

                if not ("VAT Calculation Type" in
                        ["VAT Calculation Type"::"Normal VAT", "VAT Calculation Type"::"Reverse Charge VAT"])
                then
                    Error(
                      MustBeErr, FieldCaption("VAT Calculation Type"),
                      "VAT Calculation Type"::"Normal VAT", "VAT Calculation Type"::"Reverse Charge VAT");
                if "VAT Amount" <> 0 then begin
                    TestField("VAT %");
                    TestField("VAT Base Amount");
                end;

                "VAT Amount" := Round("VAT Amount", Currency."Amount Rounding Precision", Currency.VATRoundingDirection());
                if "VAT Amount" * "VAT Base Amount" < 0 then begin
                    if "VAT Amount" > 0 then
                        Error(MustBeNegativeErr, FieldCaption("VAT Amount"));
                    Error(MustBePositiveErr, FieldCaption("VAT Amount"));
                end;

                if CashDocumentHeaderCZP."Currency Code" = '' then begin
                    "VAT Amount (LCY)" := "VAT Amount";
                    if CashDocumentHeaderCZP."Amounts Including VAT" then
                        "Amount Including VAT (LCY)" := "Amount Including VAT"
                    else
                        "VAT Base Amount (LCY)" := "VAT Base Amount";
                end else begin
                    "VAT Amount (LCY)" := Round("VAT Amount" / CashDocumentHeaderCZP."Currency Factor");
                    if CashDocumentHeaderCZP."Amounts Including VAT" then
                        "Amount Including VAT (LCY)" := Round("Amount Including VAT" / CashDocumentHeaderCZP."Currency Factor")
                    else
                        "VAT Base Amount (LCY)" := Round("VAT Base Amount" / CashDocumentHeaderCZP."Currency Factor");
                end;

                if CashDocumentHeaderCZP."Amounts Including VAT" then begin
                    "VAT Base Amount" := "Amount Including VAT" - "VAT Amount";
                    "VAT Base Amount (LCY)" := "Amount Including VAT (LCY)" - "VAT Amount (LCY)";
                end else begin
                    "Amount Including VAT" := "VAT Base Amount" + "VAT Amount";
                    "Amount Including VAT (LCY)" := "VAT Base Amount (LCY)" + "VAT Amount (LCY)";
                end;

                "VAT Difference" := "VAT Amount" - CalcVATAmount();
                "VAT Difference (LCY)" := "VAT Amount (LCY)" - CalcVATAmountLCY();

                if CurrFieldNo = FieldNo("VAT Amount") then
                    if Abs("VAT Difference") > Currency."Max. VAT Difference Allowed" then
                        Error(MustNotBeMoreThanErr, FieldCaption("VAT Difference"), Currency."Max. VAT Difference Allowed");
            end;
        }
        field(55; "VAT Base Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Base Amount (LCY)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(56; "Amount Including VAT (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount Including VAT (LCY)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(57; "VAT Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Amount (LCY)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(59; "VAT Difference"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Difference';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(60; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DecimalPlaces = 0 : 5;
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(61; "VAT Identifier"; Code[20])
        {
            Caption = 'VAT Identifier';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(62; "VAT Difference (LCY)"; Decimal)
        {
            Caption = 'VAT Difference (LCY)';
            DataClassification = CustomerContent;
        }
        field(63; "System-Created Entry"; Boolean)
        {
            Caption = 'System-Created Entry';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(65; "Gen. Posting Type"; Enum "General Posting Type")
        {
            Caption = 'Gen. Posting Type';
            DataClassification = CustomerContent;
        }
        field(70; "VAT Calculation Type"; Enum "Tax Calculation Type")
        {
            Caption = 'VAT Calculation Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(71; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("VAT Prod. Posting Group");
            end;
        }
        field(72; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group") then begin
                    "VAT %" := VATPostingSetup."VAT %";
                    "VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
                    "VAT Identifier" := VATPostingSetup."VAT Identifier";
                    case "VAT Calculation Type" of
                        "VAT Calculation Type"::"Reverse Charge VAT",
                        "VAT Calculation Type"::"Sales Tax":
                            "VAT %" := 0;
                        "VAT Calculation Type"::"Full VAT":
                            begin
                                TestField("Account Type", "Account Type"::"G/L Account");
                                VATPostingSetup.TestField("Sales VAT Account");
                                TestField("Account No.", VATPostingSetup."Sales VAT Account");
                            end;
                    end;
                end else begin
                    "VAT %" := 0;
                    "VAT Calculation Type" := "VAT Calculation Type"::"Normal VAT";
                    "VAT Identifier" := '';
                end;
                Validate(Amount);
            end;
        }
        field(75; "Use Tax"; Boolean)
        {
            Caption = 'Use Tax';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Gen. Posting Type", "Gen. Posting Type"::Purchase);
            end;
        }
        field(90; "FA Posting Type"; Enum "Cash Document FA Post.Type CZP")
        {
            Caption = 'FA Posting Type';
            DataClassification = CustomerContent;
        }
        field(91; "Depreciation Book Code"; Code[10])
        {
            Caption = 'Depreciation Book Code';
            TableRelation = "Depreciation Book";
            DataClassification = CustomerContent;
        }
        field(92; "Maintenance Code"; Code[10])
        {
            Caption = 'Maintenance Code';
            TableRelation = Maintenance;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Maintenance Code" <> '' then
                    TestField("FA Posting Type", "FA Posting Type"::Maintenance);
            end;
        }
        field(93; "Duplicate in Depreciation Book"; Code[10])
        {
            Caption = 'Duplicate in Depreciation Book';
            TableRelation = "Depreciation Book";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Use Duplication List" := false;
            end;
        }
        field(94; "Use Duplication List"; Boolean)
        {
            Caption = 'Use Duplication List';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Duplicate in Depreciation Book" := '';
            end;
        }
        field(98; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            Editable = false;
            TableRelation = "Responsibility Center";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CreateDim(
                  TypeToTableID("Account Type".AsInteger()), "Account No.",
                  Database::"Salesperson/Purchaser", "Salespers./Purch. Code",
                  Database::"Responsibility Center", "Responsibility Center",
                  Database::"Cash Desk Event CZP", "Cash Desk Event");
            end;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                ShowDimensions();
            end;

            trigger OnValidate()
            begin
                DimensionManagement.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
        }
#if not CLEAN18
        field(31001; "Advance Letter Link Code"; Code[30])
        {
            Caption = 'Advance Letter Link Code';
            DataClassification = CustomerContent;
            Access = Internal;
            ObsoleteState = Pending;
            ObsoleteReason = 'Remove after Advance Payment Localization for Czech will be implemented.';
            ObsoleteTag = '18.0';
        }
#endif    
    }

    keys
    {
        key(Key1; "Cash Desk No.", "Cash Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Cash Desk No.", "Cash Document No.", "External Document No.", "VAT Identifier")
        {
            SumIndexFields = Amount, "Amount (LCY)", "Amount Including VAT", "Amount Including VAT (LCY)", "VAT Base Amount", "VAT Base Amount (LCY)", "VAT Amount", "VAT Amount (LCY)";
        }
    }

    trigger OnInsert()
    begin
        LockTable();
        InitRecord();
    end;

    trigger OnRename()
    begin
        Error(RenameErr, TableCaption);
    end;

#if not CLEAN18
    trigger OnDelete()
    var
        PrepaymentLinksManagement: Codeunit "Prepayment Links Management";
    begin
        if "Advance Letter Link Code" <> '' then
            case "Account Type" of
                "Account Type"::Customer:
                    PrepaymentLinksManagement.UnLinkWholeSalesLetter("Advance Letter Link Code");
                "Account Type"::Vendor:
                    PrepaymentLinksManagement.UnLinkWholePurchLetter("Advance Letter Link Code");
            end;
    end;

#endif
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        Currency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        CashDeskCZP: Record "Cash Desk CZP";
        CashDeskEventCZP: Record "Cash Desk Event CZP";
        TempCashDocumentLineCZP: Record "Cash Document Line CZP" temporary;
        FixedAsset: Record "Fixed Asset";
        PaymentToleranceMgt: Codeunit "Payment Tolerance Management";
        DimensionManagement: Codeunit DimensionManagement;
        ConfirmManagement: Codeunit "Confirm Management";
        RenameErr: Label 'You cannot rename a %1.', Comment = '%1 = TableCaption';
        LookupConfirmQst: Label 'The %1 in the %2 will be changed from %3 to %4.\Do you wish to continue?', Comment = '%1 = Currency Code FieldCaption, %2 = Gen. Jnl. Line TableCaption, %3 = Old Currency Code, %4 = New Currency Code';
        UpdateInteruptedErr: Label 'The update has been interrupted to respect the warning.';
        MustBeNegativeErr: Label '%1 must be negative.', Comment = '%1 = VAT Amount FieldCaption';
        MustBePositiveErr: Label '%1 must be positive.', Comment = '%1 = VAT Amount FieldCaption';
        MustBeErr: Label '%1 must be %2 or %3.', Comment = '%1 = VAT Calculation Type FiledCaption, %2 = "VAT Calculation Type"::"Normal VAT", %3 = "VAT Calculation Type"::"Reverse Charge VAT"';
        MustNotBeMoreThanErr: Label 'The %1 must not be more than %2.', Comment = '%1 = VAT Difference FieldCaption, %2 = Max. VAT Difference Allowed';
        MustBeZeroErr: Label ' must be 0 when %1 is %2.', Comment = ' %1 = "VAT Calculation Type FieldCaption, %2 = VAT Calculation Type';
        HideValidationDialog: Boolean;

    procedure InitRecord()
    begin
        GetCashDocumentHeaderCZP();
        "Cash Desk No." := CashDocumentHeaderCZP."Cash Desk No.";
        "Document Type" := CashDocumentHeaderCZP."Document Type";
    end;

    procedure ShowDimensions()
    var
        ThreePlacehodersTok: Label '%1 %2 %3', Locked = true;
    begin
        "Dimension Set ID" := DimensionManagement.EditDimensionSet("Dimension Set ID", StrSubstNo(ThreePlacehodersTok, TableCaption, "Cash Document No.", "Line No."));
        DimensionManagement.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    procedure CreateDim(Type1: Integer; No1: Code[20]; Type2: Integer; No2: Code[20]; Type3: Integer; No3: Code[20]; Type4: Integer; No4: Code[20])
    var
        SourceCodeSetup: Record "Source Code Setup";
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        SourceCodeSetup.Get();
        TableID[1] := Type1;
        No[1] := No1;
        TableID[2] := Type2;
        No[2] := No2;
        TableID[3] := Type3;
        No[3] := No3;
        TableID[4] := Type4;
        No[4] := No4;
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        GetCashDocumentHeaderCZP();
        "Dimension Set ID" :=
          DimensionManagement.GetRecDefaultDimID(
            Rec, CurrFieldNo, TableID, No, SourceCodeSetup."Cash Desk CZP",
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code",
            CashDocumentHeaderCZP."Dimension Set ID", Database::Customer);
        DimensionManagement.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimensionManagement.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimensionManagement.LookupDimValueCode(FieldNumber, ShortcutDimCode);
        ValidateShortcutDimCode(FieldNumber, ShortcutDimCode);
    end;

    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimensionManagement.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;

    procedure GetCashDocumentHeaderCZP()
    begin
        TestField("Cash Desk No.");
        TestField("Cash Document No.");
        if ("Cash Desk No." <> CashDocumentHeaderCZP."Cash Desk No.") or ("Cash Document No." <> CashDocumentHeaderCZP."No.") then begin
            CashDocumentHeaderCZP.Get("Cash Desk No.", "Cash Document No.");
            if CashDocumentHeaderCZP."Currency Code" = '' then
                Currency.InitRoundingPrecision()
            else begin
                CashDocumentHeaderCZP.TestField("Currency Factor");
                Currency.Get(CashDocumentHeaderCZP."Currency Code");
                Currency.TestField("Amount Rounding Precision");
            end;
        end;

        CashDocumentHeaderCZP.SetHideValidationDialog(HideValidationDialog);
    end;

    procedure UpdateAmounts()
    var
        CurrExchRate: Record "Currency Exchange Rate";
        GenJournalLine: Record "Gen. Journal Line";
        CashDocumentPostCZP: Codeunit "Cash Document-Post CZP";
    begin
        GetCashDocumentHeaderCZP();

        if CashDocumentHeaderCZP."Currency Code" <> '' then
            "Amount (LCY)" := Round(CurrExchRate.ExchangeAmtFCYToLCY(CashDocumentHeaderCZP."Posting Date", CashDocumentHeaderCZP."Currency Code",
                  Amount, CashDocumentHeaderCZP."Currency Factor"))
        else
            "Amount (LCY)" := Round(Amount);

        if CashDocumentHeaderCZP."Amounts Including VAT" then
            Validate("Amount Including VAT", Amount)
        else
            Validate("VAT Base Amount", Amount);

        if (Amount <> xRec.Amount) and (xRec.Amount <> 0) or (xRec."Applies-To Doc. No." <> '') or (xRec."Applies-to ID" <> '') then begin
            CashDocumentPostCZP.InitGenJnlLine(CashDocumentHeaderCZP, Rec);
            CashDocumentPostCZP.GetGenJnlLine(GenJournalLine);
            PaymentToleranceMgt.PmtTolGenJnl(GenJournalLine);
        end;
    end;

    procedure UpdateDocumentType()
    begin
        "Gen. Document Type" := "Gen. Document Type"::" ";
        if not ("Account Type" in ["Account Type"::Customer, "Account Type"::Vendor]) then
            exit;
        if (("Document Type" = "Document Type"::Receipt) and ("Account Type" = "Account Type"::Customer)) or
           (("Document Type" = "Document Type"::Withdrawal) and ("Account Type" = "Account Type"::Vendor))
        then
            "Gen. Document Type" := "Gen. Document Type"::Payment;
        if (("Document Type" = "Document Type"::Withdrawal) and ("Account Type" = "Account Type"::Customer)) or
           (("Document Type" = "Document Type"::Receipt) and ("Account Type" = "Account Type"::Vendor))
        then
            "Gen. Document Type" := "Gen. Document Type"::Refund;
    end;

    procedure SignAmount(): Integer
    begin
        if "Document Type" = "Document Type"::Receipt then
            exit(-1);
        exit(1);
    end;

    procedure ApplyEntries()
    var
        GenJnlLine: Record "Gen. Journal Line";
        CashDocumentPostCZP: Codeunit "Cash Document-Post CZP";
    begin
        CashDocumentHeaderCZP.Get("Cash Desk No.", "Cash Document No.");
        CashDocumentPostCZP.InitGenJnlLine(CashDocumentHeaderCZP, Rec);
        CashDocumentPostCZP.GetGenJnlLine(GenJnlLine);
        Codeunit.Run(Codeunit::"Gen. Jnl.-Apply", GenJnlLine);
        "Applies-to ID" := GenJnlLine."Applies-to ID";
        if Amount = 0 then
            if CashDocumentHeaderCZP."Amounts Including VAT" then
                Validate(Amount, SignAmount() * GenJnlLine.Amount)
            else
                Validate(Amount, SignAmount() * GenJnlLine.Amount * (1 - "VAT %" / (100 + "VAT %")));
        Modify();
    end;

    local procedure GetAmtToApplyCust(CustLedgEntry: Record "Cust. Ledger Entry"; GenJnlLine: Record "Gen. Journal Line"): Decimal
    begin
        if PaymentToleranceMgt.CheckCalcPmtDiscGenJnlCust(GenJnlLine, CustLedgEntry, 0, false) then
            if (CustLedgEntry."Amount to Apply" = 0) or
               (Abs(CustLedgEntry."Amount to Apply") >= Abs(CustLedgEntry."Remaining Amount" - CustLedgEntry."Remaining Pmt. Disc. Possible"))
            then
                exit(-CustLedgEntry."Remaining Amount" + CustLedgEntry."Remaining Pmt. Disc. Possible");
        if CustLedgEntry."Amount to Apply" = 0 then
            exit(-CustLedgEntry."Remaining Amount");
        exit(-CustLedgEntry."Amount to Apply");
    end;

    local procedure GetAmtToApplyVend(VendLedgEntry: Record "Vendor Ledger Entry"; GenJnlLine: Record "Gen. Journal Line"): Decimal
    begin
        if PaymentToleranceMgt.CheckCalcPmtDiscGenJnlVend(GenJnlLine, VendLedgEntry, 0, false) then
            if (VendLedgEntry."Amount to Apply" = 0) or
               (Abs(VendLedgEntry."Amount to Apply") >= Abs(VendLedgEntry."Remaining Amount" - VendLedgEntry."Remaining Pmt. Disc. Possible"))
            then
                exit(-VendLedgEntry."Remaining Amount" + VendLedgEntry."Remaining Pmt. Disc. Possible");
        if VendLedgEntry."Amount to Apply" = 0 then
            exit(-VendLedgEntry."Remaining Amount");
        exit(-VendLedgEntry."Amount to Apply");
    end;

    local procedure GetAmtToApplyEmpl(EmplLedgEntry: Record "Employee Ledger Entry"): Decimal
    begin
        if EmplLedgEntry."Amount to Apply" = 0 then
            exit(-EmplLedgEntry."Remaining Amount");
        exit(-EmplLedgEntry."Amount to Apply");
    end;

    local procedure SetAppliesToFiltersCust(var CustLedgEntry: Record "Cust. Ledger Entry"; GenJnlLine: Record "Gen. Journal Line"; AccNo: Code[20])
    begin
        CustLedgEntry.SetCurrentKey("Customer No.", Open, Positive, "Due Date");
        if AccNo <> '' then
            CustLedgEntry.SetRange("Customer No.", AccNo);
        CustLedgEntry.SetRange(Open, true);
        CustLedgEntry.SetRange("Currency Code", GenJnlLine."Currency Code");
        if GenJnlLine."Applies-to Doc. No." <> '' then begin
            CustLedgEntry.SetRange("Document Type", GenJnlLine."Applies-to Doc. Type");
            CustLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
            if not CustLedgEntry.FindFirst() then begin
                CustLedgEntry.SetRange("Document Type");
                CustLedgEntry.SetRange("Document No.");
            end;
        end;
        if GenJnlLine."Applies-to ID" <> '' then begin
            CustLedgEntry.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
            if not CustLedgEntry.FindFirst() then
                CustLedgEntry.SetRange("Applies-to ID");
        end;
        if GenJnlLine."Applies-to Doc. Type" <> GenJnlLine."Applies-to Doc. Type"::" " then begin
            CustLedgEntry.SetRange("Document Type", GenJnlLine."Applies-to Doc. Type");
            if not CustLedgEntry.FindFirst() then
                CustLedgEntry.SetRange("Document Type");
        end;
        if GenJnlLine."Applies-to Doc. No." <> '' then begin
            CustLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
            if not CustLedgEntry.FindFirst() then
                CustLedgEntry.SetRange("Document No.");
        end;
        if GenJnlLine.Amount <> 0 then begin
            CustLedgEntry.SetRange(Positive, GenJnlLine.Amount < 0);
            if CustLedgEntry.FindFirst() then;
            CustLedgEntry.SetRange(Positive);
        end;
    end;

    local procedure SetAppliesToFiltersVend(var VendLedgEntry: Record "Vendor Ledger Entry"; GenJnlLine: Record "Gen. Journal Line"; AccNo: Code[20])
    begin
        VendLedgEntry.SetCurrentKey("Vendor No.", Open, Positive, "Due Date");
        if AccNo <> '' then
            VendLedgEntry.SetRange("Vendor No.", AccNo);
        VendLedgEntry.SetRange(Open, true);
        VendLedgEntry.SetRange("Currency Code", GenJnlLine."Currency Code");
        if GenJnlLine."Applies-to Doc. No." <> '' then begin
            VendLedgEntry.SetRange("Document Type", GenJnlLine."Applies-to Doc. Type");
            VendLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
            if not VendLedgEntry.FindFirst() then begin
                VendLedgEntry.SetRange("Document Type");
                VendLedgEntry.SetRange("Document No.");
            end;
        end;
        if GenJnlLine."Applies-to ID" <> '' then begin
            VendLedgEntry.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
            if not VendLedgEntry.FindFirst() then
                VendLedgEntry.SetRange("Applies-to ID");
        end;
        if GenJnlLine."Applies-to Doc. Type" <> GenJnlLine."Applies-to Doc. Type"::" " then begin
            VendLedgEntry.SetRange("Document Type", GenJnlLine."Applies-to Doc. Type");
            if not VendLedgEntry.FindFirst() then
                VendLedgEntry.SetRange("Document Type");
        end;
        if GenJnlLine."Applies-to Doc. No." <> '' then begin
            VendLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
            if not VendLedgEntry.FindFirst() then
                VendLedgEntry.SetRange("Document No.");
        end;
        if GenJnlLine.Amount <> 0 then begin
            VendLedgEntry.SetRange(Positive, GenJnlLine.Amount < 0);
            if VendLedgEntry.FindFirst() then;
            VendLedgEntry.SetRange(Positive);
        end;
    end;

    local procedure SetAppliesToFiltersEmpl(var EmplLedgEntry: Record "Employee Ledger Entry"; GenJnlLine: Record "Gen. Journal Line"; AccNo: Code[20])
    begin
        EmplLedgEntry.SetCurrentKey("Employee No.", "Applies-to ID", Open, Positive);
        if AccNo <> '' then
            EmplLedgEntry.SetRange("Employee No.", AccNo);
        EmplLedgEntry.SetRange(Open, true);
        EmplLedgEntry.SetRange("Currency Code", GenJnlLine."Currency Code");
        if GenJnlLine."Applies-to Doc. No." <> '' then begin
            EmplLedgEntry.SetRange("Document Type", GenJnlLine."Applies-to Doc. Type");
            EmplLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
            if not EmplLedgEntry.FindFirst() then begin
                EmplLedgEntry.SetRange("Document Type");
                EmplLedgEntry.SetRange("Document No.");
            end;
        end;
        if GenJnlLine."Applies-to ID" <> '' then begin
            EmplLedgEntry.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
            if not EmplLedgEntry.FindFirst() then
                EmplLedgEntry.SetRange("Applies-to ID");
        end;
        if GenJnlLine."Applies-to Doc. Type" <> GenJnlLine."Applies-to Doc. Type"::" " then begin
            EmplLedgEntry.SetRange("Document Type", GenJnlLine."Applies-to Doc. Type");
            if not EmplLedgEntry.FindFirst() then
                EmplLedgEntry.SetRange("Document Type");
        end;
        if GenJnlLine."Applies-to Doc. No." <> '' then begin
            EmplLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
            if not EmplLedgEntry.FindFirst() then
                EmplLedgEntry.SetRange("Document No.");
        end;
        if GenJnlLine.Amount <> 0 then begin
            EmplLedgEntry.SetRange(Positive, GenJnlLine.Amount < 0);
            if EmplLedgEntry.FindFirst() then;
            EmplLedgEntry.SetRange(Positive);
        end;
    end;

    local procedure LookupApplyCustEntry(var GenJnlLine: Record "Gen. Journal Line"; AccNo: Code[20])
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        GenJnlApply: Codeunit "Gen. Jnl.-Apply";
        ApplyCustEntries: Page "Apply Customer Entries";
    begin
        Clear(CustLedgEntry);
        SetAppliesToFiltersCust(CustLedgEntry, GenJnlLine, AccNo);
        ApplyCustEntries.SetGenJnlLine(GenJnlLine, GenJnlLine.FieldNo("Applies-to Doc. No."));
        ApplyCustEntries.SetTableView(CustLedgEntry);
        ApplyCustEntries.SetRecord(CustLedgEntry);
        ApplyCustEntries.LookupMode(true);
        if ApplyCustEntries.RunModal() = Action::LookupOK then begin
            ApplyCustEntries.GetRecord(CustLedgEntry);
            if GenJnlLine."Currency Code" <> CustLedgEntry."Currency Code" then
                if GenJnlLine.Amount = 0 then begin
                    if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(LookupConfirmQst,
                                                                    GenJnlLine.FieldCaption("Currency Code"), GenJnlLine.TableCaption,
                                                                    GenJnlLine.GetShowCurrencyCode(GenJnlLine."Currency Code"),
                                                                    GenJnlLine.GetShowCurrencyCode(CustLedgEntry."Currency Code")), true)
                    then
                        Error(UpdateInteruptedErr);
                    GenJnlLine.Validate("Currency Code", CustLedgEntry."Currency Code");
                end else
                    GenJnlApply.CheckAgainstApplnCurrency(
                      GenJnlLine."Currency Code", CustLedgEntry."Currency Code",
                      GenJnlLine."Account Type"::Customer, true);
            if Amount = 0 then begin
                CustLedgEntry.CalcFields("Remaining Amount");
                GenJnlLine.Validate(Amount, GetAmtToApplyCust(CustLedgEntry, GenJnlLine));
            end;
            if AccNo = '' then
                GenJnlLine.Validate("Account No.", CustLedgEntry."Customer No.");
            GenJnlLine."Applies-to Doc. Type" := CustLedgEntry."Document Type";
            GenJnlLine."Applies-to Doc. No." := CustLedgEntry."Document No.";
            GenJnlLine."Applies-to ID" := '';
        end;
        Clear(ApplyCustEntries);
    end;

    local procedure LookupApplyVendEntry(var GenJnlLine: Record "Gen. Journal Line"; AccNo: Code[20])
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
        GenJnlApply: Codeunit "Gen. Jnl.-Apply";
        ApplyVendEntries: Page "Apply Vendor Entries";
    begin
        Clear(VendLedgEntry);
        SetAppliesToFiltersVend(VendLedgEntry, GenJnlLine, AccNo);
        ApplyVendEntries.SetGenJnlLine(GenJnlLine, GenJnlLine.FieldNo("Applies-to Doc. No."));
        ApplyVendEntries.SetTableView(VendLedgEntry);
        ApplyVendEntries.SetRecord(VendLedgEntry);
        ApplyVendEntries.LookupMode(true);
        if ApplyVendEntries.RunModal() = Action::LookupOK then begin
            ApplyVendEntries.GetRecord(VendLedgEntry);
            if GenJnlLine."Currency Code" <> VendLedgEntry."Currency Code" then
                if GenJnlLine.Amount = 0 then begin
                    if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(LookupConfirmQst,
                                                                    GenJnlLine.FieldCaption("Currency Code"), GenJnlLine.TableCaption,
                                                                    GenJnlLine.GetShowCurrencyCode(GenJnlLine."Currency Code"),
                                                                    GenJnlLine.GetShowCurrencyCode(VendLedgEntry."Currency Code")), true)
                    then
                        Error(UpdateInteruptedErr);
                    GenJnlLine.Validate("Currency Code", VendLedgEntry."Currency Code");
                end else
                    GenJnlApply.CheckAgainstApplnCurrency(
                      GenJnlLine."Currency Code", VendLedgEntry."Currency Code",
                      GenJnlLine."Account Type"::Vendor, true);
            if Amount = 0 then begin
                VendLedgEntry.CalcFields("Remaining Amount");
                GenJnlLine.Validate(Amount, GetAmtToApplyVend(VendLedgEntry, GenJnlLine));
            end;
            if AccNo = '' then
                GenJnlLine.Validate("Account No.", VendLedgEntry."Vendor No.");
            GenJnlLine."Applies-to Doc. Type" := VendLedgEntry."Document Type";
            GenJnlLine."Applies-to Doc. No." := VendLedgEntry."Document No.";
            GenJnlLine."Applies-to ID" := '';
        end;
        Clear(ApplyVendEntries);
    end;

    local procedure LookupApplyEmplEntry(var GenJnlLine: Record "Gen. Journal Line"; AccNo: Code[20])
    var
        EmplLedgEntry: Record "Employee Ledger Entry";
        GenJnlApply: Codeunit "Gen. Jnl.-Apply";
        ApplyEmplEntries: Page "Apply Employee Entries";
    begin
        Clear(EmplLedgEntry);
        SetAppliesToFiltersEmpl(EmplLedgEntry, GenJnlLine, AccNo);
        ApplyEmplEntries.SetGenJnlLine(GenJnlLine, GenJnlLine.FieldNo("Applies-to Doc. No."));
        ApplyEmplEntries.SetTableView(EmplLedgEntry);
        ApplyEmplEntries.SetRecord(EmplLedgEntry);
        ApplyEmplEntries.LookupMode(true);
        if ApplyEmplEntries.RunModal() = Action::LookupOK then begin
            ApplyEmplEntries.GetRecord(EmplLedgEntry);
            if GenJnlLine."Currency Code" <> EmplLedgEntry."Currency Code" then
                if GenJnlLine.Amount = 0 then begin
                    if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(LookupConfirmQst,
                                                                    GenJnlLine.FieldCaption("Currency Code"), GenJnlLine.TableCaption,
                                                                    GenJnlLine.GetShowCurrencyCode(GenJnlLine."Currency Code"),
                                                                    GenJnlLine.GetShowCurrencyCode(EmplLedgEntry."Currency Code")), true)
                    then
                        Error(UpdateInteruptedErr);
                    GenJnlLine.Validate("Currency Code", EmplLedgEntry."Currency Code");
                end else
                    GenJnlApply.CheckAgainstApplnCurrency(
                      GenJnlLine."Currency Code", EmplLedgEntry."Currency Code",
                      GenJnlLine."Account Type"::Employee, true);
            if Amount = 0 then begin
                EmplLedgEntry.CalcFields("Remaining Amount");
                GenJnlLine.Validate(Amount, GetAmtToApplyEmpl(EmplLedgEntry));
            end;
            if AccNo = '' then
                GenJnlLine.Validate("Account No.", EmplLedgEntry."Employee No.");
            GenJnlLine."Applies-to Doc. Type" := EmplLedgEntry."Document Type";
            GenJnlLine."Applies-to Doc. No." := EmplLedgEntry."Document No.";
            GenJnlLine."Applies-to ID" := '';
        end;
        Clear(ApplyEmplEntries);
    end;

    procedure TypeToTableID(Type: Option " ","G/L Account",Customer,Vendor,"Bank Account","Fixed Asset",Employee): Integer
    begin
        case Type of
            Type::" ":
                exit(0);
            Type::"G/L Account":
                exit(Database::"G/L Account");
            Type::Customer:
                exit(Database::Customer);
            Type::Vendor:
                exit(Database::Vendor);
            Type::"Bank Account":
                exit(Database::"Bank Account");
            Type::"Fixed Asset":
                exit(Database::"Fixed Asset");
            Type::Employee:
                exit(Database::Employee);
        end;
    end;

    local procedure GetFAPostingGroup()
    var
        LocalGLAcc: Record "G/L Account";
        FAPostingGr: Record "FA Posting Group";
        FASetup: Record "FA Setup";
        FADeprBook: Record "FA Depreciation Book";
    begin
        if ("Account Type" <> "Account Type"::"Fixed Asset") or ("Account No." = '') then
            exit;
        if "Depreciation Book Code" = '' then begin
            FASetup.Get();
            FADeprBook.Reset();
            FADeprBook.SetRange("FA No.", "Account No.");
            FADeprBook.SetRange("Default FA Depreciation Book", true);
            if not FADeprBook.FindFirst() then begin
                "Depreciation Book Code" := FASetup."Default Depr. Book";
                if not FADeprBook.Get("Account No.", "Depreciation Book Code") then
                    "Depreciation Book Code" := '';
            end else
                "Depreciation Book Code" := FADeprBook."Depreciation Book Code";
            if "Depreciation Book Code" = '' then
                exit;
        end;
        if "FA Posting Type" = "FA Posting Type"::" " then
            "FA Posting Type" := "FA Posting Type"::"Acquisition Cost";
        FADeprBook.Get("Account No.", "Depreciation Book Code");
        FADeprBook.TestField("FA Posting Group");
        FAPostingGr.Get(FADeprBook."FA Posting Group");
        if "FA Posting Type" = "FA Posting Type"::"Custom 2" then begin
            FAPostingGr.TestField("Custom 2 Account");
            LocalGLAcc.Get(FAPostingGr."Custom 2 Account");
        end else
            if "FA Posting Type" = "FA Posting Type"::"Acquisition Cost" then begin
                FAPostingGr.TestField("Acquisition Cost Account");
                LocalGLAcc.Get(FAPostingGr."Acquisition Cost Account");
            end;
        LocalGLAcc.CheckGLAcc();
        LocalGLAcc.TestField("Gen. Prod. Posting Group");
        "Posting Group" := FADeprBook."FA Posting Group";
        Validate("Gen. Posting Type", LocalGLAcc."Gen. Posting Type");
        Validate("VAT Bus. Posting Group", LocalGLAcc."VAT Bus. Posting Group");
        Validate("VAT Prod. Posting Group", LocalGLAcc."VAT Prod. Posting Group");
    end;

    procedure ExtStatistics()
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        TestField("Cash Desk No.");
        TestField("Cash Document No.");

        GetCashDocumentHeaderCZP();
        if CashDocumentHeaderCZP.Status = CashDocumentHeaderCZP.Status::Open then begin
            CashDocumentHeaderCZP.VATRounding();
            Commit();
        end;

        CashDocumentLineCZP.SetRange("Cash Desk No.", "Cash Desk No.");
        CashDocumentLineCZP.SetRange("Cash Document No.", "Cash Document No.");
        CashDocumentLineCZP.SetRange("Line No.", "Line No.");
        Page.RunModal(Page::"Cash Document Statistics CZP", CashDocumentLineCZP);
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    local procedure CalcVATAmount(): Decimal
    begin
        GetCashDocumentHeaderCZP();
        if CashDocumentHeaderCZP."Amounts Including VAT" then
            exit(Round("Amount Including VAT" * "VAT %" / (100 + "VAT %"), Currency."Amount Rounding Precision", Currency.VATRoundingDirection()));
        exit(Round("VAT Base Amount" * "VAT %" / 100, Currency."Amount Rounding Precision", Currency.VATRoundingDirection()));
    end;

    local procedure CalcVATAmountLCY(): Decimal
    begin
        GetCashDocumentHeaderCZP();
        if CashDocumentHeaderCZP."Amounts Including VAT" then
            exit(Round("Amount Including VAT (LCY)" * "VAT %" / (100 + "VAT %"), Currency."Amount Rounding Precision", Currency.VATRoundingDirection()));
        exit(Round("VAT Base Amount (LCY)" * "VAT %" / 100, Currency."Amount Rounding Precision", Currency.VATRoundingDirection()));
    end;

    local procedure GetCashDeskEventCZP()
    begin
        if "Cash Desk Event" = '' then begin
            Clear(CashDeskEventCZP);
            exit;
        end;

        if "Cash Desk Event" <> CashDeskEventCZP.Code then
            CashDeskEventCZP.Get("Cash Desk Event");
    end;

#if not CLEAN18
    internal procedure LinkToAdvLetter()
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        TestField("Gen. Document Type", "Gen. Document Type"::Payment);
        if not ("Account Type" in ["Account Type"::Customer, "Account Type"::Vendor]) then
            FieldError("Account Type");

        GetCashDocumentHeaderCZP();
        GenJournalLine.Init();
        GenJournalLine."Line No." := "Line No.";
        GenJournalLine."Account No." := "Account No.";
        GenJournalLine."Document Type" := "Document Type";
        GenJournalLine."Document No." := "Cash Document No.";
        GenJournalLine."Currency Code" := CashDocumentHeaderCZP."Currency Code";
        GenJournalLine."Posting Date" := CashDocumentHeaderCZP."Posting Date";
        GenJournalLine."Posting Group" := "Posting Group";
        GenJournalLine.Prepayment := true;
        GenJournalLine."Prepayment Type" := GenJournalLine."Prepayment Type"::Advance;
        GenJournalLine."Advance Letter Link Code" := "Advance Letter Link Code";
        case "Account Type" of
            "Account Type"::Customer:
                begin
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                    GenJournalLine.Amount := -Amount;
                end;
            "Account Type"::Vendor:
                begin
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine.Amount := Amount;
                end;
        end;
        Codeunit.Run(Codeunit::"Gen. Jnl.-Link Letters", GenJournalLine);

        if (GenJournalLine."Advance Letter Link Code" <> "Advance Letter Link Code") or
           (GenJournalLine."Posting Group" <> "Posting Group")
        then begin
            "Advance Letter Link Code" := GenJournalLine."Advance Letter Link Code";
            Validate("Posting Group", GenJournalLine."Posting Group");
            Modify();
        end;
    end;

    internal procedure LinkWholeLetter()
    begin
        LinkCashDocLine();
    end;

    internal procedure UnLinkWholeLetter()
    begin
        UnLinkCashDocLine();
    end;

    internal procedure LinkCashDocLine()
    var
        PrepaymentLinksManagement: Codeunit "Prepayment Links Management";
        LinkCode: Code[30];
        AmountToLink: Decimal;
        PostingGroup: Code[20];
    begin
        TestField("Advance Letter Link Code", '');
        case "Document Type" of
            "Document Type"::Receipt:
                TestField("Account Type", "Account Type"::Customer);
            "Document Type"::Withdrawal:
                TestField("Account Type", "Account Type"::Vendor);
        end;
        TestField("Account No.");

        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.TestField("Prepayment Type", GeneralLedgerSetup."Prepayment Type"::Advances);

        LinkCode := "Cash Document No." + ' ' + Format("Line No.");
        case "Account Type" of
            "Account Type"::Customer:
                AmountToLink := PrepaymentLinksManagement.LinkWholeSalesLetter("Account No.", CashDocumentHeaderCZP."Currency Code",
                    LinkCode, PostingGroup);
            "Account Type"::Vendor:
                AmountToLink := PrepaymentLinksManagement.LinkWholePurchLetter("Account No.", CashDocumentHeaderCZP."Currency Code",
                    LinkCode, PostingGroup);
        end;

        if AmountToLink <> 0 then begin
            Validate(Amount, AmountToLink);
            Validate("Advance Letter Link Code", LinkCode);
            Validate("Posting Group", PostingGroup);
            Modify();
        end;
    end;

    local procedure UnLinkCashDocLine()
    var
        PrepaymentLinksManagement: Codeunit "Prepayment Links Management";
    begin
        TestField("Advance Letter Link Code");
        case "Document Type" of
            "Document Type"::Receipt:
                TestField("Account Type", "Account Type"::Customer);
            "Document Type"::Withdrawal:
                TestField("Account Type", "Account Type"::Vendor);
        end;
        TestField("Account No.");

        case "Account Type" of
            "Account Type"::Customer:
                PrepaymentLinksManagement.UnLinkWholeSalesLetter("Advance Letter Link Code");
            "Account Type"::Vendor:
                PrepaymentLinksManagement.UnLinkWholePurchLetter("Advance Letter Link Code");
        end;
        Validate("Advance Letter Link Code", '');
        Modify();
    end;
#endif
}
