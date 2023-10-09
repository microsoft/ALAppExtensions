namespace Microsoft.API.V1;

using Microsoft.Sales.Customer;

page 20048 "Customer Financial Details"
{
    PageType = API;
    EntityName = 'customerFinancialDetail';
    EntitySetName = 'customerFinancialDetails';
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
                field(id; Rec.SystemId)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'number', Locked = true;
                    Editable = false;
                }
                field(balance; Rec."Balance (LCY)")
                {
                    Caption = 'balance', Locked = true;
                    Editable = false;
                }
                field(totalSalesExcludingTax; Rec."Sales (LCY)")
                {
                    Caption = 'totalSalesExcludingTax', Locked = true;
                    Editable = false;
                }
                field(overdueAmount; Rec."Balance Due (LCY)")
                {
                    Caption = 'overdueAmount', Locked = true;
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
        Rec.SETRANGE("Date Filter", 0D, WorkDate() - 1);
        Rec.CALCfieldS("Balance Due (LCY)", "Sales (LCY)", "Balance (LCY)");
    end;

}
