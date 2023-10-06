// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Reconcilation;

page 18283 "GST Reconciliation Lines"
{
    Caption = 'GST Reconciliation Lines';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "GST Reconcilation Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("GSTIN No."; Rec."GSTIN No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GSTIN for the reconciliation line.';
                }
                field("Input Service Distribution"; Rec."Input Service Distribution")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the GSTIN is an input service distributor.';
                }
                field("State Code"; Rec."State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the GSTIN is an input service distributor.';
                }
                field(Month; Rec.Month)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the month for which GST reconciliation is created.';
                }
                field(Year; Rec.Year)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the year for which GST reconciliation is created.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type for the reconciliation line.';
                }
                field("GSTIN of Supplier"; Rec."GSTIN of Supplier")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GSTIN of the supplier for reconciliation line.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number for the reconciliation line.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number that refers to the Customer or Vendors numbering system.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the creation date of the reconciliation line.';
                }
                field("Taxable Value"; Rec."Taxable Value")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the taxable value for the reconciliation line.';
                }
                field("Component 1 Amount"; Rec."Component 1 Amount")
                {
                    Caption = 'Component 1 Amount';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the component 1 amount for reconciliation line as defined in GST reconciliation component reconciliation mapping.';
                }
                field("Component 2 Amount"; Rec."Component 2 Amount")
                {
                    Caption = 'Component 2 Amount';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the component 2 amount for reconciliation line as defined in GST reconciliation component reconciliation mapping.';
                }
                field("Component 3 Amount"; Rec."Component 3 Amount")
                {
                    Caption = 'Component 3 Amount';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the component 3 amount for reconciliation line as defined in GST reconciliation component reconciliation mapping.';
                }
                field("Component 4 Amount"; Rec."Component 4 Amount")
                {
                    Caption = 'Component 4 Amount';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the component 4 amount for reconciliation line as defined in GST reconciliation component reconciliation mapping.';
                }
                field("Component 5 Amount"; Rec."Component 5 Amount")
                {
                    Caption = 'Component 5 Amount';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the component 5 amount for reconciliation line as defined in GST reconciliation component reconciliation mapping.';
                }
                field("Component 6 Amount"; Rec."Component 6 Amount")
                {
                    Caption = 'Component 6 Amount';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the component 6 amount for reconciliation line as defined in GST reconciliation component reconciliation mapping.';
                }
                field("Component 7 Amount"; Rec."Component 7 Amount")
                {
                    Caption = 'Component 7 Amount';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the component 7 amount for reconciliation line as defined in GST reconciliation component reconciliation mapping.';
                }
                field("Component 8 Amount"; Rec."Component 8 Amount")
                {
                    Caption = 'Component 8 Amount';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the component 8 amount for reconciliation line as defined in GST reconciliation component reconciliation mapping.';
                }
                field(Reconciled; Rec.Reconciled)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the reconciliation lines have been reconciled.';
                }
                field("Reconciliation Date"; Rec."Reconciliation Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date of reconciliation for the reconciliation line.';
                }
                field("Error Type"; Rec."Error Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the error type if the line is not reconciled.';
                }
            }
        }
    }
}

