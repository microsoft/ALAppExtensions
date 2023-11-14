// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Finance.Currency;
#if not CLEAN22
using Microsoft.Finance.VAT.Calculation;
#endif

pageextension 11729 "Sales Credit Memo CZL" extends "Sales Credit Memo"
{
    layout
    {
#if not CLEAN22
        modify("VAT Reporting Date")
        {
            Visible = ReplaceVATDateEnabled and VATDateEnabled;
        }
#endif
        movelast(General; "Posting Description")
        addlast(General)
        {
            field("Credit Memo Type CZL"; Rec."Credit Memo Type CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of credit memo (corrective tax document, internal correction, insolvency tax document).';
            }
        }
        addbefore("Location Code")
        {
            field("Reason Code CZL"; Rec."Reason Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the reason code on the entry.';
                Visible = true;
            }
        }
        addafter("Posting Date")
        {
#if not CLEAN22
            field("VAT Date CZL"; Rec."VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'VAT Date (Obsolete)';
                ToolTip = 'Specifies date by which the accounting transaction will enter VAT statement.';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Replaced by VAT Reporting Date.';
                Visible = not ReplaceVATDateEnabled;
            }
#endif
            field("Original Doc. VAT Date CZL"; Rec."Original Doc. VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT date of the original document.';
                Visible = false;
            }
        }
        addafter("Document Date")
        {
            field("Correction CZL"; Rec.Correction)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if you need to post a corrective entry to an account.';
            }
        }
#if not CLEAN22
        addafter("Customer Posting Group")
        {
            field("Customer Posting Group CZL"; Rec."Customer Posting Group")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                Visible = false;
                Importance = Additional;
                ToolTip = 'Specifies the customer''s market type to link business transactions to.';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Replaced by Customer Posting Group field.';
            }
        }
#endif
        addlast("Credit Memo Details")
        {
            field("VAT Registration No. CZL"; Rec."VAT Registration No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT registration number. The field will be used when you do business with partners from EU countries/regions.';
            }
            field("Registration No. CZL"; Rec."Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the registration number of customer.';
            }
            field("Tax Registration No. CZL"; Rec."Tax Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the secondary VAT registration number for the customer.';
                Importance = Additional;
            }
        }
        addafter("Transport Method")
        {
            field("Shipment Method Code CZL"; Rec."Shipment Method Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies how items on the sales document are shipped to the customer.';
            }
        }
        addafter("Currency Code")
        {
            field("VAT Currency Code CZL"; Rec."VAT Currency Code CZL")
            {
                ApplicationArea = Suite;
                Importance = Promoted;
                ToolTip = 'Specifies the currency of VAT on the sales credit memo.';

                trigger OnAssistEdit()
                var
                    ChangeExchangeRate: Page "Change Exchange Rate";
                begin
#if not CLEAN22
#pragma warning disable AL0432
                    if not ReplaceVATDateEnabled then
                        Rec."VAT Reporting Date" := Rec."VAT Date CZL";
#pragma warning restore AL0432
#endif
                    if Rec."VAT Reporting Date" <> 0D then
                        ChangeExchangeRate.SetParameter(Rec."VAT Currency Code CZL", Rec."VAT Currency Factor CZL", Rec."VAT Reporting Date")
                    else
                        ChangeExchangeRate.SetParameter(Rec."VAT Currency Code CZL", Rec."VAT Currency Factor CZL", WorkDate());
                    if ChangeExchangeRate.RunModal() = Action::OK then begin
                        Rec.Validate("VAT Currency Factor CZL", ChangeExchangeRate.GetParameter());
                        CurrPage.Update();
                    end;
                end;

                trigger OnValidate()
                begin
                    CurrPage.SaveRecord();
                end;
            }
        }
        addlast("Foreign Trade")
        {
            field("Language Code CZL"; Rec."Language Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the language to be used on printouts for this document.';
            }
            field("VAT Country/Region Code CZL"; Rec."VAT Country/Region Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT country/region code of customer.';
            }
            field("EU 3-Party Intermed. Role CZL"; Rec."EU 3-Party Intermed. Role CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies when the sales header will use European Union third-party intermediate trade rules. This option complies with VAT accounting standards for EU third-party trade.';
            }
            field(IsIntrastatTransactionCZL; Rec.IsIntrastatTransactionCZL())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Intrastat Transaction';
                Editable = false;
                ToolTip = 'Specifies if the entry is an Intrastat transaction.';
            }
#if not CLEAN22 
            field("Intrastat Exclude CZL"; Rec."Intrastat Exclude CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Intrastat Exclude (Obsolete)';
                ToolTip = 'Specifies that entry will be excluded from intrastat.';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
            }
            field("Physical Transfer CZL"; Rec."Physical Transfer CZL")
            {
                ApplicationArea = SalesReturnOrder;
                Caption = 'Physical Transfer (Obsolete)';
                ToolTip = 'Specifies if there is physical transfer of the item.';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
            }
#endif
        }
        addafter("Foreign Trade")
        {
            group(PaymentsCZL)
            {
                Caption = 'Payment Details';
                field("Variable Symbol CZL"; Rec."Variable Symbol CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the detail information for payment.';
                    Importance = Promoted;
                }
                field("Constant Symbol CZL"; Rec."Constant Symbol CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the additional symbol of bank payments.';
                    Importance = Additional;
                }
                field("Specific Symbol CZL"; Rec."Specific Symbol CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the additional symbol of bank payments.';
                    Importance = Additional;
                }
                field("Bank Account Code CZL"; Rec."Bank Account Code CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code to idenfity bank account of company.';
                }
                field("Bank Name CZL"; Rec."Bank Name CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the bank.';
                }
                field("Bank Account No. CZL"; Rec."Bank Account No. CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number used by the bank for the bank account.';
                    Importance = Promoted;
                }
                field("IBAN CZL"; Rec."IBAN CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank account''s international bank account number.';
                    Importance = Promoted;
                }
                field("SWIFT Code CZL"; Rec."SWIFT Code CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the international bank identifier code (SWIFT) of the bank where you have the account.';
                }
                field("Transit No. CZL"; Rec."Transit No. CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a bank identification number of your own choice.';
                    Importance = Additional;
                }
                field("Bank Branch No. CZL"; Rec."Bank Branch No. CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the bank branch.';
                    Importance = Additional;
                }
            }
        }
    }
#if not CLEAN22

    trigger OnOpenPage()
    begin
        VATDateEnabled := VATReportingDateMgt.IsVATDateEnabled();
        ReplaceVATDateEnabled := ReplaceVATDateMgtCZL.IsEnabled();
    end;

    var
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
#pragma warning disable AL0432
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
#pragma warning restore AL0432
        ReplaceVATDateEnabled: Boolean;
        VATDateEnabled: Boolean;
#endif
}
