page 1693 "Bank Deposit Subform"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    PageType = ListPart;
    PromotedActionCategories = 'New,Process,Report,Line,Functions';
    SourceTable = "Gen. Journal Line";
    Permissions = tabledata "Bank Deposit Header" = r;

    layout
    {
        area(content)
        {
            repeater(Control1020000)
            {
                ShowCaption = false;
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the account type from which the bank deposit was received.';

                    trigger OnValidate()
                    var
                        CurType: Enum "Gen. Journal Account Type";
                    begin
                        if xRec."Account Type" <> "Account Type" then begin
                            CurType := Rec."Account Type";
                            OnValidateAccountTypeOnBeforeInit(Rec);
                            Rec.Init();
                            CopyValuesFromHeader();
                            Rec."Account Type" := CurType;
                        end;
                        AccountTypeOnAfterValidate();
                    end;
                }
                field("Account No."; "Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the account number of the entity from which the bank deposit item was received.';

                    trigger OnValidate()
                    begin
                        // special case:  OnValidate for Account No. field changed the Currency code, now we must change it back.
                        BankDepositHeader.Reset();
                        BankDepositHeader.SetCurrentKey("Journal Template Name", "Journal Batch Name");
                        BankDepositHeader.SetRange("Journal Template Name", "Journal Template Name");
                        BankDepositHeader.SetRange("Journal Batch Name", "Journal Batch Name");
                        if BankDepositHeader.FindFirst() then begin
                            Rec.Validate("Currency Code", BankDepositHeader."Currency Code");
                            Rec.Validate("Posting Date", BankDepositHeader."Posting Date");
                        end;
                        Rec.Validate(Description, GetLineDescription());
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the bank deposit line.';
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date of the bank deposit document.';
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the document that the bank deposit is related to.';
                    ValuesAllowed = " ", Payment, Refund;

                    trigger OnValidate()
                    begin
                        if not ("Document Type" in ["Document Type"::Payment, "Document Type"::Refund, "Document Type"::" "]) then
                            error(DocumentTypeErr);
                    end;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the bank deposit document.';
                }
                field("Credit Amount"; "Credit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total of the credit entries in the bank deposit.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of the item, such as a check, that was deposited.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the value assigned to this dimension for this bank deposit.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the value assigned to this dimension for this bank deposit.';
                    Visible = false;
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                    ToolTip = 'Specifies the shortcut dimension for this bank deposit.';

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                    ToolTip = 'Specifies the shortcut dimension for this bank deposit.';

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                    ToolTip = 'Specifies the shortcut dimension for this bank deposit.';

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                    ToolTip = 'Specifies the shortcut dimension for this bank deposit.';

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                    ToolTip = 'Specifies the shortcut dimension for this bank deposit.';

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                    ToolTip = 'Specifies the shortcut dimension for this bank deposit.';

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field("Applies-to Doc. Type"; "Applies-to Doc. Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type that will be applied to the bank deposit process.';
                    Visible = false;
                }
                field("Applies-to Doc. No."; "Applies-to Doc. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number that will be applied to the bank deposit process.';
                    Visible = false;
                }
                field("Applies-to ID"; "Applies-to ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry ID that will be applied to the bank deposit process.';
                    Visible = false;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a reason code that will enable you to trace the entry. The reason code to all G/L, bank account, customer and other ledger entries created when posting.';
                    Visible = false;
                }
            }
            group(Footer)
            {
                ShowCaption = false;
                group(LinesTotal)
                {
                    ShowCaption = false;
                    field(TotalDepositLines; TotalDepositLines)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Total Deposit Lines';
                        Editable = false;
                        ToolTip = 'Specifies the sum of the amounts in the Amount fields on the associated bank deposit lines.';
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(ApplyEntries)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Apply Entries';
                    Image = ApplyEntries;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F11';
                    ToolTip = 'Select one or more ledger entries that you want to apply this record to so that the related posted documents are closed as paid or refunded. ';

                    trigger OnAction()
                    begin
                        ShowApplyEntries();
                    end;
                }
            }
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(AccountCard)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Account &Card';
                    Image = Account;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View or change detailed information about the account on the bank deposit line.';

                    trigger OnAction()
                    begin
                        ShowAccountCard();
                    end;
                }
                action(AccountLedgerEntries)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Account Ledger E&ntries';
                    Image = LedgerEntries;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View ledger entries that are posted for the account on the bank deposit line.';

                    trigger OnAction()
                    begin
                        ShowAccountLedgerEntries();
                    end;
                }
                action(Dimensions)
                {
                    ApplicationArea = Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        ShowDimensionEntries();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        TotalDepositLines := GetLinesTotal();
        Rec.ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        TotalDepositLines := GetLinesTotal();
        CurrPage.Update(false);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        BankDepositPost: codeunit "Bank Deposit-Post";
    begin
        BankDepositHeader.SetCurrentKey("Journal Template Name", "Journal Batch Name");
        BankDepositHeader.SetRange("Journal Template Name", Rec."Journal Template Name");
        BankDepositHeader.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        BankDepositHeader.FindFirst();
        Rec."Dimension Set ID" := BankDepositPost.CombineDimensionSets(BankDepositHeader, Rec);
        exit(true);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if Rec."Journal Template Name" <> '' then begin
            Rec."Account Type" := xRec."Account Type";
            Rec."Document Type" := xRec."Document Type";
            Clear(ShortcutDimCode);
            CopyValuesFromHeader();
        end;
    end;

    var
        BankDepositHeader: Record "Bank Deposit Header";
        TotalDepositLines: Decimal;
        DocumentTypeErr: Label 'Document Type should be Payment, Refund or blank.';

    protected var
        ShortcutDimCode: array[8] of Code[20];

    local procedure GetLinesTotal(): Decimal
    begin
        BankDepositHeader.SetCurrentKey("Journal Template Name", "Journal Batch Name");
        BankDepositHeader.SetRange("Journal Template Name", Rec."Journal Template Name");
        BankDepositHeader.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        if not BankDepositHeader.FindFirst() then
            exit(0);
        BankDepositHeader.CalcFields("Total Deposit Lines");
        exit(BankDepositHeader."Total Deposit Lines");
    end;

    local procedure CopyValuesFromHeader()
    begin
        BankDepositHeader.SetCurrentKey("Journal Template Name", "Journal Batch Name");
        BankDepositHeader.SetRange("Journal Template Name", Rec."Journal Template Name");
        BankDepositHeader.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        BankDepositHeader.FindFirst();
        Rec."Bal. Account Type" := Rec."Bal. Account Type"::"Bank Account";
        Rec."Bal. Account No." := BankDepositHeader."Bank Account No.";
        Rec."Currency Code" := BankDepositHeader."Currency Code";
        Rec."Currency Factor" := BankDepositHeader."Currency Factor";
        Rec."Document Date" := BankDepositHeader."Document Date";
        Rec."Posting Date" := BankDepositHeader."Posting Date";
        Rec."External Document No." := BankDepositHeader."No.";
        Rec."Reason Code" := BankDepositHeader."Reason Code";
    end;

    local procedure GetLineDescription(): Text[100]
    var
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        Employee: Record Employee;
        ICPartner: Record "IC Partner";
        FixedAsset: Record "Fixed Asset";
    begin
        Case Rec."Account Type" of
            "Gen. Journal Account Type"::"G/L Account":
                if GLAccount.Get(Rec."Account No.") then
                    exit(GLAccount.Name);
            "Gen. Journal Account Type"::Customer:
                if Customer.Get(Rec."Account No.") then
                    exit(Customer.Name);
            "Gen. Journal Account Type"::Vendor:
                if Vendor.Get(Rec."Account No.") then
                    exit(Vendor.Name);
            "Gen. Journal Account Type"::Employee:
                if Employee.Get(Rec."Account No.") then
                    exit(Employee.FullName());
            "Gen. Journal Account Type"::"IC Partner":
                if ICPartner.Get(Rec."Account No.") then
                    exit(ICPartner.Name);
            "Gen. Journal Account Type"::"Fixed Asset":
                if FixedAsset.Get(Rec."Account No.") then
                    exit(FixedAsset.Description);
        End
    end;

    procedure ShowAccountCard()
    var
        GenJnlShowCard: Codeunit "Gen. Jnl.-Show Card";
    begin
        GenJnlShowCard.Run(Rec);
    end;

    procedure ShowAccountLedgerEntries()
    var
        GenJnlShowEntries: Codeunit "Gen. Jnl.-Show Entries";
    begin
        GenJnlShowEntries.Run(Rec);
    end;

    procedure ShowApplyEntries()
    var
        GenJnlApply: Codeunit "Gen. Jnl.-Apply";
    begin
        Clear(GenJnlApply);
        Commit();
        GenJnlApply.Run(Rec);
    end;

    procedure ShowDimensionEntries()
    begin
        Rec.ShowDimensions();
    end;

    local procedure AccountTypeOnAfterValidate()
    begin
        if Rec."Account Type" = Rec."Account Type"::Vendor then
            Rec."Document Type" := Rec."Document Type"::Refund
        else
            Rec."Document Type" := Rec."Document Type"::Payment;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidateAccountTypeOnBeforeInit(var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;
}

