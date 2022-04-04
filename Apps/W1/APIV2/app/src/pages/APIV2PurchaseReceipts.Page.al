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
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(number; "No.")
                {
                    Caption = 'No.';
                    Editable = false;
                }
                field(invoiceDate; "Document Date")
                {
                    Caption = 'Invoice Date';
                }
                field(postingDate; "Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(dueDate; "Due Date")
                {
                    Caption = 'Due Date';
                }
                field(vendorNumber; "Buy-from Vendor No.")
                {
                    Caption = 'Vendor No.';
                }
                field(vendorName; "Buy-from Vendor Name")
                {
                    Caption = 'Vendor Name';
                    Editable = false;
                }
                field(payToName; "Pay-to Name")
                {
                    Caption = 'Pay-To Name';
                    Editable = false;
                }
                field(payToContact; "Pay-to Contact")
                {
                    Caption = 'Pay-To Contact';
                    Editable = false;
                }
                field(payToVendorNumber; "Pay-to Vendor No.")
                {
                    Caption = 'Pay-To Vendor No.';
                }
                field(shipToName; "Ship-to Name")
                {
                    Caption = 'Ship-To Name';
                }
                field(shipToContact; "Ship-to Contact")
                {
                    Caption = 'Ship-To Contact';
                }
                field(buyFromAddressLine1; "Buy-from Address")
                {
                    Caption = 'Buy-from Address Line 1';
                }
                field(buyFromAddressLine2; "Buy-from Address 2")
                {
                    Caption = 'Buy-from Address Line 2';
                }
                field(buyFromCity; "Buy-from City")
                {
                    Caption = 'Buy-from City';
                }
                field(buyFromCountry; "Buy-from Country/Region Code")
                {
                    Caption = 'Buy-from Country/Region Code';
                }
                field(buyFromState; "Buy-from County")
                {
                    Caption = 'Buy-from State';
                }
                field(buyFromPostCode; "Buy-from Post Code")
                {
                    Caption = 'Buy-from Post Code';
                }
                field(shipToAddressLine1; "Ship-to Address")
                {
                    Caption = 'Ship-to Address Line 1';
                }
                field(shipToAddressLine2; "Ship-to Address 2")
                {
                    Caption = 'Ship-to Address Line 2';
                }
                field(shipToCity; "Ship-to City")
                {
                    Caption = 'Ship-to City';
                }
                field(shipToCountry; "Ship-to Country/Region Code")
                {
                    Caption = 'Ship-to Country/Region Code';
                }
                field(shipToState; "Ship-to County")
                {
                    Caption = 'Ship-to State';
                }
                field(shipToPostCode; "Ship-to Post Code")
                {
                    Caption = 'Ship-to Post Code';
                }
                field(payToAddressLine1; "Pay-to Address")
                {
                    Caption = 'Pay To Address Line 1';
                    Editable = false;
                }
                field(payToAddressLine2; "Pay-to Address 2")
                {
                    Caption = 'Pay To Address Line 2';
                    Editable = false;
                }
                field(payToCity; "Pay-to City")
                {
                    Caption = 'Pay To City';
                    Editable = false;
                }
                field(payToCountry; "Pay-to Country/Region Code")
                {
                    Caption = 'Pay To Country/Region Code';
                    Editable = false;
                }
                field(payToState; "Pay-to County")
                {
                    Caption = 'Pay To State';
                    Editable = false;
                }
                field(payToPostCode; "Pay-to Post Code")
                {
                    Caption = 'Pay To Post Code';
                    Editable = false;
                }
                field(currencyCode; CurrencyCodeTxt)
                {
                    Caption = 'Currency Code';
                }
                field(orderNumber; "Order No.")
                {
                    Caption = 'Order No.';
                    Editable = false;
                }
                part(purchaseReceiptLines; "APIV2 - Purch Receipt Lines")
                {
                    Caption = 'Lines';
                    EntityName = 'purchaseReceiptLine';
                    EntitySetName = 'purchaseReceiptLines';
                    SubPageLink = "Document Id" = Field(SystemId);
                }
                field(lastModifiedDateTime; SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = Field(SystemId), "Parent Type" = const("Purchase Receipt");
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
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, "Currency Code");
    end;

}