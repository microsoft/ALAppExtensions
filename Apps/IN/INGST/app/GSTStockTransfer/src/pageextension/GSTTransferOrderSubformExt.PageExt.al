// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.StockTransfer;

using Microsoft.Finance.TaxEngine.UseCaseBuilder;
using Microsoft.Inventory.Transfer;

pageextension 18396 "GST Transfer Order Subform Ext" extends "Transfer Order Subform"
{

    layout
    {
        modify(Quantity)
        {
            trigger OnAfterValidate()
            var
                TaxCaseExecution: Codeunit "Use Case Execution";
            begin
                CurrPage.SaveRecord();
                TaxCaseExecution.HandleEvent('OnAfterTransferPrirce', Rec, '', 0);
            end;
        }
        addafter(Quantity)
        {
            field(Amount; Rec.Amount)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the amount for the item on the transfer line.';
            }
            field("Transfer Price"; Rec."Transfer Price")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Transfer Price for the item on the transfer line.';

                trigger OnValidate()
                begin
                    CurrPage.SaveRecord();
                end;
            }
            field("GST Credit"; Rec."GST Credit")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the GST credit should be availed or not';
                trigger OnValidate()
                var
                    TaxCaseExecution: Codeunit "Use Case Execution";
                begin
                    CurrPage.SaveRecord();
                    TaxCaseExecution.HandleEvent('OnAfterTransferPrirce', Rec, '', 0);
                end;
            }
        }
        addafter("Receipt Date")
        {
            field("Custom Duty Amount"; Rec."Custom Duty Amount")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the custom duty amount  on the transfer line.';

                trigger OnValidate()
                var
                    TaxCaseExecution: Codeunit "Use Case Execution";
                begin
                    CurrPage.SaveRecord();
                    TaxCaseExecution.HandleEvent('OnAfterTransferPrirce', Rec, '', 0);
                end;
            }
            field("GST Assessable Value"; Rec."GST Assessable Value")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST assessable value on the transfer line.';

                trigger OnValidate()
                var
                    TaxCaseExecution: Codeunit "Use Case Execution";
                begin
                    CurrPage.SaveRecord();
                    TaxCaseExecution.HandleEvent('OnAfterTransferPrirce', Rec, '', 0);
                end;
            }
            field("GST Group Code"; Rec."GST Group Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST Group code for the calculation of GST on transfer line.';

                trigger OnValidate()
                var
                    TaxCaseExecution: Codeunit "Use Case Execution";
                begin
                    TaxCaseExecution.HandleEvent('OnAfterTransferPrirce', Rec, '', 0);
                end;
            }
            field("HSN/SAC Code"; Rec."HSN/SAC Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the HSN/SAC code for the calculation of GST on transfer line.';

                trigger OnValidate()
                var
                    TaxCaseExecution: Codeunit "Use Case Execution";
                begin
                    TaxCaseExecution.HandleEvent('OnAfterTransferPrirce', Rec, '', 0);
                end;
            }
        }
    }
}
