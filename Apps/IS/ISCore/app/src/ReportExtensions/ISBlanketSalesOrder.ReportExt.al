// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Sales.Document;

reportextension 14603 "IS Blanket Sales Order" extends "Blanket Sales Order"
{
    dataset
    {
        modify("Sales Line")
        {
            trigger OnAfterAfterGetRecord()
            begin
                    if LastVATCodeUsed = '' then
                        LastVATCodeUsed := "VAT Identifier";
                    if LastVATCodeUsed <> "VAT Identifier" then
                        MoreThanOneVATCode := true;
            end;
        }
        modify("Sales Header")
        {
            trigger OnAfterAfterGetRecord()
            begin
                    MoreThanoneVATCode := false;
                    LastVATCodeUsed := '';
            end;
        }
        modify(VATCounter)
        {
            trigger OnBeforePostDataItem()
            begin
                    if not MoreThanOneVATCode and not AllwaysShowVATSum then
                        CurrReport.Break();
            end;
        }
        modify(VATCounterLCY)
        {
            trigger OnBeforePostDataItem()
            begin
                    if not MoreThanOneVATCode and not AllwaysShowVATSum then
                        CurrReport.Break();
            end;
        }
    }

    requestpage
    {
        layout
        {
            addlast(Options)
            {
                field(AlwaysShowVATSum; AllwaysShowVATSum)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Always Show VAT Summary';
                    ToolTip = 'Specifies that you want the document to include VAT information.';
                }
            }
        }
    }
    var
        AllwaysShowVATSum: Boolean;
        MoreThanOneVATCode: Boolean;
        LastVATCodeUsed: Code[20];
}