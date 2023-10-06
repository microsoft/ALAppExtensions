// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

page 5315 "Dimensions SIE"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Dimensions SIE';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Dimension SIE";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                ShowCaption = false;
                field("Dimension Code"; Rec."Dimension Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = not LookupModeActive;
                    ToolTip = 'Specifies a dimension code.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = not LookupModeActive;
                    ToolTip = 'Specifies a descriptive name for the dimension.';
                }
                field(Selected; Rec.Selected)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if this dimension should be used when importing or exporting G/L data.';
                }
                field("SIE Dimension"; Rec."SIE Dimension")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = not LookupModeActive;
                    ToolTip = 'Specifies the number you want to assign to the dimension.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        LookupModeActive := false;
    end;

#if CLEAN22
    trigger OnOpenPage()
    begin
        if CurrPage.LookupMode then
            LookupModeActive := true;
    end;
#else
    trigger OnOpenPage()
    var
        SIEManagement: Codeunit "SIE Management";
    begin
        if not SIEManagement.IsFeatureEnabled() then
            if not IsRunFromWizard then begin
                Page.Run(Page::"SIE Dimensions");
                Error('');
            end;

        if CurrPage.LookupMode then
            LookupModeActive := true;
    end;
#endif

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if LookupModeActive then
            Error(CannotEditInLookupModeErr);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        if LookupModeActive then
            Error(CannotEditInLookupModeErr);
    end;

    var
#if not CLEAN22
        IsRunFromWizard: Boolean;
#endif
        [InDataSet]
        LookupModeActive: Boolean;
        CannotEditInLookupModeErr: label 'SIE dimension cannot be added or deleted when the page is opened in lookup mode. To add, remove or edit SIE dimensions, search for the page Dimensions SIE and open it.';
#if not CLEAN22
#pragma warning disable AS0072
    [Obsolete('Feature will be enabled by default.', '22.0')]
    procedure SetRunFromWizard(RunFromWizard: Boolean)
    begin
        IsRunFromWizard := RunFromWizard;
    end;
#pragma warning restore AS0072
#endif
}
