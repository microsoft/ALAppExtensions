// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

using Microsoft.Finance.TaxEngine.TaxTypeHandler;

page 18247 "Journal Bank Charges"
{
    PageType = list;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Journal Bank Charges";
    DataCaptionFields = "Bank Charge";
    Caption = 'Journal Bank Charges';
    DelayedInsert = true;

    layout
    {
        area(FactBoxes)
        {
            part(TaxInformation; "Tax Information Factbox")
            {
                ApplicationArea = all;
                SubPageLink = "Table ID Filter" = const(18247),
                    "Template Name Filter" = field("Journal Template Name"),
                    "Batch Name Filter" = field("Journal Batch Name"),
                    "Document No. Filter" = field("Bank Charge"),
                    "Line No. Filter" = field("Line No.");
            }
        }
        area(Content)
        {
            repeater(GroupName)
            {
                field("Bank Charge"; Rec."Bank Charge")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank charge code.';

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                    end;
                }
                field("GST Document Type"; Rec."GST Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Document Type of the journal.';

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                    end;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number that refers to the Customer/Vendors/Banks numbering system.';
                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                    end;
                }
                field(Exempted; Rec.Exempted)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the journal is exempted from GST.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank charge amount of the journal line.';

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                    end;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount in local currency as defined in company information.';
                }
                field("GST Group Code"; Rec."GST Group Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Group code for the calculation of GST on Bank Charges line.';

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                    end;
                }
                field("HSN/SAC Code"; Rec."HSN/SAC Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the HSN/SAC code for the calculation of GST on Bank Charges line.';

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                    end;
                }
                field("GST Credit"; Rec."GST Credit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the GST credit has to be availed or not.';
                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                    end;
                }
                field("Foreign Exchange"; Rec."Foreign Exchange")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the transaction has a foreign currency involved.';
                }
                field(LCY; Rec.LCY)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the transaction is in local currency.';
                }
            }
        }
    }
}
