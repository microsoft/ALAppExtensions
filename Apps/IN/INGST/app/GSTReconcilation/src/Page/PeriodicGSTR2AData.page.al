// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Reconcilation;

page 18285 "Periodic GSTR-2A Data"
{
    Caption = 'Periodic GSTR-2A Data';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Periodic GSTR-2A Data";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Matched; Rec.Matched)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the line is matched with GST Reconciliation line.';
                }
                field("GSTIN No."; Rec."GSTIN No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GSTIN number on the ledger entry.';
                }
                field("State Code"; Rec."State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies State Code on the ledger entry.';
                }
                field(Month; Rec.Month)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the month for which GST reconciliation is created.';
                }
                field(Year; Rec.Year)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the year for which GST Reconciliation is created.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of document that the entry belongs to.';
                }
                field("GSTIN of Supplier"; Rec."GSTIN of Supplier")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the year for which GST Reconciliation is created.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entries document number.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the creation date of the ledger entry.';
                }
                field("Taxable Value"; Rec."Taxable Value")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Taxable Value on the ledger entry.';
                }
                field("Component 1 Amount"; Rec."Component 1 Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Component 1 Amount';
                    ToolTip = 'Specifies the component 1 amount for reconciliation line as defined in GST reconciliation component reconciliation mapping.';
                }
                field("Component 2 Amount"; Rec."Component 2 Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Component 2 Amount';
                    ToolTip = 'Specifies the component 2 amount for reconciliation line as defined in GST reconciliation component reconciliation mapping.';
                }
                field("Component 3 Amount"; Rec."Component 3 Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Component 3 Amount';
                    ToolTip = 'Specifies the component 3 amount for reconciliation line as defined in GST reconciliation component reconciliation mapping.';
                }
                field("Component 4 Amount"; Rec."Component 4 Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Component 4 Amount';
                    ToolTip = 'Specifies the component 4 amount for reconciliation line as defined in GST reconciliation component reconciliation mapping.';
                }
                field("Component 5 Amount"; Rec."Component 5 Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Component 5 Amount';
                    ToolTip = 'Specifies the component 5 amount for reconciliation line as defined in GST reconciliation component reconciliation mapping.';

                }
                field("Component 6 Amount"; Rec."Component 6 Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Component 6 Amount';
                    ToolTip = 'Specifies the component 6 amount for reconciliation line as defined in GST reconciliation component reconciliation mapping.';
                }
                field("Component 7 Amount"; Rec."Component 7 Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Component 7 Amount';
                    ToolTip = 'Specifies the component 7 amount for reconciliation line as defined in GST reconciliation component reconciliation mapping.';
                }
                field("Component 8 Amount"; Rec."Component 8 Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Component 8 Amount';
                    ToolTip = 'Specifies the component 8 amount for reconciliation line as defined in GST reconciliation component reconciliation mapping.';
                }
                field(Reconciled; Rec.Reconciled)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the ledger entry is reconciled.';
                }
                field("Reconciliation Date"; Rec."Reconciliation Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date of reconciliation of the ledger entry.';
                }
            }
        }
    }
}
