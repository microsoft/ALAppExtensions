report 1690 "Bank Deposit"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/reports/BankDeposit.rdlc';
    ApplicationArea = Basic, Suite;
    Caption = 'Bank Deposit';
    UsageCategory = ReportsAndAnalysis;
    Permissions = tabledata "Posted Bank Deposit Header" = r,
                  tabledata "Posted Bank Deposit Line" = r;

    dataset
    {
        dataitem("Posted Bank Deposit Header"; "Posted Bank Deposit Header")
        {
            RequestFilterFields = "No.", "Bank Account No.";
            column(Posted_Bank_Deposit_Header_No_; "No.")
            {
            }
            dataitem(PageHeader; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(USERID; UserId)
                {
                }
                column(TIME; Time)
                {
                }
                column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
                {
                }
                column(STRSUBSTNO_DepositDescriptionTxt__Posted_Bank_Deposit_Header___No___; StrSubstNo(DepositDescriptionTxt, "Posted Bank Deposit Header"."No."))
                {
                }
                column(CompanyInformation_Name; CompanyInformation.Name)
                {
                }
                column(Posted_Bank_Deposit_Header___Bank_Account_No__; "Posted Bank Deposit Header"."Bank Account No.")
                {
                }
                column(BankAccount_Name; BankAccount.Name)
                {
                }
                column(Posted_Bank_Deposit_Header___Document_Date_; "Posted Bank Deposit Header"."Document Date")
                {
                }
                column(Posted_Bank_Deposit_Header___Posting_Date_; "Posted Bank Deposit Header"."Posting Date")
                {
                }
                column(Posted_Bank_Deposit_Header___Total_Deposit_Amount_; "Posted Bank Deposit Header"."Total Deposit Amount")
                {
                }
                column(Posted_Bank_Deposit_Header___Posting_Description_; "Posted Bank Deposit Header"."Posting Description")
                {
                }
                column(PrintApplications; PrintApplications)
                {
                }
                column(PageHeader_Number; Number)
                {
                }
                column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
                {
                }
                column(Deposited_InCaption; Deposited_InCaptionLbl)
                {
                }
                column(Posted_Bank_Deposit_Header___Bank_Account_No__Caption; Posted_Bank_Deposit_Header___Bank_Account_No__CaptionLbl)
                {
                }
                column(Currency_CodeCaption; Currency_CodeCaptionLbl)
                {
                }
                column(Posted_Bank_Deposit_Header___Document_Date_Caption; Posted_Bank_Deposit_Header___Document_Date_CaptionLbl)
                {
                }
                column(Posted_Bank_Deposit_Header___Posting_Date_Caption; Posted_Bank_Deposit_Header___Posting_Date_CaptionLbl)
                {
                }
                column(Posted_Bank_Deposit_Header___Total_Deposit_Amount_Caption; Posted_Bank_Deposit_Header___Total_Deposit_Amount_CaptionLbl)
                {
                }
                column(Posted_Bank_Deposit_Header___Posting_Description_Caption; Posted_Bank_Deposit_Header___Posting_Description_CaptionLbl)
                {
                }
                column(Control1020008Caption; GetCurrencyCaptionDesc("Posted Bank Deposit Header"."Currency Code"))
                {
                }
                column(Control1020012Caption; GetCurrencyCaptionCode("Posted Bank Deposit Header"."Currency Code"))
                {
                }
                column(Posted_Bank_Deposit_Line__Account_Type_Caption; "Posted Bank Deposit Line".FieldCaption("Account Type"))
                {
                }
                column(Posted_Bank_Deposit_Line__Account_No__Caption; "Posted Bank Deposit Line".FieldCaption("Account No."))
                {
                }
                column(Posted_Bank_Deposit_Line__Document_Date_Caption; "Posted Bank Deposit Line".FieldCaption("Document Date"))
                {
                }
                column(Posted_Bank_Deposit_Line__Document_Type_Caption; "Posted Bank Deposit Line".FieldCaption("Document Type"))
                {
                }
                column(Posted_Bank_Deposit_Line__Document_No__Caption; "Posted Bank Deposit Line".FieldCaption("Document No."))
                {
                }
                column(Posted_Bank_Deposit_Line_AmountCaption; "Posted Bank Deposit Line".FieldCaption(Amount))
                {
                }
                column(AccountNameCaption; AccountNameCaptionLbl)
                {
                }
                column(Posted_Bank_Deposit_Line_DescriptionCaption; "Posted Bank Deposit Line".FieldCaption(Description))
                {
                }
                dataitem("Posted Bank Deposit Line"; "Posted Bank Deposit Line")
                {
                    DataItemLink = "Bank Deposit No." = FIELD("No.");
                    DataItemLinkReference = "Posted Bank Deposit Header";
                    DataItemTableView = SORTING("Bank Deposit No.", "Line No.");
                    column(Posted_Bank_Deposit_Line__Account_Type_; "Account Type")
                    {
                    }
                    column(Posted_Bank_Deposit_Line__Account_No__; "Account No.")
                    {
                    }
                    column(Posted_Bank_Deposit_Line__Document_Date_; "Document Date")
                    {
                    }
                    column(Posted_Bank_Deposit_Line__Document_Type_; "Document Type")
                    {
                    }
                    column(Posted_Bank_Deposit_Line__Document_No__; "Document No.")
                    {
                    }
                    column(Posted_Bank_Deposit_Line_Amount; Amount)
                    {
                    }
                    column(AccountName; AccountName)
                    {
                    }
                    column(Posted_Bank_Deposit_Line_Description; Description)
                    {
                    }
                    column(Posted_Bank_Deposit_Line_Amount_Control1020042; Amount)
                    {
                    }
                    column(Bank_Deposit_No__Posted_Bank_Deposit_Header__FIELDCAPTION__Bank_Account_No__Posted_Bank_Deposit_Header_Bank_Account_No__; StrSubstNo(TotalForBankDepositTxt, "Bank Deposit No.", "Posted Bank Deposit Header".FieldCaption("Bank Account No."), "Posted Bank Deposit Header"."Bank Account No."))
                    {
                    }
                    column(Posted_Bank_Deposit_Line_Bank_Deposit_No_; "Bank Deposit No.")
                    {
                    }
                    column(Posted_Bank_Deposit_Line_Line_No_; "Line No.")
                    {
                    }
                    dataitem(CustApplication; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(TempAppliedCustLedgerEntry__Document_Date_; TempAppliedCustLedgerEntry."Document Date")
                        {
                        }
                        column(TempAppliedCustLedgerEntry__Document_Type_; TempAppliedCustLedgerEntry."Document Type")
                        {
                        }
                        column(TempAppliedCustLedgerEntry__Document_No__; TempAppliedCustLedgerEntry."Document No.")
                        {
                        }
                        column(TempAppliedCustLedgerEntry__Original_Amount_; TempAppliedCustLedgerEntry."Original Amount")
                        {
                        }
                        column(AmountApplied; AmountApplied)
                        {
                        }
                        column(TempAppliedCustLedgerEntry_Open; Format(TempAppliedCustLedgerEntry.Open))
                        {
                        }
                        column(STRSUBSTNO_Text004__Posted_Bank_Deposit_Line___Document_Type___Posted_Bank_Deposit_Line___Document_No___; StrSubstNo(TotalApplicationTxt, "Posted Bank Deposit Line"."Document Type", "Posted Bank Deposit Line"."Document No."))
                        {
                        }
                        column(TotalAmountApplied; TotalAmountApplied)
                        {
                        }
                        column(CustApplication_Number; Number)
                        {
                        }
                        column(Applied_ToCaption; Applied_ToCaptionLbl)
                        {
                        }
                        column(TempAppliedCustLedgerEntry__Original_Amount_Caption; TempAppliedCustLedgerEntry__Original_Amount_CaptionLbl)
                        {
                        }
                        column(AmountAppliedCaption; AmountAppliedCaptionLbl)
                        {
                        }
                        column(Currency_CodeCaption_Control1020024; Currency_CodeCaption_Control1020024Lbl)
                        {
                        }
                        column(TempAppliedCustLedgerEntry_OpenCaption; TempAppliedCustLedgerEntry_OpenCaptionLbl)
                        {
                        }
                        column(Control1020023Caption; CaptionClassTranslate(GetCurrencyCaptionCode(TempAppliedCustLedgerEntry."Currency Code")))
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then
                                TempAppliedCustLedgerEntry.Find('-')
                            else
                                TempAppliedCustLedgerEntry.Next();
                            TempAppliedCustLedgerEntry.CalcFields("Original Amount");
                            AmountApplied := TempAppliedCustLedgerEntry."Amount to Apply";
                            TotalAmountApplied := TotalAmountApplied + AmountApplied;
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not PrintApplications or
                               ("Posted Bank Deposit Line"."Account Type" <> "Posted Bank Deposit Line"."Account Type"::Customer)
                            then
                                CurrReport.Break();
                            SetRange(Number, 1, TempAppliedCustLedgerEntry.Count);
                            TempAppliedCustLedgerEntry.SetCurrentKey("Customer No.", "Posting Date");
                            TotalAmountApplied := 0;
                        end;
                    }
                    dataitem(VendApplication; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(TempAppliedVendorLedgerEntry__Document_Date_; TempAppliedVendorLedgerEntry."Document Date")
                        {
                        }
                        column(TempAppliedVendorLedgerEntry__Document_Type_; TempAppliedVendorLedgerEntry."Document Type")
                        {
                        }
                        column(TempAppliedVendorLedgerEntry__Document_No__; TempAppliedVendorLedgerEntry."Document No.")
                        {
                        }
                        column(TempAppliedVendorLedgerEntry__Original_Amount_; TempAppliedVendorLedgerEntry."Original Amount")
                        {
                        }
                        column(AmountApplied_Control1020060; AmountApplied)
                        {
                        }
                        column(TempAppliedVendorLedgerEntry_Open; Format(TempAppliedVendorLedgerEntry.Open))
                        {
                        }
                        column(STRSUBSTNO_Text004__Posted_Bank_Deposit_Line___Document_Type___Posted_Bank_Deposit_Line___Document_No____Control1020061; StrSubstNo(TotalApplicationTxt, "Posted Bank Deposit Line"."Document Type", "Posted Bank Deposit Line"."Document No."))
                        {
                        }
                        column(TotalAmountApplied_Control1020062; TotalAmountApplied)
                        {
                        }
                        column(VendApplication_Number; Number)
                        {
                        }
                        column(Applied_ToCaption_Control1020036; Applied_ToCaption_Control1020036Lbl)
                        {
                        }
                        column(Currency_CodeCaption_Control1020037; Currency_CodeCaption_Control1020037Lbl)
                        {
                        }
                        column(TempAppliedVendorLedgerEntry__Original_Amount_Caption; TempAppliedVendorLedgerEntry__Original_Amount_CaptionLbl)
                        {
                        }
                        column(AmountApplied_Control1020060Caption; AmountApplied_Control1020060CaptionLbl)
                        {
                        }
                        column(TempAppliedVendorLedgerEntry_OpenCaption; TempAppliedVendorLedgerEntry_OpenCaptionLbl)
                        {
                        }
                        column(Control1020058Caption; CaptionClassTranslate(GetCurrencyCaptionCode(TempAppliedVendorLedgerEntry."Currency Code")))
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then
                                TempAppliedVendorLedgerEntry.Find('-')
                            else
                                TempAppliedVendorLedgerEntry.Next();
                            TempAppliedVendorLedgerEntry.CalcFields("Original Amount");
                            AmountApplied := TempAppliedVendorLedgerEntry."Amount to Apply";
                            TotalAmountApplied := TotalAmountApplied + AmountApplied;
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not PrintApplications or
                               ("Posted Bank Deposit Line"."Account Type" <> "Posted Bank Deposit Line"."Account Type"::Vendor)
                            then
                                CurrReport.Break();
                            SetRange(Number, 1, TempAppliedVendorLedgerEntry.Count);
                            TempAppliedVendorLedgerEntry.SetCurrentKey("Vendor No.", "Posting Date");
                            TotalAmountApplied := 0;
                        end;
                    }

                    trigger OnAfterGetRecord()
                    var
                        TempTempAppliedCustLedgerEntry: Record "Cust. Ledger Entry" temporary;
                        TempTempAppliedVendorLedgerEntry: Record "Vendor Ledger Entry" temporary;
                    begin
                        case "Account Type" of
                            "Account Type"::"G/L Account":
                                begin
                                    if GLAccount.Get("Account No.") then
                                        AccountName := GLAccount.Name
                                    else
                                        AccountName := StrSubstNo(InvalidAccountTxt, GLAccount.TableCaption);
                                    if Description = AccountName then
                                        Description := '';
                                end;
                            "Account Type"::Customer:
                                begin
                                    if Customer.Get("Account No.") then
                                        AccountName := Customer.Name
                                    else
                                        AccountName := StrSubstNo(InvalidAccountTxt, Customer.TableCaption);
                                    if Description = AccountName then
                                        Description := '';
                                end;
                            "Account Type"::Vendor:
                                begin
                                    if Vendor.Get("Account No.") then
                                        AccountName := Vendor.Name
                                    else
                                        AccountName := StrSubstNo(InvalidAccountTxt, Vendor.TableCaption);
                                    if Description = AccountName then
                                        Description := '';
                                end;
                            "Account Type"::"Bank Account":
                                begin
                                    if BankAccount2.Get("Account No.") then
                                        AccountName := BankAccount2.Name
                                    else
                                        AccountName := StrSubstNo(InvalidAccountTxt, BankAccount2.TableCaption);
                                    if Description = AccountName then
                                        Description := '';
                                end;
                        end;

                        if PrintApplications then
                            case "Account Type" of
                                "Account Type"::Customer:
                                    begin
                                        TempAppliedCustLedgerEntry.DeleteAll();
                                        FilterDepositCustLedgerEntry("Posted Bank Deposit Line", CustLedgerEntry);
                                        if CustLedgerEntry.FindSet() then
                                            repeat
                                                EntryApplicationMgt.GetAppliedCustEntries(TempTempAppliedCustLedgerEntry, CustLedgerEntry, false);
                                                if TempTempAppliedCustLedgerEntry.FindSet() then
                                                    repeat
                                                        TempAppliedCustLedgerEntry := TempTempAppliedCustLedgerEntry;
                                                        TempAppliedCustLedgerEntry.Insert();
                                                    until TempTempAppliedCustLedgerEntry.Next() = 0;
                                            until CustLedgerEntry.Next() = 0;
                                    end;
                                "Account Type"::Vendor:
                                    begin
                                        TempAppliedVendorLedgerEntry.DeleteAll();
                                        FilterDepositVendorLedgerEntry("Posted Bank Deposit Line", VendorLedgerEntry);
                                        if VendorLedgerEntry.FindSet() then
                                            repeat
                                                EntryApplicationMgt.GetAppliedVendEntries(TempTempAppliedVendorLedgerEntry, VendorLedgerEntry, false);
                                                if TempTempAppliedVendorLedgerEntry.FindSet() then
                                                    repeat
                                                        TempAppliedVendorLedgerEntry := TempTempAppliedVendorLedgerEntry;
                                                        TempAppliedVendorLedgerEntry.Insert();
                                                    until TempTempAppliedVendorLedgerEntry.Next() = 0;
                                            until VendorLedgerEntry.Next() = 0;
                                    end;
                            end;
                    end;

                    trigger OnPostDataItem()
                    begin
                        if not CurrReport.Preview then
                            BankDepositPrinted.Run("Posted Bank Deposit Header");
                    end;
                }
            }

            trigger OnAfterGetRecord()
            begin
                CurrReport.Language := Language.GetLanguageIdOrDefault("Language Code");

                if not BankAccount.Get("Bank Account No.") then
                    BankAccount.Name := StrSubstNo(InvalidAccountTxt, BankAccount.TableCaption);

                if "Currency Code" = '' then begin
                    if GeneralLedgerSetup."LCY Code" = '' then
                        Currency.Description := CopyStr(GeneralLedgerSetup."Local Currency Description", 1, MaxStrLen(Currency.Description))
                    else
                        if not Currency.Get(GeneralLedgerSetup."LCY Code") then
                            Currency.Description := StrSubstNo(InvalidAccountTxt, FieldCaption("Currency Code"));
                end else
                    if not Currency.Get("Currency Code") then
                        Currency.Description := StrSubstNo(InvalidAccountTxt, FieldCaption("Currency Code"));
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
                    field(ShowApplications; PrintApplications)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Applications';
                        ToolTip = 'Specifies if application information is included in the report.';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
        GeneralLedgerSetup.Get();
    end;

    var
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        BankAccount: Record "Bank Account";
        Currency: Record Currency;
        Customer: Record Customer;
        Vendor: Record Vendor;
        GLAccount: Record "G/L Account";
        BankAccount2: Record "Bank Account";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        TempAppliedCustLedgerEntry: Record "Cust. Ledger Entry" temporary;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        TempAppliedVendorLedgerEntry: Record "Vendor Ledger Entry" temporary;
        Language: Codeunit Language;
        BankDepositPrinted: Codeunit "Bank Deposit-Printed";
        EntryApplicationMgt: Codeunit "Entry Application Mgt";
        AccountName: Text[100];
        DepositDescriptionTxt: Label 'Bank Deposit %1', Comment = '%1 - deposit number';
        InvalidAccountTxt: Label '<Invalid %1>', Comment = '%1 - G/L account number';
        TotalForBankDepositTxt: Label 'Total for Bank Deposit %1, into %2 %3', Comment = '%1 - Bank deposit number, %2 - field caption Bank Account No, %3 - bank account number';
        PrintApplications: Boolean;
        TotalApplicationTxt: Label 'Total Application of %1 %2', Comment = '%1 - document type, %2 - document number';
        AmountApplied: Decimal;
        TotalAmountApplied: Decimal;
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Deposited_InCaptionLbl: Label 'Deposited In';
        Posted_Bank_Deposit_Header___Bank_Account_No__CaptionLbl: Label 'Bank Account No.';
        Currency_CodeCaptionLbl: Label 'Currency Code';
        Posted_Bank_Deposit_Header___Document_Date_CaptionLbl: Label 'Document Date';
        Posted_Bank_Deposit_Header___Posting_Date_CaptionLbl: Label 'Posting Date';
        Posted_Bank_Deposit_Header___Total_Deposit_Amount_CaptionLbl: Label 'Total Deposit Amount';
        Posted_Bank_Deposit_Header___Posting_Description_CaptionLbl: Label 'Posting Description';
        AccountNameCaptionLbl: Label 'Account Name';
        Applied_ToCaptionLbl: Label 'Applied To';
        TempAppliedCustLedgerEntry__Original_Amount_CaptionLbl: Label 'Original Amount';
        AmountAppliedCaptionLbl: Label 'Amount Applied';
        Currency_CodeCaption_Control1020024Lbl: Label 'Currency Code';
        TempAppliedCustLedgerEntry_OpenCaptionLbl: Label 'Remains Open';
        Applied_ToCaption_Control1020036Lbl: Label 'Applied To';
        Currency_CodeCaption_Control1020037Lbl: Label 'Currency Code';
        TempAppliedVendorLedgerEntry__Original_Amount_CaptionLbl: Label 'Original Amount';
        AmountApplied_Control1020060CaptionLbl: Label 'Amount Applied';
        TempAppliedVendorLedgerEntry_OpenCaptionLbl: Label 'Remains Open';

    local procedure GetCurrencyRecord(var Currency: Record Currency; CurrencyCode: Code[10])
    begin
        if CurrencyCode = '' then begin
            Clear(Currency);
            Currency.Description := CopyStr(GeneralLedgerSetup."Local Currency Description", 1, MaxStrLen(Currency.Description));
            Currency."Amount Rounding Precision" := GeneralLedgerSetup."Amount Rounding Precision";
        end else
            if Currency.Code <> CurrencyCode then
                Currency.Get(CurrencyCode);
    end;

    local procedure GetCurrencyCaptionCode(CurrencyCode: Code[10]): Text[80]
    begin
        GetCurrencyRecord(Currency, CurrencyCode);
        if Currency.Code = '' then
            exit(GeneralLedgerSetup."LCY Code");
        exit(Currency.Code);
    end;

    local procedure GetCurrencyCaptionDesc(CurrencyCode: Code[10]): Text[80]
    begin
        GetCurrencyRecord(Currency, CurrencyCode);
        if (Format(Currency.Code) = Format(Currency.Description)) then
            exit('');
        exit(Currency.Description);
    end;

    procedure FilterDepositCustLedgerEntry(PostedBankDepositLine: Record "Posted Bank Deposit Line"; var DepositCustLedgerEntry: Record "Cust. Ledger Entry")
    var
        FromEntryNo: Integer;
        ToEntryNo: Integer;
    begin
        PostedBankDepositLine.Reset();
        PostedBankDepositLine.SetCurrentKey("Bank Deposit No.", "Line No.");
        PostedBankDepositLine.SetRange("Bank Deposit No.", PostedBankDepositLine."Bank Deposit No.");
        PostedBankDepositLine.SetRange("Line No.", PostedBankDepositLine."Line No.");
        if PostedBankDepositLine.FindFirst() then
            FromEntryNo := PostedBankDepositLine."Entry No.";

        DepositCustLedgerEntry.Get(PostedBankDepositLine."Entry No.");
        PostedBankDepositLine.Reset();
        PostedBankDepositLine.SetCurrentKey("Bank Deposit No.", "Line No.");
        PostedBankDepositLine.SetRange("Bank Deposit No.", PostedBankDepositLine."Bank Deposit No.");
        PostedBankDepositLine.SetFilter("Line No.", '>%1', PostedBankDepositLine."Line No.");
        if PostedBankDepositLine.FindFirst() then begin
            DepositCustLedgerEntry.Reset();
            ToEntryNo := PostedBankDepositLine."Entry No.";
            DepositCustLedgerEntry.SetRange("Transaction No.", DepositCustLedgerEntry."Transaction No.");
            DepositCustLedgerEntry.SetFilter("Entry No.", '%1..%2', FromEntryNo, ToEntryNo - 1);
        end else begin
            DepositCustLedgerEntry.Reset();
            DepositCustLedgerEntry.SetFilter("Entry No.", '>=%1', FromEntryNo);
            DepositCustLedgerEntry.SetRange("Transaction No.", DepositCustLedgerEntry."Transaction No.");
            DepositCustLedgerEntry.SetRange("External Document No.", PostedBankDepositLine."Bank Deposit No.");
        end;
    end;

    procedure FilterDepositVendorLedgerEntry(PostedBankDepositLine: Record "Posted Bank Deposit Line"; var DepositVendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        FromEntryNo: Integer;
        ToEntryNo: Integer;
    begin
        PostedBankDepositLine.Reset();
        PostedBankDepositLine.SetCurrentKey("Bank Deposit No.", "Line No.");
        PostedBankDepositLine.SetRange("Bank Deposit No.", PostedBankDepositLine."Bank Deposit No.");
        PostedBankDepositLine.SetRange("Line No.", PostedBankDepositLine."Line No.");
        if PostedBankDepositLine.FindFirst() then
            FromEntryNo := PostedBankDepositLine."Entry No.";

        DepositVendorLedgerEntry.Get(PostedBankDepositLine."Entry No.");
        PostedBankDepositLine.Reset();
        PostedBankDepositLine.SetCurrentKey("Bank Deposit No.", "Line No.");
        PostedBankDepositLine.SetRange("Bank Deposit No.", PostedBankDepositLine."Bank Deposit No.");
        PostedBankDepositLine.SetFilter("Line No.", '>%1', PostedBankDepositLine."Line No.");
        if PostedBankDepositLine.FindFirst() then begin
            DepositVendorLedgerEntry.Reset();
            ToEntryNo := PostedBankDepositLine."Entry No.";
            DepositVendorLedgerEntry.SetRange("Transaction No.", DepositVendorLedgerEntry."Transaction No.");
            DepositVendorLedgerEntry.SetFilter("Entry No.", '%1..%2', FromEntryNo, ToEntryNo - 1);
        end else begin
            DepositVendorLedgerEntry.Reset();
            DepositVendorLedgerEntry.SetFilter("Entry No.", '>=%1', FromEntryNo);
            DepositVendorLedgerEntry.SetRange("Transaction No.", DepositVendorLedgerEntry."Transaction No.");
            DepositVendorLedgerEntry.SetRange("External Document No.", PostedBankDepositLine."Bank Deposit No.");
        end;
    end;
}

