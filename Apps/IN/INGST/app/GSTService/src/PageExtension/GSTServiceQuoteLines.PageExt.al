// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Services;

using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Service.Document;

pageextension 18456 "GST Service Quote Lines" extends "Service Quote Lines"
{
    layout
    {
        addfirst(factboxes)
        {
            part(TaxInformation; "Tax Information Factbox")
            {
                ApplicationArea = all;
                SubPageLink = "Table ID Filter" = const(5902),
                "Document Type Filter" = field("Document Type"),
                    "Document No. Filter" = field("Document No."),
                    "Line No. Filter" = field("Line No.");
            }
        }
        modify("Unit Price")
        {
            trigger OnAfterValidate()
            begin
                CurrPage.SaveRecord();
            end;
        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            begin
                CurrPage.SaveRecord();
                CalculateTax.CallTaxEngineOnServiceLine(Rec, xRec);
            end;
        }
        modify("Line Discount %")
        {
            trigger OnAfterValidate()
            begin
                CurrPage.SaveRecord();
                CalculateTax.CallTaxEngineOnServiceLine(Rec, xRec);
            end;
        }
        modify("Line Discount Amount")
        {
            trigger OnAfterValidate()
            begin
                CurrPage.SaveRecord();
                CalculateTax.CallTaxEngineOnServiceLine(Rec, xRec);
            end;
        }
        modify(Type)
        {
            Trigger OnAfterValidate()
            begin
                FormatLine();
            end;
        }
        modify("No.")
        {
            trigger OnAfterValidate()
            begin
                FormatLine();
            end;
        }
        addafter("Line Amount")
        {
            field("GST Place Of Supply"; Rec."GST Place Of Supply")
            {
                ApplicationArea = Basic, Suite;
                Editable = IsHSNSACEditable;
                ToolTip = 'Specifies on which location state code system should consider for GST calculation in case of sale of product or service.';

                trigger OnValidate()
                begin
                    CalculateTax.CallTaxEngineOnServiceLine(Rec, xRec);
                end;
            }
            field("GST Group Code"; Rec."GST Group Code")
            {
                ApplicationArea = Basic, Suite;
                Editable = IsHSNSACEditable;
                ToolTip = 'Specifies an identifier for the GST Group  used to calculate and post GST.';
                trigger OnValidate()
                begin
                    CurrPage.SaveRecord();
                    CalculateTax.CallTaxEngineOnServiceLine(Rec, xRec);
                end;
            }
            field("HSN/SAC Code"; Rec."HSN/SAC Code")
            {
                ApplicationArea = Basic, Suite;
                Editable = IsHSNSACEditable;
                ToolTip = 'Specifies an unique identifier for the type of HSN or SAC that is used to calculate and post GST.';
                trigger OnValidate()
                begin
                    CurrPage.SaveRecord();
                    CalculateTax.CallTaxEngineOnServiceLine(Rec, xRec);
                end;
            }
            field("GST Group Type"; Rec."GST Group Type")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies that the GST Group assigned for goods or service.';
            }
            field("GST Jurisdiction Type"; Rec."GST Jurisdiction Type")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                Tooltip = 'Specifies the entries related to gst jurisdiction, for example interstate or intrastate.';
            }
            field("Exempted"; Rec."Exempted")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies whether the Service is exempted from GST or not.';
                trigger OnValidate()
                begin
                    CurrPage.SaveRecord();
                    CalculateTax.CallTaxEngineOnServiceLine(Rec, xRec);
                end;
            }
            field("GST On Assessable Value"; Rec."GST On Assessable Value")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the assessable value on which GST will be calculated.';

                trigger OnValidate()
                begin
                    CurrPage.SaveRecord();
                    CalculateTax.CallTaxEngineOnServiceLine(Rec, xRec);
                end;
            }
            field("GST Assessable Value (LCY)"; Rec."GST Assessable Value (LCY)")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the assessable value in local currency on which GST will be calculated.';

                trigger OnValidate()
                begin
                    CurrPage.SaveRecord();
                    CalculateTax.CallTaxEngineOnServiceLine(Rec, xRec);
                end;
            }
            field("Non-GST Line"; Rec."Non-GST Line")
            {
                ApplicationArea = Basic, Suite;
                ToolTIp = 'Specifies whether the line item is applicable for GST or not.';

                trigger OnValidate()
                begin
                    CurrPage.SaveRecord();
                    CalculateTax.CallTaxEngineOnServiceLine(Rec, xRec);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        FormatLine();
    end;

    local procedure FormatLine()
    var
        GSTServiceValidations: Codeunit "GST Service Validations";
    begin
        GSTServiceValidations.SetHSNSACEditable(Rec, IsHSNSACEditable);
    end;

    var
        CalculateTax: Codeunit "Calculate Tax";
        IsHSNSACEditable: Boolean;
}
