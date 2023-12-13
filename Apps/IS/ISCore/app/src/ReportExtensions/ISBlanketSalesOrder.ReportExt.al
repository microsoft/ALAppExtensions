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
#if not CLEAN24
                if IsISCoreAppEnabled then begin
#endif
                    if LastVATCodeUsed = '' then
                        LastVATCodeUsed := "VAT Identifier";
                    if LastVATCodeUsed <> "VAT Identifier" then
                        MoreThanOneVATCode := true;
#if not CLEAN24
                end else begin
                    if LastVATCode = '' then
                        LastVATCode := "VAT Identifier";
                    if LastVATCode <> "VAT Identifier" then
                        MoreThan1VATCode := true;
                end;
#endif
            end;
        }
        modify("Sales Header")
        {
            trigger OnAfterAfterGetRecord()
            begin
#if not CLEAN24
                if IsISCoreAppEnabled then begin
#endif
                    MoreThanoneVATCode := false;
                    LastVATCodeUsed := '';
#if not CLEAN24
                end else begin
                    MoreThan1VATCode := false;
                    LastVATCode := '';
                end;
#endif
            end;
        }
        modify(VATCounter)
        {
            trigger OnBeforePostDataItem()
            begin
#if not CLEAN24
                if IsISCoreAppEnabled then begin
#endif
                    if not MoreThanOneVATCode and not AllwaysShowVATSum then
                        CurrReport.Break();
#if not CLEAN24
                end else
                    if not MoreThan1VATCode and not AlwShowVATSum then
                        CurrReport.Break();
#endif
            end;
        }
        modify(VATCounterLCY)
        {
            trigger OnBeforePostDataItem()
            begin
#if not CLEAN24
                if IsISCoreAppEnabled then begin
#endif
                    if not MoreThanOneVATCode and not AllwaysShowVATSum then
                        CurrReport.Break();
#if not CLEAN24
                end else
                    if not MoreThan1VATCode and not AlwShowVATSum then
                        CurrReport.Break();
#endif
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
#if not CLEAN24
                    // Visible = IsISCoreAppEnabled; Bug 488336
                    // Enabled = IsISCoreAppEnabled; Bug 488336
#endif
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