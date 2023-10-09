// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Finance.GST.Sales;
using Microsoft.Finance.TaxBase;

pageextension 18161 "GST Sales Return Subform" extends "Sales Return Order Subform"
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
        addafter("Qty. to Assign")
        {
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
            field("GST Group Code"; Rec."GST Group Code")
            {
                ApplicationArea = Basic, Suite;
                Editable = IsHSNSACEditable;
                ToolTip = 'Specifies an identifier for the GST group used to calculate and post GST.';

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
                Editable = IsHSNSACEditable;
                ToolTip = 'Specifies the HSN/SAC code for the calculation of GST on Sales line.';

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
                ToolTip = 'Specifies if the line is exempted from GST.';

                trigger OnValidate()
                var
                    CalculateTax: Codeunit "Calculate Tax";
                begin
                    CurrPage.SaveRecord();
                    CalculateTax.CallTaxEngineOnSalesLine(Rec, xRec);
                end;
            }
            field("GST Jurisdiction Type"; Rec."GST Jurisdiction Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type related to GST jurisdiction. For example, interstate/intrastate.';
            }
            field("Price Exclusive of Tax"; Rec."Price Inclusive of Tax")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies if the price in inclusive of tax for the line.';

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
