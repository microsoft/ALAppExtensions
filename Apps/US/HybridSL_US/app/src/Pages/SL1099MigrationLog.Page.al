// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

page 47200 "SL 1099 Migration Log"
{
    ApplicationArea = All;
    Caption = 'SL 1099 Migration Log';
    PageType = List;
    SourceTable = "SL 1099 Migration Log";
    UsageCategory = Administration;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Vendor No."; Rec."Vendor No.")
                {
                    Caption = 'Vendor No.';
                    ToolTip = 'Specifies the value of the Vendor No. field.';
                }
                field("SL Data Value"; Rec."SL Data Value")
                {
                    Caption = 'SL Data Value';
                    ToolTip = 'Specifies the value of the DfltBox field in the SL Vendor table.';
                }
                field("SL 1099 Box No."; Rec."SL 1099 Box No.")
                {
                    Caption = 'SL Default 1099 Box No.';
                    ToolTip = 'Specifies the SL Default 1099 Box No. based on the SL Data Value field.';
                }
                field("Form Type"; Rec."Form Type")
                {
                    Caption = 'Form Type';
                    ToolTip = 'Specifies the value of the Form Type field. Value can be MISC or NEC.';
                }
                field("BC IRS 1099 Code"; Rec."BC IRS 1099 Code")
                {
                    Caption = 'IRS 1099 Code';
                    ToolTip = 'Specifies the value of the IRS 1099 Code in Business Central based on the SL 1099 Box No. field.';
                }
                field(WasSkipped; Rec.WasSkipped)
                {
                    Caption = 'Was Skipped';
                    ToolTip = 'Specifies whether the record was skipped.';
                }
                field(IsError; Rec.IsError)
                {
                    Caption = 'Is Error';
                    ToolTip = 'Specifies whether the record has an error.';
                }
                field("Error Code"; Rec."Error Code")
                {
                    Caption = 'Error Code';
                    ToolTip = 'Specifies the value of the Error Code field.';
                }
                field("Error Message"; Rec.GetErrorMessage())
                {
                    Caption = 'Error Message';
                    ToolTip = 'Specifies the value of the Error Message field.';
                }
                field("Message Code"; Rec."Message Code")
                {
                    Caption = 'Message Code';
                    ToolTip = 'Specifies the value of the Message Code field.';
                }
                field("Message Text"; Rec."Message Text")
                {
                    Caption = 'Message Text';
                    ToolTip = 'Specifies the value of the Message Text field.';
                }
            }
        }
    }

    procedure FilterOnErrors()
    begin
        Rec.SetRange(IsError, true);
    end;
}