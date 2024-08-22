namespace Microsoft.Finance.Analysis.StatisticalAccount;

using Microsoft.Finance.Dimension;

page 2633 "Statistical Accounts Journal"
{
    Caption = 'Statistical Account Journal';
    PageType = Worksheet;
    SourceTable = "Statistical Acc. Journal Line";
    AdditionalSearchTerms = 'statistical accounts journals,unit account journals,statistical account posting';
    ApplicationArea = All;
    UsageCategory = Tasks;
    AutoSplitKey = true;
    DelayedInsert = true;
    SaveValues = true;

    layout
    {
        area(content)
        {
            group(Control120)
            {
                ShowCaption = false;
                field(CurrentJnlBatchName; CurrentJnlBatchName)
                {
                    ApplicationArea = All;
                    Caption = 'Batch Name';
                    Lookup = true;
                    ToolTip = 'Specifies the name of the journal batch.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        CurrPage.SaveRecord();
                        Rec.LookupBatchName(CurrentJnlBatchName, Rec);
                        CurrPage.Update(false)
                    end;

                    trigger OnValidate()
                    begin
                        if not Rec.CheckName(CurrentJnlBatchName) then
                            Error(BatchDoesNotExistErr);

                        CurrPage.SaveRecord();
                        Rec.SetName(CurrentJnlBatchName, Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(Control1)
            {
                ShowCaption = false;

                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Caption = 'Posting date';
                    ToolTip = 'Specifies the date of the transaction in the statistical ledger, and thereby the fiscal year and period.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'Document No.';
                    ToolTip = 'Specifies the number of the related document.';
                }
                field(StatisticalAccountNo; Rec."Statistical Account No.")
                {
                    ApplicationArea = All;
                    Caption = 'Statistical Account No.';
                    ToolTip = 'Specifies the account number that the entry on the journal line will be posted to.';

                    trigger OnValidate()
                    begin
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the entry.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount of the entry.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup page.';
                    Visible = DimVisible1;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup page.';
                    Visible = DimVisible2;
                }
                field(ShortcutDimCode3; ShortcutDimCode[3])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(3),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    Visible = DimVisible3;
                    ToolTip = 'Specifies the dimension value code linked to the journal line.';

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field(ShortcutDimCode4; ShortcutDimCode[4])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(4),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    Visible = DimVisible4;
                    ToolTip = 'Specifies the dimension value code linked to the journal line.';

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field(ShortcutDimCode5; ShortcutDimCode[5])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(5),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    Visible = DimVisible5;
                    ToolTip = 'Specifies the dimension value code linked to the journal line.';

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field(ShortcutDimCode6; ShortcutDimCode[6])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(6),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    Visible = DimVisible6;
                    ToolTip = 'Specifies the dimension value code linked to the journal line.';

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field(ShortcutDimCode7; ShortcutDimCode[7])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(7),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    Visible = DimVisible7;
                    ToolTip = 'Specifies the dimension value code linked to the journal line.';

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field(ShortcutDimCode8; ShortcutDimCode[8])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(8),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    Visible = DimVisible8;
                    ToolTip = 'Specifies the dimension value code linked to the journal line.';

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
            }
            group(TotalsGroup)
            {
                ShowCaption = false;
                fixed(TotalsGroupFixedLayout)
                {
                    ShowCaption = false;
                    group("Number of Lines")
                    {
                        Caption = 'Number of Lines';
                        field(NumberOfJournalRecords; NumberOfRecords)
                        {
                            ApplicationArea = All;
                            AutoFormatType = 1;
                            ShowCaption = false;
                            Editable = false;
                            ToolTip = 'Specifies the number of lines in the current journal batch.';
                        }
                    }
                    group("Account Name")
                    {
                        Caption = 'Account Name';
                        field(AccName; Rec."Statistical Account Name")
                        {
                            ApplicationArea = All;
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the name of the account.';
                        }
                    }
                    group(BalanceGroup)
                    {
                        Caption = 'Balance';
                        field(Balance; Balance)
                        {
                            ApplicationArea = All;
                            AutoFormatType = 1;
                            Caption = 'Balance';
                            Editable = false;
                            ToolTip = 'Specifies the balance that has accumulated in the journal on the selected line.';
                        }
                    }
                    group(BalanceAfterPostingGroup)
                    {
                        Caption = 'Balance after posting';
                        field(BalanceAfterPosting; BalanceAfterPosting)
                        {
                            ApplicationArea = All;
                            AutoFormatType = 1;
                            Caption = 'BalanceAfterPosting';
                            Editable = false;
                            ToolTip = 'Specifies the balance that has accumulated in the journal selected on the line.';
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            part(Control1900919607; "Dimension Set Entries FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Dimension Set ID" = field("Dimension Set ID");
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Process)
            {
                action(Register)
                {
                    ApplicationArea = All;
                    Caption = 'Register';
                    Image = PostOrder;
                    ToolTip = 'Finalize the document or journal by registering the amounts and quantities to the related accounts in your company books.';
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    begin
                        if Confirm(RegisterBatchQst, true) then
                            Codeunit.Run(Codeunit::"Stat. Acc. Post. Batch", Rec);
                    end;
                }
            }
        }
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                        CurrPage.SaveRecord();
                    end;
                }
                action(LedgerEntries)
                {
                    ApplicationArea = All;
                    Caption = 'Ledger Entries';
                    Image = Ledger;
                    RunObject = Page "Statistical Ledger Entry List";
                    RunPageLink = "Statistical Account No." = field("Statistical Account No.");
                    ToolTip = 'View the statistical ledger entries for the selected account.';
                }
            }
        }

        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                actionref(Register_Promoted; Register)
                {
                }

                actionref(Dimensions_Promoted; Dimensions)
                {
                }
                actionref(LedgerEntries_Promoted; LedgerEntries)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        StatAccTelemetry: Codeunit "Stat. Acc. Telemetry";
    begin
        StatAccTelemetry.LogSetup();
        Rec.SelectJournal(CurrentJnlBatchName);
        SetDimensionVisibility();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        StatAccTelemetry: Codeunit "Stat. Acc. Telemetry";
    begin
        StatAccTelemetry.LogSetup();
        Rec.SetUpNewLine(xRec, CurrentJnlBatchName);
        if Rec."Statistical Account No." <> '' then
            Rec.ShowShortcutDimCode(ShortcutDimCode);
        Clear(ShortcutDimCode);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        NumberOfRecords := Rec.Count();
        Rec.GetBalance(Rec, BalanceAfterPosting, Balance);
        Rec.ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
    end;

    local procedure SetDimensionVisibility()
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimVisible1 := false;
        DimVisible2 := false;
        DimVisible3 := false;
        DimVisible4 := false;
        DimVisible5 := false;
        DimVisible6 := false;
        DimVisible7 := false;
        DimVisible8 := false;

        DimensionManagement.UseShortcutDims(
          DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);

        Clear(DimensionManagement);
    end;

    var
        ShortcutDimCode: array[8] of Code[20];
        CurrentJnlBatchName: Code[10];
        BalanceAfterPosting: Decimal;
        Balance: Decimal;
        NumberOfRecords: Integer;
        DimVisible1: Boolean;
        DimVisible2: Boolean;
        DimVisible3: Boolean;
        DimVisible4: Boolean;
        DimVisible5: Boolean;
        DimVisible6: Boolean;
        DimVisible7: Boolean;
        DimVisible8: Boolean;
        BatchDoesNotExistErr: Label 'The batch name does not exist';
        RegisterBatchQst: Label 'Do you want to register the journal lines?';
}

