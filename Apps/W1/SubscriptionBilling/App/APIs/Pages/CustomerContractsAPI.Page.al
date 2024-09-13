namespace Microsoft.SubscriptionBilling;

page 8024 "Customer Contracts API"
{
    APIGroup = 'subsBilling';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    EntityName = 'customerContract';
    EntitySetName = 'customerContracts';
    PageType = API;
    SourceTable = "Customer Contract";
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
                field(sellToCustomerNo; Rec."Sell-to Customer No.")
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
                field(yourReference; Rec."Your Reference")
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
                field(paymentTermsCode; Rec."Payment Terms Code")
                {
                }
                field(shortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                {
                }
                field(shortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
                {
                }
                field(currencyCode; Rec."Currency Code")
                {
                }
                field(salespersonCode; Rec."Salesperson Code")
                {
                }
                field(sellToCustomerName; Rec."Sell-to Customer Name")
                {
                }
                field(sellToCustomerName2; Rec."Sell-to Customer Name 2")
                {
                }
                field(sellToAddress; Rec."Sell-to Address")
                {
                }
                field(sellToAddress2; Rec."Sell-to Address 2")
                {
                }
                field(sellToCity; Rec."Sell-to City")
                {
                }
                field(sellToContact; Rec."Sell-to Contact")
                {
                }
                field(billToPostCode; Rec."Bill-to Post Code")
                {
                }
                field(billToCounty; Rec."Bill-to County")
                {
                }
                field(sellToPostCode; Rec."Sell-to Post Code")
                {
                }
                field(sellToCounty; Rec."Sell-to County")
                {
                }
                field(sellToCountryRegionCode; Rec."Sell-to Country/Region Code")
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
                field(paymentMethodCode; Rec."Payment Method Code")
                {
                }
                field(noSeries; Rec."No. Series")
                {
                }
                field(description; Rec.Description)
                {
                }
                field(sellToContactNo; Rec."Sell-to Contact No.")
                {
                }
                field(billToContactNo; Rec."Bill-to Contact No.")
                {
                }
                field(assignedUserID; Rec."Assigned User ID")
                {
                }
                field(active; Rec.Active)
                {
                }
                field(contractType; Rec."Contract Type")
                {
                }
                field(descriptionPreview; Rec."Description Preview")
                {
                }
                field(withoutContractDeferrals; Rec."Without Contract Deferrals")
                {
                }
                field(detailOverview; Rec."Detail Overview")
                {
                }
                field(billingRhytmFilter; Rec."Billing Rhythm Filter")
                {
                }
                field(dimensionFromJobNo; Rec."Dimension from Job No.")
                {
                }
                field(billingBaseDate; Rec."Billing Base Date")
                {
                }
                field(defaultBillingRhythm; Rec."Default Billing Rhythm")
                {
                }
                field(nextBillingFrom; Rec."Next Billing From")
                {
                }
                field(nextBillingTo; Rec."Next Billing To")
                {
                }
                field(billToCountryRegionCode; Rec."Bill-to Country/Region Code")
                {
                }
                field(contractorNameInCollInv; Rec."Contractor Name in coll. Inv.")
                {
                }
                field(dimensionSetID; Rec."Dimension Set ID")
                {
                }
                field(recipientNameInCollInv; Rec."Recipient Name in coll. Inv.")
                {
                }
                field(shipToCode; Rec."Ship-to Code")
                {
                }
                part(customerContractLinesAPI; "Customer Contract Lines API")
                {
                    Caption = 'customerContractLines', Locked = true;
                    EntityName = 'customerContractLines';
                    EntitySetName = 'customerContractLines';
                    SubPageLink = "Contract No." = field("No.");
                }
            }
        }
    }
}
