namespace Microsoft.SubscriptionBilling;

page 8020 "Service Object API"
{
    APIGroup = 'subsBilling';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    EntityName = 'serviceObject';
    EntitySetName = 'serviceObjects';
    PageType = API;
    SourceTable = "Service Object";
    ODataKeyFields = SystemId;
    Extensible = false;
    Editable = false;
    DataAccessIntent = ReadOnly;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(systemId; Rec.SystemId)
                {
                }
                field(endUserCustomerNo; Rec."End-User Customer No.")
                {
                }
                field(no; Rec."No.")
                {
                }
                field(billToCustomerNo; Rec."Bill-to Customer No.")
                {
                }
                field(billToName; Rec."Bill-to Name")
                {
                }
                field(billToName2; Rec."Bill-to Name 2")
                {
                }
                field(billToAddress; Rec."Bill-to Address")
                {
                }
                field(billToAddress2; Rec."Bill-to Address 2")
                {
                }
                field(billToCity; Rec."Bill-to City")
                {
                }
                field(billToContact; Rec."Bill-to Contact")
                {
                }
                field(shipToCode; Rec."Ship-to Code")
                {
                }
                field(shipToName; Rec."Ship-to Name")
                {
                }
                field(shipToName2; Rec."Ship-to Name 2")
                {
                }
                field(shipToAddress; Rec."Ship-to Address")
                {
                }
                field(shipToAddress2; Rec."Ship-to Address 2")
                {
                }
                field(shipToCity; Rec."Ship-to City")
                {
                }
                field(shipToContact; Rec."Ship-to Contact")
                {
                }
                field(itemNo; Rec."Item No.")
                {
                }
                field(description; Rec.Description)
                {
                }
                field(serialNo; Rec."Serial No.")
                {
                }
                field("version"; Rec."Version")
                {
                }
                field("key"; Rec."Key")
                {
                }
                field(provisionStartDate; Rec."Provision Start Date")
                {
                }
                field(provisionEndDate; Rec."Provision End Date")
                {
                }
                field(quantityDecimal; Rec."Quantity Decimal")
                {
                }
                field(customerPriceGroup; Rec."Customer Price Group")
                {
                }
                field(endUserCustomerName; Rec."End-User Customer Name")
                {
                }
                field(endUserCustomerName2; Rec."End-User Customer Name 2")
                {
                }
                field(endUserAddress; Rec."End-User Address")
                {
                }
                field(endUserAddress2; Rec."End-User Address 2")
                {
                }
                field(endUserCity; Rec."End-User City")
                {
                }
                field(endUserContact; Rec."End-User Contact")
                {
                }
                field(billToPostCode; Rec."Bill-to Post Code")
                {
                }
                field(billToCounty; Rec."Bill-to County")
                {
                }
                field(billToCountryRegionCode; Rec."Bill-to Country/Region Code")
                {
                }
                field(endUserPostCode; Rec."End-User Post Code")
                {
                }
                field(endUserCounty; Rec."End-User County")
                {
                }
                field(endUserCountryRegionCode; Rec."End-User Country/Region Code")
                {
                }
                field(shipToPostCode; Rec."Ship-to Post Code")
                {
                }
                field(shipToCounty; Rec."Ship-to County")
                {
                }
                field(shipToCountryRegionCode; Rec."Ship-to Country/Region Code")
                {
                }
                field(customerReference; Rec."Customer Reference")
                {
                }
                field(archivedServiceCommitments; Rec."Archived Service Commitments")
                {
                }
                field(noSeries; Rec."No. Series")
                {
                }
                field(endUserPhoneNo; Rec."End-User Phone No.")
                {
                }
                field(endUserEMail; Rec."End-User E-Mail")
                {
                }
                field(endUserFaxNo; Rec."End-User Fax No.")
                {
                }
                field(plannedServCommExists; Rec."Planned Serv. Comm. exists")
                {
                }
                field(endUserContactNo; Rec."End-User Contact No.")
                {
                }
                field(billToContactNo; Rec."Bill-to Contact No.")
                {
                }
                field(unitOfMeasure; Rec."Unit of Measure")
                {
                }
            }
        }
    }
}
