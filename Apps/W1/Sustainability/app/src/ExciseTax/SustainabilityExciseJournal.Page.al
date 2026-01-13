// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ExciseTax;

using Microsoft.Finance.Dimension;
#if not CLEAN28
using Microsoft.Sustainability.Account;
#endif
using System.Utilities;

page 6287 "Sustainability Excise Journal"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Excise Journal';
    Extensible = true;
    PageType = Worksheet;
    UsageCategory = Tasks;
    SourceTable = "Sust. Excise Jnl. Line";
    AnalysisModeEnabled = false;
    SaveValues = true;
    DelayedInsert = true;
    AutoSplitKey = true;
    RefreshOnActivate = true;
    AdditionalSearchTerms = 'CBAM Journal, EPR Journal';

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
                    TableRelation = "Sust. Excise Journal Batch".Name;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch";
                    begin
                        // Assign the Template Name so when create a new batch, the template will be populated
                        SustainabilityExciseJnlBatch."Journal Template Name" := Rec."Journal Template Name";
                        // Assign the Batch Name so the current batch will be selected
                        SustainabilityExciseJnlBatch.Name := Rec."Journal Batch Name";
                        // Filer on the current batch's template
                        SustainabilityExciseJnlBatch.FilterGroup(2);
                        SustainabilityExciseJnlBatch.SetRange("Journal Template Name", Rec."Journal Template Name");
                        SustainabilityExciseJnlBatch.FilterGroup(0);

                        CurrPage.SaveRecord();
                        Commit();

                        if Page.RunModal(Page::"Sust. Excise Jnl. Batches", SustainabilityExciseJnlBatch) = Action::LookupOK then begin
                            ResetFilterOnLinesWithNewBatch(SustainabilityExciseJnlBatch);
                            CurrPage.Update(false);
                        end;
                    end;

                    trigger OnValidate()
                    var
                        SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch";
                    begin
                        CurrPage.SaveRecord();
                        SustainabilityExciseJnlBatch.Get(Rec.GetRangeMax("Journal Template Name"), CurrentJournalBatchName);
                        ResetFilterOnLinesWithNewBatch(SustainabilityExciseJnlBatch);
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(repeater)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the date when the transaction is posted.';
                    ShowMandatory = true;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ToolTip = 'Specifies the value of the Entry Type field.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the type of the document.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the document number.';
                    ShowMandatory = true;
                }
#if not CLEAN28
                field("Sustainability Account No."; Rec."Account No.")
                {
                    ToolTip = 'Specifies the sustainability account number.';
                    ShowMandatory = true;
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This field is no longer required and will be removed in a future release.';
                    ObsoleteTag = '28.0';

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
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This field is no longer required and will be removed in a future release.';
                    ObsoleteTag = '28.0';
                }
#endif
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the journal line.';
                    ShowMandatory = true;
                }
#if not CLEAN28
                field("Sustainability Account Category"; Rec."Account Category")
                {
                    ToolTip = 'Specifies the sustainability account category.';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This field is no longer required and will be removed in a future release.';
                    ObsoleteTag = '28.0';
                }
                field("Sustainability Account Subcategory"; Rec."Account Subcategory")
                {
                    ToolTip = 'Specifies the sustainability account subcategory.';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This field is no longer required and will be removed in a future release.';
                    ObsoleteTag = '28.0';
                }
