// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ExciseTax;

using Microsoft.Finance.Dimension;

page 6288 "Sust. Excise Taxes Trans. Logs"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Excise Taxes Transaction Logs';
    PageType = Worksheet;
    SourceTable = "Sust. Excise Taxes Trans. Log";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = History;
    DeleteAllowed = false;
    InsertAllowed = false;
    Editable = false;
    AnalysisModeEnabled = true;

    layout
    {
        area(Content)
        {
            repeater(repeater)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the entry number of the Excise Taxes Transaction Logs.';
                }
                field("Template Name"; Rec."Journal Template Name")
                {
                    Caption = 'Template Name';
                    ToolTip = 'Specifies the name of the journal template.';
                }
                field("Batch Name"; Rec."Journal Batch Name")
                {
                    Caption = 'Batch Name';
                    ToolTip = 'Specifies the name of the journal batch.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the date when the transaction is posted.';
                }
                field("Log Type"; Rec."Log Type")
                {
                    ToolTip = 'Specifies the value of the Log Type field.';
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
                }
#if not CLEAN28
                field("Sustainability Account No."; Rec."Account No.")
                {
                    ToolTip = 'Specifies the sustainability account number.';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This field is no longer required and will be removed in a future release.';
                    ObsoleteTag = '28.0';
                }
                field("Sustainability Account Name"; Rec."Account Name")
                {
                    ToolTip = 'Specifies the sustainability account name.';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This field is no longer required and will be removed in a future release.';
                    ObsoleteTag = '28.0';
                }
#endif
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the journal line.';
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
                }
                field("Material Breakdown Description"; Rec."Material Breakdown Description")
                {
                    ToolTip = 'Specifies the value of the Material Breakdown Description field.';
                }
                field("Material Breakdown Weight"; Rec."Material Breakdown Weight")
                {
                    ToolTip = 'Specifies the value of the Material Breakdown Weight field.';
                }
                field("Material Breakdown UOM"; Rec."Material Breakdown UOM")
                {
                    ToolTip = 'Specifies the value of the Material Breakdown Unit of Measure field.';
                }
                field("Total Embedded CO2e Emission"; Rec."Total Embedded CO2e Emission")
                {
                    ToolTip = 'Specifies the value of the Total Embedded CO2e Emission field.';
                }
                field("CO2e Unit of Measure"; Rec."CO2e Unit of Measure")
                {
                    ToolTip = 'Specifies the value of the CO2e Unit of Measure field.';
                }
                field("CBAM Certificates Required"; Rec."CBAM Certificates Required")
                {
                    ToolTip = 'Specifies the value of the CBAM Certificates Required field.';
                }
                field("Total Emission Cost"; Rec."Total Emission Cost")
                {
                    ToolTip = 'Specifies the value of the Total Emission Cost field.';
                }
                field("Carbon Pricing Paid"; Rec."Carbon Pricing Paid")
                {
                    ToolTip = 'Specifies the value of the Carbon Pricing Paid field.';
                }
                field("Already Paid Emission"; Rec."Already Paid Emission")
                {
                    ToolTip = 'Specifies the value of the Already Paid Emission field.';
                }
                field("Adjusted CBAM Cost"; Rec."Adjusted CBAM Cost")
                {
                    ToolTip = 'Specifies the value of the Adjusted CBAM Cost field.';
                }
                field("Certificate Amount"; Rec."Certificate Amount")
                {
                    ToolTip = 'Specifies the value of the Certificate Amount field.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ToolTip = 'Specifies the country/region code of the entry.';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ToolTip = 'Specifies the responsibility center of the entry.';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for the global dimension that is linked to the record or entry for analysis purposes. Two global dimensions, typically for the company''s most important activities, are available on all cards, documents, reports, and lists.';
                    Visible = Dim1Visible;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for the global dimension that is linked to the record or entry for analysis purposes. Two global dimensions, typically for the company''s most important activities, are available on all cards, documents, reports, and lists.';
                    Visible = Dim2Visible;
                }
                field("Shortcut Dimension 3 Code"; Rec."Shortcut Dimension 3 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 3, which is one of dimension codes that you set up in the General Ledger Setup window.';
                    Visible = Dim3Visible;
                }
                field("Shortcut Dimension 4 Code"; Rec."Shortcut Dimension 4 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 4, which is one of dimension codes that you set up in the General Ledger Setup window.';
                    Visible = Dim4Visible;
                }
                field("Shortcut Dimension 5 Code"; Rec."Shortcut Dimension 5 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 5, which is one of dimension codes that you set up in the General Ledger Setup window.';
                    Visible = Dim5Visible;
                }
                field("Shortcut Dimension 6 Code"; Rec."Shortcut Dimension 6 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 6, which is one of dimension codes that you set up in the General Ledger Setup window.';
                    Visible = Dim6Visible;
                }
                field("Shortcut Dimension 7 Code"; Rec."Shortcut Dimension 7 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 7, which is one of dimension codes that you set up in the General Ledger Setup window.';
                    Visible = Dim7Visible;
                }
                field("Shortcut Dimension 8 Code"; Rec."Shortcut Dimension 8 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 8, which is one of dimension codes that you set up in the General Ledger Setup window.';
                    Visible = Dim8Visible;
                }
            }
        }
    }
    actions
    {
        area(navigation)
        {
            group("Entry")
            {
                Caption = 'Entry';
                Image = Entry;
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Scope = Repeater;
                    ToolTip = 'View dimensions, such as area, project, or department, that are assigned to sustainability entry.';

                    trigger OnAction()
                    var
                        DimMgt: Codeunit DimensionManagement;
                    begin
                        DimMgt.ShowDimensionSet(Rec."Dimension Set ID", StrSubstNo(DimensionCaptionLbl, Rec.TableCaption(), Rec."Entry No."));
                    end;
                }
                action(SetDimensionFilter)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Set Dimension Filter';
                    Ellipsis = true;
                    Image = "Filter";
                    ToolTip = 'Limit the entries according to the dimension filters that you specify. NOTE: If you use a high number of dimension combinations, this function may not work and can result in a message that the SQL server only supports a maximum of 2100 parameters.';

                    trigger OnAction()
                    begin
                        Rec.SetFilter("Dimension Set ID", DimensionSetIDFilter.LookupFilter());
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Category4)
            {
                Caption = 'Entry';
                actionref(Dimensions_Promoted; Dimensions) { }
                actionref(SetDimensionFilter_Promoted; SetDimensionFilter) { }
            }
        }
    }

    var
        DimensionSetIDFilter: Page "Dimension Set ID Filter";
        Dim1Visible, Dim2Visible, Dim3Visible, Dim4Visible, Dim5Visible, Dim6Visible, Dim7Visible, Dim8Visible : Boolean;
        DimensionCaptionLbl: Label '%1 %2', Locked = true;

    trigger OnOpenPage()
    begin
        SetDimVisibility();
    end;

    local procedure SetDimVisibility()
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimensionManagement.UseShortcutDims(Dim1Visible, Dim2Visible, Dim3Visible, Dim4Visible, Dim5Visible, Dim6Visible, Dim7Visible, Dim8Visible);
    end;
}