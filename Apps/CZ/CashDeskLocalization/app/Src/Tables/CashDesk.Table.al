// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.EServices.OnlineMap;
using Microsoft.Finance;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Comment;
using Microsoft.Foundation.NoSeries;
using Microsoft.HumanResources.Employee;
using Microsoft.Inventory.Location;
using Microsoft.Utilities;
using System.EMail;
using System.Globalization;
using System.Security.AccessControl;
using System.Security.User;
using System.Utilities;

#pragma warning disable AA0232
table 11744 "Cash Desk CZP"
{
    Caption = 'Cash Desk';
    DataClassification = CustomerContent;
    DrillDownPageID = "Cash Desk List CZP";
    LookupPageID = "Cash Desk List CZP";
    Permissions = tabledata "Bank Account Ledger Entry" = r;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    GeneralLedgerSetup.Get();
                    NoSeriesManagement.TestManual(GeneralLedgerSetup."Cash Desk Nos. CZP");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Name; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Name';

            trigger OnValidate()
            begin
                if ("Search Name" = UpperCase(xRec.Name)) or ("Search Name" = '') then
                    "Search Name" := Name;
            end;
        }
        field(3; "Search Name"; Code[100])
        {
            Caption = 'Search Name';
            DataClassification = CustomerContent;
        }
        field(4; "Name 2"; Text[50])
        {
            Caption = 'Name 2';
            DataClassification = CustomerContent;
        }
        field(5; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(6; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(7; City; Text[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
            TableRelation = if ("Country/Region Code" = const('')) "Post Code".City else
            if ("Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                CityTxt, CountyTxt : Text;
            begin
                CityTxt := City;
                CountyTxt := County;
                PostCode.LookupPostCode(CityTxt, "Post Code", CountyTxt, "Country/Region Code");
                City := CopyStr(CityTxt, 1, MaxStrLen(City));
                County := CopyStr(CountyTxt, 1, MaxStrLen(City));
            end;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(8; Contact; Text[100])
        {
            Caption = 'Contact';
            DataClassification = CustomerContent;
        }
        field(9; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
        }
        field(16; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(17; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(21; "Bank Acc. Posting Group"; Code[20])
        {
            Caption = 'Bank Acc. Posting Group';
            TableRelation = "Bank Account Posting Group";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Bank Acc. Posting Group" <> xRec."Bank Acc. Posting Group" then
                    CheckOpenBankAccLedgerEntries();
            end;
        }
        field(22; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Currency Code" = xRec."Currency Code" then
                    exit;

                TestZeroBalance();
                if not BankAccountLedgerEntry.SetCurrentKey("Bank Account No.", Open) then
                    BankAccountLedgerEntry.SetCurrentKey("Bank Account No.");
                BankAccountLedgerEntry.SetRange("Bank Account No.", "No.");
                BankAccountLedgerEntry.SetRange(Open, true);
                if not BankAccountLedgerEntry.IsEmpty() then
                    Error(OpenLedgerEntriesErr, FieldCaption("Currency Code"));
                if "Currency Code" = '' then
                    "Exclude from Exch. Rate Adj." := false;
            end;
        }
        field(24; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
            DataClassification = CustomerContent;
        }
        field(35; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                CityTxt, CountyTxt : Text;
            begin
                CityTxt := City;
                CountyTxt := County;
                PostCode.CheckClearPostCodeCityCounty(CityTxt, "Post Code", CountyTxt, "Country/Region Code", xRec."Country/Region Code");
                City := CopyStr(CityTxt, 1, MaxStrLen(City));
                County := CopyStr(CountyTxt, 1, MaxStrLen(City));
            end;
        }
        field(41; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
            TableRelation = if ("Country/Region Code" = const('')) "Post Code" else
            if ("Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                CityTxt, CountyTxt : Text;
            begin
                CityTxt := City;
                CountyTxt := County;
                PostCode.LookupPostCode(CityTxt, "Post Code", CountyTxt, "Country/Region Code");
                City := CopyStr(CityTxt, 1, MaxStrLen(City));
                County := CopyStr(CountyTxt, 1, MaxStrLen(City));
            end;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(42; County; Text[30])
        {
            CaptionClass = '5,1,' + "Country/Region Code";
            Caption = 'County';
            DataClassification = CustomerContent;
        }
        field(45; "E-Mail"; Text[80])
        {
            Caption = 'Email';
            ExtendedDatatype = EMail;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
                EMail: Text;
            begin
                EMail := "E-Mail";
                MailManagement.ValidateEmailAddressField(EMail);
                "E-Mail" := CopyStr(EMail, 1, MaxStrLen("E-Mail"));
            end;
        }
        field(48; Comment; Boolean)
        {
            CalcFormula = Exist("Comment Line" where("Table Name" = const("Cash Desk CZP"), "No." = field("No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(49; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(55; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(56; "Global Dimension 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(57; "Global Dimension 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(58; Balance; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("Bank Account Ledger Entry".Amount where("Bank Account No." = field("No."),
                                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter")));
            Caption = 'Balance';
            Editable = false;
            FieldClass = FlowField;
        }
        field(59; "Balance (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Bank Account Ledger Entry"."Amount (LCY)" where("Bank Account No." = field("No."),
                                                                                "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                                "Global Dimension 2 Code" = field("Global Dimension 2 Filter")));
            Caption = 'Balance (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(60; "Net Change"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("Bank Account Ledger Entry".Amount where("Bank Account No." = field("No."),
                                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                        "Posting Date" = field("Date Filter")));
            Caption = 'Net Change';
            Editable = false;
            FieldClass = FlowField;
        }
        field(61; "Net Change (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Bank Account Ledger Entry"."Amount (LCY)" where("Bank Account No." = field("No."),
                                                                                "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                                "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                                "Posting Date" = field("Date Filter")));
            Caption = 'Net Change (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(95; "Balance at Date"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("Bank Account Ledger Entry".Amount where("Bank Account No." = field("No."),
                                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                        "Posting Date" = field(UPPERLIMIT("Date Filter"))));
            Caption = 'Balance at Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(96; "Balance at Date (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Bank Account Ledger Entry"."Amount (LCY)" where("Bank Account No." = field("No."),
                                                                                "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                                "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                                "Posting Date" = field(UPPERLIMIT("Date Filter"))));
            Caption = 'Balance at Date (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(97; "Debit Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum("Bank Account Ledger Entry"."Debit Amount" where("Bank Account No." = field("No."),
                                                                                "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                                "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                                "Posting Date" = field("Date Filter")));
            Caption = 'Debit Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(98; "Credit Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum("Bank Account Ledger Entry"."Credit Amount" where("Bank Account No." = field("No."),
                                                                                 "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                                 "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                                 "Posting Date" = field("Date Filter")));
            Caption = 'Credit Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(99; "Debit Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum("Bank Account Ledger Entry"."Debit Amount (LCY)" where("Bank Account No." = field("No."),
                                                                                      "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                                      "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                                      "Posting Date" = field("Date Filter")));
            Caption = 'Debit Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100; "Credit Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum("Bank Account Ledger Entry"."Credit Amount (LCY)" where("Bank Account No." = field("No."),
                                                                                       "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                                                       "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                                                       "Posting Date" = field("Date Filter")));
            Caption = 'Credit Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(107; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(120; "Min. Balance"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Min. Balance';
            DataClassification = CustomerContent;
        }
        field(121; "Min. Balance Checking"; Option)
        {
            Caption = 'Min. Balance Checking';
            OptionCaption = 'No Checking,Warning,Blocking';
            OptionMembers = "No Checking",Warning,Blocking;
            DataClassification = CustomerContent;
        }
        field(122; "Max. Balance"; Decimal)
        {
            Caption = 'Max. Balance';
            DataClassification = CustomerContent;
        }
        field(123; "Max. Balance Checking"; Option)
        {
            Caption = 'Max. Balance Checking';
            OptionCaption = 'No Checking,Warning,Blocking';
            OptionMembers = "No Checking",Warning,Blocking;
            DataClassification = CustomerContent;
        }
        field(232; "Allow VAT Difference"; Boolean)
        {
            Caption = 'Allow VAT Difference';
            DataClassification = CustomerContent;
        }
        field(233; "Payed To/By Checking"; Option)
        {
            Caption = 'Payed To/By Checking';
            OptionCaption = 'No Checking,Warning,Blocking';
            OptionMembers = "No Checking",Warning,Blocking;
            DataClassification = CustomerContent;
        }
        field(234; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
            DataClassification = CustomerContent;
        }
        field(236; "Amounts Including VAT"; Boolean)
        {
            Caption = 'Amounts Including VAT';
            DataClassification = CustomerContent;
        }
        field(237; "Confirm Inserting of Document"; Boolean)
        {
            Caption = 'Confirm Inserting of Document';
            DataClassification = CustomerContent;
        }
        field(238; "Debit Rounding Account"; Code[20])
        {
            Caption = 'Debit Rounding Account';
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting));
            DataClassification = CustomerContent;
        }
        field(239; "Credit Rounding Account"; Code[20])
        {
            Caption = 'Credit Rounding Account';
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting));
            DataClassification = CustomerContent;
        }
        field(240; "Rounding Method Code"; Code[10])
        {
            Caption = 'Rounding Method Code';
            TableRelation = "Rounding Method";
            DataClassification = CustomerContent;
        }
        field(241; "Responsibility ID (Release)"; Code[50])
        {
            Caption = 'Responsibility ID (Release)';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("Responsibility ID (Release)");
            end;
        }
        field(242; "Responsibility ID (Post)"; Code[50])
        {
            Caption = 'Responsibility ID (Post)';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("Responsibility ID (Post)");
            end;
        }
        field(243; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center";
            DataClassification = CustomerContent;
        }
        field(260; "Amount Rounding Precision"; Decimal)
        {
            Caption = 'Amount Rounding Precision';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            InitValue = 1;
            MinValue = 0;
        }
        field(265; "Cash Document Receipt Nos."; Code[20])
        {
            Caption = 'Cash Document Receipt Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(266; "Cash Document Withdrawal Nos."; Code[20])
        {
            Caption = 'Cash Document Withdrawal Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(267; "Cash Receipt Limit"; Decimal)
        {
            Caption = 'Cash Receipt Limit';
            DataClassification = CustomerContent;
        }
        field(268; "Cash Withdrawal Limit"; Decimal)
        {
            Caption = 'Cash Withdrawal Limit';
            DataClassification = CustomerContent;
        }
        field(269; "Exclude from Exch. Rate Adj."; Boolean)
        {
            Caption = 'Exclude from Exch. Rate Adj.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Exclude from Exch. Rate Adj." then begin
                    TestField("Currency Code");
                    if not ConfirmManagement.GetResponseOrDefault(ExcludeEntriesQst, false) then
                        "Exclude from Exch. Rate Adj." := xRec."Exclude from Exch. Rate Adj."
                end;
            end;
        }
        field(270; "Cashier No."; Code[20])
        {
            Caption = 'Cashier No.';
            TableRelation = Employee;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Search Name")
        {
        }
        key(Key3; "Bank Acc. Posting Group")
        {
        }
        key(Key4; "Currency Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Name, "Currency Code")
        {
        }
        fieldgroup(Brick; "No.", Name, "Currency Code")
        {
        }
    }

    trigger OnDelete()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDeskUserCZP: Record "Cash Desk User CZP";
        CashDeskEventCZP: Record "Cash Desk Event CZP";
        EETCashRegisterCZL: Record "EET Cash Register CZL";
    begin
        TestZeroBalance();
        CheckOpenBankAccLedgerEntries();

        CashDocumentHeaderCZP.SetRange("Cash Desk No.", "No.");
        if not CashDocumentHeaderCZP.IsEmpty() then
            Error(CannotDeleteErr, TableCaption(), "No.", CashDocumentHeaderCZP.TableCaption);

        CommentLine.SetRange("Table Name", CommentLine."Table Name"::"Cash Desk CZP");
        CommentLine.SetRange("No.", "No.");
        CommentLine.DeleteAll();
        DimensionManagement.DeleteDefaultDim(Database::"Cash Desk CZP", "No.");
        CashDeskUserCZP.SetRange("Cash Desk No.", "No.");
        CashDeskUserCZP.DeleteAll();
        CashDeskEventCZP.SetRange("Cash Desk No.", "No.");
        CashDeskEventCZP.DeleteAll();

        if BankAccount.Get("No.") then begin
            BankAccount.TestField("Account Type CZP", BankAccount."Account Type CZP"::"Cash Desk");
            MoveEntries.MoveBankAccEntries(BankAccount);
            BankAccount.Delete(false);
        end;

        if EETCashRegisterCZL.FindByCashRegisterNo(EETCashRegisterCZL."Cash Register Type"::"Cash Desk", "No.") then begin
            EETCashRegisterCZL.Validate("Cash Register Type", EETCashRegisterCZL."Cash Register Type"::Default);
            EETCashRegisterCZL.Validate("Cash Register No.", '');
            EETCashRegisterCZL.Modify();
        end;
    end;

    trigger OnInsert()
    begin
        if "No." = '' then begin
            GeneralLedgerSetup.Get();
            GeneralLedgerSetup.TestField("Cash Desk Nos. CZP");
            NoSeriesManagement.InitSeries(GeneralLedgerSetup."Cash Desk Nos. CZP", xRec."No. Series", 0D, "No.", "No. Series");
        end;
        DimensionManagement.UpdateDefaultDim(Database::"Cash Desk CZP", "No.", "Global Dimension 1 Code", "Global Dimension 2 Code");

        if not BankAccount.Get("No.") then begin
            BankAccount.Init();
            BankAccount."No." := "No.";
            BankAccount."No. Series" := "No. Series";
            BankAccount."Account Type CZP" := BankAccount."Account Type CZP"::"Cash Desk";
            BankAccount.Name := Name;
            BankAccount."Search Name" := "Search Name";
            BankAccount."Bank Acc. Posting Group" := "Bank Acc. Posting Group";
            BankAccount."Global Dimension 1 Code" := "Global Dimension 1 Code";
            BankAccount."Global Dimension 2 Code" := "Global Dimension 2 Code";
            BankAccount."Currency Code" := "Currency Code";
            BankAccount."Excl. from Exch. Rate Adj. CZL" := "Exclude from Exch. Rate Adj.";
            BankAccount."Last Date Modified" := Today();
            DimensionManagement.UpdateDefaultDim(Database::"Bank Account", "No.", "Global Dimension 1 Code", "Global Dimension 2 Code");
            BankAccount.Insert(false);
        end;
    end;

    trigger OnModify()
    begin
        if not BankAccount.Get("No.") then begin
            BankAccount.Init();
            BankAccount."No." := "No.";
            BankAccount."No. Series" := "No. Series";
            BankAccount."Account Type CZP" := BankAccount."Account Type CZP"::"Cash Desk";
            BankAccount.Insert(false);
        end;
        BankAccount.TestField("Account Type CZP", BankAccount."Account Type CZP"::"Cash Desk");
        BankAccount.Name := Name;
        BankAccount."Search Name" := "Search Name";
        BankAccount."Bank Acc. Posting Group" := "Bank Acc. Posting Group";
        BankAccount.Validate("Global Dimension 1 Code", "Global Dimension 1 Code");
        BankAccount.Validate("Global Dimension 2 Code", "Global Dimension 2 Code");
        BankAccount."Currency Code" := "Currency Code";
        BankAccount."Excl. from Exch. Rate Adj. CZL" := "Exclude from Exch. Rate Adj.";
        BankAccount."Last Date Modified" := Today();
        BankAccount.Modify(false);
    end;

    trigger OnRename()
    begin
        DimensionManagement.RenameDefaultDim(Database::"Cash Desk CZP", xRec."No.", "No.");
        if BankAccount.Get(xRec."No.") then
            BankAccount.Rename("No.");
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CashDeskCZP: Record "Cash Desk CZP";
        BankAccount: Record "Bank Account";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        CommentLine: Record "Comment Line";
        PostCode: Record "Post Code";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        ConfirmManagement: Codeunit "Confirm Management";
        MoveEntries: Codeunit MoveEntries;
        DimensionManagement: Codeunit DimensionManagement;
        OpenLedgerEntriesErr: Label 'You cannot change %1 because there are one or more open ledger entries for this bank account.', Comment = '%1 = Currenc Code FieldCaption';
        OnlineMapSetupErr: Label 'Before you can use Online Map, you must fill in the Online Map Setup window.\See Setting Up Online Map in Help.';
        ExcludeEntriesQst: Label 'All entries will be excluded from Exchange Rates Adjustment. Do you want to continue?';
        CannotDeleteErr: Label 'You cannot delete %1 %2, beacause %3 exist.', Comment = '%1 = TableCaption, %2 = No., %3 = Cash Doc. Header TableCaption';
        CurrExchRateIsEmptyErr: Label 'There is no Currency Exchange Rate within the filter. Filters: %1.', Comment = '%1 = GetFilters';

    procedure AssistEdit(OldCashDeskCZP: Record "Cash Desk CZP"): Boolean
    begin
        CashDeskCZP := Rec;
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.TestField("Cash Desk Nos. CZP");
        if NoSeriesManagement.SelectSeries(GeneralLedgerSetup."Cash Desk Nos. CZP", OldCashDeskCZP."No. Series", CashDeskCZP."No. Series") then begin
            NoSeriesManagement.SetSeries(CashDeskCZP."No.");
            Rec := CashDeskCZP;
            exit(true);
        end;
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        OnBeforeValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);

        DimensionManagement.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        if not IsTemporary() then begin
            DimensionManagement.SaveDefaultDim(Database::"Cash Desk CZP", "No.", FieldNumber, ShortcutDimCode);
            Modify();
        end;

        OnAfterValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);
    end;

    procedure DisplayMap()
    var
        OnlineMapSetup: Record "Online Map Setup";
        OnlineMapManagement: Codeunit "Online Map Management";
    begin
        if not OnlineMapSetup.IsEmpty() then
            OnlineMapManagement.MakeSelection(Database::"Cash Desk CZP", CopyStr(GetPosition(), 1, 1000))
        else
            Message(OnlineMapSetupErr);
    end;

    procedure TestZeroBalance()
    begin
        CalcFields(Balance, "Balance (LCY)");
        TestField(Balance, 0);
        TestField("Balance (LCY)", 0);
    end;

    local procedure CheckOpenBankAccLedgerEntries()
    begin
        if BankAccount.Get("No.") then begin
            BankAccount.CalcFields(Balance, "Balance (LCY)");
            BankAccount.TestField(Balance, 0);
            BankAccount.TestField("Balance (LCY)", 0);
        end;
    end;

    procedure CalcBalance(): Decimal
    begin
        exit(CalcOpenedReceipts() + CalcOpenedWithdrawals() + CalcPostedReceipts() + CalcPostedWithdrawals());
    end;

    procedure CalcOpenedWithdrawals(): Decimal
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        exit(CalcOpenedNetChanges(CashDocumentHeaderCZP."Document Type"::Withdrawal));
    end;

    procedure CalcOpenedReceipts(): Decimal
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        exit(CalcOpenedNetChanges(CashDocumentHeaderCZP."Document Type"::Receipt));
    end;

    local procedure CalcOpenedNetChanges(CashDocumentType: Enum "Cash Document Type CZP"): Decimal
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        CopyFilter("Date Filter", CashDocumentHeaderCZP."Posting Date");
        CashDocumentHeaderCZP.SetRange("Cash Desk No.", "No.");
        CashDocumentHeaderCZP.SetRange("Document Type", CashDocumentType);
        CashDocumentHeaderCZP.SetRange(Status, CashDocumentHeaderCZP.Status::Released);
        CashDocumentHeaderCZP.CalcSums("Released Amount");

        if CashDocumentType = CashDocumentHeaderCZP."Document Type"::Withdrawal then
            exit(-CashDocumentHeaderCZP."Released Amount");

        exit(CashDocumentHeaderCZP."Released Amount");
    end;

    procedure CalcPostedWithdrawals(): Decimal
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        exit(CalcPostedNetChanges(CashDocumentHeaderCZP."Document Type"::Withdrawal));
    end;

    procedure CalcPostedReceipts(): Decimal
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        exit(CalcPostedNetChanges(CashDocumentHeaderCZP."Document Type"::Receipt));
    end;

    local procedure CalcPostedNetChanges(CashDocumentType: Enum "Cash Document Type CZP"): Decimal
    var
        PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        TotalNetChange: Decimal;
    begin
        if GetFilter("Date Filter") = '' then begin
            PostedCashDocumentLineCZP.SetRange("Cash Desk No.", "No.");
            PostedCashDocumentLineCZP.SetRange("Document Type", CashDocumentType);
            PostedCashDocumentLineCZP.CalcSums("Amount Including VAT");
            TotalNetChange += PostedCashDocumentLineCZP."Amount Including VAT";
        end else begin
            CopyFilter("Date Filter", PostedCashDocumentHdrCZP."Posting Date");
            PostedCashDocumentHdrCZP.SetRange("Cash Desk No.", "No.");
            if PostedCashDocumentHdrCZP.FindSet() then
                repeat
                    PostedCashDocumentLineCZP.SetRange("Cash Document No.", PostedCashDocumentHdrCZP."No.");
                    PostedCashDocumentLineCZP.SetRange("Cash Desk No.", "No.");
                    PostedCashDocumentLineCZP.SetRange("Document Type", CashDocumentType);
                    PostedCashDocumentLineCZP.CalcSums("Amount Including VAT");
                    TotalNetChange += PostedCashDocumentLineCZP."Amount Including VAT";
                until PostedCashDocumentHdrCZP.Next() = 0;
        end;

        if CashDocumentType = PostedCashDocumentHdrCZP."Document Type"::Withdrawal then
            exit(-TotalNetChange);

        exit(TotalNetChange);
    end;

    procedure IsInLocalCurrency(): Boolean
    begin
        if "Currency Code" = '' then
            exit(true);

        GeneralLedgerSetup.Get();
        exit("Currency Code" = GeneralLedgerSetup.GetCurrencyCode(''));
    end;

    procedure CheckCurrExchRateExist(Date: Date)
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        if IsInLocalCurrency() then
            exit;

        CurrencyExchangeRate.SetRange("Currency Code", "Currency Code");
        CurrencyExchangeRate.SetRange("Starting Date", 0D, Date);
        if CurrencyExchangeRate.IsEmpty() then
            Error(CurrExchRateIsEmptyErr, CurrencyExchangeRate.GetFilters());
    end;

    procedure IsEETCashRegister() EETCashRegister: Boolean
    var
        EETCashRegisterCZL: Record "EET Cash Register CZL";
    begin
        EETCashRegister := EETCashRegisterCZL.FindByCashRegisterNo("EET Cash Register Type CZL"::"Cash Desk", "No.");
        OnAfterIsEETCashRegister(Rec, EETCashRegister);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateShortcutDimCode(var CashDeskCZP: Record "Cash Desk CZP"; var xCashDeskCZP: Record "Cash Desk CZP"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var CashDeskCZP: Record "Cash Desk CZP"; var xCashDeskCZP: Record "Cash Desk CZP"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsEETCashRegister(CashDeskCZP: Record "Cash Desk CZP"; var EETCashRegister: Boolean)
    begin
    end;
}
