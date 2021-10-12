table 31257 "Payment Order Line CZB"
{
    Caption = 'Payment Order Line';
    DrillDownPageID = "Payment Order Lines CZB";
    LookupPageID = "Payment Order Lines CZB";

    fields
    {
        field(1; "Payment Order No."; Code[20])
        {
            Caption = 'Payment Order No.';
            TableRelation = "Payment Order Header CZB"."No.";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                GetPaymentOrder();
                "Currency Code" := PaymentOrderHeaderCZB."Currency Code";
                "Payment Order Currency Code" := PaymentOrderHeaderCZB."Payment Order Currency Code";
                "Payment Order Currency Factor" := PaymentOrderHeaderCZB."Payment Order Currency Factor";
                "Due Date" := PaymentOrderHeaderCZB."Document Date";
                if BankAccount.Get(PaymentOrderHeaderCZB."Bank Account No.") then begin
                    "Constant Symbol" := BankAccount."Default Constant Symbol CZB";
                    "Specific Symbol" := BankAccount."Default Specific Symbol CZB";
                end;
            end;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; Type; Enum "Banking Line Type CZB")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
                if Type <> xRec.Type then begin
                    PaymentOrderLineCZB := Rec;
                    Init();
                    Validate("Payment Order No.");
                    Type := PaymentOrderLineCZB.Type;
                end;
            end;
        }
        field(4; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = if (Type = const(Customer)) Customer."No." else
            if (Type = const(Vendor)) Vendor."No." else
            if (Type = const("Bank Account")) "Bank Account"."No." else
            if (Type = const(Employee)) Employee."No.";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                BankAccount: Record "Bank Account";
                Customer: Record Customer;
                Vendor: Record Vendor;
                Employee: Record Employee;
            begin
                TestStatusOpen();
                if "No." <> xRec."No." then begin
                    if CurrFieldNo = FieldNo("No.") then begin
                        PaymentOrderLineCZB := Rec;
                        Init();
                        Validate("Payment Order No.");
                        Type := PaymentOrderLineCZB.Type;
                        "No." := PaymentOrderLineCZB."No.";
                    end;
                    case Type of
                        Type::Customer:
                            begin
                                if not Customer.Get("No.") then
                                    Customer.Init();
                                Customer.Testfield(Blocked, Customer.Blocked::" ");
                                Customer.Testfield("Privacy Blocked", false);
                                Name := Customer.Name;
                                "Payment Method Code" := Customer."Payment Method Code";
                                Validate("Cust./Vendor Bank Account Code", Customer."Preferred Bank Account Code");
                            end;
                        Type::Vendor:
                            begin
                                if not Vendor.Get("No.") then
                                    Vendor.Init();
                                Vendor.Testfield(Blocked, Vendor.Blocked::" ");
                                Vendor.Testfield("Privacy Blocked", false);
                                Name := Vendor.Name;
                                "Payment Method Code" := Vendor."Payment Method Code";
                                Validate("Cust./Vendor Bank Account Code", Vendor."Preferred Bank Account Code");
                            end;
                        Type::"Bank Account":
                            begin
                                if not BankAccount.Get("No.") then
                                    BankAccount.Init();
                                BankAccount.Testfield(Blocked, false);
                                "Account No." := BankAccount."Bank Account No.";
                                "Specific Symbol" := BankAccount."Default Specific Symbol CZB";
                                "Transit No." := BankAccount."Transit No.";
                                IBAN := BankAccount.IBAN;
                                "SWIFT Code" := BankAccount."SWIFT Code";
                                Name := BankAccount.Name;
                            end;
                        Type::Employee:
                            begin
                                Testfield("Currency Code", '');
                                if not Employee.Get("No.") then
                                    Employee.Init();
                                Employee.Testfield("Privacy Blocked", false);
                                "Account No." := Employee."No.";
                                IBAN := Employee.IBAN;
                                "SWIFT Code" := Employee."SWIFT Code";
                                Name := CopyStr(Employee.FullName(), 1, MaxStrLen(Name));
                            end;
                    end;
                end;
            end;
        }
        field(5; "Cust./Vendor Bank Account Code"; Code[20])
        {
            Caption = 'Cust./Vendor Bank Account Code';
            TableRelation = if (Type = const(Customer)) "Customer Bank Account".Code where("Customer No." = field("No.")) else
            if (Type = const(Vendor)) "Vendor Bank Account".Code where("Vendor No." = field("No."));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                VendorBankAccount: Record "Vendor Bank Account";
                CustomerBankAccount: Record "Customer Bank Account";
            begin
                TestStatusOpen();
                case Type of
                    Type::Vendor:
                        begin
                            if not VendorBankAccount.Get("No.", "Cust./Vendor Bank Account Code") then
                                VendorBankAccount.Init();
                            "Account No." := VendorBankAccount."Bank Account No.";
                            "Transit No." := VendorBankAccount."Transit No.";
                            IBAN := VendorBankAccount.IBAN;
                            "SWIFT Code" := VendorBankAccount."SWIFT Code";
                        end;
                    Type::Customer:
                        begin
                            if not CustomerBankAccount.Get("No.", "Cust./Vendor Bank Account Code") then
                                CustomerBankAccount.Init();
                            "Account No." := CustomerBankAccount."Bank Account No.";
                            "Transit No." := CustomerBankAccount."Transit No.";
                            IBAN := CustomerBankAccount.IBAN;
                            "SWIFT Code" := CustomerBankAccount."SWIFT Code";
                        end
                    else
                        FieldError(Type);
                end;
            end;
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(7; "Account No."; Text[30])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                BankOperationsFunctionsCZB: Codeunit "Bank Operations Functions CZB";
                BankOperationsFunctionsCZL: Codeunit "Bank Operations Functions CZL";
            begin
                TestStatusOpen();

                GetPaymentOrder();
                if not PaymentOrderHeaderCZB."Foreign Payment Order" then begin
                    BankOperationsFunctionsCZB.CheckBankAccountNoCharacters("Account No.");
                    BankOperationsFunctionsCZL.CheckCzBankAccountNo("Account No.", '');
                end;

                if "Account No." <> xRec."Account No." then begin
                    Type := Type::" ";
                    "No." := '';
                    "Cust./Vendor Bank Account Code" := '';
                    "Specific Symbol" := '';
                    "Transit No." := '';
                    IBAN := '';
                    "SWIFT Code" := '';
                    "Applies-to C/V/E Entry No." := 0;
                end;
            end;
        }
        field(8; "Variable Symbol"; Code[10])
        {
            Caption = 'Variable Symbol';
            CharAllowed = '09';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(9; "Constant Symbol"; Code[10])
        {
            Caption = 'Constant Symbol';
            CharAllowed = '09';
            TableRelation = "Constant Symbol CZL";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(10; "Specific Symbol"; Code[10])
        {
            Caption = 'Specific Symbol';
            CharAllowed = '09';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(11; Amount; Decimal)
        {
            Caption = 'Amount';
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
                GetPaymentOrder();
                if PaymentOrderHeaderCZB."Currency Code" <> '' then
                    "Amount (LCY)" :=
                      Round(CurrencyExchangeRate.ExchangeAmtFCYToLCY(PaymentOrderHeaderCZB."Document Date",
                          PaymentOrderHeaderCZB."Currency Code",
                          Amount,
                          PaymentOrderHeaderCZB."Currency Factor"))
                else
                    "Amount (LCY)" := Amount;

                if "Payment Order Currency Code" <> '' then begin
                    GetPaymentOrderCurrency();
                    "Amount (Paym. Order Currency)" :=
                      Round(CurrencyExchangeRate.ExchangeAmtLCYToFCY(PaymentOrderHeaderCZB."Document Date",
                          "Payment Order Currency Code",
                          "Amount (LCY)",
                          "Payment Order Currency Factor"),
                        PaymentOrderCurrency."Amount Rounding Precision")
                end else
                    "Amount (Paym. Order Currency)" := "Amount (LCY)";

                Positive := (Amount > 0);
            end;
        }
        field(12; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            AutoFormatType = 1;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
                GetPaymentOrder();
                if PaymentOrderHeaderCZB."Currency Code" <> '' then
                    Amount := Round(CurrencyExchangeRate.ExchangeAmtLCYToFCY(PaymentOrderHeaderCZB."Document Date", PaymentOrderHeaderCZB."Currency Code",
                          "Amount (LCY)", PaymentOrderHeaderCZB."Currency Factor"),
                        Currency."Amount Rounding Precision")
                else
                    Amount := "Amount (LCY)";

                if "Payment Order Currency Code" <> '' then begin
                    GetPaymentOrderCurrency();
                    "Amount (Paym. Order Currency)" := Round(CurrencyExchangeRate.ExchangeAmtLCYToFCY(PaymentOrderHeaderCZB."Document Date",
                          "Payment Order Currency Code",
                          "Amount (LCY)",
                          "Payment Order Currency Factor"),
                        PaymentOrderCurrency."Amount Rounding Precision")
                end else
                    "Amount (Paym. Order Currency)" := "Amount (LCY)";

                Positive := ("Amount (LCY)" > 0);
            end;
        }
        field(13; "Applies-to Doc. Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Applies-to Doc. Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
                Testfield("Applies-to C/V/E Entry No.", 0);
            end;
        }
        field(14; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                SalesInvoiceHeader: Record "Sales Invoice Header";
                SalesCrMemoHeader: Record "Sales Cr.Memo Header";
                PurchInvoiceHeader: Record "Purch. Inv. Header";
                PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
            begin
                if not (Type in [Type::Customer, Type::Vendor]) then
                    FieldError(Type);
                if not ("Applies-to Doc. Type" in ["Applies-to Doc. Type"::Invoice, "Applies-to Doc. Type"::"Credit Memo"]) then
                    FieldError("Applies-to Doc. Type");

                case true of
                    (Type = Type::Customer) and ("Applies-to Doc. Type" = "Applies-to Doc. Type"::Invoice):
                        begin
                            if "No." <> '' then
                                SalesInvoiceHeader.SetRange("Bill-to Customer No.", "No.");
                            if SalesInvoiceHeader.Get("Applies-to Doc. No.") then;
                            if PAGE.RunModal(0, SalesInvoiceHeader) = Action::LookupOK then begin
                                Testfield("Applies-to C/V/E Entry No.", 0);
                                Validate("Applies-to Doc. No.", SalesInvoiceHeader."No.");
                            end;
                        end;
                    (Type = Type::Customer) and ("Applies-to Doc. Type" = "Applies-to Doc. Type"::"Credit Memo"):
                        begin
                            if "No." <> '' then
                                SalesCrMemoHeader.SetRange("Bill-to Customer No.", "No.");
                            if SalesCrMemoHeader.Get("Applies-to Doc. No.") then;
                            if PAGE.RunModal(0, SalesCrMemoHeader) = Action::LookupOK then begin
                                Testfield("Applies-to C/V/E Entry No.", 0);
                                Validate("Applies-to Doc. No.", SalesCrMemoHeader."No.");
                            end;
                        end;
                    (Type = Type::Vendor) and ("Applies-to Doc. Type" = "Applies-to Doc. Type"::Invoice):
                        begin
                            if "No." <> '' then
                                PurchInvoiceHeader.SetRange("Pay-to Vendor No.", "No.");
                            if PurchInvoiceHeader.Get("Applies-to Doc. No.") then;
                            if PAGE.RunModal(0, PurchInvoiceHeader) = Action::LookupOK then begin
                                Testfield("Applies-to C/V/E Entry No.", 0);
                                Validate("Applies-to Doc. No.", PurchInvoiceHeader."No.");
                            end;
                        end;
                    (Type = Type::Vendor) and ("Applies-to Doc. Type" = "Applies-to Doc. Type"::"Credit Memo"):
                        begin
                            if "No." <> '' then
                                PurchCrMemoHdr.SetRange("Pay-to Vendor No.", "No.");
                            if PurchCrMemoHdr.Get("Applies-to Doc. No.") then;
                            if PAGE.RunModal(0, PurchCrMemoHdr) = Action::LookupOK then begin
                                Testfield("Applies-to C/V/E Entry No.", 0);
                                Validate("Applies-to Doc. No.", PurchCrMemoHdr."No.");
                            end;
                        end;
                end;
            end;

            trigger OnValidate()
            var
                CustLedgerEntry: Record "Cust. Ledger Entry";
                VendorLedgerEntry: Record "Vendor Ledger Entry";
            begin
                TestStatusOpen();
                Testfield("Applies-to C/V/E Entry No.", 0);
                if not (Type in [Type::Customer, Type::Vendor]) then
                    FieldError(Type);
                if not ("Applies-to Doc. Type" in ["Applies-to Doc. Type"::Invoice, "Applies-to Doc. Type"::"Credit Memo"]) then
                    FieldError("Applies-to Doc. Type");

                case Type of
                    Type::Customer:
                        begin
                            CustLedgerEntry.SetCurrentKey("Document No.");
                            CustLedgerEntry.SetRange("Document No.", "Applies-to Doc. No.");
                            case "Applies-to Doc. Type" of
                                "Applies-to Doc. Type"::Invoice:
                                    CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
                                "Applies-to Doc. Type"::"Credit Memo":
                                    CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
                            end;
                            if "No." <> '' then
                                CustLedgerEntry.SetRange("Customer No.", "No.");
                            case true of
                                CustLedgerEntry.IsEmpty:
                                    Error(NotExistEntryErr, CustLedgerEntry.FieldCaption("Document No."), CustLedgerEntry.TableCaption, "Applies-to Doc. No.");
                                CustLedgerEntry.Count > 1:
                                    Error(ExistEntryErr, CustLedgerEntry.FieldCaption("Document No."), CustLedgerEntry.TableCaption, "Applies-to Doc. No.");
                                else begin
                                        CustLedgerEntry.FindFirst();
                                        Validate("Applies-to C/V/E Entry No.", CustLedgerEntry."Entry No.");
                                    end;
                            end;
                        end;
                    Type::Vendor:
                        begin
                            VendorLedgerEntry.SetCurrentKey("Document No.");
                            VendorLedgerEntry.SetRange("Document No.", "Applies-to Doc. No.");
                            case "Applies-to Doc. Type" of
                                "Applies-to Doc. Type"::Invoice:
                                    VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
                                "Applies-to Doc. Type"::"Credit Memo":
                                    VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::"Credit Memo");
                            end;
                            if "No." <> '' then
                                VendorLedgerEntry.SetRange("Vendor No.", "No.");
                            case true of
                                VendorLedgerEntry.IsEmpty:
                                    Error(NotExistEntryErr, VendorLedgerEntry.FieldCaption("Document No."), VendorLedgerEntry.TableCaption, "Applies-to Doc. No.");
                                VendorLedgerEntry.Count > 1:
                                    Error(ExistEntryErr, VendorLedgerEntry.FieldCaption("Document No."), VendorLedgerEntry.TableCaption, "Applies-to Doc. No.");
                                else begin
                                        VendorLedgerEntry.FindFirst();
                                        Validate("Applies-to C/V/E Entry No.", VendorLedgerEntry."Entry No.");
                                    end;
                            end;
                        end;
                end;
            end;
        }
        field(16; "Applies-to C/V/E Entry No."; Integer)
        {
            Caption = 'Applies-to C/V/E Entry No.';
            BlankZero = true;
            TableRelation = if (Type = const(Vendor)) "Vendor Ledger Entry"."Entry No." where(Open = const(true), "On Hold" = const('')) else
            if (Type = const(Customer)) "Cust. Ledger Entry"."Entry No." where(Open = const(true), "On Hold" = const('')) else
            if (Type = const(Employee)) "Employee Ledger Entry"."Entry No." where(Open = const(true));
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                VendorLedgerEntry: Record "Vendor Ledger Entry";
                CustLedgerEntry: Record "Cust. Ledger Entry";
                EmployeeLedgerEntry: Record "Employee Ledger Entry";
                VendorLedgerEntries: Page "Vendor Ledger Entries";
                CustomerLedgerEntries: Page "Customer Ledger Entries";
                EmployeeLedgerEntries: Page "Employee Ledger Entries";
            begin
                case Type of
                    Type::Vendor:
                        begin
                            VendorLedgerEntry.SetCurrentKey("Vendor No.", Open);
                            VendorLedgerEntry.SetRange("On Hold", '');
                            VendorLedgerEntry.SetRange(Open, true);
                            VendorLedgerEntry.SetRange(Positive, false);
                            if VendorLedgerEntry.Get("Applies-to C/V/E Entry No.") then
                                VendorLedgerEntries.SetRecord(VendorLedgerEntry);
                            if "No." <> '' then
                                VendorLedgerEntry.SetRange("Vendor No.", "No.");
                            VendorLedgerEntries.SetTableView(VendorLedgerEntry);
                            VendorLedgerEntries.LookupMode(true);
                            if VendorLedgerEntries.RunModal() = Action::LookupOK then begin
                                VendorLedgerEntries.GetRecord(VendorLedgerEntry);
                                Validate("Applies-to C/V/E Entry No.", VendorLedgerEntry."Entry No.");
                            end else
                                Error('');
                        end;
                    Type::Customer:
                        begin
                            CustLedgerEntry.SetCurrentKey("Customer No.", Open);
                            CustLedgerEntry.SetRange("On Hold", '');
                            CustLedgerEntry.SetRange(Open, true);
                            CustLedgerEntry.SetRange(Positive, false);
                            if CustLedgerEntry.Get("Applies-to C/V/E Entry No.") then
                                CustomerLedgerEntries.SetRecord(CustLedgerEntry);
                            if "No." <> '' then
                                CustLedgerEntry.SetRange("Customer No.", "No.");
                            CustomerLedgerEntries.SetTableView(CustLedgerEntry);
                            CustomerLedgerEntries.LookupMode(true);
                            if CustomerLedgerEntries.RunModal() = Action::LookupOK then begin
                                CustomerLedgerEntries.GetRecord(CustLedgerEntry);
                                Validate("Applies-to C/V/E Entry No.", CustLedgerEntry."Entry No.");
                            end else
                                Error('');
                        end;
                    Type::Employee:
                        begin
                            EmployeeLedgerEntry.SetRange(Open, true);
                            EmployeeLedgerEntry.SetRange(Positive, false);
                            if EmployeeLedgerEntry.Get("Applies-to C/V/E Entry No.") then
                                EmployeeLedgerEntries.SetRecord(EmployeeLedgerEntry);
                            if "No." <> '' then
                                EmployeeLedgerEntry.SetRange("Employee No.", "No.");
                            EmployeeLedgerEntries.SetTableView(EmployeeLedgerEntry);
                            EmployeeLedgerEntries.LookupMode(true);
                            if EmployeeLedgerEntries.RunModal() = Action::LookupOK then begin
                                EmployeeLedgerEntries.GetRecord(EmployeeLedgerEntry);
                                Validate("Applies-to C/V/E Entry No.", EmployeeLedgerEntry."Entry No.");
                            end else
                                Error('');
                        end;
                end;
            end;

            trigger OnValidate()
            begin
                if "Applies-to C/V/E Entry No." <> 0 then
                    if CurrFieldNo = FieldNo("Applies-to C/V/E Entry No.") then
                        if not PaymentOrderManagementCZB.CheckPaymentOrderLineApply(Rec, false) then begin
                            if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(LedgerAlreadyAppliedQst, "Applies-to C/V/E Entry No."), false) then
                                Error('');
                            "Amount Must Be Checked" := true;
                        end;

                TestStatusOpen();
                GetPaymentOrder();
                "Original Amount" := 0;
                "Original Amount (LCY)" := 0;
                "Orig. Amount(Pay.Order Curr.)" := 0;
                "Original Due Date" := 0D;
                "Pmt. Discount Date" := 0D;
                "Pmt. Discount Possible" := false;
                "Remaining Pmt. Disc. Possible" := 0;
                "Applies-to Doc. Type" := "Applies-to Doc. Type"::" ";
                "Applies-to Doc. No." := '';

                PaymentOrderManagementCZB.ClearErrorMessageLog();

                if "Applies-to C/V/E Entry No." = 0 then
                    exit;

                case Type of
                    Type::Vendor:
                        AppliesToVendLedgEntryNo();
                    Type::Customer:
                        AppliesToCustLedgEntryNo();
                    Type::Employee:
                        AppliesToEmplLedgEntryNo();
                    else
                        FieldError(Type);
                end;
            end;
        }
        field(17; Positive; Boolean)
        {
            Caption = 'Positive';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18; "Transit No."; Text[20])
        {
            Caption = 'Transit No.';
            DataClassification = CustomerContent;
        }
        field(20; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(24; "Applied Currency Code"; Code[10])
        {
            Caption = 'Applied Currency Code';
            Editable = false;
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(25; "Payment Order Currency Code"; Code[10])
        {
            Caption = 'Payment Order Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                CurrExchRate: Record "Currency Exchange Rate";
            begin
                TestStatusOpen();
                GetPaymentOrder();
                if "Payment Order Currency Code" <> '' then
                    Validate("Payment Order Currency Factor",
                      CurrExchRate.ExchangeRate(PaymentOrderHeaderCZB."Document Date", "Payment Order Currency Code"))
                else
                    Validate("Payment Order Currency Factor", 0);
                case true of
                    ("Applies-to C/V/E Entry No." <> 0):
                        begin
                            Amount := 0;
                            Validate("Applies-to C/V/E Entry No.");
                        end
                    else
                        Validate("Amount (LCY)");
                end;
            end;
        }
        field(26; "Amount (Paym. Order Currency)"; Decimal)
        {
            Caption = 'Amount (Payment Order Currency)';
            AutoFormatExpression = "Payment Order Currency Code";
            AutoFormatType = 1;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
                GetPaymentOrder();
                if "Payment Order Currency Code" <> '' then begin
                    GetPaymentOrderCurrency();
                    "Amount (LCY)" := Round(CurrencyExchangeRate.ExchangeAmtFCYToLCY(PaymentOrderHeaderCZB."Document Date",
                          "Payment Order Currency Code", "Amount (Paym. Order Currency)", "Payment Order Currency Factor"))
                end else
                    "Amount (LCY)" := "Amount (Paym. Order Currency)";

                if PaymentOrderHeaderCZB."Currency Code" <> '' then
                    Amount := Round(CurrencyExchangeRate.ExchangeAmtLCYToFCY(PaymentOrderHeaderCZB."Document Date",
                          PaymentOrderHeaderCZB."Currency Code", "Amount (LCY)",
                          PaymentOrderHeaderCZB."Currency Factor"), Currency."Amount Rounding Precision")
                else
                    Amount := "Amount (LCY)";

                Positive := ("Amount (Paym. Order Currency)" > 0);
            end;
        }
        field(27; "Payment Order Currency Factor"; Decimal)
        {
            Caption = 'Payment Order Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Payment Order Currency Code" = "Applied Currency Code") and ("Payment Order Currency Code" <> '') then
                    Validate("Amount (Paym. Order Currency)")
                else
                    Validate("Amount (LCY)");
            end;
        }
        field(30; "Due Date"; Date)
        {
            Caption = 'Due Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(40; IBAN; Code[50])
        {
            Caption = 'IBAN';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                CompanyInfo: Record "Company Information";
            begin
                TestStatusOpen();
                CompanyInfo.CheckIBAN(IBAN);
            end;
        }
        field(45; "SWIFT Code"; Code[20])
        {
            Caption = 'SWIFT Code';
            TableRelation = "SWIFT Code";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(50; "Amount Must Be Checked"; Boolean)
        {
            Caption = 'Amount Must Be Checked';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(70; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(80; "Original Amount"; Decimal)
        {
            Caption = 'Original Amount';
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(90; "Original Amount (LCY)"; Decimal)
        {
            Caption = 'Original Amount (LCY)';
            AutoFormatType = 1;
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(100; "Orig. Amount(Pay.Order Curr.)"; Decimal)
        {
            Caption = 'Original Amount (Payment Order Currency)';
            AutoFormatExpression = "Payment Order Currency Code";
            AutoFormatType = 1;
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(110; "Original Due Date"; Date)
        {
            Caption = 'Original Due Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(120; "Skip Payment"; Boolean)
        {
            Caption = 'Skip Payment';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(130; "Pmt. Discount Date"; Date)
        {
            Caption = 'Pmt. Discount Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(135; "Pmt. Discount Possible"; Boolean)
        {
            Caption = 'Pmt. Discount Possible';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(140; "Remaining Pmt. Disc. Possible"; Decimal)
        {
            Caption = 'Remaining Payment Discount Possible';
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Editable = false;
            DataClassification = CustomerContent;
        }
#pragma warning disable AL0432         
        field(150; "Letter Type"; Option)
        {
            Caption = 'Letter Type';
            OptionCaption = ' ,,Purchase';
            OptionMembers = " ",,Purchase;
#if CLEAN19
            ObsoleteState = Removed;
#else
            ObsoleteState = Pending;
#endif    
            ObsoleteReason = 'Remove after new Advance Payment Localization for Czech will be implemented.';
            ObsoleteTag = '19.0';
#if not CLEAN19
            trigger OnValidate()
            begin
                TestStatusOpen();
                "Applies-to Doc. Type" := "Applies-to Doc. Type"::" ";
                "Applies-to Doc. No." := '';
                "Applies-to C/V/E Entry No." := 0;
                "Original Amount" := 0;
                "Original Amount (LCY)" := 0;
                "Orig. Amount(Pay.Order Curr.)" := 0;
                "Original Due Date" := 0D;
                "Pmt. Discount Date" := 0D;
                "Pmt. Discount Possible" := false;
                "Remaining Pmt. Disc. Possible" := 0;
            end;
#endif
        }
        field(151; "Letter No."; Code[20])
        {
            Caption = 'Letter No.';
            TableRelation = if ("Letter Type" = const(Purchase)) "Purch. Advance Letter Header";
#if CLEAN19
            ObsoleteState = Removed;
#else
            ObsoleteState = Pending;
#endif    
            ObsoleteReason = 'Remove after new Advance Payment Localization for Czech will be implemented.';
            ObsoleteTag = '19.0';
#if not CLEAN19
            trigger OnValidate()
            var
                PurchAdvLetterHeader: Record "Purch. Advance Letter Header";
                Vendor: Record Vendor;
                Currency: Record Currency;
                RemAmount: Decimal;
            begin
                TestStatusOpen();
                GetPaymentOrder();
                "Applies-to Doc. Type" := "Applies-to Doc. Type"::" ";
                "Applies-to Doc. No." := '';
                "Applies-to C/V/E Entry No." := 0;
                "Original Amount" := 0;
                "Original Amount (LCY)" := 0;
                "Orig. Amount(Pay.Order Curr.)" := 0;
                "Original Due Date" := 0D;
                "Pmt. Discount Date" := 0D;
                "Pmt. Discount Possible" := false;
                "Remaining Pmt. Disc. Possible" := 0;
                "Letter Line No." := 0;

                RemAmount := 0;
                PaymentOrderManagementCZB.ClearErrorMessageLog();
                case "Letter Type" of
                    "Letter Type"::Purchase:
                        begin
                            if "Letter No." <> '' then begin
                                if CurrFieldNo = FieldNo("Letter No.") then
                                    if not PaymentOrderManagementCZB.CheckPaymentOrderLineApply(Rec, false) then begin
                                        if not Confirm(StrSubstNo(AdvanceAlreadyAppliedQst, "Letter No.")) then
                                            Error('');
                                        "Amount Must Be Checked" := true;
                                    end;
                                PurchAdvLetterHeader.Get("Letter No.");
                                "Variable Symbol" := PurchAdvLetterHeader."Variable Symbol";
                                if PurchAdvLetterHeader."Constant Symbol" <> '' then
                                    "Constant Symbol" := PurchAdvLetterHeader."Constant Symbol";
                                BankAccount.Get(PaymentOrderHeaderCZB."Bank Account No.");
                                if BankAccount."Payment Order Line Description" = '' then
                                    Description := PurchAdvLetterHeader."Posting Description"
                                else begin
                                    Vendor.Get(PurchAdvLetterHeader."Pay-to Vendor No.");
                                    Description := CreateDescription(AdvancePaymentTxt, PurchAdvLetterHeader."No.",
                                        Vendor."No.", Vendor.Name, PurchAdvLetterHeader."Vendor Adv. Payment No.");
                                end;
                                Type := Type::Vendor;
                                "No." := PurchAdvLetterHeader."Pay-to Vendor No.";
                                Validate("No.", PurchAdvLetterHeader."Pay-to Vendor No.");
                                "Cust./Vendor Bank Account Code" := PurchAdvLetterHeader."Bank Account Code";
                                "Account No." := PurchAdvLetterHeader."Bank Account No.";
                                "Specific Symbol" := PurchAdvLetterHeader."Specific Symbol";
                                "Transit No." := PurchAdvLetterHeader."Transit No.";
                                IBAN := PurchAdvLetterHeader.IBAN;
                                "SWIFT Code" := PurchAdvLetterHeader."SWIFT Code";
                                "Applied Currency Code" := PurchAdvLetterHeader."Currency Code";
                                if PurchAdvLetterHeader."Advance Due Date" > "Due Date" then
                                    "Due Date" := PurchAdvLetterHeader."Advance Due Date";
                                "Original Due Date" := PurchAdvLetterHeader."Advance Due Date";
                                if Amount = 0 then begin
                                    RemAmount := PurchAdvLetterHeader.GetRemAmount();
                                    if "Payment Order Currency Code" = PurchAdvLetterHeader."Currency Code" then begin
                                        "Amount (Paym. Order Currency)" := RemAmount;
                                        Validate("Amount (Paym. Order Currency)");
                                    end else begin
                                        if PurchAdvLetterHeader."Currency Code" <> '' then begin
                                            Currency.Get(PurchAdvLetterHeader."Currency Code");
                                            Currency.InitRoundingPrecision();
                                            "Amount (LCY)" := Round(CurrencyExchangeRate.ExchangeAmtFCYToLCY(PurchAdvLetterHeader."Document Date",
                                                  PurchAdvLetterHeader."Currency Code",
                                                  RemAmount,
                                                  PurchAdvLetterHeader."Currency Factor"));
                                        end else
                                            "Amount (LCY)" := RemAmount;

                                        Validate("Amount (LCY)");
                                    end;
                                end;
                            end;
                            "Original Amount" := Amount;
                            "Original Amount (LCY)" := "Amount (LCY)";
                            "Orig. Amount(Pay.Order Curr.)" := "Amount (Paym. Order Currency)";
                        end;
                    else
                        FieldError(Type);
                end;
            end;
#endif
        }
        field(152; "Letter Line No."; Integer)
        {
            Caption = 'Letter Line No.';
            TableRelation = IF ("Letter Type" = const(Purchase)) "Purch. Advance Letter Line"."Line No." where("Letter No." = field("Letter No."));
#if CLEAN19
            ObsoleteState = Removed;
#else
            ObsoleteState = Pending;
#endif    
            ObsoleteReason = 'Remove after new Advance Payment Localization for Czech will be implemented.';
            ObsoleteTag = '19.0';
#if not CLEAN19
            trigger OnValidate()
            var
                PurchAdvLetterHeader: Record "Purch. Advance Letter Header";
                PurchAdvLetterLine: Record "Purch. Advance Letter Line";
                Vendor: Record Vendor;
                Currency: Record Currency;
                RemAmount: Decimal;
            begin
                TestStatusOpen();
                GetPaymentOrder();
                "Applies-to Doc. Type" := "Applies-to Doc. Type"::" ";
                "Applies-to Doc. No." := '';
                "Applies-to C/V/E Entry No." := 0;
                "Original Amount" := 0;
                "Original Amount (LCY)" := 0;
                "Orig. Amount(Pay.Order Curr.)" := 0;
                "Original Due Date" := 0D;
                "Pmt. Discount Date" := 0D;
                "Pmt. Discount Possible" := false;
                "Remaining Pmt. Disc. Possible" := 0;

                RemAmount := 0;
                PaymentOrderManagementCZB.ClearErrorMessageLog();
                case "Letter Type" of
                    "Letter Type"::Purchase:
                        begin
                            if "Letter Line No." <> 0 then begin
                                TestField("Letter No.");
                                if CurrFieldNo = FieldNo("Letter Line No.") then
                                    if not PaymentOrderManagementCZB.CheckPaymentOrderLineApply(Rec, false) then begin
                                        if not Confirm(StrSubstNo(LedgerAlreadyAppliedLineQst, "Letter No.")) then
                                            Error('');
                                        "Amount Must Be Checked" := true;
                                    end;

                                PurchAdvLetterHeader.Get("Letter No.");
                                PurchAdvLetterHeader.TestField("Due Date from Line", true);
                                PurchAdvLetterLine.Get("Letter No.", "Letter Line No.");

                                "Variable Symbol" := PurchAdvLetterHeader."Variable Symbol";
                                if PurchAdvLetterHeader."Constant Symbol" <> '' then
                                    "Constant Symbol" := PurchAdvLetterHeader."Constant Symbol";
                                BankAccount.Get(PaymentOrderHeaderCZB."Bank Account No.");
                                if BankAccount."Payment Order Line Description" = '' then
                                    Description := PurchAdvLetterHeader."Posting Description"
                                else begin
                                    Vendor.Get(PurchAdvLetterHeader."Pay-to Vendor No.");
                                    Description := CreateDescription(AdvancePaymentLineTxt, PurchAdvLetterHeader."No.",
                                        Vendor."No.", Vendor.Name, PurchAdvLetterHeader."Vendor Adv. Payment No.");
                                end;
                                Type := Type::Vendor;
                                "No." := PurchAdvLetterHeader."Pay-to Vendor No.";
                                Validate("No.", PurchAdvLetterHeader."Pay-to Vendor No.");
                                "Cust./Vendor Bank Account Code" := PurchAdvLetterHeader."Bank Account Code";
                                "Account No." := PurchAdvLetterHeader."Bank Account No.";
                                "Specific Symbol" := PurchAdvLetterHeader."Specific Symbol";
                                "Transit No." := PurchAdvLetterHeader."Transit No.";
                                IBAN := PurchAdvLetterHeader.IBAN;
                                "SWIFT Code" := PurchAdvLetterHeader."SWIFT Code";
                                "Applied Currency Code" := PurchAdvLetterHeader."Currency Code";
                                if PurchAdvLetterLine."Advance Due Date" > "Due Date" then
                                    "Due Date" := PurchAdvLetterLine."Advance Due Date";
                                "Original Due Date" := PurchAdvLetterLine."Advance Due Date";
                                if Amount = 0 then begin
                                    RemAmount := PurchAdvLetterLine."Amount To Link";
                                    if "Payment Order Currency Code" = PurchAdvLetterHeader."Currency Code" then begin
                                        "Amount (Paym. Order Currency)" := RemAmount;
                                        Validate("Amount (Paym. Order Currency)");
                                    end else begin
                                        if PurchAdvLetterHeader."Currency Code" <> '' then begin
                                            Currency.Get(PurchAdvLetterHeader."Currency Code");
                                            Currency.InitRoundingPrecision();
                                            "Amount (LCY)" := Round(CurrencyExchangeRate.ExchangeAmtFCYToLCY(PurchAdvLetterHeader."Document Date",
                                                  PurchAdvLetterHeader."Currency Code",
                                                  RemAmount,
                                                  PurchAdvLetterHeader."Currency Factor"))
                                        end else
                                            "Amount (LCY)" := RemAmount;

                                        Validate("Amount (LCY)");
                                    end;
                                end;
                            end;
                            "Original Amount" := "Amount";
                            "Original Amount (LCY)" := "Amount (LCY)";
                            "Orig. Amount(Pay.Order Curr.)" := "Amount (Paym. Order Currency)";
                        end;
                    else
                        FieldError(Type);
                end;
            end;
#endif
        }
#pragma warning restore AL0432 
        field(190; "VAT Unreliable Payer"; Boolean)
        {
            Caption = 'VAT Unreliable Payer';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(191; "Public Bank Account"; Boolean)
        {
            Caption = 'Public Bank Account';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(192; "Third Party Bank Account"; Boolean)
        {
            Caption = 'Third Party Bank Account';
            CalcFormula = lookup("Vendor Bank Account"."Third Party Bank Account CZL" where("Vendor No." = field("No."), Code = field("Cust./Vendor Bank Account Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(200; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
    }

    keys
    {
        key(Key1; "Payment Order No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Payment Order No.", Positive, "Skip Payment")
        {
            SumIndexFields = Amount, "Amount (LCY)";
        }
        key(Key3; "Payment Order No.", "Due Date")
        {
        }
        key(Key4; "Payment Order No.", Amount)
        {
        }
        key(Key5; "Payment Order No.", Type, "No.")
        {
        }
        key(Key6; "Payment Order No.", "Skip Payment")
        {
            SumIndexFields = "Amount (Paym. Order Currency)";
        }
        key(Key7; "Payment Order No.", "Original Due Date")
        {
        }
    }

    trigger OnDelete()
    begin
        TestStatusOpen();
    end;

    trigger OnInsert()
    begin
        TestStatusOpen();
        ModifyPaymentOrderHeader();
    end;

    trigger OnModify()
    begin
        ModifyPaymentOrderHeader();
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
        Currency: Record Currency;
        PaymentOrderCurrency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        BankAccount: Record "Bank Account";
        Vendor: Record Vendor;
        PaymentOrderManagementCZB: Codeunit "Payment Order Management CZB";
        ConfirmManagement: Codeunit "Confirm Management";
        GLSetupRead: Boolean;
        AdvancePaymentTxt: Label 'Advance Payment';
        AdvancePaymentLineTxt: Label 'Advance Payment Line';
        AdvanceAlreadyAppliedQst: Label 'Advanced payment %1 is already applied on payment order. Continue?', Comment = '%1 = Letter No.';
        ExistEntryErr: Label 'For the field %1 in table %2 exist more than one value %3.', Comment = '%1 = FieldCaption, %2 = TableCaption, %3 = Applies-to Doc. No.';
        NotExistEntryErr: Label 'For the field %1 in table %2 not exist value %3.', Comment = '%1 = FieldCaption, %2 = TableCaption, %3 = Applies-to Doc. No.';
        LedgerAlreadyAppliedQst: Label 'Ledger entry %1 is already applied on payment order. Continue?', Comment = '%1 = Applies-to C/V Entry No.';
        LedgerAlreadyAppliedLineQst: Label 'Advanced payment %1 is already applied on payment order. Continue?', Comment = '%1 = Letter No.';
        StatusCheckSuspended: Boolean;

    procedure GetPaymentOrder()
    begin
        if "Payment Order No." <> PaymentOrderHeaderCZB."No." then begin
            PaymentOrderHeaderCZB.Get("Payment Order No.");
            if PaymentOrderHeaderCZB."Currency Code" = '' then
                Currency.InitRoundingPrecision()
            else begin
                PaymentOrderHeaderCZB.Testfield("Currency Factor");
                Currency.Get(PaymentOrderHeaderCZB."Currency Code");
                Currency.Testfield("Amount Rounding Precision");
            end;
        end;
    end;

    procedure GetPaymentOrderCurrency()
    begin
        if "Payment Order Currency Code" <> PaymentOrderCurrency.Code then
            if "Payment Order Currency Code" = '' then
                PaymentOrderCurrency.InitRoundingPrecision()
            else begin
                Testfield("Payment Order Currency Factor");
                PaymentOrderCurrency.Get("Payment Order Currency Code");
                PaymentOrderCurrency.Testfield("Amount Rounding Precision");
            end;
    end;

    procedure CreateDescription(DocType: Text[30]; DocNo: Text[20]; PartnerNo: Text[20]; PartnerName: Text[100]; ExtNo: Text[35]): Text[50]
    begin
        exit(CopyStr(StrSubstNo(BankAccount."Payment Order Line Descr. CZB", DocType, DocNo, PartnerNo, PartnerName, ExtNo), 1, 50));
    end;

    procedure GetGLSetup()
    begin
        if not GLSetupRead then begin
            GLSetupRead := true;
            GeneralLedgerSetup.Get();
        end;
    end;

    procedure ModifyPaymentOrderHeader()
    begin
        GetPaymentOrder();
        if PaymentOrderHeaderCZB."Unreliable Pay. Check DateTime" <> 0DT then begin
            PaymentOrderHeaderCZB."Unreliable Pay. Check DateTime" := 0DT;
            PaymentOrderHeaderCZB.Modify();
        end;
    end;

    procedure AppliesToCustLedgEntryNo()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        CurrencyAmount: Decimal;
        CurrFactor: Decimal;
    begin
        CustLedgerEntry.Get("Applies-to C/V/E Entry No.");
        "Applies-to Doc. Type" := CustLedgerEntry."Document Type";
        "Applies-to Doc. No." := CustLedgerEntry."Document No.";
        "Variable Symbol" := CustLedgerEntry."Variable Symbol CZL";
        if CustLedgerEntry."Constant Symbol CZL" <> '' then
            "Constant Symbol" := CustLedgerEntry."Constant Symbol CZL";
        BankAccount.Get(PaymentOrderHeaderCZB."Bank Account No.");
        if BankAccount."Payment Order Line Descr. CZB" = '' then
            Description := CustLedgerEntry.Description
        else begin
            Customer.Get(CustLedgerEntry."Customer No.");
            Description := CreateDescription(Format(CustLedgerEntry."Document Type"), CustLedgerEntry."Document No.",
                Customer."No.", Customer.Name, CustLedgerEntry."External Document No.");
        end;
        Type := Type::Customer;
        "No." := CustLedgerEntry."Customer No.";
        Validate("No.", CustLedgerEntry."Customer No.");
        "Cust./Vendor Bank Account Code" :=
          CopyStr(CustLedgerEntry."Bank Account Code CZL", 1, MaxStrLen("Cust./Vendor Bank Account Code"));
        "Account No." := CustLedgerEntry."Bank Account No. CZL";
        "Specific Symbol" := CustLedgerEntry."Specific Symbol CZL";
        "Transit No." := CustLedgerEntry."Transit No. CZL";
        IBAN := CustLedgerEntry."IBAN CZL";
        "SWIFT Code" := CustLedgerEntry."SWIFT Code CZL";
        Validate("Applied Currency Code", CustLedgerEntry."Currency Code");
        if CustLedgerEntry."Due Date" > "Due Date" then
            "Due Date" := CustLedgerEntry."Due Date";
        "Original Due Date" := CustLedgerEntry."Due Date";
        if Amount = 0 then begin
            CustLedgerEntry.CalcFields("Remaining Amount", "Remaining Amt. (LCY)");
            if "Payment Order Currency Code" = CustLedgerEntry."Currency Code" then begin
                if (CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Invoice) and
                   (PaymentOrderHeaderCZB."Document Date" <= CustLedgerEntry."Pmt. Discount Date")
                then begin
                    "Amount (Paym. Order Currency)" := -(CustLedgerEntry."Remaining Amount" - CustLedgerEntry."Remaining Pmt. Disc. Possible");
                    "Pmt. Discount Date" := CustLedgerEntry."Pmt. Discount Date";
                    "Pmt. Discount Possible" := true;
                    "Remaining Pmt. Disc. Possible" := CustLedgerEntry."Remaining Pmt. Disc. Possible";
                end else
                    "Amount (Paym. Order Currency)" := -CustLedgerEntry."Remaining Amount";
                Validate("Amount (Paym. Order Currency)");
            end else begin
                if (CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Invoice) and
                   (PaymentOrderHeaderCZB."Document Date" <= CustLedgerEntry."Pmt. Discount Date")
                then begin
                    CurrencyAmount := -(CustLedgerEntry."Remaining Amount" - CustLedgerEntry."Remaining Pmt. Disc. Possible");
                    CurrFactor := CurrencyExchangeRate.ExchangeRate(PaymentOrderHeaderCZB."Document Date", CustLedgerEntry."Currency Code");
                    "Amount (LCY)" := Round(CurrencyExchangeRate.ExchangeAmtFCYToLCY(PaymentOrderHeaderCZB."Document Date",
                          CustLedgerEntry."Currency Code", CurrencyAmount, CurrFactor));
                    "Pmt. Discount Date" := CustLedgerEntry."Pmt. Discount Date";
                    "Pmt. Discount Possible" := true;
                    "Remaining Pmt. Disc. Possible" := CustLedgerEntry."Remaining Pmt. Disc. Possible";
                end else
                    "Amount (LCY)" := -CustLedgerEntry."Remaining Amt. (LCY)";
                Validate("Amount (LCY)");
            end;
            "Original Amount" := Amount;
            "Original Amount (LCY)" := "Amount (LCY)";
            "Orig. Amount(Pay.Order Curr.)" := "Amount (Paym. Order Currency)";
        end;
    end;

    procedure AppliesToVendLedgEntryNo()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        CurrencyAmount: Decimal;
        CurrFactor: Decimal;
    begin
        VendorLedgerEntry.Get("Applies-to C/V/E Entry No.");
        "Applies-to Doc. Type" := VendorLedgerEntry."Document Type";
        "Applies-to Doc. No." := VendorLedgerEntry."Document No.";
        "Variable Symbol" := VendorLedgerEntry."Variable Symbol CZL";
        if VendorLedgerEntry."Constant Symbol CZL" <> '' then
            "Constant Symbol" := VendorLedgerEntry."Constant Symbol CZL";
        BankAccount.Get(PaymentOrderHeaderCZB."Bank Account No.");
        if BankAccount."Payment Order Line Descr. CZB" = '' then
            Description := VendorLedgerEntry.Description
        else begin
            Vendor.Get(VendorLedgerEntry."Vendor No.");
            Description := CreateDescription(Format(VendorLedgerEntry."Document Type"), VendorLedgerEntry."Document No.",
                Vendor."No.", Vendor.Name, VendorLedgerEntry."External Document No.");
        end;
        Type := Type::Vendor;
        "No." := VendorLedgerEntry."Vendor No.";
        Validate("No.", VendorLedgerEntry."Vendor No.");
        "Cust./Vendor Bank Account Code" :=
          CopyStr(VendorLedgerEntry."Bank Account Code CZL", 1, MaxStrLen("Cust./Vendor Bank Account Code"));
        "Account No." := VendorLedgerEntry."Bank Account No. CZL";
        "Specific Symbol" := VendorLedgerEntry."Specific Symbol CZL";
        "Transit No." := VendorLedgerEntry."Transit No. CZL";
        IBAN := VendorLedgerEntry."IBAN CZL";
        "SWIFT Code" := VendorLedgerEntry."SWIFT Code CZL";
        Validate("Applied Currency Code", VendorLedgerEntry."Currency Code");
        if VendorLedgerEntry."Due Date" > "Due Date" then
            "Due Date" := VendorLedgerEntry."Due Date";
        "Original Due Date" := VendorLedgerEntry."Due Date";
        if Amount = 0 then begin
            VendorLedgerEntry.CalcFields("Remaining Amount", "Remaining Amt. (LCY)");
            if "Payment Order Currency Code" = VendorLedgerEntry."Currency Code" then begin
                if (VendorLedgerEntry."Document Type" = VendorLedgerEntry."Document Type"::Invoice) and
                   (PaymentOrderHeaderCZB."Document Date" <= VendorLedgerEntry."Pmt. Discount Date")
                then begin
                    "Amount (Paym. Order Currency)" := -(VendorLedgerEntry."Remaining Amount" - VendorLedgerEntry."Remaining Pmt. Disc. Possible");
                    "Pmt. Discount Date" := VendorLedgerEntry."Pmt. Discount Date";
                    "Pmt. Discount Possible" := true;
                    "Remaining Pmt. Disc. Possible" := VendorLedgerEntry."Remaining Pmt. Disc. Possible";
                    if ("Remaining Pmt. Disc. Possible" <> 0) and ("Pmt. Discount Date" <> 0D) then
                        "Due Date" := "Pmt. Discount Date";
                end else
                    "Amount (Paym. Order Currency)" := -VendorLedgerEntry."Remaining Amount";
                Validate("Amount (Paym. Order Currency)");
            end else begin
                if (VendorLedgerEntry."Document Type" = VendorLedgerEntry."Document Type"::Invoice) and
                   (PaymentOrderHeaderCZB."Document Date" <= VendorLedgerEntry."Pmt. Discount Date")
                then begin
                    CurrencyAmount := -(VendorLedgerEntry."Remaining Amount" - VendorLedgerEntry."Remaining Pmt. Disc. Possible");
                    CurrFactor := CurrencyExchangeRate.ExchangeRate(PaymentOrderHeaderCZB."Document Date", VendorLedgerEntry."Currency Code");
                    "Amount (LCY)" := Round(CurrencyExchangeRate.ExchangeAmtFCYToLCY(PaymentOrderHeaderCZB."Document Date",
                          VendorLedgerEntry."Currency Code", CurrencyAmount, CurrFactor));
                    "Pmt. Discount Date" := VendorLedgerEntry."Pmt. Discount Date";
                    "Pmt. Discount Possible" := true;
                    "Remaining Pmt. Disc. Possible" := VendorLedgerEntry."Remaining Pmt. Disc. Possible";
                    if ("Remaining Pmt. Disc. Possible" <> 0) and ("Pmt. Discount Date" <> 0D) then
                        "Due Date" := "Pmt. Discount Date";
                end else
                    "Amount (LCY)" := -VendorLedgerEntry."Remaining Amt. (LCY)";
                Validate("Amount (LCY)");
            end;
            "Original Amount" := Amount;
            "Original Amount (LCY)" := "Amount (LCY)";
            "Orig. Amount(Pay.Order Curr.)" := "Amount (Paym. Order Currency)";
        end;
    end;

    procedure AppliesToEmplLedgEntryNo()
    var
        EmployeeLedgerEntry: Record "Employee Ledger Entry";
        Employee: Record Employee;
    begin
        EmployeeLedgerEntry.Get("Applies-to C/V/E Entry No.");
        Employee.Get(EmployeeLedgerEntry."Employee No.");

        "Applies-to Doc. Type" := EmployeeLedgerEntry."Document Type";
        "Applies-to Doc. No." := EmployeeLedgerEntry."Document No.";
        "Variable Symbol" := EmployeeLedgerEntry."Variable Symbol CZL";
        "Specific Symbol" := EmployeeLedgerEntry."Specific Symbol CZL";
        if EmployeeLedgerEntry."Constant Symbol CZL" <> '' then
            "Constant Symbol" := EmployeeLedgerEntry."Constant Symbol CZL";
        BankAccount.Get(PaymentOrderHeaderCZB."Bank Account No.");
        if BankAccount."Payment Order Line Descr. CZB" = '' then
            Description := EmployeeLedgerEntry.Description
        else
            Description := CreateDescription(Format(EmployeeLedgerEntry."Document Type"), EmployeeLedgerEntry."Document No.",
                Employee."No.", CopyStr(Employee.FullName(), 1, MaxStrLen(Description)), '');

        Type := Type::Employee;
        Validate("No.", EmployeeLedgerEntry."Employee No.");
        "Account No." := Employee."Bank Account No.";
        IBAN := Employee.IBAN;
        "SWIFT Code" := Employee."SWIFT Code";
        Validate("Applied Currency Code", EmployeeLedgerEntry."Currency Code");
        if Amount = 0 then begin
            EmployeeLedgerEntry.CalcFields("Remaining Amount", "Remaining Amt. (LCY)");
            if "Payment Order Currency Code" = EmployeeLedgerEntry."Currency Code" then
                Validate("Amount (Paym. Order Currency)", -EmployeeLedgerEntry."Remaining Amount")
            else
                Validate("Amount (LCY)", -EmployeeLedgerEntry."Remaining Amt. (LCY)");
            "Original Amount" := Amount;
            "Original Amount (LCY)" := "Amount (LCY)";
            "Orig. Amount(Pay.Order Curr.)" := "Amount (Paym. Order Currency)";
        end;
    end;

    local procedure TestStatusOpen()
    begin
        if StatusCheckSuspended then
            exit;
        GetPaymentOrder();
        PaymentOrderHeaderCZB.Testfield(Status, PaymentOrderHeaderCZB.Status::Open);
    end;

    procedure SuspendStatusCheck(Suspend: Boolean)
    begin
        StatusCheckSuspended := Suspend;
    end;

    local procedure GetVendor(): Boolean
    begin
        if Type <> Type::Vendor then
            exit(false);

        if Vendor."No." <> "No." then
            exit(Vendor.Get("No."));

        exit(true);
    end;

    procedure IsUnreliablePayerCheckPossible(): Boolean
    begin
        if not GetVendor() then
            exit(false);

        exit(Vendor.IsUnreliablePayerCheckPossibleCZL());
    end;

    procedure GetUnreliablePayerStatus(): Integer
    begin
        if not GetVendor() then
            exit(0);

        exit(Vendor.GetUnreliablePayerStatusCZL());
    end;

    procedure HasUnreliablePayer(): Boolean
    var
        UnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL";
    begin
        exit(GetUnreliablePayerStatus() = UnreliablePayerEntryCZL."Unreliable Payer"::YES);
    end;

    procedure HasPublicBankAccount(): Boolean
    var
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
    begin
        if not GetVendor() then
            exit(false);

        exit(UnreliablePayerMgtCZL.IsPublicBankAccount('', Vendor."VAT Registration No.", "Account No.", IBAN));
    end;
}

