pageextension 18091 "GST Purch. Return Order Subfm" extends "Purchase Return Order Subform"
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
#if not CLEAN17
        Modify("Cross-Reference No.")
        {
            trigger OnAfterValidate()
            begin
                SaveRecords();
            end;
        }
#endif
        Modify(Quantity)
        {
            trigger OnAfterValidate()
            begin
                SaveRecords();
            end;
        }
        Modify("Line Amount")
        {
            trigger OnAfterValidate()
            begin
                SaveRecords();
            end;
        }
        Modify("Line Discount %")
        {
            trigger OnAfterValidate()
            begin
                SaveRecords();
            end;
        }
        modify("Location Code")
        {
            trigger OnAfterValidate()
            var
                CalculateTax: Codeunit "Calculate Tax";
            begin
                CurrPage.SaveRecord();
                CalculateTax.CallTaxEngineOnPurchaseLine(Rec, xRec);
            end;
        }
        addafter("Qty. to Assign")
        {
            field("GST Group Code"; Rec."GST Group Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies an identifier for the GST group  used to calculate and post GST.';
            }
            field("GST Group Type"; Rec."GST Group Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the GST group is assigned for goods or service.';
            }
            field(Exempted; Rec.Exempted)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specified whether the return order is exempted form GST or not.';

                trigger OnValidate()
                var
                    CalculateTax: Codeunit "Calculate Tax";
                begin
                    CurrPage.SaveRecord();
                    CalculateTax.CallTaxEngineOnPurchaseLine(Rec, xRec);
                end;
            }
            field("GST Jurisdiction Type"; Rec."GST Jurisdiction Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type related to GST jurisdiction. For example, interstate/intrastate.';
            }
            field("GST Credit"; Rec."GST Credit")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies if the GST credit has to be availed or not.';

                trigger OnValidate()
                var
                    CalculateTax: Codeunit "Calculate Tax";
                begin
                    CurrPage.SaveRecord();
                    CalculateTax.CallTaxEngineOnPurchaseLine(Rec, xRec);
                end;
            }
            field("GST Assessable Value"; Rec."GST Assessable Value")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the assessable value on which GST will be calculated in case of import purchase.';

                trigger OnValidate()
                var
                    CalculateTax: Codeunit "Calculate Tax";
                begin
                    CurrPage.SaveRecord();
                    CalculateTax.CallTaxEngineOnPurchaseLine(Rec, xRec);
                end;
            }
            field("Custom Duty Amount"; Rec."Custom Duty Amount")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the custom duty amount  on the Purchase Return.';

                trigger OnValidate()
                var
                    CalculateTax: Codeunit "Calculate Tax";
                begin
                    CurrPage.SaveRecord();
                    CalculateTax.CallTaxEngineOnPurchaseLine(Rec, xRec);
                end;
            }
        }
    }
    local Procedure SaveRecords()
    begin
        CurrPage.SaveRecord();
    end;
}