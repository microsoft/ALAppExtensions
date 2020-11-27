report 11703 "Accounting Sheets CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/AccountingSheets.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Accounting Sheets';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(CommonLabels; "Integer")
        {
            DataItemTableView = sorting(Number);
            MaxIteration = 1;
            column(NameDescCaption; NameDescCaption)
            {
            }
            column(PostingDateCaption; "Sales Invoice Header".FieldCaption("Posting Date"))
            {
            }
            column(VATDateCaption; "Sales Invoice Header".FieldCaption("VAT Date CZL"))
            {
            }
            column(DocumentDateCaption; "Sales Invoice Header".FieldCaption("Document Date"))
            {
            }
            column(DueDateCaption; "Sales Invoice Header".FieldCaption("Due Date"))
            {
            }
            column(SalesInvoiceCaption; SalesInvoiceLbl)
            {
            }
            column(CustomerCaption; CustomerLbl)
            {
            }
            column(RateCaption; RateLbl)
            {
            }
            column(CreditAmountCaption; CreditAmountLbl)
            {
            }
            column(DebitAmountCaption; DebitAmountLbl)
            {
            }
            column(GLAccountCaption; GLAccountLbl)
            {
            }
            column(DateCaption; DateLbl)
            {
            }
            column(SalesCreditMemoCaption; SalesCreditMemoLbl)
            {
            }
            column(PurchaseInvoiceCaption; PurchaseInvoiceLbl)
            {
            }
            column(VendorCaption; VendorLbl)
            {
            }
            column(ExternalNoCaption; ExternalNoLbl)
            {
            }
            column(PurchaseCreditMemoCaption; PurchaseCreditMemoLbl)
            {
            }
            column(GeneralDocumentCaption; GeneralDocumentLbl)
            {
            }
            column(FactualCorrectnessVerifiedByCaption; FactualCorrectnessVerifiedByLbl)
            {
            }
            column(PostedByCaption; PostedByLbl)
            {
            }
            column(ApprovedByCaption; ApprovedByLbl)
            {
            }
            column(FormalCorrectnessVerifiedByCaption; FormalCorrectnessVerifiedByLbl)
            {
            }
            column(LastDataItem; LastDataItem)
            {
            }
            column(SalesInvHdrExists; SalesInvHdrExists)
            {
            }
            column(SalesCrMemoHdrExists; SalesCrMemoHdrExists)
            {
            }
            column(PurchInvHdrExists; PurchInvHdrExists)
            {
            }
            column(PurchCrMemoHdrExists; PurchCrMemoHdrExists)
            {
            }
            column(GeneralDocExists; GeneralDocExists)
            {
            }
            trigger OnAfterGetRecord()
            begin
                if GroupGLAccounts then
                    NameDescCaption := GLAccountNameLbl
                else
                    NameDescCaption := DescriptionLbl;
            end;
        }
        dataitem("Sales Invoice Header"; "Sales Invoice Header")
        {
            CalcFields = Amount, "Amount Including VAT";
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Posting Date";
            column(greCompanyInfo_Name; CompanyInfo.Name)
            {
            }
            column(Sales_Invoice_Header__No; "No.")
            {
            }
            column(Sales_Invoice_Header__Sell_to_Customer_Name_; "Sell-to Customer Name")
            {
            }
            column(Sales_Invoice_Header__Due_Date_; Format("Due Date"))
            {
            }
            column(Sales_Invoice_Header_Amount; Amount)
            {
            }
            column(Amount_Including_VAT__Amount; "Amount Including VAT" - Amount)
            {
            }
            column(gdeFCYRate; FCYRate)
            {
                DecimalPlaces = 5 : 5;
            }
            column(Sales_Invoice_Header__Currency_Code_; "Currency Code")
            {
            }
            column(Sales_Invoice_Header__No_Caption; FieldCaption("No."))
            {
            }
            column(Sales_Invoice_Header_AmountCaption; FieldCaption(Amount))
            {
            }
            column(Sales_Invoice_Header__Currency_Code_Caption; FieldCaption("Currency Code"))
            {
            }
            column(SalesInvoiceHeader_PostingDate; "Posting Date")
            {
            }
            column(SalesInvoiceHeader_VATDate; "VAT Date CZL")
            {
            }
            column(SalesInvoiceHeader_DocumentDate; "Document Date")
            {
            }
            dataitem(GLEntry1; "G/L Entry")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Posting Date");

                trigger OnAfterGetRecord()
                begin
                    if UserSetup."User ID" <> "User ID" then
                        if not UserSetup.Get("User ID") then
                            UserSetup.Init();

                    BufferGLEntry(GLEntry1);
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Entry No.", 1, LastGLEntry);
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = sorting(Number) WHERE(Number = FILTER(1 ..));
                column(greTGLEntry__Credit_Amount_; TempGLEntry."Credit Amount")
                {
                }
                column(greTGLEntry__Debit_Amount_; TempGLEntry."Debit Amount")
                {
                }
                column(greTGLEntry__Global_Dimension_2_Code_; TempGLEntry."Global Dimension 2 Code")
                {
                }
                column(greTGLEntry__Global_Dimension_1_Code_; TempGLEntry."Global Dimension 1 Code")
                {
                }
                column(NameDescText1; NameDescText)
                {
                }
                column(greTGLEntry__G_L_Account_No__; TempGLEntry."G/L Account No.")
                {
                }
                column(Sales_Invoice_Header___Posting_Date_; Format("Sales Invoice Header"."Posting Date"))
                {
                }
                column(greUserSetup__User_Name_; UserSetup."User Name")
                {
                }
                column(greTGLEntry__Global_Dimension_2_Code_Caption; CaptionClassTranslate('1,1,2'))
                {
                }
                column(greTGLEntry__Global_Dimension_1_Code_Caption; CaptionClassTranslate('1,1,1'))
                {
                }
                column(Integer_Number; Number)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TempGLEntry.FindSet()
                    else
                        TempGLEntry.Next();

                    GLAcc.Get(TempGLEntry."G/L Account No.");
                    if GroupGLAccounts then
                        NameDescText := GLAcc.Name
                    else
                        NameDescText := TempGLEntry.Description;
                end;

                trigger OnPreDataItem()
                begin
                    TempGLEntry.Reset();
                    SetRange(Number, 1, TempGLEntry.Count);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                TempGLEntry.DeleteAll();

                FCYRate := 0;
                if ("Currency Code" <> '') and ("Currency Factor" <> 0) then
                    FCYRate := 1 / "Currency Factor";
            end;

            trigger OnPreDataItem()
            begin
                if not "Sales Invoice Header".HasFilter then
                    CurrReport.Break();
            end;
        }
        dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
        {
            CalcFields = Amount, "Amount Including VAT";
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Posting Date";
            column(Sales_Cr_Memo_Header__No; "No.")
            {
            }
            column(greCompanyInfo_Name_Control4; CompanyInfo.Name)
            {
            }
            column(Sales_Cr_Memo_Header__Due_Date_; Format("Due Date"))
            {
            }
            column(Sales_Cr_Memo_Header__Sell_to_Customer_Name_; "Sell-to Customer Name")
            {
            }
            column(Amount_Including_VAT__Amount_Control235; "Amount Including VAT" - Amount)
            {
            }
            column(Sales_Cr_Memo_Header_Amount; Amount)
            {
            }
            column(Sales_Cr_Memo_Header__Currency_Code_; "Currency Code")
            {
            }
            column(gdeFCYRate_Control1100162004; FCYRate)
            {
                DecimalPlaces = 5 : 5;
            }
            column(Sales_Cr_Memo_Header__No_Caption; FieldCaption("No."))
            {
            }
            column(Sales_Cr_Memo_Header_AmountCaption; FieldCaption(Amount))
            {
            }
            column(Sales_Cr_Memo_Header__Currency_Code_Caption; FieldCaption("Currency Code"))
            {
            }
            column(SalesCrMemoHeader_PostingDate; "Posting Date")
            {
            }
            column(SalesCrMemoHeader_VATDate; "VAT Date CZL")
            {
            }
            column(SalesCrMemoHeader_DocumentDate; "Document Date")
            {
            }
            dataitem(GLEntry2; "G/L Entry")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Posting Date");

                trigger OnAfterGetRecord()
                begin
                    if UserSetup."User ID" <> "User ID" then
                        if not UserSetup.Get("User ID") then
                            UserSetup.Init();

                    BufferGLEntry(GLEntry2);
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Entry No.", 1, LastGLEntry);
                end;
            }
            dataitem(Integer2; "Integer")
            {
                DataItemTableView = sorting(Number) WHERE(Number = FILTER(1 ..));
                column(greTGLEntry__Credit_Amount__Control90; TempGLEntry."Credit Amount")
                {
                }
                column(greTGLEntry__Debit_Amount__Control91; TempGLEntry."Debit Amount")
                {
                }
                column(greTGLEntry__Global_Dimension_2_Code__Control106; TempGLEntry."Global Dimension 2 Code")
                {
                }
                column(greTGLEntry__Global_Dimension_1_Code__Control112; TempGLEntry."Global Dimension 1 Code")
                {
                }
                column(NameDescText2; NameDescText)
                {
                }
                column(greTGLEntry__G_L_Account_No___Control115; TempGLEntry."G/L Account No.")
                {
                }
                column(Sales_Cr_Memo_Header___Posting_Date_; Format("Sales Cr.Memo Header"."Posting Date"))
                {
                }
                column(greUserSetup__User_Name__Control310; UserSetup."User Name")
                {
                }
                column(greTGLEntry__Global_Dimension_2_Code__Control106Caption; CaptionClassTranslate('1,1,2'))
                {
                }
                column(greTGLEntry__Global_Dimension_1_Code__Control112Caption; CaptionClassTranslate('1,1,1'))
                {
                }
                column(Integer2_Number; Number)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TempGLEntry.FindSet()
                    else
                        TempGLEntry.Next();

                    GLAcc.Get(TempGLEntry."G/L Account No.");
                    if GroupGLAccounts then
                        NameDescText := GLAcc.Name
                    else
                        NameDescText := TempGLEntry.Description;
                end;

                trigger OnPreDataItem()
                begin
                    TempGLEntry.Reset();
                    SetRange(Number, 1, TempGLEntry.Count);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                TempGLEntry.DeleteAll();

                FCYRate := 0;
                if ("Currency Code" <> '') and ("Currency Factor" <> 0) then
                    FCYRate := 1 / "Currency Factor";
            end;

            trigger OnPreDataItem()
            begin
                if not "Sales Cr.Memo Header".HasFilter then
                    CurrReport.Break();
            end;
        }
        dataitem("Purch. Inv. Header"; "Purch. Inv. Header")
        {
            CalcFields = Amount, "Amount Including VAT";
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Posting Date";
            column(Purch__Inv__Header__No; "No.")
            {
            }
            column(greCompanyInfo_Name_Control32; CompanyInfo.Name)
            {
            }
            column(Purch__Inv__Header__Due_Date_; Format("Due Date"))
            {
            }
            column(Purch__Inv__Header__Buy_from_Vendor_Name_; "Buy-from Vendor Name")
            {
            }
            column(Purch__Inv__Header__Vendor_Invoice_No__; "Vendor Invoice No.")
            {
            }
            column(Purch__Inv__Header_Amount; Amount)
            {
            }
            column(Amount_Including_VAT__Amount_Control241; "Amount Including VAT" - Amount)
            {
            }
            column(Purch__Inv__Header__Currency_Code_; "Currency Code")
            {
            }
            column(gdeFCYRate_Control1100162009; FCYRate)
            {
                DecimalPlaces = 5 : 5;
            }
            column(Purch__Inv__Header__No_Caption; FieldCaption("No."))
            {
            }
            column(Purch__Inv__Header_AmountCaption; FieldCaption(Amount))
            {
            }
            column(Purch__Inv__Header__Currency_Code_Caption; FieldCaption("Currency Code"))
            {
            }
            column(PurchInvoiceHeader_PostingDate; "Posting Date")
            {
            }
            column(PurchInvoiceHeader_VATDate; "VAT Date CZL")
            {
            }
            column(PurchInvoiceHeader_DocumentDate; "Document Date")
            {
            }
            dataitem(GLEntry3; "G/L Entry")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Posting Date");

                trigger OnAfterGetRecord()
                begin
                    if UserSetup."User ID" <> "User ID" then
                        if not UserSetup.Get("User ID") then
                            UserSetup.Init();

                    BufferGLEntry(GLEntry3);
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Entry No.", 1, LastGLEntry);
                end;
            }
            dataitem(Integer3; "Integer")
            {
                DataItemTableView = sorting(Number) WHERE(Number = FILTER(1 ..));
                column(greTGLEntry__Credit_Amount__Control331; TempGLEntry."Credit Amount")
                {
                }
                column(greTGLEntry__Debit_Amount__Control332; TempGLEntry."Debit Amount")
                {
                }
                column(greTGLEntry__Global_Dimension_2_Code__Control334; TempGLEntry."Global Dimension 2 Code")
                {
                }
                column(greTGLEntry__Global_Dimension_1_Code__Control335; TempGLEntry."Global Dimension 1 Code")
                {
                }
                column(NameDescText3; NameDescText)
                {
                }
                column(greTGLEntry__G_L_Account_No___Control338; TempGLEntry."G/L Account No.")
                {
                }
                column(Purch__Inv__Header___Posting_Date_; Format("Purch. Inv. Header"."Posting Date"))
                {
                }
                column(greUserSetup__User_Name__Control352; UserSetup."User Name")
                {
                }
                column(greTGLEntry__Global_Dimension_2_Code__Control334Caption; CaptionClassTranslate('1,1,2'))
                {
                }
                column(greTGLEntry__Global_Dimension_1_Code__Control335Caption; CaptionClassTranslate('1,1,1'))
                {
                }
                column(Integer3_Number; Number)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TempGLEntry.FindSet()
                    else
                        TempGLEntry.Next();

                    GLAcc.Get(TempGLEntry."G/L Account No.");
                    if GroupGLAccounts then
                        NameDescText := GLAcc.Name
                    else
                        NameDescText := TempGLEntry.Description;
                end;

                trigger OnPreDataItem()
                begin
                    TempGLEntry.Reset();
                    SetRange(Number, 1, TempGLEntry.Count);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                TempGLEntry.DeleteAll();

                FCYRate := 0;
                if ("Currency Code" <> '') and ("Currency Factor" <> 0) then
                    FCYRate := 1 / "Currency Factor";
            end;

            trigger OnPreDataItem()
            begin
                if not "Purch. Inv. Header".HasFilter then
                    CurrReport.Break();
            end;
        }
        dataitem("Purch. Cr. Memo Hdr."; "Purch. Cr. Memo Hdr.")
        {
            CalcFields = Amount, "Amount Including VAT";
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Posting Date";
            column(Purch__Cr__Memo_Hdr__No; "No.")
            {
            }
            column(greCompanyInfo_Name_Control35; CompanyInfo.Name)
            {
            }
            column(Purch__Cr__Memo_Hdr___Due_Date_; Format("Due Date"))
            {
            }
            column(Purch__Cr__Memo_Hdr___Buy_from_Vendor_Name_; "Buy-from Vendor Name")
            {
            }
            column(Purch__Cr__Memo_Hdr___Vendor_Cr__Memo_No__; "Vendor Cr. Memo No.")
            {
            }
            column(Purch__Cr__Memo_Hdr__Amount; Amount)
            {
            }
            column(Amount_Including_VAT__Amount_Control245; "Amount Including VAT" - Amount)
            {
            }
            column(gdeFCYRate_Control1100162011; FCYRate)
            {
                DecimalPlaces = 5 : 5;
            }
            column(Purch__Cr__Memo_Hdr___Currency_Code_; "Currency Code")
            {
            }
            column(Purch__Cr__Memo_Hdr__No_Caption; FieldCaption("No."))
            {
            }
            column(Purch__Cr__Memo_Hdr__AmountCaption; FieldCaption(Amount))
            {
            }
            column(Purch__Cr__Memo_Hdr___Currency_Code_Caption; FieldCaption("Currency Code"))
            {
            }
            column(PurchCrMemoHeader_PostingDate; "Posting Date")
            {
            }
            column(PurchCrMemoHeader_VATDate; "VAT Date CZL")
            {
            }
            column(PurchCrMemoHeader_DocumentDate; "Document Date")
            {
            }
            dataitem(GLEntry4; "G/L Entry")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Posting Date");

                trigger OnAfterGetRecord()
                begin
                    if UserSetup."User ID" <> "User ID" then
                        if not UserSetup.Get("User ID") then
                            UserSetup.Init();

                    BufferGLEntry(GLEntry4);
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Entry No.", 1, LastGLEntry);
                end;
            }
            dataitem(Integer4; "Integer")
            {
                DataItemTableView = sorting(Number) WHERE(Number = FILTER(1 ..));
                column(greTGLEntry__Credit_Amount__Control373; TempGLEntry."Credit Amount")
                {
                }
                column(greTGLEntry__Debit_Amount__Control374; TempGLEntry."Debit Amount")
                {
                }
                column(greTGLEntry__Global_Dimension_2_Code__Control376; TempGLEntry."Global Dimension 2 Code")
                {
                }
                column(greTGLEntry__Global_Dimension_1_Code__Control377; TempGLEntry."Global Dimension 1 Code")
                {
                }
                column(NameDescText4; NameDescText)
                {
                }
                column(greTGLEntry__G_L_Account_No___Control380; TempGLEntry."G/L Account No.")
                {
                }
                column(Purch__Cr__Memo_Hdr____Posting_Date_; Format("Purch. Cr. Memo Hdr."."Posting Date"))
                {
                }
                column(greUserSetup__User_Name__Control394; UserSetup."User Name")
                {
                }
                column(greTGLEntry__Global_Dimension_2_Code__Control376Caption; CaptionClassTranslate('1,1,2'))
                {
                }
                column(greTGLEntry__Global_Dimension_1_Code__Control377Caption; CaptionClassTranslate('1,1,1'))
                {
                }
                column(Integer4_Number; Number)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TempGLEntry.FindSet()
                    else
                        TempGLEntry.Next();

                    GLAcc.Get(TempGLEntry."G/L Account No.");
                    if GroupGLAccounts then
                        NameDescText := GLAcc.Name
                    else
                        NameDescText := TempGLEntry.Description;
                end;

                trigger OnPreDataItem()
                begin
                    TempGLEntry.Reset();
                    SetRange(Number, 1, TempGLEntry.Count);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                TempGLEntry.DeleteAll();

                FCYRate := 0;
                if ("Currency Code" <> '') and ("Currency Factor" <> 0) then
                    FCYRate := 1 / "Currency Factor";
            end;

            trigger OnPreDataItem()
            begin
                if not "Purch. Cr. Memo Hdr.".HasFilter then
                    CurrReport.Break();
            end;
        }
        dataitem(GeneralDoc; "G/L Entry")
        {
            DataItemTableView = sorting("Document No.", "Posting Date");
            RequestFilterFields = "Document No.", "Posting Date";
            RequestFilterHeading = 'General Document';
            column(greCompanyInfo_Name_Control14; CompanyInfo.Name)
            {
            }
            column(GeneralDoc__Document_No; "Document No.")
            {
            }
            column(greTGLEntry__Global_Dimension_2_Code__Control104Caption; CaptionClassTranslate('1,1,2'))
            {
            }
            column(greTGLEntry__Global_Dimension_1_Code__Control107Caption; CaptionClassTranslate('1,1,1'))
            {
            }
            column(GeneralDoc__Document_No_Caption; FieldCaption("Document No."))
            {
            }
            column(GeneralDoc_Entry_No_; "Entry No.")
            {
            }
            dataitem(GLEntry5; "G/L Entry")
            {
                DataItemLink = "Document No." = field("Document No.");
                DataItemTableView = sorting("Document No.", "Posting Date");

                trigger OnAfterGetRecord()
                begin
                    if UserSetup."User ID" <> "User ID" then
                        if not UserSetup.Get("User ID") then
                            UserSetup.Init();

                    BufferGLEntry(GLEntry5);
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Entry No.", 1, LastGLEntry);
                end;
            }
            dataitem(Integer5; "Integer")
            {
                DataItemTableView = sorting(Number) WHERE(Number = FILTER(1 ..));
                column(greTGLEntry__Credit_Amount__Control98; TempGLEntry."Credit Amount")
                {
                }
                column(greTGLEntry__Debit_Amount__Control99; TempGLEntry."Debit Amount")
                {
                }
                column(greTGLEntry__Global_Dimension_2_Code__Control104; TempGLEntry."Global Dimension 2 Code")
                {
                }
                column(greTGLEntry__Global_Dimension_1_Code__Control107; TempGLEntry."Global Dimension 1 Code")
                {
                }
                column(greTGLEntry_Description; TempGLEntry.Description)
                {
                }
                column(NameDescText5; NameDescText)
                {
                }
                column(greTGLEntry__G_L_Account_No___Control127; TempGLEntry."G/L Account No.")
                {
                }
                column(greTGLEntry__Posting_Date_; Format(TempGLEntry."Posting Date"))
                {
                }
                column(greUserSetup__User_Name__Control55; UserSetup."User Name")
                {
                }
                column(Integer5_Number; Number)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TempGLEntry.FindSet()
                    else
                        TempGLEntry.Next();

                    GLAcc.Get(TempGLEntry."G/L Account No.");
                    if GroupGLAccounts then
                        NameDescText := GLAcc.Name
                    else
                        NameDescText := TempGLEntry.Description;
                end;

                trigger OnPreDataItem()
                begin
                    TempGLEntry.Reset();
                    SetRange(Number, 1, TempGLEntry.Count);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                if LastDocNo <> "Document No." then begin
                    LastDocNo := "Document No.";
                    TempGLEntry.DeleteAll();
                end else
                    CurrReport.Skip();
            end;

            trigger OnPreDataItem()
            begin
                if not HasFilter then
                    CurrReport.Break();
                LastDocNo := '';
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(GroupGLAccountsField; GroupGLAccounts)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Group same G/L accounts';
                        ToolTip = 'Specifies if the same G/L accounts have to be group.';
                    }
                }
            }
        }
    }
    trigger OnInitReport()
    begin
        GroupGLAccounts := true;
    end;

    trigger OnPreReport()
    begin
        CompanyInfo.Get();

        GLEntry.Reset();
        if GLEntry.FindLast() then
            LastGLEntry := GLEntry."Entry No.";

        LastDataItem := GetLastDataItem();
        SalesInvHdrExists := not "Sales Invoice Header".IsEmpty() and "Sales Invoice Header".HasFilter();
        SalesCrMemoHdrExists := not "Sales Cr.Memo Header".IsEmpty() and "Sales Cr.Memo Header".HasFilter();
        PurchInvHdrExists := not "Purch. Inv. Header".IsEmpty() and "Purch. Inv. Header".HasFilter();
        PurchCrMemoHdrExists := not "Purch. Cr. Memo Hdr.".IsEmpty() and "Purch. Cr. Memo Hdr.".HasFilter();
        GeneralDocExists := not GeneralDoc.IsEmpty() and GeneralDoc.HasFilter();
    end;

    var
        CompanyInfo: Record "Company Information";
        GLAcc: Record "G/L Account";
        UserSetup: Record "User Setup";
        TempGLEntry: Record "G/L Entry" temporary;
        GLEntry: Record "G/L Entry";
        LastDocNo: Code[20];
        FCYRate: Decimal;
        LastGLEntry: Integer;
        LastDataItem: Integer;
        GroupGLAccounts: Boolean;
        SalesInvHdrExists: Boolean;
        SalesCrMemoHdrExists: Boolean;
        PurchInvHdrExists: Boolean;
        PurchCrMemoHdrExists: Boolean;
        GeneralDocExists: Boolean;
        NameDescCaption: Text;
        NameDescText: Text;
        SalesInvoiceLbl: Label '(Sales Invoice)';
        SalesCreditMemoLbl: Label '(Sales Credit Memo)';
        PurchaseInvoiceLbl: Label '(Purchase Invoice)';
        PurchaseCreditMemoLbl: Label '(Purchase Credit Memo)';
        GeneralDocumentLbl: Label '(General Document)';
        CustomerLbl: Label 'Customer';
        VendorLbl: Label 'Vendor';
        DateLbl: Label 'Date:';
        RateLbl: Label 'Rate';
        CreditAmountLbl: Label 'Credit Amount';
        DebitAmountLbl: Label 'Debit Amount';
        GLAccountLbl: Label 'G/L Account';
        GLAccountNameLbl: Label 'G/L Account Name';
        FormalCorrectnessVerifiedByLbl: Label 'Formal Correctness Verified by:';
        FactualCorrectnessVerifiedByLbl: Label 'Factual Correctness Verified by :';
        PostedByLbl: Label 'Posted by :';
        ApprovedByLbl: Label 'Approved by :';
        ExternalNoLbl: Label 'External No.';
        DescriptionLbl: Label 'Description';

    procedure GetLastDataItem(): Integer
    begin
        case true of
            not GeneralDoc.IsEmpty() and GeneralDoc.HasFilter():
                exit(5);
            not "Purch. Cr. Memo Hdr.".IsEmpty() and "Purch. Cr. Memo Hdr.".HasFilter():
                exit(4);
            not "Purch. Inv. Header".IsEmpty() and "Purch. Inv. Header".HasFilter():
                exit(3);
            not "Sales Cr.Memo Header".IsEmpty() and "Sales Cr.Memo Header".HasFilter():
                exit(2);
            not "Sales Invoice Header".IsEmpty() and "Sales Invoice Header".HasFilter():
                exit(1);
        end;
    end;

    local procedure BufferGLEntry(GLEntry: Record "G/L Entry")
    begin
        if GLEntry.Amount = 0 then
            exit;
        TempGLEntry.SetRange("G/L Account No.", GLEntry."G/L Account No.");
        TempGLEntry.SetRange("Global Dimension 1 Code", GLEntry."Global Dimension 1 Code");
        TempGLEntry.SetRange("Global Dimension 2 Code", GLEntry."Global Dimension 2 Code");
        TempGLEntry.SetRange("Job No.", GLEntry."Job No.");
        if TempGLEntry.FindFirst() and GroupGLAccounts then begin
            TempGLEntry."Debit Amount" += GLEntry."Debit Amount";
            TempGLEntry."Credit Amount" += GLEntry."Credit Amount";
            TempGLEntry.Modify();
        end else begin
            TempGLEntry.Init();
            TempGLEntry.TransferFields(GLEntry);
            TempGLEntry.Insert();
        end;
    end;
}
