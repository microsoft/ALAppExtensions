namespace Microsoft.Finance.Analysis.StatisticalAccount;

using System.Security.User;
using Microsoft.Finance.GeneralLedger.Reversal;
using Microsoft.Finance.Dimension;

page 2634 "Statistical Ledger Entry List"
{
    ApplicationArea = All;
    AdditionalSearchTerms = 'Statistical account ledger entries, Unit account ledger entries, Non-posting account ledger entries';
    Caption = 'Statistical Account Ledger Entries';
    PageType = List;
    SourceTable = "Statistical Ledger Entry";
    UsageCategory = Lists;
    MultipleNewLines = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    SourceTableView = sorting("Posting Date") order(descending);

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                ShowCaption = false;
                Editable = false;
                field(PostingDate; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Caption = 'Posting date';
                    Tooltip = 'Specifies the posting date of the ledger entry.';
                }
                field("No."; Rec."Statistical Account No.")
                {
                    ApplicationArea = All;
                    Caption = 'Statistical Account No.';
                    ToolTip = 'Specifies the statistical account number of the ledger entry.';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of the ledger entry.';
                }

                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Amount';
                    ToolTip = 'Specifies the amount of the ledger entry.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'Entry No.';
                    ToolTip = 'Specifies the entry number of the ledger entry.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the ID of the user who posted the entry. The ID is used, for example, in the change log.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        UserMgt: Codeunit "User Management";
                    begin
                        UserMgt.DisplayUserInformation(Rec."User ID");
                    end;
                }
                field(Reversed; Rec.Reversed)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies whether the entry has been part of a reverse transaction (correction) made by the Reverse action.';
                    Visible = false;
                }
                field("Reversed by Entry No."; Rec."Reversed by Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the number of the correcting entry. If this field shows a number the entry has already been reversed, and it cannot be reversed again.';
                    Visible = false;
                }
                field("Reversed Entry No."; Rec."Reversed Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the number of the original entry that was undone by the reverse transaction.';
                    Visible = false;
                }
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                    ApplicationArea = Dimensions;
                    Editable = false;
                    ToolTip = 'Specifies a reference to a combination of dimension values. The actual values are stored in the Dimension Set Entry table.';
                    Visible = false;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    Editable = false;
                    ToolTip = 'Specifies the code for Global Dimension 1, which is one of dimension codes that you set up in the General Ledger Setup window.';
                    Visible = Dim1Visible;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    Editable = false;
                    ToolTip = 'Specifies the code for Global Dimension 2, which is one of dimension codes that you set up in the General Ledger Setup window.';
                    Visible = Dim2Visible;
                }
                field("Shortcut Dimension 3 Code"; Rec."Shortcut Dimension 3 Code")
                {
                    ApplicationArea = Dimensions;
                    Editable = false;
                    ToolTip = 'Specifies the code for Shortcut Dimension 3, which is one of dimension codes that you set up in the General Ledger Setup window.';
                    Visible = Dim3Visible;
                }
                field("Shortcut Dimension 4 Code"; Rec."Shortcut Dimension 4 Code")
                {
                    ApplicationArea = Dimensions;
                    Editable = false;
                    ToolTip = 'Specifies the code for Shortcut Dimension 4, which is one of dimension codes that you set up in the General Ledger Setup window.';
                    Visible = Dim4Visible;
                }
                field("Shortcut Dimension 5 Code"; Rec."Shortcut Dimension 5 Code")
                {
                    ApplicationArea = Dimensions;
                    Editable = false;
                    ToolTip = 'Specifies the code for Shortcut Dimension 5, which is one of dimension codes that you set up in the General Ledger Setup window.';
                    Visible = Dim5Visible;
                }
                field("Shortcut Dimension 6 Code"; Rec."Shortcut Dimension 6 Code")
                {
                    ApplicationArea = Dimensions;
                    Editable = false;
                    ToolTip = 'Specifies the code for Shortcut Dimension 6, which is one of dimension codes that you set up in the General Ledger Setup window.';
                    Visible = Dim6Visible;
                }
                field("Shortcut Dimension 7 Code"; Rec."Shortcut Dimension 7 Code")
                {
                    ApplicationArea = Dimensions;
                    Editable = false;
                    ToolTip = 'Specifies the code for Shortcut Dimension 7, which is one of dimension codes that you set up in the General Ledger Setup window.';
                    Visible = Dim7Visible;
                }
                field("Shortcut Dimension 8 Code"; Rec."Shortcut Dimension 8 Code")
                {
                    ApplicationArea = Dimensions;
                    Editable = false;
                    ToolTip = 'Specifies the code for Shortcut Dimension 8, which is one of dimension codes that you set up in the General Ledger Setup window.';
                    Visible = Dim8Visible;
                }
            }
        }
        area(factboxes)
        {
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
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(ReverseTransaction)
                {
                    ApplicationArea = All;
                    Caption = 'Reverse Transaction';
                    Ellipsis = true;
                    Image = ReverseRegister;
                    Scope = Repeater;
                    ToolTip = 'Reverse a posted statistical ledger entry.';

                    trigger OnAction()
                    var
                        ReversalEntry: Record "Reversal Entry";
                    begin
                        Clear(ReversalEntry);
                        ReversalEntry."Entry Type" := ReversalEntry."Entry Type"::"Statistical Account";
                        if Rec.Reversed then
                            ReversalEntry.AlreadyReversedEntry(Rec.TableCaption(), Rec."Entry No.");
                        Rec.TestField("Transaction No.");
                        ReversalEntry.ReverseTransaction(Rec."Transaction No.")
                    end;
                }
            }
        }
        area(navigation)
        {
            group("A&ccount")
            {
                action(Dimensions)
                {
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
            }
            group("Periodic Activities")
            {
                Caption = 'Periodic Activities';
                action("Statistical Accounts Journal")
                {
                    ApplicationArea = All;
                    Caption = 'Statistical Accounts Journal';
                    Image = Journal;
                    RunObject = Page "Statistical Accounts Journal";
                    ToolTip = 'Open the statistical accounts journal, for example, to record or post an update to non-transactional data.';
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';
                actionref(Dimensions_Promoted; Dimensions)
                {
                }
                actionref("StatisticalAccountsJournal_Promoted"; "Statistical Accounts Journal")
                {
                }
                actionref("ReverseTransactions_Promoted"; ReverseTransaction)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        StatAccTelemetry: Codeunit "Stat. Acc. Telemetry";
    begin
        StatAccTelemetry.LogDiscovered();

        SetDimVisibility();
        if (Rec.GetFilters() <> '') then
            if (not Rec.Find()) then
                if Rec.FindFirst() then;
    end;

    protected var
        Dim1Visible: Boolean;
        Dim2Visible: Boolean;
        Dim3Visible: Boolean;
        Dim4Visible: Boolean;
        Dim5Visible: Boolean;
        Dim6Visible: Boolean;
        Dim7Visible: Boolean;
        Dim8Visible: Boolean;

    local procedure SetDimVisibility()
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimensionManagement.UseShortcutDims(Dim1Visible, Dim2Visible, Dim3Visible, Dim4Visible, Dim5Visible, Dim6Visible, Dim7Visible, Dim8Visible);
    end;
}
