page 30048 "APIV2 - Cust Financial Details"
{
    PageType = API;
    APIVersion = 'v2.0';
    EntityName = 'customerFinancialDetail';
    EntitySetName = 'customerFinancialDetails';
    EntityCaption = 'Customer Financial Detail';
    EntitySetCaption = 'Customer Financial Details';
    SourceTable = Customer;
    Editable = false;
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    DelayedInsert = true;
    Extensible = false;


    layout
    {
        area(Content)
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
                field(balance; "Balance (LCY)")
                {
                    Caption = 'Balance';
                    Editable = false;
                }
                field(totalSalesExcludingTax; "Sales (LCY)")
                {
                    Caption = 'Total Sales Excluding Tax';
                    Editable = false;
                }
                field(overdueAmount; "Balance Due (LCY)")
                {
                    Caption = 'Overdue Amount';
                    Editable = false;
                }
            }
        }

    }

    actions
    {
    }
    trigger OnAfterGetRecord()
    begin
        SetRange("Date Filter", 0D, WorkDate() - 1);
        CalcFields("Balance Due (LCY)", "Sales (LCY)", "Balance (LCY)");
    end;

}