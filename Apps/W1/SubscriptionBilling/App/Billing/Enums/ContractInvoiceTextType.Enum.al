namespace Microsoft.SubscriptionBilling;

enum 8001 "Contract Invoice Text Type"
{
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; "Service Object")
    {
        Caption = 'Subscription';
    }
    value(2; "Service Commitment")
    {
        Caption = 'Subscription Line';
    }
    value(3; "Customer Reference")
    {
        Caption = 'Customer Reference';
    }
    value(4; "Serial No.")
    {
        Caption = 'Serial No.';
    }
    value(5; "Billing Period")
    {
        Caption = 'Billing Period';
    }
    value(6; "Primary attribute")
    {
        Caption = 'Primary attribute';
    }
}