enum 51751 "Bus Queue Status"
{
    Access = Internal;
    Extensible = false;
    
    value(0; Pending) 
    {
        Caption = 'Pending';
    }
    value(1; Processing) 
    {
        Caption = 'Processing';
    }
    value(2; Processed)
    {
        Caption = 'Processed';
    }
    value(3; Error)
    {
        Caption = 'Error';
    }
    value(4; Retry)
    {
        Caption = 'Retry';
    }
}