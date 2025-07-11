// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

using Microsoft.Finance.GST.Base;

page 18200 "Dist. Input GST Credit"
{
    Caption = 'Dist. Input GST Credit';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SaveValues = false;
    SourceTable = "Detailed GST Ledger Entry";
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies number of the entry, as assigned from the specified number series when then entry wise created.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of document that the entry belongs to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry''s document number.';
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line number of an entry of a document.  ';
                }
                field(Type; Rec.Type)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of entries as Item or service.';
                }
                field("No."; Rec."No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the unique identification number of the specified type.';
                }
                field("GST Credit"; Rec."GST Credit")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the GST credit has to be availed or not.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry''s posting date.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                }
                field("Buyer/Seller Reg. No."; Rec."Buyer/Seller Reg. No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the customer''s or vendor''s GST registration number.';
                }
                field("GST Group Code"; Rec."GST Group Code")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an unique identifier for the GST group code used to calculate and post GST.';
                }
                field("HSN/SAC Code"; Rec."HSN/SAC Code")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an unique identifier for the type of HSN or SAC that is used to calculate and post GST.';
                }
                field("GST Component Code"; Rec."GST Component Code")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST component wise entry as CGST/SGST/USTGST or IGST.';
                }
                field("GST Jurisdiction Type"; Rec."GST Jurisdiction Type")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type related to GST jurisdiction. For example, interstate/intrastate.';
                }
                field("GST Base Amount"; Rec."GST Base Amount")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST base amount on which GST will be calculated for a specific line of transaction.';
                }
                field("GST %"; Rec."GST %")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the relevant GST rate for the particular combination of GST group, state. Do not enter percent sign, only the number. For example, if the GST rate is 10%, enter 10 into this field.';
                }
                field("GST Amount"; Rec."GST Amount")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the calculated GST amount calculated for the particular combination of GST group and state.';
                }
                field("Dist. Input GST Credit"; Rec."Dist. Input GST Credit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry of dist. input GST  credit by marking true or false.';
                }
            }
        }
    }
}

