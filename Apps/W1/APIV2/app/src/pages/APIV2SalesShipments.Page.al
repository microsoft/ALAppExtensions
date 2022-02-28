page 30062 "APIV2 - Sales Shipments"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Sales Shipment';
    EntitySetCaption = 'Sales Shipments';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityName = 'salesShipment';
    EntitySetName = 'salesShipments';
    InsertAllowed = false;
    ModifyAllowed = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Sales Shipment Header";
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
                field(externalDocumentNumber; "External Document No.")
                {
                    Caption = 'External Document No.';
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
                field(customerPurchaseOrderReference; "Your Reference")
                {
                    Caption = 'Customer Purchase Order Reference',;
                }
                field(customerNumber; "Sell-to Customer No.")
                {
                    Caption = 'Customer No.';

                }
                field(customerName; "Sell-to Customer Name")
                {
                    Caption = 'Customer Name';
                    Editable = false;
                }
                field(billToName; "Bill-to Name")
                {
                    Caption = 'Bill-To Name';
                    Editable = false;
                }
                field(billToCustomerNumber; "Bill-to Customer No.")
                {
                    Caption = 'Bill-To Customer No.';
                }
                field(shipToName; "Ship-to Name")
                {
                    Caption = 'Ship-to Name';
                }
                field(shipToContact; "Ship-to Contact")
                {
                    Caption = 'Ship-to Contact';
                }
                field(sellToAddressLine1; "Sell-to Address")
                {
                    Caption = 'Sell-to Address Line 1';
                }
                field(sellToAddressLine2; "Sell-to Address 2")
                {
                    Caption = 'Sell-to Address Line 2';
                }
                field(sellToCity; "Sell-to City")
                {
                    Caption = 'Sell-to City';
                }
                field(sellToCountry; "Sell-to Country/Region Code")
                {
                    Caption = 'Sell-to Country/Region Code';
                }
                field(sellToState; "Sell-to County")
                {
                    Caption = 'Sell-to State';
                }
                field(sellToPostCode; "Sell-to Post Code")
                {
                    Caption = 'Sell-to Post Code';
                }
                field(billToAddressLine1; "Bill-To Address")
                {
                    Caption = 'Bill-to Address Line 1';
                    Editable = false;
                }
                field(billToAddressLine2; "Bill-To Address 2")
                {
                    Caption = 'Bill-to Address Line 2';
                    Editable = false;
                }
                field(billToCity; "Bill-To City")
                {
                    Caption = 'Bill-to City';
                    Editable = false;
                }
                field(billToCountry; "Bill-To Country/Region Code")
                {
                    Caption = 'Bill-to Country/Region Code';
                    Editable = false;
                }
                field(billToState; "Bill-To County")
                {
                    Caption = 'Bill-to State';
                    Editable = false;
                }
                field(billToPostCode; "Bill-To Post Code")
                {
                    Caption = 'Bill-to Post Code';
                    Editable = false;
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
                field(currencyCode; CurrencyCodeTxt)
                {
                    Caption = 'Currency Code';
                }
                field(orderNumber; "Order No.")
                {
                    Caption = 'Order No.';
                    Editable = false;
                }
                field(paymentTermsCode; "Payment Terms Code")
                {
                    Caption = 'Payment Terms Code';
                }
                field(shipmentMethodCode; "Shipment Method Code")
                {
                    Caption = 'Shipment Method Code';
                }
                field(salesperson; "Salesperson Code")
                {
                    Caption = 'Salesperson';
                }
                field(pricesIncludeTax; "Prices Including VAT")
                {
                    Caption = 'Prices Include Tax';
                    Editable = false;
                }
                part(salesShipmentLines; "APIV2 - Sales Shipment Lines")
                {
                    Caption = 'Lines';
                    EntityName = 'salesShipmentLine';
                    EntitySetName = 'salesShipmentLines';
                    SubPageLink = "Document Id" = Field(SystemId);
                }
                field(lastModifiedDateTime; SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
                field(phoneNumber; "Sell-to Phone No.")
                {
                    Caption = 'Phone No.';
                }
                field(email; "Sell-to E-Mail")
                {
                    Caption = 'Email';
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = Field(SystemId), "Parent Type" = const("Sales Shipment");
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

    trigger OnOpenPage()
    begin
    end;

    var
        CurrencyCodeTxt: Text;

    local procedure SetCalculatedFields()
    var
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        LCYCurrencyCode: Code[10];
    begin
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, "Currency Code");
    end;
}