#endif
                field("Partner Type"; Rec."Partner Type")
                {
                    ToolTip = 'Specifies the value of the Partner Type field.';
                }
                field("Partner No."; Rec."Partner No.")
                {
                    ToolTip = 'Specifies the value of the Partner No. field.';
                }
                field("Source of Emission Data"; Rec."Source of Emission Data")
                {
                    ToolTip = 'Specifies the value of the Source of Emission Data field.';
                }
                field("Emission Verified"; Rec."Emission Verified")
                {
                    ToolTip = 'Specifies the value of the Emission Verified field.';
                    Visible = EnableCBAM;
                }
                field("CBAM Compliance"; Rec."CBAM Compliance")
                {
                    ToolTip = 'Specifies the value of the CBAM Compliance field.';
                    Visible = EnableCBAM;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ToolTip = 'Specifies the value of the Source Type field.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ToolTip = 'Specifies the value of the Source No. field.';
                }
                field("Source Description"; Rec."Source Description")
                {
                    ToolTip = 'Specifies the value of the Source Description field.';
                }
                field("Source Unit of Measure Code"; Rec."Source Unit of Measure Code")
                {
                    ToolTip = 'Specifies the value of the Source Unit of Measure field.';
                }
                field("Source Qty."; Rec."Source Qty.")
                {
                    ToolTip = 'Specifies the value of the Source Qty. field.';
                }
                field("Material Breakdown No."; Rec."Material Breakdown No.")
                {
                    ToolTip = 'Specifies the value of the Material Breakdown No. field.';
                    Visible = EnableEPR;
                }
                field("Material Breakdown Description"; Rec."Material Breakdown Description")
                {
                    ToolTip = 'Specifies the value of the Material Breakdown Description field.';
                    Visible = EnableEPR;
                }
                field("Material Breakdown UOM"; Rec."Material Breakdown UOM")
                {
                    ToolTip = 'Specifies the value of the Material Breakdown Unit of Measure field.';
                    Visible = EnableEPR;
                }
                field("Material Breakdown Weight"; Rec."Material Breakdown Weight")
                {
                    ToolTip = 'Specifies the value of the Material Breakdown Weight field.';
                    Visible = EnableEPR;
                }
                field("CO2e Unit of Measure"; Rec."CO2e Unit of Measure")
                {
                    ToolTip = 'Specifies the value of the CO2e Unit of Measure field.';
                    Visible = EnableCBAM;
                }
                field("Total Embedded CO2e Emission"; Rec."Total Embedded CO2e Emission")
                {
                    ToolTip = 'Specifies the value of the Total Embedded CO2e Emission field.';
                    Visible = EnableCBAM;
                }
                field("CBAM Certificates Required"; Rec."CBAM Certificates Required")
                {
                    ToolTip = 'Specifies the value of the CBAM Certificates Required field.';
                    Visible = EnableCBAM;
                }
                field("Total Emission Cost"; Rec."Total Emission Cost")
                {
                    ToolTip = 'Specifies the value of the Total Emission Cost field.';
                }
                field("Carbon Pricing Paid"; Rec."Carbon Pricing Paid")
                {
                    ToolTip = 'Specifies the value of the Carbon Pricing Paid field.';
                    Visible = EnableCBAM;
                }
                field("Already Paid Emission"; Rec."Already Paid Emission")
                {
                    ToolTip = 'Specifies the value of the Already Paid Emission field.';
                    Visible = EnableCBAM;
                }
                field("Adjusted CBAM Cost"; Rec."Adjusted CBAM Cost")
                {
                    ToolTip = 'Specifies the value of the Adjusted CBAM Cost field.';
                    Visible = EnableCBAM;
                }
                field("Certificate Amount"; Rec."Certificate Amount")
                {
                    ToolTip = 'Specifies the value of the Certificate Amount field.';
                    Visible = EnableCBAM;
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
    }
    actions
    {
        area(Navigation)
        {
            group(Line)
            {
                Caption = 'Line';
                Image = Line;
                group(Account)
                {
                    Caption = 'Account';
                    Image = ChartOfAccounts;
#if not CLEAN28
                    action(Card)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Card';
                        Image = EditLines;
                        RunObject = page "Sustainability Account Card";
                        RunPageLink = "No." = field("Account No.");
                        Visible = false;
                        ObsoleteState = Pending;
                        ObsoleteReason = 'This action is no longer required and will be removed in a future release.';
                        ObsoleteTag = '28.0';
                        ToolTip = 'View or change detailed information about the record on the document or journal line.';
                    }
#endif
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
            action(Register)
            {
                Image = Register;
                ToolTip = 'Finalize the document or journal by Register the amounts and quantities to the related accounts in your company books.';
                ShortCutKey = 'F9';

                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"Sust. Excise Jnl.-Post", Rec);
                end;
            }
            action(Calculate)
            {
                Caption = 'Calculate';
                Image = Calculate;
                ToolTip = 'Calculate the emission of the journal line.';

                trigger OnAction()
                var
                    ConfirmManagement: Codeunit "Confirm Management";
                    SustainabilityExciseCalcMgt: Codeunit "Sust. Excise Cal. Mgt";
                begin
                    if not ConfirmManagement.GetResponseOrDefault(CalculateExciseJournalQst, false) then
                        exit;

                    SustainabilityExciseCalcMgt.Calculate(Rec."Journal Template Name", Rec."Journal Batch Name");
                    CurrPage.Update(true);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(Register_Promoted; Register) { }
                actionref(Calculate_Promoted; Calculate) { }
            }
            group(Category_Category10)
            {
                Caption = 'Line';
                actionref(Dimension_Promoted; Dimension) { }
            }
        }
    }

    trigger OnInit()
    begin
        SetDimensionVisibility();
    end;

    trigger OnOpenPage()
    var
        SustainabilityExciseJnlTemplate: Record "Sust. Excise Journal Template";
        SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch";
        SustainabilityExciseJournalMgt: Codeunit "Sust. Excise Journal Mgt.";
    begin
        if Rec."Journal Batch Name" <> '' then
            CurrentJournalBatchName := Rec."Journal Batch Name";

        SustainabilityExciseJnlTemplate := SustainabilityExciseJournalMgt.SelectTemplate();
        SustainabilityExciseJnlBatch := SustainabilityExciseJournalMgt.SelectBatch(SustainabilityExciseJnlTemplate, CurrentJournalBatchName);

        ResetFilterOnLinesWithNewBatch(SustainabilityExciseJnlBatch);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetupNewLine(xRec);

        Clear(ShortcutDimCode);
    end;

    trigger OnAfterGetRecord()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        InitializeAndSetControlAppearance();
        DimMgt.GetShortcutDimensions(Rec."Dimension Set ID", ShortcutDimCode);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        InitializeAndSetControlAppearance();
    end;

    var
        CurrentJournalBatchName: Code[10];
        ShortcutDimCode: array[8] of Code[20];
        DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8 : Boolean;
        EnableEPR: Boolean;
        EnableCBAM: Boolean;
        CalculateExciseJournalQst: Label 'Do you want to calculate the journal line?';

    local procedure ResetFilterOnLinesWithNewBatch(SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch")
    begin
        CurrentJournalBatchName := SustainabilityExciseJnlBatch.Name;

        Rec.FilterGroup(2);
        Rec.SetRange("Journal Batch Name", SustainabilityExciseJnlBatch.Name);
        Rec.SetRange("Journal Template Name", SustainabilityExciseJnlBatch."Journal Template Name");
        Rec.FilterGroup(0);
    end;

    local procedure SetDimensionVisibility()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.UseShortcutDims(DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);
    end;

    local procedure InitializeAndSetControlAppearance()
    var
        SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch";
    begin
        InitializeControlAppearance();
        SustainabilityExciseJnlBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name");
        EnableEPR := SustainabilityExciseJnlBatch.Type = SustainabilityExciseJnlBatch.Type::EPR;
        EnableCBAM := SustainabilityExciseJnlBatch.Type = SustainabilityExciseJnlBatch.Type::CBAM;
    end;

    local procedure InitializeControlAppearance()
    begin
        EnableEPR := false;
        EnableCBAM := false;
    end;
}