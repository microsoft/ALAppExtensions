pageextension 18161 "GST Sales Return Subform" extends "Sales Return Order Subform"
{
    layout
    {
        Modify("No.")
        {
            trigger OnAfterValidate()
            begin
                SaveRecords();
            end;
        }
        Modify("Quantity")
        {
            trigger OnAfterValidate()
            begin
                SaveRecords();
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
                ToolTip = 'Specifies an unique identifier for the GST group code used to calculate and post GST.';
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
}