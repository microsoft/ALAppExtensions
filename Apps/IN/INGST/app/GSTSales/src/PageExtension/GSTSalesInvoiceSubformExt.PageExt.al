// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Finance.GST.Sales;
using Microsoft.Finance.TaxBase;

pageextension 18149 "GST Sales Invoice Subform Ext" extends "Sales Invoice Subform"
{
    layout
    {
        Modify("No.")
        {
            trigger OnAfterValidate()
            begin
                SaveRecords();
                FormatLine();
            end;
        }
        Modify("Quantity")
        {
            trigger OnAfterValidate()
            var
                CalculateTax: Codeunit "Calculate Tax";
            begin
                SaveRecords();
                if (Rec."GST Group Code" <> '') and (Rec."HSN/SAC Code" <> '') then begin
                    Rec.Validate("GST Place Of Supply");
                    CalculateTax.CallTaxEngineOnSalesLine(Rec, xRec);
                end;
            end;
        }
        modify("Location Code")
        {
            Trigger OnAfterValidate()
            var
                CalculateTax: Codeunit "Calculate Tax";
            begin
                CurrPage.SaveRecord();
                CalculateTax.CallTaxEngineOnSalesLine(Rec, xRec);
            end;
        }
        modify(Type)
        {
            Trigger OnAfterValidate()
            begin
                FormatLine();
            end;
        }
        modify("Line Discount %")
        {
            Trigger OnAfterValidate()
            var
                CalculateTax: Codeunit "Calculate Tax";
            begin
                CurrPage.SaveRecord();
                CalculateTax.CallTaxEngineOnSalesLine(Rec, xRec);
            end;
        }
        addafter("Line Discount %")
        {
            field(FOC; Rec.FOC)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if FOC is applicable on Current Line.';

                trigger OnValidate()
                begin
                    if Rec.FOC then
                        Rec.Validate("Line Discount %", 100);
                end;
            }
        }
        modify("Line Discount Amount")
        {
            Trigger OnAfterValidate()
            var
                CalculateTax: Codeunit "Calculate Tax";
            begin
                CurrPage.SaveRecord();
                CalculateTax.CallTaxEngineOnSalesLine(Rec, xRec);
            end;
        }
        addafter("Line Amount")
        {
            field("GST on Assessable Value"; Rec."GST on Assessable Value")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if GST is applicable on assessable value.';

                trigger OnValidate()
                var
                    CalculateTax: Codeunit "Calculate Tax";
                begin
                    CurrPage.SaveRecord();
                    CalculateTax.CallTaxEngineOnSalesLine(Rec, xRec);
                end;
            }
            field("GST Assessable Value (LCY)"; Rec."GST Assessable Value (LCY)")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST Assessable value on which GST is calculated for the line.';

                trigger OnValidate()
                var
                    CalculateTax: Codeunit "Calculate Tax";
                begin
                    CurrPage.SaveRecord();
                    CalculateTax.CallTaxEngineOnSalesLine(Rec, xRec);
                end;
            }
            field("GST Place Of Supply"; Rec."GST Place Of Supply")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST Place of Supply. For example Bill-to Address, Ship-to Address, Location Address etc.';

                trigger OnValidate()
                var
                    CalculateTax: Codeunit "Calculate Tax";
                begin
                    CurrPage.SaveRecord();
                    CalculateTax.CallTaxEngineOnSalesLine(Rec, xRec);
                end;
            }
            field("Price Exclusive of Tax"; Rec."Price Inclusive of Tax")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if prices are exclusive of tax on the line.';

                trigger OnValidate()
                var
                    CalculateTax: Codeunit "Calculate Tax";
                begin
                    CurrPage.SaveRecord();
                    CalculateTax.CallTaxEngineOnSalesLine(Rec, xRec);
                end;
            }
            field("Unit Price Incl. of Tax"; Rec."Unit Price Incl. of Tax")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies unit prices are inclusive of tax on the line.';

                trigger OnValidate()
                var
                    CalculateTax: Codeunit "Calculate Tax";
                begin
                    CurrPage.SaveRecord();
                    CalculateTax.CallTaxEngineOnSalesLine(Rec, xRec);
                end;
            }
            field("GST Credit"; Rec."GST Credit")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the GST credit has to be availed or not.';

                trigger OnValidate()
                var
                    CalculateTax: Codeunit "Calculate Tax";
                begin
                    CurrPage.SaveRecord();
                    CalculateTax.CallTaxEngineOnSalesLine(Rec, xRec);
                end;
            }
            field("Qty. to Invoice"; Rec."Qty. to Invoice")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the quantity of items that remains to be invoiced. It is calculated as Quantity-Qty. Invoiced';
            }
            field("GST Jurisdiction Type"; Rec."GST Jurisdiction Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type related to GST jurisdiction. For example, interstate/intrastate.';
            }
            field("GST Group Code"; Rec."GST Group Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies an identifier for the GST group used to calculate and post GST.';
                Editable = IsHSNSACEditable;
                trigger OnValidate()
                var
                    CalculateTax: Codeunit "Calculate Tax";
                begin
                    CurrPage.SaveRecord();
                    Rec.Validate("GST Place Of Supply");
                    CalculateTax.CallTaxEngineOnSalesLine(Rec, xRec);
                end;
            }
            field("HSN/SAC Code"; Rec."HSN/SAC Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the HSN/SAC code for the calculation of GST on Sales line.';
                Editable = IsHSNSACEditable;
                trigger OnValidate()
                var
                    CalculateTax: Codeunit "Calculate Tax";
                begin
                    CurrPage.SaveRecord();
                    CalculateTax.CallTaxEngineOnSalesLine(Rec, xRec);
                end;
            }
            field("GST Group Type"; Rec."GST Group Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the GST group is assigned for goods or service.';
            }
            field(Exempted; Rec.Exempted)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the current line is exempted of GST Calculation.';

                trigger OnValidate()
                var
                    CalculateTax: Codeunit "Calculate Tax";
                begin
                    CurrPage.SaveRecord();
                    CalculateTax.CallTaxEngineOnSalesLine(Rec, xRec);
                end;
            }
        }
    }
    local Procedure SaveRecords()
    begin
        CurrPage.SaveRecord();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        FormatLine();
    end;

    local procedure FormatLine()
    var
        GSTSalesValidation: Codeunit "GST Sales Validation";
    begin
        GSTSalesValidation.SetHSNSACEditable(Rec, IsHSNSACEditable);
    end;

    var
        IsHSNSACEditable: Boolean;
}
