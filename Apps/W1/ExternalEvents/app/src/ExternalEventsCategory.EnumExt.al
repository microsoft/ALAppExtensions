namespace Microsoft.Integration.ExternalEvents;

using System.Integration;

enumextension 38500 "External Events Category" extends EventCategory
/// <summary>
/// enum extension MyEventCategory exten EventCategory. This enum extensions will define the eventcategories used in this project
/// </summary>
{
    value(38500; "Accounts Receivable")
    {
        Caption = 'Accounts Receivable';
    }
    value(38501; "Accounts Payable")
    {
        Caption = 'Accounts Payable';
    }
    value(38502; "Sales")
    {
        Caption = 'Sales';
    }

    value(38503; "Purchasing")
    {
        Caption = 'Purchasing';
    }
    value(38504; "Opportunities")
    {
        Caption = 'Opportunities';
    }
}
