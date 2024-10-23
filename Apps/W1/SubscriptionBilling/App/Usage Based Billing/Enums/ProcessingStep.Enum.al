namespace Microsoft.SubscriptionBilling;

enum 8006 "Processing Step"
{
    Extensible = false;

    value(0; None)
    {
        Caption = ' ', Locked = true;
    }
    value(1; "Create Imported Lines")
    {
        Caption = 'Create Imported Lines';
    }
    value(2; "Process Imported Lines")
    {
        Caption = 'Process Imported Lines';
    }
    value(3; "Create Usage Data Billing")
    {
        Caption = 'Create Usage Data Billing';
    }
    value(4; "Process Usage Data Billing")
    {
        Caption = 'Process Usage Data Billing';
    }
}
