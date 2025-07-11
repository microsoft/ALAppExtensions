namespace Microsoft.API.V2;

using Microsoft.Purchases.History;
using Microsoft.Integration.Graph;

page 30064 "APIV2 - Purchase Receipts"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Purchase Receipt';
    EntitySetCaption = 'Purchase Receipts';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    EntityName = 'purchaseReceipt';
    EntitySetName = 'purchaseReceipts';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Purch. Rcpt. Header";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'No.';
                    Editable = false;
                }
                field(invoiceDate; Rec."Document Date")
                {
                    Caption = 'Invoice Date';
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due Date';
                }
                field(vendorNumber; Rec."Buy-from Vendor No.")
                {
                    Caption = 'Vendor No.';
                }
                field(vendorName; Rec."Buy-from Vendor Name")
                {
                    Caption = 'Vendor Name';
                    Editable = false;
                }
                field(payToName; Rec."Pay-to Name")
                {
                    Caption = 'Pay-To Name';
                    Editable = false;
                }
                field(payToContact; Rec."Pay-to Contact")
                {
                    Caption = 'Pay-To Contact';
                    Editable = false;
                }
                field(payToVendorNumber; Rec."Pay-to Vendor No.")
                {
                    Caption = 'Pay-To Vendor No.';
                }
                field(shipToName; Rec."Ship-to Name")
                {
                    Caption = 'Ship-To Name';
                }
                field(shipToContact; Rec."Ship-to Contact")
                {
                    Caption = 'Ship-To Contact';
                }
                field(buyFromAddressLine1; Rec."Buy-from Address")
                {
                    Caption = 'Buy-from Address Line 1';
                }
                field(buyFromAddressLine2; Rec."Buy-from Address 2")
                {
                    Caption = 'Buy-from Address Line 2';
                }
                field(buyFromCity; Rec."Buy-from City")
                {
                    Caption = 'Buy-from City';
                }
                field(buyFromCountry; Rec."Buy-from Country/Region Code")
                {
                    Caption = 'Buy-from Country/Region Code';
                }
                field(buyFromState; Rec."Buy-from County")
                {
                    Caption = 'Buy-from State';
                }
                field(buyFromPostCode; Rec."Buy-from Post Code")
                {
                    Caption = 'Buy-from Post Code';
                }
                field(shipToAddressLine1; Rec."Ship-to Address")
                {
                    Caption = 'Ship-to Address Line 1';
                }
                field(shipToAddressLine2; Rec."Ship-to Address 2")
                {
                    Caption = 'Ship-to Address Line 2';
                }
                field(shipToCity; Rec."Ship-to City")
                {
                    Caption = 'Ship-to City';
                }
                field(shipToCountry; Rec."Ship-to Country/Region Code")
                {
                    Caption = 'Ship-to Country/Region Code';
                }
                field(shipToState; Rec."Ship-to County")
                {
                    Caption = 'Ship-to State';
                }
                field(shipToPostCode; Rec."Ship-to Post Code")
                {
                    Caption = 'Ship-to Post Code';
                }
                field(payToAddressLine1; Rec."Pay-to Address")
                {
                    Caption = 'Pay To Address Line 1';
                    Editable = false;
                }
                field(payToAddressLine2; Rec."Pay-to Address 2")
                {
                    Caption = 'Pay To Address Line 2';
                    Editable = false;
                }
                field(payToCity; Rec."Pay-to City")
                {
                    Caption = 'Pay To City';
                    Editable = false;
                }
                field(payToCountry; Rec."Pay-to Country/Region Code")
                {
                    Caption = 'Pay To Country/Region Code';
                    Editable = false;
                }
                field(payToState; Rec."Pay-to County")
                {
                    Caption = 'Pay To State';
                    Editable = false;
                }
                field(payToPostCode; Rec."Pay-to Post Code")
                {
                    Caption = 'Pay To Post Code';
                    Editable = false;
                }
                field(currencyCode; CurrencyCodeTxt)
                {
                    Caption = 'Currency Code';
                }
                field(orderNumber; Rec."Order No.")
                {
                    Caption = 'Order No.';
                    Editable = false;
                }
                part(purchaseReceiptLines; "APIV2 - Purch Receipt Lines")
                {
                    Caption = 'Lines';
                    EntityName = 'purchaseReceiptLine';
                    EntitySetName = 'purchaseReceiptLines';
                    SubPageLink = "Document Id" = field(SystemId);
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = field(SystemId), "Parent Type" = const("Purchase Receipt");
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
    end;

    var
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        LCYCurrencyCode: Code[10];
        CurrencyCodeTxt: Text;

    local procedure SetCalculatedFields()
    begin
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, Rec."Currency Code");
    end;

}