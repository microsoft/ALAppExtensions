// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FADepreciation;

page 18633 "Fixed Asset Shifts"
{
    ApplicationArea = FixedAssets;
    AutoSplitKey = true;
    Caption = 'Fixed Asset Shifts';
    DelayedInsert = true;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "Fixed Asset Shift";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater("")
            {
                field("Depreciation Book Code"; Rec."Depreciation Book Code")
                {
                    Editable = false;
                    ToolTip = 'Specifies the depreciation book code.';
                    ApplicationArea = FixedAssets;
                }
                field("FA Posting Group"; Rec."FA Posting Group")
                {
                    Editable = false;
                    ToolTip = 'Specifies the fixed asset posting group.';
                    ApplicationArea = FixedAssets;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'New field introduced as Fixed Asset Posting Group';
                    ObsoleteTag = '23.0';

                    trigger OnValidate()
                    var
                        FAPostingGroupsErr: Label 'This field has been depricated, use a new field Fixed Asset Posting Group.';
                    begin
                        Error(FAPostingGroupsErr);
                    end;
                }
                field("Fixed Asset Posting Group"; Rec."Fixed Asset Posting Group")
                {
                    Editable = false;
                    ToolTip = 'Specifies the fixed asset posting group.';
                    ApplicationArea = FixedAssets;
                }
                field("Depreciation Starting Date"; Rec."Depreciation Starting Date")
                {
                    ToolTip = 'Specifies the depreciation starting date.';
                    ApplicationArea = FixedAssets;
                }
                field("Depreciation ending Date"; Rec."Depreciation ending Date")
                {
                    ToolTip = 'Specifies the depreciation ending date.';
                    ApplicationArea = FixedAssets;
                }
                field("No. of Depreciation Years"; Rec."No. of Depreciation Years")
                {
                    ToolTip = 'Specifies the number of depreciation years.';
                    ApplicationArea = FixedAssets;
                }
                field("Depreciation Method"; Rec."Depreciation Method")
                {
                    ToolTip = 'Specifies the depreciation method.';
                    ApplicationArea = FixedAssets;
                }
                field("Straight-Line %"; Rec."Straight-Line %")
                {
                    ToolTip = 'Specifies the straight line % where depreciation method is straight line.';
                    ApplicationArea = FixedAssets;
                }
                field("Fixed Depr. Amount"; Rec."Fixed Depr. Amount")
                {
                    Visible = false;
                    ToolTip = 'Specifies the fixed depreciation amount.';
                    ApplicationArea = FixedAssets;
                }
                field("Declining-Balance %"; Rec."Declining-Balance %")
                {
                    ToolTip = 'Specifies the declining balance % where depreciation method is declining balance.';
                    ApplicationArea = FixedAssets;
                }
                field("First User-Defined Depr. Date"; Rec."First User-Defined Depr. Date")
                {
                    Visible = false;
                    ToolTip = 'Specifies the first user-defined depreciation date.';
                    ApplicationArea = FixedAssets;
                }
                field("Depreciation Table Code"; Rec."Depreciation Table Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the depreciation table code.';
                    ApplicationArea = FixedAssets;
                }
                field("Final Rounding Amount"; Rec."Final Rounding Amount")
                {
                    Visible = false;
                    ToolTip = 'Specifies the final rounding amount';
                    ApplicationArea = FixedAssets;
                }
                field("Ending Book Value"; Rec."Ending Book Value")
                {
                    Visible = false;
                    ToolTip = 'Specifies the ending book value.';
                    ApplicationArea = FixedAssets;
                }
                field("FA Exchange Rate"; Rec."FA Exchange Rate")
                {
                    Visible = false;
                    ToolTip = 'Specifies the fixed asset exchange rate with FA additional currency.';
                    ApplicationArea = FixedAssets;
                }
                field("Use FA Ledger Check"; Rec."Use FA Ledger Check")
                {
                    Visible = false;
                    ToolTip = 'Specifies if fixed asset ledger check is used.';
                    ApplicationArea = FixedAssets;
                }
                field("Depr. below Zero %"; Rec."Depr. below Zero %")
                {
                    Visible = false;
                    ToolTip = 'Specifies the rate of depreciation after book value of asset is zero.';
                    ApplicationArea = FixedAssets;
                }
                field("Fixed Depr. Amount below Zero"; Rec."Fixed Depr. Amount below Zero")
                {
                    Visible = false;
                    ToolTip = 'Specifies the fixed depreciation amount after asset''s book value is zero.';
                    ApplicationArea = FixedAssets;
                }
                field("Projected Disposal Date"; Rec."Projected Disposal Date")
                {
                    Visible = false;
                    ToolTip = 'Specifies the projected disposal date.';
                    ApplicationArea = FixedAssets;
                }
                field("Projected Proceeds on Disposal"; Rec."Projected Proceeds on Disposal")
                {
                    Visible = false;
                    ToolTip = 'Specifies the projected proceeds on disposal.';
                    ApplicationArea = FixedAssets;
                }
                field("Depr. Starting Date (Custom 1)"; Rec."Depr. Starting Date (Custom 1)")
                {
                    Visible = false;
                    ToolTip = 'Specifies the depreciation starting date where depreciation method is custom 1.';
                    ApplicationArea = FixedAssets;
                }
                field("Depr. ending Date (Custom 1)"; Rec."Depr. ending Date (Custom 1)")
                {
                    Visible = false;
                    ToolTip = 'Specifies the depreciation ending date where depreciation method is custom 1.';
                    ApplicationArea = FixedAssets;
                }
                field("Accum. Depr. % (Custom 1)"; Rec."Accum. Depr. % (Custom 1)")
                {
                    Visible = false;
                    ToolTip = 'Specifies the accumulated depreciation % where depreciation method is custom 1.';
                    ApplicationArea = FixedAssets;
                }
                field("Depr. This Year % (Custom 1)"; Rec."Depr. This Year % (Custom 1)")
                {
                    Visible = false;
                    ToolTip = 'Specifies the depreciation this year % where depreciation method is custom 1.';
                    ApplicationArea = FixedAssets;
                }
                field("Use Half-Year Convention"; Rec."Use Half-Year Convention")
                {
                    Visible = false;
                    ToolTip = 'Specifies if use half-year convention is used for depreciation calculation.';
                    ApplicationArea = FixedAssets;
                }
                field("Property Class (Custom 1)"; Rec."Property Class (Custom 1)")
                {
                    Visible = false;
                    ToolTip = 'Specifies the property class where depreciation method is custom 1.';
                    ApplicationArea = FixedAssets;
                }
                field("Use DB% First Fiscal Year"; Rec."Use DB% First Fiscal Year")
                {
                    Visible = false;
                    ToolTip = 'Specifies if the depreciation need to be calculated for DB% in the first year, where retrospective effect of depreciation needs to be calculated.';
                    ApplicationArea = FixedAssets;
                }
                field("Temp. ending Date"; Rec."Temp. ending Date")
                {
                    Visible = false;
                    ToolTip = 'Specifies the temp. ending date.';
                    ApplicationArea = FixedAssets;
                }
                field("Temp. Fixed Depr. Amount"; Rec."Temp. Fixed Depr. Amount")
                {
                    Visible = false;
                    ToolTip = 'Specifies the temp. fixed depreciation amount.';
                    ApplicationArea = FixedAssets;
                }
                field("Shift Type"; Rec."Shift Type")
                {
                    ToolTip = 'Specifies the shift type.';
                    ApplicationArea = FixedAssets;
                }
                field("Industry Type"; Rec."Industry Type")
                {
                    ToolTip = 'Specifies the industry type.';
                    ApplicationArea = FixedAssets;
                }
                field("Used No. of Days"; Rec."Used No. of Days")
                {
                    ToolTip = 'Specifies the used number of days.';
                    ApplicationArea = FixedAssets;
                }
                field(Disposed; Disposed)
                {
                    Caption = 'Disposed';
                    Editable = false;
                    ToolTip = 'Specifies if the fixed asset has been dosposed off.';
                    ApplicationArea = FixedAssets;
                }
                field("Book Value"; Rec."Book Value")
                {
                    ToolTip = 'Specifies the book value of the asset.';
                    ApplicationArea = FixedAssets;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Disposed := Rec."Disposal Date" > 0D;
        if Disposed then
            Rec."Book Value" := 0;
    end;

    var
        Disposed: Boolean;
}
