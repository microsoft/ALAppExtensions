pageextension 20601 "Accountant Role Center BF" extends "Accountant Role Center"
{
    actions
    {
        modify("Purchase Orders") //US: The action '"Purchase Orders"' is not found in the target 'Accountant Role Center'
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}