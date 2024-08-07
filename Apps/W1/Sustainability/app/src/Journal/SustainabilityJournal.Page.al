namespace Microsoft.Sustainability.Journal;

using Microsoft.Sustainability.Posting;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Calculation;
using Microsoft.Finance.Dimension;

page 6219 "Sustainability Journal"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Sustainability Journal';
    Extensible = true;
    PageType = Worksheet;
    UsageCategory = Tasks;
    SourceTable = "Sustainability Jnl. Line";
    AnalysisModeEnabled = false;
    SaveValues = true;
    DelayedInsert = true;
    AutoSplitKey = true;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                ShowCaption = false;
                field("Journal Batch Name"; CurrentJournalBatchName)
                {
                    Caption = 'Journal Batch Name';
                    ToolTip = 'Specifies the name of the journal batch.';
                    TableRelation = "Sustainability Jnl. Batch".Name;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
                    begin
                        // Assign the Template Name so when create a new batch, the template will be populated
                        SustainabilityJnlBatch."Journal Template Name" := Rec."Journal Template Name";
                        // Assign the Batch Name so the current batch will be selected
                        SustainabilityJnlBatch.Name := Rec."Journal Batch Name";
                        // Filer on the current batch's template
                        SustainabilityJnlBatch.FilterGroup(2);
                        SustainabilityJnlBatch.SetRange("Journal Template Name", Rec."Journal Template Name");
                        SustainabilityJnlBatch.FilterGroup(0);

                        CurrPage.SaveRecord();
                        Commit();

                        if Page.RunModal(Page::"Sustainability Jnl. Batches", SustainabilityJnlBatch) = Action::LookupOK then begin
                            ResetFilterOnLinesWithNewBatch(SustainabilityJnlBatch);
                            CurrPage.Update(false);
                        end;
                    end;

                    trigger OnValidate()
                    var
                        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
                    begin
                        CurrPage.SaveRecord();
                        SustainabilityJnlBatch.Get(Rec.GetRangeMax("Journal Template Name"), CurrentJournalBatchName);
                        ResetFilterOnLinesWithNewBatch(SustainabilityJnlBatch);
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(repeater)
            {
                field("Recurring Method"; Rec."Recurring Method")
                {
                    ToolTip = 'Specifies the recurring method.';
                    Visible = IsRecurringView;
                    ShowMandatory = IsRecurringView;
                }
                field("Recurring Frequency"; Rec."Recurring Frequency")
                {
                    ToolTip = 'Specifies the recurring frequency.';
                    Visible = IsRecurringView;
                    ShowMandatory = IsRecurringView;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ToolTip = 'Specifies the expiration date.';
                    Visible = IsRecurringView;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the date when the transaction is posted.';
                    ShowMandatory = true;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the type of the document.';

                    trigger OnValidate()
                    begin
                        if Rec."Document Type" = Rec."Document Type"::"GHG Credit" then
                            Error(InvalidDocumentTypeErr, Rec."Document Type");
                    end;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the document number.';
                    Visible = not IsRecurringView;
                    ShowMandatory = true;
                }
                field("Sustainability Account No."; Rec."Account No.")
                {
                    ToolTip = 'Specifies the sustainability account number.';
                    ShowMandatory = true;

                    trigger OnValidate()
                    var
                        DimMgt: Codeunit DimensionManagement;
                    begin
                        DimMgt.GetShortcutDimensions(Rec."Dimension Set ID", ShortcutDimCode);
                        CurrPage.Update();
                    end;
                }
                field("Sustainability Account Name"; Rec."Account Name")
                {
                    ToolTip = 'Specifies the sustainability account name.';
                    DrillDown = false;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the journal line.';
                    ShowMandatory = true;
                }
                field("Sustainability Account Category"; Rec."Account Category")
                {
                    ToolTip = 'Specifies the sustainability account category.';
                }
                field("Sustainability Account Subcategory"; Rec."Account Subcategory")
                {
                    ToolTip = 'Specifies the sustainability account subcategory.';
                }
                field("Manual Input"; Rec."Manual Input")
                {
                    ToolTip = 'Specifies whether the amounts will be input manually.';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ToolTip = 'Specifies the unit of measure of the journal line.';
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Fuel/Electricity"; Rec."Fuel/Electricity")
                {
                    Editable = not Rec."Manual Input";
                    ToolTip = 'Specifies the fuel or electricity of the journal line.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Distance; Rec.Distance)
                {
                    Editable = not Rec."Manual Input";
                    ToolTip = 'Specifies the distance of the journal line.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Custom Amount"; Rec."Custom Amount")
                {
                    Editable = not Rec."Manual Input";
                    ToolTip = 'Specifies the custom amount of the journal line.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Installation Multiplier"; Rec."Installation Multiplier")
                {
                    Editable = not Rec."Manual Input";
                    ToolTip = 'Specifies the installation multiplier of the journal line.';
                }
                field("Time Factor"; Rec."Time Factor")
                {
                    Editable = not Rec."Manual Input";
                    ToolTip = 'Specifies the time factor of the journal line.';
                }
                field("Emission CO2"; Rec."Emission CO2")
                {
                    Editable = Rec."Manual Input";
                    ToolTip = 'Specifies the emission CO2 of the journal line.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Emission CH4"; Rec."Emission CH4")
                {
                    Editable = Rec."Manual Input";
                    ToolTip = 'Specifies the emission CH4 of the journal line.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Emission N2O"; Rec."Emission N2O")
                {
                    Editable = Rec."Manual Input";
                    ToolTip = 'Specifies the emission N2O of the journal line.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ToolTip = 'Specifies the country/region code of the journal line.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ToolTip = 'Specifies the responsibility center of the journal line.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Source Code"; Rec."Source Code")
                {
                    ToolTip = 'Specifies the source code of the journal line.';
                    Visible = false;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ToolTip = 'Specifies the reason code of the journal line.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = DimVisible1;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = DimVisible2;
                }
                field(ShortcutDimCode3; ShortcutDimCode[3])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(3), "Dimension Value Type" = const(Standard), Blocked = const(false));
                    ToolTip = 'Specifies the code for Shortcut Dimension 3.';
                    Visible = DimVisible3;

                    trigger OnValidate()
                    var
                        DimMgt: Codeunit DimensionManagement;
                    begin
                        DimMgt.ValidateShortcutDimValues(3, ShortcutDimCode[3], Rec."Dimension Set ID");
                    end;
                }
                field(ShortcutDimCode4; ShortcutDimCode[4])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(4), "Dimension Value Type" = const(Standard), Blocked = const(false));
                    ToolTip = 'Specifies the code for Shortcut Dimension 4.';
                    Visible = DimVisible4;

                    trigger OnValidate()
                    var
                        DimMgt: Codeunit DimensionManagement;
                    begin
                        DimMgt.ValidateShortcutDimValues(4, ShortcutDimCode[4], Rec."Dimension Set ID");
                    end;
                }
                field(ShortcutDimCode5; ShortcutDimCode[5])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(5), "Dimension Value Type" = const(Standard), Blocked = const(false));
                    ToolTip = 'Specifies the code for Shortcut Dimension 5.';
                    Visible = DimVisible5;

                    trigger OnValidate()
                    var
                        DimMgt: Codeunit DimensionManagement;
                    begin
                        DimMgt.ValidateShortcutDimValues(5, ShortcutDimCode[5], Rec."Dimension Set ID");
                    end;
                }
                field(ShortcutDimCode6; ShortcutDimCode[6])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(6), "Dimension Value Type" = const(Standard), Blocked = const(false));
                    ToolTip = 'Specifies the code for Shortcut Dimension 6.';
                    Visible = DimVisible6;

                    trigger OnValidate()
                    var
                        DimMgt: Codeunit DimensionManagement;
                    begin
                        DimMgt.ValidateShortcutDimValues(6, ShortcutDimCode[6], Rec."Dimension Set ID");
                    end;
                }
                field(ShortcutDimCode7; ShortcutDimCode[7])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(7), "Dimension Value Type" = const(Standard), Blocked = const(false));
                    ToolTip = 'Specifies the code for Shortcut Dimension 7.';
                    Visible = DimVisible7;

                    trigger OnValidate()
                    var
                        DimMgt: Codeunit DimensionManagement;
                    begin
                        DimMgt.ValidateShortcutDimValues(7, ShortcutDimCode[7], Rec."Dimension Set ID");
                    end;
                }
                field(ShortcutDimCode8; ShortcutDimCode[8])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(8), "Dimension Value Type" = const(Standard), Blocked = const(false));
                    ToolTip = 'Specifies the code for Shortcut Dimension 8.';
                    Visible = DimVisible8;

                    trigger OnValidate()
                    var
                        DimMgt: Codeunit DimensionManagement;
                    begin
                        DimMgt.ValidateShortcutDimValues(8, ShortcutDimCode[8], Rec."Dimension Set ID");
                    end;
                }
            }
        }
        area(FactBoxes)
        {
            part(SustainJnlErrorsFactbox; "Sustain. Jnl. Errors Factbox")
            {
                ShowFilter = false;
                SubPageLink = "Journal Template Name" = field("Journal Template Name"),
                              "Journal Batch Name" = field("Journal Batch Name"),
                              "Line No." = field("Line No.");
            }
            part(CategoryFactBox; "Sustain. Category FactBox")
            {
                SubPageLink = Code = field("Account Category");
            }
            part(subcategoryFactBox; "Sustain. Subcategory FactBox")
            {
                SubPageLink = Code = field("Account Subcategory");
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            group(Line)
            {
                Caption = 'Line';
                Image = Line;
                action(CollectAmountFromGL)
                {
                    Caption = 'Collect Amount from G/L Entries';
                    Image = GetEntries;
                    ToolTip = 'Collect custom amount from general ledger entries.';

                    trigger OnAction()
                    var
                        SustainabilityCalcMgt: Codeunit "Sustainability Calc. Mgt.";
                    begin
                        SustainabilityCalcMgt.CollectGeneralLedgerAmount(Rec);
                    end;
                }
                group(Account)
                {
                    Caption = 'Account';
                    Image = ChartOfAccounts;
                    action(Card)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Card';
                        Image = EditLines;
                        RunObject = page "Sustainability Account Card";
                        RunPageLink = "No." = field("Account No.");
                        ToolTip = 'View or change detailed information about the record on the document or journal line.';
                    }
                    action("Ledger Entries")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Ledger Entries';
                        Image = Entries;
                        RunObject = page "Sustainability Ledger Entries";
                        RunPageLink = "Account No." = field("Account No.");
                        ToolTip = 'View the history of transactions that have been posted for the selected record.';
                    }
                }
                action(Dimension)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to the journal and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                        CurrPage.SaveRecord();
                    end;
                }
            }
        }
        area(Processing)
        {
            action(Post)
            {
                Image = Post;
                ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';
                ShortCutKey = 'F9';

                trigger OnAction()
                begin
                    if IsRecurringView then
                        Codeunit.Run(Codeunit::"Sustainability Recur Jnl.-Post", Rec)
                    else
                        Codeunit.Run(Codeunit::"Sustainability Jnl.-Post", Rec);
                end;
            }
            action(Recalculate)
            {
                Caption = 'Recalculate';
                Image = Calculate;
                ToolTip = 'Recalculate the emission of the journal line.';

                trigger OnAction()
                var
                    SustainabilityCalcMgt: Codeunit "Sustainability Calc. Mgt.";
                begin
                    if Rec.FindSet() then
                        repeat
                            SustainabilityCalcMgt.CalculationEmissions(Rec);
                            Rec.Modify(true)
                        until Rec.Next() = 0;
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(Post_Promoted; Post) { }
            }
            group(Category_Category10)
            {
                Caption = 'Line';
                actionref(CollectAmountFromGL_Promoted; CollectAmountFromGL) { }
                actionref(Dimension_Promoted; Dimension) { }
            }
        }
    }

    var
        CurrentJournalBatchName: Code[10];
        ShortcutDimCode: array[8] of Code[20];
        DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8 : Boolean;
        IsRecurringView: Boolean;
        InvalidDocumentTypeErr: Label 'You cannot use Document type %1 on Sustainability Journal Line.', Comment = ' %1 = Document Type';

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetupNewLine(xRec);

        Clear(ShortcutDimCode);
    end;

    trigger OnAfterGetRecord()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.GetShortcutDimensions(Rec."Dimension Set ID", ShortcutDimCode);
    end;

    trigger OnInit()
    begin
        SetDimensionVisibility();
    end;

    trigger OnOpenPage()
    var
        SustainabilityJnlTemplate: Record "Sustainability Jnl. Template";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
    begin
        SustainabilityJnlTemplate := SustainabilityJournalMgt.SelectTemplate(IsRecurringView);
        SustainabilityJnlBatch := SustainabilityJournalMgt.SelectBatch(SustainabilityJnlTemplate, CurrentJournalBatchName);

        ResetFilterOnLinesWithNewBatch(SustainabilityJnlBatch);
    end;

    // The "current" batch and template is "saved" in the filters
    // global variable CurrentJnlBatchName is mostly used to trigger the lookup
    local procedure ResetFilterOnLinesWithNewBatch(SustainabilityJnlBatch: Record "Sustainability Jnl. Batch")
    begin
        CurrentJournalBatchName := SustainabilityJnlBatch.Name;

        Rec.FilterGroup(2);
        Rec.SetRange("Journal Batch Name", SustainabilityJnlBatch.Name);
        Rec.SetRange("Journal Template Name", SustainabilityJnlBatch."Journal Template Name");
        Rec.FilterGroup(0);
    end;

    local procedure SetDimensionVisibility()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.UseShortcutDims(DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);
    end;

    /// <summary>
    /// Set the page to be opened in recurring view.
    /// </summary>
    procedure SetRecurringView()
    var
        RecurringSustainabilityJnl: page "Recurring Sustainability Jnl.";
    begin
        IsRecurringView := true;
        CurrPage.Caption(RecurringSustainabilityJnl.Caption());
    end;
}