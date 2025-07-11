namespace Microsoft.API.V2;

using Microsoft.Sales.History;
using Microsoft.Integration.Graph;

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
                field(externalDocumentNumber; Rec."External Document No.")
                {
                    Caption = 'External Document No.';
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
                field(customerPurchaseOrderReference; Rec."Your Reference")
                {
                    Caption = 'Customer Purchase Order Reference',;
                }
                field(customerId; Rec."Customer Id")
                {
                    Caption = 'Customer Id';
                }
                field(customerNumber; Rec."Sell-to Customer No.")
                {
                    Caption = 'Customer No.';
                }
                field(customerName; Rec."Sell-to Customer Name")
                {
                    Caption = 'Customer Name';
                    Editable = false;
                }
                field(billToCustomerId; Rec."Bill-to Customer Id")
                {
                    Caption = 'Bill-to Customer Id';
                }
                field(billToName; Rec."Bill-to Name")
                {
                    Caption = 'Bill-To Name';
                    Editable = false;
                }
                field(billToCustomerNumber; Rec."Bill-to Customer No.")
                {
                    Caption = 'Bill-To Customer No.';
                }
                field(shipToName; Rec."Ship-to Name")
                {
                    Caption = 'Ship-to Name';
                }
                field(shipToContact; Rec."Ship-to Contact")
                {
                    Caption = 'Ship-to Contact';
                }
                field(sellToAddressLine1; Rec."Sell-to Address")
                {
                    Caption = 'Sell-to Address Line 1';
                }
                field(sellToAddressLine2; Rec."Sell-to Address 2")
                {
                    Caption = 'Sell-to Address Line 2';
                }
                field(sellToCity; Rec."Sell-to City")
                {
                    Caption = 'Sell-to City';
                }
                field(sellToCountry; Rec."Sell-to Country/Region Code")
                {
                    Caption = 'Sell-to Country/Region Code';
                }
                field(sellToState; Rec."Sell-to County")
                {
                    Caption = 'Sell-to State';
                }
                field(sellToPostCode; Rec."Sell-to Post Code")
                {
                    Caption = 'Sell-to Post Code';
                }
                field(billToAddressLine1; Rec."Bill-To Address")
                {
                    Caption = 'Bill-to Address Line 1';
                    Editable = false;
                }
                field(billToAddressLine2; Rec."Bill-To Address 2")
                {
                    Caption = 'Bill-to Address Line 2';
                    Editable = false;
                }
                field(billToCity; Rec."Bill-To City")
                {
                    Caption = 'Bill-to City';
                    Editable = false;
                }
                field(billToCountry; Rec."Bill-To Country/Region Code")
                {
                    Caption = 'Bill-to Country/Region Code';
                    Editable = false;
                }
                field(billToState; Rec."Bill-To County")
                {
                    Caption = 'Bill-to State';
                    Editable = false;
                }
                field(billToPostCode; Rec."Bill-To Post Code")
                {
                    Caption = 'Bill-to Post Code';
                    Editable = false;
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
                field(currencyCode; CurrencyCodeTxt)
                {
                    Caption = 'Currency Code';
                }
                field(orderNumber; Rec."Order No.")
                {
                    Caption = 'Order No.';
                    Editable = false;
                }
                field(paymentTermsCode; Rec."Payment Terms Code")
                {
                    Caption = 'Payment Terms Code';
                }
                field(shipmentMethodCode; Rec."Shipment Method Code")
                {
                    Caption = 'Shipment Method Code';
                }
                field(salesperson; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson';
                }
                field(pricesIncludeTax; Rec."Prices Including VAT")
                {
                    Caption = 'Prices Include Tax';
                    Editable = false;
                }
                part(salesShipmentLines; "APIV2 - Sales Shipment Lines")
                {
                    Caption = 'Lines';
                    EntityName = 'salesShipmentLine';
                    EntitySetName = 'salesShipmentLines';
                    SubPageLink = "Document Id" = field(SystemId);
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
                field(phoneNumber; Rec."Sell-to Phone No.")
                {
                    Caption = 'Phone No.';
                }
                field(email; Rec."Sell-to E-Mail")
                {
                    Caption = 'Email';
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = field(SystemId), "Parent Type" = const("Sales Shipment");
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
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, Rec."Currency Code");
    end;
}