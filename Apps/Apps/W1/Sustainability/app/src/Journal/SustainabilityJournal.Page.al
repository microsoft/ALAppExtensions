namespace Microsoft.Sustainability.Journal;

using Microsoft.Finance.Dimension;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Calculation;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Posting;
using Microsoft.Sustainability.Workflow;
using System.Automation;

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
                            SetControlAppearanceFromBatch();
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
                        SetControlAppearanceFromBatch();
                        CurrPage.Update(false);
                    end;
                }
                field(SustJnlBatchApprovalStatus; SustJnlBatchApprovalStatus)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Approval Status';
                    Editable = false;
                    Visible = EnabledSustJnlBatchWorkflowsExist;
                    ToolTip = 'Specifies the approval status for Sustainability journal batch.';
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
                field("Energy Source Code"; Rec."Energy Source Code")
                {
                    ToolTip = 'Specifies the Energy Source Code.';
                }
                field("Manual Input"; Rec."Manual Input")
                {
                    ToolTip = 'Specifies whether the amounts will be input manually.';
                }
                field("Renewable Energy"; Rec."Renewable Energy")
                {
                    ToolTip = 'Specifies the Renewable Energy.';
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
                field("Water Intensity"; Rec."Water Intensity")
                {
                    Editable = Rec."Manual Input";
                    ToolTip = 'Specifies the Water Intensity of the entry.';
                }
                field("Discharged Into Water"; Rec."Discharged Into Water")
                {
                    Editable = Rec."Manual Input";
                    ToolTip = 'Specifies the Discharged Into Water of the entry.';
                }
                field("Waste Intensity"; Rec."Waste Intensity")
                {
                    Editable = Rec."Manual Input";
                    ToolTip = 'Specifies the Waste Intensity of the entry.';
                }
                field("Energy Consumption"; Rec."Energy Consumption")
                {
                    ToolTip = 'Specifies the Energy Consumption.';
                }
                field("Water/Waste Intensity Type"; Rec."Water/Waste Intensity Type")
                {
                    Editable = EnableWater or EnableWaste;
                    ToolTip = 'Specifies the Water/Waste Intensity Type of the entry.';
                }
                field("Water Type"; Rec."Water Type")
                {
                    Editable = EnableWater;
                    ToolTip = 'Specifies the Water Type of the entry.';
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
            part(WorkflowStatusBatch; "Workflow Status FactBox")
            {
                ApplicationArea = Suite;
                Caption = 'Batch Workflows';
                Editable = false;
                Enabled = false;
                ShowFilter = false;
                Visible = ShowWorkflowStatusOnBatch;
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
                action(Approvals)
                {
                    AccessByPermission = TableData "Approval Entry" = R;
                    ApplicationArea = Suite;
                    Caption = 'Approvals';
                    Image = Approvals;
                    ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                    trigger OnAction()
                    var
                        [SecurityFiltering(SecurityFilter::Filtered)]
                        SustJournalLine: Record "Sustainability Jnl. Line";
                        SustApprovalsMgmt: Codeunit "Sust. Approvals Mgmt.";
                    begin
                        GetCurrentlySelectedLines(SustJournalLine);
                        SustApprovalsMgmt.ShowJournalApprovalEntries(SustJournalLine);
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
            group("Request Approval")
            {
                Caption = 'Request Approval';
                group(SendApprovalRequest)
                {
                    Caption = 'Send Approval Request';
                    Image = SendApprovalRequest;
                    action(SendApprovalRequestJournalBatch)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Journal Batch';
                        Enabled = not OpenApprovalEntriesOnBatchOrAnyJnlLineExist and EnabledSustJnlBatchWorkflowsExist;
                        Image = SendApprovalRequest;
                        ToolTip = 'Send all journal lines for approval, also those that you may not see because of filters.';

                        trigger OnAction()
                        var
                            ApprovalsMgmt: Codeunit "Sust. Approvals Mgmt.";
                        begin
                            ApprovalsMgmt.TrySendJournalBatchApprovalRequest(Rec);
                            SetControlAppearanceFromBatch();
                        end;
                    }
                }
                group(CancelApprovalRequest)
                {
                    Caption = 'Cancel Approval Request';
                    Image = Cancel;
                    action(CancelApprovalRequestJournalBatch)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Journal Batch';
                        Enabled = CanCancelApprovalForJnlBatch;
                        Image = CancelApprovalRequest;
                        ToolTip = 'Cancel sending all journal lines for approval, also those that you may not see because of filters.';

                        trigger OnAction()
                        var
                            SustApprovalsMgmt: Codeunit "Sust. Approvals Mgmt.";
                        begin
                            SustApprovalsMgmt.TryCancelJournalBatchApprovalRequest(Rec);
                            SetControlAppearanceFromBatch();
                        end;
                    }
                }
            }
            group(Approval)
            {
                Caption = 'Approval';
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    ToolTip = 'Approve the requested changes.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        SustApprovalsMgmt: Codeunit "Sust. Approvals Mgmt.";
                    begin
                        SustApprovalsMgmt.ApproveSustJournalLineRequest(Rec);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    ToolTip = 'Reject the approval request.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        SustApprovalsMgmt: Codeunit "Sust. Approvals Mgmt.";
                    begin
                        SustApprovalsMgmt.RejectSustJournalLineRequest(Rec);
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    ToolTip = 'Delegate the approval to a substitute approver.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        SustApprovalsMgmt: Codeunit "Sust. Approvals Mgmt.";
                    begin
                        SustApprovalsMgmt.DelegateSustJournalLineRequest(Rec);
                    end;
                }
                action(Comments)
                {
                    ApplicationArea = All;
                    Caption = 'Comments';
                    Image = ViewComments;
                    ToolTip = 'View or add comments for the record.';
                    Visible = OpenApprovalEntriesExistForCurrUser or ApprovalEntriesExistSentByCurrentUser;

                    trigger OnAction()
                    var
                        SustJournalBatch: Record "Sustainability Jnl. Batch";
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if OpenApprovalEntriesOnJnlBatchExist then
                            if SustJournalBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name") then
                                ApprovalsMgmt.GetApprovalComment(SustJournalBatch);
                    end;
                }
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
                actionref(Approvals_Promoted; Approvals) { }
            }
            group("Category_Request Approval")
            {
                Caption = 'Request Approval';

                group("Category_Send Approval Request")
                {
                    Caption = 'Send Approval Request';

                    actionref(SendApprovalRequestJournalBatch_Promoted; SendApprovalRequestJournalBatch)
                    {
                    }
                }
                group("Category_Cancel Approval Request")
                {
                    Caption = 'Cancel Approval Request';

                    actionref(CancelApprovalRequestJournalBatch_Promoted; CancelApprovalRequestJournalBatch)
                    {
                    }
                }
            }
            group(Category_Category7)
            {
                Caption = 'Approve', Comment = 'Generated from the PromotedActionCategories property index 6.';

                actionref(Approve_Promoted; Approve)
                {
                }
                actionref(Reject_Promoted; Reject)
                {
                }
                actionref(Comments_Promoted; Comments)
                {
                }
                actionref(Delegate_Promoted; Delegate)
                {
                }
            }
        }
    }

    var
        SustApprovalMgmt: Codeunit "Sust. Approvals Mgmt.";
        CurrentJournalBatchName: Code[10];
        ShortcutDimCode: array[8] of Code[20];
        DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8 : Boolean;
        IsRecurringView, EnableWater, EnableWaste : Boolean;
        OpenApprovalEntriesOnBatchOrAnyJnlLineExist: Boolean;
        EnabledSustJnlBatchWorkflowsExist: Boolean;
        ShowWorkflowStatusOnBatch: Boolean;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesOnJnlBatchExist: Boolean;
        CanCancelApprovalForJnlBatch: Boolean;
        ApprovalEntriesExistSentByCurrentUser: Boolean;
        SustJnlBatchApprovalStatus: Text[20];

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetupNewLine(xRec);

        Clear(ShortcutDimCode);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        SustApprovalMgmt.CleanSustJournalApprovalStatus(Rec, SustJnlBatchApprovalStatus);
    end;

    trigger OnAfterGetRecord()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.GetShortcutDimensions(Rec."Dimension Set ID", ShortcutDimCode);
        InitializeAndEnableIntensityControl();
        SetControlAppearanceFromBatch();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        InitializeAndEnableIntensityControl();
        SetControlAppearanceFromBatch();

        SustApprovalMgmt.GetSustJnlBatchApprovalStatus(Rec, SustJnlBatchApprovalStatus, EnabledSustJnlBatchWorkflowsExist);
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
        if Rec."Journal Template Name" <> '' then
            if SustainabilityJnlTemplate.Get(Rec."Journal Template Name") then
                if SustainabilityJnlTemplate.Recurring then
                    SetRecurringView();

        if Rec."Journal Batch Name" <> '' then
            CurrentJournalBatchName := Rec."Journal Batch Name";

        SustainabilityJnlTemplate := SustainabilityJournalMgt.SelectTemplate(IsRecurringView);
        SustainabilityJnlBatch := SustainabilityJournalMgt.SelectBatch(SustainabilityJnlTemplate, CurrentJournalBatchName);

        ResetFilterOnLinesWithNewBatch(SustainabilityJnlBatch);
        SetControlAppearanceFromBatch();
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

    local procedure InitializeAndEnableIntensityControl()
    var
        SustAccountCategory: Record "Sustain. Account Category";
    begin
        InitializeIntensityControl();
        if SustAccountCategory.Get(Rec."Account Category") then begin
            EnableWater := SustAccountCategory."Water Intensity" or SustAccountCategory."Discharged Into Water";
            EnableWaste := SustAccountCategory."Waste Intensity";
        end;
    end;

    local procedure InitializeIntensityControl()
    begin
        EnableWater := false;
        EnableWaste := false;
    end;

    local procedure SetControlAppearanceFromBatch()
    var
        SustJournalBatch: Record "Sustainability Jnl. Batch";
    begin
        if not SustJournalBatch.Get(Rec.GetRangeMax("Journal Template Name"), CurrentJournalBatchName) then
            exit;

        ShowWorkflowStatusOnBatch := CurrPage.WorkflowStatusBatch.Page.SetFilterOnWorkflowRecord(SustJournalBatch.RecordId);
        SetApprovalStateForBatch(SustJournalBatch, Rec, OpenApprovalEntriesExistForCurrUser, OpenApprovalEntriesOnJnlBatchExist, OpenApprovalEntriesOnBatchOrAnyJnlLineExist, CanCancelApprovalForJnlBatch, ApprovalEntriesExistSentByCurrentUser, EnabledSustJnlBatchWorkflowsExist);
    end;

    local procedure GetCurrentlySelectedLines(var SustJournalLine: Record "Sustainability Jnl. Line"): Boolean
    begin
        CurrPage.SetSelectionFilter(SustJournalLine);
        exit(SustJournalLine.FindSet());
    end;

    internal procedure SetApprovalStateForBatch(SustJournalBatch: Record "Sustainability Jnl. Batch"; SustJournalLine: Record "Sustainability Jnl. Line"; var OpenApprovalEntriesExistForCurrentUser: Boolean; var OpenApprovalEntriesOnJournalBatchExist: Boolean; var OpenApprovalEntriesOnBatchOrAnyJournalLineExist: Boolean; var CanCancelApprovalForJournalBatch: Boolean; var LocalApprovalEntriesExistSentByCurrentUser: Boolean; var EnabledSustJournalBatchWorkflowsExist: Boolean)
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        SustApprovalsMgmt: Codeunit "Sust. Approvals Mgmt.";
        WorkflowEventHandling: Codeunit "Sust. Workflow Event Handling";
        WorkflowManagement: Codeunit "Workflow Management";
    begin
        OpenApprovalEntriesExistForCurrentUser := OpenApprovalEntriesExistForCurrentUser or ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(SustJournalBatch.RecordId);
        OpenApprovalEntriesOnJournalBatchExist := ApprovalsMgmt.HasOpenApprovalEntries(SustJournalBatch.RecordId);
        OpenApprovalEntriesOnBatchOrAnyJournalLineExist := OpenApprovalEntriesOnJournalBatchExist or SustApprovalsMgmt.HasAnyOpenJournalLineApprovalEntries(SustJournalLine."Journal Template Name", SustJournalLine."Journal Batch Name");
        CanCancelApprovalForJournalBatch := ApprovalsMgmt.CanCancelApprovalForRecord(SustJournalBatch.RecordId);
        LocalApprovalEntriesExistSentByCurrentUser := ApprovalsMgmt.HasApprovalEntriesSentByCurrentUser(SustJournalBatch.RecordId) or ApprovalsMgmt.HasApprovalEntriesSentByCurrentUser(SustJournalLine.RecordId);

        EnabledSustJournalBatchWorkflowsExist := WorkflowManagement.EnabledWorkflowExist(Database::"Sustainability Jnl. Batch", WorkflowEventHandling.RunWorkflowOnSendSustJournalBatchForApprovalCode());
    end;
}