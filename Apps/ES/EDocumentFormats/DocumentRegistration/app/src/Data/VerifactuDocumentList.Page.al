// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Verifactu;
page 10776 "Verifactu Document List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Verifactu Document";
    Caption = 'Verifactu Documents';
    InherentPermissions = X;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("E-Document Entry No."; Rec."E-Document Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'E-Document Entry No.';
                }
                field("Source Document Type"; Rec."Source Document Type")
                {
                    ApplicationArea = All;
                    Caption = 'Source Document Type';
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'Source Document No.';
                }
                field("Verifactu Hash"; Rec."Verifactu Hash")
                {
                    ApplicationArea = All;
                    Caption = 'Verifactu Hash';
                }
                field("Verifactu Posting Date"; Rec."Verifactu Posting Date")
                {
                    ApplicationArea = All;
                    Caption = 'Verifactu Posting Date';
                }
                field("Submission Id"; Rec."Submission Id")
                {
                    ApplicationArea = All;
                    Caption = 'Submission Id';
                }
                field("Submission Status"; Rec."Submission Status")
                {
                    ApplicationArea = All;
                    Caption = 'Submission Status';
                }
            }
        }
    }
}