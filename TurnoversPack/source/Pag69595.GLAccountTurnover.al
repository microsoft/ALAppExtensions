page 69595 "RUL G/L Account Turnover"
{
    Caption = 'G/L Account Turnover';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    RefreshOnActivate = true;
    SaveValues = true;
    SourceTable = "G/L Account";
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(content)
        {
            group(Options)
            {
                Caption = 'Options';
                field(DateFilter; DateFilter)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Date Filter';

                    trigger OnValidate()
                    var
                        TextManagement: Codeunit TextManagement;
                    begin
                        if TextManagement.MakeDateFilter(DateFilter) = 0 then;
                        SetFilter("Date Filter", DateFilter);
                        DateFilter := GetFilter("Date Filter");
                        CurrPage.Update;
                    end;
                }
                field(PeriodType; PeriodType)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'View by';
                    OptionCaption = 'Day,Week,Month,Quarter,Year,Accounting Period';
                    ToolTip = 'Day';

                    trigger OnValidate()
                    begin
                        if PeriodType = PeriodType::"Accounting Period" then
                            FindUserPeriod('')
                        else
                            FindPeriod('');
                        DateFilter := GetFilter("Date Filter");
                        CurrPage.Update;
                    end;
                }
                field("G/L Account Filter"; GLAccountFilter)
                {
                    ApplicationArea = Basic, Suite;
                    TableRelation = "G/L Account"."No.";

                    trigger OnValidate()
                    begin
                        SetFilter("No.", GLAccountFilter);
                        CurrPage.Update;
                    end;
                }
                field("Business Unit Filter"; BusinessUnitFilter)
                {
                    ApplicationArea = Basic, Suite;
                    TableRelation = "Business Unit";

                    trigger OnValidate()
                    begin
                        SetFilter("Business Unit Filter", BusinessUnitFilter);
                        CurrPage.Update;
                    end;
                }
                field("Global Dimension 1 Filter"; GlobalDimension1Filter)
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '1,3,1';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookUpDimFilter(GLSetup."Global Dimension 1 Code", Text));
                    end;

                    trigger OnValidate()
                    begin
                        SetFilter("Global Dimension 1 Filter", GlobalDimension1Filter);
                        CurrPage.Update;
                    end;
                }
                field("Global Dimension 2 Filter"; GlobalDimension2Filter)
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '1,3,2';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookUpDimFilter(GLSetup."Global Dimension 2 Code", Text));
                    end;

                    trigger OnValidate()
                    begin
                        SetFilter("Global Dimension 2 Filter", GlobalDimension2Filter);
                        CurrPage.Update;
                    end;
                }
            }
            repeater(Control5)
            {
                Editable = false;
                IndentationColumn = NameIndent;
                IndentationControls = Name;
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = Basic, Suite;
                    Style = Strong;
                    StyleExpr = NoEmphasize;
                }
                field(Name; Name)
                {
                    ApplicationArea = Basic, Suite;
                    Style = Strong;
                    StyleExpr = NameEmphasize;
                }
                field("BalanceAmounts[BalanceType::StartBal]"; BalanceAmounts[BalanceType::StartBal])
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Caption = 'Starting Balance';

                    trigger OnDrillDown()
                    begin
                        DrillDownGLEntry(4);
                    end;
                }
                field(StartingBalanceDebit; BalanceAmounts[BalanceType::StartBalDebit])
                {
                    BlankZero = true;
                    Caption = 'Starting Debit Balance';
                    Visible = false;
                }
                field(StartingBalanceCredit; BalanceAmounts[BalanceType::StartBalCredit])
                {
                    BlankZero = true;
                    Caption = 'Starting Credit Balance';
                    Visible = false;
                }
                field("RUL Debit Amount"; "RUL Debit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    BlankNumbers = BlankZero;
                    Style = Strong;
                    StyleExpr = DebitAmountEmphasize;

                    trigger OnDrillDown()
                    begin
                        DrillDownGLEntry(0);
                    end;
                }
                field("RUL Credit Amount"; "RUL Credit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    BlankNumbers = BlankZero;
                    Style = Strong;
                    StyleExpr = CreditAmountEmphasize;

                    trigger OnDrillDown()
                    begin
                        DrillDownGLEntry(1);
                    end;
                }
                field("Balance at End Period"; "RUL Balance at Date")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Caption = 'Balance at End Period';
                    Style = Strong;
                    StyleExpr = BalanceEndPeriodEmphasize;
                }
                field(EndingBalanceDebit; BalanceAmounts[BalanceType::EndBalDebit])
                {
                    BlankZero = true;
                    Caption = 'Ending Debit Balance';
                    Visible = false;
                }
                field(EndingBalanceCredit; BalanceAmounts[BalanceType::EndBalCredit])
                {
                    BlankZero = true;
                    Caption = 'Ending Credit Balance';
                    Visible = false;
                }
                field("RUL Net Change"; "RUL Net Change")
                {
                    BlankZero = true;
                    Style = Strong;
                    StyleExpr = NetChangeEmphasize;
                    Visible = false;
                }
                field("BalanceAmounts[BalanceType::StartBalACY]"; BalanceAmounts[BalanceType::StartBalACY])
                {
                    BlankZero = true;
                    Caption = 'ACY Balance at Begin Period';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        DrillDownGLEntry(5);
                    end;
                }
                field("RUL Debit Amount (ACY)"; "RUL Debit Amount (ACY)")
                {
                    BlankZero = true;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        DrillDownGLEntry(2);
                    end;
                }
                field("RUL Credit Amount (ACY)"; "RUL Credit Amount (ACY)")
                {
                    BlankZero = true;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        DrillDownGLEntry(3);
                    end;
                }
                field("RUL Balance at Date (ACY)"; "RUL Balance at Date (ACY)")
                {
                    BlankZero = true;
                    Caption = 'ACY Balance at End Period';
                    Visible = false;
                }
                field("RUL Net Change (ACY)"; "RUL Net Change (ACY)")
                {
                    BlankZero = true;
                    Visible = false;
                }
            }
            group(Source)
            {
                Caption = 'Source';
                field(SourceType; SourceType)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Source Type Filter';
                    OptionCaption = ' ,Customer,Vendor,Bank Account,Fixed Asset';

                    trigger OnValidate()
                    begin
                        SourceTypeOnAfterValidate;
                        CurrPage.Update;
                    end;
                }
                field(SourceNo; SourceNo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Source No. Filter';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        CustList: Page "Customer List";
                        VendList: Page "Vendor List";
                        FAList: Page "Fixed Asset List";
                        BankAccList: Page "Bank Account List";
                    begin
                        case SourceType of
                            SourceType::Customer:
                                begin
                                    Clear(CustList);
                                    Cust."No." := SourceNo;
                                    CustList.SetRecord(Cust);
                                    CustList.LookupMode(true);
                                    if CustList.RunModal = ACTION::LookupOK then begin
                                        CustList.GetRecord(Cust);
                                        SourceNo := Cust."No.";
                                    end;
                                end;
                            SourceType::Vendor:
                                begin
                                    Clear(VendList);
                                    Vend."No." := SourceNo;
                                    VendList.SetRecord(Vend);
                                    VendList.LookupMode(true);
                                    if VendList.RunModal = ACTION::LookupOK then begin
                                        VendList.GetRecord(Vend);
                                        SourceNo := Vend."No.";
                                    end;
                                end;
                            SourceType::"Bank Account":
                                begin
                                    Clear(BankAccList);
                                    BankAcc."No." := SourceNo;
                                    BankAccList.SetRecord(BankAcc);
                                    BankAccList.LookupMode(true);
                                    if BankAccList.RunModal = ACTION::LookupOK then begin
                                        BankAccList.GetRecord(BankAcc);
                                        SourceNo := BankAcc."No.";
                                    end;
                                end;
                            SourceType::"Fixed Asset":
                                begin
                                    Clear(FAList);
                                    FA."No." := SourceNo;
                                    FAList.SetRecord(FA);
                                    FAList.LookupMode(true);
                                    if FAList.RunModal = ACTION::LookupOK then begin
                                        FAList.GetRecord(FA);
                                        SourceNo := FA."No.";
                                    end;
                                end;
                        end;
                        UpdateSourceNoFilter;
                    end;

                    trigger OnValidate()
                    begin
                        UpdateSourceNoFilter;
                    end;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("G/L Account")
            {
                Caption = 'G/L Account';
                action(Card)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = Page "G/L Account Card";
                    RunPageLink = "No." = FIELD ("No."),
                                  "Date Filter" = FIELD ("Date Filter"),
                                  "Global Dimension 1 Filter" = FIELD ("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter" = FIELD ("Global Dimension 2 Filter"),
                                  "Budget Filter" = FIELD ("Budget Filter"),
                                  "Business Unit Filter" = FIELD ("Business Unit Filter");
                    ShortCutKey = 'Shift+F7';
                }
                action("Ledger Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ledger Entries';
                    Image = GLRegisters;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    RunObject = Page "General Ledger Entries";
                    RunPageLink = "G/L Account No." = FIELD ("No.");
                    RunPageView = SORTING ("G/L Account No.");
                    ShortCutKey = 'Ctrl+F7';
                }
                action("&Comments")
                {
                    Caption = '&Comments';
                    Image = ViewComments;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = CONST ("G/L Account"),
                                  "No." = FIELD ("No.");
                }
                action("Receivables-Payables")
                {
                    ApplicationArea = Suite;
                    Caption = 'Receivables-Payables';
                    Image = ReceivablesPayables;
                    RunObject = Page "Receivables-Payables";
                }
            }
            group(Balance)
            {
                Caption = 'Balance';
                Image = Balance;
                action("G/L &Account Balance")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'G/L &Account Balance';
                    Image = GLAccountBalance;
                    RunObject = Page "G/L Account Balance";
                    RunPageLink = "No." = FIELD ("No."),
                                  "Global Dimension 1 Filter" = FIELD ("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter" = FIELD ("Global Dimension 2 Filter"),
                                  "Business Unit Filter" = FIELD ("Business Unit Filter");
                }
                action("G/L &Balance")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'G/L &Balance';
                    Image = GLBalance;
                    RunObject = Page "G/L Balance";
                }
                action("G/L Balance by &Dimension")
                {
                    ApplicationArea = Suite;
                    Caption = 'G/L Balance by &Dimension';
                    Image = GLBalanceDimension;
                    RunObject = Page "G/L Balance by Dimension";
                }
                separator(Separator1210008)
                {
                }
                action("G/L Account Balance/Bud&get")
                {
                    ApplicationArea = Suite;
                    Caption = 'G/L Account Balance/Bud&get';
                    Image = Period;
                    RunObject = Page "G/L Account Balance/Budget";
                    RunPageLink = "No." = FIELD ("No."),
                                  "Global Dimension 1 Filter" = FIELD ("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter" = FIELD ("Global Dimension 2 Filter"),
                                  "Business Unit Filter" = FIELD ("Business Unit Filter");
                }
                action("G/L Balance/B&udget")
                {
                    ApplicationArea = Suite;
                    Caption = 'G/L Balance/B&udget';
                    Image = GeneralLedger;
                    RunObject = Page "G/L Balance/Budget";
                }
                separator(Separator1210011)
                {
                }
                action("G/L Turnover by Customers")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'G/L Turnover by Customers';
                    Image = CustomerLedger;
                    RunObject = Page "RUL Customer G/L Turnover";
                    RunPageLink = "RUL G/L Account Filter" = FIELD ("No."),
                                  "Date Filter" = FIELD ("Date Filter");
                }
                action("G/L Turnover by Vendors")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'G/L Turnover by Vendors';
                    Image = VendorLedger;
                    RunObject = Page "RUL Vendor G/L Turnover";
                    RunPageLink = "RUL G/L Account Filter" = FIELD ("No."),
                                  "Date Filter" = FIELD ("Date Filter");
                }
            }
        }
        area(processing)
        {
            action("Previous Period")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Previous Period';
                Image = PreviousRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Previous Period';

                trigger OnAction()
                begin
                    FindPeriod('<=');
                    DateFilter := GetFilter("Date Filter");
                end;
            }
            action("Next Period")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Next Period';
                Image = NextRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Next Period';

                trigger OnAction()
                begin
                    FindPeriod('>=');
                    DateFilter := GetFilter("Date Filter");
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        NameIndent := 0;
        CalculateAmounts(BalanceAmounts);
        NoOnFormat;
        NameOnFormat;
        DebitAmountOnFormat;
        CreditAmountOnFormat;
        BalanceatDateOnFormat;
        NetChangeOnFormat;
    end;

    trigger OnOpenPage()
    begin
        GLSetup.Get;
        if PeriodType = PeriodType::"Accounting Period" then
            FindUserPeriod('')
        else
            FindPeriod('');
        DateFilter := GetFilter("Date Filter");
        if GLAccountFilter <> '' then
            SetFilter("No.", GLAccountFilter);
    end;

    var
        GLAcc: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        Cust: Record Customer;
        Vend: Record Vendor;
        BankAcc: Record "Bank Account";
        FA: Record "Fixed Asset";
        GLSetup: Record "General Ledger Setup";
        DateFilter: Text;
        GLAccountFilter: Code[250];
        BusinessUnitFilter: Code[250];
        GlobalDimension1Filter: Code[250];
        GlobalDimension2Filter: Code[250];
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        BalanceAmounts: array[7] of Decimal;
        BalanceType: Option ,StartBal,StartBalACY,StartBalCredit,StartBalDebit,EndBalCredit,EndBalDebit,EndBal;
        SourceType: Option " ",Customer,Vendor,"Bank Account","Fixed Asset";
        SourceNo: Code[20];
        [InDataSet]
        NoEmphasize: Boolean;
        [InDataSet]
        NameEmphasize: Boolean;
        [InDataSet]
        NameIndent: Integer;
        [InDataSet]
        DebitAmountEmphasize: Boolean;
        [InDataSet]
        CreditAmountEmphasize: Boolean;
        [InDataSet]
        BalanceEndPeriodEmphasize: Boolean;
        [InDataSet]
        NetChangeEmphasize: Boolean;

    procedure DrillDownGLEntry(Show: Option Debit,Credit,ACYDebet,ACYCredit,BeginPeriod,ACYBeginPeriod)
    begin
        GLEntry.Reset;
        if (GetFilter("Business Unit Filter") <> '') or
           (GetFilter("Global Dimension 1 Filter") <> '') or
           (GetFilter("Global Dimension 2 Filter") <> '')
        then
            GLEntry.SetCurrentKey("G/L Account No.", "Business Unit Code", "Global Dimension 1 Code", "Global Dimension 2 Code")
        else
            GLEntry.SetCurrentKey("G/L Account No.", "Posting Date");
        if Totaling = '' then
            GLEntry.SetRange("G/L Account No.", "No.")
        else
            GLEntry.SetFilter("G/L Account No.", Totaling);
        GLEntry.SetFilter("Posting Date", GetFilter("Date Filter"));
        GLEntry.SetFilter("Global Dimension 1 Code", GetFilter("Global Dimension 1 Filter"));
        GLEntry.SetFilter("Global Dimension 2 Code", GetFilter("Global Dimension 2 Filter"));
        GLEntry.SetFilter("Business Unit Code", GetFilter("Business Unit Filter"));
        GLEntry.SetFilter("Source Type", GetFilter("RUL Source Type Filter"));
        GLEntry.SetFilter("Source No.", GetFilter("RUL Source No. Filter"));
        case Show of
            Show::Debit:
                GLEntry.SetFilter("Debit Amount", '<>%1', 0);
            Show::Credit:
                GLEntry.SetFilter("Credit Amount", '<>%1', 0);
            Show::ACYDebet:
                GLEntry.SetFilter("Add.-Currency Debit Amount", '<>%1', 0);
            Show::ACYCredit:
                GLEntry.SetFilter("Add.-Currency Credit Amount", '<>%1', 0);
            Show::BeginPeriod,
          Show::ACYBeginPeriod:
                if CopyStr(GetFilter("Date Filter"), 1, 2) <> '..' then begin
                    if GetRangeMin("Date Filter") <> 0D then
                        GLEntry.SetRange("Posting Date", 0D, ClosingDate(GetRangeMin("Date Filter") - 1));
                end else
                    exit;
            else
                Error('');
        end;
        PAGE.Run(0, GLEntry);
    end;

    local procedure SourceTypeOnAfterValidate()
    begin
        if SourceType > 0 then
            SetFilter("RUL Source Type Filter", '%1', SourceType)
        else begin
            SetRange("RUL Source Type Filter");
            SetRange("RUL Source No. Filter");
            SourceNo := '';
        end;
    end;

    local procedure UpdateSourceNoFilter()
    begin
        if SourceNo <> '' then
            SetFilter("RUL Source No. Filter", '%1', SourceNo)
        else
            SetRange("RUL Source No. Filter");
        CurrPage.Update;
    end;

    local procedure NoOnFormat()
    begin
        NoEmphasize := "Account Type" <> "Account Type"::Posting;
    end;

    local procedure NameOnFormat()
    begin
        NameIndent := Indentation;
        NameEmphasize := "Account Type" <> "Account Type"::Posting;
    end;

    local procedure DebitAmountOnFormat()
    begin
        DebitAmountEmphasize := "Account Type" <> "Account Type"::Posting;
    end;

    local procedure CreditAmountOnFormat()
    begin
        CreditAmountEmphasize := "Account Type" <> "Account Type"::Posting;
    end;

    local procedure BalanceatDateOnFormat()
    begin
        BalanceEndPeriodEmphasize := "Account Type" <> "Account Type"::Posting;
    end;

    local procedure NetChangeOnFormat()
    begin
        NetChangeEmphasize := "Account Type" <> "Account Type"::Posting;
    end;

    procedure FindPeriod(SearchText: Code[10])
    var
        Calendar: Record Date;
        PeriodFormManagement: Codeunit PeriodFormManagement;
    begin
        if GetFilter("Date Filter") <> '' then begin
            Calendar.SetFilter("Period Start", GetFilter("Date Filter"));
            if not PeriodFormManagement.FindDate('+', Calendar, PeriodType) then
                PeriodFormManagement.FindDate('+', Calendar, PeriodType::Day);
            Calendar.SetRange("Period Start");
        end;
        PeriodFormManagement.FindDate(SearchText, Calendar, PeriodType);
        if Calendar."Period Start" = Calendar."Period End" then
            SetRange("Date Filter", Calendar."Period Start")
        else
            SetRange("Date Filter", Calendar."Period Start", Calendar."Period End");
    end;

    procedure FindUserPeriod(SearchText: Code[10])
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId) then begin
            SetRange("Date Filter", UserSetup."Allow Posting From", UserSetup."Allow Posting To");
            if GetRangeMin("Date Filter") = GetRangeMax("Date Filter") then
                SetRange("Date Filter", GetRangeMin("Date Filter"));
        end else
            FindPeriod(SearchText);
    end;

    local procedure CalculateAmounts(var BalanceAmounts: array[7] of Decimal)
    var
        GLAcc: Record "G/L Account";
        BalanceType: Option ,StartBal,StartBalACY,StartBalCredit,StartBalDebit,EndBalCredit,EndBalDebit,EndBal;
    begin
        Clear(BalanceAmounts);

        if CopyStr(GetFilter("Date Filter"), 1, 2) <> '..' then
            if GetRangeMin("Date Filter") <> 0D then begin
                GLAcc.Reset;
                GLAcc.Get("No.");
                GLAcc.CopyFilters(Rec);
                GLAcc.SetRange("Date Filter", 0D, ClosingDate(CalcDate('<-1D>', GetRangeMin("Date Filter"))));
                GLAcc.CalcFields(
                  "RUL Balance at Date", "RUL Balance at Date (ACY)",
                  "RUL Credit Amount at Date", "RUL Debit Amount at Date");
                BalanceAmounts[BalanceType::StartBal] := GLAcc."RUL Balance at Date";
                BalanceAmounts[BalanceType::StartBalACY] := GLAcc."RUL Balance at Date (ACY)";
                BalanceAmounts[BalanceType::StartBalDebit] := GLAcc."RUL Debit Amount at Date";
                BalanceAmounts[BalanceType::StartBalCredit] := GLAcc."RUL Credit Amount at Date";

                GLAcc.SetRange("Date Filter", GetRangeMax("Date Filter"));
                GLAcc.CalcFields("RUL Credit Amount at Date", "RUL Debit Amount at Date", "RUL Balance at Date");
                BalanceAmounts[BalanceType::EndBalDebit] := GLAcc."RUL Debit Amount at Date";
                BalanceAmounts[BalanceType::EndBalCredit] := GLAcc."RUL Credit Amount at Date";
                BalanceAmounts[BalanceType::EndBal] := GLAcc."RUL Balance at Date";
            end;
    end;

    local procedure LookUpDimFilter(Dim: Code[20]; var Text: Text[250]): Boolean
    var
        DimVal: Record "Dimension Value";
        DimValList: Page "Dimension Value List";
    begin
        if Dim = '' then
            exit(false);
        DimValList.LookupMode(true);
        DimVal.SetRange("Dimension Code", Dim);
        DimValList.SetTableView(DimVal);
        if DimValList.RunModal = ACTION::LookupOK then begin
            DimValList.GetRecord(DimVal);
            Text := DimValList.GetSelectionFilter;
        end;
        exit(true);
    end;
}

