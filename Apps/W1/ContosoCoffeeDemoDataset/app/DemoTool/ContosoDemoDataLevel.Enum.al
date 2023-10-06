enum 5123 "Contoso Demo Data Level"
{
    Extensible = false;
    // The value of the enum needs to follow the layering of the data. e.g. All > "Setup Data" > " "

    value(0; " ")
    {
    }
    value(1; "Setup Data")
    {
    }
    value(2; "Master Data")
    {
    }
    value(3; "Transactional Data")
    {
    }
    value(4; "Historical Data")
    {
    }
    value(10; All)
    {
    }
}