namespace Microsoft.PowerBIReports;

using Microsoft.CRM.Team;

page 36958 "Salesperson/Purchasers"
{
    PageType = API;
    Caption = 'Power BI Salesperson/Purchasers';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'salespersonPurchaser';
    EntitySetName = 'salespersonPurchasers';
    SourceTable = "Salesperson/Purchaser";
    DelayedInsert = true;
    DataAccessIntent = ReadOnly;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(salespersonPurchaserCode; Rec."Code")
                {
                }
                field(salespersonPurchaserName; Rec.Name)
                {
                }
            }
        }
    }
}