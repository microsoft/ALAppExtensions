namespace Microsoft.Sustainability.Ledger;

using Microsoft.Finance.Dimension;

page 6220 "Sustainability Ledger Entries"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Sustainability Ledger Entries';
    PageType = Worksheet;
    SourceTable = "Sustainability Ledger Entry";
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
                    ToolTip = 'Specifies the entry number of the Sustainability Ledger Entry.';
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
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the type of the document.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the document number.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ToolTip = 'Specifies the sustainability account number.';
                }
                field("Account Name"; Rec."Account Name")
                {
                    ToolTip = 'Specifies the sustainability account name.';
                }
                field("Emission Scope"; Rec."Emission Scope")
                {
                    ToolTip = 'Specifies the scope of the emission.';
                }
                field("Account Category"; Rec."Account Category")
                {
                    ToolTip = 'Specifies the sustainability account category.';
                }
                field("Account Subcategory"; Rec."Account Subcategory")
                {
                    ToolTip = 'Specifies the sustainability account subcategory.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the entry.';
                }
                field("Manual Input"; Rec."Manual Input")
                {
                    ToolTip = 'Specifies whether the amounts are input manually.';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ToolTip = 'Specifies the unit of measure of the entry.';
                }
                field("Fuel/Electricity"; Rec."Fuel/Electricity")
                {
                    ToolTip = 'Specifies the fuel or electricity of the entry.';
                }
                field(Distance; Rec.Distance)
                {
                    ToolTip = 'Specifies the distance of the entry.';
                }
                field("Custom Amount"; Rec."Custom Amount")
                {
                    ToolTip = 'Specifies the custom amount of the entry.';
                }
                field("Emission Factor CO2"; Rec."Emission Factor CO2")
                {
                    ToolTip = 'Specifies the emission factor CO2 of the entry.';
                }
                field("Emission Factor CH4"; Rec."Emission Factor CH4")
                {
                    ToolTip = 'Specifies the emission factor CH4 of the entry.';
                }
                field("Emission Factor N2O"; Rec."Emission Factor N2O")
                {
                    ToolTip = 'Specifies the emission factor N2O of the entry.';
                }
                field("Installation Multiplier"; Rec."Installation Multiplier")
                {
                    ToolTip = 'Specifies the installation multiplier of the entry.';
                }
                field("Time Factor"; Rec."Time Factor")
                {
                    ToolTip = 'Specifies the time factor of the entry.';
                }
                field("Emission CO2"; Rec."Emission CO2")
                {
                    ToolTip = 'Specifies the emission CO2 of the entry.';
                }
                field("Emission CH4"; Rec."Emission CH4")
                {
                    ToolTip = 'Specifies the emission CH4 of the entry.';
                }
                field("Emission N2O"; Rec."Emission N2O")
                {
                    ToolTip = 'Specifies the emission N2O of the entry.';
                }
                field("CO2e Emission"; Rec."CO2e Emission")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies total carbon dioxide and other equivalents emission expressing different greenhouse gases impact in terms of the amount of CO2 that would create the same effect.';
                }
                field("Carbon Fee"; Rec."Carbon Fee")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies internal carbon fee that a company charges itself for each unit of CO2 equivalent that it emits.';
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